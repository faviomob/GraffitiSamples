//
// GoogleAddressContentController.swift
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

public class GoogleAddressContentController: BaseContentController {
    
    @IBOutlet var mapContainer: GoogleMapContainer!
    
    /// Resolves coordinate with provided search string
    @IBOutlet var addressGeocoder: GoogleGeocoder?
    
    /// Resolves selected map center street address
    @IBOutlet var mapReverseGeocoder: GoogleReverseGeocoder?
    
    /// Resolves user street address
    @IBOutlet var userReverseGeocoder: GoogleReverseGeocoder?
    
    /// Provides data for suggestions view, if both are connected outlets
    @IBOutlet var suggestionsProvider: GooglePlaceAutocompleter?
    
    /// Requests data for `suggestionsProvider` via its input control
    @IBOutlet var suggestionsSearchController: SearchActionController?
    
    /// Controls content of the `suggestionsView`
    @IBOutlet var suggestionsContentController: TableContentController?
    
    /// Controls content of the `refineView`
    @IBOutlet var refineContentController: TableContentController?
    
    @IBOutlet var addressInput: TextInputView?
    @IBOutlet var refineView: UITableView?
    @IBOutlet var suggestionsView: UITableView?
    @IBOutlet var geocodingProgressView: UIActivityIndicatorView?
    
    @objc public var apiKey: String?
    @objc public var searchOnMove = true
    @objc public var followUserLocation = true
    @objc public var mapBasedSuggestions = false
    @objc public var releaseKeyboardOnMove = false
    
    @objc public fileprivate(set) var userAddress: GoogleGeocoderAddress?
    @objc public fileprivate(set) var selectedAddress: GoogleGeocoderAddress?
    
    func selectAddress(_ address: GoogleGeocoderAddress) {
        selectedAddress = address
        if !address.coordinate.isZero {
            mapContainer.moveToCoordinate(address.coordinate)
        }
        addressGeocoder?.reset()
        suggestionsSearchController?.resetSearch()
    }
    
    func updateUserAddress(_ address: GoogleGeocoderAddress) {
        let moveMap = userAddress == nil && !address.coordinate.isZero
        userAddress = address
        if followUserLocation || mapContainer.selectedCoordinate == nil {
            selectAddress(address)
        } else if moveMap {
            mapContainer.moveToCoordinate(address.coordinate)
        }
        if !mapBasedSuggestions {
            suggestionsProvider?.aroundCoordinate = userAddress!.coordinate
        }
    }
    
    func searchAddress(string: String) {
        suggestionsProvider?.reset()
        geocodingProgressView?.startAnimating()
        addressGeocoder?.searchString = string
    }
    
    public override func renderContent(from source: ContentProviderProtocol? = nil) {
        guard let source = source else {
            super.renderContent(); return // just update vc
        }
        if source === userReverseGeocoder {
            if let address = source.value as? GoogleGeocoderAddress {
                updateUserAddress(address)
            }
        } else if source === mapReverseGeocoder {
            geocodingProgressView?.stopAnimating()
            if let address = source.value as? GoogleGeocoderAddress {
                selectedAddress = address // do not call selectAddress() here, because it will overwrite coordinate which is already selected
            }
        } else {
            if source === addressGeocoder {
                geocodingProgressView?.stopAnimating()
                refineContentController?.renderContent()
                let count = source.totalCount()
                if count == 1 || refineView == nil { // no choice for address
                    if let address = source.value as? GoogleGeocoderAddress {
                        selectAddress(address)
                    }
                }
            } else if source === suggestionsProvider {
                suggestionsContentController?.renderContent()
            }
        }
        super.renderContent()
    }
    
    func setupAPIKey() {
        assert(apiKey != nil, "API key required for \(type(of: self))")
        if addressGeocoder?.apiKey == nil {
            addressGeocoder?.apiKey = apiKey
        }
        if userReverseGeocoder?.apiKey == nil {
            userReverseGeocoder?.apiKey = apiKey
        }
        if mapReverseGeocoder?.apiKey == nil {
            mapReverseGeocoder?.apiKey = apiKey
        }
        if suggestionsProvider?.apiKey == nil {
            suggestionsProvider?.apiKey = apiKey
        }
    }
    
    func setupAddressInput() {
        addressInput?.returnPressed.append { [weak self] text in
            self?.searchAddress(string: text)
            self?.renderContent()
        }
        addressInput?.textTyped.append { [weak self] _ in
            self?.addressGeocoder?.reset()
        }
        addressInput?.textCleared.append { [weak self] in
            self?.addressGeocoder?.reset()
        }
    }
    
    public override func setup() {
        super.setup()
        setupAPIKey()
        setupAddressInput()
        mapContainer.createGoogleMapWithAPIKey(apiKey!, delegate: self)
    }
    
    public override func prepare() {
        addressGeocoder?.contentConsumer = self
        mapReverseGeocoder?.contentConsumer = self
        userReverseGeocoder?.contentConsumer = self
        suggestionsProvider?.contentConsumer = self
    }
}

extension GoogleAddressContentController: UITableViewDelegate {
    
    public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        if tableView === refineView {
            if let address = addressGeocoder?.item(at: indexPath) as? GoogleGeocoderAddress {
                after(0.25) {
                    self.selectAddress(address)
                }
            }
        }
        else if tableView === suggestionsView {
            if let item = suggestionsProvider?.item(at: indexPath) as? GooglePlaceAutocompletionItem, let text = item.text {
                after(0.25) {
                    self.searchAddress(string: text)
                }
            }
        }
    }
}

extension GoogleAddressContentController: GMSMapViewDelegate {
    
    @objc func _handleMapIdle() {
        guard mapContainer.userCoordinate != nil, let coordinate = mapContainer.selectedCoordinate else { return }
        if mapBasedSuggestions {
            suggestionsProvider?.aroundCoordinate = coordinate
        }
        geocodingProgressView?.startAnimating()
        mapReverseGeocoder?.targetCoordinate = coordinate
        if searchOnMove {
            searchController?.performSearch()
        }
    }
    
    public func mapView(_ mapView: GMSMapView, idleAt position: GMSCameraPosition) {
        if releaseKeyboardOnMove {
            searchController?.releaseKeyboard()
            suggestionsSearchController?.releaseKeyboard()
        }
        NSObject.cancelPreviousPerformRequests(withTarget: self, selector: #selector(_handleMapIdle), object: nil)
        perform(#selector(_handleMapIdle), with: nil, afterDelay: 1.0)
    }
}

extension GoogleAddressContentController {
    
    @IBAction func closeRefineAction(_ sender: UIButton?) {
        addressGeocoder?.reset()
    }
    
    @IBAction func takeSuggestionAction(_ sender: UIButton?) {
        if let suggestion = sender?.contentContainer()?.content as? GooglePlaceAutocompletionItem {
            let editableText = suggestion.title.replacingOccurrences(of: suggestion.mainTerm, with: suggestion.mainTerm + ", ")
            suggestionsSearchController?.searchText = editableText
            suggestionsSearchController?.textInput?.cursorPosition = suggestion.mainTerm.count + 2
        }
    }
}
