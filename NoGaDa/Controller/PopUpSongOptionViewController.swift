//
//  PopUpSongOptionViewController.swift
//  NoGaDa
//
//  Created by 이승기 on 2021/12/14.
//

import UIKit
import RxSwift
import RxCocoa

@objc protocol PopUpSongOptionViewDelegate: AnyObject {
    @objc optional func didSelectedSongRemoved()
    @objc optional func didSelectedItemMoved()
}

class PopUpSongOptionViewController: UIViewController {

    // MARK: - Declaration
    @IBOutlet weak var songThumbnailImageView: UIImageView!
    @IBOutlet weak var exitButton: UIButton!
    @IBOutlet weak var songTitleLabel: UILabel!
    @IBOutlet weak var singerLabel: UILabel!
    @IBOutlet weak var optionTableView: UITableView!
    
    weak var delegate: PopUpSongOptionViewDelegate?
    public var viewModel: PopUpSongOptionViewModel?
    private var disposeBag = DisposeBag()
    public var exitButtonAction: () -> Void = {}
    private var archiveFolderFloatingPanelView: ArchiveFolderFloatingPanelView?
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()

        setupData()
        setupView()
        bind()
    }
    
    // MARK: - Initializers
    private func setupData() {
        setupViewModel()
    }
    
    private func setupView() {
        setupExitButton()
        setupSongThumbnailImageView()
        setupSongTitleLabel()
        setupSingerLabel()
        setupOptionTableView()
        setupArchiveFolderFloatingPanelView()
    }
    
    private func bind() {
        bindExitButton()
        bindOptionTableView()
    }
    
    // MARK: - Setups
    private func setupViewModel() {
        if viewModel == nil {
            dismiss(animated: true, completion: nil)
            return
        }
    }
    
    private func setupExitButton() {
        exitButton.makeAsCircle()
    }
    
    private func setupSongThumbnailImageView() {
        songThumbnailImageView.layer.cornerRadius = 12
    }
    
    private func setupSongTitleLabel() {
        songTitleLabel.text = viewModel?.selectedSong?.title
    }
    
    private func setupSingerLabel() {
        singerLabel.text = viewModel?.selectedSong?.singer
    }
    
    private func setupOptionTableView() {
        optionTableView.separatorStyle = .none
        optionTableView.tableFooterView = UIView()
        
        let nibName = UINib(nibName: "PopUpSongOptionTableViewCell", bundle: nil)
        optionTableView.register(nibName, forCellReuseIdentifier: "popUpSongOptionTableCell")
        optionTableView.dataSource = self
        optionTableView.delegate = self
    }
    
    private func setupArchiveFolderFloatingPanelView() {
        archiveFolderFloatingPanelView = ArchiveFolderFloatingPanelView(parentViewController: viewModel?.parentViewController ?? self, delegate: self)
    }
    
    // MARK: - Binds
    private func bindExitButton() {
        exitButton.rx.tap
            .asDriver()
            .drive(with: self, onNext: { vc, _ in
                vc.exitButtonAction()
            }).disposed(by: disposeBag)
    }
    
    private func bindOptionTableView() {
        optionTableView.rx.itemSelected
            .asDriver()
            .drive(with: self, onNext: { vc, indexPath in
                if indexPath.row == 0 {
                    guard let selectedSong = vc.viewModel?.selectedSong?.asSongType() else { return }
                    vc.archiveFolderFloatingPanelView?.show(selectedSong)
                } else {
                    vc.presentRemoveAlert()
                }
            }).disposed(by: disposeBag)
    }
    
    // MARK: - Methods
    private func presentArchiveFolderVC(_ selectedSong: Song) {
        guard let archiveFolderVC = storyboard?.instantiateViewController(withIdentifier: "popUpArchiveStoryboard") as? PopUpArchiveFolderListViewController else {
            return
        }
        
        let viewModel = PopUpArchiveFolderListViewModel(selectedSong: selectedSong)
        archiveFolderVC.viewModel = viewModel
        archiveFolderVC.delegate = self
        
        present(archiveFolderVC, animated: true, completion: nil)
    }
    
    private func presentRemoveAlert() {
        let removeAlert = UIAlertController(title: "삭제", message: "정말 「\(viewModel!.selectedSong!.title)」 를 삭제하시겠습니까?", preferredStyle: .alert)
        
        let confirmAction = UIAlertAction(title: "확인", style: .default) { [weak self] action in
            self?.deletedSelectedSong()
        }
        
        let cancelAction = UIAlertAction(title: "취소", style: .destructive, handler: nil)
        
        removeAlert.addAction(confirmAction)
        removeAlert.addAction(cancelAction)
        
        present(removeAlert, animated: true)
    }
    
    private func deletedSelectedSong() {
        viewModel!.deleteSong()
            .subscribe(with: self, onCompleted: { vc in
                vc.archiveFolderFloatingPanelView?.hide(animated: true)
                vc.delegate?.didSelectedItemMoved?()
            }).disposed(by: disposeBag)
    }
}

// MARK: - Extensions
extension PopUpSongOptionViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel!.numberOfRowsInSection(viewModel!.sectionCount)
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let optionCell = tableView.dequeueReusableCell(withIdentifier: "popUpSongOptionTableCell", for: indexPath) as? PopUpSongOptionTableViewCell else { return UITableViewCell() }
        
        let optionModel = viewModel!.optionAtIndex(indexPath)
        optionCell.titleLabel.text = optionModel.title
        optionCell.iconImageView.image = optionModel.icon
        
        return optionCell
    }
}

extension PopUpSongOptionViewController: PopUpArchiveFolderViewDelegate {
    func didSongAdded() {
        archiveFolderFloatingPanelView?.hide(animated: true)
        archiveFolderFloatingPanelView = nil
        
        deletedSelectedSong()
    }
}
