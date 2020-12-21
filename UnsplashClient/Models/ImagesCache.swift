//
//  ImagesCache.swift
//  UnsplashClient
//
//  Created by Максим Голов on 21.12.2020.
//

import UIKit

class ImagesCache {
    private var uiImages: [UIImage?]
    private var dataTasks: [URLSessionDataTask?]
    
    init(size: Int) {
        uiImages = [UIImage?](repeating: nil, count: size)
        dataTasks = [URLSessionDataTask?](repeating: nil, count: size)
    }
    
    subscript(i: Int) -> UIImage? {
        get {
            return uiImages[i]
        }
        set {
            uiImages[i] = newValue
        }
    }
    
    func recreate(newSize: Int) {
        uiImages = [UIImage?](repeating: nil, count: newSize)
        dataTasks.forEach { $0?.cancel() }
        dataTasks = [URLSessionDataTask?](repeating: nil, count: newSize)
    }
    
    func increase(by count: Int) {
        uiImages += [UIImage?](repeating: nil, count: count)
        dataTasks += [URLSessionDataTask?](repeating: nil, count: count)
    }
    
    func setDataTask(_ dataTask: URLSessionDataTask?, for row: Int) {
        dataTasks[row] = dataTask
    }
    
    func cancelDataTasksFor(indexPaths: [IndexPath]) {
        indexPaths.forEach {
            dataTasks[$0.row]?.cancel()
        }
    }
}
