//
//  MVCRepositoryTablewithDelegateVC.swift
//  ArchitectureSampler
//
//  Created by N. M on 2023/08/05.
//

import UIKit

final class MVCRepositoryTablewithDelegateVC: UIViewController {
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
    
    private let api = GitHubAPIwithDelegate()
    
    /// MVCRepositoryTablewithDelegateVCを生成する
    static func generateVC() -> MVCRepositoryTablewithDelegateVC {
        let mvcRepositoryTablewithDelegateVCStoryboard = UIStoryboard(name: String(describing: MVCRepositoryTablewithDelegateVC.self), bundle: nil)
        let mvcRepositoryTablewithDelegateVC = mvcRepositoryTablewithDelegateVCStoryboard.instantiateInitialViewController() as! MVCRepositoryTablewithDelegateVC
        return mvcRepositoryTablewithDelegateVC
    }
    
    private var repositoryModels: [RepositoryModel] = [] // TableViewに表示するリポジトリモデルオブジェクトのリスト
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupDelegate()
    }
}

extension MVCRepositoryTablewithDelegateVC {
    /// MVCRepositoryTableVCが受け持つデリゲートを設定する
    private func setupDelegate() {
        repositoryTableView.delegate = self
        repositoryTableView.dataSource = self
        searchWordTextField.delegate = self
        api.delegate = self
    }
    
    /// 検索ワードを含むリポジトリ名を検索する
    /// - Parameters:
    ///   - searchWord: 検索ワード
    private func reload(searchWord: String) {
        indicator.startAnimating()
        api.fetchRepository(name: searchWord)
    }
}

extension MVCRepositoryTablewithDelegateVC: UITableViewDelegate {
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

extension MVCRepositoryTablewithDelegateVC: UITableViewDataSource {
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

extension MVCRepositoryTablewithDelegateVC: UITextFieldDelegate {
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

extension MVCRepositoryTablewithDelegateVC: GitHubAPIDelegate {
    /// リポジトリ検索結果を保存し、TableViewを更新する
    /// - Parameters:
    ///   - result: 検索結果
    func didFetch(result: Result<[RepositoryModel], NetworkError>) {
        DispatchQueue.main.async {
            switch result {
            case let .success(models):
                // 検索にかかったリポジトリを保存
                self.repositoryModels = models
                // TableViewを更新
                self.repositoryTableView.reloadData()
                
            case let .failure(error):
                // エラー名をアラートで表示
                self.showOneButtonAlert(title: error.message)
            }
            self.indicator.stopAnimating()
        }
    }
}


