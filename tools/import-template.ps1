<#
.SYNOPSIS
    Merges a "Template submission" issue into the matching addons\templates_*\CfgZEIC.hpp.

.DESCRIPTION
    Reads the issue body (gh issue view <n> --json body), takes the category and the required mods
    from the form and the template from the pasted config, and adds it to the template pack of its
    heaviest dependency:

        None (vanilla) -> templates_vanilla       CUP -> templates_cup      GM    -> templates_gm
        SOG            -> templates_sog           WS  -> templates_ws       OPTRE -> templates_optre

    Existing templates are never changed. Every new template gets the pack's tag plus the next free
    number in that building (vanilla_3, cup_2, ...), the building class is created if needed (sorted in),
    and an identical layout that is already there is skipped. Only the objects[] entries are taken over,
    and every entry must look like {"Class", {x, y, z}, dir} or {"Class", {x, y, z}, dir, {x, y, z}}:
    anything else in the paste stops the script.

    The script only edits the file. Review the diff, test in game and commit yourself
    (steps: CONTRIBUTING.md, "Merging submissions").

.PARAMETER Issue
    Number of the submission issue (read with gh, needs gh auth login).

.PARAMETER BodyFile
    Read the issue body from a file instead (for tests, or an issue copied by hand).

.PARAMETER Pack
    Force the pack (vanilla, cup, gm, sog, ws, optre), for example when the form names two mods.

.PARAMETER DryRun
    Show what would be added without writing the file.

.EXAMPLE
    powershell -ExecutionPolicy Bypass -File tools\import-template.ps1 -Issue 123

.EXAMPLE
    powershell -ExecutionPolicy Bypass -File tools\import-template.ps1 -BodyFile body.md -DryRun
#>
[CmdletBinding(DefaultParameterSetName = 'Issue')]
param (
    [Parameter(ParameterSetName = 'Issue', Mandatory = $true, Position = 0)]
    [int]$Issue,

    [Parameter(ParameterSetName = 'File', Mandatory = $true)]
    [string]$BodyFile,

    [string]$Repo = 'CVO-Org/ZEIC',

    [ValidateSet('vanilla', 'cup', 'gm', 'sog', 'ws', 'optre')]
    [string]$Pack,

    [switch]$DryRun
)

$ErrorActionPreference = 'Stop'
$root = Split-Path $PSScriptRoot -Parent
$packs = @('vanilla', 'cup', 'gm', 'sog', 'ws', 'optre')

# ---------------------------------------------------------------- read the issue

if ($PSCmdlet.ParameterSetName -eq 'Issue') {
    [Console]::OutputEncoding = [Text.Encoding]::UTF8
    $json = gh issue view $Issue --repo $Repo --json body,state,labels,title
    if ($LASTEXITCODE -ne 0) { throw "gh issue view $Issue failed (gh auth login?)" }
    $issueData = ($json -join "`n") | ConvertFrom-Json
    if ($issueData.state -ne 'OPEN') { Write-Warning "Issue #$Issue is $($issueData.state)." }
    if (-not ($issueData.labels | Where-Object { $_.name -eq 'template submission' })) {
        Write-Warning "Issue #$Issue has no 'template submission' label."
    }
    $body = $issueData.body
    $source = "#$Issue"
} else {
    $body = [IO.File]::ReadAllText((Resolve-Path $BodyFile))
    $source = Split-Path $BodyFile -Leaf
}
$body = $body -replace "`r`n", "`n"

# Issue forms render every field as "### Label" followed by the value ("_No response_" when empty)
$sections = @{}
foreach ($part in ([regex]::Split("`n" + $body, '\n### ') | Select-Object -Skip 1)) {
    $nl = $part.IndexOf("`n")
    if ($nl -lt 0) { $sections[$part.Trim()] = ''; continue }
    $value = $part.Substring($nl + 1).Trim()
    if ($value -eq '_No response_') { $value = '' }
    $sections[$part.Substring(0, $nl).Trim()] = $value
}

