//
//  BrandPickerViewModel.swift
//  NoGaDa
//
//  Created by 이승기 on 2022/01/05.
//

import UIKit

class KaraokeBrandPickerViewModel {
    
}

extension KaraokeBrandPickerViewModel {
    var sectionCount: Int {
        return 1
    }
    
    func numberOfRowsInSection(_ section: Int) -> Int {
        return KaraokeBrand.allCases.count
    }
    
    func brandForRowAt(_ indexPath: IndexPath) -> KaraokeBrand {
        return KaraokeBrand.allCases[indexPath.row]
    }
}
