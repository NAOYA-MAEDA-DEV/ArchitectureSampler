//
//  UIVCExtension.swift
//  ArchitectureSampler
//
//  Created by N. M on 2023/07/23.
//

import UIKit

extension UIViewController {
    /// [OK]ボタンのみのアラートを表示する
    /// - Parameters:
    ///   - title: アラートのタイトルに表示する文字列
    ///   - message: アラートの本文に表示する文字列
    ///   - completion: [OK]ボタンタップ後に実行する処理
    func showOneButtonAlert(title: String, message: String = "", completion: (() -> Void)? = nil) {
        let alert: UIAlertController = UIAlertController(title: title, message: message, preferredStyle:  UIAlertController.Style.alert)
        let defaultAction: UIAlertAction = UIAlertAction(title: "OK", style: UIAlertAction.Style.default) { _ in
            completion?()
        }
        alert.addAction(defaultAction)
        self.present(alert, animated: true, completion: nil)
    }
    
    /// 画面遷移を行う
    /// - Parameters:
    ///   - next: 遷移先画面のVC
    ///   - animated: 画面遷移中のアニメーション可否
    ///   - completion: 画面遷移後に実行する処理
    func show(next: UIViewController, animated: Bool = true, completion: (() -> Void)? = nil) {
      DispatchQueue.main.async {
        if let nav = self.navigationController {
          nav.pushViewController(next, animated: animated)
          completion?()
        } else {
          self.present(next, animated: animated, completion: completion)
        }
      }
    }
}
