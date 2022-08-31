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
  
  
  // MARK: - Properties
  
  private var disposeBag = DisposeBag()
  private let searchHistoryManager = SearchHistoryManager()
  
  
  // MARK: - Methods
  
  public func addSearchHistory(_ keyword: String) {
    searchHistoryManager.addData(searchKeyword: keyword)
      .subscribe()
      .disposed(by: disposeBag)
  }
}
