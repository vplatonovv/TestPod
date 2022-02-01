//
//  ViewController.swift
//  BlinkingLabel
//
//  Created by viacheslavplatonov on 02/01/2022.
//  Copyright (c) 2022 viacheslavplatonov. All rights reserved.
//

import UIKit
import BlinkingLabel

class ViewController: UIViewController {
    
    var blinkingLabel: BlinkingLabel!
    var isBlinking = false

    override func viewDidLoad() {
        super.viewDidLoad()

        // Setup the BlinkingLabel
        blinkingLabel = BlinkingLabel(frame: CGRect(x: 20, y: 30, width: 200, height: 30))
        blinkingLabel.text = "I blink!"
        blinkingLabel.font = UIFont.systemFont(ofSize: 20)
        view.addSubview(blinkingLabel)
        blinkingLabel.startBlinking()
        isBlinking = true
        
        // Create UIButton to toogle the blinking
        let toogleButton = UIButton(frame: CGRect(x: 20, y: 70, width: 150, height: 30))
        toogleButton.setTitle(" Toogle Blinking ", for: .normal)
        toogleButton.setTitleColor(UIColor.red, for: .normal)
        toogleButton.isEnabled = true
        toogleButton.layer.borderColor = UIColor.black.cgColor
        toogleButton.layer.borderWidth = 2
        toogleButton.layer.cornerRadius = 10
        toogleButton.addTarget(self, action: #selector(toogleBlinking), for: .touchUpInside)
        view.addSubview(toogleButton)
    }
    
    @objc func toogleBlinking() {
        if isBlinking {
            blinkingLabel.stopBlinking()
        } else {
            blinkingLabel.startBlinking()
        }
        isBlinking.toggle()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}

