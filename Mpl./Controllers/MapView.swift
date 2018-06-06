//
//  MapView.swift
//  Mpl.
//
//  Created by Darius Martin on 23/01/2018.
//  Copyright © 2018 Darius MARTIN. All rights reserved.
//

import UIKit
import Mapbox

class StationPointAnnotation: MGLPointAnnotation {
    var station: StopZone
    var lines: [Line]
    
    init(_ station: StopZone, lines: [Line]) {
        self.station = station
        self.lines = lines
        super.init()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

class MapView: UIViewController, CLLocationManagerDelegate, MGLMapViewDelegate {

    @IBOutlet weak var header: UIAdvanced!
    @IBOutlet weak var mapBack: UIView!
    var mapBoxView: MGLMapView?
    
    let gradient = CAGradientLayer()
    
    func initStationAnnotations(mapView: MGLMapView, lines: [Line]) {
        DispatchQueue.global(qos: .background).async {
            var stations: [(lines: [Line], stopZone: StopZone)] = []
            
            for line in lines {
                for stopZone in TransportData.getLineStopZones(line: line) {
                    var tmp = stations.filter({$0.stopZone.id == stopZone.id})
                    
                    if tmp.isEmpty {
                        stations.append((lines: [line], stopZone: stopZone))
                    } else {
                        tmp[0].lines.append(line)
                    }
                }
            }
            for station in stations {
                let tmplocs = TransportData.getStopZoneLocationsByLine(stopZone: station.stopZone)
            
                for loc in tmplocs.sorted(by: {$0.lines.count < $1.lines.count}) {
                    let wantedLines = loc.lines.filter({lines.contains($0)}).sorted(by: {$0.displayId > $1.displayId})
                    
                    if wantedLines.count == 0 { continue }
                    DispatchQueue.main.async {
                        let annotation = StationPointAnnotation(station.stopZone, lines: wantedLines)
                        annotation.coordinate = loc.location
                        annotation.title = station.stopZone.name
                        mapView.addAnnotation(annotation)
                    }
                }
            }
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        let gradientTopColor = UIColor.init(red: 254.0/255.0, green: 106.0/255, blue: 166.0/255.0, alpha: 1.0)
        let gradientBotColor = UIColor.init(red: 235.0/255.0, green: 61.0/255, blue: 145.0/255.0, alpha: 1.0)
        
        //Change header height percentage
        header.frame = CGRect(x: header.frame.minX, y: header.frame.minY, width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height*0.22)
        
        //Map
        let url = URL(string: "mapbox://styles/slaymd/cjdj47fr31ex32sqp8dy4h9m7")
        let mapView = MGLMapView(frame: view.bounds, styleURL: url)
        mapView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        mapView.setCenter(CLLocationCoordinate2D(latitude: 43.610769, longitude: 3.876716), zoomLevel: 11, animated: false)
        mapView.showsUserLocation = true
        mapView.delegate = self
        self.mapBoxView = mapView
        self.view.addSubview(mapView)
        
        //Stations
        let linesToDisp = TransportData.lines.filter({$0.type == .TRAMWAY})
        
        self.initStationAnnotations(mapView: mapView, lines: linesToDisp)
        
        //Creating header gradient
        header.backgroundColor = gradientBotColor
        gradient.frame = header.bounds
        gradient.colors = [gradientTopColor.cgColor, gradientBotColor.cgColor]
        gradient.startPoint = CGPoint(x: 0, y: 0)
        gradient.endPoint = CGPoint(x: 1, y: 1)
        header.layer.insertSublayer(gradient, at: 0)
        self.view.addSubview(header)
    }
    
    func mapView(_ mapView: MGLMapView, viewFor annotation: MGLAnnotation) -> MGLAnnotationView? {
        let stationAnnotation = annotation as? StationPointAnnotation
        let lines: [Line]
        let reuseIdentifier: String
        var annotationView: MGLAnnotationView?
        
        if (stationAnnotation == nil) { return nil }
        lines = stationAnnotation!.lines
        
        if (lines.count > 1) {
            //Multi-line
            reuseIdentifier = "mono-line"
            annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: reuseIdentifier)

            if (annotationView == nil) {
                annotationView = MGLAnnotationView(reuseIdentifier: reuseIdentifier)
                annotationView?.frame = CGRect(x: 0, y: 0, width: 15, height: 15)
                annotationView?.layer.borderColor = UIColor.black.cgColor
                annotationView?.layer.borderWidth = 4.0
                annotationView!.backgroundColor = UIColor.white
            }
        } else if (lines.count == 1) {
            //Mono-color
            reuseIdentifier = lines[0].shortName
            annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: reuseIdentifier)
            
            if (annotationView == nil) {
                annotationView = MGLAnnotationView(reuseIdentifier: reuseIdentifier)
                annotationView?.frame = CGRect(x: 0, y: 0, width: 10, height: 10)
                annotationView?.layer.cornerRadius = (annotationView?.frame.size.width)! / 2
                annotationView!.backgroundColor = lines[0].bgColor
            }
        } else {
            mapView.removeAnnotation(annotation)
            return nil
        }
        return annotationView
    }
    
    //MARK: - ANNOTATION CLICK AND POP-UP STATION
    
    func mapView(_ mapView: MGLMapView, didSelect annotation: MGLAnnotation) {
        if annotation.isKind(of: StationPointAnnotation.classForCoder()) {
            let stationAnnot = annotation as? StationPointAnnotation
            
            if (stationAnnot == nil) { return }
            let stationPopUp: StationPopUpView = StationPopUpView.init(nibName: "StationPopUpView", bundle: nil, station: stationAnnot!.station, mainView: self)
            stationPopUp.modalPresentationStyle = .overCurrentContext
            self.present(stationPopUp, animated: false, completion: nil)
        }
        mapView.deselectAnnotation(annotation, animated: false)
    }

}
