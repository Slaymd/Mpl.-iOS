//
//  ResearcherViewController.swift
//  Mpl.
//
//  Created by Darius Martin on 12/03/2018.
//  Copyright © 2018 Darius MARTIN. All rights reserved.
//

import UIKit

class ResearcherViewController: UIViewController, UIGestureRecognizerDelegate {

    var mainScrollView: MainScrollView
    
    var lineCards: [UILineCard] = []
    var stationCards: [UILightStationCard] = []
    var animState = 0

    @IBOutlet weak var headerView: UIView!
    @IBOutlet weak var headerShadowLabel: UILabel!
    @IBOutlet weak var headerLightLabel: UILabel!

    @IBOutlet weak var linesTitle: UILabel!
    @IBOutlet weak var linesScroll: UIScrollView!
    
    @IBOutlet weak var stationsTitle: UILabel!
    @IBOutlet weak var stationsScroll: UIScrollView!
    
    
    //MARK: - INITS
    
    init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?, mainScrollView: MainScrollView) {
        self.mainScrollView = mainScrollView
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //MARK: - APPEAR
    
    override func viewWillAppear(_ animated: Bool) {
        //self.navigationController?.setNavigationBarHidden(true, animated: animated)
        super.viewWillAppear(animated)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        //self.navigationController?.setNavigationBarHidden(false, animated: animated)
        super.viewWillDisappear(animated)
    }
    
    //MARK: - VIEW LOAD INITIALIZATION
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //Header
        self.headerView.frame.size = CGSize(width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height*0.22)
        self.headerView.layer.shadowRadius = 40
        self.headerView.layer.shadowColor = UIColor.lightGray.cgColor
        self.headerView.layer.shadowOpacity = 1
        //Label position
        headerLightLabel.frame = CGRect(x: 12, y: headerView.frame.maxY-45, width: self.view.frame.width-20, height: headerLightLabel.frame.height)
        headerShadowLabel.frame = CGRect(x: 16, y: headerView.frame.maxY-42, width: self.view.frame.width-20, height: headerLightLabel.frame.height)
        headerView.addSubview(headerShadowLabel)
        headerView.addSubview(headerLightLabel)
        
        //Lines scrollview
        linesScroll.frame.origin = CGPoint(x: 0, y: self.headerView.frame.height+75)
        linesScroll.frame.size = CGSize(width: UIScreen.main.bounds.width, height: 170)
        
        self.linesTitle.frame = CGRect(x: 16, y: self.headerView.frame.maxY+50, width: self.linesScroll.frame.width, height: 23)
        
        let sortedLines = TransportData.lines.sorted(by: { $0.displayId < $1.displayId})
        
        for i in 0..<sortedLines.count {
            if i >= sortedLines.count { break }
            let line = sortedLines[i]
            
            let tap = UITapGestureRecognizer(target: self, action: #selector(handleTap(sender:)))
            let lineCard = UILineCard.init(frame: CGRect.init(x: i*150+15+(15*i), y: 5, width: 150, height: 160), line: line)
            lineCard.addGestureRecognizer(tap)
            lineCards.append(lineCard)
            self.linesScroll.addSubview(lineCard)
            self.linesScroll.contentSize = CGSize(width: i*150+15+(15*i)+150+15, height: 170)
        }
        
        //Station list
        self.stationsTitle.frame.origin = CGPoint(x: 16, y: self.linesScroll.frame.maxY+20)
        self.stationsScroll.frame.origin = CGPoint(x: 0, y: self.linesScroll.frame.maxY+50)
        self.stationsScroll.frame.size = CGSize(width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height-self.stationsScroll.frame.minY)
        
        let refLocation = self.mainScrollView.userLocation != nil ? self.mainScrollView.userLocation : TransportData.getStopZoneById(stopZoneId: 308)!.coords
        let sortedStations = TransportData.stopZones.sorted(by: { refLocation!.distance(from: $0.coords) < refLocation!.distance(from: $1.coords) })
        
        for i in 0..<12 {
            if i >= sortedStations.count { break }
            
            let tap = UITapGestureRecognizer(target: self, action: #selector(handleStationTap(sender:)))
            let distance = self.mainScrollView.userLocation == nil ? 1000.0 : Double((refLocation?.distance(from: sortedStations[i].coords))!)
            let stationCard = UILightStationCard.init(frame: CGRect.init(x: 16, y: (50+15)*i, width: Int(UIScreen.main.bounds.width)-32, height: 50), station: sortedStations[i], distance: distance)
            stationCard.addGestureRecognizer(tap)
            self.stationsScroll.addSubview(stationCard)
            self.stationCards.append(stationCard)
            self.stationsScroll.contentSize = CGSize(width: Int(self.stationsScroll.frame.width), height: (50+15)*i+50+15)
        }

        //Navigation
        self.navigationController?.setNavigationBarHidden(true, animated: false)
        self.navigationController?.interactivePopGestureRecognizer?.delegate = self
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //MARK: - CLICKS
    
    @objc func handleStationTap(sender: UITapGestureRecognizer) {
        let clickLoc = sender.location(in: self.stationsScroll)
        
        print(clickLoc)
        for stationCard in self.stationCards {
            print(stationCard.frame)
            if clickLoc.x < stationCard.frame.minX || clickLoc.x > stationCard.frame.maxX { continue }
            if clickLoc.y < stationCard.frame.minY || clickLoc.y > stationCard.frame.maxY { continue }
            
            ViewMaker.createStationPopUpFromResearcherView(view: self, researcherView: self, station: stationCard.station!)
            break
        }
    }
    
    @objc func handleTap(sender: UITapGestureRecognizer? = nil) {
        // handling code
        let card = self.lineCards[0]
        if (card.animState == 0) {
            self.view.addSubview(card)
            card.frame = CGRect.init(x: 15, y: 150+5, width: card.frame.width, height: card.frame.height)
            for label in card.destinationsLabels {
                label.removeFromSuperview()
            }
            UIView.animate(withDuration: 0.55, delay: 0.0, options: [.curveEaseInOut], animations: {
                card.frame.origin = CGPoint(x: 0, y: 0)
                card.frame.size = CGSize(width: UIScreen.main.bounds.size.width, height: UIScreen.main.bounds.size.height*0.22)
                card.logo?.panel.frame.origin = CGPoint(x: 25, y: 50)
                card.logo?.panel.transform = CGAffineTransform(scaleX: 1.45, y: 1.45)
                card.layer.cornerRadius = 0
            }) { (value: Bool) in
                card.animState = 1
                print("animation finished.")
            }
        } else if (card.animState == 1) {
            UIView.animate(withDuration: 0.55, delay: 0.0, options: [.curveEaseInOut], animations: {
                card.frame.origin = CGPoint(x: 15, y: 5)
                card.frame.size = CGSize(width: 150, height: 160)
                card.logo!.panel.frame.origin = CGPoint(x: 5, y: 5)
                card.logo!.panel.transform = CGAffineTransform.identity
                card.layer.cornerRadius = 15
                self.linesScroll.addSubview(card)
            }) { (value: Bool) in
                card.animState = 0
                print("animation finished.")
                //self.linesScroll.addSubview(card)
            }
        }
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
