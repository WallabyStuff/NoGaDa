//
//  PopOvserSearchFilterViewModel.swift
//  NoGaDa
//
//  Created by 이승기 on 2022/06/11.
//

import Foundation

import RxSwift
import RxCocoa

class PopOverSearchFilterViewModel {
    
    
    // MARK: - Properties
    
    public var searchFilterItem = BehaviorRelay<[SearchFilterItem]>(value: SearchFilterItem.allCases)
}
