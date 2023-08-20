//
//  MVCRepositoryListVC.swift
//  ArchitectureSampler
//
//  Created by N. M on 2023/07/22.
//

import UIKit

final class MVCRepositoryTableVC: UIViewController {
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
    
    /// MVCRepositoryTableVCを生成する
    static func generateVC() -> MVCRepositoryTableVC {
        let mvcRepositoryTableVCStoryboard = UIStoryboard(name: String(describing: MVCRepositoryTableVC.self), bundle: nil)
        let mvcRepositoryTableVC = mvcRepositoryTableVCStoryboard.instantiateInitialViewController() as! MVCRepositoryTableVC
        return mvcRepositoryTableVC
    }
    
    private var repositoryModels: [RepositoryModel] = [] // TableViewに表示するリポジトリモデルオブジェクトのリスト
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupDelegate()
    }
}

extension MVCRepositoryTableVC {
    /// MVCRepositoryTableVCが受け持つデリゲートを設定する
    private func setupDelegate() {
        repositoryTableView.delegate = self
        repositoryTableView.dataSource = self
        searchWordTextField.delegate = self
    }
    
    /// 検索ワードを含むリポジトリ名を検索し、検索にかかったリポジトリを保存した後にTableViewを更新する
    /// - Parameters:
    ///   - searchWord: 検索ワード
    private func reload(searchWord: String) {
        indicator.startAnimating()
        GitHubAPI.shared.fetchRepository(name: searchWord) { [weak self] result in
            DispatchQueue.main.async {
                guard let _self = self else { return }
                switch result {
                case let .success(models):
                    // 検索にかかったリポジトリを保存
                    _self.repositoryModels = models
                    // TableViewをリロード
                    _self.repositoryTableView.reloadData()

                case let .failure(error):
                    // エラー名をアラートで表示
                    _self.showOneButtonAlert(title: error.message)
                }
                _self.indicator.stopAnimating()
            }
        }
    }
}

extension MVCRepositoryTableVC: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // 端末のネットワーク接続状況のチェック
        guard NetworkMonitoringAPI.shared.isOnline else {
            showOneButtonAlert(title: NetworkError.network.message)
            return
        }
        // 有効なURLであるかのチェック
        guard let _ = URL(string: repositoryModels[indexPath.item].repositoryUrl) else {
            showOneButtonAlert(title: NetworkError.invalid.message)
            return
        }
        // MVCRepositoryWeb画面へ遷移
        Router.showMVCRepositoryWebPage(from: self, model: repositoryModels[indexPath.item])
        // セルの選択を解除
        tableView.deselectRow(at: indexPath, animated: true)
    }
}

extension MVCRepositoryTableVC: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        repositoryModels.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let repositoryModel = repositoryModels[indexPath.item]
        let cell = repositoryTableView.dequeueReusableCell(withIdentifier: RepositoryCell.reuseIdentifier, for: indexPath) as! RepositoryCell
        cell.setupUI(model: repositoryModel)
        return cell
    }
}

extension MVCRepositoryTableVC: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        // キーボードを非表示にする
        textField.resignFirstResponder()
        // テキストフィールド内にキーワードが入力されているかのチェック
        guard let text = searchWordTextField.text, !text.isEmpty else { return true }
        // リポジトリ検索処理の実行
        reload(searchWord: text)
        return true
    }
}

