//
//  SearchViewController.swift
//  NoGaDa
//
//  Created by 이승기 on 2021/09/17.
//

import UIKit

import RxSwift
import RxCocoa
import RxGesture
import FloatingPanel
import Hero

class SearchViewController: UIViewController {

    // MARK: - Declaraiton
    var disposeBag = DisposeBag()
    let archiveFloatingPanel = FloatingPanelController()
    
    @IBOutlet weak var exitButton: UIButton!
    @IBOutlet weak var brandSelector: UISegmentedControl!
    @IBOutlet weak var searchTextField: UITextField!
    @IBOutlet weak var searchButton: UIButton!
    @IBOutlet weak var searchResultTableView: UITableView!
    
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
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        view.endEditing(true)
    }

    // MARK: - Initialization
    private func initView() {
        self.hero.isEnabled = true
        
        // Search TextField
        searchTextField.hero.id = "searchBar"
        searchTextField.layer.cornerRadius = 12
        searchTextField.setPlaceholderColor(ColorSet.searchBarPlaceholderColor)
        searchTextField.setLeftPadding(width: 12)
        searchTextField.setRightPadding(width: 52)
        searchTextField.layer.shadowColor = ColorSet.searchbarShadowColor.cgColor
        searchTextField.layer.shadowOffset = .zero
        searchTextField.layer.shadowRadius = 20
        searchTextField.layer.shadowOpacity = 1
        
        // Search Button
        searchButton.hero.id = "searchButton"
        searchButton.layer.cornerRadius = 8
        
        // Brand Selector SegmentedControl
        brandSelector.setTextColor(color: ColorSet.segmentedControlTextColor)
        
        // Exit Button
        exitButton.makeAsCircle()
        
        // SearchResult TableView
        searchResultTableView.tableFooterView = UIView()
        searchResultTableView.separatorStyle = .none
        searchResultTableView.layer.cornerRadius = 12
        
    }
    
    private func initInstance() {
        // SearchResult TableView
        let searchResultCellNibName = UINib(nibName: "SongTableViewCell", bundle: nil)
        searchResultTableView.register(searchResultCellNibName, forCellReuseIdentifier: "searchResultTableViewCell")
        searchResultTableView.dataSource = self
        searchResultTableView.delegate = self
    }
    
    private func initEventListener() {
        // Exit Button Tap Action
        exitButton.rx.tap
            .bind(with: self) { vc, _ in
                vc.dismiss(animated: true, completion: nil)
            }.disposed(by: disposeBag)
        
        // Search Button Tap Action
        searchButton.rx.tap
            .bind(with: self) { vc, _ in
                vc.dismissKeyboardAndArchivePanel()
            }.disposed(by: disposeBag)
        
        // Search TextField Tap Action
        searchTextField.rx.tapGesture()
            .when(.recognized)
            .bind(with: self) { vc, _ in
                vc.archiveFloatingPanel.hide(animated: true)
            }.disposed(by: disposeBag)
        
        // Brand Segmented Control Action
        brandSelector.rx.selectedSegmentIndex
            .bind(with: self) { vc, index in
                // TODO - replace table cells according to brand catalog
            }.disposed(by: disposeBag)
    }
    
    // MARK: - Method
    private func configurePopUpArchivePanel() {
        let appearance = SurfaceAppearance()
        appearance.cornerRadius = 32
        appearance.setPanelShadow(color: ColorSet.floatingPanelShadowColor)
        
        archiveFloatingPanel.removeFromParent()
        archiveFloatingPanel.isRemovalInteractionEnabled = true
        archiveFloatingPanel.contentMode = .fitToBounds
        archiveFloatingPanel.surfaceView.appearance = appearance
        archiveFloatingPanel.surfaceView.grabberHandle.barColor = ColorSet.accentSubColor
        archiveFloatingPanel.layout = PopUpArchiveFloatingPanelLayout()
        
        guard let popUpArchiveVC = storyboard?.instantiateViewController(identifier: "popUpArchiveStoryboard") as? PopUpArchiveViewController else { return }
        popUpArchiveVC.exitButtonAction = { [weak self] in
            self?.archiveFloatingPanel.hide(animated: true)
        }
        archiveFloatingPanel.set(contentViewController: popUpArchiveVC)
        archiveFloatingPanel.addPanel(toParent: self)
    }
    
    private func showPopUpArchivePanel() {
        configurePopUpArchivePanel()
        archiveFloatingPanel.show(animated: true, completion: nil)
        archiveFloatingPanel.move(to: .half, animated: true)
    }
    
    private func dismissKeyboardAndArchivePanel() {
        view.endEditing(true)
        archiveFloatingPanel.hide(animated: true)
    }
    
}

// MARK: - Extension
extension SearchViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 5
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let searchResultCell = tableView.dequeueReusableCell(withIdentifier: "searchResultTableViewCell") as? SongTableViewCell else { return UITableViewCell() }
        
        return searchResultCell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        view.endEditing(true)
        showPopUpArchivePanel()
    }
}

extension SearchViewController: UIScrollViewDelegate {
    
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        dismissKeyboardAndArchivePanel()
    }
}
