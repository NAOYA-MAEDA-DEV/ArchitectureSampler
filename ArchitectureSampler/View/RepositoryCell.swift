//
//  RepositoryCell.swift
//  ArchitectureSampler
//
//  Created by N. M on 2023/07/22.
//

import UIKit

final class RepositoryCell: UITableViewCell {
    static var reuseIdentifier = String(describing: RepositoryCell.self)
    static var nib: UINib { UINib(nibName: String(describing: RepositoryCell.reuseIdentifier), bundle: nil) }
    
    @IBOutlet weak private var ripositoryNameLabel: UILabel!
    @IBOutlet weak private var ripositoryUrlLabel: UILabel!
    
    /// リポジトリ名とURLをセル内のラベルに設定する
    /// - Parameters:
    ///   - model: リポジトリを表現するモデルクラス
    func setupUI(model: RepositoryModel) {
        ripositoryUrlLabel.text = model.repositoryUrl
        ripositoryNameLabel.text = model.repositoryName
        ripositoryNameLabel.font = UIFont.boldSystemFont(ofSize: 15.0)
        ripositoryUrlLabel.font = UIFont.systemFont(ofSize: 10.0)
    }
}
