//
//  ViewController.swift
//  PlanesOnTheMap
//
//  Created by Sena Küçükerdoğan on 16.12.2024.
//

import UIKit
import MapKit

class AircraftFlightView: UIViewController {

    @IBOutlet weak var mapView: MKMapView!
    
    fileprivate let locationManager = CLLocationManager()
    private var stabilityTimer: Timer?
    private var refreshTimer: Timer?
    private var lastRegion: MKCoordinateRegion?
    private var isRegionMoving = false
    
    private lazy var networkManager = NetworkManager()
      
    private var flightModelData: [FlightData] = []
    private var selectedAnnotationView: MKAnnotationView?
    private var selectedAnnotationId: Int?
    
    // MARK: - View Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()

        setupLocationManager()
        setupMapView()
        startRefreshTimer()
    }

    deinit {
        stabilityTimer?.invalidate()
        refreshTimer?.invalidate()
    }
    
    // MARK: - Setup Methods

    private func setupLocationManager() {
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.distanceFilter = kCLDistanceFilterNone
        locationManager.startUpdatingLocation()
    }

    private func setupMapView() {
        mapView.delegate = self
        mapView.showsUserLocation = true
    }
    
    // MARK: - Data Fetching

    private func fetchData(for region: MKCoordinateRegion) {
        let lomin = region.center.longitude - region.span.longitudeDelta / 2
        let lomax = region.center.longitude + region.span.longitudeDelta / 2
        let lamin = region.center.latitude - region.span.latitudeDelta / 2
        let lamax = region.center.latitude + region.span.latitudeDelta / 2

        networkManager.fetchFlights(lomin: lomin, lamin: lamin, lomax: lomax, lamax: lamax) { [weak self] result in
            switch result {
            case .success(let data):
                DispatchQueue.main.async {
                    self?.processFetchedData(data: data)
                }
            case .failure(let error):
                print("Error fetching data: \(error)")
            }
        }
    }
    
    private func processFetchedData(data: FlightModel) {
        flightModelData = data.states.compactMap { FlightData(from: $0) }
        updateAnnotations(for: flightModelData)
    }

    // MARK: - Annotations

    private func updateAnnotations(for flightData: [FlightData]) {
        mapView.removeAnnotations(mapView.annotations)
        addAnnotations(for: flightData)
    }

    private func addAnnotations(for flightData: [FlightData]) {
        flightData.forEach { flight in
            guard let latitude = flight.latitude, let longitude = flight.longitude else { return }

            let annotation = MKPointAnnotation()
            annotation.coordinate = CLLocationCoordinate2D(latitude: CLLocationDegrees(latitude), longitude: CLLocationDegrees(longitude))
            annotation.title = flight.callsign ?? "Unknown"
            mapView.addAnnotation(annotation)
        }
    }

    private func startRefreshTimer() {
        refreshTimer?.invalidate()
        refreshTimer = Timer.scheduledTimer(withTimeInterval: 5.0, repeats: true) { [weak self] _ in
            guard let self = self, !self.isRegionMoving, let lastRegion = self.lastRegion else { return }
            self.fetchData(for: lastRegion)
        }
    }

    private func startStabilityTimer(for region: MKCoordinateRegion) {
        stabilityTimer?.invalidate()
        isRegionMoving = true

        stabilityTimer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: false) { [weak self] _ in
            guard let self = self else { return }
            self.isRegionMoving = false
            self.lastRegion = region
            self.fetchData(for: region)
        }
    }
}

// MARK: - CLLocationManagerDelegate
extension AircraftFlightView: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let userLocation = locations.last?.coordinate {
            let region = MKCoordinateRegion(center: userLocation,span: MKCoordinateSpan(latitudeDelta: 5.0, longitudeDelta: 5.0))
            mapView.setRegion(region, animated: true)
        }
    }
}

// MARK: - MKMapViewDelegate
extension AircraftFlightView: MKMapViewDelegate {
    func mapView(_ mapView: MKMapView, regionDidChangeAnimated animated: Bool) {
        let visibleRegion = mapView.region
        startStabilityTimer(for: visibleRegion)
    }
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        guard !(annotation is MKUserLocation) else { return nil }
        
       // var marker = mapView.dequeueReusableAnnotationView(withIdentifier: "annotation") as? MKMarkerAnnotationView
        
        let marker = MKMarkerAnnotationView(annotation: annotation, reuseIdentifier: "annotation")
        marker.clusteringIdentifier = "air"
        marker.canShowCallout = true
        marker.markerTintColor = .blue
        marker.glyphImage = UIImage(systemName: "airplane")

        return marker
    }
}

