//
//  PhotoAlbumViewController.swift
//  VirtualTourist
//
//  Created by Heiner Bruß on 01.09.20.
//  Copyright © 2020 Heiner Bruß. All rights reserved.
//

import UIKit
import MapKit
import CoreData


class PhotoAlbumViewController: UIViewController, MKMapViewDelegate, UICollectionViewDelegate, NSFetchedResultsControllerDelegate    {
    
    enum Mode {
        case view
        case select
    }
    
    var activityIndicator: UIActivityIndicatorView! = PictureCell().activityIndicator
    var pin: Pin!
    var flickrPhotos: [FlickrPhoto] = []
    var savedPhotos = [Photo]()
    var numberOfColumns = 3
    let cellId = "cellId"
    var mMode: Mode = .select
    
    //MARK:- Setup View
    
    var mapView: MKMapView! = {
        let mapView = MKMapView()
        mapView.translatesAutoresizingMaskIntoConstraints = false
        mapView.isZoomEnabled = true
        return mapView
    }()
    
    var collectionView: UICollectionView! = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        let cv = UICollectionView(frame: .zero, collectionViewLayout: layout)
        cv.allowsSelection = false
        cv.translatesAutoresizingMaskIntoConstraints = false
        return cv
    }()
    
    //MARK:- Setup Buttons
    
    lazy var selectBarButton: UIBarButtonItem = {
        let barButtonItem = UIBarButtonItem(title: "Select", style: .plain, target: self, action: #selector(selectPressed))
        return barButtonItem
    }()
    
    lazy var deleteBarButton: UIBarButtonItem = {
        let barButtonItem = UIBarButtonItem(barButtonSystemItem: .trash, target: self, action: #selector(deletePressed))
        return barButtonItem
    }()
    
    lazy var newCollectionButton: UIBarButtonItem = {
        let barButtonItem = UIBarButtonItem(title: "New Collection", style: .plain, target: self, action: #selector(newCollectionPressed))
        return barButtonItem
    }()
    
    private func setupBarButtonItems() {
        activityIndicator.isHidden = false
        navigationItem.rightBarButtonItem = selectBarButton
        
        let flex1 = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: self, action: nil)
        let flex2 = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: self, action: nil)
        toolbarItems = [flex1, newCollectionButton, flex2]
        navigationController?.setToolbarHidden(false, animated: false)
    }
    
    //MARK:- Button Methods
    
    @objc func selectPressed() {
        if mMode == .view {
            mMode = .select
        } else {
            mMode = .view
        }
        
        switch mMode {
        case .view:
            selectBarButton.title = "Cancel"
            collectionView.allowsSelection = true
            collectionView.allowsMultipleSelection = true
            newCollectionButton.isEnabled = true
            navigationItem.leftBarButtonItem = deleteBarButton
        default:
            selectBarButton.title = "Select"
            collectionView.allowsSelection = false
            collectionView.allowsMultipleSelection = false
            newCollectionButton.isEnabled = false
            navigationItem.leftBarButtonItem = nil
        }
    }
    
    @objc func deletePressed() {
        if let selectedIndexPaths = collectionView.indexPathsForSelectedItems {
            for indexPath in selectedIndexPaths {
                let savedPhoto = savedPhotos[indexPath.row]
                for photo in savedPhotos {
                    if photo.imageURL == savedPhoto.imageURL {
                        CoreDataManager.shared.persistentContainer.viewContext.delete(photo)
                        CoreDataManager.shared.save()
                    }
                }
            }
            savedPhotos = loadSavedData()!
            insertInCollection()
        }
    }
    
    @objc func newCollectionPressed() {
        deleteExistingCoreDataPhoto()
        downloadRandomFlickrPhotos()
    }
    

    
    //MARK:- ViewdDidLoad
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupCollectionView()
        mapView.delegate = self
        setupBarButtonItems()
        reloadData()
        activityIndicator.startAnimating()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setupSmallMapView(true)
    }
    
    //MARK:- Methods
    func loadSavedData() -> [Photo]? {
        CoreDataManager.shared.fetchPhotos(pin: pin)
    }
    
    func reloadData() {
        guard let coreDataPics = loadSavedData() else {return}
        if coreDataPics.count != 0  {
            savedPhotos = coreDataPics
            insertInCollection()
        } else {
            showNewResult()
        }
    }
    
    func insertInCollection() {
        DispatchQueue.main.async {
            self.collectionView.reloadData()
        }
    }
    
    func showNewResult() {
        deleteExistingCoreDataPhoto()
        savedPhotos.removeAll()
        downloadFlickrPhotos()
    }
    
    func deleteExistingCoreDataPhoto() {
        for image in savedPhotos {
            CoreDataManager.shared.persistentContainer.viewContext.delete(image)
        }
    }
    
    func deletePhoto(_ photo: Photo) {
        CoreDataManager.shared.persistentContainer.viewContext.delete(photo)
        CoreDataManager.shared.save()
    }
    
    //MARK:- setupSmallMapView
    func setupSmallMapView(_ active: Bool) {
        
        guard let longitude = pin?.longitude else {return}
        guard let latitude = pin?.latitude else {return}
            let center: CLLocationCoordinate2D = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
                mapView.setCenter(center, animated: true)
                let mySpan: MKCoordinateSpan = MKCoordinateSpan(latitudeDelta: 0.1, longitudeDelta: 0.1)
                let myRegion: MKCoordinateRegion = MKCoordinateRegion(center: center, span: mySpan)
                mapView.setRegion(myRegion, animated: true)
                let annotation: MKPointAnnotation = MKPointAnnotation()
                annotation.coordinate = center
                mapView.addAnnotation(annotation)
    }
    
    //MARK:- Download Pictures
    func downloadFlickrPhotos() {
        
        guard let longitude = pin?.longitude else {return}
        guard let latitude = pin?.latitude else {return}
        _ = NetworkManager.shared.getFlickrPics(latitude: latitude, longitude: longitude, page: 1) { (photos, error) in
            if let downloadError = error {
                DispatchQueue.main.async {
                    self.activityIndicator.stopAnimating()
                    self.alert(title: "Error", message: "Error downloading images")
                    print(downloadError.localizedDescription)
                }
            } else {
                guard let photos = photos else {return}
                DispatchQueue.main.async {
                    self.flickrPhotos = photos
                    self.saveToCoreData(photos: photos)
                    self.collectionView.reloadData()
                    self.savedPhotos = self.loadSavedData()!
                    self.insertInCollection()
                    self.activityIndicator.stopAnimating()
                }
            }
        }
    }
    
    //MARK:- Download new Collections
    func downloadRandomFlickrPhotos() {
        
        
        guard let longitude = pin?.longitude else {return}
        guard let latitude = pin?.latitude else {return}
        let randomNumber = Int.random(in: 2...4)
        _ = NetworkManager.shared.getFlickrPics(latitude: latitude, longitude: longitude, page: randomNumber, completion: { (photos, error) in
            if let downloadError = error {
                DispatchQueue.main.async {
                    self.activityIndicator.startAnimating()
                    self.alert(title: "Error", message: "Error downloading random images")
                    print(downloadError.localizedDescription)
                }
            } else {
                guard let photos = photos else {return}
                DispatchQueue.main.async {
                    self.flickrPhotos = photos
                    self.saveToCoreData(photos: photos)
                    self.savedPhotos = self.loadSavedData()!
                    self.insertInCollection()
                    self.activityIndicator.stopAnimating()
                }
            }
        })
    }
    
    //MARK:- Save Picture Collection
    func saveToCoreData(photos: [FlickrPhoto]) {
        
        for flickrPhoto in photos {
            let photo = Photo(context: CoreDataManager.shared.persistentContainer.viewContext)
            photo.imageURL = flickrPhoto.imageURLString()
            photo.pin = pin
            savedPhotos.append(photo)
            CoreDataManager.shared.save()
        }
    }
    
    //MARK:- SETUP UI
    func setupUI() {
        view.backgroundColor = .lightBlue
        view.addSubview(mapView)
        mapView.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        mapView.heightAnchor.constraint(equalToConstant: 200).isActive = true
        mapView.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true
        mapView.rightAnchor.constraint(equalTo: view.rightAnchor).isActive = true
        
        view.addSubview(collectionView)
        collectionView.topAnchor.constraint(equalTo: mapView.bottomAnchor).isActive = true
        collectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        collectionView.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true
        collectionView.rightAnchor.constraint(equalTo: view.rightAnchor).isActive = true
    }
}
