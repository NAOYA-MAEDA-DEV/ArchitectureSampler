//
//  ArchitecturePattern.swift
//  ArchitectureSampler
//
//  Created by N. M on 2023/08/02.
//

import UIKit

/// アーキテクチャパターンの種類
enum ArchitecturePattern: CaseIterable {
    case mvc, mvc_delegate, mvc_notification, mvp, mvvm_rxswift
    
    /// アーキテクチャ名を表す文字列
    var name: String {
        switch self {
        case .mvc:
            return "MVC"
            
        case .mvc_delegate:
            return "MVC with Delegate"
            
        case .mvc_notification:
            return "MVC with Notification"
            
        case .mvp:
            return "MVP"
            
        case .mvvm_rxswift:
            return "MVVM with RxSwift"
        }
    }
    
    /// アーキテクチャ詳細画面へ遷移する
    /// - Parameters:
    ///   - from: 遷移元のVC
    func segue(from: UIViewController) {
        switch self {
        case .mvc:
            Router.showMVCRepositoryTablePage(from: from)
            
        case .mvc_delegate:
            Router.showMVCRepositoryTablewithDelegatePage(from: from)
            
        case .mvc_notification:
            Router.showMVCRepositoryTablewithNotificationPage(from: from)
            
        case .mvp:
            Router.showMVPRepositoryTablePage(from: from)
            
        case .mvvm_rxswift:
            Router.showMVVMRepositoryTablePage(from: from)
        }
    }
}
