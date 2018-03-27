//
//  ApiClient.swift
//
//  Created by Alejandro Pasccon on 8/15/17.
//  Copyright © 2017 Alejandro Pasccon. All rights reserved.
//

import Foundation
import Alamofire
import AlamofireObjectMapper
import ObjectMapper

class ApiClient {
    
    fileprivate let baseUrl: String
    fileprivate var apiKey = ""
    fileprivate var headers: [String: String] = [:]
    
    static let shared = ApiClient()
    
    private init() {
        // Get base url and api key from the Environment configuration
        self.baseUrl = Environments.global.value(forKey: "api_base_url") as! String
        self.apiKey = Environments.global.value(forKey: "api_key") as! String
    }

    func fetchPaymentMethods(completion: @escaping (_ result: ApiResult<[PaymentMethod]>) -> Void) {
        let url = "\(baseUrl)/payment_methods"
        
        Alamofire.request(url, method: .get, parameters: defaultParams(), headers: headers)
            .validate(statusCode: 200..<300)
            .responseArray { [weak self] (response: DataResponse<[PaymentMethod]>) in
                switch response.result {
                case .success:
                    if let items = response.result.value {
                        completion(ApiResult.success(result: items))
                    } else {
                        completion(ApiResult.failure(error: .parsingError))
                    }
                    break
                case .failure(let error):
                    completion(ApiResult.failure(error: self!.apiError(from: error)))
                    print(error)
                    break
                }
        }
    }
    
    func fetchPaymentMethodIssuers(paymentMethodId: String, completion: @escaping (_ result: ApiResult<[Issuer]>) -> Void) {
        let url = "\(baseUrl)/payment_methods/card_issuers"
        
        let parameters = defaultParams(paymentMethodId: paymentMethodId)
        
        Alamofire.request(url, method: .get, parameters: parameters, headers: headers)
            .validate(statusCode: 200..<300)
            .responseArray { [weak self] (response: DataResponse<[Issuer]>) in
                switch response.result {
                case .success:
                    if let items = response.result.value {
                        completion(ApiResult.success(result: items))
                    } else {
                        completion(ApiResult.failure(error: .parsingError))
                    }
                    break
                case .failure(let error):
                    completion(ApiResult.failure(error: self!.apiError(from: error)))
                    print(error)
                    break
                }
        }
    }
    
    func fetchAvailableInstallments(paymentMethodId: String, issuerId: String?, amount: Float, completion: @escaping (_ result: ApiResult<[Installment]>) -> Void) {
        let url = "\(baseUrl)/payment_methods/installments"
        let parameters = defaultParams(paymentMethodId: paymentMethodId, issuerId: issuerId, amount: amount)

        Alamofire.request(url, method: .get, parameters: parameters, headers: headers)
            .validate(statusCode: 200..<300)
            .responseJSON(completionHandler: { [weak self] response in
                switch response.result {
                case .success(let json):
                    if let responseValue = (json as? NSArray)?.firstObject as? NSDictionary, let payerCosts = responseValue["payer_costs"] as? [[String: Any]] {
                        var result:[Installment] = []
                        
                        for installmentJson in payerCosts {
                            if let installment = Installment(JSON: installmentJson) {
                                result.append(installment)
                            }
                        }
                        
                        completion(ApiResult.success(result: result))
                    } else {
                        completion(ApiResult.failure(error: ApiError.parsingError))
                    }
                    break
                case .failure(let error):
                    completion(ApiResult.failure(error: self!.apiError(from: error)))
                    print(error)
                }
            })
    }
}

// Private
extension ApiClient {
    private func apiError(from error: Error?) -> ApiError {
        if let error = error as? AFError, let responseCode = error.responseCode {
            switch responseCode {
            case 400, 404, 500..<600: //400 or something between 500 and 600
                return .internalServerError
            default:
                return .unknownError
            }
        } else {
            return .unknownError
        }
    }

    private func defaultParams(paymentMethodId: String? = nil, issuerId: String? = nil, amount: Float? = nil) -> [String: Any] {
        var params: [String: Any] = [:]
        params = ["public_key": self.apiKey]
        
        if let paymentMethodId = paymentMethodId {
            params["payment_method_id"] = paymentMethodId
        }
        if let issuerId = issuerId {
            params["issuer.id"] = issuerId
        }
        if let amount = amount {
            params["amount"] = amount
        }
        
        return params
    }
}

////////////////////////////////////////////////////////////////////////////

enum ApiResult<U> {
    case success(result: U)
    case failure(error: ApiError)
}

public enum ApiError: Error {
    case unknownError
    case internalServerError
    case serverUnreachable
    case parsingError
}
