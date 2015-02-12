//
//  CalculatorBrain.swift
//  Calculator
//
//  Created by Damir Dizdarevic on 08.02.15.
//  Copyright (c) 2015 Damir Dizdarevic. All rights reserved.
//

import Foundation

class CalculatorBrain
{
    // MARK: - Private API

    private enum Op: Printable
    {
        case Operand(Double)
        case Variable(String)
        case Constant(String, Double)
        case UnaryOperation(String, Double -> Double)
        case BinaryOperation(String, (Double, Double) -> Double)
        
        var description: String {
            get {
                switch self {
                case .Operand(let operand):
                    return "\(operand)"
                case .Variable(let variable):
                    return "\(variable)"
                case .Constant(let symbol, _):
                    return symbol
                case .UnaryOperation(let symbol, _):
                    return symbol
                case .BinaryOperation(let symbol, _):
                    return symbol
                }
            }
        }
    }
    
    private var opStack = [Op]() //Array<Op>()
    
    private var knownOps = [String:Op]() //Dictionary<String, Op>()
    
    private func evaluate(ops: [Op]) -> (result: Double?, remainingOps: [Op]){
        if !ops.isEmpty {
            var remainingOps = ops
            let op = remainingOps.removeLast()
            
            switch op {
            case .Operand(let operand):
                return (operand, remainingOps)
            case .Variable(let variable):
                if let var variableValue = variableValues[variable] {
                    return (variableValue, remainingOps)
                } else {
                    return (nil, remainingOps)
                }
            case .Constant(_, let constant):
                return (constant, remainingOps)
            case .UnaryOperation(let name, let operation):
                let operandEvaluation = evaluate(remainingOps)
                
                if let operand = operandEvaluation.result {
                    return (operation(operand), remainingOps)
                }
            case .BinaryOperation(_, let operation):
                let op1Evaluation = evaluate(remainingOps)
                if let operand1 = op1Evaluation.result {
                    let op2Evaluation = evaluate(op1Evaluation.remainingOps)
                    if let operand2 = op2Evaluation.result {
                        return (operation(operand1, operand2), op2Evaluation.remainingOps)
                    }
                }
            }
        }
        return (nil, ops)
    }
    
    private func describe(ops: [Op]) -> (result: String?, remainingOps: [Op]){
        if !ops.isEmpty {
            var remainingOps = ops
            let op = remainingOps.removeLast()
            
            switch op {
            case .Operand(let operand):
                return ("\(operand)", remainingOps)
            case .Variable(let variable):
                return (variable, remainingOps)
            case .Constant(let name, _):
                return (name, remainingOps)
            case .UnaryOperation(let name, let operation):
                let operandEvaluation = describe(remainingOps)
                
                if let operand = operandEvaluation.result {
                    return ("\(name)(\(operand))", remainingOps)
                }
            case .BinaryOperation(let opName, let operation):
                let op1Evaluation = describe(remainingOps)
                if let operand1 = op1Evaluation.result {
                    let op2Evaluation = describe(op1Evaluation.remainingOps)
                    if let operand2 = op2Evaluation.result {
                        return ("\(operand2) \(opName) \(operand1)", op2Evaluation.remainingOps)
                    } else {
                        return ("? \(opName) \(operand1)", remainingOps)
                    }
                } else {
                    return ("?", remainingOps)
                }
            }
        }
        return (nil, ops)
    }

    
    // MARK: - Public API
    
    var variableValues = [String:Double]() //Dictionary<String,Double>

    init() {
        func learnOp(op: Op) {
            knownOps[op.description] = op
        }
        
        learnOp(Op.BinaryOperation("×", *))          //Op.BinaryOperation("×") { $0 * $1 }
        learnOp(Op.BinaryOperation("÷") { $1 / $0 })
        learnOp(Op.BinaryOperation("+", +))          //Op.BinaryOperation("+") { $0 + $1 }
        learnOp(Op.BinaryOperation("−") { $1 - $0 })
        learnOp(Op.UnaryOperation("√", sqrt))        //Op.UnaryOperation("√") { sqrt($0) }
        learnOp(Op.UnaryOperation("sin") { sin($0) })
        learnOp(Op.UnaryOperation("cos") { cos($0) })
        learnOp(Op.UnaryOperation("ᐩ/-") { -($0) })
        learnOp(Op.Constant("π", M_PI))
    }

    typealias PropertyList = AnyObject
    
    var program: PropertyList { // gaurenteed to be a PropertyList
        get {
            return opStack.map { $0.description }
        }
        set {
            if let opSymbols = newValue as? Array<String> {
                var newOpStack = [Op]()
                for opSymbol in opSymbols {
                    if let op = knownOps[opSymbol] {
                        opStack.append(op)
                    } else if let operand = NSNumberFormatter().numberFromString(opSymbol)?.doubleValue {
                        opStack.append(.Operand(operand))
                    }
                }
                opStack = newOpStack
            }
        }
    }
    
    var description: String {
        get {
            var opStackClone = opStack
            let (description, remainder) = describe(opStackClone)
            if description != nil {
                return description!
            } else {
                return "Empty Stack"
            }
        }
    }
    
    func evaluate() -> Double? {
        let (result, remainder) = evaluate(opStack)
        println("\(opStack) = \(result) with \(remainder) left over")
        return result
    }
    
    func pushOperand(operand: Double) -> Double! {
        opStack.append(Op.Operand(operand))
        return evaluate()
    }
    
    func pushOperand(symbol: String) -> Double? {
        opStack.append(Op.Variable(symbol))
        return evaluate()
    }
    
    func performOperation(symbol: String) -> Double? {
        if let operation = knownOps[symbol] {
            opStack.append(operation)
        }
        
        return evaluate()
    }
        
    func clearBrain() {
        opStack.removeAll(keepCapacity: false)
        variableValues.removeAll(keepCapacity: false)
        
        println("Stack cleared")
    }
    
}