//
//  AppDelegate.swift
//  ArchitectureSampler
//
//  Created by N. M on 2023/08/20.
//

import UIKit

@main
class AppDelegate: UIResponder, UIApplicationDelegate {
    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // アプリ起動後、最初に表示する画面の設定を行う
        window = UIWindow(frame: UIScreen.main.bounds)
        Router.showRoot(window: window)
        // 端末のネットワーク状況の監視を開始する
        NetworkMonitoringAPI.shared.startMonitoring()
        return true
    }
}

