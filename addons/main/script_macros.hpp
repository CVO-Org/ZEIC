#ifndef DOUBLES
    #define DOUBLES(var1,var2) var1##_##var2
    #define TRIPLES(var1,var2,var3) var1##_##var2##_##var3
    #define QUOTE(var1) #var1
#endif

#ifndef Q
    #define Q(var1) #var1
#endif

#ifndef PVAR
    #define PVAR(var1) DOUBLES(PREFIX,var1)
    #define QPVAR(var1) QUOTE(PVAR(var1))
#endif

#ifndef PFUNC
    #define PFUNC(var1) TRIPLES(PREFIX,fnc,var1)
    #define QPFUNC(var1) QUOTE(PFUNC(var1))
#endif

#ifndef ADDON_NAME
    #define ADDON_NAME Q(PREFIX_BEAUTIFIED - COMPONENT_BEAUTIFIED)
#endif

#ifndef PATH_TO_FUNC_SUB
    #define PATH_TO_FUNC_SUB(var1) QUOTE(\MAINPREFIX\PREFIX\addons\COMPONENT\functions\var1)
#endif

#ifndef VERSION
    #define VERSION 0
#endif

#ifndef VERSION_STR
    #define VERSION_STR VERSION
#endif

#ifndef VERSION_AR
    #define VERSION_AR VERSION
#endif

#ifndef VERSION_CONFIG
    #define VERSION_CONFIG version = VERSION; versionStr = QUOTE(VERSION_STR); versionAr[] = {VERSION_AR}
#endif

#ifndef LSTRING
    #define LSTRING(var1) QUOTE(TRIPLES(STR,ADDON,var1))
    #define ELSTRING(var1,var2) QUOTE(TRIPLES(STR,DOUBLES(PREFIX,var1),var2))
#endif

#ifndef CSTRING
    #define CSTRING(var1) QUOTE(TRIPLES($STR,ADDON,var1))
    #define ECSTRING(var1,var2) QUOTE(TRIPLES($STR,DOUBLES(PREFIX,var1),var2))
#endif

#ifndef LLSTRING
    #define LLSTRING(var1) localize QUOTE(TRIPLES(STR,ADDON,var1))
    #define LELSTRING(var1,var2) localize QUOTE(TRIPLES(STR,DOUBLES(PREFIX,var1),var2))
#endif
