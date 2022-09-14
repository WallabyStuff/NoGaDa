//
//  SettingViewModel.swift
//  NoGaDa
//
//  Created by 이승기 on 2022/09/14.
//

import Foundation
import RxSwift
import RxCocoa

class SettingViewModel: ViewModelType {
  
  
  // MARK: - Properties
  
  struct Input {
    let tapExitButton = PublishRelay<Void>()
  }
  
  struct Output {
    let settingItems = BehaviorRelay<[SettingItem]>(value: SettingItem.allCases)
    let dismiss = PublishRelay<Void>()
  }
  
  private(set) var input: Input!
  private(set) var output: Output!
  private(set) var disposeBag = DisposeBag()
  
  
  // MARK: - Initializers
  
  init() {
    setupIntoutOutput()
  }
  
  
  // MARK: - Setups
  
  private func setupIntoutOutput() {
    self.input = Input()
    let output = Output()
    
    input.tapExitButton
      .subscribe(onNext: {
        output.dismiss.accept(Void())
      })
      .disposed(by: disposeBag)
    
    self.output = output
  }
}
