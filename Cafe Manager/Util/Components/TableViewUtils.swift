//
//  TableViewUtils.swift
//  Cafe Manager
//
//  Created by Nimesh Lakshan on 2021-04-29.
//

import Foundation
import UIKit

extension UITableView {
    
    func exportAsPdfFromTable() -> String {
        let priorBounds = self.bounds

          let fittedSize = self.sizeThatFits(CGSize(
            width: priorBounds.size.width,
            height: self.contentSize.height
          ))

        self.bounds = CGRect(
            x: 0, y: 0,
            width: fittedSize.width,
            height: fittedSize.height
          )

          let pdfPageBounds = CGRect(
            x :0, y: 0,
            width: self.frame.width,
            height: self.frame.height
          )

          let pdfData = NSMutableData()
          UIGraphicsBeginPDFContextToData(pdfData, pdfPageBounds, nil)

          var pageOriginY: CGFloat = 0
          while pageOriginY < fittedSize.height {
            UIGraphicsBeginPDFPageWithInfo(pdfPageBounds, nil)
            UIGraphicsGetCurrentContext()!.saveGState()
            UIGraphicsGetCurrentContext()!.translateBy(x: 0, y: -pageOriginY)
            self.layer.render(in: UIGraphicsGetCurrentContext()!)
            UIGraphicsGetCurrentContext()!.restoreGState()
            pageOriginY += pdfPageBounds.size.height
            self.contentOffset = CGPoint(x: 0, y: pageOriginY) // move "renderer"
          }
          UIGraphicsEndPDFContext()

        self.bounds = priorBounds
          var docURL = (FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)).last! as URL
          docURL = docURL.appendingPathComponent("myDocument.pdf")
//          pdfData.write(to: docURL as URL, atomically: true)
        return saveTablePdf(data: pdfData)
    }
    
    // Save pdf file in document directory
    func saveTablePdf(data: NSMutableData) -> String {
        
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        let docDirectoryPath = paths[0]
        let pdfPath = docDirectoryPath.appendingPathComponent("tablePdf.pdf")
        if data.write(to: pdfPath, atomically: true) {
            return pdfPath.path
        } else {
            return ""
        }
    }
}

