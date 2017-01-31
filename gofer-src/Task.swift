//
//  Task.swift
//  Gofer
//
//  Created by Cotton, Jonathan (Mobile Developer) on 27/01/2017.
//  Copyright © 2017 Sky UK. All rights reserved.
//

import Foundation

struct Task {
    private(set) static var tasks: [String: Task] = [:]

    let name: String
    let description: String
    let parameters: [Parameter]
    let task: ([Argument], [Option], [String: String]) -> ()

    init(_ name: String, description: String, parameters: [Parameter] = [], task: @escaping ([Argument], [Option], [String: String]) -> () = {_,_,_ in }) {
        self.name = name
        self.description = description
        self.parameters = parameters
        self.task = task
    }

    init(_ name: String, description: String, parameters: Parameter..., task: @escaping ([Argument], [Option], [String: String]) -> ()) {
        self.init(name, description: description, parameters: parameters, task: task)
    }

    func parameter(_ name: String, description: String? = nil, defaultValue: String? = nil) -> Task {
        let newParam = Parameter.argument(name, description: description ?? "", defaultValue: defaultValue)
        return Task(self.name, description: self.description, parameters: parameters + [newParam], task: task)
    }

    func parameters(_ names: String...) -> Task {
        let newParams = names.map { Parameter.argument($0, description: "", defaultValue: nil) }
        return Task(name, description: description, parameters: parameters + newParams, task: task)
    }

    func option(_ name: String, description: String? = nil, defaultValue: Bool? = nil) -> Task {
        let newParam = Parameter.option(name, description: description ?? "")
        return Task(self.name, description: self.description, parameters: parameters + [newParam], task: task)
    }

    func options(_ names: String...) -> Task {
        let newParams = names.map { Parameter.option($0, description: "") }
        return Task(name, description: description, parameters: parameters + newParams, task: task)
    }

    func flag(_ name: Character, description: String? = nil, defaultValue: Bool? = nil) -> Task {
        let newParam = Parameter.flag(name, description: description ?? "")
        return Task(self.name, description: self.description, parameters: parameters + [newParam], task: task)
    }

    func flags(_ names: Character...) -> Task {
        let newParams = names.map { Parameter.flag($0, description: "") }
        return Task(name, description: description, parameters: parameters + newParams, task: task)
    }

    func register(closure: @escaping ([Argument], [Option], [String: String]) -> ()) {
        Task.tasks[name] = Task(name, description: description, parameters: parameters, task: closure)
    }
}

extension Task {
    static func named(_ name: String) -> Task? {
        return tasks[name]
    }

    var usage: String {
        return "\(name) usage:\n"
    }
}
