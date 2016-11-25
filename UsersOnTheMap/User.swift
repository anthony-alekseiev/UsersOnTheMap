//
//  User.swift
//  UsersOnTheMap
//
//  Created by Anton Aleksieiev on 11/25/16.
//  Copyright © 2016 fynjy. All rights reserved.
//

import Foundation
import CoreLocation

struct User {
    var name: String?
    var currentLocation: CLLocationCoordinate2D?
    var ID : String?
    
    init() {
        name = "no user"
    }
}
