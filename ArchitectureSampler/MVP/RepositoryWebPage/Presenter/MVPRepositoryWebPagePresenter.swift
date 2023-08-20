//
//  MVPRepositoryWebPagePresenter.swift
//  ArchitectureSampler
//
//  Created by N. M on 2023/07/24.
//

import Foundation

// Viewからの入力に関するプロトコル
protocol RepositoryWebPagePresenterInput {
    func viewDidLoad()
}

// Viewへの出力に関するプロトコル
protocol RepositoryWebPagePresenterOutput: AnyObject {
    func load(request: URL)
    func showAlert(title: String)
}

final class MVPRepositoryWebPagePresenter {
    private weak var output: RepositoryWebPagePresenterOutput! // View
    private var repositoryModel: RepositoryModel!
    
    init(output: RepositoryWebPagePresenterOutput, model: RepositoryModel) {
        self.output = output
        self.repositoryModel = model
    }
}

extension MVPRepositoryWebPagePresenter: RepositoryWebPagePresenterInput {
    /// Viewに対してリポジトリ情報を表示する指示を行う
    func viewDidLoad() {
        // 有効なURLであるかのチェック
        guard let url = URL(string: repositoryModel.repositoryUrl) else {
            output.showAlert(title: NetworkError.invalid.message)
            return
        }
        output.load(request: url)
    }
}
