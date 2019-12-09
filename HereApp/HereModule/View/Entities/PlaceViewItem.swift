//
//  PlaceViewItem.swift
//  HereApp
//
//  Created by Maria Holubieva on 09.11.2019.
//  Copyright © 2019 Maria Holubieva. All rights reserved.
//

import Foundation
import MapKit

class PlaceViewItem: NSObject, MKAnnotation {
    let id: String
    let title: String?

    var coordinate: CLLocationCoordinate2D

    let isCurrentLocation: Bool

    init(id: String, title: String?, coordinate: CLLocationCoordinate2D, isCurrentLocation: Bool = false) {
        self.id = id
        self.title = title
        self.coordinate = coordinate
        self.isCurrentLocation = isCurrentLocation
        
        super.init()
    }
}
