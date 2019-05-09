//
//  UIViewController+Alert.swift
//  DeviceBits
//
//  Created by Watanabe Toshinori on 5/10/19.
//  Copyright © 2019 Watanabe Toshinori. All rights reserved.
//

import UIKit

extension UIViewController {

    func alert(title: String?, message: String? = nil, completionHandler: (() -> Void)? = nil) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        
        alertController.addAction(UIAlertAction(title: "OK", style: .default, handler: { (action) -> Void in
            completionHandler?()
        }))
        
        present(alertController, animated: true, completion: nil)
    }
    
}
