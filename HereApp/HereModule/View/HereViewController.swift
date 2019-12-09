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
        return HereViewModel(state: .initialLocationFetching)
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

        let gotCurrentAddress = viewModel.$state
            .filter({ (state: HereViewModelState) -> Bool in
                switch state {
                case .gotCurrentAddressName: return true
                default: return false
                }
            })
            .map({
                switch $0 {
                    case .gotCurrentAddressName(let title):
                        return "Current address is: \(title)"
                    default:
                        return nil
                }
            })
            .assign(to: \.text, on: titleLabel)

        let gotCategoriesList = viewModel.$state
            .filter({ (state: HereViewModelState) -> Bool in
                switch state {
                case .gotCategoriesList: return true
                default: return false
                }
            })
            .map({
                switch $0 {
                case .gotCategoriesList(let categories):
                    return categories
                default:
                    return []
                }
            })
            .assign(to: \.categories, on: tableViewAdapter)

        let gotPlacesList = viewModel.$state
            .filter({ (state: HereViewModelState) -> Bool in
                switch state {
                case .gotPlacesList: return true
                default: return false
                }
            })
            .map({
                switch $0 {
                case .gotPlacesList(let places):
                    return places
                default:
                    return []
                }
            })
            .assign(to: \.data, on: mapAdapter)

        let gotPlacesList2 = viewModel.$state
            .filter({ (state: HereViewModelState) -> Bool in
                switch state {
                case .gotPlacesList: return true
                default: return false
                }
            })
            .map({
                switch $0 {
                case .gotPlacesList(let places):
                    return places
                default:
                    return []
                }
            })
            .assign(to: \.searchResults, on: tableViewAdapter)

        let stateChange = viewModel.$state
            .sink(receiveValue: { [weak self] (state: HereViewModelState) in
                guard let self = self else { return }

                switch state {
                case .error(let error):
                    self.loadingIndicator.stopAnimating()
                    debugPrint("ERROR: \(error.localizedDescription)")

                case .gotLocation(let location):
                    self.loadingIndicator.stopAnimating()
                    self.setCurrentLocation(location)

                case .loading:
                    self.loadingIndicator.startAnimating()

                default:
                    self.loadingIndicator.stopAnimating()
                }
            })

        publishers.append(contentsOf: [gotCurrentAddress, gotCategoriesList, gotPlacesList, gotPlacesList2, stateChange])
    }

    @IBAction func onUpdate() {
        viewModel.state = .placesLoading
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
