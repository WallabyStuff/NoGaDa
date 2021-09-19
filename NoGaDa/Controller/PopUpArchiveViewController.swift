//
//  PopUpArchiveViewController.swift
//  NoGaDa
//
//  Created by 이승기 on 2021/09/17.
//

import UIKit

import RxSwift
import RxCocoa
import RxGesture

class PopUpArchiveViewController: UIViewController {

    // MARK: - Declaraiton
    var disposeBag = DisposeBag()
    var exitButtonAction: () -> Void = {}
    
    @IBOutlet weak var exitButton: UIButton!
    @IBOutlet weak var addFolderButton: UIButton!
    @IBOutlet weak var folderTableView: UITableView!
    
    // MARK: - LifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()

        initView()
        initInstance()
        initEventListener()
    }

    // MARK: - Initialization
    private func initView() {
        // AddFolder Button
        addFolderButton.layer.cornerRadius = 12
        
        // Folder TableView
        folderTableView.layer.cornerRadius = 8
        folderTableView.tableFooterView = UIView()
        
        // Exit Button
        exitButton.makeAsCircle()
    }
    
    private func initInstance() {
        // Folder TableView
        let folderCellNibName = UINib(nibName: "PopUpArchiveFolderTableViewCell", bundle: nil)
        folderTableView.register(folderCellNibName, forCellReuseIdentifier: "popUpArchiveTableCell")
        folderTableView.dataSource = self
        folderTableView.delegate = self
        
    }
    
    private func initEventListener() {
        // AddFolder Button Tap Actiobn
        addFolderButton.rx.tap
            .bind(with: self) { vc, _ in
                vc.presentAddFolderVC()
            }.disposed(by: disposeBag)
        
        // Exit button Tap Action
        exitButton.rx.tap
            .bind(with: self) { vc, _ in
                vc.exitButtonAction()
            }.disposed(by: disposeBag)
    }
    
    // MARK: - Method
    private func presentAddFolderVC() {
        guard let addFolderVC = storyboard?.instantiateViewController(identifier: "addFolderStoryboard") as? AddFolderViewController else { return }
        
        present(addFolderVC, animated: true, completion: nil)
    }
}

// MARK: - Extension
extension PopUpArchiveViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 5
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let folderCell = tableView.dequeueReusableCell(withIdentifier: "popUpArchiveTableCell") as? PopUpArchiveFolderTableViewCell else { return UITableViewCell() }
        
        return folderCell
    }
}
