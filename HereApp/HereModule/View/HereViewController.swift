//
//  HereViewController.swift
//  HereApp
//
//  Created by Maria Holubieva on 09.11.2019.
//  Copyright © 2019 Maria Holubieva. All rights reserved.
//

import UIKit
import Combine
import MapKit

class HereViewController: UIViewController {

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var btnUpdate: UIButton!
    @IBOutlet weak var btnSwitchTableViewSource: UISegmentedControl!
    @IBOutlet weak var loadingIndicator: UIActivityIndicatorView!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var mapView: MKMapView!

    private lazy var viewModel: HereViewModel = {
        return HereViewModel()
    }()
    
    private let tableViewAdapter = HereTableViewAdapter()
    private let mapAdapter = HereMapAdapter()

    private var publishers = [AnyCancellable]()

    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.delegate = tableViewAdapter
        tableView.dataSource = tableViewAdapter
        tableViewAdapter.tableView = tableView
        tableViewAdapter.onCategorySelected = { [weak self] (category: PlaceCategoryViewItem) in
            self?.viewModel.onSelectCategory(category)
        }
        tableViewAdapter.onCategoryDeselected = { [weak self] (category: PlaceCategoryViewItem) in
            self?.viewModel.onDeselectCategory(category)
        }
        tableViewAdapter.onSearchResultSelected = { [weak self] (place: PlaceViewItem) in
            self?.mapView.selectAnnotation(place, animated: true)
        }

        mapView.delegate = mapAdapter
        mapAdapter.mapView = mapView

        let gotCurrentAddress = viewModel.$locationAddressName
            .assign(to: \.text, on: titleLabel)

        let gotCategoriesList = viewModel.$categoriesViewItems
            .assign(to: \.categories, on: tableViewAdapter)

        let gotPlacesList = viewModel.$placesViewItems
            .assign(to: \.data, on: mapAdapter)

        let gotPlacesList2 = viewModel.$placesViewItems
            .assign(to: \.searchResults, on: tableViewAdapter)

        let loader = viewModel.$isLoading.sink { [unowned self] (isLoading: Bool) in
            if isLoading {
                self.loadingIndicator.startAnimating()
            } else {
                self.loadingIndicator.stopAnimating()
            }
        }

        let error = viewModel.$error.sink { (errorMessage: String?) in
            debugPrint("ERROR: \(errorMessage ?? "Unknown")")
        }

        let currentLocation = viewModel.$location.sink { [unowned self] (location: CLLocationCoordinate2D?) in
            guard let location = location else { return }
            self.setCurrentLocation(location)
        }

        publishers.append(contentsOf: [gotCurrentAddress, gotCategoriesList, gotPlacesList, gotPlacesList2, loader, error, currentLocation])
    }

    @IBAction func onUpdate() {
        viewModel.fetchPlacesInfo()
    }

    @IBAction func onTableViewDataTypeChanged(_ sender: UISegmentedControl) {
        tableViewAdapter.dataType = sender.selectedSegmentIndex == 0 ? .categories : .searchResults
        tableView.allowsMultipleSelection = sender.selectedSegmentIndex == 0
    }

    //MARK: - Private

    private func setCurrentLocation(_ location: CLLocationCoordinate2D) {
        mapView.setCenter(location, animated: true)
        mapAdapter.currentPosition = PlaceViewItem(id: UUID().uuidString, title: "Current Location", coordinate: location, isCurrentLocation: true)
    }
}
