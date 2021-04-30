//
//  OrderViewController.swift
//  Cafe Manager
//
//  Created by Nimesh Lakshan on 2021-04-28.
//

import UIKit

class OrderViewController: BaseViewController {

    @IBOutlet weak var imgProfile: UIImageView!
    @IBOutlet weak var segmentOrderType: UISegmentedControl!
    @IBOutlet weak var tblOrders: UITableView!
    
    
    let calendar = Calendar(identifier: .gregorian)
    
    var fetchedOrders: [Order] = []
    var filteredOrders: [Order] = []
    var selectedIndex = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        imgProfile.generateRoundImage()
        registerNIB()
        tblOrders.accessibilityIdentifier = "tblOrders"
    }
    
    override func viewDidAppear(_ animated: Bool) {
        firebaseOP.delegate = self
        if #available(iOS 10.0, *) {
            tblOrders.refreshControl = refreshControl
        } else {
            tblOrders.addSubview(refreshControl)
        }
        refreshControl.addTarget(self, action: #selector(refreshOrderData), for: .valueChanged)
        displayProgress()
        firebaseOP.getAllOrders()
    }
    @IBAction func onSegmentChanged(_ sender: UISegmentedControl) { switch sender.selectedSegmentIndex {
    case 0:
        filteredOrders.removeAll()
        filteredOrders = fetchedOrders.filter {
            $0.orderStatus == OrderStatus.ORDER_PENDING
        }
        tblOrders.reloadData()
        return
    case 1:
        filteredOrders.removeAll()
        filteredOrders = fetchedOrders.filter {
            $0.orderStatus == OrderStatus.ORDER_PREPERATION
        }
        tblOrders.reloadData()
        return
    case 2:
        filteredOrders.removeAll()
        filteredOrders = fetchedOrders.filter {
            $0.orderStatus == OrderStatus.ORDER_READY ||
                $0.orderStatus == OrderStatus.ORDER_ARRIVING
        }
        tblOrders.reloadData()
        return
    case 3:
        filteredOrders.removeAll()
        filteredOrders = fetchedOrders.filter {
            $0.orderStatus == OrderStatus.ORDER_COMPLETED ||
                $0.orderStatus == OrderStatus.ORDER_CANCELLED
        }
        tblOrders.reloadData()
        return
    default:
        NSLog("Default")
    }
}

func registerNIB() {
    tblOrders.register(UINib(nibName: OrderItemTableViewCell.nibName, bundle: nil), forCellReuseIdentifier: OrderItemTableViewCell.reuseIdentifier)
}

@objc func refreshOrderData() {
    firebaseOP.getAllOrders()
}

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == StoryBoardSegues.ordersToOrderInfo {
            (segue.destination as! OrderDetailViewController).order = filteredOrders[selectedIndex]
        }
    }
}

extension OrderViewController: UITableViewDelegate, UITableViewDataSource, OrderItemCellActions {
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tblOrders.dequeueReusableCell(withIdentifier: OrderItemTableViewCell.reuseIdentifier, for: indexPath) as! OrderItemTableViewCell
        cell.selectionStyle = .none
        cell.delegete = self
        cell.configureCell(order: filteredOrders[indexPath.row], index: indexPath.row)
        return cell
    }
    
func onOrderAcceptedOrRejected(isAccepted: Bool, order: Order, index: Int) {
    displayProgress()
    firebaseOP.changeOrderStatus(order: order, status: isAccepted ? 1 : 5)
    self.selectedIndex = index
}

func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return filteredOrders.count
}

func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
    cell.transform = CGAffineTransform(translationX: cell.contentView.frame.width, y: 0)
    UIView.animate(withDuration: 1.0, delay: 0.05 * Double(indexPath.row), usingSpringWithDamping: 0.4, initialSpringVelocity: 0.1,
                   options: .curveEaseIn, animations: {
                    cell.transform = CGAffineTransform(translationX: cell.contentView.frame.width, y: cell.contentView.frame.height)
                   })
}

func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    self.selectedIndex = indexPath.row
    self.performSegue(withIdentifier: StoryBoardSegues.ordersToOrderInfo, sender: nil)
}
}

extension OrderViewController: FirebaseActions {
func onConnectionLost() {
    refreshControl.endRefreshing()
    dismissProgress()
    displayWarningMessage(message: "Please check internet connection")
}
func onAllOrdersLoaded(orderedList: [Order]) {
    refreshControl.endRefreshing()
    dismissProgress()
    fetchedOrders.removeAll()
    filteredOrders.removeAll()
    fetchedOrders.append(contentsOf: orderedList)
    filteredOrders.append(contentsOf: orderedList)
    tblOrders.reloadData()
    onSegmentChanged(self.segmentOrderType)
}
func onAllOrdersLoadFailed(error: String) {
    refreshControl.endRefreshing()
    dismissProgress()
    displayErrorMessage(message: error)
}
func onOrderStatusChanged(status: Int) {
    dismissProgress()
    displaySuccessMessage(message: "Order status changed!", completion: nil)
    refreshOrderData()
}
func onOrderStatusNotChanged() {
    dismissProgress()
    displayErrorMessage(message: "Failed to change order status!")
}
}
