//
//  KaraokeManager.swift
//  NoGaDa
//
//  Created by 이승기 on 2021/09/20.
//

import UIKit

import RxSwift
import RxCocoa

class KaraokeManager {
    
    var disposeBag = DisposeBag()
    
    func fetchUpdatedSong(brand: KaraokeBrand) -> Observable<[Song]> {
        
        return Observable.create { observable in
            let fullPath = "\(KaraokeAPIPath.basePath.rawValue)\(brand.rawValue)".urlEncode()
            
            guard let url = URL(string: fullPath) else {
                observable.onError(KaraokeAPIErrMessage.urlParsingError)
                return Disposables.create()
            }
            
            var request         = URLRequest(url: url)
            request.httpMethod  = "GET"
            
            URLSession.shared.dataTask(with: request) { jsonData, response, error in
                guard let jsonData = jsonData else {
                    observable.onError(KaraokeAPIErrMessage.didNotReceiveData)
                    return
                }
                
                guard let response = response as? HTTPURLResponse, (200 ..< 300) ~= response.statusCode else {
                    observable.onError(KaraokeAPIErrMessage.httpRequestFailure)
                    return
                }
                
                guard let updatedSongList = try? JSONDecoder().decode([Song].self, from: jsonData) else {
                    observable.onError(KaraokeAPIErrMessage.jsonParsingError)
                    return
                }
                
                observable.onNext(updatedSongList)
                observable.onCompleted()
            }.resume()
            
            return Disposables.create()
        }
    }
    
    func fetchSong(title: String, brand: KaraokeBrand) -> Observable<[Song]> {
        
        return Observable.create { observable in
            let fullPath = "\(KaraokeAPIPath.basePath.rawValue)\(KaraokeAPIPath.song.rawValue)/\(title)\(brand.rawValue)".urlEncode()
            
            guard let url = URL(string: fullPath) else {
                observable.onError(KaraokeAPIErrMessage.urlParsingError)
                return Disposables.create()
            }
            
            var request         = URLRequest(url: url)
            request.httpMethod  = "GET"
            
            URLSession.shared.dataTask(with: request) { jsonData, response, error in
                guard let jsonData = jsonData else {
                    observable.onError(KaraokeAPIErrMessage.didNotReceiveData)
                    return
                }
                
                guard let response = response as? HTTPURLResponse, (200 ..< 300) ~= response.statusCode else {
                    observable.onError(KaraokeAPIErrMessage.httpRequestFailure)
                    return
                }
                
                guard let searchResultSongList = try? JSONDecoder().decode([Song].self, from: jsonData) else {
                    observable.onError(KaraokeAPIErrMessage.jsonParsingError)
                    return
                }
                
                observable.onNext(searchResultSongList)
            }.resume()
            
            return Disposables.create()
        }
    }
    
    func fetchSong(singer: String, brand: KaraokeBrand) -> Observable<[Song]> {
        
        return Observable.create { observable in
            let fullPath = "\(KaraokeAPIPath.basePath.rawValue)\(KaraokeAPIPath.singer.rawValue)/\(singer)\(brand.rawValue)".urlEncode()
            
            guard let url = URL(string: fullPath) else {
                observable.onError(KaraokeAPIErrMessage.urlParsingError)
                return Disposables.create()
            }
            
            var request         = URLRequest(url: url)
            request.httpMethod  = "GET"
            
            URLSession.shared.dataTask(with: request) { jsonData, response, error in
                guard let jsonData = jsonData else {
                    observable.onError(KaraokeAPIErrMessage.didNotReceiveData)
                    return
                }
                
                guard let response = response as? HTTPURLResponse, (200 ..< 300) ~= response.statusCode else {
                    observable.onError(KaraokeAPIErrMessage.httpRequestFailure)
                    return
                }
                
                guard let searchResultSongList = try? JSONDecoder().decode([Song].self, from: jsonData) else {
                    observable.onError(KaraokeAPIErrMessage.jsonParsingError)
                    return
                }
                
                observable.onNext(searchResultSongList)
            }.resume()
            
            return Disposables.create()
        }
    }
    
    func fetchSong(titleOrSinger: String, brand: KaraokeBrand) -> Observable<[Song]> {
        
        let fetchWithTitle      = fetchSong(title: titleOrSinger, brand: brand)
        let fetchWithSinger     = fetchSong(singer: titleOrSinger, brand: brand)
        
        return Observable.create { [weak self] observable in
            guard let self = self else { return Disposables.create() }
            
            if SearchFilterItem.searchWithTitle.state && SearchFilterItem.searchWithSinger.state {
                // Search with singer & title
                Observable.combineLatest(fetchWithTitle, fetchWithSinger, resultSelector: { resultWithTitle, resultWithSinger in
                    return Array(Set(resultWithTitle).union(Set(resultWithSinger))).sorted{ $0.title < $1.title }
                }).subscribe(onNext: { combinedSongResultList in
                    observable.onNext(combinedSongResultList)
                }, onError: { error in
                    observable.onError(error)
                }).disposed(by: self.disposeBag)
            } else if SearchFilterItem.searchWithTitle.state && !SearchFilterItem.searchWithSinger.state {
                // Search with title
                self.fetchSong(title: titleOrSinger, brand: brand)
                    .subscribe(onNext: { searchResultSongList in
                        observable.onNext(searchResultSongList)
                    }, onError: { error in
                        observable.onError(error)
                    }).disposed(by: self.disposeBag)
            } else {
                // Search with singer
                self.fetchSong(singer: titleOrSinger, brand: brand)
                    .subscribe(onNext: { searchResultSongList in
                        observable.onNext(searchResultSongList)
                    }, onError: { error in
                        observable.onError(error)
                    }).disposed(by: self.disposeBag)
            }
            
            return Disposables.create()
        }
    }
}

extension String {
    
    func urlEncode() -> String {
        return self.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? self
    }
}
