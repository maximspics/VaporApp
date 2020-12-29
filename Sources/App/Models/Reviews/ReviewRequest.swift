//
//  ReviewRequest.swift
//  
//
//  Created by Maxim Safronov on 27.12.2020.
//

import Foundation
import Vapor

struct ReviewRequest: Content {
    var reviewId: Int?
    var productId: Int?
    var user_name, user_email, title, description: String?
}
struct GetReviewList: Content {
    var productId: Int?
}
