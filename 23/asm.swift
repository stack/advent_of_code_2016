import Foundation

enum Arg {
    case int(Int)
    case empty
    case register(String)

    static func parse(value: String?) -> Arg {
        guard let arg = value else {
            return .empty
        }

        if ["a", "b", "c", "d"].contains(arg) {
            return .register(arg)
        } else {
            return .int(Int(arg)!)
        }
    }

    func toString() -> String {
        var value: String

        switch self {
        case .int(let x):
            value = String(x)
        case .empty:
            value = ""
        case .register(let x):
            value = x
        }

        while value.characters.count < 3 {
            value = " " + value
        }

        return value
    }
}

enum Op {
    case cpy
    case dec
    case inc
    case jnz
    case tgl

    func toString() -> String {
        switch self {
        case .cpy: return "cpy"
        case .dec: return "dec"
        case .inc: return "inc"
        case .jnz: return "jnz"
        case .tgl: return "tgl"
        }
    }
}

struct Instruction {
    let op: Op
    let arg1: Arg
    let arg2: Arg

    static func parse(instruction: String) -> Instruction {
        // Get the parts of the input
        let parts = instruction.components(separatedBy: " ")

        // Convert arguments
        let arg1 = Arg.parse(value: parts[1])

        let arg2: Arg
        if parts.count > 2 {
            arg2 = Arg.parse(value: parts[2])
        } else {
            arg2 = .empty
        }

        // Build the proper operator
        let op: Op
        switch parts[0] {
        case "cpy": op = .cpy
        case "dec": op = .dec
        case "inc": op = .inc
        case "jnz": op = .jnz
        case "tgl": op = .tgl
        default:
            fatalError("Invalid op: \(parts[0])")
        } 

        return Instruction(op: op, arg1: arg1, arg2: arg2)
    }

    func toggle() -> Instruction {
        switch arg2 {
        case .empty:
            if op == .inc {
                return Instruction(op: .dec, arg1: arg1, arg2: arg2)
            } else {
                return Instruction(op: .inc, arg1: arg1, arg2: arg2)
            }
        default:
            if op == .jnz {
                return Instruction(op: .cpy, arg1: arg1, arg2: arg2)
            } else {
                return Instruction(op: .jnz, arg1: arg1, arg2: arg2)
            }
        }
    }

    func toString() -> String {
        let opString = op.toString()
        let arg1String = arg1.toString()
        let arg2String = arg2.toString()

        return "\(opString) \(arg1String) \(arg2String)"
    }
}


class Computer {

    var registers = [Int]()
    var instructions = [Instruction]()
    var ptr = 0

    let shouldPrint: Bool

    init(registers: [Int], shouldPrint: Bool) {
        self.registers = registers
        self.shouldPrint = shouldPrint
    }

    func parse(instruction: String) {
        let instruction = Instruction.parse(instruction: instruction)
        instructions.append(instruction)
    }

    func printState() {
        guard shouldPrint else {
            return
        }

        for (idx, instruction) in instructions.enumerated() {
            let pointer = (idx == ptr) ? "> " : "  "
            let instructionString = instruction.toString()

            let registerString: String
            if idx == 0 {
                registerString = "a: \(registers[0])"
            } else if idx == 1 {
                registerString = "b: \(registers[1])"
            } else if idx == 2 {
                registerString = "c: \(registers[2])"
            } else if idx == 3 {
                registerString = "d: \(registers[3])"
            } else {
                registerString = ""
            }

            print("\(pointer) \(instructionString) | \(registerString)")
        }
    }

    func run() {
        printState()

        while ptr < instructions.count {
            let current = instructions[ptr]

            switch current.op {
            case .cpy: cpy(current)
            case .dec: dec(current)
            case .inc: inc(current)
            case .jnz: jnz(current)
            case .tgl: tgl(current)
            }

            printState()
        }
    }

    internal func cpy(_ instruction: Instruction) {
        ptr += 1

        guard let value = resolve(instruction.arg1) else {
            return
        }

        if let idx = resolveIndex(instruction.arg2) {
            registers[idx] = value
        }
    }

    internal func dec(_ instruction: Instruction) {
        guard let idx = resolveIndex(instruction.arg1) else {
           return
        }

        registers[idx] -= 1
        ptr += 1 
    }

    internal func inc(_ instruction: Instruction) {
        guard let idx = resolveIndex(instruction.arg1) else {
           return
        }

        registers[idx] += 1
        ptr += 1 
    }

    internal func jnz(_ instruction: Instruction) {
        guard let value = resolve(instruction.arg1) else {
            return
        }

        guard let offset = resolve(instruction.arg2) else {
            return
        }

        if value == 0 {
            ptr += 1
        } else {
            ptr += offset
        }
    }

    internal func resolve(_ arg: Arg) -> Int? {
        switch arg {
        case .int(let x): return x
        case .empty: fatalError("Cannot resolve empty")
        case .register(let x):
            guard let idx = sym2reg(x) else {
                fatalError("Cannot lookup register with non-register")
            }

            return registers[idx]
        }
    }

    internal func resolveIndex(_ arg: Arg) -> Int? {
        switch arg {
        case .int(let x): return x
        case .empty: fatalError("Cannot resolve index empty")
        case .register(let x): return sym2reg(x)
        }
    }

    internal func sym2reg(_ x: String) -> Int? {
        switch x {
        case "a": return 0
        case "b": return 1
        case "c": return 2
        case "d": return 3
        default: return nil
        }
    }

    internal func tgl(_ instruction: Instruction) {
        guard let offset = resolve(instruction.arg1) else {
            return
        }

        let destPtr = offset + ptr
        ptr += 1

        guard destPtr < instructions.count else {
            return
        }

        let instruction = instructions[destPtr]
        instructions[destPtr] = instruction.toggle()
    }
}

// Get the command line arguments
let registerValues = CommandLine.arguments[1]
let registers = registerValues.components(separatedBy: ",").map { Int($0)! }

// Build the computer
let computer = Computer(registers: registers, shouldPrint: true)

// Read all of the input
while true {
    guard let line = readLine() else {
        break
    }

    computer.parse(instruction: line)
}

computer.run()
