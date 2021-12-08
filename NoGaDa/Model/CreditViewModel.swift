//
//  CreditViewModel.swift
//  NoGaDa
//
//  Created by 이승기 on 2021/12/08.
//

import UIKit

class CreditViewModel {
    private var developerEmail = "avocado.34.131@gmail.com"
}

extension CreditViewModel {
    var headerText: String {
        return "노가다\n노래방 가서 다 부를거야\n\nVersion \(appVersion)"
    }
}

extension CreditViewModel {
    private var appVersion: String {
        if let appVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String {
            return appVersion
        } else {
            return "-.-.-"
        }
    }
}

extension CreditViewModel {
    var emailRecipients: [String] {
        var emailList = [String]()
        emailList.append(developerEmail)
        
        return emailList
    }
    
    var snedEmailSubject: String {
        return "문의"
    }
    
    var sendEmailErrorMessage: String {
        return "can't send an email because some reason"
    }
}

extension CreditViewModel {
    var sectionCount: Int {
        return 0
    }
    
    func numberOfRowInSection(_ section: Int) -> Int {
        return ResourceItem.allCases.count
    }
    
    func resourceItemAtIndex(_ indexPath: IndexPath) -> ResourceItem {
        return ResourceItem.allCases[indexPath.row]
    }
}
