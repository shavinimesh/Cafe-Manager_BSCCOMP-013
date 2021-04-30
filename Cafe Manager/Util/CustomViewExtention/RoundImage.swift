//
//  RoundImage.swift
//  Cafe Manager
//
//  Created by Nimesh Lakshan on 2021-04-28.
//

import UIKit

extension UIImageView {
    func generateRoundImage() {
        self.layer.cornerRadius = 0.5 * self.bounds.size.width
        self.clipsToBounds = true
    }
}
