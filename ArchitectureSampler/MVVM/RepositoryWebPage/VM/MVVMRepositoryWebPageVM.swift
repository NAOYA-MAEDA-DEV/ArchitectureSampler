//
//  MVVMRepositoryWebPageVM.swift
//  ArchitectureSampler
//
//  Created by N. M on 2023/08/06.
//

import Foundation
import RxSwift
import RxRelay

// Viewからの入力を要素とするObservableを定義したプロトコル
protocol RepositoryWebPageInput {
    var viewDidLoadObservable: Observable<Void> { get } // VCでviewDidLoad発火時に殻要素が発生するObservable
}

// Viewへの出力を要素とするObservableを定義したプロトコル
protocol RepositoryWebPageOutput {
    var loadObservable: Observable<URLRequest> { get } // URLRequestを要素とするObservable
}

final class MVVMRepositoryWebPageVM: RepositoryWebPageOutput {
    
    private let _loadObservable: PublishRelay<URLRequest> = .init()
    lazy var loadObservable: Observable<URLRequest> = _loadObservable.asObservable()
    
    var diposeBag = DisposeBag()
    
    init(input: RepositoryWebPageInput, model: RepositoryModel) {
        input.viewDidLoadObservable
            .map { _ in model }
            .map { model -> URLRequest? in
                guard let url = URL(string: model.repositoryUrl) else { return nil }
                return URLRequest(url: url)
              }
            .flatMap {
                if let request = $0 {
                    return Observable.just(request)
                } else {
                    return Observable.empty()
                }
            }
            .bind(to: _loadObservable)
            .disposed(by: diposeBag)
    }
}

