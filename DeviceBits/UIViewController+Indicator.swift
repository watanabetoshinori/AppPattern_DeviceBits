//
//  UIViewController+Indicator.swift
//  DeviceBits
//
//  Created by Watanabe Toshinori on 5/10/19.
//  Copyright © 2019 Watanabe Toshinori. All rights reserved.
//

import UIKit

extension UIViewController {
    
    func showIndicator() {
        if let indicator = storyboard?.instantiateViewController(withIdentifier: "ActivityIndicatorController") {
            (navigationController ?? self).present(indicator, animated: true, completion: nil)
        }
    }
    
    func hideIndicator(completionHandler: (() -> Void)?) {
        dismiss(animated: true, completion: completionHandler)
    }

}
