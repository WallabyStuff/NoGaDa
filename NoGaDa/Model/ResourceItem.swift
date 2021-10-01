//
//  IconResourceItem.swift
//  NoGaDa
//
//  Created by 이승기 on 2021/09/29.
//

import UIKit

enum ResourceItem: CaseIterable {
    case folder
    case information
    case archiveIllustration
    
    var description: String {
        switch self {
        case .folder:
            return "Flaticon.com"
        case .information:
            return "Flaticon.com"
        case .archiveIllustration:
            return "Vecteezy.com"
        }
    }
    
    var image: UIImage {
        switch self {
        case .folder:
            return UIImage(named: "folder")!
        case .information:
            return UIImage(named: "information.fill")!
        case .archiveIllustration:
            return UIImage(named: "ArchiveShortcutBackgroundImage")!
        }
    }
    
    var link: String {
        switch self {
        case .folder:
            return "https://www.flaticon.com/free-icon/folder_891094?term=folder&page=1&position=35&page=1&position=35&related_id=891094&origin=search"
        case .information:
            return "https://www.flaticon.com/free-icon/information-button_1176?term=information&page=1&position=3&page=1&position=3&related_id=1176&origin=search"
        case .archiveIllustration:
            return "https://www.vecteezy.com/vector-art/217562-women-of-color-singer"
        }
    }
    
    func openLink(vc: UIViewController) {
        switch self {
        case .folder:
            if let url = URL(string: self.link) {
                UIApplication.shared.open(url, options: [:])
            }
        case .information:
            if let url = URL(string: self.link) {
                UIApplication.shared.open(url, options: [:])
            }
        case .archiveIllustration:
            if let url = URL(string: self.link) {
                UIApplication.shared.open(url, options: [:])
            }
        }
    }
}
