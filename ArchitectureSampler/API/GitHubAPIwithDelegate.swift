//
//  GitHubAPIDelegate.swift
//  ArchitectureSampler
//
//  Created by N. M on 2023/08/05.
//

import Foundation

/// リポジトリ検索完了後に呼び出すデリゲートメソッドを定義したプロトコル
protocol GitHubAPIDelegate: AnyObject {
    func didFetch(result: Result<[RepositoryModel], NetworkError>)
}

protocol GitHubAPIwithDelegateProtocol {
    func fetchRepository(name: String)
}

/// リポジトリ検索APIを保持しているモデルクラス
final class GitHubAPIwithDelegate: GitHubAPIwithDelegateProtocol {
    private let baseUrl = "https://api.github.com/search/repositories?q="
    weak var delegate: GitHubAPIDelegate? = nil

    /// 引数nameの文字列を含むリポジトリを検索し、検索実行結果をデリゲートメソッドで通知する
    /// - Parameters:
    ///   - name: 検索するリポジトリ名
    func fetchRepository(name: String) {
        guard let _delegate = delegate else { fatalError("Could not find delegate instance.") }
        // 端末のネットワーク接続状況のチェック
        guard NetworkMonitoringAPI.shared.isOnline else {
            _delegate.didFetch(result: .failure(.network))
            return
        }
        // 有効なURLであるかのチェック
        let urlString = baseUrl + name
        guard let url = URL(string: urlString) else {
            _delegate.didFetch(result: .failure(.invalid))
            return
        }
        // 有効なレスポンスデータが返ってきたかのチェック
        let task = URLSession.shared.dataTask(with: url) { [weak self] data, _, _ in
            guard let _data = data,
                  let response = try? JSONDecoder().decode(Repositories.self, from: _data),
                  let models = response.items
            else {
                fatalError("Illegal Error")
            }
            self?.delegate?.didFetch(result: .success(models))
        }
        // リポジトリの検索を実行
        task.resume()
    }
}

