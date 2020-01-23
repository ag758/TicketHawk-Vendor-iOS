

import Foundation
import Alamofire
import Stripe

enum Result {
  case success
  case failure(Error)
}

final class StripeClient {
  
  static let shared = StripeClient()
  
  private init() {
    // private
  }
  
  private lazy var accountURL: URL = {
    guard let url = URL(string: Constants.stripeAccountCreateURL) else {
      fatalError("Invalid URL")
    }
    return url
  }()
    
    func createAccount(with firstName: String, lastName: String, completion: @escaping (String) -> Void) {
        // 1
        let url = accountURL.appendingPathComponent("create")
        
        print(url)
        // 2
        let params: [String: Any] = [
            "first_name": firstName,
            "last_name": lastName
        ]
        // 3
        Alamofire.request(url, method: .post, parameters: params)
            .validate(statusCode: 200..<300)
            .responseString { response in
                
                let s = String(data: response.data ?? Data(), encoding: .utf8) ?? ""
                
                print(s)
                switch response.result {
                case .success:
                    completion(s)
                case .failure( _):
                    print(response.error)
                    completion("Error")
                }
        }
    }
    
    func checkVerificationStatus( accountID: String, completion: @escaping (String) -> Void) {
        
        let url = accountUpdateURL.appendingPathComponent("getVerificationStatus")
        
        let params: [String: Any] = [
            "account_id": accountID
        ]
        
        Alamofire.request(url, method: .post, parameters: params)
            .validate(statusCode: 200..<300)
            .responseString { response in
                
                var s = String(data: response.data ?? Data(), encoding: .utf8) ?? ""
                print(s)
                switch response.result {
                case .success:
                    completion(s)
                case .failure( _):
                    print(response.error)
                    completion("Error")
                }
        }
        
        
    }
    
    private lazy var accountUpdateURL: URL = {
        guard let url = URL(string: Constants.stripeAccountUpdateURL) else {
            fatalError("Invalid URL")
        }
        return url
    }()
    
    func accountLinkOnly(accountID: String, failureURL: String, successURL: String, completion: @escaping (String) -> Void) {
        let url3 = accountUpdateURL.appendingPathComponent("createAccountLink")
        
        let params: [String: Any] = [
            "account_id": accountID,
            "failure_url": failureURL,
            "success_url": successURL
        ]
        
        Alamofire.request(url3, method: .post, parameters: params)
            .validate(statusCode: 200..<300)
            .responseString { response in
                
                let s = String(data: response.data ?? Data(), encoding: .utf8) ?? ""
                
                print(s)
                switch response.result {
                case .success:
                    completion(s)
                case .failure( _):
                    print(response.error)
                    completion("Error")
                }
        }
    }
    
    func updateAccount(accountID: String, failureURL: String, successURL: String, completion: @escaping (String) -> Void) {
        // 1
        let url1 = accountUpdateURL.appendingPathComponent("updateTOS")
        let url2 = accountUpdateURL.appendingPathComponent("updateBankFreq")
        let url3 = accountUpdateURL.appendingPathComponent("createAccountLink")
        
        // 2
        let params: [String: Any] = [
            "account_id": accountID,
            "failure_url": failureURL,
            "success_url": successURL
        ]
        // 3
        Alamofire.request(url1, method: .post, parameters: params)
            .validate(statusCode: 200..<300)
            .responseString { response in
                
                let s = String(data: response.data ?? Data(), encoding: .utf8) ?? ""
                
                print(s)
                switch response.result {
                case .success:
                    Alamofire.request(url2, method: .post, parameters: params)
                        .validate(statusCode: 200..<300)
                        .responseString { response in
                            
                            print(s)
                            switch response.result {
                            case .success:
                                Alamofire.request(url3, method: .post, parameters: params)
                                    .validate(statusCode: 200..<300)
                                    .responseString { response in
                                        
                                        let s = String(data: response.data ?? Data(), encoding: .utf8) ?? ""
                                        
                                        print(s)
                                        switch response.result {
                                        case .success:
                                            completion(s)
                                        case .failure( _):
                                            print(response.error)
                                            completion("Error")
                                        }
                                }
                            case .failure( _):
                                print(response.error)
                                completion("Error")
                            }
                    }
                case .failure( _):
                    print(response.error)
                    completion("Error")
                }
        }
    }
    
    private lazy var bankTokenGenerate: URL = {
        guard let url = URL(string: Constants.stripeBankTokenGenerateURL) else {
            fatalError("Invalid URL")
        }
        return url
    }()
    
    private lazy var bankUpdate: URL = {
        guard let url = URL(string: Constants.stripeBankSetURL) else {
            fatalError("Invalid URL")
        }
        return url
    }()
    
    func setBankToken(accountName: String, accountNumber: String, routingNumber: String, accountID: String, completion: @escaping (String) -> Void) {
        // 1
        let url1 = bankTokenGenerate.appendingPathComponent("create")
        let url2 = bankUpdate.appendingPathComponent("create")
        
        // 2
        let params: [String: Any] = [
            "account_holder_name": accountName,
            "routing_number": routingNumber,
            "account_number": accountNumber
        ]
        // 3
        Alamofire.request(url1, method: .post, parameters: params)
            .validate(statusCode: 200..<300)
            .responseString { response in
                
                let s = String(data: response.data ?? Data(), encoding: .utf8) ?? ""
                
                print(s)
                switch response.result {
                case .success:
                    
                    let params: [String: Any] = [
                        "bank_token": s,
                        "account_id": accountID
                    ]
                    
                
                    Alamofire.request(url2, method: .post, parameters: params)
                        .validate(statusCode: 200..<300)
                        .responseString { response in
                            
                            switch response.result {
                            case .success:
                                completion(s)
                            case .failure( _):
                                print(response.error)
                                completion("Error")
                            }
                    }
                case .failure( _):
                    print(response.error)
                    completion("Error")
                }
        }
    }
  
}
