//
//  AdMobManager.swift
//  NoGaDa
//
//  Created by 이승기 on 2021/10/07.
//

import UIKit

import GoogleMobileAds
import RxSwift
import RxCocoa

enum AdMobUnitID {
  static let testInterstitial = "ca-app-pub-3940256099942544/4411468910"
  static let initialAd = "ca-app-pub-3998172297943713/4233053278"
}

class AdMobManager {
  
  
  // MARK: - Properties
  
  static let shared = AdMobManager()
  private var interstitial: GADInterstitialAd?
  public var presentFrequency = 1
  
  
  // MARK: - Initializers
  
  private init() { }
  
  
  // MARK: - Methods
  
  public func presentAd(vc: UIViewController) -> Completable {
    configureAdMob()
    
    return Completable.create { observer in
      let request = GADRequest()
      GADInterstitialAd.load(withAdUnitID: AdMobUnitID.initialAd,
                             request: request) { ad, error in
        if let error = error {
          observer(.error(error))
        } else {
          ad?.present(fromRootViewController: vc)
        }
      }
      
      return Disposables.create()
    }
  }
  
  public func configureAdMob() {
    let request = GADRequest()
    GADInterstitialAd.load(withAdUnitID: AdMobUnitID.initialAd,
                           request: request) { [weak self] ad, error in
      guard let self = self else { return }
      
      if let error = error {
        print(error)
        return
      }
      
      self.interstitial = ad
    }
  }
}


// MARK: - Admob frequency

extension AdMobManager {
  private func admobUsageState() -> Bool {
    let currentUsageCount = UserDefaults.standard.integer(forKey: "admobUsageCount")
    
    if currentUsageCount % presentFrequency == 0 {
      return true
    } else {
      return false
    }
  }
  
  private func updateAdmobUsageCount() {
    let currentUsageState = UserDefaults.standard.integer(forKey: "admobUsageCount")
    UserDefaults.standard.set(currentUsageState + 1, forKey: "admobUsageCount")
  }
}
