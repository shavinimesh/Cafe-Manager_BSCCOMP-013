//
//  CircularView.swift
//  Cafe Manager
//
//  Created by Nimesh Lakshan on 2021-04-29.
//

import Foundation
import UIKit

extension UIView {
    func generateRoundView() {
        self.layer.masksToBounds = true
        self.layer.cornerRadius = self.bounds.width / 2
    }
}
