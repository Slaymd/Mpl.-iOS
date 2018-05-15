//
//  TextResearcherView.swift
//  Mpl.
//
//  Created by Darius Martin on 12/05/2018.
//  Copyright © 2018 Darius MARTIN. All rights reserved.
//

import UIKit

class TextResearcherView: UIViewController {

    @IBOutlet weak var searchField: UITextField!
    @IBOutlet weak var stationScroll: UIScrollView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        searchField.placeholder = NSLocalizedString("Station name", comment: "")
        searchField.addTarget(self, action: #selector(self.textFieldDidChange(_:)),
                            for: UIControlEvents.editingChanged)
        // Do any additional setup after loading the view.
    }
    
    //MARK: - EDIT VALUE EVENT
    
    @objc func textFieldDidChange(_ textField: UITextField) {
        let formattedTextField: String
        var filteredStations: [StopZone] = []
        
        print("coucou")
        if (self.searchField.text == nil) { return }
        formattedTextField = self.searchField.text!.toASCII().lowercased()
        if formattedTextField.count < 2 {
            //Clear displayed stations
            for view in self.stationScroll.subviews { view.removeFromSuperview() }
            return
        }
        //Filter each stations with good name / city
        filteredStations = TransportData.stopZones.filter({$0.name.toASCII().lowercased().contains(formattedTextField)})
        //Sort by number of lines
        filteredStations = filteredStations.sorted(by: {$0.getLines().count > $1.getLines().count})
        filteredStations = filteredStations.sorted(by: {$0.lines.filter({$0.type == .TRAMWAY}).count > $1.lines.filter({$0.type == .TRAMWAY}).count})
        updateStationList(with: filteredStations)
    }
    
    //MARK: - DISP STATION LIST
    
    func updateStationList(with stations: [StopZone]) {
        var y = 16;
        var stationCard: UILightStationCard
        
        //Clear displayed stations
        for view in self.stationScroll.subviews { view.removeFromSuperview() }
        //Display new station list
        for i in 0..<stations.count {
            stationCard = UILightStationCard(frame: CGRect(x: 16, y: y, width: Int(UIScreen.main.bounds.width)-32, height: 50), station: stations[i], distance: 1000)
            y += Int(stationCard.frame.height)+15
            self.stationScroll.addSubview(stationCard)
            self.stationScroll.contentSize = CGSize(width: Int(self.stationScroll.frame.width), height: y)
        }
    }
    
    //MARK: - STATUS BAR
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
}
