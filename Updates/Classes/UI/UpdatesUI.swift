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
    
    /// Presents SKStoreProductViewController modally.
    public func presentAppStore(presentingViewController: UIViewController) {
        guard let appStoreId = Updates.appStoreId, let appStoreIdentifierInt = UInt(appStoreId) else {
                return
        }
         let animated = self.animated
        let appStoreIdentifier: NSNumber = NSNumber(value: appStoreIdentifierInt)
        let parameters = [SKStoreProductParameterITunesItemIdentifier: appStoreIdentifier]
        let viewController = SKStoreProductViewController()
        viewController.delegate = self
        viewController.loadProduct(withParameters: parameters) { [weak self] (loadedSuccessfully, error) in
            guard loadedSuccessfully else {
                viewController.dismiss(animated: animated, completion: nil)
                if let appStoreURL = Updates.appStoreURL {
                    self?.presentSafariViewController(animated: animated,
                                                      presentingViewController: presentingViewController,
                                                      url: appStoreURL)
                }
                return
            }
            viewController.dismiss(animated: animated, completion: nil)
            if let appStoreURL = Updates.appStoreURL {
                self?.presentSafariViewController(animated: animated,
                                                  presentingViewController: presentingViewController,
                                                  url: appStoreURL)
            }
            debugPrint(error as Any)
        }
        DispatchQueue.main.async {
            presentingViewController.present(viewController, animated: animated, completion: nil)
        }
    }
    
    /// Presents SKStoreProductViewController modally.
    /// - Parameters:
    ///     - animated: Whether or not the modal presentation is animated.
    ///     - completion: Completion closure called on SKStoreProductViewController dismissal.
    public static func presentAppStore(animated: Bool = true, completion: (() -> Void)? = nil,
                                       presentingViewController: UIViewController) {
        updatesUI = UpdatesUI(animated: animated, completion: completion)
        updatesUI.presentAppStore(presentingViewController: presentingViewController)
    }
    
    /// Presents SKStoreProductViewController modally.
    /// - Parameters:
    ///     - delegate: Delegate for receiving completion delegate call if required.
    ///     - animated: Whether or not the modal presentation is animated.
    public static func presentAppStore(animated: Bool = true,
                                       delegate: SKStoreProductViewControllerDelegate,
                                       presentingViewController: UIViewController) {
        guard let appStoreId = Updates.appStoreId,
            let appStoreIdentifierInt = UInt(appStoreId) else {
                return
        }
        let appStoreIdentifier: NSNumber = NSNumber(value: appStoreIdentifierInt)
        let parameters = [SKStoreProductParameterITunesItemIdentifier: appStoreIdentifier]
        let viewController = SKStoreProductViewController()
        viewController.delegate = delegate
        viewController.loadProduct(withParameters: parameters) { (loadedSuccessfully, error) in
            guard loadedSuccessfully else {
                viewController.dismiss(animated: animated, completion: nil)
                if let appStoreURL = Updates.appStoreURL {
                    updatesUI.presentSafariViewController(animated: animated,
                                                          presentingViewController: presentingViewController,
                                                          url: appStoreURL)
                }
                return
            }
            viewController.dismiss(animated: animated, completion: nil)
            if let appStoreURL = Updates.appStoreURL {
                updatesUI.presentSafariViewController(animated: animated,
                                                  presentingViewController: presentingViewController,
                                                  url: appStoreURL)
            }
            debugPrint(error as Any)
        }
        presentingViewController.present(viewController, animated: animated, completion: nil)
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
