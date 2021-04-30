//
//  ProfileViewController.swift
//  Cafe Manager
//
//  Created by Nimesh Lakshan on 2021-04-28.
//

import UIKit

class ProfileViewController: BaseViewController {
    
    @IBOutlet weak var imgProfile: UIImageView!
    @IBOutlet weak var CategoryViewCell: UIImageView!
    @IBOutlet weak var lblUserName: UILabel!
    @IBOutlet weak var lblPhoneNo: UILabel!
    
    @IBOutlet weak var txtFromDate: UITextField!
    @IBOutlet weak var txtToDate: UITextField!
    @IBOutlet weak var lblTotalAmount: UILabel!
    @IBOutlet weak var tblPastOrders: UITableView!
    
    var periodTotal: Double = 0
    
    let datePicker = UIDatePicker()
    let dateFormatter = DateFormatter()
    
    var startDate: Date!
    var endDate: Date!
    
    var documentPath: String?
    
    var fetchedOrderList: [Order] = []
    var filteredOrders: [Order] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        registerNIB()
        imgProfile.generateRoundImage()
        // Do any additional setup after loading the view.
    }
    
    override func viewDidAppear(_ animated: Bool) {
        firebaseOP.delegate = self
        datePicker.date = Date()
        
        if let user = SessionManager.getUserSesion() {
//            if let image = user.imageRes {
//                self.imgProfile.kf.setImage(with: URL(string: image))
//            }
            lblUserName.text = user.userName
            lblPhoneNo.text = user.phoneNo
        }
        buildDatePicker()
        txtToDate.text = dateFormatter.string(from: Date())
        txtFromDate.text = dateFormatter.string(from: Date())
        
        fetchFromServer()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == StoryBoardSegues.AccountToPreview {
            (segue.destination as! PreviewViewController).path = self.documentPath
        }
    }
    
    @IBAction func OnSignOutPressed(_ sender: UIButton) {
        displayActionSheet(title: "Sign Out", message: "Are You sure You Want To Sign Out From The Application ?", positiveTitle: "Sign out", negativeTitle: "Cancel", positiveHandler: {
            action in
            DispatchQueue.main.async {
                self.dismiss(animated: true, completion: nil)
                SessionManager.clearUserSession()
                self.performSegue(withIdentifier: "profileToSplashScreen", sender: nil)
                
            }
        }, negativeHandler: {
            action in
        })
    }
        
    func registerNIB() {
        tblPastOrders.register(UINib(nibName: OrderSummaryCell.nibName, bundle: nil), forCellReuseIdentifier: OrderSummaryCell.reuseIdentifier)
        self.tblPastOrders.estimatedRowHeight = 250
        self.tblPastOrders.rowHeight = UITableView.automaticDimension
    }
    
    func fetchFromServer() {
        displayProgress()
        firebaseOP.getAllOrders()
    }
    
    func refreshData() {
        filteredOrders.removeAll()
        let range = startDate...endDate
        for order in fetchedOrderList {
            if range.contains(order.orderDate) {
                filteredOrders.append(order)
            }
        }
        periodTotal = filteredOrders.lazy.map {$0.orderTotal}.reduce(0 , +)
        lblTotalAmount.text = periodTotal.lkrString
        tblPastOrders.reloadData()
    }
    
    func buildDatePicker() {
        let pickerToolBar = UIToolbar()
        pickerToolBar.sizeToFit()
        
        let doneAction = UIBarButtonItem(barButtonSystemItem: .done, target: nil, action: #selector(onDatePicked))
        let cancelButton = UIBarButtonItem(barButtonSystemItem: .cancel, target: nil, action: #selector(onPickerCancelled))
        let space = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        pickerToolBar.setItems([doneAction, space, cancelButton], animated: true)
        txtToDate.inputAccessoryView = pickerToolBar
        txtFromDate.inputAccessoryView = pickerToolBar
        
        txtToDate.inputView = datePicker
        txtFromDate.inputView = datePicker
        datePicker.datePickerMode = .date
        dateFormatter.dateStyle = .medium
        
        if #available(iOS 13.4, *) {
           datePicker.preferredDatePickerStyle = .wheels
        }
    }
    
    @objc func onPickerCancelled() {
        self.view.endEditing(true)
    }
    
    @objc func onDatePicked() {
        if txtFromDate.isFirstResponder {
            if datePicker.date > endDate {
                txtToDate.text = dateFormatter.string(from: datePicker.date)
                endDate = datePicker.date
                return
            }
            txtFromDate.text = dateFormatter.string(from: datePicker.date)
            startDate = datePicker.date
        }
        if txtToDate.isFirstResponder {
            if datePicker.date < startDate {
                txtFromDate.text = dateFormatter.string(from: datePicker.date)
                startDate = datePicker.date
                return
            }
            txtToDate.text = dateFormatter.string(from: datePicker.date)
            endDate = datePicker.date
        }
        self.view.endEditing(true)
        refreshData()
    }

}

extension ProfileViewController : UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return filteredOrders.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tblPastOrders.dequeueReusableCell(withIdentifier: OrderSummaryCell.reuseIdentifier, for: indexPath) as! OrderSummaryCell
        cell.selectionStyle = .none
        cell.delegate = self
        cell.configureCell(order: filteredOrders[indexPath.row], index: indexPath.row)
        return cell
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        cell.transform = CGAffineTransform(scaleX: 0, y : 0)
        UIView.animate(withDuration: 0.5, animations: {
            cell.transform = CGAffineTransform(scaleX: 1, y : 1)
        })
    }
}

extension ProfileViewController: OrderSummaryCellActions {
    func onSummaryCellPrintPressed(path: String) {
        self.documentPath = path
        self.performSegue(withIdentifier: StoryBoardSegues.AccountToPreview, sender: nil)
    }
}

extension ProfileViewController : FirebaseActions {
    func onConnectionLost() {
        refreshControl.endRefreshing()
        dismissProgress()
        displayWarningMessage(message: "Please check internet connection")
    }
    func onAllOrdersLoaded(orderedList: [Order]) {
        dismissProgress()
        self.filteredOrders.removeAll()
        self.fetchedOrderList.removeAll()
        self.fetchedOrderList.append(contentsOf: orderedList)
        self.filteredOrders.append(contentsOf: orderedList)
        startDate = fetchedOrderList.min { $0.orderDate < $1.orderDate }?.orderDate
        endDate = fetchedOrderList.min { $0.orderDate > $1.orderDate }?.orderDate
        txtFromDate.text = dateFormatter.string(from: startDate)
        txtToDate.text = dateFormatter.string(from: endDate)
        refreshData()
    }
    func onAllOrdersLoadFailed(error: String) {
        dismissProgress()
        displayErrorMessage(message: error)
    }
}
