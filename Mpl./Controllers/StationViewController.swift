//
//  StationViewController.swift
//  Mpl.
//
//  Created by Darius Martin on 02/01/2018.
//  Copyright © 2018 Darius MARTIN. All rights reserved.
//

import UIKit
import MarqueeLabel

class StationViewController: UIViewController {

    var station: StopZone? = nil
    
    @IBOutlet weak var favButton: UIButton!
    @IBOutlet var blurClickOutlet: UITapGestureRecognizer!
    @IBOutlet weak var stationPanel: UIAdvanced!
    @IBOutlet weak var cardHeader: UIView!
    @IBOutlet weak var stationName: MarqueeLabel!
    @IBOutlet weak var blurEffectView: UIVisualEffectView!
    @IBOutlet weak var directionsPanel: UIScrollView!
    
    var refresher: Timer!
    
    var oldView: UIViewController?
    var effect: UIVisualEffect!
    
    var homeView: HomeView? = nil
    var researchView: ResearcherViewController? = nil
    //var tableView: StationsTableViewController? = nil
    
    //MARK: Remove navigation bar in main view
    
    override func viewWillAppear(_ animated: Bool) {
        appearAnimation()
        super.viewWillAppear(animated)
    }
    
    @IBAction func blurClick(_ sender: Any) {
        let loc = blurClickOutlet.location(in: blurEffectView)

        if loc.x >= stationPanel.frame.minX && loc.x <= stationPanel.frame.maxX {
            if loc.y >= stationPanel.frame.minY && loc.y <= stationPanel.frame.maxY {
                return
            }
        }
        disappearAnimation(0)
    }
    
