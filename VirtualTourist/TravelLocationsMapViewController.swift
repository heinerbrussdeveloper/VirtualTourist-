//
//  TravelLocationsMapViewController.swift
//  VirtualTourist
//
//  Created by Heiner Bruß on 27.08.20.
//  Copyright © 2020 Heiner Bruß. All rights reserved.
//

import UIKit
import MapKit
import CoreData

class TravelLocationsMapViewController: UIViewController, MKMapViewDelegate, NSFetchedResultsControllerDelegate, CLLocationManagerDelegate {
    
    
    var annotations = [Pin]()
    var savedPins = [MKPointAnnotation]()
    
    var locationManager: CLLocationManager! = {
        let locationManager = CLLocationManager()
        return locationManager
    }()
    
    var mapView: MKMapView! = {
        let mapView = MKMapView()
        mapView.translatesAutoresizingMaskIntoConstraints = false
        mapView.isZoomEnabled = true
        return mapView
    }()
    
    let gestureRecognizer: UILongPressGestureRecognizer = {
        UILongPressGestureRecognizer()
        }()
    
    lazy var infoButton: UIBarButtonItem = {
        let barButtonItem = UIBarButtonItem(title: "Info", style: .plain, target: self, action: #selector(showInfo))
        return barButtonItem
    }()
    
    lazy var changeViewButton: UIBarButtonItem = {
        let barButtonItem = UIBarButtonItem(title: "Change View", style: .plain, target: self, action: #selector(changeView))
        return barButtonItem
    }()

    func setupNavigationBar() {
        navigationItem.title = "Travel Locations"
        navigationItem.rightBarButtonItem = changeViewButton
        navigationItem.leftBarButtonItem = infoButton
    }
    //MARK:- ViewDidLoad
    
    override func viewDidLoad() {
        super.viewDidLoad()
        mapView.delegate = self
        setupNavigationBar()
        setupUI()
        findCurrentLocation()
        fetchPins()
        setCenter()
        gestureRecognizer.addTarget(self, action: #selector(gRecognizerPressed(_ :)))
        mapView.addGestureRecognizer(gestureRecognizer)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    

    
    //MARK:- Button Methods
    @objc private func gRecognizerPressed(_ sender: UILongPressGestureRecognizer) {
        guard sender.state == UIGestureRecognizer.State.began else {return}
        let location = sender.location(in: mapView)
        let myCoordinate: CLLocationCoordinate2D = mapView.convert(location, toCoordinateFrom: mapView)
        let newPin: MKPointAnnotation = MKPointAnnotation()
        newPin.coordinate = myCoordinate
        mapView.register(MKMarkerAnnotationView.self, forAnnotationViewWithReuseIdentifier: MKMapViewDefaultAnnotationViewReuseIdentifier)
        newPin.title = "Pics"
        mapView.addAnnotation(newPin)
        let pin = Pin(context: CoreDataManager.shared.persistentContainer.viewContext)
        pin.latitude = Double(myCoordinate.latitude)
        pin.longitude = Double(myCoordinate.longitude)
        annotations.append(pin)
        CoreDataManager.shared.save()
    }
    
    @objc func showInfo() {
        alert(title: "How it works?", message: "By pressing down on the Map you can add a new Pin to the View. By clicking on the pin you can download related photos to that location from flickr and add them to your photo album ")
    }
    //MARK:- Change View
    
    @objc func changeView() {
        let ac = UIAlertController(title: "Want to change your view?", message: nil, preferredStyle: .alert)
        ac.addAction(UIAlertAction(title: "Standard", style: .default, handler: switchView))
        ac.addAction(UIAlertAction(title: "Sattelite", style: .default, handler: switchView))
        ac.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        present(ac, animated: true)
    }
    
    func switchView(action: UIAlertAction) {
        if action.title == "Sattelite" {
            mapView.mapType = .satellite
        }
        if action.title == "Standard" {
            mapView.mapType = .standard
        }
    }
    
    //MARK:- Methods
    
    private func findCurrentLocation() {
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.distanceFilter = kCLDistanceFilterNone
        locationManager.startUpdatingLocation()
        mapView.showsUserLocation = true
    }

    
    fileprivate func setCenter() {
        let defaults = UserDefaults.standard
        defaults.set(37.773972, forKey: "Lat")
        defaults.set(-122.431297, forKey: "Lon")
        let center = CLLocationCoordinate2DMake(defaults.double(forKey: "Lat"), defaults.double(forKey: "Lon"))
        mapView.setCenter(center, animated: true)
        let span: MKCoordinateSpan = MKCoordinateSpan(latitudeDelta: 1.0, longitudeDelta: 1.0)
        let region: MKCoordinateRegion = MKCoordinateRegion(center: center, span: span)
        mapView.region = region
    }
    
    private func fetchPins() {
        annotations =  CoreDataManager.shared.fetchPins()
        annotations.forEach { (annotation) in
            let savePin = MKPointAnnotation()
            if let lat = CLLocationDegrees(exactly: annotation.latitude), let lon = CLLocationDegrees(exactly: annotation.longitude) {
                let coordinateLocation = CLLocationCoordinate2D(latitude: lat, longitude: lon)
                savePin.coordinate = coordinateLocation
                savePin.title = "Pics"
                savedPins.append(savePin)
        }
    }
        mapView.addAnnotations(savedPins)
    }
    
    //MARK:- MAP VIEW DELEGATE METHODS
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        if annotation is MKUserLocation {return nil}
        
        
        var pinView: MKMarkerAnnotationView
        
        if let annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: MKMapViewDefaultAnnotationViewReuseIdentifier) as? MKMarkerAnnotationView {
            pinView = annotationView
        } else {
            pinView = MKMarkerAnnotationView(annotation: annotation, reuseIdentifier: MKMapViewDefaultAnnotationViewReuseIdentifier)
        }
        pinView.animatesWhenAdded = true
        pinView.titleVisibility = .adaptive
        pinView.canShowCallout = true
        pinView.rightCalloutAccessoryView = UIButton(type: .detailDisclosure)
        pinView.annotation = annotation
        return pinView
    }
    
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        let photoAlbumViewController = PhotoAlbumViewController()
        guard let lat = view.annotation?.coordinate.latitude else {return}
        guard let lon = view.annotation?.coordinate.longitude else {return}
        let selectedPinCoordinate = CLLocationCoordinate2D(latitude: lat, longitude: lon)
        let selectedPin = MKPointAnnotation()
        selectedPin.coordinate = selectedPinCoordinate
        annotations.forEach { (pin) in
            if pin.latitude == selectedPin.coordinate.latitude &&
            pin.longitude == selectedPin.coordinate.longitude {
                photoAlbumViewController.pin = pin
            }
        }
        navigationController?.pushViewController(photoAlbumViewController, animated: true)
    }
    
    
    
    //MARK:- SETUP UI
    func setupUI() {
        view.addSubview(mapView)
        mapView.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        mapView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        mapView.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true
        mapView.rightAnchor.constraint(equalTo: view.rightAnchor).isActive = true
    }

}

