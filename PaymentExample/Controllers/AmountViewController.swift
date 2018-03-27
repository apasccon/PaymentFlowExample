//
//  ViewController.swift
//  PaymentExample
//
//  Created by Alejandro Pasccon on 26/03/2018.
//  Copyright © 2018 Alejandro Pasccon. All rights reserved.
//

import UIKit
import LGButton

class AmountViewController: UIViewController {

    @IBOutlet weak var amountTextField: UITextField!
    @IBOutlet weak var nextStepButton: LGButton!
    @IBOutlet weak var errorLabel: UILabel!
    
    private var fetchedPaymentMethods: [PaymentMethod]?
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        amountTextField.becomeFirstResponder()
    }
    
    @IBAction func next(_ sender: Any) {
        // If the amount is valid, fetch the list of payment methods and inject it to the next screen:
        // - Fetch the payment methods and save locally
        // - Save the amount using the PaymentsManager
        // - Invoke the segue to move to the next screen
        // - In the prepare(for segue:) method inject the fetched payment methods in the next screen
        
        if validateAmount() {
            nextStepButton.isLoading = true
            
            PaymentsManager.shared.fetchPaymentMethods { [weak self] result in
                self?.nextStepButton.isLoading = false
                
                switch result {
                case .success(let paymentMethods):
                    self?.fetchedPaymentMethods = paymentMethods
                    self?.updatePaymentInfoAndContinue()
                    break
                case .failure(let error):
                    Utils.AlertController.alert("Error", message: error.userMessage(), handler: nil).show()
                    break
                }
            }
        }
    }
    
    @IBAction func unwindToAmountViewController(segue: UIStoryboardSegue) {
        // This is called at the end of the payment flow (unwind segue)
        
        if let segue = segue as? UIStoryboardSegueWithCompletion, let message = messageForCurrentPaymentInfo() {
            segue.completion = { [weak self] in
                self?.amountTextField.text = ""
                Utils.AlertController.alert("Datos de su compra", message: message, handler: nil).show()
            }
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "NavigateToPaymentMethods", let vc = segue.destination as? PaymentMethodsViewController {
            vc.paymentMethods = fetchedPaymentMethods
        }
    }
}

// Private
extension AmountViewController {
    fileprivate func updatePaymentInfoAndContinue() {
        PaymentsManager.shared.currentPaymentInfo.selectedAmount = Float(amountTextField.text!) ?? 0
        performSegue(withIdentifier: "NavigateToPaymentMethods", sender: nil)
    }
    
    fileprivate func validateAmount() -> Bool {
        let amount = Float(amountTextField.text!) ?? 0
        
        if amount <= 0 {
            errorLabel.text = "Por favor ingrese el monto"
            return false
        }
        
        errorLabel.text = ""
        return true
    }
    
    // Build a string message from the flow's selected values
    fileprivate func messageForCurrentPaymentInfo() -> String? {
        var message = ""
        let paymentInfo = PaymentsManager.shared.currentPaymentInfo
        
        if let amount = paymentInfo.selectedAmount {
            message += "\nMonto a pagar: \(amount)\n\n"
        }
        if let paymentMethod = paymentInfo.selectedPaymentMethod?.name {
            message += "Método de pago: \(paymentMethod)\n\n"
        }
        if let issuer = paymentInfo.selectedIssuer?.name {
            message += "Banco emisor: \(issuer)\n\n"
        }
        if let installment = paymentInfo.selectedInstallment?.recommendedMessage {
            message += "Forma de pago: \(installment)"
        }
        
        if message == "" {
            return nil
        } else {
            return message
        }
    }
}

// UITextFieldDelegate - Allow the user to enter only float values
extension AmountViewController: UITextFieldDelegate {
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if string.count == 0 {
            return true
        }
        
        let currentText = textField.text ?? ""
        let prospectiveText = (currentText as NSString).replacingCharacters(in: range, with: string)
        
        return prospectiveText.containsOnlyCharactersIn(matchCharacters: "0123456789.")
    }
}
