//
//  HereViewModel.swift
//  HereApp
//
//  Created by Maria Holubieva on 09.11.2019.
//  Copyright © 2019 Maria Holubieva. All rights reserved.
//

import Foundation
import DomainLayer
import Combine
import CoreLocation

enum HereViewModelState {
    case none
    case initialLocationFetching
    case addressAndCategoriesLoading
    case placesLoading
    case gotLocation(CLLocationCoordinate2D)
    case gotCurrentAddressName(String)
    case gotCategoriesList([PlaceCategoryViewItem])
    case gotPlacesList([PlaceViewItem])
    case error(Error)
    case loading
}

class HereViewModel: NSObject, ObservableObject, CLLocationManagerDelegate {

    @Published var state: HereViewModelState = .none {
        didSet {
            switch state {
            case .initialLocationFetching:
                locationManager.requestWhenInUseAuthorization()
                break

            case .addressAndCategoriesLoading:
                if let location = self.location {
                    fetchAddress(for: location)
                    fetchCategories(for: location)
                }

            case .placesLoading:
                if let location = self.location {
                    fetchPlaces(for: location, categories: selectedCategories)
                }

            default:
                break
            }
        }
    }

    private let locationManager = CLLocationManager()

    //use cases
    private let getAddress = GetAddress()
    private let getCategories = GetPlaceCategories()
    private let getPlaces = GetPlaces()

    //data
    private var location: CLLocationCoordinate2D? {
        didSet {
            if let location = self.location {
                state = .gotLocation(location)
            }
        }
    }
    private var currentAddress: CurrentAddress = CurrentAddress.empty {
        didSet {
            state = .gotCurrentAddressName(currentAddress.name)
        }
    }
    private var categories = [PlaceCategory]() {
        didSet {
            let viewItems = categories.map({ PlaceCategoryViewItem(id: $0.id, title: $0.title, icon: $0.icon) })
            state = .gotCategoriesList(viewItems)
        }
    }
    private var places: Pagination<Place>? {
        didSet {
            let viewItems = places?.items.map({ PlaceViewItem(id: $0.id, title: $0.title, coordinate: CLLocationCoordinate2D(latitude: $0.latitude, longitude: $0.longitude)) }) ?? []
            state = .gotPlacesList(viewItems)
        }
    }

    private var selectedCategories = [PlaceCategory]()

    init(state: HereViewModelState) {
        super.init()

        self.locationManager.delegate = self
        self.state = state
    }

    func onSelectCategory(_ category: PlaceCategoryViewItem) {
        if let item = categories.first(where: { $0.id == category.id }) {
            selectedCategories.append(item)
        }
    }

    func onDeselectCategory(_ category: PlaceCategoryViewItem) {
        selectedCategories.removeAll(where: { $0.id == category.id })
    }

    //MARK: - Private

    private func fetchAddress(for location: CLLocationCoordinate2D) {
        state = .loading
        let args = GetAddressArgs(latitude: location.latitude, longitude: location.longitude, radius: 250)
        getAddress.execute(with: args) { [weak self] (result: Result<CurrentAddress, Error>) in
            switch result {
            case .success(let address):
                self?.currentAddress = address
            case .failure(let error):
                self?.state = .error(error)
            }
        }
    }

    private func fetchCategories(for location: CLLocationCoordinate2D) {
        state = .loading
        let args = GetPlaceCategoriesArgs(latitude: location.latitude, longitude: location.longitude)
        getCategories.execute(with: args) { [weak self] (result: Result<[PlaceCategory], Error>) in
            switch result {
            case .success(let categories):
                self?.categories = categories
            case .failure(let error):
                self?.state = .error(error)
            }
        }
    }

    private func fetchPlaces(for location: CLLocationCoordinate2D, categories: [PlaceCategory]) {
        state = .loading
        let args = GetPlacesArgs(latitude: location.latitude, longitude: location.longitude, categories: categories)
        getPlaces.execute(with: args) { [weak self] (result: Result<Pagination<Place>, Error>) in
            switch result {
            case .success(let pagination):
                self?.places = pagination
            case .failure(let error):
                self?.state = .error(error)
            }
        }
    }

    //MARK: - CLLocationManagerDelegate

    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        switch status {
        case .authorizedWhenInUse:
            locationManager.requestLocation()
        default:
            break
        }
    }
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        state = .error(error)
    }

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        location = locations.first?.coordinate
        state = .addressAndCategoriesLoading
    }
}
