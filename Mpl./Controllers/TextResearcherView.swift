//
//  TextResearcherView.swift
//  Mpl.
//
//  Created by Darius Martin on 12/05/2018.
//  Copyright © 2018 Darius MARTIN. All rights reserved.
//

import UIKit

class TextResearcherView: UIViewController, UITextFieldDelegate, UIScrollViewDelegate {

    @IBOutlet weak var headerView: UIView!
    @IBOutlet weak var stationScroll: UIScrollView!
    @IBOutlet weak var newSearchField: UITextField!
    @IBOutlet weak var backButton: UIButton!
    
    @IBOutlet weak var headerHeightConstraint: NSLayoutConstraint!
    var headerHeightState = 0
    
    var lastFilteredStations: [StopZone] = []
    var stationCards: [UILightStationCard] = []
    var keyboardHeight: CGFloat = 0.0
    
    override func viewDidLoad() {
        super.viewDidLoad()

        newSearchField.placeholder = NSLocalizedString("Station name", comment: "")
        newSearchField.delegate = self
        stationScroll.delegate = self
        newSearchField.returnKeyType = .done
        //Observer when keyboard is opened to get its size.
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(keyboardWillShow),
            name: NSNotification.Name.UIKeyboardWillShow,
            object: nil
        )
    }
    
    //MARK: - HEADER VIEW HEIGHT WHILE SCROLLING STATION LIST
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let contentOffset = scrollView.contentOffset
        var heightConstraint: [NSLayoutConstraint]
        
        heightConstraint = self.view.constraints.filter({$0.identifier == "height"})
        if (contentOffset.y > 10 && self.headerHeightState == 0) {
            if (heightConstraint.count != 1) { return; }
            self.view.addConstraint(heightConstraint[0].setMultiplier(multiplier: 0.12))
            self.headerHeightState = 1
        } else if (contentOffset.y <= 10 &&  self.headerHeightState == 1) {
            if (heightConstraint.count != 1) { return; }
            self.view.addConstraint(heightConstraint[0].setMultiplier(multiplier: 0.22))
            self.headerHeightState = 0
        } else { return }
        UIView.animate(withDuration: 0.125, animations: {
            if (self.headerHeightState == 1) {
                self.backButton.alpha = 0
            } else {
                self.backButton.alpha = 1
            }
            self.view.layoutIfNeeded()
        })
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
            self.lastFilteredStations = getStationListFiltered(byName: str!.replacingOccurrences(of: "-", with: " "))
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
        filteredStations = TransportData.stopZones.filter({$0.name.toASCII().lowercased().replacingOccurrences(of: "-", with: " ").contains(name)})
        //Sort by number of lines
        filteredStations.sort(by: {($0.getLines().count > 0 && $1.getLines().count > 0) && $0.getLines()[0].tamId < $1.getLines()[0].tamId})
        filteredStations.sort(by: {$0.getLines().count > $1.getLines().count})
        filteredStations.sort(by: {$0.lines.filter({$0.type == .TRAMWAY}).count > $1.lines.filter({$0.type == .TRAMWAY}).count})
        updateStationList(with: filteredStations)
        return filteredStations
    }
    
    //MARK: - DISP STATION LIST
    
    func updateStationList(with stations: [StopZone]) {
        var y = 16;
        var stationCard: UILightStationCard
        var tap: UITapGestureRecognizer
        
        //Clear displayed stations
        for view in self.stationScroll.subviews { view.removeFromSuperview() }
        self.stationCards.removeAll()
        //Display new station list
        for i in 0..<stations.count {
            stationCard = UILightStationCard(frame: CGRect(x: 16, y: y, width: Int(UIScreen.main.bounds.width)-32, height: 50), station: stations[i], distance: 1000)
            y += Int(stationCard.frame.height)+15
            tap = UITapGestureRecognizer(target: self, action: #selector(handleStationTap(sender:)))
            stationCard.addGestureRecognizer(tap)
            self.stationCards.append(stationCard)
            self.stationScroll.addSubview(stationCard)
            self.stationScroll.contentSize = CGSize(width: Int(self.stationScroll.frame.width), height: y + Int(self.keyboardHeight))
        }
    }
    
    //MARK: - CLICKING ON STATION CARD
    
    @objc func handleStationTap(sender: UITapGestureRecognizer) {
        let clickLoc = sender.location(in: self.stationScroll)
        
        for stationCard in self.stationCards {
            if clickLoc.x < stationCard.frame.minX || clickLoc.x > stationCard.frame.maxX { continue }
            if clickLoc.y < stationCard.frame.minY || clickLoc.y > stationCard.frame.maxY { continue }
            
            let stationPopUp: StationPopUpView = StationPopUpView.init(nibName: "StationPopUpView", bundle: nil, station: stationCard.station, mainView: self)
            stationPopUp.modalPresentationStyle = .overCurrentContext
            self.view.endEditing(true)
            self.keyboardHeight = 0
            self.updateStationList(with: self.lastFilteredStations)
            self.present(stationPopUp, animated: false, completion: nil)
            break
        }
    }
    
    //MARK: - CLICKING BACK BUTTON
    
    @IBAction func clickBackButton(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
    //MARK: - STATUS BAR
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
}

extension NSLayoutConstraint {
    /**
     Change multiplier constraint
     
     - parameter multiplier: CGFloat
     - returns: NSLayoutConstraint
     */
    func setMultiplier(multiplier:CGFloat) -> NSLayoutConstraint {
        
        NSLayoutConstraint.deactivate([self])
        
        let newConstraint = NSLayoutConstraint(
            item: firstItem as Any,
            attribute: firstAttribute,
            relatedBy: relation,
            toItem: secondItem,
            attribute: secondAttribute,
            multiplier: multiplier,
            constant: constant)
        
        newConstraint.priority = priority
        newConstraint.shouldBeArchived = self.shouldBeArchived
        newConstraint.identifier = self.identifier
        
        NSLayoutConstraint.activate([newConstraint])
        return newConstraint
    }
}
