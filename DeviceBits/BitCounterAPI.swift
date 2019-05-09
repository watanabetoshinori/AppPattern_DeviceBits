//
//  BitCounterAPI.swift
//  DeviceBits
//
//  Created by Watanabe Toshinori on 5/9/19.
//  Copyright © 2019 Watanabe Toshinori. All rights reserved.
//

import UIKit

class BitCounterAPI: NSObject {
    
    /* Rewrite this URL according to your environment. */
    static let baseURL = "http://192.168.1.1:3000"

    // MARK: - Custom Error

    enum BitCounterAPIError: Error, LocalizedError {
        case invalidResponse(String?)
        
        var errorDescription: String? {
            switch self {
            case .invalidResponse(let string):
                return string ?? "Invalid response"
            }
        }
    }
    
    // MARK: - API
    
    class func query(deviceToken: String, completionHandler: @escaping (Result<BitCounter, Error>) -> Void) {
        var components = URLComponents(string: baseURL + "/query")!
        components.percentEncodedQueryItems = [
            URLQueryItem(name: "deviceToken", value: deviceToken.addingPercentEncoding(withAllowedCharacters: .urlQueryStringAllowed))
        ]
        
        let session = URLSession(configuration: .default)
        
        let task = session.dataTask(with: components.url!) { (data, response, error) in
            DispatchQueue.main.async {
                if let error = error {
                    completionHandler(.failure(error))
                    return
                }
                
                if let httpResponse = response as? HTTPURLResponse,
                    httpResponse.statusCode != 200 {
                    
                    let message = String(data: data ?? Data(), encoding: .utf8)
                    let error = BitCounterAPIError.invalidResponse(message)
                    completionHandler(.failure(error))
                    return
                }

                do {
                    let bitCounter = try JSONDecoder().decode(BitCounter.self, from: data ?? Data())
                    completionHandler(.success(bitCounter))
                    
                } catch {
                    completionHandler(.failure(error))
                }
            }
        }
        
        task.resume()
    }
    
    class func updte(deviceToken: String, bitCounter: Int, completionHandler: @escaping (Result<BitCounter, Error>) -> Void) {
        do {
            let json: [String: Any] = ["deviceToken": deviceToken,
                                       "counter": bitCounter]
            let data = try JSONSerialization.data(withJSONObject: json, options: [])
            
            let url = URL(string: baseURL + "/update")!
            
            var request = URLRequest(url: url)
            request.addValue("application/json", forHTTPHeaderField: "Content-Type")
            request.httpMethod = "POST"
            request.httpBody = data
            
            let session = URLSession(configuration: .default)
            
            let task = session.dataTask(with: request) { (data, response, error) in
                DispatchQueue.main.async {
                    if let error = error {
                        completionHandler(.failure(error))
                        return
                    }
                    
                    if let httpResponse = response as? HTTPURLResponse,
                        httpResponse.statusCode != 200 {
                        
                        let message = String(data: data ?? Data(), encoding: .utf8)
                        let error = BitCounterAPIError.invalidResponse(message)
                        completionHandler(.failure(error))
                        return
                    }
                    
                    do {
                        let bitCounter = try JSONDecoder().decode(BitCounter.self, from: data ?? Data())
                        completionHandler(.success(bitCounter))
                        
                    } catch {
                        completionHandler(.failure(error))
                    }
                }
            }
            
            task.resume()
            
        } catch {
            completionHandler(.failure(error))
        }
    }
    
    class func validate(deviceToken: String, completionHandler: @escaping (Result<Int, Error>) -> Void) {
        do {
            let json: [String: Any] = ["deviceToken": deviceToken]
            let data = try JSONSerialization.data(withJSONObject: json, options: [])
            
            let url = URL(string: baseURL + "/validate")!
            
            var request = URLRequest(url: url)
            request.addValue("application/json", forHTTPHeaderField: "Content-Type")
            request.httpMethod = "POST"
            request.httpBody = data
            
            let session = URLSession(configuration: .default)
            
            let task = session.dataTask(with: request) { (data, response, error) in
                DispatchQueue.main.async {
                    if let error = error {
                        completionHandler(.failure(error))
                        return
                    }
                    
                    if let httpResponse = response as? HTTPURLResponse,
                        httpResponse.statusCode != 200 {
                        
                        let message = String(data: data ?? Data(), encoding: .utf8)
                        let error = BitCounterAPIError.invalidResponse(message)
                        completionHandler(.failure(error))
                        return
                    }

                    completionHandler(.success(200))
                }
            }
            
            task.resume()
            
        } catch {
            completionHandler(.failure(error))
        }
    }
    
}

extension CharacterSet {
    
    public static let urlQueryStringAllowed: CharacterSet = {
        return CharacterSet.urlQueryAllowed.subtracting(CharacterSet(charactersIn: ":#[]@!$&'()*+,;="))
    }()
}
