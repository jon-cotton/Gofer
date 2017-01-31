//
//  Parameter.swift
//  Gofer
//
//  Created by Cotton, Jonathan (Mobile Developer) on 27/01/2017.
//  Copyright © 2017 Sky UK. All rights reserved.
//

import Foundation

private let argumentSeperator = ":"

enum Parameter {
    case argument(String, description: String, defaultValue: String?)
    case option(String, description: String)
    case flag(Character, description: String)

    // TODO: Tidy up, is this going to use Enamel?
    func argumentValue(from command: String) throws -> Argument? {
        switch self {
            case let .argument(name, _, defaultValue):
                let regex = try! NSRegularExpression(pattern: "\(name):.[^\\s]+", options: .caseInsensitive)
                let range = NSRange(location: 0, length: command.characters.count)
                if let match = regex.firstMatch(in: command, options: .reportCompletion, range: range) {
                    let arg = NSString(string: command).substring(with: match.range)
                    let argComponents = arg.components(separatedBy: argumentSeperator)

                    guard argComponents.count == 2 else {
                        throw Error.parameterHasNoValue(self)
                    }

                    return Argument(parameter: self, value: argComponents.last!)
                } else {
                    guard defaultValue != nil else {
                        throw Error.requiredParameterNotSupplied(self)
                    }

                    return Argument(parameter: self, value: defaultValue!)
                }

            case .flag, .option: return nil
        }
    }

    func optionValue(from command: String) -> Option? {
        switch self {
            case .argument: return nil
            case let .flag(chr, _): return Option(parameter: self, value: command.contains("-\(chr)"))
            case let .option(name, _): return Option(parameter: self, value: command.contains("--\(name)"))
        }
    }

    var name: String {
        switch self {
            case .argument(let name, _, _): return name
            case .option(let name, _): return name
            case .flag(let name, _): return String(name)
        }
    }

    var isArgument: Bool {
        switch self {
            case .argument: return true
            default: return false
        }
    }

    var isOption: Bool {
        switch self {
            case .option, .flag: return true
            default: return false
        }
    }
}

extension Parameter {
    enum Error: Swift.Error {
        case requiredParameterNotSupplied(Parameter)
        case parameterHasNoValue(Parameter)
    }
}

protocol AnyArgument {
    var parameter: Parameter {get}
}

protocol OptionArgument: AnyArgument {
    var value: Bool {get}
    var isEnabled: Bool {get}
}

struct Argument: AnyArgument {
    let parameter: Parameter
    let value: String
}

struct Option: OptionArgument {
    let parameter: Parameter
    let value: Bool
    var isEnabled: Bool {
        return value
    }
}

extension Collection where Iterator.Element: AnyArgument {
    subscript(key: String) -> Iterator.Element? {
        return filter { $0.parameter.name == key }.first
    }
}

extension Optional where Wrapped: OptionArgument {
    var isEnabled: Bool {
        switch self {
            case .some(let option): return option.isEnabled
            case .none: return false
        }
    }
}
