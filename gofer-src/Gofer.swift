//
//  main.swift
//  Gofer
//
//  Created by Cotton, Jonathan (Mobile Developer) on 27/01/2017.
//  Copyright © 2017 Sky UK. All rights reserved.
//

import Foundation

/**
 Example Task

Task("release", description: "Build a new release version of the app to an .ipa file")
    .parameter("version", description: "The version you would like to release")
    .parameter("configuration", description: "The build config you would like to use for the release", defaultValue: "Release")
    .options("verbose", "skip-tagging", "deliver-to-testflight")
    .flags("v", "s", "d")
    .register
{ args, options in
    if options["verbose"].isEnabled || options["v"].isEnabled {
        print("verbose is on!")
    }

    if args["version"]?.value == "6.0" {
        print("this is really version 1.0 ;)")
    }
}
*/

let envVars = ProcessInfo.processInfo.environment as [String: String]
let args = CommandLine.arguments
let command = args.reduce("") { "\($0) \($1)" }

guard args.count > 1 else {
    print("Tasks: \(Task.tasks.reduce("") { "\($0)\n\($1.0) - \($1.1.description)" } )")
    exit(0)
}

guard let task = Task.named(args[1]) else {
    print("Task not found")
    exit(1)
}

do {
    let taskArgs = try task.parameters.filter { $0.isArgument }.flatMap { try $0.argumentValue(from: command) }
    let taskOptions = task.parameters.filter { $0.isOption }.flatMap { $0.optionValue(from: command) }

    task.task(taskArgs, taskOptions, envVars)
} catch {
    print(task.usage)
    exit(0)
}
