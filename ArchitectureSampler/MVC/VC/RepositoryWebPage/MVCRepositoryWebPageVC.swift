//
//  RepositoryWebPageVC.swift
//  ArchitectureSampler
//
//  Created by N. M on 2023/07/23.
//

import UIKit
import WebKit

class MVCRepositoryWebPageVC: UIViewController {
    @IBOutlet weak private var webView: WKWebView!
    
    private var urlStr: String? // 表示するリポジトリページのURL
    
    /// MVCRepositoryWebPageVCを生成する
    /// - Parameters:
    ///   - model: 表示するリポジトリ情報を含むリポジトリモデルオブジェクト
    static func generateVC(model: RepositoryModel) -> MVCRepositoryWebPageVC {
        let mvcRepositoryWebPageStoryboard = UIStoryboard(name: String(describing: MVCRepositoryWebPageVC.self), bundle: nil)
        let mvcRepositoryWebPageVC = mvcRepositoryWebPageStoryboard.instantiateInitialViewController() as! MVCRepositoryWebPageVC
        mvcRepositoryWebPageVC.urlStr = model.repositoryUrl
        return mvcRepositoryWebPageVC
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // 有効なURLであるかのチェック
        guard let _urlStr = urlStr, let _url = URL(string: _urlStr) else {
            showOneButtonAlert(title: NetworkError.invalid.message)
            return
        }
        // Webページの読み込み
        webView.load(URLRequest(url: _url))
    }
}
