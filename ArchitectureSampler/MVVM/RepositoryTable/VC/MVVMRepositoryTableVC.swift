//
//  MVVMPRepositoryListVC.swift
//  ArchitectureSampler
//
//  Created by N. M on 2023/08/02.
//

import UIKit
import RxSwift
import RxCocoa

class MVVMRepositoryTableVC: UIViewController {
    @IBOutlet weak private var repositoryTableView: UITableView! {
        didSet {
            repositoryTableView.register(RepositoryCell.nib, forCellReuseIdentifier: RepositoryCell.reuseIdentifier)
        }
    }
    @IBOutlet weak private var searchWordTextField: UITextField! {
        didSet {
            searchWordTextField.placeholder = "Enter Keyword"
        }
    }
    @IBOutlet weak private var indicator: UIActivityIndicatorView! {
        didSet {
            indicator.isHidden = true
            indicator.hidesWhenStopped = true
        }
    }
    
    /// VVMRepositoryTableVCを生成する
    static func generateVC() -> MVVMRepositoryTableVC {
        let mvvmRepositoryTableViewStoryboard = UIStoryboard(name: String(describing: MVVMRepositoryTableVC.self), bundle: nil)
        let mvvmRepositoryTableVC = mvvmRepositoryTableViewStoryboard.instantiateInitialViewController() as! MVVMRepositoryTableVC
        return mvvmRepositoryTableVC
    }
    
    private var viewModel: MVVMRepositoryTableVM!
    private let didSelectRelay: PublishRelay<Int> = .init()
    private let disposeBag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupDelegate()
        setupViewModel()
    }
}

extension MVVMRepositoryTableVC {
    /// MVVMRepositoryTableVCが受け持つデリゲートを設定する
    private func setupDelegate() {
        repositoryTableView.delegate = self
        repositoryTableView.dataSource = self
        searchWordTextField.delegate = self
    }
    
    /// ViewModelで保持している各種ObservableをMVVMRepositoryTableVCにバインドする
    func setupViewModel() {
        viewModel = MVVMRepositoryTableVM(input: self)
        
        viewModel
            .updateRepositoryModelsObservable
            .bind(to: Binder(self) { vc, _ in
                vc.repositoryTableView.reloadData()
            })
            .disposed(by: disposeBag)
        
        viewModel
            .loadingObservable
            .bind(to: Binder(self) { vc, loading in
                vc.indicator.isHidden = !loading
                loading
                ? vc.indicator.startAnimating()
                : vc.indicator.stopAnimating()
            })
            .disposed(by: disposeBag)
        
        viewModel
            .selectRepositoryModelObservable
            .bind(to: Binder(self) { vc, repositoryModel in
                Router.showMVVMRepositoryWebPage(from: vc, model: repositoryModel)
            })
            .disposed(by: disposeBag)
        
        viewModel
            .errorMessageObservable
            .bind(to: Binder(self) { vc, message in
                vc.showOneButtonAlert(title: message)
            })
            .disposed(by: disposeBag)
    }
}

extension MVVMRepositoryTableVC: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // 端末のネットワーク接続状況のチェック
        guard NetworkMonitoringAPI.shared.isOnline else {
            showOneButtonAlert(title: NetworkError.network.message)
            return
        }
        // 選択した行数を発行
        didSelectRelay.accept(indexPath.item)
    }
}

extension MVVMRepositoryTableVC: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        viewModel.repositoryModels.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let repositoryModel = viewModel.repositoryModels[indexPath.row]
        let cell = repositoryTableView.dequeueReusableCell(withIdentifier: RepositoryCell.reuseIdentifier, for: indexPath) as! RepositoryCell
        cell.setupUI(model: repositoryModel)
        return cell
    }
}

extension MVVMRepositoryTableVC: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        // キーボードを非表示にする
        textField.resignFirstResponder()
        return true
    }
}

extension MVVMRepositoryTableVC: RepositoryTableVMInput {
    var searchWordTextFieldObservable: Observable<String?> {
        searchWordTextField.rx.controlEvent(.editingDidEnd)
            .compactMap { [weak self] in
                self?.searchWordTextField.text
            }
    }
    
    var didSelectObservable: Observable<Int> {
        didSelectRelay.asObservable()
    }
}
