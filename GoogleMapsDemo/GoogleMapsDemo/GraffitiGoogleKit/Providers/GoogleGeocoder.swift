//
// GoogleGeocoder.swift
// GraffitiKit
//
// BSD License
// Copyright © 2018, M8 Labs (m8labs.com). All rights reserved.
//
// Redistribution and use in source and binary forms, with or without
// modification, are permitted provided that the following conditions are met:
//
// * Redistributions of source code must retain the above copyright notice, this
//   list of conditions and the following disclaimer.
//
// * Redistributions in binary form must reproduce the above copyright notice,
//   this list of conditions and the following disclaimer in the documentation
//   and/or other materials provided with the distribution.
//
// THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
// AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
// IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
// DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE
// FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
// DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR
// SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER
// CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY,
// OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
// OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

import MapKit
import Alamofire
import Contacts
import Graffiti

protocol JSONDecodable {
    init(json: NSDictionary)
}

public class GoogleResultItem: NSObject, JSONDecodable {
    
    var apiKey: String!
    
    public required init(json: NSDictionary) {
        //
    }
}

public class GoogleBaseContentProvider: BaseContentProvider {
    
    var currentRequest: DataRequest?
    
    var endpointFormat: String { return "" }
    
    var resultsKey: String { return "results" }
    
    var itemType: GoogleResultItem.Type { return GoogleGeocoderAddress.self }
    
    func url(with string: String) -> String? {
        return nil
    }
    
    @objc public var apiKey: String?
    
    @objc public var locale = Locale.current.languageCode ?? "en"
    
    @objc public internal(set) var inProgress = false
    
    func createItem(ofType itemType: GoogleResultItem.Type, json: NSDictionary) -> GoogleResultItem {
        let item = itemType.init(json: json)
        return item
    }
    
    public func search(string: String, _ complete: @escaping (Error?) -> Void) {
        currentRequest?.cancel()
        if let url = url(with: string) {
            inProgress = true
            currentRequest = Alamofire.request(url)
                .responseJSON { [weak self] response in
                    guard let this = self else { return }
                    this.inProgress = false
                    if let json = response.result.value, let jsonString = JSONSerialization.jsonObjectToString(json) {
                        print("'\(this.viewController.restorationIdentifier ?? "\(type(of: this.viewController!))").\(this.gx.identifier ?? "\(type(of: this))")' response: \(jsonString)")
                    }
                    switch response.result {
                    case .success:
                        let json = response.result.value as! [String: Any]
                        if let jsonObjects = json[this.resultsKey] as? [[String: Any]] {
                            this.reset()
                            for jsonObject in jsonObjects {
                                let item = this.createItem(ofType: this.itemType, json: jsonObject as NSDictionary)
                                item.apiKey = this.apiKey
                                this.insertItem(item)
                            }
                        }
                        complete(nil)
                    case .failure(let error):
                        print(error)
                        complete(error)
                    }
            }
        } else {
            currentRequest = nil
            reset()
            complete(nil)
        }
    }
    
    public override func fetch() {
        search(string: searchString ?? "") { [weak self] error in
            if let this = self {
                this.contentConsumer?.renderContent(from: this)
            }
        }
    }
}

public class GoogleGeocoder: GoogleBaseContentProvider {
    
    override var endpointFormat: String {
        return "https://maps.googleapis.com/maps/api/geocode/json?address=%@&bounds=%@&language=%@&key=%@"
    }
    
    public var region: CLCircularRegion?
    
    @objc public var regionString = ""
    
    override func url(with string: String) -> String? {
        guard apiKey != nil else {
            print("API key required!")
            return nil
        }
        guard string.count >= 2 else {
            print("Search string shoud be at least 2 characters!")
            return nil
        }
        return String(format: endpointFormat,
                      string,
                      region != nil ? boundsString(from: region!) : regionString,
                      locale,
                      apiKey!).addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed)
    }
}

public class GoogleGeocoderAddress: GoogleResultItem {
    
    static let addressFormatter = CNPostalAddressFormatter()
    
    @objc public var streetAddress: String?
    @objc public var placeID: String?
    @objc public var city: String?
    @objc public var country: String?
    @objc public var route: String?
    @objc public var streetNumber: String?
    @objc public var postalCode: String?
    @objc public var formattedString: String?
    @objc public var coordinate = CLLocationCoordinate2D.zero
    
    public required init(json: NSDictionary) {
        super.init(json: json)
        placeID = json["place_id"] as? String
        formattedString = json["formatted_address"] as? String
        coordinate = CLLocationCoordinate2D(latitude: json.value(forKeyPath: "geometry.location.lat") as! Double,
                                            longitude: json.value(forKeyPath: "geometry.location.lng") as! Double)
        
        if let components = json["address_components"] as? [[String: Any]] {
            for component in components {
                let types = component["types"] as! [String]
                if types.contains("route") {
                    route = component["short_name"] as? String
                }
                else if types.contains("street_number") {
                    streetNumber = component["short_name"] as? String
                }
                else if types.contains("locality") {
                    city = component["short_name"] as? String
                }
                else if types.contains("country") {
                    country = component["long_name"] as? String
                }
                else if types.contains("postal_code") {
                    postalCode = component["short_name"] as? String
                }
            }
        }
        if let route = route {
            let postalAddress = CNMutablePostalAddress()
            postalAddress.street = streetNumber == nil ? route : route + ", " + streetNumber!
            streetAddress = GoogleGeocoderAddress.addressFormatter.string(from: postalAddress)
        } else {
            streetAddress = formattedString
        }
    }
}

func boundsString(from region: CLCircularRegion) -> String {
    let r = MKCoordinateRegionMakeWithDistance(region.center, region.radius, region.radius)
    let bounds = "\(r.center.latitude - (r.span.latitudeDelta / 2.0)),\(r.center.longitude - (r.span.longitudeDelta / 2.0))|\(r.center.latitude + (r.span.latitudeDelta / 2.0)),\(r.center.longitude + (r.span.longitudeDelta / 2.0))"
    return bounds
}
