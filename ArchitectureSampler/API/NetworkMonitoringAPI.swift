//
//  NetworkMonitoringAPI.swift
//  ArchitectureSampler
//
//  Created by N. M on 2023/07/23.
//

import Network

/// 端末のネットワーク接続状況を監視するシングルトンクラス
final class NetworkMonitoringAPI {
    static let shared = NetworkMonitoringAPI()
    private init() {}
    private let monitor = NWPathMonitor()    
    var isOnline: Bool { monitor.currentPath.status == .satisfied } // 端末のネットワーク接続状況
    
    /// 端末のネットワーク接続状況の監視を開始する
    func startMonitoring() {
        let queue = DispatchQueue(label: "NetworkMonitoring")
        monitor.start(queue: queue)
    }    
}
