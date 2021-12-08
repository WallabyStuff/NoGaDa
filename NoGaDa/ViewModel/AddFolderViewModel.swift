//
//  AddFolderViewModel.swift
//  NoGaDa
//
//  Created by 이승기 on 2021/10/21.
//

import Foundation
import RxSwift
import RxCocoa

class AddFolderViewModel {
    
    private var disposeBag = DisposeBag()
    private let songFolderManager = SongFolderManager()
}

extension AddFolderViewModel {
    func addFolder(_ title: String, _ titleEmoji: String) -> Completable {
        return Completable.create { [weak self] observer in
            guard let self = self else { return Disposables.create() }
            
            self.songFolderManager.addData(title: title, titleEmoji: titleEmoji)
                .subscribe(onCompleted: {
                    observer(.completed)
                }, onError: { error in
                    observer(.error(error))
                }).disposed(by: self.disposeBag)
            
            return Disposables.create()
        }
    }
}
