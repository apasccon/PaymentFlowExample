//
//  PaymentsManager.swift
//
//  Created by Alejandro Pasccon on 26/03/2018.
//  Copyright © 2018 Alejandro Pasccon. All rights reserved.
//

import Foundation

class PaymentsManager {

    var currentPaymentInfo: PaymentInfo
    
    // Singleton
    private init() {
        currentPaymentInfo = PaymentInfo()
    }
    
    static let shared = PaymentsManager()
    
    
    func fetchPaymentMethods(completion: ((_ result: ManagerResult<[PaymentMethod]>) -> Void)?) {
        ApiClient.shared.fetchPaymentMethods { [weak self] result in
            switch result {
            case .success(let paymentMethods):
                completion?(ManagerResult.success(paymentMethods))
                break
            case .failure(let error):
                if let error = self?.managerError(fromError: error) {
                    completion?(ManagerResult.failure(error))
                } else {
                    completion?(ManagerResult.failure(.unknownError))
                }
                break
            }
        }
    }
    
    func fetchIssuers(forPaymentMethod paymentMethod: PaymentMethod, completion: ((_ result: ManagerResult<[Issuer]>) -> Void)?) {
        guard let paymentMethodId = paymentMethod.paymentMethodId else {
            return
        }
        
        ApiClient.shared.fetchPaymentMethodIssuers(paymentMethodId: paymentMethodId) { [weak self] result in
            switch result {
            case .success(let issuers):
                completion?(ManagerResult.success(issuers))
                break
            case .failure(let error):
                if let error = self?.managerError(fromError: error) {
                    completion?(ManagerResult.failure(error))
                } else {
                    completion?(ManagerResult.failure(.unknownError))
                }
                break
            }
        }
    }
    
    func fetchInstallments(forPaymentMethod paymentMethod: PaymentMethod, issuer: Issuer?, amount: Float, completion: ((_ result: ManagerResult<[Installment]>) -> Void)?) {
        guard let paymentMethodId = paymentMethod.paymentMethodId else {
            return
        }
        
        ApiClient.shared.fetchAvailableInstallments(paymentMethodId: paymentMethodId, issuerId: issuer?.issuerId, amount: amount) { [weak self] result in
            switch result {
            case .success(let installments):
                completion?(ManagerResult.success(installments))
                break
            case .failure(let error):
                if let error = self?.managerError(fromError: error) {
                    completion?(ManagerResult.failure(error))
                } else {
                    completion?(ManagerResult.failure(.unknownError))
                }
                break
            }
        }
    }
}

// Private
extension PaymentsManager {
    fileprivate func managerError(fromError error: ApiError) -> ManagerError {
        switch error {
        case .unknownError:
            return .unknownError
        case .internalServerError:
            return .internalServerError
        case .serverUnreachable:
            return .serverUnreachable
        default:
            return .unknownError
        }
    }
}

////////////////////////////////////////////////////////

public enum ManagerError: Error {
    case unknownError
    case internalServerError
    case serverUnreachable
}

extension ManagerError {
    func userMessage() -> String {
        switch self {
        case .unknownError:
            return "Ocurrió un problema tratando de obtener datos remotos. Por favor reintente luego."
        case .internalServerError:
            return "El servidor respondió de forma inesperada. Por favor intente nuevamente más tarde."
        case .serverUnreachable:
            return "El servidor está tomando demasiado tiempo en responder. Por favor intente nuevamente más tarde."
        }
    }
}

public enum ManagerResult<U> {
    case success(U)
    case failure(ManagerError)
}
