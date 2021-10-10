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
    
    func presentAdMob(vc: UIViewController) {
        if let interstitial = interstitial {
            interstitial.present(fromRootViewController: vc)
        } else {
            print("Log Ad wasn't ready")
        }
    }
}
