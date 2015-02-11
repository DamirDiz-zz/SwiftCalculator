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
        //check if display.text has comma
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
        userIsInTheMiddleOfTypingANumber = false
        if let result = brain.pushOperand(displayValue!) {
            displayValue = result
        } else {
            resetDisplay()
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
        /*
        If the user is in the middle of entering a number, you probably want to change the sign of that number and allow typing to continue, not force an enter like other operations do
        */
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
    
    private func resetDisplay() {
        displayValue = nil
    }
    
    func updateHistory() {
        history.text = brain.brainHistory()
    }
    
    var displayValue: Double? {
        get {
            return NSNumberFormatter().numberFromString(display.text!)!.doubleValue
        }
        set {
            if newValue != nil {
                display.text = "\(newValue!)"
                userIsInTheMiddleOfTypingANumber = false
            } else {
                display.text = "0.0"
            }
            updateHistory()
        }
        
    }
}

