//
//  ViewController.swift
//  Calculator
//
//  Created by Damir Dizdarevic on 05.02.15.
//  Copyright (c) 2015 Damir Dizdarevic. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    @IBOutlet weak var display: UILabel!
    
    @IBOutlet weak var history: UILabel!
    
    var userIsInTheMiddleOfTypingANumber = false
    
    var brain = CalculatorBrain()
    
    @IBAction func appendComma(sender: AnyObject) {
        if display.text!.rangeOfString(".") == nil {
            display.text = display.text! + "."
            userIsInTheMiddleOfTypingANumber = true
        }
        
    }
    
    @IBAction func appendDigit(sender: UIButton) {
        let digit = sender.currentTitle!
        if userIsInTheMiddleOfTypingANumber {
            display.text = display.text! + digit
        } else {
            display.text = digit
            userIsInTheMiddleOfTypingANumber = true
        }
    }
    
    @IBAction func clear(sender: UIButton) {
        brain.clearBrain()
        resetDisplay()
    }
    
    @IBAction func enter() {
        if userIsInTheMiddleOfTypingANumber {
            if let result = brain.pushOperand(displayValue!) {
                displayValue = result
            } else {
                resetDisplay()
            }
            userIsInTheMiddleOfTypingANumber = false
        }
    }
    
    @IBAction func operate(sender: UIButton) {
        if userIsInTheMiddleOfTypingANumber {
            enter()
        }
        
        if let operation = sender.currentTitle {
            if let result = brain.performOperation(operation) {
                displayValue = result
                history.text = history.text! + (" =")
            } else {
                resetDisplay()
            }
        }
    }
    
    @IBAction func changeSign(sender: UIButton) {
        if userIsInTheMiddleOfTypingANumber {
            if display.text!.rangeOfString("-") == nil {
                display.text = "-" + display.text!
            } else {
                var temp = display.text!
                display.text = temp.substringFromIndex(advance(temp.startIndex,1))
            }

        } else {
            operate(sender)            
        }
    }
    
    @IBAction func setVariable(sender: UIButton) {
        if userIsInTheMiddleOfTypingANumber {
            userIsInTheMiddleOfTypingANumber = false
            brain.variableValues["M"] = displayValue
            
            if let result = brain.evaluate() {
                displayValue = result
            }
        }
    }
    
    @IBAction func getVariable(sender: UIButton) {
        if userIsInTheMiddleOfTypingANumber {
            enter()
        }
        
        if let result = brain.pushOperand("M") {
            displayValue = result
        } else {
            resetDisplay()
        }
    }
    
    private func resetDisplay() {
        displayValue = nil
    }
    
    func updateHistory() {
        history.text = brain.description
    }
    
    var displayValue: Double? {
        get {
            if let value = NSNumberFormatter().numberFromString(display.text!) {
                return value.doubleValue
            } else {
                return nil
            }
        }
        set {
            if newValue != nil {
                display.text = "\(newValue!)"
                userIsInTheMiddleOfTypingANumber = false
            } else {
                display.text = " "
                userIsInTheMiddleOfTypingANumber = false
            }
            updateHistory()
        }
        
    }
}

