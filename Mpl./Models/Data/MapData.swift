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
                    }
                }
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
