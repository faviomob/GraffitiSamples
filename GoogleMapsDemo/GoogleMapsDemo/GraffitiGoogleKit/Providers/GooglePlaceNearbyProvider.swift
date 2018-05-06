//
// GooglePlaceNearbyProvider.swift
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

import UIKit
import CoreLocation

let kGooglePlacesAPIBase = "https://maps.googleapis.com/maps/api/place"

public class GooglePlaceNearbyProvider: GoogleBaseContentProvider {
    
    // list of supported types: https://developers.google.com/places/web-service/supported_types
    override var endpointFormat: String {
        return "\(kGooglePlacesAPIBase)/nearbysearch/json?keyword=%@&location=%@&radius=%d&type=%@&language=%@&key=%@"
    }
    
    override var itemType: GoogleResultItem.Type { return GooglePlace.self }
    
    @objc public var radius: Double = 5000 // meters
    
    @objc public var placeType = ""
    
    public var aroundCoordinate: CLLocationCoordinate2D?
    
    override func url(with string: String) -> String? {
        guard apiKey != nil else {
            print("API key required!")
            return nil
        }
        guard aroundCoordinate != nil else {
            print("Location required!")
            return nil
        }
        guard string.count > 1 else {
            return nil
        }
        return String(format: endpointFormat,
                      string,
                      aroundCoordinate!.stringValue,
                      Int(radius),
                      placeType,
                      locale,
                      apiKey!).addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed)
    }
}

public class GooglePlace: GoogleGeocoderAddress {
    
    @objc public var name: String?
    @objc public var vicinity: String?
    @objc public var reference: String?
    @objc public var placeTypes: [String]?
    @objc public var placeType: String {
        return placeTypes?.first ?? ""
    }
    
    @objc public var photoMaxWidth: Int = 200
    @objc public var photoMaxHeight: Int = -1
    
    @objc public var photoUrl: String {
        let url = "\(kGooglePlacesAPIBase)/photo?maxwidth=\(photoMaxWidth < 0 ? "" : "\(photoMaxWidth)")&maxheight=\(photoMaxHeight < 0 ? "" : "\(photoMaxHeight)")&photoreference=\(reference ?? "")&key=\(apiKey ?? "")"
        //print(url) // demo reference = CnRtAAAATLZNl354RwP_9UKbQ_5Psy40texXePv4oAlgP4qNEkdIrkyse7rPXYGd9D_Uj1rVsQdWT4oRz4QrYAJNpFX7rzqqMlZw2h2E2y5IKMUZ7ouD_SlcHxYq1yL4KbKUv3qtWgTK0A6QbGh87GB3sscrHRIQiG2RrmU_jF4tENr9wGS_YxoUSSDrYjWmrNfeEHSGSc3FyhNLlBU
        return url
    }
    
    public required init(json: NSDictionary) {
        super.init(json: json)
        name = json["name"] as? String
        vicinity = json["vicinity"] as? String
        reference = json["reference"] as? String
        placeTypes = json["types"] as? [String]
    }
}
