//
//  SearchDriversServiece.swift
//  WunderDrive
//
//  Created by Tran Hoang Canh on 15/3/18.
//  Copyright © 2018 Tran Hoang Canh. All rights reserved.
//

import UIKit
import RxCocoa
import RxSwift
import CT_RESTAPI
import Alamofire

typealias SearchDriversServiceCompletionHandler = (_ results: [Driver], _ error: Error?) -> Void

protocol SearchDriversServiceProtocol {
    func getListDrivers(completion: @escaping SearchDriversServiceCompletionHandler) -> Observable<[Driver]>
}

final class SearchDriversServiece: SearchDriversServiceProtocol {
    
    /// Get drivers list
    ///
    /// - Parameters:
    ///   - completion: Results and error of API
    /// - Returns: Observable<[Driver]>
    func getListDrivers(completion: @escaping SearchDriversServiceCompletionHandler) -> Observable<[Driver]> {
        
        let apiManager = RESTApiClient(subPath: "wunderbucket", functionName: "locations.json", method: .GET, endcoding: .URL)
        
        return apiManager.requestObjects(keyPath: "placemarks")
            .observeOn(MainScheduler.instance)
            .catchError({ (error) -> Observable<[Driver]> in
                completion([], error as! CTNetworkErrorType)
                return Observable.empty()
            })
            .map { (results) -> [Driver] in
                if results.count > 0 {
                    completion(results, nil)
                    return results
                }
                else {
                    completion([], nil)
                    return []
                }
        }
    }
    
    func createFakePagingLoading() -> Observable<[Driver]> {
        return Observable.create { observer -> Disposable in
            request("https://www.google.com/",
                    method: HTTPMethod.get)
                .responseData(queue: DispatchQueue.main, completionHandler: {(_) in
                    observer.onNext([])
                    observer.onCompleted()
                })

            return Disposables.create {}
            }.do(onError: { (error) in
            }) 
        
//        let apiManager = RESTApiClient(subPath: "wunderbucket", functionName: "locations.json", method: .GET, endcoding: .URL)
//
//        return apiManager.requestObjects(keyPath: "placemarks")
    }

}