foreach ($field in 'Building class', 'Category', 'Required mods', 'Template') {
    if (-not $sections[$field]) { throw "The issue has no '$field' field. Is it a Template submission?" }
}

$config = $sections['Template']
$fence = [regex]::Match($config, '(?s)```[\w+-]*\n(.*?)\n?```')
if ($fence.Success) { $config = $fence.Groups[1].Value }

$category = $sections['Category'].Trim()
if ($category -notmatch '^\w+$') { throw "Category '$category' is not a class name." }

# ---------------------------------------------------------------- config parser

function New-ConfigNode([string]$Name, [string]$Base, [int]$Start, $Parent) {
    [pscustomobject]@{
        Name       = $Name
        Base       = $Base
        Start      = $Start   # index of "class"
        Open       = -1       # index of "{", -1 for "class X;"
        Close      = -1       # index of the matching "}"
        Parent     = $Parent
        Children   = New-Object System.Collections.Generic.List[object]
        HasObjects = $false
    }
}

# Class tree of a config text. Braces in strings and comments don't count, array braces are matched but not kept.
function Read-ConfigTree([string]$Text) {
    $tree = New-ConfigNode '' '' 0 $null
    $tree.Close = $Text.Length
    $stack = New-Object System.Collections.Stack
    $stack.Push($tree)
    $pattern = '//[^\n]*|/\*.*?\*/|"(?:[^"]|"")*"|\bclass\s+(\w+)\s*(?::\s*(\w+))?\s*([{;])|\bobjects\[\]\s*=|[{}]'
    foreach ($m in [regex]::Matches($Text, $pattern, 'Singleline')) {
        $v = $m.Value
        if ($v.StartsWith('//') -or $v.StartsWith('/*') -or $v.StartsWith('"')) { continue }
        $top = $stack.Peek()
        if ($m.Groups[1].Success) {
            if ($top -isnot [pscustomobject]) { throw "Class $($m.Groups[1].Value) inside an array." }
            $node = New-ConfigNode $m.Groups[1].Value $m.Groups[2].Value $m.Index $top
            $top.Children.Add($node)
            if ($m.Groups[3].Value -eq '{') {
                $node.Open = $m.Index + $m.Length - 1
                $stack.Push($node)
            } else {
                $node.Close = $m.Index + $m.Length - 1
            }
        } elseif ($v.StartsWith('objects')) {
            if ($top -is [pscustomobject]) { $top.HasObjects = $true }
        } elseif ($v -eq '{') {
            $stack.Push('array')
        } else {
            if ($stack.Count -le 1) { throw "Unbalanced '}' at character $($m.Index)." }
            $closed = $stack.Pop()
            if ($closed -is [pscustomobject]) { $closed.Close = $m.Index }
        }
    }
    if ($stack.Count -ne 1) { throw "Unbalanced '{': $($stack.Count - 1) not closed." }
    $tree
}

function Find-Child($Node, [string]$Name) {
    $Node.Children | Where-Object { $_.Name -eq $Name } | Select-Object -First 1   # -eq ignores case, like Arma
}

function Get-AllNodes($Node) {
    foreach ($child in $Node.Children) { $child; Get-AllNodes $child }
}

# Object entries of a template body, checked and in one canonical form. $null when the body has anything else.
$number = '-?\d+(?:\.\d+)?(?:[eE][-+]?\d+)?'
$entryPattern = "\{\s*""([\w-]+)""\s*,\s*\{\s*($number)\s*,\s*($number)\s*,\s*($number)\s*\}\s*(?:,\s*($number)\s*)?(?:,\s*\{\s*($number)\s*,\s*($number)\s*,\s*($number)\s*\}\s*)?\}"
function Get-ObjectEntries([string]$Body) {
    $bodyNoComments = [regex]::Replace($Body, '//[^\n]*|/\*.*?\*/', '', 'Singleline')
    $entries = @()
    foreach ($m in [regex]::Matches($bodyNoComments, $entryPattern)) {
        $g = $m.Groups
        $entry = '{"' + $g[1].Value + '", {' + $g[2].Value + ', ' + $g[3].Value + ', ' + $g[4].Value + '}'
        $dir = $g[5].Value; if (-not $dir) { $dir = '0' }
        $entry += ', ' + $dir
        if ($g[6].Success) { $entry += ', {' + $g[6].Value + ', ' + $g[7].Value + ', ' + $g[8].Value + '}' }
        $entries += $entry + '}'
    }
    $rest = [regex]::Replace($bodyNoComments, $entryPattern, '') -replace '[\s,]', ''
    if ($rest -ne 'objects[]={};') { return $null }
    , $entries
}

