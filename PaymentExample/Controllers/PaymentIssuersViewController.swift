//
//  PaymentIssuersViewController.swift
//  PaymentExample
//
//  Created by Alejandro Pasccon on 26/03/2018.
//  Copyright © 2018 Alejandro Pasccon. All rights reserved.
//

import UIKit
import LGButton

class PaymentIssuersViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var nextStepButton: LGButton!
    
    var issuers: [Issuer]?
    var fetchedInstallments: [Installment]?

    var currentPaymentInfo = PaymentsManager.shared.currentPaymentInfo

    override func viewDidLoad() {
        super.viewDidLoad()

        nextStepButton.isEnabled = false
        tableView.tableFooterView = UIView()
    }

    @IBAction func next(_ sender: Any) {
        // From this screen:
        // - Fetch the installments list and save locally
        // - Invoke the segue to move to the next screen
        // - In the prepare(for segue:) method inject the fetched installments in the next screen

        
        if nextStepButton.isEnabled,
            let amount = currentPaymentInfo.selectedAmount,
            let selectedPaymentMethod = currentPaymentInfo.selectedPaymentMethod,
            let selectedIssuer = currentPaymentInfo.selectedIssuer {
            
            nextStepButton.isLoading = true
            
            PaymentsManager.shared.fetchInstallments(forPaymentMethod: selectedPaymentMethod, issuer: selectedIssuer, amount: amount, completion: { [weak self] result in
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
            })
        }
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "NavigateToInstallments", let vc = segue.destination as? PaymentInstallmentsViewController {
            vc.installments = fetchedInstallments
        }
    }
}

extension PaymentIssuersViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let issuers = issuers {
            return issuers.count
        }
        
        return 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "CustomCell", for: indexPath) as! CustomCell
        
        if let issuer = issuers?[indexPath.row] {
            cell.configure(thumbnailUrl: issuer.thumbnailUrl, name: issuer.name)
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let issuers = issuers {
            currentPaymentInfo.selectedIssuer = issuers[indexPath.row]
            nextStepButton.isEnabled = true
        }
    }
}
