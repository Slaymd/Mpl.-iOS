//
//  TextResearcherView.swift
//  Mpl.
//
//  Created by Darius Martin on 12/05/2018.
//  Copyright © 2018 Darius MARTIN. All rights reserved.
//

import UIKit

class TextResearcherView: UIViewController, UITextFieldDelegate {

    @IBOutlet weak var stationScroll: UIScrollView!
    @IBOutlet weak var newSearchField: UITextField!
    
    var lastFilteredStations: [StopZone] = []
    var keyboardHeight: CGFloat = 0.0
    
    override func viewDidLoad() {
        super.viewDidLoad()

        newSearchField.placeholder = NSLocalizedString("Station name", comment: "")
        newSearchField.delegate = self
        newSearchField.returnKeyType = .done
        //Observer when keyboard is opened to getting its size.
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(keyboardWillShow),
            name: NSNotification.Name.UIKeyboardWillShow,
            object: nil
        )
    }
    
    //MARK: - GETTING KEYBOARD HEIGHT
    
    @objc func keyboardWillShow(_ notification: Notification) {
        if let keyboardFrame: NSValue = notification.userInfo?[UIKeyboardFrameEndUserInfoKey] as? NSValue {
            let keyboardRectangle = keyboardFrame.cgRectValue
            keyboardHeight = keyboardRectangle.height
            self.updateStationList(with: self.lastFilteredStations)
        }
    }
    
    //MARK: - CLICKING DONE BUTTON : UI redisplay without keyboard space
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.view.endEditing(true)
        self.keyboardHeight = 0
        self.updateStationList(with: self.lastFilteredStations)
        return true
    }
    
    //MARK: - EDITING TEXTFIELD
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        var str = newSearchField.text
        let endindex = str!.index(str!.endIndex, offsetBy: range.length * -1)
        
        str = String(str![..<endindex])
        if (string.count > 1) { return true }
        if (str == nil) { str = string } else { str!.append(string) }
        str = str!.toASCII().lowercased()
        if (str!.count > 2) {
            //Display
            self.lastFilteredStations = getStationListFiltered(byName: str!)
            updateStationList(with: self.lastFilteredStations)
        } else {
            //Clear
            for view in self.stationScroll.subviews { view.removeFromSuperview() }
        }
        return true
    }
    
    //MARK: - GET STATIONS LIST BY STRING
    
    func getStationListFiltered(byName name: String) -> [StopZone] {
        var filteredStations: [StopZone] = []
        
        //Filter each stations with good name
        filteredStations = TransportData.stopZones.filter({$0.name.toASCII().lowercased().contains(name)})
        //Sort by number of lines
        filteredStations = filteredStations.sorted(by: {$0.getLines().count > $1.getLines().count})
        filteredStations = filteredStations.sorted(by: {$0.lines.filter({$0.type == .TRAMWAY}).count > $1.lines.filter({$0.type == .TRAMWAY}).count})
        updateStationList(with: filteredStations)
        return filteredStations
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
            self.stationScroll.contentSize = CGSize(width: Int(self.stationScroll.frame.width), height: y + Int(self.keyboardHeight))
        }
    }
    
    @IBAction func clickBackButton(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
    //MARK: - STATUS BAR
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
}
