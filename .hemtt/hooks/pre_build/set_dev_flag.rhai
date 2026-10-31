// Release builds: switch the development features off (self test on scenario start)
if HEMTT.is_release() {
    HEMTT_VFS.join("addons").join("main").join("script_dev.hpp")
        .create_file()
        .write("#define _ZEIC_DEV_ 0\n");
    print("_ZEIC_DEV_ set to 0");
}
