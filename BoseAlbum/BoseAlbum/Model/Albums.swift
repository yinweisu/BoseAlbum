//
//  Albums.swift
//  BoseAlbum
//
//  Created by Weisu Yin on 3/17/19.
//  Copyright © 2019 UCDavis. All rights reserved.
//

import Foundation
import UIKit

struct Albums: Decodable {
    var albumCounts: Int = 0
    var albums: [String] = []
}

struct Album {
    var photoCount: Int = 0
    var photos: [UIImage] = []
    var photoNames: [String] = []
}
