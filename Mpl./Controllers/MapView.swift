//
//  MapView.swift
//  Mpl.
//
//  Created by Darius Martin on 23/01/2018.
//  Copyright © 2018 Darius MARTIN. All rights reserved.
//

import UIKit
import Mapbox
import os.log

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

class ServicePointAnnotation: MGLPointAnnotation {
    
    var type: ServiceType
    var service: Any?
    
    init(type: ServiceType, serviceData: Any?) {
        self.type = type
        self.service = serviceData
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
    
    func initServiceAnnotations(mapView: MGLMapView) {
        //Parkings
        for parking in ParkingData.getParkings() {
            let annotation = ServicePointAnnotation(type: .PARKING, serviceData: parking)
            annotation.coordinate = parking.location.coordinate
            annotation.title = parking.name
            mapView.addAnnotation(annotation)
        }
        //BikeStations
        BikeData.updateIfNeeded { (success) in
            for bike in BikeData.getStations() {
                let annotation = ServicePointAnnotation(type: .BIKE, serviceData: bike)
                annotation.coordinate = bike.location.coordinate
                annotation.title = bike.name
                mapView.addAnnotation(annotation)
            }
        }
    }
    
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
        let mapView = MGLMapView(frame: view.bounds, styleURL: MGLStyle.lightStyleURL())
        mapView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        mapView.setCenter(CLLocationCoordinate2D(latitude: 43.610769, longitude: 3.876716), zoomLevel: 12.5, animated: false)
        mapView.showsUserLocation = true
        mapView.delegate = self
        mapView.minimumZoomLevel = 10
        mapView.maximumZoomLevel = 18
        self.mapBoxView = mapView
        self.view.addSubview(mapView)
        
        //Stations
        //let linesToDisp = TransportData.lines.filter({$0.type == .TRAMWAY})
        //self.initStationAnnotations(mapView: mapView, lines: linesToDisp)
        
        //Services
        //self.initServiceAnnotations(mapView: mapView)
        
        //Creating header gradient
        header.backgroundColor = gradientBotColor
        gradient.frame = header.bounds
        gradient.colors = [gradientTopColor.cgColor, gradientBotColor.cgColor]
        gradient.startPoint = CGPoint(x: 0, y: 0)
        gradient.endPoint = CGPoint(x: 1, y: 1)
        header.layer.insertSublayer(gradient, at: 0)
        self.view.addSubview(header)
    }

    /*
    **  ANNOTATION DISPLAY
    */
    
    //MARK: - SETUP DISPLAY
    
    func mapView(_ mapView: MGLMapView, didFinishLoading style: MGLStyle) {
        os_log("Displaying lines on map...", type: .info)
        self.displayLines(mapView: mapView, layersData: MapData.getAllLines())
        os_log("Displaying stations on map...", type: .info)
        self.displayStations(mapView: mapView, features: MapData.getAllStations())
    }
    
    //MARK: - LINES LAYERS
    
    func displayLines(mapView: MGLMapView, layersData: [(line: Line, feature: MGLPolylineFeature)]) {
        guard let style = mapView.style else { return }
        //Sorting features
        var tramlines_features: [MGLPolylineFeature] = []
        var buslines_features: [MGLPolylineFeature] = []
        
        for layerData in layersData {
            if layerData.line.type == .TRAMWAY {
                tramlines_features.append(layerData.feature)
            } else {
                buslines_features.append(layerData.feature)
            }
        }
        
        //Sources
        let tramlines_source = MGLShapeSource(identifier: "tam-tram-lines", features: tramlines_features, options: nil)
        let buslines_source = MGLShapeSource(identifier: "tam-bus-lines", features: buslines_features, options: nil)
        style.addSource(tramlines_source)
        style.addSource(buslines_source)
        
        //Layers
        self.setTramLinesLayer(mapStyle: style, source: tramlines_source)
        self.setBusLinesLayer(mapStyle: style, source: buslines_source)
    }
    
    //MARK: - LINES LAYERS INITIALIZERS
    
