//
//  ViewController.swift
//  RMtest
//
//  Created by Narek on 20.02.22.
//

import UIKit

enum RMError: Error {
    case wrongUrl
    case wrongImage
    case inProcess
}

struct Response: Decodable {
    var results: [Item]
}

struct Item: Decodable {
    var name: String
    var image: String
    var location: Location?
}

struct Location: Decodable {
    var name: String?
}
