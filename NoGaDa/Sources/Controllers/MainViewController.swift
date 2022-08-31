//
//  ViewController.swift
//  NoGaDa
//
//  Created by 이승기 on 2021/09/17.
//

import UIKit

import RxCocoa
import RxSwift
import RxGesture

class MainViewController: BaseViewController, ViewModelInjectable {
  
  
  // MARK: Properties
  
  typealias ViewModel = MainViewModel
  static let identifier = R.storyboard.main.mainStoryboard.identifier
  
  @IBOutlet weak var appbarView: AppbarView!
  @IBOutlet weak var appbarViewHeightConstraint: NSLayoutConstraint!
  @IBOutlet weak var appbarTitleLabel: UILabel!
  @IBOutlet weak var settingButton: UIButton!
  @IBOutlet weak var mainContentScrollView: UIScrollView!
  @IBOutlet weak var mainContentScrollViewContentViewHeightConstraint: NSLayoutConstraint!
  @IBOutlet weak var archiveShortcutView: ArchiveFolderShortcutView!
  @IBOutlet weak var archiveShortcutBackgroundImageView: UIImageView!
  @IBOutlet weak var totalArchivedSongSizeLabel: UILabel!
  @IBOutlet weak var searchBoxView: UIView!
  @IBOutlet weak var searchButton: UIButton!
  @IBOutlet weak var brandSegmentedControl: BISegmentedControl!
  @IBOutlet weak var newUpdateSongTableView: UITableView!
  @IBOutlet weak var newUpdateSongErrorMessageLabel: UILabel!
  @IBOutlet weak var newUpdateSongLoadingIndicator: UIActivityIndicatorView!
  
  var viewModel: ViewModel
  private var archiveFolderFloatingView: ArchiveFolderFloatingPanelView?
  
  
  // MARK: - Initializers
  
  required init(_ viewModel: ViewModel) {
    self.viewModel = viewModel
    super.init(nibName: nil, bundle: nil)
    dismiss(animated: true)
  }
  
  required init?(_ coder: NSCoder, _ viewModel: ViewModel) {
    self.viewModel = viewModel
    super.init(coder: coder)
  }
  
  required init?(coder: NSCoder) {
    fatalError("ViewModel has not been implemented")
  }
  
  
  // MARK: - Lifecycle
  
  override func viewDidLoad() {
    super.viewDidLoad()
    setup()
    bind()
  }
  
  override func viewDidAppear(_ animated: Bool) {
    super.viewDidAppear(animated)
    requestTrackingAuthorization()
    
    // Update constraints
    appbarView.setNeedsLayout()
  }
  
  
  // MARK: - Constraints
  