    func setBusLinesLayer(mapStyle: MGLStyle, source: MGLShapeSource) {
        let buslines = MGLLineStyleLayer(identifier: "buslines", source: source)
        
        buslines.minimumZoomLevel = 12.6
        buslines.lineJoin = MGLStyleValue(rawValue: NSValue(mglLineJoin: .round))
        buslines.lineCap = MGLStyleValue(rawValue: NSValue(mglLineCap: .round))
        buslines.lineColor = MGLStyleValue(interpolationMode: .identity, sourceStops: nil, attributeName: "lineColor", options: nil)
        buslines.lineWidth = MGLStyleValue(interpolationMode: .exponential, cameraStops: [12: MGLStyleValue(rawValue: 2 as NSNumber), 18: MGLStyleValue(rawValue: 4 as NSNumber)], options: nil)
        mapStyle.addLayer(buslines)
    }
    
    func setTramLinesLayer(mapStyle: MGLStyle, source: MGLShapeSource) {
        let tramlines = MGLLineStyleLayer(identifier: "tramlines", source: source)
        
        tramlines.minimumZoomLevel = 8
        tramlines.lineJoin = MGLStyleValue(rawValue: NSValue(mglLineJoin: .round))
        tramlines.lineCap = MGLStyleValue(rawValue: NSValue(mglLineCap: .round))
        tramlines.lineColor = MGLStyleValue(interpolationMode: .identity, sourceStops: nil, attributeName: "lineColor", options: nil)
        tramlines.lineWidth = MGLStyleValue(interpolationMode: .exponential, cameraStops: [12: MGLStyleValue(rawValue: 4 as NSNumber), 18: MGLStyleValue(rawValue: 8 as NSNumber)], options: nil)
        mapStyle.addLayer(tramlines)
    }
    
    //MARK: - DISPLAY STATION FEATURES
    
    func displayStations(mapView: MGLMapView, features: [[MGLPointFeature]]) {
        guard let style = mapView.style else { return }
        if features.count < 4 { return }
        
        //Setting data source
        let simplebus_source = MGLShapeSource(identifier: "tam-bus-simple", features: features[3], options: nil)
        let mainbus_source = MGLShapeSource(identifier: "tam-bus-main", features: features[2], options: nil)
        let simpletram_source = MGLShapeSource(identifier: "tam-tram-simple", features: features[1], options: nil)
        let maintram_source = MGLShapeSource(identifier: "tam-tram-main", features: features[0], options: nil)
        style.addSource(simplebus_source)
        style.addSource(mainbus_source)
        style.addSource(simpletram_source)
        style.addSource(maintram_source)
        
        //layers
        style.addLayer(self.getSimpleBusLayer(source: simplebus_source))
        style.addLayer(self.getMainBusLayer(source: mainbus_source))
        self.setSimpleTramLayer(mapStyle: style, source: simpletram_source)
        self.setMainTramLayer(mapStyle: style, source: maintram_source)
    }
    
    //MARK: - LAYERS INITIALIZATION
    
    func getSimpleBusLayer(source: MGLShapeSource) -> MGLCircleStyleLayer {
        let simplebus = MGLCircleStyleLayer(identifier: "simplebus", source: source)
        
        simplebus.minimumZoomLevel = 13.5
        simplebus.circleColor = MGLStyleValue(interpolationMode: .identity, sourceStops: nil, attributeName: "lineColor", options: nil)
        simplebus.circleStrokeColor = MGLStyleValue(rawValue: .white)
        simplebus.circleStrokeWidth = MGLStyleValue(interpolationMode: .exponential, cameraStops: [14: MGLStyleValue(rawValue: 1.5 as NSNumber), 22: MGLStyleValue(rawValue: 3 as NSNumber)], options: nil)
        simplebus.circleRadius = MGLStyleValue(interpolationMode: .exponential, cameraStops: [14: MGLStyleValue(rawValue: 4 as NSNumber), 22: MGLStyleValue(rawValue: 8 as NSNumber)], options: nil)
        return simplebus
    }
    
    func getMainBusLayer(source: MGLShapeSource) -> MGLCircleStyleLayer {
        let mainbus = MGLCircleStyleLayer(identifier: "mainbus", source: source)
        
        mainbus.minimumZoomLevel = 13.5
        mainbus.circleColor = MGLStyleValue(rawValue: .white)
        mainbus.circleStrokeColor = MGLStyleValue(rawValue: .black)
        mainbus.circleStrokeWidth = MGLStyleValue(interpolationMode: .exponential, cameraStops: [14: MGLStyleValue(rawValue: 2 as NSNumber), 22: MGLStyleValue(rawValue: 4 as NSNumber)], options: nil)
        mainbus.circleRadius = MGLStyleValue(interpolationMode: .exponential, cameraStops: [14: MGLStyleValue(rawValue: 3.5 as NSNumber), 22: MGLStyleValue(rawValue: 7 as NSNumber)], options: nil)
        return mainbus
    }
    
