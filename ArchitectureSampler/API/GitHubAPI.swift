//
//  GitHubAPI.swift
//  ArchitectureSampler
//
//  Created by N. M on 2023/07/22.
//

import Foundation

protocol GitHubAPIProtocol {
    func fetchRepository(name: String, completion: @escaping (Result<[RepositoryModel], NetworkError>) -> Void)
}

/// リポジトリ検索APIを保持しているシングルトンクラス
final class GitHubAPI: GitHubAPIProtocol {
    static let shared = GitHubAPI()
    private init() {}    
    private let baseUrl = "https://api.github.com/search/repositories?q="
    
    /// 引数nameの文字列を含むリポジトリを検索し、検索実行結果を引数completionクロージャに渡して実行する
    /// - Parameters:
    ///   - name: 検索するリポジトリ名
    ///   - completion: 検索完了後に実行するクロージャ
    func fetchRepository(name: String, completion: @escaping (Result<[RepositoryModel], NetworkError>) -> Void) {
        // 端末のネットワーク接続状況のチェック
        guard NetworkMonitoringAPI.shared.isOnline else {
            completion(.failure(.network))
            return
        }
        // 有効なURLであるかのチェック
        let urlString = baseUrl + name
        guard let url = URL(string: urlString) else {
            completion(.failure(.invalid))
            return
        }
        // 有効なレスポンスデータが返ってきたかのチェック
        let task = URLSession.shared.dataTask(with: url) { data, _, _ in
            guard let _data = data,
                  let response = try? JSONDecoder().decode(Repositories.self, from: _data),
                  let models = response.items
            else {
                completion(.failure(.parse))
                return
            }
            completion(.success(models))
        }
        // リポジトリの検索を実行
        task.resume()
    }
}
