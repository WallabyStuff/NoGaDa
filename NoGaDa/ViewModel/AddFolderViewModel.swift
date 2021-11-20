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
    private let songfolderManager = SongFolderManager()
}

extension AddFolderViewModel {
    func addFolder(_ title: String, _ titleEmoji: String) -> Completable {
        return Completable.create { [weak self] completable in
            guard let self = self else { return Disposables.create() }
            
            self.songfolderManager.addData(title: title, titleEmoji: titleEmoji)
                .subscribe(onCompleted: {
                    completable(.completed)
                }, onError: { error in
                    completable(.error(error))
                }).disposed(by: self.disposeBag)
            
            return Disposables.create()
        }
    }
}
