//
//  BaseViewController.swift
//  NoGaDa
//
//  Created by 이승기 on 2022/06/11.
//

import UIKit

import RxSwift
import RxCocoa
import AppTrackingTransparency

class BaseViewController: UIViewController {
  
  
  // MARK: - Properties
  
  var disposeBag = DisposeBag()
  let compactAppBarHeight: CGFloat = AppBarHeight.compactAppBarHeight
  let regularAppBarHeight: CGFloat = AppBarHeight.regularAppBarHeight
  
  
  // MARK: - StatusBarStyle
  
  override var preferredStatusBarStyle: UIStatusBarStyle {
    return .lightContent
  }
  
  
  // MARK: - Methods
  
  func requestTrackingAuthorization() {
    if #available(iOS 14, *) {
      ATTrackingManager.requestTrackingAuthorization { _ in }
    }
  }
}
