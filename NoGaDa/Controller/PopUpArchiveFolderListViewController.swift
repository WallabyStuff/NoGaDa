//
//  PopUpArchiveViewController.swift
//  NoGaDa
//
//  Created by 이승기 on 2021/09/17.
//

import UIKit

import FloatingPanel
import RxSwift
import RxCocoa
import RxGesture

@objc protocol PopUpArchiveFolderViewDelegate: AnyObject {
    @objc optional func didSongAdded()
}

class PopUpArchiveFolderListViewController: UIViewController {

    // MARK: - Declaraiton
    @IBOutlet weak var exitButton: UIButton!
    @IBOutlet weak var addFolderButton: UIButton!
    @IBOutlet weak var archiveFolderTableView: UITableView!
    
    weak var delegate: PopUpArchiveFolderViewDelegate?
    public var viewModel: PopUpArchiveFolderListViewModel?
    private var disposeBag = DisposeBag()
    public var exitButtonAction: () -> Void = {}
    private let admobManager = AdMobManager()
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()

        setupData()
        setupView()
        bind()
        setArchiveFolders()
    }

    // MARK: - Initializers
    private func setupData() {
        setupViewModel()
    }
    
    private func setupView() {
        setupAddFolderButton()
        setupArchiveFolderTableView()
        setupExitButton()
        setupAddFolderButton()
    }
    
    private func bind() {
        bindAddFolderButton()
        bindExitButton()
        bindArchiveFolderTableView()
    }
    
    // MARK: - Setups
    private func setupViewModel() {
        if viewModel == nil {
            dismiss(animated: true, completion: nil)
            return
        }
    }
    
    private func setupAddFolderButton() {
        addFolderButton.layer.cornerRadius = 12
        addFolderButton.layer.shadowColor = UIColor.gray.cgColor
        addFolderButton.layer.shadowOffset = CGSize(width: 0, height: 4)
        addFolderButton.layer.shadowRadius = 4
        addFolderButton.layer.shadowOpacity = 0.1
    }
    
    private func setupArchiveFolderTableView() {
        archiveFolderTableView.layer.cornerRadius = 8
        archiveFolderTableView.tableFooterView = UIView()
        archiveFolderTableView.separatorInset = UIEdgeInsets(top: 0, left: 44, bottom: 0, right: 0)
        
        let nibName = UINib(nibName: "PopUpArchiveFolderTableViewCell", bundle: nil)
        archiveFolderTableView.register(nibName, forCellReuseIdentifier: "popUpArchiveTableCell")
        archiveFolderTableView.dataSource = self
        archiveFolderTableView.delegate = self
    }
    
    private func setupExitButton() {
        exitButton.makeAsCircle()
    }
    
    // MARK: - Binds
    private func bindAddFolderButton() {
        addFolderButton.rx.tap
            .asDriver()
            .drive(with: self) { vc, _ in
                vc.presentAddFolderVC()
            }.disposed(by: disposeBag)
    }
    
    private func bindExitButton() {
        exitButton.rx.tap
            .asDriver()
            .drive(with: self) { vc, _ in
                vc.exitButtonAction()
            }.disposed(by: disposeBag)
    }
    
    private func bindArchiveFolderTableView() {
        archiveFolderTableView.rx.itemSelected
            .asDriver()
            .drive(with: self, onNext: { vc, indexPath in
                vc.viewModel?.presentAddSongAlert(viewController: self, indexPath: indexPath)
                    .subscribe(with: vc, onCompleted: { vc in
                        vc.admobManager.presentAdMob(vc: vc)
                        vc.delegate?.didSongAdded?()
                    })
                    .disposed(by: vc.disposeBag)
            }).disposed(by: disposeBag)
    }
    
    // MARK: - Methods
    private func setArchiveFolders() {
        viewModel?.fetchSongFolder()
            .observe(on: MainScheduler.instance)
            .subscribe(onCompleted: { [weak self] in
                self?.archiveFolderTableView.reloadData()
            }).disposed(by: disposeBag)
    }
    
    private func presentAddFolderVC() {
        let storyboard = UIStoryboard(name: "Folder", bundle: nil)
        guard let addFolderVC = storyboard.instantiateViewController(identifier: "addFolderStoryboard") as? AddFolderViewController else {
            return
        }
        
        addFolderVC.delegate = self
        present(addFolderVC, animated: true, completion: nil)
    }
    
    private func reloadArchiveFolderTableView() {
        viewModel?.fetchSongFolder()
            .subscribe(onCompleted: { [weak self] in
                self?.archiveFolderTableView.reloadData()
            }).disposed(by: disposeBag)
    }
}

// MARK: - Extensions
extension PopUpArchiveFolderListViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel!.numberOfRowsInSection(viewModel!.sectionCount)
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let folderCell = tableView.dequeueReusableCell(withIdentifier: "popUpArchiveTableCell") as? PopUpArchiveFolderTableViewCell,
              let songFolderVM = viewModel?.songFolderAtIndex(indexPath) else {
              return UITableViewCell()
          }
        
        folderCell.titleLabel.text = songFolderVM.title
        folderCell.emojiLabel.text = songFolderVM.titleEmoji
        
        return folderCell
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            viewModel?.presentRemoveFolderAlert(viewController: self, indexPath: indexPath)
                .subscribe(onCompleted: { [weak self] in
                    self?.reloadArchiveFolderTableView()
                })
                .disposed(by: disposeBag)
        }
    }
}

extension PopUpArchiveFolderListViewController: AddFolderViewDelegate {
    func didFolderAdded() {
        reloadArchiveFolderTableView()
    }
}
