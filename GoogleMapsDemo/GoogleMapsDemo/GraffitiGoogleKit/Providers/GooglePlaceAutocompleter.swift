//
// GooglePlaceAutocompleter.swift
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

import CoreLocation

public class GooglePlaceAutocompleter: GoogleBaseContentProvider {
    
    override var endpointFormat: String {
        return "https://maps.googleapis.com/maps/api/place/autocomplete/json?input=%@&location=%@&radius=%d&strictbounds&types=%@&language=%@&key=%@"
    }
    
    override var resultsKey: String { return "predictions" }
    
    override var itemType: GoogleResultItem.Type { return GooglePlaceAutocompletionItem.self }
    
    @objc public var radius: Double = 10000 // meters
    
    @objc public var types = "address"
    
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
                      types,
                      locale,
                      apiKey!).addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed)
    }
}

public class GooglePlaceAutocompletionItem: GoogleResultItem {
    
    @objc public var placeID: String?
    @objc public var text: String?
    @objc public var terms = [String]()
    @objc public var title: String!
    @objc public var mainTerm: String!
    
    public required init(json: NSDictionary) {
        super.init(json: json)
        placeID = json["place_id"] as? String
        text = json["description"] as? String
        terms = json.value(forKeyPath: "terms.value") as? [String] ?? []
        mainTerm = terms.first ?? ""
        title = (terms.first ?? "") + (terms.count > 1 ? (", " + terms[1]) : "")
    }
}
