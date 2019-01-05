//
//  ViewController.swift
//  Updates
//
//  Created by Ross Butler on 12/27/2018.
//  Copyright (c) 2018 Ross Butler. All rights reserved.
//

import UIKit
import Updates

class ViewController: UIViewController {
    
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var versionLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        activityIndicator.startAnimating()
        configureLabels()
        configureUpdates()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        Updates.configurationURL = URL(string: "")
        Updates.checkForUpdates(notifying: .once) { updateAvailable, releaseNotes in
            if updateAvailable {
                UpdatesUI.presentAppStore(animated: animated, presentingViewController: self)
            }
            self.activityIndicator.stopAnimating()
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

}

private extension ViewController {
    
    func configureLabels() {
        let versionString: String? = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String
        let buildString: String? =  Bundle.main.infoDictionary?[kCFBundleVersionKey as String] as? String
        if let version = versionString, let build = buildString {
            versionLabel.text = "App version: \(version)(\(build))"
        }
    }
    
    func configureUpdates() {
        // - Add custom configuration here if needed - 
        // Updates.bundleIdentifier = ""
        // Updates.countryCode = "gb"
    }
    
}
