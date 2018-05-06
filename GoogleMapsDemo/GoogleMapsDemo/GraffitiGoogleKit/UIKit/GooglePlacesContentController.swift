//
// GooglePlacesContentController.swift
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

import Graffiti
import GoogleMaps

public class GooglePlacesContentController: BaseContentController {
    
    @IBOutlet var mapContainer: GoogleMapContainer!
    
    @IBOutlet var infoView: ContentDisplayView?
    @IBOutlet var markerView: ContentDisplayView?
    
    @IBOutlet var searchInput: TextInputView?
    @IBOutlet var searchProgressView: UIActivityIndicatorView?
    
    var placesProvider: GooglePlaceNearbyProvider {
        return mainContentProvider as! GooglePlaceNearbyProvider
    }
    
    @objc public var apiKey: String?
    @objc public var searchOnMove = true
    @objc public var releaseKeyboardOnMove = false
    @objc public var defaultMarkerIconPrefix = ""
    @objc public var defaultMarkerIconName: String?
    @objc public var markerTapSegue: String?
    @objc public var markerTitleTapSegue: String?
    @objc public var showSystemTitleWithInfo = true
    @objc public var infoViewMaxAlpha: CGFloat = 0.95
    
    fileprivate weak var lastTappedMarker: GMSMarker?
    
    fileprivate func setMarkers(for places: [GooglePlace]) {
        guard let mapView = mapContainer.mapView else { return }
        mapView.clear()
        infoView?.unveilAlpha = 0
        var bounds = GMSCoordinateBounds()
        places.forEach { place in
            if !place.coordinate.isZero {
                let position = place.coordinate
                let marker = GMSMarker(position: position)
                marker.userData = place
                marker.title = place.name
                let placeType = defaultMarkerIconPrefix + place.placeType
                if placeType.isEmpty, let iconName = defaultMarkerIconName {
                    marker.icon = UIImage(named: iconName)
                } else {
                    marker.icon = UIImage(named: placeType)
                }
                marker.map = mapContainer.mapView
                bounds = bounds.includingCoordinate(position)
            }
        }
        if places.count == 1 {
            mapContainer.moveToCoordinate(places.first!.coordinate)
        } else {
            mapContainer.moveToCoordinateBounds(bounds)
        }
    }
    
    public override func renderContent(from source: ContentProviderProtocol? = nil) {
        if source === placesProvider {
            searchProgressView?.stopAnimating()
            setMarkers(for: placesProvider.allItems as! [GooglePlace])
        }
        super.renderContent()
    }
    
    func setupAPIKey() {
        assert(apiKey != nil, "API key required for \(type(of: self))")
        if placesProvider.apiKey == nil {
            placesProvider.apiKey = apiKey
        }
    }
    
    func setupSearchInput() {
        searchInput?.returnPressed.append { [weak self] text in
            self?.searchProgressView?.startAnimating()
            self?.renderContent()
        }
    }
    
    public override func setup() {
        super.setup()
        setupAPIKey()
        setupSearchInput()
        mapContainer.createGoogleMapWithAPIKey(apiKey!, delegate: self)
    }
    
    public override func prepare() {
        infoView?.setup(with: viewController.scheme)
        markerView?.setup(with: viewController.scheme)
    }
}

extension GooglePlacesContentController: GMSMapViewDelegate {
    
    @objc func _handleMapIdle() {
        guard mapContainer.userCoordinate != nil, let coordinate = mapContainer.selectedCoordinate else { return }
        placesProvider.aroundCoordinate = coordinate
        if searchOnMove {
            searchController?.performSearch()
        }
    }
    
    func showMarkerView(with marker: GMSMarker) {
        guard let markerView = markerView else { return }
        markerView.content = marker.userData
        lastTappedMarker?.iconView = nil
        marker.iconView = markerView
        lastTappedMarker = marker
        markerView.gx_fitContent()
    }
    
    public func mapView(_ mapView: GMSMapView, idleAt position: GMSCameraPosition) {
        if releaseKeyboardOnMove {
            searchController?.releaseKeyboard()
        }
        NSObject.cancelPreviousPerformRequests(withTarget: self, selector: #selector(_handleMapIdle), object: nil)
        perform(#selector(_handleMapIdle), with: nil, afterDelay: 1.0)
    }
    
    public func mapView(_ mapView: GMSMapView, didTap marker: GMSMarker) -> Bool {
        if let segue = markerTapSegue {
            viewController.performSegue(withIdentifier: segue, sender: ContentWrapper(content: marker.userData as? NSObject))
            return true
        }
        if markerView != nil {
            showMarkerView(with: marker)
            return true
        }
        if let infoView = infoView {
            infoView.content = marker.userData
            infoView.unveilAlpha = infoViewMaxAlpha
            if !showSystemTitleWithInfo {
                return true
            }
        }
        return false
    }
    
    public func mapView(_ mapView: GMSMapView, didTapInfoWindowOf marker: GMSMarker) {
        if let segue = markerTitleTapSegue {
            viewController.performSegue(withIdentifier: segue, sender: ContentWrapper(content: marker.userData as? NSObject))
        }
    }
    
    public func mapView(_ mapView: GMSMapView, didTapAt coordinate: CLLocationCoordinate2D) {
        lastTappedMarker?.iconView = nil
        infoView?.unveilAlpha = 0
    }
}
