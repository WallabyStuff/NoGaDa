//
//  ViewModel.swift
//  NoGaDa
//
//  Created by 이승기 on 2021/10/18.
//

import Foundation

import RxSwift
import RxCocoa

class MainViewModel: ViewModelType {
    
    
    // MARK: - Properties
    
    struct Input {
        let viewDidLoad: Observable<Void>
        let viewDidAppear: Observable<Bool>
        let tapSearchBar: Observable<Void>
        let tapArchiveFolderView: Observable<Void>
        let tapSettingButton: Observable<Void>
        let tapNewUpdateSongItem: Observable<IndexPath>
        let changeSelectedKaraokeBrand: Observable<KaraokeBrand>
    }
    
    struct Output {
        let newUpdateSongs = BehaviorRelay<[Song]>(value: [])
        let selectedKaraokeBrand = BehaviorRelay<KaraokeBrand>(value: .tj)
        let isLoadingNewUpdateSongs = BehaviorRelay<Bool>(value: true)
        let newUpdateSongsErrorState = PublishRelay<String>()
        let amountOfSavedSongs = PublishRelay<String>()
        let showSearchVC = PublishRelay<Bool>()
        let showArchiveFolderVC = PublishRelay<Bool>()
        let showSettingVC = PublishRelay<Bool>()
        let showArchiveFolderFloadingView = PublishRelay<Song>()
    }
    
    var disposeBag = DisposeBag()
    private let karaokeManager = KaraokeApiManager()
    private let songFolderManager = SongFolderManager()
    
    
    // MARK: - Transform
    
    func transform(input: Input) -> Output {
        let output = Output()
        
        Observable.merge(
            input.viewDidAppear.map { _ in },
            input.changeSelectedKaraokeBrand
                .map { brand in
                    output.selectedKaraokeBrand.accept(brand)
                    print(brand)
                }.asObservable()
        ).map { _ in
                output.newUpdateSongs.accept([])
                output.isLoadingNewUpdateSongs.accept(true)
            }
            .flatMap({ [weak self] () -> Observable<[Song]> in
                guard let self = self else { return .never() }
                let selectedBrand = output.selectedKaraokeBrand.value
                return self.karaokeManager.fetchUpdatedSong(brand: selectedBrand)
            })
            .subscribe(on: ConcurrentDispatchQueueScheduler.init(qos: .background))
            .observe(on: MainScheduler.instance)
            .subscribe(with: self, onNext: { strongSelf, songs  in
                if songs.isEmpty {
                    output.newUpdateSongsErrorState.accept("업데이트 된 곡이 없습니다.")
                } else {
                    output.newUpdateSongsErrorState.accept("")
                    output.newUpdateSongs.accept(songs)
                }

                output.isLoadingNewUpdateSongs.accept(false)
            }, onError: { strongSelf, error in
                output.newUpdateSongsErrorState.accept("오류가 발생했습니다.")
                output.isLoadingNewUpdateSongs.accept(false)
            })
            .disposed(by: disposeBag)
        
        input.viewDidAppear
            .subscribe(onNext: { [weak self] _ in
                let amount = self?.songFolderManager.getAmountOfSongs() ?? 0
                let text = "총 \(amount)곡"
                output.amountOfSavedSongs.accept(text)
            })
            .disposed(by: disposeBag)
        
        input.tapSearchBar
            .subscribe(onNext: {
                output.showSearchVC.accept(true)
            })
            .disposed(by: disposeBag)
        
        input.tapArchiveFolderView
            .subscribe(onNext: {
                output.showArchiveFolderVC.accept(true)
            })
            .disposed(by: disposeBag)
        
        input.tapSettingButton
            .subscribe(onNext: {
                output.showSettingVC.accept(true)
            })
            .disposed(by: disposeBag)
        
        input.tapNewUpdateSongItem
            .subscribe(onNext: { indexPath in
                let selectedSong = output.newUpdateSongs.value[indexPath.row]
                output.showArchiveFolderFloadingView.accept(selectedSong)
            })
            .disposed(by: disposeBag)
        
        return output
    }
}
