//
//  GitHubAPIwithNotification.swift
//  ArchitectureSampler
//
//  Created by N. M on 2023/08/05.
//

import Foundation

protocol GitHubAPIwithNotificationProtocol {
    func fetchRepository(name: String)
}

/// リポジトリ検索APIを保持しているモデルクラス
final class GitHubAPIwithNotification: GitHubAPIwithNotificationProtocol {
    static let postName = "repositorModels"
    static let infoKey = "repositries"
    
    private let baseUrl = "https://api.github.com/search/repositories?q="
    let notificationCenter: NotificationCenter = NotificationCenter()
    
    private var repositoryModels: [RepositoryModel] = [] { // リポジトリ検索処理で取得したリポジトリモデルオブジェクトのリスト
        didSet {
            // リポジトリモデルオブジェクトのリストが更新された時はオブザーバに通知する
            notificationCenter.post(name: .init(rawValue: GitHubAPIwithNotification.postName),
                                    object: nil,
                                    userInfo: [GitHubAPIwithNotification.infoKey: Result<[RepositoryModel], NetworkError>.success(repositoryModels)])
        }
    }

    /// 引数nameの文字列を含むリポジトリを検索し、検索実行結果を保存する
    /// - Parameters:
    ///   - name: 検索するリポジトリ名
    func fetchRepository(name: String) {
        // 端末のネットワーク接続状況のチェック
        guard NetworkMonitoringAPI.shared.isOnline else {
            notificationCenter.post(name: .init(rawValue: GitHubAPIwithNotification.postName),
                                    object: nil,
                                    userInfo: [GitHubAPIwithNotification.infoKey: Result<[RepositoryModel], NetworkError>.failure(NetworkError.network)])
            return
        }
        // 有効なURLであるかのチェック
        let urlString = baseUrl + name
        guard let url = URL(string: urlString) else {
            notificationCenter.post(name: .init(rawValue: GitHubAPIwithNotification.postName),
                                    object: nil,
                                    userInfo: [GitHubAPIwithNotification.infoKey: Result<[RepositoryModel], NetworkError>.failure(NetworkError.invalid)])
            return
        }
        // 有効なレスポンスデータが返ってきたかのチェック
        let task = URLSession.shared.dataTask(with: url) { [weak self] data, _, _ in
            guard let _data = data,
                  let response = try? JSONDecoder().decode(Repositories.self, from: _data),
                  let models = response.items,
                  let _self = self
            else {
                fatalError("Illegal Error")
            }
            _self.repositoryModels = models
        }
        // リポジトリの検索を実行
        task.resume()
    }
}

