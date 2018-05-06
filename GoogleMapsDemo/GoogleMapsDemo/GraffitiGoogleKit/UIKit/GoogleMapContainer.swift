//
// GoogleMapContainer.swift
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
import GoogleMaps

public class GoogleMapContainer: UIView {
    
    var mapView: GMSMapView!
    
    @objc public var myLocationEnabled = true
    @objc public var defaultCameraZoom: Float = 16
    
    public var userCoordinate: CLLocationCoordinate2D?
    public var selectedCoordinate: CLLocationCoordinate2D? {
        return mapView.camera.target
    }
    
    func moveToCoordinate(_ coordinate: CLLocationCoordinate2D) {
        mapView.animate(to: GMSCameraPosition.camera(withTarget:coordinate, zoom: defaultCameraZoom))
    }
    
    func moveToCoordinateBounds(_ bounds: GMSCoordinateBounds) {
        mapView.animate(with: GMSCameraUpdate.fit(bounds, withPadding: 50))
    }
    
    func moveToCurrentCoordinate() {
        if let coordinate = mapView.myLocation?.coordinate {
            mapView.camera = GMSCameraPosition.camera(withTarget:coordinate, zoom: defaultCameraZoom)
        }
    }
    
    func createGoogleMapWithAPIKey(_ apiKey: String, delegate: GMSMapViewDelegate) {
        GMSServices.provideAPIKey(apiKey)
        mapView = GMSMapView(frame: bounds)
        mapView.delegate = delegate
        addSubview(mapView, withEdgeConstraints: UIEdgeInsets.zero)
        mapView.addObserver(self, forKeyPath: "\(#selector(getter: GMSMapView.myLocation))", options: .new, context: nil)
        mapView.isMyLocationEnabled = true
    }
    
    public override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if userCoordinate == nil, let coordinate = mapView.myLocation?.coordinate {
            userCoordinate = coordinate
            moveToCurrentCoordinate()
            mapView.isMyLocationEnabled = myLocationEnabled
        }
    }
}

extension GoogleMapContainer {
    
    @IBAction func zoomInAction(_ sender: UIButton?) {
        mapView.animate(with: GMSCameraUpdate.zoomIn())
    }
    
    @IBAction func zoomOutAction(_ sender: UIButton?) {
        mapView.animate(with: GMSCameraUpdate.zoomOut())
    }
    
    @IBAction func moveToCurrentCoordinateAction(_ sender: UIButton?) {
        moveToCurrentCoordinate()
    }
}

extension GoogleMapContainer {
    
    open override var gx_value: Any? {
        get {
            if let coordinate = selectedCoordinate {
                return coordinate.stringValue
            }
            return ""
        }
        set { }
    }
}

extension CLLocationCoordinate2D: Equatable {
    
    public static func ==(lhs: CLLocationCoordinate2D, rhs: CLLocationCoordinate2D) -> Bool {
        return lhs.latitude == rhs.latitude && lhs.longitude == rhs.longitude
    }
    
    public static func !=(lhs: CLLocationCoordinate2D, rhs: CLLocationCoordinate2D) -> Bool {
        return lhs.latitude != rhs.latitude && lhs.longitude != rhs.longitude
    }
}

extension CLLocationCoordinate2D {
    
    public static let zero = CLLocationCoordinate2D()
    
    public var isZero: Bool {
        return self == CLLocationCoordinate2D.zero
    }
}

extension CLLocationCoordinate2D {
    
    public var stringValue: String {
        return "\(latitude),\(longitude)"
    }
}
