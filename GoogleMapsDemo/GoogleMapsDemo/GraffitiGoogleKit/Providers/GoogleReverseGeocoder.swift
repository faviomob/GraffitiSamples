//
// GoogleReverseGeocoder.swift
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
import Graffiti

public class GoogleReverseGeocoder: GoogleBaseContentProvider {
    
    override var endpointFormat: String {
        return "https://maps.googleapis.com/maps/api/geocode/json?latlng=%@&key=%@&language=%@&result_type=%@"
    }
    
    var locationManager: CLLocationManager?
    
    @objc public var resolveLocation: Bool = true
    
    public var targetCoordinate: CLLocationCoordinate2D? {
        didSet { fetch() }
    }
    
    public override var searchString: String? {
        get {
            return targetCoordinate?.stringValue
        }
        set {
            //
        }
    }
    
    @objc public var resultType = "locality" // city
    
    @objc public var requestAccessLocation = true
    
    override func url(with string: String) -> String? {
        guard apiKey != nil else {
            print("API key required!")
            return nil
        }
        return String(format: endpointFormat,
                      string,
                      apiKey!,
                      locale,
                      resultType).addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed)
    }
    
    func setupLocationManagerIfNeeded() {
        guard resolveLocation, locationManager == nil else { return }
        locationManager = CLLocationManager()
        locationManager!.delegate = self
        locationManager!.desiredAccuracy = kCLLocationAccuracyThreeKilometers
        if requestAccessLocation {
            locationManager!.requestWhenInUseAuthorization()
        }
    }
    
    public override func setup() {
        super.setup()
        async { self.setupLocationManagerIfNeeded() }
    }
}

extension GoogleReverseGeocoder {
    
    public func resolve(location: CLLocation, resultType: String, locale: String, _ complete: @escaping ([GoogleGeocoderAddress]?, Error?) -> Void) {
        self.targetCoordinate = location.coordinate
        self.resultType = resultType
        self.locale = locale
        search(string: searchString!) { error in
            complete(self.allItems as? [GoogleGeocoderAddress], error)
        }
    }
}

extension GoogleReverseGeocoder: CLLocationManagerDelegate {
    
    public func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        if status == .authorizedWhenInUse || status == .authorizedAlways {
            inProgress = true
            contentConsumer?.renderContent(from: self)
            locationManager!.requestLocation()
        }
        else if (status == .restricted || status == .denied) {
            inProgress = false
            contentConsumer?.renderContent(from: self)
        }
    }
    
    public func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        targetCoordinate = locations.last?.coordinate
    }
    
    public func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print(error)
        inProgress = false
        contentConsumer?.renderContent(from: self)
    }
}