    func setSimpleTramLayer(mapStyle: MGLStyle, source: MGLShapeSource) {
        let simpletram = MGLCircleStyleLayer(identifier: "simpletram", source: source)
        let simpletram_names = MGLSymbolStyleLayer(identifier: "simpletram-names", source: source)
        
        //Zoom level
        simpletram.minimumZoomLevel = 11.5
        simpletram_names.minimumZoomLevel = 12.5
        
        //Circles
        simpletram.circleColor = MGLStyleValue(interpolationMode: .identity, sourceStops: nil, attributeName: "lineColor", options: nil)
        simpletram.circleStrokeColor = MGLStyleValue(rawValue: .white)
        simpletram.circleStrokeWidth = MGLStyleValue(interpolationMode: .exponential, cameraStops: [13: MGLStyleValue(rawValue: 2.5 as NSNumber), 22: MGLStyleValue(rawValue: 5 as NSNumber)], options: nil)
        simpletram.circleRadius = MGLStyleValue(interpolationMode: .exponential, cameraStops: [13: MGLStyleValue(rawValue: 6 as NSNumber), 22: MGLStyleValue(rawValue: 12.0 as NSNumber)], options: nil)
        
        //Text
        simpletram_names.text = MGLStyleValue(interpolationMode: .identity, sourceStops: nil, attributeName: "name", options: nil)
        simpletram_names.textColor = MGLStyleValue(interpolationMode: .exponential, cameraStops: [12.5: MGLStyleValue(rawValue: .clear), 13: MGLStyleValue(rawValue: .darkGray)], options: nil)
        simpletram_names.textHaloColor = MGLStyleValue(interpolationMode: .exponential, cameraStops: [12.5: MGLStyleValue(rawValue: .clear), 13: MGLStyleValue(rawValue: .white)], options: nil)
        simpletram_names.textFontSize = MGLStyleValue(interpolationMode: .exponential, cameraStops: [12: MGLStyleValue(rawValue: 9 as NSNumber), 16: MGLStyleValue(rawValue: 15 as NSNumber)], options: nil)
        simpletram_names.textTranslation = MGLStyleValue(interpolationMode: .exponential, cameraStops: [13: MGLStyleValue(rawValue: NSValue(cgVector: CGVector(dx: 10, dy: 0))), 22: MGLStyleValue(rawValue: NSValue(cgVector: CGVector(dx: 20, dy: 0)))], options: nil)
        simpletram_names.textHaloWidth = MGLStyleValue(rawValue: 2)
        simpletram_names.textJustification = MGLStyleValue(rawValue: NSValue(mglTextJustification: .left))
        simpletram_names.textAnchor = MGLStyleValue(rawValue: NSValue(mglTextAnchor: .left))
        simpletram_names.textColorTransition = MGLTransition(duration: 2.0, delay: 0.0)
        mapStyle.addLayer(simpletram)
        mapStyle.addLayer(simpletram_names)
    }
    
