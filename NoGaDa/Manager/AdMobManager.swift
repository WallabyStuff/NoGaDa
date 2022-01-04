//
//  AdMobManager.swift
//  NoGaDa
//
//  Created by 이승기 on 2021/10/07.
//

import UIKit
import GoogleMobileAds

enum AdMobUnitID {
    static let testInterstitial = "ca-app-pub-3940256099942544/4411468910"
    static let afterSaveSong = "ca-app-pub-3998172297943713/4233053278"
}

class AdMobManager {
    private var interstitial: GADInterstitialAd?
    public var presentFrequency = 2
    
    init() {
        configureAdMob()
    }
    
    private func configureAdMob() {
        let request = GADRequest()
        GADInterstitialAd.load(withAdUnitID: AdMobUnitID.afterSaveSong,
                               request: request) { [weak self] ad, error in
            guard let self = self else { return }
            
            if let error = error {
                print(error)
                return
            }
            
            self.interstitial = ad
        }
    }
    
    public func presentAdMob(vc: UIViewController) {
        guard let interstitial = interstitial else {
            print("Log ad is not loaded")
            return
        }
        
        if !admobUsageState() {
            print("admob present now")
            interstitial.present(fromRootViewController: vc)
            configureAdMob()
        }
        
        updateAdmobUsageCount()
    }
    
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
