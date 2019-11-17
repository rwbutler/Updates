//
//  UpdatesUI.swift
//  Updates
//
//  Created by Ross Butler on 12/27/18.
//

import Foundation
import StoreKit
import SafariServices

public class UpdatesUI: NSObject {
    
    private let animated: Bool
    private let completion: (() -> Void)?
    private static var updatesUI: UpdatesUI = UpdatesUI()
    
    public init(animated: Bool = true, completion: (() -> Void)? = nil) {
        self.animated = animated
        self.completion = completion
    }
    
    /// Button title displayed by the `UIAlertController`.
    private static func buttonTitle(_ key: String) -> String {
        let updateLocalizationKey = "updates.\(key)-button-title".lowercased()
        let updateButtonTitle = NSLocalizedString(updateLocalizationKey, comment: key)
        if updateButtonTitle != updateLocalizationKey {
            return updateButtonTitle
        } else {
            return key
        }
    }
    
    /// Presents SKStoreProductViewController modally.
    public func presentAppStore(animated: Bool = true, completion: (() -> Void)? = nil,
                                presentingViewController: UIViewController) {
        guard let appStoreId = Updates.appStoreId, let appStoreIdentifierInt = UInt(appStoreId) else {
            return
        }
        let animated = self.animated
        let appStoreIdentifier: NSNumber = NSNumber(value: appStoreIdentifierInt)
        let parameters = [SKStoreProductParameterITunesItemIdentifier: appStoreIdentifier]
        let viewController = SKStoreProductViewController()
        viewController.delegate = self
        viewController.loadProduct(withParameters: parameters) { [weak self] (loadedSuccessfully, error) in
            if !loadedSuccessfully, let appStoreURL = Updates.appStoreURL {
                print(error as Any)
                self?.presentSafariViewController(animated: animated,
                                                  presentingViewController: presentingViewController,
                                                  url: appStoreURL)
            }
        }
        DispatchQueue.main.async {
            presentingViewController.present(viewController, animated: animated, completion: nil)
        }
    }
    
    /// Presents SKStoreProductViewController modally.
    public func presentAppStore(animated: Bool = true, delegate: SKStoreProductViewControllerDelegate,
                                presentingViewController: UIViewController) {
        guard let appStoreId = Updates.appStoreId, let appStoreIdentifierInt = UInt(appStoreId) else {
            return
        }
        let animated = self.animated
        let appStoreIdentifier: NSNumber = NSNumber(value: appStoreIdentifierInt)
        let parameters = [SKStoreProductParameterITunesItemIdentifier: appStoreIdentifier]
        let viewController = SKStoreProductViewController()
        viewController.delegate = delegate
        viewController.loadProduct(withParameters: parameters) { [weak self] (loadedSuccessfully, error) in
            if !loadedSuccessfully, let appStoreURL = Updates.appStoreURL {
                print(error as Any)
                self?.presentSafariViewController(animated: animated,
                                                  presentingViewController: presentingViewController,
                                                  url: appStoreURL)
            }
        }
        DispatchQueue.main.async {
            presentingViewController.present(viewController, animated: animated, completion: nil)
        }
    }
    
    /// Prompt the user to update to the latest version
    public static func promptToUpdate(_ result: UpdatesResult, animated: Bool = true, completion: (() -> Void)? = nil,
                                      presentingViewController: UIViewController,
                                      title: String? = nil,
                                      message: String? = nil) {
        guard case let .available(update) = result else { return }
        let alertTitle: String
        if let title = title {
            alertTitle = title
        } else if let productName = Updates.productName {
            alertTitle = "\(productName) v\(update.newVersionString) Available"
        } else {
            alertTitle = "Version \(update.newVersionString) Available"
        }
        let alertMessage: String? = message ?? update.releaseNotes
        let alert = UIAlertController(title: alertTitle, message: alertMessage, preferredStyle: .alert)
        let updateButtonTitle = buttonTitle("Update")
        let updateAction = UIAlertAction(title: updateButtonTitle, style: .default) { _ in
            alert.dismiss(animated: animated, completion: completion)
            self.presentAppStore(animated: animated, completion: completion,
                                 presentingViewController: presentingViewController)
        }
        let cancelButtonTitle = buttonTitle("Cancel")
        let cancelAction = UIAlertAction(title: cancelButtonTitle, style: .cancel) { _ in
            alert.dismiss(animated: animated, completion: completion)
        }
        alert.addAction(updateAction)
        alert.addAction(cancelAction)
        presentingViewController.present(alert, animated: animated, completion: nil)
    }
    
    /// Presents SKStoreProductViewController modally.
    /// - Parameters:
    ///     - animated: Whether or not the modal presentation is animated.
    ///     - completion: Completion closure called on SKStoreProductViewController dismissal.
    ///     - presentingViewController: View controller to present on.
    public static func presentAppStore(animated: Bool = true, completion: (() -> Void)? = nil,
                                       presentingViewController: UIViewController) {
        updatesUI.presentAppStore(animated: animated, completion: completion,
                                  presentingViewController: presentingViewController)
    }
    
    /// Presents SKStoreProductViewController modally.
    /// - Parameters:
    ///     - animated: Whether or not the modal presentation is animated.
    ///     - delegate: Delegate for receiving completion delegate call if required.
    ///     - presentingViewController: View controller to present on.
    public static func presentAppStore(animated: Bool = true,
                                       delegate: SKStoreProductViewControllerDelegate,
                                       presentingViewController: UIViewController) {
        updatesUI.presentAppStore(animated: animated, delegate: delegate,
                                  presentingViewController: presentingViewController)
    }
    
}

extension UpdatesUI: SKStoreProductViewControllerDelegate {
    
    /// Invoked when the user elects to close the SKStoreProductViewController.
    /// - Parameters:
    ///     - viewController: The SKStoreProductViewController to be dismissed.
    @objc public func productViewControllerDidFinish(_ viewController: SKStoreProductViewController) {
        viewController.dismiss(animated: animated, completion: completion)
    }
    
}

// Private API
private extension UpdatesUI {
    
    /// Presents the specified URL
    func presentSafariViewController(animated: Bool, presentingViewController: UIViewController, url: URL) {
        let safariViewController = SFSafariViewController(url: url)
        presentingViewController.present(safariViewController, animated: animated, completion: nil)
    }
    
}
