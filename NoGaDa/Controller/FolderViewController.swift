//
//  FolderViewController.swift
//  NoGaDa
//
//  Created by 이승기 on 2021/09/17.
//

import UIKit

import RxSwift
import RxCocoa
import RxGesture
import Hero

class FolderViewController: UIViewController {

    // MARK: - Declaraiton
    var disposeBag = DisposeBag()
    
    @IBOutlet weak var folderTitleLabel: UILabel!
    @IBOutlet weak var exitButton: UIButton!
    @IBOutlet weak var archivedSongTableView: UITableView!
    
    // MARK: - LifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()

        initView()
        initInstance()
        initEventListener()
    }
    
    // MARK: - Override
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .darkContent
    }

    // MARK: - Initialization
    private func initView() {
        // Exit Button
        exitButton.makeAsCircle()
        
        // Archived Song TableView
        archivedSongTableView.tableFooterView = UIView()
        archivedSongTableView.separatorStyle = .none
        archivedSongTableView.layer.cornerRadius = 12
    }
    
    private func initInstance() {
        // Archived Song TableView
        let songCellNibName = UINib(nibName: "SongTableViewCell", bundle: nil)
        archivedSongTableView.register(songCellNibName, forCellReuseIdentifier: "searchResultTableViewCell")
        archivedSongTableView.dataSource = self
        archivedSongTableView.delegate = self
    }
    
    private func initEventListener() {
        // Exit Button Tap Action
        exitButton.rx.tap
            .bind(with: self) { vc, _ in
                vc.dismiss(animated: true, completion: nil)
            }.disposed(by: disposeBag)
    }
    
    // MARK: - Method
}

// MARK: - Extension
extension FolderViewController: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 10
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let songCell = tableView.dequeueReusableCell(withIdentifier: "searchResultTableViewCell") as? SongTableViewCell else { return UITableViewCell() }
        
        return songCell
    }
    
    
}