    func setMainTramLayer(mapStyle: MGLStyle, source: MGLShapeSource) {
        let maintram = MGLCircleStyleLayer(identifier: "maintram", source: source)
        let maintram_names = MGLSymbolStyleLayer(identifier: "maintram-names", source: source)
        
        //Zoom level
        maintram.minimumZoomLevel = 11.5
        maintram_names.minimumZoomLevel = 11.5
        
        //Circles
        maintram.circleColor = MGLStyleValue(rawValue: .white)
        maintram.circleStrokeColor = MGLStyleValue(rawValue: .black)
        maintram.circleStrokeWidth = MGLStyleValue(interpolationMode: .exponential, cameraStops: [13: MGLStyleValue(rawValue: 3.5 as NSNumber), 22: MGLStyleValue(rawValue: 7 as NSNumber)], options: nil)
        maintram.circleRadius = MGLStyleValue(interpolationMode: .exponential, cameraStops: [13: MGLStyleValue(rawValue: 5 as NSNumber), 22: MGLStyleValue(rawValue: 10 as NSNumber)], options: nil)
        mapStyle.addLayer(maintram)
        
        //Text
        maintram_names.text = MGLStyleValue(interpolationMode: .identity, sourceStops: nil, attributeName: "name", options: nil)
        maintram_names.textColor = MGLStyleValue(interpolationMode: .exponential, cameraStops: [11.5: MGLStyleValue(rawValue: .clear), 12: MGLStyleValue(rawValue: .black)], options: nil)
        maintram_names.textHaloColor = MGLStyleValue(interpolationMode: .exponential, cameraStops: [11.5: MGLStyleValue(rawValue: .clear), 12: MGLStyleValue(rawValue: .white)], options: nil)
        maintram_names.textFontSize = MGLStyleValue(interpolationMode: .exponential, cameraStops: [11: MGLStyleValue(rawValue: 11 as NSNumber), 16: MGLStyleValue(rawValue: 17 as NSNumber)], options: nil)
        maintram_names.textTranslation = MGLStyleValue(interpolationMode: .exponential, cameraStops: [13: MGLStyleValue(rawValue: NSValue(cgVector: CGVector(dx: 10, dy: 0))), 22: MGLStyleValue(rawValue: NSValue(cgVector: CGVector(dx: 20, dy: 0)))], options: nil)
        maintram_names.textHaloWidth = MGLStyleValue(rawValue: 2)
        maintram_names.textJustification = MGLStyleValue(rawValue: NSValue(mglTextJustification: .left))
        maintram_names.textAnchor = MGLStyleValue(rawValue: NSValue(mglTextAnchor: .left))
        maintram_names.textColorTransition = MGLTransition(duration: 2.0, delay: 0.0)
        mapStyle.addLayer(maintram_names)
    }
    
    //MARK: - ANNOTATION VIEWS
    
    func mapView(_ mapView: MGLMapView, viewFor annotation: MGLAnnotation) -> MGLAnnotationView? {
        var annotView: MGLAnnotationView?
        
        if let stationAnnotation = annotation as? StationPointAnnotation {
            annotView = displayViewOf(mapView: mapView, stationAnnotation: stationAnnotation)
        } else if let serviceAnnotation = annotation as? ServicePointAnnotation {
            annotView = displayViewOf(mapView: mapView, serviceAnnotation: serviceAnnotation)
        }
        
        if annotView == nil { mapView.removeAnnotation(annotation) }
        return annotView
    }
    
    //Service Annotation Display
    
    func displayViewOf(mapView: MGLMapView, serviceAnnotation: ServicePointAnnotation) -> MGLAnnotationView? {
        let reuseIdentifier: String
        var annotationView: MGLAnnotationView?
        
        switch serviceAnnotation.type {
        case .PARKING:
            reuseIdentifier = "parking"
            annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: reuseIdentifier)
            if annotationView == nil {
                annotationView = MGLAnnotationView(reuseIdentifier: reuseIdentifier)
                annotationView!.frame = CGRect(x: 0, y: 0, width: 15, height: 15)
                annotationView!.backgroundColor = UIColor(red: 0, green: 168/255, blue: 1.0, alpha: 0.8)
                let logoLabel = UILabel(frame: CGRect(x: 0, y: 0, width: 15, height: 15))
                logoLabel.text = "P"
                logoLabel.textColor = .white
                logoLabel.textAlignment = .center
                logoLabel.font = UIFont(name: "Ubuntu-Bold", size: 12)
                annotationView!.addSubview(logoLabel)
            }
        case .BIKE:
            reuseIdentifier = "bike"
            annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: reuseIdentifier)
            if annotationView == nil {
                annotationView = MGLAnnotationView(reuseIdentifier: reuseIdentifier)
                annotationView!.frame = CGRect(x: 0, y: 0, width: 15, height: 15)
                annotationView!.backgroundColor = UIColor(red: 241/255, green: 196/255, blue: 15/255, alpha: 0.8)
                let logoImageMargin = annotationView!.frame.width * 0.15
                let logoImageSize = annotationView!.frame.width - (logoImageMargin * 2)
                let logoImage = UIImageView(frame: CGRect(x: logoImageMargin, y: logoImageMargin, width: logoImageSize, height: logoImageSize))
                logoImage.image = #imageLiteral(resourceName: "man-cycling")
                annotationView!.addSubview(logoImage)
            }
        }
        return annotationView
    }
    
    //Station Annotation Display
    
    func displayViewOf(mapView: MGLMapView, stationAnnotation: StationPointAnnotation) -> MGLAnnotationView? {
        let lines: [Line] = stationAnnotation.lines
        let reuseIdentifier: String
        var annotationView: MGLAnnotationView?
        
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
