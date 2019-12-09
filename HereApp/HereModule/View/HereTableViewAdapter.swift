//
//  HereTableViewAdapter.swift
//  HereApp
//
//  Created by Maria Holubieva on 09.11.2019.
//  Copyright © 2019 Maria Holubieva. All rights reserved.
//

import UIKit

enum TableViewDataType {
    case categories
    case searchResults
}

class HereTableViewAdapter: NSObject, UITableViewDelegate, UITableViewDataSource {

    weak var tableView: UITableView?

    var dataType: TableViewDataType = .categories {
        didSet {
            tableView?.reloadData()
        }
    }

    var categories = [PlaceCategoryViewItem]() {
        didSet {
            if case .categories = dataType {
                tableView?.reloadData()
            }
        }
    }

    var searchResults = [PlaceViewItem]() {
        didSet {
            if case .searchResults = dataType {
                tableView?.reloadData()
            }
        }
    }

    var onCategorySelected: ((PlaceCategoryViewItem) -> Void)?
    var onCategoryDeselected: ((PlaceCategoryViewItem) -> Void)?
    var onSearchResultSelected: ((PlaceViewItem) -> Void)?

    private var headerViewLabel: UILabel?

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch dataType {
        case .categories:
            return categories.count
        case .searchResults:
            return searchResults.count
        }
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "HerePlaceCategoryCell", for: indexPath) as! HerePlaceCategoryCell

        var text: String?
        switch dataType {
        case .categories:
            text = categories[indexPath.row].title
        case .searchResults:
            if let title = searchResults[indexPath.row].title {
                text = "PLACE: \(title)"
            }
        }

        cell.labelName.text = text

        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch dataType {
        case .categories:
            onCategorySelected?(categories[indexPath.row])
        case .searchResults:
            onSearchResultSelected?(searchResults[indexPath.row])
        }
    }

    func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        switch dataType {
        case .categories:
            onCategoryDeselected?(categories[indexPath.row])
        case .searchResults:
            break
        }
    }
}
