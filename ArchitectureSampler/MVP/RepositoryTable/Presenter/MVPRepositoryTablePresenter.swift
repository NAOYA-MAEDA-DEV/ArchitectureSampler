//
//  MVPRepositoryTablePresenter.swift
//  ArchitectureSampler
//
//  Created by N. M on 2023/07/24.
//

// Viewからの入力に関するプロトコル
protocol RepositoryTablePresenterInput {
    var numberOfRepositories: Int { get }
    func repository(row: Int) -> RepositoryModel
    func didSelectRowAt(row: Int)
    func search(word: String)
}

// Viewへの出力に関するプロトコル
protocol RepositoryTablePresenterOutput: AnyObject {
    func update(models: [RepositoryModel])
    func update(loading: Bool)
    func showAlert(title: String)
    func showWRepositoryWebPage(model: RepositoryModel)
}

final class MVPRepositoryTablePresenter {
    private weak var output: RepositoryTablePresenterOutput! // View
    private var api: GitHubAPIProtocol // リポジトリ検索用API
    private var models: [RepositoryModel] // リポジトリ検索処理で取得したリポジトリモデルオブジェクトのリスト
    
    init(output: RepositoryTablePresenterOutput!, api: GitHubAPIProtocol) {
        self.output = output
        self.api = api
        self.models = []
    }
}

extension MVPRepositoryTablePresenter: RepositoryTablePresenterInput {
    /// 保持しているリポジトリモデルオブジェクト数を返す
    var numberOfRepositories: Int { models.count }
    
    /// 引数のインデックス情報に対応するリポジトリモデルオブジェクトを返す
    /// - Parameters:
    ///   - indexPath: インデックス情報
    func repository(row: Int) -> RepositoryModel { models[row] }
    
    /// 引数のインデックス情報に対応するリポジトリモデルオブジェクト情報を表示する画面への遷移指示を行う
    /// - Parameters:
    ///   - row: インデックス情報
    func didSelectRowAt(row: Int) {
        // 端末のネットワーク接続状況のチェック
        guard NetworkMonitoringAPI.shared.isOnline else {
            output.showAlert(title: NetworkError.network.message)
            return
        }
        // 遷移指示
        output.showWRepositoryWebPage(model: models[row])
    }
    
    /// 検索ワードを含むリポジトリ名を検索してView更新指示を行う
    /// - Parameters:
    ///   - word: 検索ワード
    func search(word: String) {
        // 端末のネットワーク接続状況のチェック
        guard NetworkMonitoringAPI.shared.isOnline else {
            output.showAlert(title: NetworkError.network.message)
            return
        }
        // インジケータを表示
        output.update(loading: true)
        // 検索処理を実行
        api.fetchRepository(name: word) { [weak self] result in
            guard let _self = self else { return }
            switch result {
            case let .success(models):
                // 検索にかかったリポジトリを保存
                _self.models = models
                // 取得したリポジトリ情報を元にViewの更新を指示
                _self.output.update(models: models)
            
            case let .failure(error):
                // リポジトリ取得に失敗したことをアラートで通知
                _self.output.showAlert(title: error.message)
            }
            // インジケータを非表示
            _self.output.update(loading: false)
        }
    }
}
