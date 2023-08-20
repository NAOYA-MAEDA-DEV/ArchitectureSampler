//
//  RepositoryModel.swift
//  ArchitectureSampler
//
//  Created by N. M on 2023/07/22.
//

import Foundation

struct Repositories: Codable {
  let items: [RepositoryModel]?
}

// リポジトリを表現するモデルクラス
struct RepositoryModel: Codable {
    var repositoryName: String // リポジトリ名
    var repositoryUrl: String // リポジトリのURL
    
    enum CodingKeys: String, CodingKey {
        case repositoryName = "full_name"
        case repositoryUrl = "html_url"
    }
}
