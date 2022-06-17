//
//  SearchHistoryViewController.swift
//  NoGaDa
//
//  Created by 이승기 on 2021/10/09.
//

import UIKit

import RxSwift
import RxCocoa

protocol SearchHistoryViewDelegate: AnyObject {
    func didCallEndEditing()
    func didHSelectistoryItem(_ keyword: String)
}

class SearchHistoryViewController: BaseViewController, ViewModelInjectable {
    
    
    // MARK: - Properties
    
    typealias ViewModel = SearchHistoryViewModel
    static let idnetifier = R.storyboard.search.searchHistoryStoryboard.identifier
    
    @IBOutlet weak var searchHistoryTableView: UITableView!
    @IBOutlet weak var searchHistoryTableViewPlaceholderLabel: UILabel!
    @IBOutlet weak var clearHistoryButton: UIButton!
    
    weak var delegate: SearchHistoryViewDelegate?
    var viewModel: ViewModel
    private let searchHistoryViewModel = SearchHistoryViewModel()
    
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
        bind()
    }
    
    
    // MARK: - Initializers
    
    required init(_ viewModel: SearchHistoryViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(_ coder: NSCoder, _ viewModel: SearchHistoryViewModel) {
        self.viewModel = viewModel
        super.init(coder: coder)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    

    // MARK: - Setups
    
    private func setup() {
        setupView()
        setupData()
    }
    
    private func setupView() {
        setupSearchHistoryTableView()
    }
    
    private func setupData() {
        viewModel.fetchSearchHistory()
    }
    
    private func setupSearchHistoryTableView() {
        registerSearchHistoryTableView()
        searchHistoryTableView.separatorStyle = .none
        searchHistoryTableView.tableFooterView = UIView()
        searchHistoryTableView.rx.setDelegate(self)
            .disposed(by: disposeBag)
    }
    
    private func registerSearchHistoryTableView() {
        let nibName = UINib(nibName: R.nib.searchHistoryTableViewCell.name, bundle: nil)
        searchHistoryTableView.register(nibName, forCellReuseIdentifier: SearchHistoryTableViewCell.identifier)
    }
    
    
    // MARK: - Binds
    
    private func bind() {
        bindSearchHistoryTableView()
        bindSearchHistoryTableCell()
        bindClearHistoryButton()
    }

    private func bindSearchHistoryTableView() {
        viewModel.searchHistories
            .bind(to: searchHistoryTableView.rx.items(cellIdentifier: SearchHistoryTableViewCell.identifier,
                                                      cellType: SearchHistoryTableViewCell.self)) { [weak self] index, item, cell in
                guard let self = self else { return }
                
                cell.titleLabel.text = item.keyword
                cell.removeButtonTapAction = { [weak self] in
                    self?.viewModel.deleteHistory(index)
                }
            }.disposed(by: disposeBag)
    }
    
    private func bindSearchHistoryTableCell() {
        searchHistoryTableView.rx.itemSelected
            .subscribe(with: self, onNext: { vc, indexPath in
                vc.viewModel.historyItemSelectAction(indexPath)
            })
            .disposed(by: disposeBag)
        
        viewModel.didHistoryItemSelect
            .subscribe(with: self, onNext: { vc, item in
                vc.delegate?.didHSelectistoryItem(item.keyword)
            })
            .disposed(by: disposeBag)
    }
    
    private func bindClearHistoryButton() {
        clearHistoryButton.rx.tap
            .asDriver()
            .drive(with: self, onNext: { vc, _ in
                vc.viewModel.deleteAllHistories()
            }).disposed(by: disposeBag)
    }
}


// MARK: - Extensions

extension SearchHistoryViewController: UITableViewDelegate {
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        delegate?.didCallEndEditing()
    }
}
