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

class HereViewModel: NSObject, ObservableObject, CLLocationManagerDelegate {

    @Published var location: CLLocationCoordinate2D?
    @Published var locationAddressName: String?
    @Published var categoriesViewItems = [PlaceCategoryViewItem]()
    @Published var placesViewItems = [PlaceViewItem]()
    @Published var isLoading: Bool = false
    @Published var error: String?

    private let locationManager = CLLocationManager()

    private let getAddress = GetAddress()
    private let getCategories = GetPlaceCategories()
    private let getPlaces = GetPlaces()

    private var currentAddress: CurrentAddress = CurrentAddress.empty {
        didSet {
            locationAddressName = currentAddress.name
        }
    }
    private var categories = [PlaceCategory]() {
        didSet {
            categoriesViewItems = categories.map({ PlaceCategoryViewItem(id: $0.id, title: $0.title, icon: $0.icon, isSelected: selectedCategories.contains($0)) })
        }
    }
    private var places: Pagination<Place>? {
        didSet {
            placesViewItems = places?.items.map({ PlaceViewItem(id: $0.id, title: $0.title, coordinate: CLLocationCoordinate2D(latitude: $0.latitude, longitude: $0.longitude)) }) ?? []
        }
    }
    private var selectedCategories = [PlaceCategory]()

    override init() {
        super.init()

        locationManager.delegate = self
        fetchCurrentLocation()
    }

    func fetchCurrentLocation() {
        locationManager.requestWhenInUseAuthorization()
    }

    func fetchAddressesAndCategories() {
        if let location = self.location {
            fetchAddress(for: location)
            fetchCategories(for: location)
        }
    }

    func fetchPlacesInfo() {
        if let location = self.location {
            fetchPlaces(for: location, categories: selectedCategories)
        }
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
        isLoading = true
        let args = GetAddressArgs(latitude: location.latitude, longitude: location.longitude, radius: 250)
        getAddress.execute(with: args) { [weak self] (result: Result<CurrentAddress, Error>) in
            guard let self = self else { return }

            self.isLoading = false
            switch result {
            case .success(let address):
                self.currentAddress = address
            case .failure(let error):
                self.error = error.localizedDescription
            }
        }
    }

    private func fetchCategories(for location: CLLocationCoordinate2D) {
        isLoading = true
        let args = GetPlaceCategoriesArgs(latitude: location.latitude, longitude: location.longitude)
        getCategories.execute(with: args) { [weak self] (result: Result<[PlaceCategory], Error>) in
            guard let self = self else { return }

            self.isLoading = false
            switch result {
            case .success(let categories):
                self.categories = categories
            case .failure(let error):
                self.error = error.localizedDescription
            }
        }
    }

    private func fetchPlaces(for location: CLLocationCoordinate2D, categories: [PlaceCategory]) {
        isLoading = true
        let args = GetPlacesArgs(latitude: location.latitude, longitude: location.longitude, categories: categories)
        getPlaces.execute(with: args) { [weak self] (result: Result<Pagination<Place>, Error>) in
            guard let self = self else { return }

            self.isLoading = false
            switch result {
            case .success(let pagination):
                self.places = pagination
            case .failure(let error):
                self.error = error.localizedDescription
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
        self.error = error.localizedDescription
    }

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        location = locations.first?.coordinate
        fetchAddressesAndCategories()
    }
}
