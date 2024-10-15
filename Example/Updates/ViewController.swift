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
        configureUpdates()
        configureLabels()
        observeAppVersionDidChange()
    }

    override func viewDidAppear(_ animated: Bool) {
        Updates.configurationURL = Bundle.main.url(forResource: "Updates", withExtension: "json")
        Updates.checkForUpdates { result in
            UpdatesUI.promptToUpdate(result, presentingViewController: self)
            self.activityIndicator.stopAnimating()
        }
    }

    // MARK: - Notifications

    private func observeAppVersionDidChange() {
        NotificationCenter.default.addObserver(self, selector: #selector(appDidInstall),
        name: .appDidInstall, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(appVersionDidChange),
                                               name: .appVersionDidChange, object: nil)
    }

    @objc func appDidInstall(_ notification: Notification) {
        print("App installed.")
    }

    @objc func appVersionDidChange(_ notification: Notification) {
        print("App version changed.")
    }

}

private extension ViewController {

    func configureLabels() {
        let versionString: String? = Updates.versionString
        let buildString: String? =  Updates.buildString
        if let version = versionString, let build = buildString {
            versionLabel.text = "App version: \(version)(\(build))"
        }
    }

    func configureUpdates() {
        // - Add custom configuration here if needed - 
        // Updates.bundleIdentifier = ""
        // Updates.countryCode = ""
        // Updates.versionString = ""
    }

}
