//
//  Albums.swift
//  BoseAlbum
//
//  Created by Weisu Yin on 3/17/19.
//  Copyright © 2019 UCDavis. All rights reserved.
//

import Foundation

struct Albums: Decodable {
    var albumCounts: Int = 0
    var albums: [String] = []
}

struct Album: Decodable {
    var photos: [URL] = []
}
