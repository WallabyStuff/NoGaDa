//
//  EtcSettingItem.swift
//  NoGaDa
//
//  Created by 이승기 on 2021/09/29.
//

import UIKit
import MessageUI

enum SettingItem: CaseIterable {
  case credit
  case bugReport
}

extension SettingItem {
  var title: String {
    switch self {
    case .credit:
      return "크레딧"
    case .bugReport:
      return "버그 리포트"
    }
  }
}

extension SettingItem {
  var icon: UIImage {
    switch self {
    case .credit:
      return R.image.informationFill()!
    case .bugReport:
      return R.image.email()!
    }
  }
}

extension SettingItem
{
  var iconContainerColor: UIColor {
    switch self {
    case .credit:
      return R.color.accentBlue()!
    case .bugReport:
      return R.color.accentOrange()!
    }
  }
}

extension SettingItem {
  func action(vc: UIViewController) {
    switch self {
    case .credit:
      let storyboard = UIStoryboard(name: "Setting", bundle: Bundle.main)
      let creditVC = storyboard.instantiateViewController(identifier: "creditStoryboard") { coder -> CreditViewController in
        let viewModel = CreditViewModel()
        return .init(coder, viewModel) ?? CreditViewController(viewModel)
      }
      
      vc.present(creditVC, animated: true, completion: nil)
    case .bugReport:
      if MFMailComposeViewController.canSendMail() {
        let composeVC = MFMailComposeViewController()
        
        composeVC.setToRecipients(["avocado.34.131@gmail.com"])
        composeVC.setSubject("노가다앱 버그 및 피드백 리포트")
        composeVC.setMessageBody("", isHTML: false)
        
        vc.present(composeVC, animated: true, completion: nil)
      } else {
        print("can't send an email because some reason")
      }
    }
  }
}
