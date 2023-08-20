//
//  Router.swift
//  ArchitectureSampler
//
//  Created by N. M on 2023/07/22.
//

import UIKit

final class Router {
    /// アプリ起動時に表示する画面の設定を行う
    /// - Parameters:
    ///   - window: 表示する画面をセットするWindow
    static func showRoot(window: UIWindow?) {
        let architectureTableVCStoryboard = UIStoryboard(name: String(describing: ArchitectureTableVC.self), bundle: nil)
        let architectureTableVC = architectureTableVCStoryboard.instantiateInitialViewController() as! ArchitectureTableVC
        let nav = UINavigationController(rootViewController: architectureTableVC)
        window?.rootViewController = nav
        window?.makeKeyAndVisible()
    }
}

/// MVC用
extension Router {
    /// MVCRepositoryTable画面を表示する
    /// - Parameters:
    ///   - from: 遷移元のVC
    static func showMVCRepositoryTablePage(from: UIViewController) {
        let vc = MVCRepositoryTableVC.generateVC()
        from.show(next: vc)
    }
    
    /// MVCRepositoryTablewithDelegate画面を表示する
    /// - Parameters:
    ///   - from: 遷移元のVC
    static func showMVCRepositoryTablewithDelegatePage(from: UIViewController) {
        let vc = MVCRepositoryTablewithDelegateVC.generateVC()
        from.show(next: vc)
    }
    
    /// MVCRepositoryTablewithNotification画面を表示する
    /// - Parameters:
    ///   - from: 遷移元のVC
    static func showMVCRepositoryTablewithNotificationPage(from: UIViewController) {
        let vc = MVCRepositoryTablewithNotificationVC.generateVC()
        from.show(next: vc)
    }
    
    /// MVCRepositoryWeb画面を表示する
    /// - Parameters:
    ///   - from: 遷移元のVC
    ///   - model: MVCRepositoryWeb画面で表示するリポジトリページ情報を含むリポジトリモデルオブジェクト
    static func showMVCRepositoryWebPage(from: UIViewController, model: RepositoryModel) {
        let vc = MVCRepositoryWebPageVC.generateVC(model: model)
        from.show(next: vc)
    }
}

/// MVP用
extension Router {
    /// MVPRepositoryTable画面を表示する
    /// - Parameters:
    ///   - from: 遷移元のVC
    static func showMVPRepositoryTablePage(from: UIViewController) {
        let vc = MVPRepositoryTableVC.generateVC()
        let presenter = MVPRepositoryTablePresenter(output: vc, api: GitHubAPI.shared)
        vc.inject(presenter: presenter)
        from.show(next: vc)
    }
    
    /// MVPRepositoryWeb画面を表示する
    /// - Parameters:
    ///   - from: 遷移元の画面VC
    ///   - model: MVPRepositoryWebPage画面で表示するリポジトリページ情報を含むリポジトリモデルオブジェクト
    static func showMVPRepositoryWebPage(from: UIViewController, model: RepositoryModel) {
        let vc = MVPRepositoryWebPageVC.generateVC(model: model)
        let presenter = MVPRepositoryWebPagePresenter(output: vc, model: model)
        vc.inject(presenter: presenter)
        from.show(next: vc)
    }
}

/// MVVM用
extension Router {
    /// MVVMRepositoryTable画面を表示する
    /// - Parameters:
    ///   - from: 遷移元のVC
    static func showMVVMRepositoryTablePage(from: UIViewController) {
        let vc = MVVMRepositoryTableVC.generateVC()
        from.show(next: vc)
    }
    
    /// MVVMRepositoryWeb画面を表示する
    /// - Parameters:
    ///   - from: 遷移元の画面VC
    ///   - model: MVVMRepositoryWeb画面で表示するリポジトリページ情報を含むリポジトリモデルオブジェクト
    static func showMVVMRepositoryWebPage(from: UIViewController, model: RepositoryModel) {
        let vc = MVVMRepositoryWebPageVC.generateVC(model: model)
        from.show(next: vc)
    }
}
