//
//  WelcomeViewController.swift
//  DeviceBits
//
//  Created by Watanabe Toshinori on 5/10/19.
//  Copyright © 2019 Watanabe Toshinori. All rights reserved.
//

import UIKit

class WelcomeViewController: UIViewController {
    
    // MARK: - ViewController lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()

    }
    
    // MARK: - Action
    
    @IBAction func startTapped(_ sender: Any) {
        showIndicator()

        UIDevice.current.loadBitCounter { (result) in
            self.hideIndicator(completionHandler: {
                switch result {
                case .success:
                    self.performSegue(withIdentifier: "PresentDeviceBits", sender: nil)
                case .failure(let error):
                    self.alert(title: error.localizedDescription)
                }
            })
        }
    }

}