# ---------------------------------------------------------------- the submitted templates

$submission = Read-ConfigTree $config
$submitted = @(Get-AllNodes $submission | Where-Object { $_.HasObjects })
if ($submitted.Count -eq 0) { throw 'The pasted config has no template (a class with objects[]).' }

$templates = foreach ($node in $submitted) {
    if (-not $node.Parent.Name) { throw "Template $($node.Name) is not inside a building class." }
    if ($node.Children.Count -gt 0) { throw "Template $($node.Name) has subclasses." }
    $entries = Get-ObjectEntries $config.Substring($node.Open + 1, $node.Close - $node.Open - 1)
    if ($null -eq $entries) { throw "Template $($node.Name) has more than objects[] entries, or an entry that doesn't parse. Check it by hand." }
    if ($entries.Count -eq 0) { throw "Template $($node.Name) has no objects." }
    [pscustomobject]@{ Building = $node.Parent.Name; Name = $node.Name; Entries = $entries }
}

$formBuilding = $sections['Building class'].Trim()
foreach ($t in $templates) {
    if ($t.Building -ne $formBuilding) { Write-Warning "The form says building '$formBuilding', the config '$($t.Building)'. Using the config." }
}

# ---------------------------------------------------------------- the pack

# Mods from the form and from the "// Required mods:" line of the paste: the heaviest one decides
$modText = $sections['Required mods']
$header = [regex]::Match($config, '//\s*Required mods:\s*([^\n]*)')
if ($header.Success) { $modText += ', ' + $header.Groups[1].Value }

$needs = @()
$others = @()
foreach ($mod in ($modText -split ',') | ForEach-Object { $_.Trim() } | Where-Object { $_ }) {
    $key = ($mod -split '[\s(:]')[0].ToLowerInvariant()
    if ($key -eq 'none') { continue }
    if ($packs -contains $key) { if ($needs -notcontains $key) { $needs += $key } } else { $others += $mod }
}

if (-not $Pack) {
    if ($others.Count -gt 0) { throw "Required mods without a pack: $($others -join ', '). Decide by hand, or pass -Pack." }
    if ($needs.Count -gt 1) { throw "The template needs $($needs -join ' and '). There is no combined pack: decide by hand, or pass -Pack." }
    $Pack = 'vanilla'
    if ($needs.Count -eq 1) { $Pack = $needs[0] }
} elseif ($needs.Count -gt 0 -and $needs -notcontains $Pack) {
    Write-Warning "Using -Pack $Pack, but the submission names: $($needs -join ', ')."
}

$target = Join-Path $root "addons\templates_$Pack\CfgZEIC.hpp"
if (-not (Test-Path $target)) { throw "$target not found." }

# ---------------------------------------------------------------- merge

$utf8 = New-Object System.Text.UTF8Encoding($false)
$text = [IO.File]::ReadAllText($target)
$nl = "`n"
if ($text.Contains("`r`n")) { $nl = "`r`n" }

function Get-LineStart([string]$Text, [int]$Index) { $Text.LastIndexOf("`n", [Math]::Max($Index - 1, 0)) + 1 }

function Format-Template([string]$Name, [string[]]$Entries, [string]$Indent) {
    $lines = @("$Indent    class $Name {", "$Indent        objects[] = {")
    for ($i = 0; $i -lt $Entries.Count; $i++) {
        $comma = ''; if ($i -lt $Entries.Count - 1) { $comma = ',' }
        $lines += "$Indent            $($Entries[$i])$comma"
    }
    $lines += "$Indent        };", "$Indent    };"
    $lines
}

