Task("release", description: "Build a new release version of the app to an .ipa file")
    .parameter("version", description: "The version you would like to release")
    .parameter("configuration", description: "The build config you would like to use for the release", defaultValue: "Release")
    .options("verbose", "skip-tagging", "deliver-to-testflight")
    .flags("v", "s", "d")
    .register
{ args, options, env in
    if options["verbose"].isEnabled || options["v"].isEnabled {
        print("verbose is on!")
    }

    if args["version"]?.value == "6.0" {
        print("this is really version 1.0 ;)")
    }
}
