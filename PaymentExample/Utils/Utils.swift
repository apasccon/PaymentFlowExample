//
//  Utils.swift
//  PaymentExample
//
//  Created by Alejandro Pasccon on 26/03/2018.
//  Copyright © 2018 Alejandro Pasccon. All rights reserved.
//

import UIKit

class Utils {
    public class AlertController: UIAlertController {
        
        /// Create an alert view with an "OK" button by default
        open static func alert(_ title: String?, message: String?, buttons:[String] = ["OK"], cancelButtonPosition:Int = -1, destructiveButtonPosition:Int = -1, handler: ((_ optionSelected: Int) -> Void)?) -> Utils.AlertController {
            
            let alertController = Utils.AlertController(title: title, message: message, preferredStyle: .alert)
            
            Utils.AlertController.buildAlertController(alertController, buttons: buttons, cancelButtonPosition: cancelButtonPosition, destructiveButtonPosition: destructiveButtonPosition, handler: handler)
            
            return alertController
        }
        
        ///You can use indistinctly actionSheet() or popover() functions. It detects if the device is an iPhone or an iPad.
        open static func actionSheet(_ title: String?, message: String?, buttons:[String] = ["OK"], cancelButtonPosition: Int = -1, destructiveButtonPosition:Int = -1, handler: ((_ optionSelected: Int) -> Void)?) -> Utils.AlertController {
            
            let alertController = Utils.AlertController(title: title, message: message, preferredStyle: .actionSheet)
            
            Utils.AlertController.buildAlertController(alertController, buttons: buttons, cancelButtonPosition: cancelButtonPosition, destructiveButtonPosition: destructiveButtonPosition, handler: handler)
            
            return alertController
        }
        
        ///You can use indistinctly actionSheet() or popover() functions. It detects if the device is an iPhone or an iPad.
        open static func popover(_ title: String?, message: String?, buttons:[String] = ["OK"], cancelButtonPosition:Int = -1, destructiveButtonPosition:Int = -1, handler: ((_ optionSelected: Int) -> Void)?) -> Utils.AlertController {
            
            let alertController = Utils.AlertController.actionSheet(title, message: message, buttons: buttons, cancelButtonPosition: cancelButtonPosition, destructiveButtonPosition: destructiveButtonPosition, handler: handler)
            
            return alertController
        }
        
        /**
         * Show the alert / action sheet / popover
         * Set fromView parameter if you want to show the popover from here. You can assign either a UIView or UIBarButtonItem
         * Set fromView parameter if you want to keep the UI compatible with both, iPhones and iPads
         */
        open func show(fromView view: NSObject? = nil) {
            showIn(UIApplication.topViewController()!, fromView: view)
        }
        
        open func showIn(_ viewController: UIViewController, fromView: NSObject? = nil) {
            if let fromView = fromView {
                if fromView.isKind(of: UIView.self) {
                    self.popoverPresentationController?.sourceView = fromView as? UIView
                    self.popoverPresentationController?.sourceRect = (fromView as! UIView).bounds
                }
                else if fromView.isKind(of: UIBarButtonItem.self) {
                    self.popoverPresentationController?.barButtonItem = fromView as? UIBarButtonItem
                }
                else {
                    assertionFailure("Only UIView and UIBarButtonItem are valid options for fromView parameter")
                }
            } else {
                if UIDevice.current.userInterfaceIdiom == .pad {
                    self.popoverPresentationController?.sourceView = viewController.view
                    self.popoverPresentationController?.sourceRect = viewController.view.bounds
                    self.popoverPresentationController?.permittedArrowDirections = UIPopoverArrowDirection()
                }
            }
            
            viewController.present(self, animated: true, completion: nil)
        }
        
        ///////////////////////////////////////////////////////////////////////////////////////////////
        // Private Implementation
        
        fileprivate static func buildAlertController(_ alertController: Utils.AlertController, buttons:[String] = ["OK"], cancelButtonPosition:Int = -1, destructiveButtonPosition:Int = -1, handler: ((_ optionSelected: Int) -> Void)?) {
            var position = 0
            
            for buttonTitle in buttons {
                var style = UIAlertActionStyle.default
                
                if cancelButtonPosition == position {
                    style = UIAlertActionStyle.cancel
                }
                else if destructiveButtonPosition == position {
                    style = UIAlertActionStyle.destructive
                }
                
                
                alertController.addAction(UIAlertAction(title: buttonTitle, style: style) { action in
                    if let handler = handler {
                        handler(buttons.index(of: action.title!)!)
                    }
                })
                
                position += 1
            }
            
        }
    }
}


////////////////////////////////////////////////////////////////////////////////////////////////////////////////
// Extensions
////////////////////////////////////////////////////////////////////////////////////////////////////////////////

public extension UIApplication {
    class func topViewController(_ base: UIViewController? = UIApplication.shared.keyWindow?.rootViewController) -> UIViewController? {
        if let nav = base as? UINavigationController {
            return topViewController(nav.visibleViewController)
        }
        if let tab = base as? UITabBarController {
            if let selected = tab.selectedViewController {
                return topViewController(selected)
            }
        }
        if let presented = base?.presentedViewController {
            if !presented.isBeingDismissed {
                return topViewController(presented)
            }
        }
        return base
    }
}

public extension String {
    func containsOnlyCharactersIn(matchCharacters: String) -> Bool {
        let disallowedCharacterSet = CharacterSet(charactersIn: matchCharacters).inverted
        return self.rangeOfCharacter(from: disallowedCharacterSet) == nil
    }
}

class UIStoryboardSegueWithCompletion: UIStoryboardSegue {
    var completion: (() -> Void)?
    
    override func perform() {
        super.perform()
        if let completion = completion {
            completion()
        }
    }
}