    @IBAction func favButtonClicked(_ sender: Any) {
        let haptic: UIImpactFeedbackGenerator = UIImpactFeedbackGenerator()
        
        if (station == nil) { return }
        haptic.prepare()
        haptic.impactOccurred()
        //Setting favorite (or not!)
        if UserData.isFavorite(self.station!) {
            UserData.removeFavStation(station: station!)
            favButton.setImage(#imageLiteral(resourceName: "star"), for: .normal)
        } else {
            UserData.addFavStation(station: station!)
            favButton.setImage(#imageLiteral(resourceName: "star_filled"), for: .normal)
        }
        //Updating old view
        if homeView != nil {
            homeView!.update()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let viewWidth = self.view.frame.width
        
        //Saving blur effect
        effect = blurEffectView.effect
        blurEffectView.effect = nil
        //Center popup
        self.view.addSubview(blurEffectView)
        stationPanel.frame = CGRect(x: viewWidth*0.05, y: (self.view.frame.height/2)-(self.stationPanel.frame.height/2), width: viewWidth*0.9, height: self.stationPanel.frame.height)
        
        //Header of card
        cardHeader.frame = CGRect(x: 0, y: 0, width: self.stationPanel.frame.width, height: self.cardHeader.frame.height)
        cardHeader.roundCorners([.topLeft, .topRight], radius: 16)
        
        //Directions panel
        directionsPanel.backgroundColor = .clear
        directionsPanel.frame = CGRect(x: 0, y: cardHeader.frame.maxY, width: self.stationPanel.frame.width, height: stationPanel.frame.height*0.75)
        stationPanel.addSubview(cardHeader)
        stationPanel.addSubview(directionsPanel)
        stationPanel.backgroundColor = UIColor(red: 1, green: 1, blue: 1, alpha: 0.6)
        
        //Update
        self.refresher = Timer.scheduledTimer(timeInterval: 5, target: self, selector: #selector(self.update), userInfo: nil, repeats: true)
        //Delay
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            self.update()
        }
    }
    
    @objc func update() {
        if (self.station == nil) { return }
        for view in self.directionsPanel.subviews {
            view.removeFromSuperview()
        }
        self.station!.updateTimetable(completion: { (result: Bool) in
            if result == true {
                self.update()
            }
        })
        if (self.station!.schedules.count == 0) {
            let waitLabel = UILabel(frame: CGRect(x: 0, y: 15, width: self.directionsPanel.frame.width, height: 25))
            waitLabel.text = self.station!.updateState == 1 ? "..." : "Service terminé."
            waitLabel.textAlignment = .center
            waitLabel.textColor = UIColor.gray
            waitLabel.font = UIFont(name: "Ubuntu-Bold", size: CGFloat(18))
            self.directionsPanel.addSubview(waitLabel)
        } else {
            self.displayDirections()
        }
        
    }
    
    func displayDirections() {
        let nextArrivals: [(line: Line, dest: Stop, times: [Int])]
        let arrCellWidth = self.stationPanel.frame.width/3
        var nbDirections = 0

        if (station == nil) { return }
        nextArrivals = self.station!.getShedulesByDirection()
        for arrival in nextArrivals {
            directionsPanel.addSubview((UILineLogo(line: arrival.line, rect: CGRect(x: 15, y: 100*nbDirections+15, width: 40, height: 28)).panel))
            let dirLabel = MarqueeLabel(frame: CGRect(x: 15+40+26, y: 100*nbDirections+13, width: Int(directionsPanel.frame.width-(30+40+25)), height: 28), duration: 6.0, fadeLength: 3.0)
            dirLabel.textColor = UIColor(red: 50/255.0, green: 50/255.0, blue: 50/255.0, alpha: 1.0)
            dirLabel.text = arrival.dest.directionName.uppercased()
            dirLabel.font = UIFont(name: "Ubuntu-Bold", size: CGFloat(19))
            directionsPanel.addSubview(dirLabel)
            var timeIndex = 0
            for time in arrival.times {
                if (time < 2) {
                    //Proche panel
                    let arrNearPanel = UIView(frame: CGRect(x: 15+arrCellWidth*CGFloat(timeIndex), y: CGFloat(100*nbDirections+63), width: 80, height: 25))
                    arrNearPanel.backgroundColor = .white
                    arrNearPanel.roundCorners([.allCorners], radius: 15)
                    //Near icon
                    let near: UIImageView = UIImageView(frame: CGRect(x: 5, y: 6, width: 14, height: 14))
                    near.animationImages = [#imageLiteral(resourceName: "near"), #imageLiteral(resourceName: "near15"), #imageLiteral(resourceName: "near2"), #imageLiteral(resourceName: "near25"), #imageLiteral(resourceName: "near3"), #imageLiteral(resourceName: "near35"), #imageLiteral(resourceName: "near4"), #imageLiteral(resourceName: "near45"), #imageLiteral(resourceName: "near5"), #imageLiteral(resourceName: "near55"), #imageLiteral(resourceName: "near6"), #imageLiteral(resourceName: "near55"), #imageLiteral(resourceName: "near5"), #imageLiteral(resourceName: "near45"), #imageLiteral(resourceName: "near4"), #imageLiteral(resourceName: "near35"), #imageLiteral(resourceName: "near3"), #imageLiteral(resourceName: "near25"), #imageLiteral(resourceName: "near2"), #imageLiteral(resourceName: "near15")]
                    near.animationDuration = 1.2
                    near.startAnimating()
                    //Proche label
                    let arrTimeLabel = UILabel(frame: CGRect(x: 22, y: -1, width: arrNearPanel.frame.width-15, height: 25))
                    arrTimeLabel.text = "proche"
                    arrTimeLabel.textColor = UIColor(red: 120.0/255, green: 169.0/255, blue: 66.0/255, alpha: 1.0)
                    arrTimeLabel.font = UIFont(name: "Ubuntu-Bold", size: CGFloat(15))
                    arrNearPanel.addSubview(near)
                    arrNearPanel.addSubview(arrTimeLabel)
                    directionsPanel.addSubview(arrNearPanel)
                    
                } else {
                    //Normal display
                    let arrTimeLabel = UILabel(frame: CGRect(x: 15+arrCellWidth*CGFloat(timeIndex), y: CGFloat(100*nbDirections+63), width: arrCellWidth, height: 25))
                    arrTimeLabel.text = "\(time) mins"
                    arrTimeLabel.font = UIFont(name: "Ubuntu-Bold", size: CGFloat(16))
                    arrTimeLabel.textColor = .darkGray
                    directionsPanel.addSubview(arrTimeLabel)
                }
                timeIndex += 1
            }
            nbDirections += 1
        }
        directionsPanel.contentSize = CGSize(width: Int(directionsPanel.frame.width), height: 100*nbDirections+15)
    }

    @IBAction func leftQuit(_ sender: Any) {
        disappearAnimation(1)
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func closePopUp(_ sender: Any)
    {
        disappearAnimation(0)
    }

    func appearAnimation()
    {
        let haptic: UISelectionFeedbackGenerator = UISelectionFeedbackGenerator()
        
        haptic.prepare()
        haptic.selectionChanged()
        self.view.alpha = 0.0
        self.stationPanel.transform = CGAffineTransform(scaleX: 0.7, y: 0.7)
        UIView.animate(withDuration: 0.3, animations: {
            self.blurEffectView.effect = self.effect
            self.view.alpha = 1.0
            self.stationPanel.transform = CGAffineTransform.identity
        })
    }
    
    func disappearAnimation(_ style: Int)
    {
        let haptic: UISelectionFeedbackGenerator = UISelectionFeedbackGenerator()
        self.refresher = nil
        
        haptic.prepare()
        haptic.selectionChanged()
        if style == 0 {
            UIView.animate(withDuration: 0.3, animations: {
                self.stationPanel.transform = CGAffineTransform(scaleX: 0.7, y: 0.7)
                self.view.alpha = 0
                self.blurEffectView.effect = nil
            }) { (success:Bool) in
                if self.oldView != nil {
                    self.oldView?.navigationController?.setNavigationBarHidden(false, animated: false)
                }
                self.dismiss(animated: false, completion: nil)
            }
        } else {
            UIView.animate(withDuration: 0.3, animations: {
                self.stationPanel.frame = CGRect(x: self.stationPanel.frame.minX+35, y: self.stationPanel.frame.minY, width: self.stationPanel.frame.width, height: self.stationPanel.frame.height)
                self.view.alpha = 0
                self.blurEffectView.effect = nil
            }) { (success:Bool) in
                self.dismiss(animated: false, completion: nil)
            }
        }
    }

}