  override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
    super.traitCollectionDidChange(previousTraitCollection)
    newUpdateSongTableView.reloadData()
  }
  
  
  // MARK: - Setups
  
  private func setup() {
    setupView()
  }
  
  private func setupView() {
    setupStatusBar()
    setupAppbarView()
    setupAppbarTitleLabel()
    setupSettingButton()
    setupMainContentScrollView()
    setupSearchTextField()
    setupSearchButton()
    setupArchiveShortcutBackgroundImageView()
    setupNewUpdateSongTableView()
    setupBrandSegmentedControl()
  }
  
  private func setupStatusBar() {
    view.fillStatusBar(color: R.color.accentColor()!)
  }
  
  private func setupAppbarView() {
    appbarView.backgroundColor = .clear
    appbarView.configure(cornerRadius: 28, roundCorners: [.bottomRight])
    appbarView.setAppbarShadow()
    appbarViewHeightConstraint.constant = regularAppbarHeight
    mainContentScrollView.contentInset = UIEdgeInsets(top: regularAppbarHeight,
                                                      left: 0, bottom: 0, right: 0)
    mainContentScrollView.scrollToTop(animated: true)
  }
  
  private func setupAppbarTitleLabel() {
    appbarTitleLabel.hero.id = "appbarTitle"
  }
  
  private func setupSettingButton() {
    settingButton.setPadding(width: 4)
  }
  
  private func setupMainContentScrollView() {
    mainContentScrollViewContentViewHeightConstraint.constant = view.frame.height
  }
  
  private func setupSearchTextField() {
    searchBoxView.layer.cornerRadius = 12
    searchBoxView.setSearchBoxShadow()
  }
  
  private func setupSearchButton() {
    searchButton.layer.cornerRadius = 8
    searchButton.setSearchBoxButtonShadow()
  }
  
  private func setupArchiveShortcutBackgroundImageView() {
    archiveShortcutBackgroundImageView.layer.cornerRadius = 20
    archiveShortcutBackgroundImageView.layer.maskedCorners = [.layerMinXMaxYCorner]
  }
  
  private func setupNewUpdateSongTableView() {
    registerNewUpdateSongTableView()
    newUpdateSongTableView.layer.cornerRadius = 12
    newUpdateSongTableView.tableFooterView = UIView()
    newUpdateSongTableView.separatorStyle = .none
  }
  
  private func registerNewUpdateSongTableView() {
    let nibName = UINib(nibName: R.nib.updatedSongTableViewCell.name, bundle: nil)
    newUpdateSongTableView.register(nibName, forCellReuseIdentifier: UpdatedSongTableViewCell.identifier)
  }
  
  private func setupBrandSegmentedControl() {
    brandSegmentedControl.segmentTintColor = R.color.updatedSongSelectorSelectedTextColor()!
    brandSegmentedControl.segmentDefaultColor = R.color.updatedSongSelectorUnSelectedTextColor()!
    brandSegmentedControl.barIndicatorColor = R.color.updatedSongSelectorBarIndicatorColor()!
    brandSegmentedControl.barIndicatorHeight = 3
    brandSegmentedControl.segmentFontSize = 14
    brandSegmentedControl.addSegment(title: "tj 업데이트")
    brandSegmentedControl.addSegment(title: "금영 업데이트")
    brandSegmentedControl.setSelected(index: 0)
  }
  
  
  // MARK: - Bindss
  
  private func bind() {
    bindInputs()
    bindOutputs()
    bindMainContentScrollView()
  }
  
  private func bindInputs() {
    Observable.just(Void())
      .bind(to: viewModel.input.viewDidLoad)
      .disposed(by: disposeBag)
    
    self.rx.viewDidAppear
      .bind(to: viewModel.input.viewDidAppear)
      .disposed(by: disposeBag)
    
    Observable.merge(
      searchBoxView.rx.tapGesture().when(.recognized)
        .map { _ in return },
      searchBoxView.rx.longPressGesture().when(.began)
        .map { _ in return },
      searchButton.rx.tap.asObservable()
        .map { _ in return }
    )
    .bind(to: viewModel.input.tapSearchBar)
    .disposed(by: disposeBag)
    
    archiveShortcutView
      .rx.tapGesture()
      .when(.recognized)
      .map { _ in return }
      .bind(to: viewModel.input.tapArchiveFolderView)
      .disposed(by: disposeBag)
    
    settingButton
      .rx.tap
      .map { _ in return }
      .asObservable()
      .bind(to: viewModel.input.tapSettingButton)
      .disposed(by: disposeBag)
    
    newUpdateSongTableView
      .rx.itemSelected
      .bind(to: viewModel.input.tapNewUpdateSongItem)
      .disposed(by: disposeBag)
    
    brandSegmentedControl
      .rx.itemSelected
      .map { index -> KaraokeBrand in
        switch index {
        case 0:
          return KaraokeBrand.tj
        case 1:
          return KaraokeBrand.kumyoung
        default:
          return KaraokeBrand.tj
        }
      }
      .distinctUntilChanged()
      .bind(to: viewModel.input.changeSelectedKaraokeBrand)
      .disposed(by: disposeBag)
  }
  
  private func bindOutputs() {
    viewModel.output.showSearchVC
      .asDriver(onErrorDriveWith: .never())
      .drive(onNext: { [weak self] isShowing in
        if isShowing {
          self?.presentSearchVC()
        }
      })
      .disposed(by: disposeBag)
    
    #if DEBUG
    #else
    viewModel.output
      .showInitialAd
      .asDriver(onErrorDriveWith: .never())
      .drive(with: self, onNext: { vc, _  in
        AdMobManager.shared.presentAd(vc: vc)
      })
      .disposed(by: disposeBag)
    #endif
    
    viewModel.output.showArchiveFolderVC
      .asDriver(onErrorDriveWith: .never())
      .drive(onNext: { [weak self] isShowing in
        if isShowing {
          self?.presentArchiveFolderVC()
        }
      })
      .disposed(by: disposeBag)
    
    viewModel.output.showSettingVC
      .asDriver(onErrorDriveWith: .never())
      .drive(onNext: { [weak self] isShowing in
        if isShowing {
          self?.presentSettingVC()
        }
      })
      .disposed(by: disposeBag)
    
    viewModel.output.newUpdateSongs
      .bind(to: newUpdateSongTableView.rx.items(cellIdentifier: UpdatedSongTableViewCell.identifier, cellType: UpdatedSongTableViewCell.self)) { index, song, cell in
        cell.songTitleLabel.text = song.title
        cell.songNumberLabel.text = song.no
        cell.singerLabel.text = song.singer
      }
      .disposed(by: disposeBag)
    
    viewModel.output.isLoadingNewUpdateSongs
      .asDriver()
      .drive(with: self, onNext: { vc, isLoading in
        if isLoading {
          vc.newUpdateSongLoadingIndicator.isHidden = false
          vc.newUpdateSongLoadingIndicator.startAnimating()
        } else {
          vc.newUpdateSongLoadingIndicator.isHidden = true
          vc.newUpdateSongLoadingIndicator.stopAnimating()
        }
      })
      .disposed(by: disposeBag)
    
    viewModel.output.newUpdateSongsErrorState
      .asDriver(onErrorDriveWith: .never())
      .drive(with: self, onNext: { vc, message in
        if message.isEmpty {
          vc.newUpdateSongErrorMessageLabel.isHidden = true
        } else {
          vc.newUpdateSongErrorMessageLabel.isHidden = false
          vc.newUpdateSongErrorMessageLabel.text = message
        }
      })
      .disposed(by: disposeBag)
    
    viewModel.output.amountOfSavedSongs
      .asDriver(onErrorDriveWith: .never())
      .drive(onNext: { [weak self] amount in
        self?.totalArchivedSongSizeLabel.text = amount
      })
      .disposed(by: disposeBag)
    
    viewModel.output.showArchiveFolderFloadingView
      .asDriver(onErrorDriveWith: .never())
      .drive(onNext: { [weak self] song in
        self?.showArchiveFolderFloatingView(song)
      })
      .disposed(by: disposeBag)
  }
  
  private func bindMainContentScrollView() {
    mainContentScrollView.rx.contentOffset
      .asDriver()
      .drive(with: self, onNext: { vc, offset in
        let compactAppbarHeight = vc.compactAppbarHeight
        let regularAppbarHeight = vc.regularAppbarHeight
        let changedY = offset.y + regularAppbarHeight
        
        if -regularAppbarHeight < offset.y {
          // Shrink Appbar
          if regularAppbarHeight - changedY >= compactAppbarHeight {
            let modifiedAppbarHeight: CGFloat = regularAppbarHeight - changedY
            vc.appbarViewHeightConstraint.constant = modifiedAppbarHeight
            
            let appbarTitleLabelAlpha: CGFloat = 1 - (regularAppbarHeight - modifiedAppbarHeight) / (regularAppbarHeight - compactAppbarHeight)
            vc.appbarTitleLabel.alpha = appbarTitleLabelAlpha
            vc.settingButton.alpha = appbarTitleLabelAlpha
          } else {
            vc.appbarViewHeightConstraint.constant = compactAppbarHeight
            vc.appbarTitleLabel.alpha = 0
            vc.settingButton.alpha = 0
          }
        } else {
          // Stretch Appbar
          vc.appbarViewHeightConstraint.constant = regularAppbarHeight - changedY * 0.2
          vc.appbarTitleLabel.alpha = 1
          vc.settingButton.alpha = 1
        }
      }).disposed(by: disposeBag)
  }
  
  
  // MARK: - Methods
  
  func presentSearchVC() {
    let storyboard = UIStoryboard(name: R.storyboard.search.name, bundle: nil)
    let searchVC = storyboard.instantiateViewController(identifier: SearchViewController.identifier) { coder -> SearchViewController in
      let viewModel = SearchViewModel()
      return .init(coder, viewModel) ?? SearchViewController(.init())
    }
    
    HapticFeedbackManager.playImpactFeedback(.light)
    searchVC.modalPresentationStyle = .fullScreen
    present(searchVC, animated: true)
  }
  
  func presentArchiveFolderVC() {
    let storyboard = UIStoryboard(name: R.storyboard.archive.name, bundle: nil)
    let archiveVC = storyboard.instantiateViewController(identifier: ArchiveFolderViewController.identifier) { coder -> ArchiveFolderViewController in
      let viewModel = ArchiveFolderViewModel()
      return .init(coder, viewModel) ?? ArchiveFolderViewController(viewModel)
    }
    
    archiveVC.delegate = self
    archiveVC.modalPresentationStyle = .fullScreen
    present(archiveVC, animated: true, completion: nil)
  }
  
  func presentSettingVC() {
    let storyboard = UIStoryboard(name: R.storyboard.setting.name, bundle: nil)
    guard let settingVC = storyboard.instantiateViewController(withIdentifier: SettingViewController.identifier) as? SettingViewController else {
      return
    }
    
    present(settingVC, animated: true, completion: nil)
  }
  
  private func showArchiveFolderFloatingView(_ selectedSong: Song) {
    archiveFolderFloatingView?.hide(animated: false)
    archiveFolderFloatingView = ArchiveFolderFloatingPanelView(parentViewController: self, delegate: self)
    archiveFolderFloatingView?.show(selectedSong)
  }
}


// MARK: - Extensions

extension MainViewController: PopUpArchiveFolderViewDelegate {
  func didSongAdded() {
    archiveFolderFloatingView?.hide(animated: true)
    Observable.just(Void())
      .bind(to: viewModel.input.didSongAdded)
      .dispose()
  }
}

extension MainViewController: ArchiveFolderListViewDelegate {
  func didFileChanged() {
    Observable.just(Void())
      .bind(to: viewModel.input.didFileChanged)
      .dispose()
  }
}
