//
//  ParkingData.swift
//  Mpl.
//
//  Created by Darius Martin on 09/06/2018.
//  Copyright © 2018 Darius MARTIN. All rights reserved.
//

import Foundation
import CoreLocation
import Alamofire
import SWXMLHash

class Parking {
    
    //base
    
    var location: CLLocation
    var name: String
    var apiName: String
    
    //data
    var open: Bool = true
    var spotFree: Int = -1
    var spotTotal: Int = -1
    
    init(name: String, lat: Double, long: Double, api: String) {
        self.location = CLLocation(latitude: lat, longitude: long)
        self.name = name
        self.apiName = api
    }
    
    convenience init(name: String, lat: Double, long: Double, totalSpot: Int) {
        self.init(name: name, lat: lat, long: long, api: "")
        self.spotTotal = totalSpot
    }
    
}

class ParkingData {
    
    static private var parkings: [Parking] = [Parking(name: "Arc de Triomphe", lat: 43.611002670702007, long: 3.873200752755528, api: "FR_MTP_ARCT"),
                                              Parking(name: "Gare Saint-Roch", lat: 43.603291492467463, long: 3.878550717206318, api: "FR_MTP_GARE"),
                                              Parking(name: "Antigone", lat: 43.608716064433729, long: 3.888818931230324, api: "FR_MTP_ANTI"),
                                              Parking(name: "Triangle", lat: 43.609233841538739, long: 3.88184418052775, api: "FR_MTP_TRIA"),
                                              Parking(name: "Comédie", lat: 43.608560920671742, long: 3.879761960475114, api: "FR_MTP_COME"),
                                              Parking(name: "Corum", lat: 43.613888214871658, long: 3.882257729371553, api: "FR_MTP_CORU"),
                                              Parking(name: "Europa", lat: 43.607849711198888, long: 3.892530735659631, api: "FR_MTP_EURO"),
                                              Parking(name: "Foch", lat: 43.610749117199369, long: 3.876570837076241, api: "FR_MTP_FOCH"),
                                              Parking(name: "Gambetta", lat: 43.606951381284333, long: 3.87137435808258, api: "FR_MTP_GAMB"),
                                              Parking(name: "Pitot", lat: 43.612244942035765, long: 3.870191169426366, api: "FR_MTP_PITO"),
                                              Parking(name: "Circé Odysseum", lat: 43.60495377250551, long: 3.917849497561747, api: "FR_MTP_CIRC"),
                                              Parking(name: "Garcia Lorca", lat: 43.590985086034571, long: 3.890715797676005, api: "FR_MTP_GARC"),
                                              Parking(name: "Mosson", lat: 43.61623716490606, long: 3.819665542286635, api: "FR_MTP_MOSS"),
                                              Parking(name: "Sabines", lat: 43.583832625579362, long: 3.86022460090246, api: "FR_MTP_SABI"),
                                              Parking(name: "Notre Dame de Sablassou", lat: 43.634191936044225, long: 3.922295361924535, api: "FR_MTP_SABL"),
                                              Parking(name: "Saint-Jean-le-Sec", lat: 43.570822254683563, long: 3.837931203678069, api: "FR_STJ_SJLC"),
                                              Parking(name: "Euromédecine", lat: 43.638953589816154, long: 3.827723649242253, api: "FR_MTP_MEDC"),
                                              Parking(name: "Charles de Gaulle", lat: 43.628542116746345, long: 3.897762101516023, api: "FR_CAS_CDGA"),
                                              Parking(name: "Occitanie", lat: 43.634562324930563, long: 3.848597961110128, api: "FR_MTP_OCCI"),
                                              Parking(name: "Vicarello", lat: 43.632677, long: 3.898415, api: "FR_CAS_VICA"),
                                              Parking(name: "Gaumont EST", lat: 43.603996, long: 3.914246, api: "FR_MTP_GA109"),
                                              Parking(name: "Gaumont OUEST", lat: 43.604788, long: 3.913787, api: "FR_MTP_GA250"),
                                              Parking(name: "La Mantilla", lat: 43.598772955205384, long: 3.902399944818471, totalSpot: 441)]
    
    static public func getNearestParkings(location: CLLocation) -> [Parking] {
        let filtered = self.parkings.filter({$0.location.distance(from: location) < 350})

        return filtered
    }
    
    static public func getParkings() -> [Parking] {
        return self.parkings
    }
    
    static public func updateData(of parking: Parking, completion: @escaping (Bool) -> Void) {
        if (parking.apiName == "") {
            completion(true)
            return
        }
        Alamofire.request("https://data.montpellier3m.fr/sites/default/files/ressources/\(parking.apiName).xml", method: .get, parameters: nil, encoding: URLEncoding.default, headers: nil)
            .responseString { response in
                if let xmlRaw = response.result.value {
                    let xml = SWXMLHash.parse(xmlRaw)
                    
                    for data in xml["park"].children {
                        let value = data.element?.text
                        
                        if value == nil { continue }
                        if (data.description.starts(with: "<Status>") && value! == "Open") { parking.open = true }
                        if (data.description.starts(with: "<Free>")) { parking.spotFree = Int(value!)! }
                        if (data.description.starts(with: "<Total>")) { parking.spotTotal = Int(value!)! }
                    }
                    completion(true)
                    return
                }
                completion(false)
        }
    }
    
}
