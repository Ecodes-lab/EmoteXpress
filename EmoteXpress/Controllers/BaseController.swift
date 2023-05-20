//
//  BaseController.swift
//  EmoteXpress
//
//  Created by Eco Dev System on 04/01/2023.
//

import UIKit

class BaseController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)

        if traitCollection.userInterfaceStyle == .dark {
            // Set the app's appearance to the dark interface style
            overrideUserInterfaceStyle = .dark
        } else {
            // Set the app's appearance to the dark interface style
            overrideUserInterfaceStyle = .dark
        }
    }

}
