//
//  ArchitectureTableVC.swift
//  ArchitectureSampler
//
//  Created by N. M on 2023/08/02.
//

import UIKit

class ArchitectureTableVC: UIViewController {
    @IBOutlet weak private var architectureTableView: UITableView! {
        didSet {
            architectureTableView.register(ArchitectureCell.nib, forCellReuseIdentifier: ArchitectureCell.reuseIdentifier)
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupDelegate()
    }
}

extension ArchitectureTableVC {
    /// ArchitectureTableVCが受け持つデリゲートを設定する
    private func setupDelegate() {
        architectureTableView.delegate = self
        architectureTableView.dataSource = self
    }
}

extension ArchitectureTableVC: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        ArchitecturePattern.allCases[indexPath.item].segue(from: self)
        architectureTableView.deselectRow(at: indexPath, animated: true)
    }
}

extension ArchitectureTableVC: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        ArchitecturePattern.allCases.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let architecturePattern = ArchitecturePattern.allCases[indexPath.item]
        let cell = architectureTableView.dequeueReusableCell(withIdentifier: ArchitectureCell.reuseIdentifier, for: indexPath) as! ArchitectureCell
        cell.setupUI(name: architecturePattern.name)
        return cell
    }
}