$added = @()
foreach ($t in $templates) {
    $tree = Read-ConfigTree $text
    $cfg = Find-Child $tree 'CfgZEIC'
    if (-not $cfg) { throw "$target has no class CfgZEIC." }
    $cat = Find-Child $cfg $category
    $building = $null
    if ($cat) { $building = Find-Child $cat $t.Building }

    # Template names of the building and the classes it inherits from, and their layouts
    $names = @()
    $layouts = @()
    $node = $building
    while ($node) {
        foreach ($tpl in $node.Children) {
            $names += $tpl.Name
            if ($tpl.Open -ge 0) { $layouts += ((Get-ObjectEntries $text.Substring($tpl.Open + 1, $tpl.Close - $tpl.Open - 1)) -join '|') }
        }
        $node = if ($node.Base) { Find-Child $cat $node.Base } else { $null }
    }
    if ($layouts -contains ($t.Entries -join '|')) {
        Write-Warning "$category >> $($t.Building): the same layout is already in templates_$Pack, skipped ($($t.Name))."
        continue
    }

    $n = 1
    foreach ($name in $names) {
        if ($name -match "^$Pack`_(\d+)$" -and [int]$Matches[1] -ge $n) { $n = [int]$Matches[1] + 1 }
    }
    $newName = "$Pack`_$n"

    if (-not $cat) {
        Write-Warning "templates_$Pack has no category '$category' yet, it is created. Is the category defined somewhere (addons/core/CfgZEIC.hpp)?"
        $at = Get-LineStart $text $cfg.Close
        $block = @("    class $category {", "        class $($t.Building) {") + (Format-Template $newName $t.Entries '        ') + @('        };', '    };')
    } elseif (-not $building) {
        # Sorted in among the buildings with their own templates, before the inheriting ones
        $siblings = $cat.Children.ToArray()
        $next = $siblings | Where-Object { -not $_.Base -and [string]::Compare($_.Name, $t.Building, [StringComparison]::OrdinalIgnoreCase) -gt 0 } | Select-Object -First 1
        if (-not $next) { $next = $siblings | Where-Object { $_.Base } | Select-Object -First 1 }
        if ($next) { $at = Get-LineStart $text $next.Start } else { $at = Get-LineStart $text $cat.Close }
        $block = @("        class $($t.Building) {") + (Format-Template $newName $t.Entries '        ') + @('        };')
    } else {
        $at = Get-LineStart $text $building.Close
        $block = Format-Template $newName $t.Entries '        '
        if ($text.Substring($at, $building.Close - $at).Trim()) {
            # "class X: Y {};" on one line: open it up
            if ($text.Substring($building.Open + 1, $building.Close - $building.Open - 1).Trim()) {
                throw "$category >> $($t.Building) in $target has an unusual layout, add $newName by hand."
            }
            $inner = (@('{') + $block + @('        }')) -join $nl
            $text = $text.Substring(0, $building.Open) + $inner + $text.Substring($building.Close + 1)
            $added += "$category >> $($t.Building) >> $newName"
            continue
        }
    }

    $text = $text.Insert($at, (($block -join $nl) + $nl))
    $added += "$category >> $($t.Building) >> $newName"
    if ($DryRun) { Write-Host ($block -join "`n") }
}

if ($added.Count -eq 0) { Write-Host 'Nothing to add.'; return }

$relative = "addons\templates_$Pack\CfgZEIC.hpp"
if ($DryRun) {
    Write-Host "Dry run, $relative not written. Would add from ${source}:"
} else {
    [IO.File]::WriteAllText($target, $text, $utf8)
    Write-Host "Added to $relative from ${source}:"
}
$added | ForEach-Object { Write-Host "  $_" }
if (-not $DryRun) {
    Write-Host ''
    Write-Host 'Next: review "git diff", run "hemtt check", test it in game, then commit (CONTRIBUTING.md, "Merging submissions").'
}
