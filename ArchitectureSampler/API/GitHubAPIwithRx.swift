//
//  GitHubAPIwithRx.swift
//  ArchitectureSampler
//
//  Created by N. M on 2023/08/02.
//

import Foundation
import RxCocoa
import RxSwift

extension GitHubAPI: ReactiveCompatible {}
extension Reactive where Base: GitHubAPI {
    /// 引数nameの文字列を含むリポジトリを検索し、検索実行結果を引数completionクロージャに渡して実行する
    /// - Parameters:
    ///   - name: 検索するリポジトリ名
    ///   - completion: 検索完了後に実行するクロージャ
    func fetchRepository(name: String) -> Observable<[RepositoryModel]> {
        return Observable.create { observer in
            // 検索処理を実行
            GitHubAPI.shared.fetchRepository(name: name) { result in
                switch result {
                case let .success(models):
                    observer.onNext(models)
                
                case let .failure(error):
                    observer.onError(error)
                }
            }
            return Disposables.create()
        }.share(replay: 1)
    }
}
