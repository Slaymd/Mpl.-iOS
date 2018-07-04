//
//  MapData.swift
//  Mpl.
//
//  Created by Darius Martin on 13/06/2018.
//  Copyright © 2018 Darius MARTIN. All rights reserved.
//

import Foundation
import Mapbox

extension CLLocation {
    
    // MARK: - Middle of two CLLocation
    
    func middle(with location: CLLocation) -> CLLocation {
        
        let lon1 = coordinate.longitude * Double.pi / 180
        let lon2 = location.coordinate.longitude * Double.pi / 180
        let lat1 = coordinate.latitude * Double.pi / 180
        let lat2 = location.coordinate.latitude * Double.pi / 180
        let dLon = lon2 - lon1
        let x = cos(lat2) * cos(dLon)
        let y = cos(lat2) * sin(dLon)
        
        let lat3 = atan2( sin(lat1) + sin(lat2), sqrt((cos(lat1) + x) * (cos(lat1) + x) + y * y) )
        let lon3 = lon1 + atan2(y, cos(lat1) + x)
        
        let center: CLLocation = CLLocation(latitude: lat3 * 180 / Double.pi, longitude: lon3 * 180 / Double.pi)
        return center
    }
}

class MapData {
    
    //MARK: - LINES

    static public func getAllLines() -> [(line: Line, feature: MGLPolylineFeature)] {
        var result: [(line: Line, feature: MGLPolylineFeature)] = []
        let polylines = TransportData.getLinesPolylines()
        
        for line_polyline in polylines {
            var count = 0
            for coordinates in line_polyline.polylines {
                let tmp = (line: line_polyline.line, feature: MGLPolylineFeature(coordinates: coordinates, count: UInt(coordinates.count)))
                tmp.feature.title = line_polyline.line.shortName + " (\(count))"
                tmp.feature.attributes = [
                    "lineTamId": line_polyline.line.tamId,
                    "lineColor": line_polyline.line.bgColor
                ]
                result.append(tmp)
                count += 1
            }
        }
        return result
    }
    
    //TRIPS
    
    static private func getPolyline(from locations: [CLLocation]) -> MGLPolylineFeature {
        var coordinates: [CLLocationCoordinate2D] = []
        let polyline: MGLPolylineFeature
        
        for loc in locations {
            coordinates.append(loc.coordinate)
        }
        polyline = MGLPolylineFeature(coordinates: coordinates, count: UInt(coordinates.count))
        return polyline
    }
    
