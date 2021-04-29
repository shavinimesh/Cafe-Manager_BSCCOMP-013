//
//  BaseViewController.swift
//  Cafe Manager
//
//  Created by Nimesh Lakshan on 2021-04-28.
//

import Foundation
import Network
import Connectivity

class NetworkMonitor {
    //singleton instane
    static let instance = NetworkMonitor()
    
    var delegate: NetworkListener?
    var connectivity = Connectivity()
    var isReachable: Bool { connectivity.isConnected }
        
    //start monitoring network events
    func startMonitoring() {
        connectivity.isPollingEnabled = true
        connectivity.pollingInterval = AppConfig.connectionCheckTimeout
        connectivity.startNotifier()
        connectivity.whenConnected = { connectivity in
            self.delegate?.onNetworkChanged(connected: true, onMobileData: connectivity.isConnectedViaCellular)
        }
        connectivity.whenDisconnected = { connectivity in
            self.delegate?.onNetworkChanged(connected: false, onMobileData: connectivity.isConnectedViaCellular)
        }
    }
    
    //stop network event monitoring
    func stopMonitoring() {
        connectivity.stopNotifier()
    }
    
}

//MARK: - Protocol to listern to network change events

protocol NetworkListener {
    func onNetworkChanged(connected: Bool, onMobileData: Bool)
}

//MARK: - Extension for protocol methods

extension NetworkListener {
    func onNetworkChanged(connected: Bool, onMobileData: Bool) {}
}
