//
//  PaymentMethodsViewController.swift
//
//  Created by Alejandro Pasccon on 26/03/2018.
//  Copyright © 2018 Alejandro Pasccon. All rights reserved.
//

import UIKit
import LGButton

class PaymentMethodsViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var nextStepButton: LGButton!

    var paymentMethods: [PaymentMethod]?
    var fetchedIssuers: [Issuer]?
    var fetchedInstallments: [Installment]?
    
    var currentPaymentInfo = PaymentsManager.shared.currentPaymentInfo
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Disable the "Next" button until a payment method is selected
        nextStepButton.isEnabled = false
        
        // A little hack to remove extra rows
        tableView.tableFooterView = UIView()
    }
    
    @IBAction func next(_ sender: Any) {
        // From this screen two alternatives of navigation:
        // 1) To the issuers list if any, or
        // 2) To the installments list if no issuers associated to the selected payment method

        if nextStepButton.isEnabled {
            nextStepButton.isLoading = true
            fetchIssuersAndContinue()
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "NavigateToIssuers", let vc = segue.destination as? PaymentIssuersViewController {
            vc.issuers = fetchedIssuers
        }
        else if segue.identifier == "NavigateToInstallments", let vc = segue.destination as? PaymentInstallmentsViewController {
            vc.installments = fetchedInstallments
        }
    }
}

// Private

extension PaymentMethodsViewController {
    fileprivate func fetchIssuersAndContinue() {
        guard let selectedPaymentMethod = currentPaymentInfo.selectedPaymentMethod else {
            return
        }
        
        PaymentsManager.shared.fetchIssuers(forPaymentMethod: selectedPaymentMethod, completion: { [weak self] result in
            self?.nextStepButton.isLoading = false
            
            switch result {
            case .success(let issuers):
                self?.fetchedIssuers = issuers
                
                if issuers.count > 0 {
                    self?.performSegue(withIdentifier: "NavigateToIssuers", sender: nil)
                } else {
                    self?.fetchInstallmentsAndContinue()
                }

                break
            case .failure(let error):
                Utils.AlertController.alert("Error", message: error.userMessage(), handler: nil).show()
                break
            }
        })
    }
    
    fileprivate func fetchInstallmentsAndContinue() {
        guard let selectedPaymentMethod = currentPaymentInfo.selectedPaymentMethod else {
            return
        }

        let selectedAmount = currentPaymentInfo.selectedAmount ?? 0
        
        PaymentsManager.shared.fetchInstallments(forPaymentMethod: selectedPaymentMethod, issuer: nil, amount: selectedAmount) { [weak self] result in
            self?.nextStepButton.isLoading = false
            
            switch result {
            case .success(let installments):
                self?.fetchedInstallments = installments
                self?.performSegue(withIdentifier: "NavigateToInstallments", sender: nil)

                break
            case .failure(let error):
                Utils.AlertController.alert("Error", message: error.userMessage(), handler: nil).show()
                break
            }
        }
    }
}

extension PaymentMethodsViewController: UITableViewDelegate, UITableViewDataSource  {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let paymentMethods = paymentMethods {
            return paymentMethods.count
        }
        
        return 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "CustomCell", for: indexPath) as! CustomCell
        
        if let paymentMethod = paymentMethods?[indexPath.row] {
            cell.configure(thumbnailUrl: paymentMethod.thumbnailUrl, name: paymentMethod.name)
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let paymentMethods = paymentMethods {
            currentPaymentInfo.selectedPaymentMethod = paymentMethods[indexPath.row]
            nextStepButton.isEnabled = true
        }
    }
}
