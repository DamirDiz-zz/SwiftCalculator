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
            } else {
                resetDisplay()
            }
        }
    }
    
    private func resetDisplay() {
        displayValue = nil
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
        }
        
    }
}