    static private func getPolyline(from tripSegment: TripSegment) -> MGLPolylineFeature? {
        var coordinates: [CLLocationCoordinate2D] = []
        var polyline: MGLPolylineFeature?
        var index = 0
        
        //No intermediate stops
        if tripSegment.intermediateStops.count == 0 {
            
            if tripSegment.mode == .BUS || tripSegment.mode == .TRAMWAY {
                
                guard let departureStop = tripSegment.departureStop else { return nil }
                guard let arrivalStop = tripSegment.arrivalStop else { return nil }
                
                //getting polyline from departure stop to arrival stop
                let raw_polyline = TransportData.getPolyline(fromStopId: departureStop.id, toStopId: arrivalStop.id, onLineId: tripSegment.line!.id)
                coordinates.append(contentsOf: raw_polyline)
                //If subpolyline wasn't found draw line between two stations
                if raw_polyline.count == 0 {
                    coordinates.append(departureStop.coords.coordinate)
                    coordinates.append(arrivalStop.coords.coordinate)
                }
            } else if tripSegment.mode == .WALK {
                
                guard let departureLoc = tripSegment.departure else { return nil }
                guard let arrivalLoc = tripSegment.arrival else { return nil }
                
                coordinates.append(departureLoc.coordinate)
                coordinates.append(arrivalLoc.coordinate)
            }
            
        }
        
        for interloc in tripSegment.intermediateStops {
            if tripSegment.mode == .BUS || tripSegment.mode == .TRAMWAY {
                if index == 0 {
                    guard let departureStop = tripSegment.departureStop else { continue }
                    guard let firstStop = TransportData.getStop(byTamId: interloc.id) else { continue }
                    //First stop : getting polyline from departure and it
                    let raw_polyline = TransportData.getPolyline(fromStopId: departureStop.id, toStopId: firstStop.id, onLineId: tripSegment.line!.id)
                    coordinates.append(contentsOf: raw_polyline)
                    //If subpolyline wasn't found draw line between two stations
                    if raw_polyline.count == 0 {
                        coordinates.append(departureStop.coords.coordinate)
                        coordinates.append(firstStop.coords.coordinate)
                    }
                } else {
                    guard let lastStop = TransportData.getStop(byTamId: tripSegment.intermediateStops[index-1].id) else { continue }
                    guard let inteStop = TransportData.getStop(byTamId: interloc.id) else { continue }
                    //Middle
                    let raw_polyline = TransportData.getPolyline(fromStopId: lastStop.id, toStopId: inteStop.id, onLineId: tripSegment.line!.id)
                    coordinates.append(contentsOf: raw_polyline)
                    //If subpolyline wasn't found draw line between two stations
                    if raw_polyline.count == 0 {
                        coordinates.append(lastStop.coords.coordinate)
                        coordinates.append(inteStop.coords.coordinate)
                    }
                }
                if index == tripSegment.intermediateStops.count-1 {
                    guard let arrivalStop = tripSegment.arrivalStop else { continue }
                    guard let lastStop = TransportData.getStop(byTamId: interloc.id) else { continue }
                    //Last stop : getting polyline from last stop to arrival stop
                    let raw_polyline = TransportData.getPolyline(fromStopId: lastStop.id, toStopId: arrivalStop.id, onLineId: tripSegment.line!.id)
                    coordinates.append(contentsOf: raw_polyline)
                    //If subpolyline wasn't found draw line between two stations
                    if raw_polyline.count == 0 {
                        coordinates.append(lastStop.coords.coordinate)
                        coordinates.append(arrivalStop.coords.coordinate)
                    }
                }
            } else {
                if index == 0 {
                    //First
                    coordinates.append(tripSegment.departure!.coordinate)
                }
                coordinates.append(interloc.loc.coordinate)
                if index == tripSegment.intermediateStops.count-1 {
                    //Last
                    coordinates.append(tripSegment.arrival!.coordinate)
                }
            }
            index += 1
        }
        if coordinates.count > 0 {
            polyline = MGLPolylineFeature(coordinates: coordinates, count: UInt(coordinates.count))
        }
        return polyline
    }
    
    static private func getPolylines(from trip: Trip) -> [MGLPolylineFeature] {
        var polylines: [MGLPolylineFeature] = []
        
        for segment in trip.segments {
            guard let polyline = self.getPolyline(from: segment) else { continue }
            let lineColor: UIColor
            let lineWidth: Int
            
            //getting line color
            if segment.mode == .BUS || segment.mode == .TRAMWAY {
                guard let line = segment.line else { continue }
                
                lineColor = line.bgColor
                lineWidth = segment.mode == .TRAMWAY ? 4 : 3
            } else {
                lineColor = .lightGray
                lineWidth = 2
            }
            polyline.attributes = [
                "lineColor": lineColor,
                "lineWidth": lineWidth
            ]
            polylines.append(polyline)
        }
        return polylines
    }
    
    static private func getIdentifier(of trip: Trip) -> String {
        let identifier: String = "\(trip.departureTime.formatted)-\(trip.arrivalTime.formatted)-\(trip.distance)-\(trip.duration)"
        
        return identifier
    }
    
