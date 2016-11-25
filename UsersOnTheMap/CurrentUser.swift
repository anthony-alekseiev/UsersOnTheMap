//
//  CurrentUser.swift
//  UsersOnTheMap
//
//  Created by Anton Aleksieiev on 11/25/16.
//  Copyright © 2016 fynjy. All rights reserved.
//

import Foundation
import CoreLocation

struct CurrentUser {
    
    static var sharedUser = CurrentUser()
    
    var signedIn = false
    var name : String?
    var currentLocation : CLLocationCoordinate2D?
    
}
