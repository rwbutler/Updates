//
//  UpdatesUI.swift
//  Updates
//
//  Created by Ross Butler on 12/27/18.
//

import Foundation
import StoreKit

public class UpdatesUI: NSObject {
    
    private let animated: Bool
    private let completion: (() -> Void)?
    private static var updatesUI: UpdatesUI = UpdatesUI()
    
    public init(animated: Bool = true, completion: (() -> Void)? = nil) {
        self.animated = animated
        self.completion = completion
    }
    
    /// Presents SKStoreProductViewController modally.
    public func presentAppStore() {
        guard let appStoreId = Updates.appStoreId, let appStoreIdentifierInt = UInt(appStoreId),
            let presenter = UIApplication.shared.keyWindow?.rootViewController else {
                return
        }
        let appStoreIdentifier: NSNumber = NSNumber(value: appStoreIdentifierInt)
        let parameters = [SKStoreProductParameterITunesItemIdentifier: appStoreIdentifier]
        let viewController = SKStoreProductViewController()
        viewController.delegate = self
        viewController.loadProduct(withParameters: parameters) { (loadedSuccessfully, error) in
            guard loadedSuccessfully else {
                if let appStoreURL = Updates.appStoreURL {
                    UpdatesUI.openURL(appStoreURL)
                }
                return
            }
            debugPrint(error as Any)
        }
        let animated = self.animated
        DispatchQueue.main.async {
            presenter.present(viewController, animated: animated, completion: nil)
        }
    }
    
    /// Presents SKStoreProductViewController modally.
    /// - Parameters:
    ///     - animated: Whether or not the modal presentation is animated.
    ///     - completion: Completion closure called on SKStoreProductViewController dismissal.
    public static func presentAppStore(animated: Bool = true, completion: (() -> Void)? = nil) {
        updatesUI = UpdatesUI(animated: animated, completion: completion)
        updatesUI.presentAppStore()
    }
    
    /// Presents SKStoreProductViewController modally.
    /// - Parameters:
    ///     - delegate: Delegate for receiving completion delegate call if required.
    ///     - animated: Whether or not the modal presentation is animated.
    public static func presentAppStore(animated: Bool = true,
                                       delegate: SKStoreProductViewControllerDelegate) {
        guard let appStoreId = Updates.appStoreId,
            let appStoreIdentifierInt = UInt(appStoreId),
            let presenter = UIApplication.shared.keyWindow?.rootViewController else {
                return
        }
        let appStoreIdentifier: NSNumber = NSNumber(value: appStoreIdentifierInt)
        let parameters = [SKStoreProductParameterITunesItemIdentifier: appStoreIdentifier]
        let viewController = SKStoreProductViewController()
        viewController.delegate = delegate
        viewController.loadProduct(withParameters: parameters) { (loadedSuccessfully, error) in
            guard loadedSuccessfully else {
                if let appStoreURL = Updates.appStoreURL {
                    openURL(appStoreURL)
                }
                return
            }
            debugPrint(error as Any)
        }
        presenter.present(viewController, animated: animated, completion: nil)
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
    
    /// Opens the URL specified, if possible.
    /// - Parameters:
    ///     - url: The URL to be opened.
    /// - Returns: Whether or not the URL was opened succesfully.
    @discardableResult static func openURL(_ url: URL) -> Bool {
        if UIApplication.shared.canOpenURL(url) {
            return UIApplication.shared.openURL(url)
        }
        return false
    }
    
}
