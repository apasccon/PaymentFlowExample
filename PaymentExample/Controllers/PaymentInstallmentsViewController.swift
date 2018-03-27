//
//  PaymentInstallmentsViewController.swift
//  PaymentExample
//
//  Created by Alejandro Pasccon on 26/03/2018.
//  Copyright © 2018 Alejandro Pasccon. All rights reserved.
//

import UIKit
import LGButton

class PaymentInstallmentsViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var nextStepButton: LGButton!
    
    var installments: [Installment]?
    
    var currentPaymentInfo = PaymentsManager.shared.currentPaymentInfo

    override func viewDidLoad() {
        super.viewDidLoad()
        
        nextStepButton.isEnabled = false
        tableView.tableFooterView = UIView()
    }
    
    @IBAction func next(_ sender: Any) {
        // Perform the unwind segue in order to get back to the main screen
        if nextStepButton.isEnabled {
            performSegue(withIdentifier: "GetBackToMainScreen", sender: self)
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}

extension PaymentInstallmentsViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let installments = installments {
            return installments.count
        }
        
        return 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "CustomCell", for: indexPath) as! CustomCell
        
        if let installment = installments?[indexPath.row] {
            cell.configure(thumbnailUrl: nil, name: installment.recommendedMessage)
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let installments = installments {
            currentPaymentInfo.selectedInstallment = installments[indexPath.row]
            nextStepButton.isEnabled = true
        }
    }
}
