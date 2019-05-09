//
//  DeviceBitsController.swift
//  DeviceBits
//
//  Created by Watanabe Toshinori on 5/9/19.
//  Copyright © 2019 Watanabe Toshinori. All rights reserved.
//

import UIKit

class DeviceBitsController: UITableViewController {
    
    let kUndefinedSymbol = "-"
    
    @IBOutlet weak var counterLabel: UILabel!
    
    @IBOutlet var counterStepper: UIStepper!

    // MARK: - ViewController lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()

        updateBarButtonItems(isEditing: isEditing)

        counterStepper.isHidden = true

        reloadData()
    }
    
    // MARK: - TableView delegate
    
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return false
    }
    
    override func tableView(_ tableView: UITableView, titleForFooterInSection section: Int) -> String? {
        return "Last Updated: " + (UIDevice.current.lastBitCounterUpdate ?? kUndefinedSymbol)
    }
    
    // MARK: - Managing the Editing of View controller
    
    override func setEditing(_ editing: Bool, animated: Bool) {
        super.setEditing(editing, animated: animated)
        
        updateBarButtonItems(isEditing: editing)
        
        if isEditing {
            counterStepper.isHidden = false

            if counterLabel.text == kUndefinedSymbol {
                counterLabel.text = "0"
            }
            
            counterStepper.value = Double(counterLabel.text!)!
        } else {
            counterStepper.isHidden = true
        }
    }

    // MARK: - Update UI
    
    private func updateBarButtonItems(isEditing: Bool) {
        if isEditing {
            navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .save, target: self, action: #selector(saveTapped(_:)))
            navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(cancelTapped(_:)))
        } else {
            navigationItem.rightBarButtonItem = editButtonItem
            navigationItem.leftBarButtonItem = nil
        }
    }
    
    private func reloadData() {
        if let bitCounter = UIDevice.current.bitCounter {
            if bitCounter < 0 {
                counterLabel.text = kUndefinedSymbol
            } else {
                counterLabel.text = String(describing: bitCounter)
            }
        } else {
            counterLabel.text = "Unknown"
        }
        
        tableView.reloadData()
    }
    
    // MARK: - Actions
    
    @IBAction func counterChanged(_ sender: UIStepper) {
        counterLabel.text = String(Int(sender.value))
    }

    @IBAction func saveTapped(_ sender: Any) {
        let newValue = Int(counterLabel.text!)!
        
        if UIDevice.current.bitCounter == newValue {
            
            // bitCounter not changed
            setEditing(false, animated: true)
            
            return
        }
        
        showIndicator()
        
        UIDevice.current.updateBitCounter(newValue) { (error) in
            self.hideIndicator(completionHandler: {
                if let error = error {
                    self.alert(title: error.localizedDescription)
                    return
                }
                
                self.reloadData()
                self.setEditing(false, animated: true)
            })
        }
    }

    @IBAction func cancelTapped(_ sender: Any) {
        reloadData()
        
        setEditing(false, animated: true)
    }
    
}
