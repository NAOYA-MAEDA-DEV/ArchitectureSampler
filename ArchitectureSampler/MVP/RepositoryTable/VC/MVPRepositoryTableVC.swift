//
//  MVPRepositoryListVC.swift
//  ArchitectureSampler
//
//  Created by N. M on 2023/07/24.
//

import UIKit

class MVPRepositoryTableVC: UIViewController {
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
    
    /// MVPRepositoryTableVCを生成する
    static func generateVC() -> MVPRepositoryTableVC {
        let mvpRepositoryTableVCStoryboard = UIStoryboard(name: String(describing: MVPRepositoryTableVC.self), bundle: nil)
        let mvpRepositoryTableVC = mvpRepositoryTableVCStoryboard.instantiateInitialViewController() as! MVPRepositoryTableVC
        return mvpRepositoryTableVC
    }
    
    private var presenter: RepositoryTablePresenterInput!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupDelegate()
    }
    
    /// MVPRepositoryTableVCに対応するプレゼンターを注入する
    /// - Parameters:
    ///   - presenter: プレゼンター
    func inject(presenter: RepositoryTablePresenterInput) {
        self.presenter = presenter
    }
}

extension MVPRepositoryTableVC {
    /// MVPRepositoryTableVCが受け持つデリゲートを設定する
    func setupDelegate() {
        repositoryTableView.delegate = self
        repositoryTableView.dataSource = self
        searchWordTextField.delegate = self
    }
}

extension MVPRepositoryTableVC: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        presenter.didSelectRowAt(row: indexPath.row)
    }
}

extension MVPRepositoryTableVC: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        presenter.numberOfRepositories
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let repositoryModel = presenter.repository(row: indexPath.row)
        let cell = repositoryTableView.dequeueReusableCell(withIdentifier: RepositoryCell.reuseIdentifier, for: indexPath) as! RepositoryCell
        cell.setupUI(model: repositoryModel)
        return cell
    }
}

extension MVPRepositoryTableVC: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        // キーボードを非表示にする
        textField.resignFirstResponder()
        // テキストフィールド内にキーワードが入力されているかのチェック
        guard let text = searchWordTextField.text, !text.isEmpty else { return true }
        // リポジトリ検索処理の実行
        presenter.search(word: text)
        return true
    }
}

extension MVPRepositoryTableVC: RepositoryTablePresenterOutput {
    /// 引数modelsのリポジトリ情報をTableViewに表示する
    /// - Parameters:
    ///   - model: リポジトリモデルクラスオブジェクト情報
    func update(models: [RepositoryModel]) {
        DispatchQueue.main.async {
            self.repositoryTableView.reloadData()
        }
    }
    
    /// インジケータの表示を制御する
    /// - Parameters:
    ///   - loading: インジケータの表示フラグ
    func update(loading: Bool) {
        DispatchQueue.main.async {
            loading ? self.indicator.startAnimating() : self.indicator.stopAnimating()
        }
    }
    
    /// アラートを表示する
    /// - Parameters:
    ///   - title: アラートに表示するタイトル
    func showAlert(title: String) {
        DispatchQueue.main.async {
            self.showOneButtonAlert(title: title)
        }
    }
    
    /// MVPRepositoryWeb画面へ遷移する
    /// - Parameters:
    ///   - model: MVPRepositoryWeb画面で表示するリポジトリモデルクラスオブジェクト
    func showWRepositoryWebPage(model: RepositoryModel) {
        DispatchQueue.main.async {
            Router.showMVPRepositoryWebPage(from: self, model: model)
        }
    }
}
