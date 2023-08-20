//
//  MVCRepositoryTablewithNotificationVC.swift
//  ArchitectureSampler
//
//  Created by N. M on 2023/08/05.
//

import UIKit

final class MVCRepositoryTablewithNotificationVC: UIViewController {
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
    
    private let api = GitHubAPIwithNotification()
    
    /// MVCRepositoryTablewithNotificationVCを生成する
    static func generateVC() -> MVCRepositoryTablewithNotificationVC {
        let mvcRepositoryTablewithNotificationVCStoryboard = UIStoryboard(name: String(describing: MVCRepositoryTablewithNotificationVC.self), bundle: nil)
        let mvcRepositoryTablewithNotificationVC = mvcRepositoryTablewithNotificationVCStoryboard.instantiateInitialViewController() as! MVCRepositoryTablewithNotificationVC
        return mvcRepositoryTablewithNotificationVC
    }
    
    private var repositoryModels: [RepositoryModel] = [] // TableViewに表示するリポジトリモデルオブジェクトのリスト
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupDelegate()
        setupNotification()
    }
}

extension MVCRepositoryTablewithNotificationVC {
    /// MVCRepositoryTablewithNotificationVCが受け持つデリゲートを設定する
    private func setupDelegate() {
        repositoryTableView.delegate = self
        repositoryTableView.dataSource = self
        searchWordTextField.delegate = self
    }
    
    /// GitHubAPIwithNotificationオブジェクトが保持しているRepositoryModelオブジェクトリストを監視する
    private func setupNotification() {
        api.notificationCenter.addObserver(forName: .init(rawValue: GitHubAPIwithNotification.postName),
                                             object: nil,
                                             queue: nil) { [weak self] notification in
            if let result = notification.userInfo?[GitHubAPIwithNotification.infoKey] as? Result<[RepositoryModel], NetworkError> {
                guard let _self = self else { return }
                DispatchQueue.main.async {
                    switch result {
                    case let .success(models):
                        // 検索にかかったリポジトリを保存
                        _self.repositoryModels = models
                        // TableViewを更新
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
    
    /// 検索ワードを含むリポジトリ名を検索する
    /// - Parameters:
    ///   - searchWord: 検索ワード
    private func reload(searchWord: String) {
        indicator.startAnimating()
        api.fetchRepository(name: searchWord)
    }
}

extension MVCRepositoryTablewithNotificationVC: UITableViewDelegate {
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

extension MVCRepositoryTablewithNotificationVC: UITableViewDataSource {
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

extension MVCRepositoryTablewithNotificationVC: UITextFieldDelegate {
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