    static public func addLayer(of trip: Trip, on mapView: MGLMapView, cameraEdgePadding: UIEdgeInsets?) {
        guard let style = mapView.style else { return }
        let polylines: [MGLPolylineFeature]
        let source: MGLShapeSource
        let triplayer: MGLLineStyleLayer
        
        //Creating polylines from trip segments
        polylines = self.getPolylines(from: trip)
        
        //Creating data source
        source = MGLShapeSource(identifier: "tripsource-" + self.getIdentifier(of: trip), features: polylines, options: nil)
        style.addSource(source)
        
        //Creating layer
        triplayer = MGLLineStyleLayer(identifier: "triplayer-" + self.getIdentifier(of: trip), source: source)
        
        triplayer.minimumZoomLevel = 10
        triplayer.lineJoin = MGLStyleValue(rawValue: NSValue(mglLineJoin: .round))
        triplayer.lineCap = MGLStyleValue(rawValue: NSValue(mglLineCap: .round))
        triplayer.lineColor = MGLStyleValue(interpolationMode: .identity, sourceStops: nil, attributeName: "lineColor", options: nil)
        triplayer.lineWidth = MGLStyleValue(interpolationMode: .identity, sourceStops: nil, attributeName: "lineWidth", options: nil)
        
        //Setting layer
        style.addLayer(triplayer)
        if (trip.segments.first != nil && trip.segments.last != nil) {
            //let bounds = MGLCoordinateBounds(sw: trip.segments.first!.departure!.coordinate, ne: trip.segments.last!.arrival!.coordinate)
            let camera = mapView.cameraThatFitsShape(source.shape!, direction: CLLocationDirection.init(), edgePadding: cameraEdgePadding == nil ? UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10) : cameraEdgePadding!)
            mapView.setCamera(camera, animated: true)
        }
    }
    
    //MARK: - STATIONS
    
    private static func fixLocation(ofStop stop: Stop, onLine line: Line) {
        let fixes: [(String, [Int], Double, Double)] = [("Millénaire", [1], 43.603330, 3.909953),("Mondial 98", [1], 43.602770, 3.903944),
                                                        ("Voltaire", [3], 43.603710, 3.889107),("Gare Saint-Roch", [3,4], 43.605209, 3.879704),
                                                        ("Corum", [2], 43.614452, 3.882029)]
        
        for fix in fixes {
            if stop.name == fix.0 && fix.1.contains(line.tamId) {
                stop.coords = CLLocation(latitude: fix.2, longitude: fix.3)
            }
        }
    }
    
    static public func getAllStationsLocations() -> [(station: StopZone, location: CLLocation, lines: [Line])] {
        var stationLocs: [(station: StopZone, location: CLLocation, lines: [Line])] = []
        
        //Getting location for each stations
        for station in TransportData.stopZones {
            var tmp: [(station: StopZone, location: CLLocation, lines: [Line])] = []
            
            TransportData.updateStopZoneDirections(stopZone: station)
            //Getting location at each station stops
            for stop in station.stops {
                var stopLines: [Line] = []
                var filtered: [(station: StopZone, location: CLLocation, lines: [Line])]
                
                //Getting lines at stop
                for dir in stop.directions {
                    if !stopLines.contains(dir.line) {
                        stopLines.append(dir.line)
                        //Fixing stop location
                        self.fixLocation(ofStop: stop, onLine: dir.line)
                    }
                }
                //Adding location
                filtered = tmp.filter({$0.lines == stopLines})
                if filtered.count == 1 {
                    //Already have a localization, so taking the center location with the new
                    filtered[0].location = filtered[0].location.middle(with: stop.coords)
                } else {
                    //Adding new stop location
                    tmp.append((station: station, location: stop.coords, lines: stopLines))
                }
            }
            stationLocs.append(contentsOf: tmp)
        }
        return stationLocs
    }
    
    static public func getAllStations() -> [[MGLPointFeature]] {
        var simplebus: [MGLPointFeature] = []
        var mainbus: [MGLPointFeature] = []
        var simpletram: [MGLPointFeature] = []
        var maintram: [MGLPointFeature] = []
        
        for loc in getAllStationsLocations() {
            let feature = MGLPointFeature()
            
            feature.coordinate = loc.location.coordinate
            feature.title = loc.station.name
            feature.attributes = [
                "name": loc.station.name,
                "lineColor": loc.lines.count == 1 ? loc.lines[0].bgColor : UIColor.black,
                "stopZoneId": loc.station.id
            ]
            if loc.lines.contains(where: {$0.type == .TRAMWAY}) {
                //TRAM
                if loc.lines.filter({$0.type == .TRAMWAY}).count > 1 {
                    //MULTI-LINE STATION
                    maintram.append(feature)
                } else {
                    //MONO-LINE STATION
                    simpletram.append(feature)
                }
            } else {
                //BUS-AUTRE
                if loc.lines.count > 1 {
                    //MULTI-LINE STATION
                    mainbus.append(feature)
                } else {
                    //MONO-LINE STATION
                    simplebus.append(feature)
                }
            }
        }
        return [maintram, simpletram, mainbus, simplebus]
    }
    
}
