//
//  File.swift
//  
//
//  Created by Maxim Safronov on 27.12.2020.
//

import Foundation
import Vapor

struct BasketRequest: Content {
    var userId: Int?
    var productId: Int?
    var quantity: Int?
    var paySumm: Int?
}
