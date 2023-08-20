//
//  MVPRepositoryWebPageVC.swift
//  ArchitectureSampler
//
//  Created by N. M on 2023/07/24.
//

import UIKit
import WebKit

class MVPRepositoryWebPageVC: UIViewController {
    @IBOutlet weak private var webView: WKWebView!
    
    private var urlStr: String? // リポジトリページのURL文字列
    private var presenter: RepositoryWebPagePresenterInput!
    
    /// MVPRepositoryWebPageVCを生成する
    /// - Parameters:
    ///   - model: 表示するリポジトリ情報を含むリポジトリモデルオブジェクト
    static func generateVC(model: RepositoryModel) -> MVPRepositoryWebPageVC {
        let mvpRepositoryWebPageStoryboard = UIStoryboard(name: String(describing: MVPRepositoryWebPageVC.self), bundle: nil)
        let mvpRepositoryWebPageVC = mvpRepositoryWebPageStoryboard.instantiateInitialViewController() as! MVPRepositoryWebPageVC
        mvpRepositoryWebPageVC.urlStr = model.repositoryUrl
        return mvpRepositoryWebPageVC
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        presenter.viewDidLoad()
    }
    
    /// プレゼンターを注入する
    /// - Parameters:
    ///   - presenter: プレゼンター
    func inject(presenter: RepositoryWebPagePresenterInput) {
        self.presenter = presenter
    }
}

extension MVPRepositoryWebPageVC: RepositoryWebPagePresenterOutput {
    /// 引数urlのWebページを表示する
    /// - Parameters:
    ///   -request: 表示するWebページのURL
    func load(request: URL) {
        webView.load(URLRequest(url: request))
    }
    
    /// アラートを表示する
    /// - Parameters:
    ///   - title: アラートに表示するタイトル
    func showAlert(title: String) {
        showOneButtonAlert(title: title)
    }
}
