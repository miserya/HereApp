//
//  HereMapAdapter.swift
//  HereApp
//
//  Created by Maria Holubieva on 09.11.2019.
//  Copyright © 2019 Maria Holubieva. All rights reserved.
//

import MapKit

class HereMapAdapter: NSObject, MKMapViewDelegate {

    weak var mapView: MKMapView?

    var currentPosition: PlaceViewItem? {
        willSet {
            if let currentPosition = self.currentPosition {
                data.removeAll(where: { currentPosition.id == $0.id })
            }
        }
        didSet {
            if let currentPosition = self.currentPosition {
                data.append(currentPosition)
            }
        }
    }
    
    var data = [PlaceViewItem]() {
        didSet {
            mapView?.showAnnotations(data, animated: true)
        }
    }

    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        let reuseIdentifier = "pin"
        var annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: reuseIdentifier)

        if annotationView == nil {
            annotationView = MKAnnotationView(annotation: annotation, reuseIdentifier: reuseIdentifier)
            annotationView?.canShowCallout = true
        } else {
            annotationView?.annotation = annotation
        }

        let customPointAnnotation = annotation as! PlaceViewItem
        if customPointAnnotation.isCurrentLocation {
            annotationView?.image = #imageLiteral(resourceName: "annotation_current_icon")
        } else {
            annotationView?.image = #imageLiteral(resourceName: "annotation_icon")
        }

        return annotationView
    }
}
