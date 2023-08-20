//
//  MVVMRepositoryListVM.swift
//  ArchitectureSampler
//
//  Created by N. M on 2023/08/02.
//

import RxSwift
import RxRelay

// Viewからの入力を要素とするObservableを定義したプロトコル
protocol RepositoryTableVMInput {
    var searchWordTextFieldObservable: Observable<String?> { get } // TextFieldに入力された文字列を要素とするObservable
    var didSelectObservable: Observable<Int> { get } // タップしたTableViewの行数を要素とするObservable
}

// Viewへの出力を要素とするObservableを定義したプロトコル
protocol RepositoryTableVMOutput: AnyObject {
    var loadingObservable: Observable<Bool> { get } // 処理中か否かを表すBool値を要素とするObservable
    var errorMessageObservable: Observable<String> { get } // リポジトリ検索エラー名を表す文字列を要素とするObservable
    var updateRepositoryModelsObservable: Observable<[RepositoryModel]> { get } // 保持しているリポジトリモデルの配列を要素とするObservable
    var selectRepositoryModelObservable: Observable<RepositoryModel> { get } // 選択中のリポジトリモデルを要素とするObservable
}

final class MVVMRepositoryTableVM: RepositoryTableVMOutput {
    private let loading: PublishRelay<Bool> = .init()
    lazy var loadingObservable: Observable<Bool> = loading.asObservable()
    
    private let errorMessage: PublishRelay<String> = .init()
    lazy var errorMessageObservable: Observable<String> = errorMessage.asObservable()
    
    private let updateRepositoryModels: BehaviorRelay<[RepositoryModel]> = .init(value: [])
    lazy var updateRepositoryModelsObservable: Observable<[RepositoryModel]> = updateRepositoryModels.asObservable()
    
    private let selectRepositoryModel: PublishRelay<RepositoryModel> = .init()
    lazy var selectRepositoryModelObservable: Observable<RepositoryModel> = selectRepositoryModel.asObservable()
    
    private let disposeBag = DisposeBag()
  
    private(set) var repositoryModels: [RepositoryModel] // 取得したリポジトリモデルのリスト
    
    init(input: RepositoryTableVMInput, api: GitHubAPIProtocol = GitHubAPI.shared) {
        repositoryModels = []
        
        // TableViewをタップした時に発行される要素を使用して選択中のリポジトリモデルを更新
        input.didSelectObservable
            .filter { $0 < self.repositoryModels.count - 1 }
            .map { self.repositoryModels[$0] }
            .bind(to: selectRepositoryModel)
            .disposed(by: disposeBag)
        
        // TextFieldに入力された文字列を要素とするObservable
        let searchWordTextFieldObservable = input.searchWordTextFieldObservable
            .flatMap {
                if let str = $0 {
                    return Observable.just(str)
                } else {
                    return Observable.empty()
                }
            }
            .filter { $0!.count > 0 }
            .distinctUntilChanged()
        
        // TextFieldへの入力が完了した後はリポジトリ検索処理を行うため処理中フラグを立てる
        searchWordTextFieldObservable
            .map { _ in true}
            .bind(to: loading)
            .disposed(by: disposeBag)
        
        // TextFieldへの入力が完了した後はリポジトリ検索処理を実行
        searchWordTextFieldObservable
            .flatMapLatest{ name -> Observable<[RepositoryModel]> in
                GitHubAPI.shared.rx.fetchRepository(name: name)
                    .catch { [weak self] error in
                        // 検索失敗時のエラー処理
                        if let _error = error as? NetworkError {
                            self?.errorMessage.accept(_error.message)
                        }
                        self?.loading.accept(false)
                        return Observable.empty()
                    }
                
            }
            .subscribe(onNext: { [weak self] repositoryModels in
                // リポジトリモデル配列を更新
                self?.repositoryModels = repositoryModels
                self?.updateRepositoryModels.accept(repositoryModels)
                // 処理中フラグを下げる
                self?.loading.accept(false)
            })
            .disposed(by: disposeBag)
    }
}

