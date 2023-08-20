//
//  MVVMRepositoryWebPage.swift
//  ArchitectureSampler
//
//  Created by N. M on 2023/08/02.
//

import UIKit
import WebKit
import RxCocoa
import RxSwift

class MVVMRepositoryWebPageVC: UIViewController {
    @IBOutlet weak private var webView: WKWebView!
    
    private var viewModel: MVVMRepositoryWebPageVM!
    private let viewDidLoadRelay: PublishRelay<Void> = .init()
    private let disposeBag = DisposeBag()
    
    private var model: RepositoryModel!
    
    /// MVMRepositoryWebPageVCを生成する
    /// - Parameters:
    ///   - model: 表示するリポジトリ情報を含むリポジトリモデルオブジェクト
    static func generateVC(model: RepositoryModel) -> MVVMRepositoryWebPageVC {
        let mvvmRepositoryWebPageStoryboard = UIStoryboard(name: String(describing: MVVMRepositoryWebPageVC.self), bundle: nil)
        let mvvmRepositoryWebPageVC = mvvmRepositoryWebPageStoryboard.instantiateInitialViewController() as! MVVMRepositoryWebPageVC
        mvvmRepositoryWebPageVC.model = model
        return mvvmRepositoryWebPageVC
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupViewModel(model: model)
        viewDidLoadRelay.accept(())
    }
}

extension MVVMRepositoryWebPageVC {
    /// ViewModelで保持している各種ObservableをViewControllerにバインドする
    /// - Parameters:
    ///   - model: 表示するリポジトリ情報を含むリポジトリモデルオブジェクト 
    private func setupViewModel(model: RepositoryModel) {
        viewModel = MVVMRepositoryWebPageVM(input: self, model: model)
        viewModel.loadObservable
            .bind(to: Binder(self) { vc, request in
                vc.webView.load(request)
            })
            .disposed(by: disposeBag)
    }
}

extension MVVMRepositoryWebPageVC: RepositoryWebPageInput {
    var viewDidLoadObservable: Observable<Void> { viewDidLoadRelay.asObservable() }
}
