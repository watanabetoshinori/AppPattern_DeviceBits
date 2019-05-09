//
//  UIDevice+DeviceCheck.swift
//  DeviceBits
//
//  Created by Watanabe Toshinori on 5/10/19.
//  Copyright © 2019 Watanabe Toshinori. All rights reserved.
//

import UIKit
import DeviceCheck

// MARK: - Public

extension UIDevice {

    // MARK: - Custom Error
    
    enum BitCounterError: Error, LocalizedError {
        case notSupported
        case tokenGenerationFailed
        case updateFiled(Int)
        
        var errorDescription: String? {
            switch self {
            case .notSupported:
                return "The DeviceCheck APIs are not available on the current device."
            case .tokenGenerationFailed:
                return "Faield to generate DeviceToken."
            case .updateFiled(let status):
                return "Faield to update bitCounter. (\(status))"
            }
        }
    }
    
    // Properties

    var bitCounter: Int? {
        return _bitCounter
    }
    
    var lastBitCounterUpdate: String? {
        return _lastBitCounterUpdate
    }
    
    // Functions
    
    func loadBitCounter(completionHandler: @escaping (Result<Int?, Error>) -> Void) {
        guard DCDevice.current.isSupported else {
            completionHandler(.failure(BitCounterError.notSupported))
            return
        }
        
        DCDevice.current.generateToken { (data, error) in
            if let error = error {
                completionHandler(.failure(error))
                return
            }
            
            guard let deviceToken = data?.base64EncodedString() else {
                completionHandler(.failure(BitCounterError.tokenGenerationFailed))
                return
            }
            
            BitCounterAPI.query(deviceToken: deviceToken, completionHandler: { (result) in
                switch result {
                case .success(let bitCounter):
                    self._bitCounter = bitCounter.counter
                    self._lastBitCounterUpdate = bitCounter.lastUpdateTime
                    completionHandler(.success(self._bitCounter))

                case .failure(let error):
                    completionHandler(.failure(error))
                }
            })
        }
    }
    
    func updateBitCounter(_ newValue: Int, completionHandler: @escaping (Error?) -> Void) {
        assert(0 <= newValue && newValue < 4, "BitCounter must be between 0 and 3.")

        guard DCDevice.current.isSupported else {
            completionHandler(BitCounterError.notSupported)
            return
        }

        DCDevice.current.generateToken { (data, error) in
            if let error = error {
                completionHandler(error)
                return
            }
            
            guard let deviceToken = data?.base64EncodedString() else {
                completionHandler(BitCounterError.tokenGenerationFailed)
                return
            }

            BitCounterAPI.updte(deviceToken: deviceToken, bitCounter: newValue, completionHandler: { (result) in
                switch result {
                case .success(let bitCounter):
                    self._bitCounter = bitCounter.counter
                    self._lastBitCounterUpdate = bitCounter.lastUpdateTime
                    completionHandler(nil)
                    
                case .failure(let error):
                    completionHandler(error)
                }
            })
        }
    }
    
}

// MARK: - Private

extension UIDevice {

    private struct AssociatedKeys {
        static var bitCounter = "bitCounter"
        static var lastBitCounterUpdate = "lastBitCounterUpdate"
    }
    
    private var _bitCounter: Int? {
        get {
            return objc_getAssociatedObject(self, &AssociatedKeys.bitCounter) as? Int
        }
        
        set {
            objc_setAssociatedObject(self, &AssociatedKeys.bitCounter, newValue, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
    
    private var _lastBitCounterUpdate : String? {
        get {
            return objc_getAssociatedObject(self, &AssociatedKeys.lastBitCounterUpdate) as? String
        }
        
        set {
            objc_setAssociatedObject(self, &AssociatedKeys.lastBitCounterUpdate, newValue, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
    
}
