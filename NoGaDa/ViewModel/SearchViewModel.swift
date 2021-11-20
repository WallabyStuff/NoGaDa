//
//  SearchViewModel.swift
//  NoGaDa
//
//  Created by 이승기 on 2021/10/21.
//

import Foundation
import RxSwift
import RxCocoa

class SearchViewModel {
    
    private var disposeBag = DisposeBag()
    private let searchHistoryManager = SearchHistoryManager()
    
    func addSearchHistory(_ keyword: String) {
        searchHistoryManager.addData(searchKeyword: keyword)
            .subscribe()
            .disposed(by: disposeBag)
    }
}
