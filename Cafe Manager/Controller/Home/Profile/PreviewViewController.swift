//
//  PreviewViewController.swift
//  Cafe Manager
//
//  Created by Nimesh Lakshan on 2021-04-30.
//

import UIKit
import PDFKit

class PreviewViewController: UIViewController {

    @IBOutlet weak var containerView: UIView!
    
    var path: String?

    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        guard let path = self.path else {
            return
        }
        let url = URL(fileURLWithPath:path)
        let pdfView = PDFView(frame: containerView.bounds)
        pdfView.autoScales = true
        pdfView.displayMode = .singlePage
        pdfView.displayDirection = .horizontal
        pdfView.usePageViewController(true)
        containerView.addSubview(pdfView)
        
        let doc = PDFDocument(url: url)
        pdfView.document = doc
    }

    @IBAction func onBackPressed(_ sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
    }
}
