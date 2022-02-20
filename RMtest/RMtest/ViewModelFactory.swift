//
//  ViewController.swift
//  RMtest
//
//  Created by Narek on 20.02.22.
//

import UIKit
import Combine


class ViewModelFactory {
    static func getNetworkLayer(_ baseUrl: String) -> INetworkLayer {
        NetworkLayer(baseUrl: baseUrl, imageCache: getImageCache())
    }
    
    static func getImageCache() -> IImageCache {
        ImageCache()
    }
    
    static func getViewModel(_ baseUrl: String) -> IViewModel {
        ViewModel(getNetworkLayer(baseUrl))
    }
}
