//
//  SearchHistoryViewModel.swift
//  NoGaDa
//
//  Created by 이승기 on 2021/10/21.
//

import Foundation

import RxSwift
import RxCocoa

class SearchHistoryViewModel {
    
    private var disposeBag = DisposeBag()
    private let searchHistoryManager = SearchHistoryManager()
    
    public var searchHistories = BehaviorRelay<[SearchHistory]>(value: [])
    public var didHistoryItemSelect = PublishRelay<SearchHistory>()
}

extension SearchHistoryViewModel {
    public func fetchSearchHistory() {
        searchHistories.accept([])
        
        searchHistoryManager.fetchData()
            .subscribe(with: self, onSuccess: { strongSelf, histories in
                strongSelf.searchHistories.accept(histories)
            }, onFailure: { strongSelf, error in
                print(error.localizedDescription)
            }).disposed(by: disposeBag)
    }
    
    public func deleteHistory(_ index: Int) {
        var histories = searchHistories.value
        let selectedItem = histories.remove(at: index)
        
        searchHistoryManager.deleteData(selectedItem)
            .subscribe(with: self, onCompleted: { strongSelf in
                strongSelf.searchHistories.accept(histories)
            }, onError: { strongSelf, error in
                print(error.localizedDescription)
            })
            .disposed(by: self.disposeBag)
    }
    
    public func deleteAllHistories() {
        self.searchHistoryManager.deleteAll()
            .subscribe(with: self, onCompleted: { strongSelf in
                strongSelf.searchHistories.accept([])
            }, onError: { strongSelf, error in
                print(error.localizedDescription)
            }).disposed(by: self.disposeBag)
    }
}

extension SearchHistoryViewModel {
    public func historyItemSelectAction(_ indexPath: IndexPath) {
        let selectedItem = searchHistories.value[indexPath.row]
        didHistoryItemSelect.accept(selectedItem)
    }
}
