//
//  PopOverSearchFilterViewModel.swift
//  NoGaDa
//
//  Created by 이승기 on 2022/06/11.
//

import Foundation

import RxSwift
import RxCocoa

class PopOverSearchFilterViewModel: ViewModelType {
  
  // MARK: - Properties
  
  struct Input {
    let tapApplyButton = PublishSubject<Void>()
    let updateKaraokeBrand = PublishSubject<KaraokeBrand>()
  }
  
  struct Output {
    let brand = BehaviorRelay(value: KaraokeBrand.tj)
    let searchFilterItems = BehaviorRelay<[SearchFilterItem]>(value: SearchFilterItem.allCases)
    let didTapApplyButton = PublishRelay<Bool>()
    let dismiss = PublishRelay<Void>()
  }
  
  private(set) var input: Input!
  private(set) var output: Output!
  private(set) var disposeBag = DisposeBag()
  
  
  // MARK: - Initializers
  
  init() {
    setupInputOutput()
  }
  
  private func setupInputOutput() {
    let input = Input()
    let output = Output()
    
    input.tapApplyButton
      .subscribe(onNext: {
        output.didTapApplyButton.accept(true)
        output.dismiss.accept(Void())
      })
      .disposed(by: disposeBag)
    
    // TODO: - Need to be implemented
//    input.updateKaraokeBrand
//      .subscribe(onNext: { brand in
//        
//      })
//      .disposed(by: disposeBag)
    
    self.input = input
    self.output = output
  }
}
