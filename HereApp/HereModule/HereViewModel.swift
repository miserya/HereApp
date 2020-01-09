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

    private var loadAddress: AnyCancellable?
    private var loadCategories: AnyCancellable?
    private var loadPlaces: AnyCancellable?

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
        loadAddress?.cancel()

        let args = GetAddressArgs(latitude: location.latitude, longitude: location.longitude, radius: 250)
        loadAddress = getAddress.execute(with: args)
            .sink(receiveCompletion: { [weak self] (completion: Subscribers.Completion<Error>) in
                if case .failure(let error) = completion {
                    self?.error = error.localizedDescription
                    self?.isLoading = false
                }
            }, receiveValue: { [weak self] (address: CurrentAddress) in
                self?.currentAddress = address
                self?.isLoading = false
            })
    }

    private func fetchCategories(for location: CLLocationCoordinate2D) {
        isLoading = true
        loadCategories?.cancel()

        let args = GetPlaceCategoriesArgs(latitude: location.latitude, longitude: location.longitude)
        loadCategories = getCategories.execute(with: args)
            .sink(receiveCompletion: { [weak self] (completion: Subscribers.Completion<Error>) in
                if case .failure(let error) = completion {
                    self?.error = error.localizedDescription
                    self?.isLoading = false
                }
            }, receiveValue: { [weak self] (categories: [PlaceCategory]) in
                self?.categories = categories
                self?.isLoading = false
            })
    }

    private func fetchPlaces(for location: CLLocationCoordinate2D, categories: [PlaceCategory]) {
        isLoading = true
        loadPlaces?.cancel()

        let args = GetPlacesArgs(latitude: location.latitude, longitude: location.longitude, categories: categories)
        loadPlaces = getPlaces.execute(with: args)
            .sink(receiveCompletion: { [weak self] (completion: Subscribers.Completion<Error>) in
                if case .failure(let error) = completion {
                    self?.error = error.localizedDescription
                    self?.isLoading = false
                }
            }, receiveValue: { [weak self] (places: Pagination<Place>) in
                self?.places = places
                self?.isLoading = false
            })
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
