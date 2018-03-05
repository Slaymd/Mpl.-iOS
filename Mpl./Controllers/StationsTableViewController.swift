//
//  StationsTableViewController.swift
//  Mpl.
//
//  Created by Darius Martin on 30/12/2017.
//  Copyright © 2017 Darius MARTIN. All rights reserved.
//

import UIKit
import os.log

class StationsTableViewController: UITableViewController {
    
    let sections: [String] = ["Favoris", "Tout"]
    let searchController = UISearchController(searchResultsController: nil)
    var filteredStations = [StopZone]()
    
    //MARK: Remove navigation bar in main view
    
    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.setNavigationBarHidden(false, animated: animated)
        super.viewWillAppear(animated)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        searchController.searchBar.barTintColor = UIColor(red: 5.0/255.0, green: 168.0/255.0, blue: 254.0/255.0, alpha: 1.0)
        UITextField.appearance(whenContainedInInstancesOf: [UISearchBar.self]).backgroundColor = .red
        (UITextField.appearance(whenContainedInInstancesOf: [UISearchBar.self])).attributedPlaceholder = NSAttributedString.init(string: "Rechercher une station", attributes: [NSAttributedStringKey(rawValue: NSAttributedStringKey.foregroundColor.rawValue): UIColor(red: 0.98, green: 0.98, blue: 0.98, alpha: 1.0)])
        (UITextField.appearance(whenContainedInInstancesOf: [UISearchBar.self])).defaultTextAttributes = [NSAttributedStringKey.foregroundColor.rawValue: UIColor(red: 5.0/255.0, green: 168.0/255.0, blue: 254.0/255.0, alpha: 1.0)]
        searchController.searchResultsUpdater = self
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.placeholder = "Rechercher une station"
        navigationItem.searchController = searchController
        navigationItem.hidesSearchBarWhenScrolling = true
        definesPresentationContext = true
        
    }
    
    //MARK: Filtering
    
    func isFiltering() -> Bool {
        return searchController.isActive && !searchBarIsEmpty()
    }
    
    func searchBarIsEmpty() -> Bool {
        return searchController.searchBar.text?.isEmpty ?? true
    }
    
    func filterContentForSearchText(_ searchText: String, scope: String = "All") {
        filteredStations = TransportData.stopZones.filter({( station: StopZone) -> Bool in
            if station.name.lowercased().toASCII().replacingOccurrences(of: "'", with: " ").contains(searchText.lowercased().toASCII().replacingOccurrences(of: "’", with: " ").replacingOccurrences(of: "'", with: " ")) {
                return true
            }
            return false
        })
    }
    
    //MARK: Memory leaks

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return self.sections[section]
    }

    override func numberOfSections(in tableView: UITableView) -> Int {
        return self.sections.count
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let station: StopZone
        
        station = indexPath.section == 0 ? UserData.getFavStations()[indexPath.row] : self.isFiltering() ? self.filteredStations[indexPath.row] : TransportData.stopZones[indexPath.row]
        ViewMaker.createStationPopUpFromTableView(view: self.navigationController!, tableView: self, station: station)
        tableView.deselectRow(at: indexPath, animated: false)
    }
    
    override func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        var swipeActions: [UITableViewRowAction] = [UITableViewRowAction]()
        
        if indexPath.section == 0 {
            let delete = UITableViewRowAction(style: .destructive, title: "Supprimer") { (action, indexPath) in
                let station = UserData.getFavStations()[indexPath.row]
                UserData.removeFavStation(station: station)
                tableView.deleteRows(at: [indexPath], with: UITableViewRowAnimation.automatic)
            }
            swipeActions.append(delete)
        } else {
            let addfav = UITableViewRowAction(style: .normal, title: "Ajouter aux favoris") { (action, indexPath) in
                let station =  self.isFiltering() ? self.filteredStations[indexPath.row] : TransportData.stopZones[indexPath.row]
                tableView.reloadData()
                if UserData.addFavStation(station: station) == 0 {
                    tableView.insertRows(at: [IndexPath.init(row: UserData.favStationsId.count-1, section: 0)], with: .automatic)
                }
            }
            addfav.backgroundColor = UIColor.orange
            swipeActions.append(addfav)
        }
        
        return swipeActions
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return UserData.favStationsId.count
        }
        if isFiltering() {
            return filteredStations.count
        }
        return TransportData.stopZones.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cellIdentifier = "station"
        guard let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as? StationsTableViewCell else { fatalError("Cell dequeue problem.") }
        
        //Delete old data (prevent from lagging)
        for view in cell.logosPanel.subviews {
            view.removeFromSuperview()
        }
        
        //New cell display
        var station: StopZone? = nil
        
        if indexPath.section == 0 {
            if indexPath.row < UserData.getFavStations().count {
                station = UserData.getFavStations()[indexPath.row]
            } else {
                os_log("1- A fav station ID doesn't exist. Ignored.", type: .error)
            }
        } else if isFiltering() {
            if indexPath.row < filteredStations.count {
                station = filteredStations[indexPath.row]
            } else {
                os_log("2- A fav station ID doesn't exist. Ignored.", type: .error)
            }
        } else {
            if indexPath.row < TransportData.stopZones.count {
                station = TransportData.stopZones[indexPath.row]
            } else {
                os_log("3- A fav station ID doesn't exist. Ignored.", type: .error)
            }
        }

        if station == nil {
            cell.nameLabel.text = "#!ID_DOESNT_EXIT"
            return cell
        }
        //Station name
        cell.nameLabel.text = station!.name
        
        return cell
    }

}


extension StationsTableViewController: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        filterContentForSearchText(searchController.searchBar.text!)
        tableView.reloadData()
    }
}
