//
//  PaymentMethodCell.swift
//  PaymentExample
//
//  Created by Alejandro Pasccon on 26/03/2018.
//  Copyright © 2018 Alejandro Pasccon. All rights reserved.
//

import UIKit
import AlamofireImage

class CustomCell: UITableViewCell {

    @IBOutlet weak var thumbnailImageView: UIImageView!
    @IBOutlet weak var paymentMethodLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    func configure(thumbnailUrl: String?, name: String?) {
        if let thumbnailUrl = thumbnailUrl, let url = URL(string: thumbnailUrl) {
            thumbnailImageView.af_setImage(withURL: url, placeholderImage: UIImage(named: "payment_placeholder"))
        }
        
        paymentMethodLabel.text = name
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
