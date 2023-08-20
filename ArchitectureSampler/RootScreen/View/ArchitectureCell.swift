//
//  ArchitectureCell.swift
//  ArchitectureSampler
//
//  Created by N. M on 2023/08/02.
//

import UIKit

final class ArchitectureCell: UITableViewCell {
    static var reuseIdentifier = String(describing: ArchitectureCell.self)
    static var nib: UINib { UINib(nibName: String(describing: ArchitectureCell.reuseIdentifier), bundle: nil) }
    
    @IBOutlet weak private var architectureCellNameLabel: UILabel!
    
    /// セルに表示する文字列を設定する
    /// - Parameters:
    ///   - name: セルに表示する文字列
    func setupUI(name: String) {
        architectureCellNameLabel.text = name
        architectureCellNameLabel.font = UIFont.systemFont(ofSize: 15)
    }
}

