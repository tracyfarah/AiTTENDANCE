//
//  WelcomeViewController.swift
//  AiTTENDANCE
//
//  Created by Tracy Farah on 10/07/2022.
//

import UIKit
import CLTypingLabel

class WelcomeViewController: UIViewController {
    
    @IBOutlet weak var titleLabel: CLTypingLabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        titleLabel.text = K.appName
        titleLabel.adjustsFontSizeToFitWidth = true
    }
}
