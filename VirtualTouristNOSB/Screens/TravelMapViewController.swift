//
//  MapViewController.swift
//  OnTheMap
//
//  Created by LALIT JAGTAP on 4/22/20.
//  Copyright © 2020 LALIT JAGTAP. All rights reserved.
//

import UIKit
import MapKit
import CoreData

class TravelMapViewController: DataLoadingViewController,  MKMapViewDelegate, NSFetchedResultsControllerDelegate {

    var dataController: DataController!
    var fetchedResultsController: NSFetchedResultsController<Pin>!
    
    var mapView: MKMapView!
    var editPin: Bool!
    var deleteLabel = LJBodyLabel(textAlignment: .center)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBlue
        configureViewController()
        configureMapView()
        configureLongTapGestureForMap()
        editPin = false
        configureDeletePrompt()
    }
    
    func configureDeletePrompt() {
        deleteLabel.text = "Tap on pin to delete"
        view.addSubview(deleteLabel)
        deleteLabel.translatesAutoresizingMaskIntoConstraints = false
        deleteLabel.backgroundColor = .systemRed
        deleteLabel.isHidden = true
        
        let padding:CGFloat = 0
        
        NSLayoutConstraint.activate([
            deleteLabel.heightAnchor.constraint(equalToConstant: 60),
            deleteLabel.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: padding),
            deleteLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: padding),
            deleteLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -padding)
        ])
    }
    
    func configureMapView() {
        mapView = MKMapView(frame: view.bounds)
        view.addSubview(mapView)
        mapView.delegate = self
        mapView.backgroundColor = .systemBackground
    }

    func configureLongTapGestureForMap() {
        let gesture = UILongPressGestureRecognizer(target: self, action: #selector(addLocationPin(gesture:)))
        gesture.minimumPressDuration = 0.4
        mapView.addGestureRecognizer(gesture)
    }
    
    func configureViewController() {
        view.backgroundColor = .systemBackground
        navigationController?.setNavigationBarHidden(false, animated: true)
        self.title = "Virtual Tourist"

        let editButton = UIBarButtonItem(barButtonSystemItem: .edit, target: self, action: #selector(setEditingMode))
        navigationItem.rightBarButtonItem = editButton
    }
    
    //MARK: Edit Button
    @objc func setEditingMode() {
        editPin = !editPin
        deleteLabel.isHidden = !editPin
    }
    
    fileprivate func configureMapRegion() {
        if let currentMapRegion = UserDefaults.standard.dictionary(forKey: "currentMapRegion") {
            let center = CLLocationCoordinate2DMake(currentMapRegion["lat"] as! Double, currentMapRegion["long"] as! Double)
            let span = MKCoordinateSpan(latitudeDelta: currentMapRegion["latDelta"] as! Double, longitudeDelta: currentMapRegion["longDelta"] as! Double)
            let region = MKCoordinateRegion(center: center, span: span)
            
            mapView.setRegion(region, animated: true)
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        configureMapRegion()
        
        setupFetchedResultsController()
        setupSavedMarkers()
    }
}
    
// MARK: - MKMapViewDelegate
extension TravelMapViewController {
    
    @objc func addLocationPin(gesture: UILongPressGestureRecognizer) {
        let pinLocation = gesture.location(in: mapView)
        let pinCoordinate = mapView.convert(pinLocation, toCoordinateFrom: mapView)
        
        if gesture.state == .began {
            placeLocationPinOnMap(coordinate: pinCoordinate)
        } else if gesture.state == .changed {
            //
        } else if gesture.state == .ended {
            savePin(coordinate: pinCoordinate)
        }
    }
    
    func placeLocationPinOnMap(coordinate: CLLocationCoordinate2D) {
        let pinAnnotation = MKPointAnnotation()
        pinAnnotation.coordinate = coordinate
        mapView.addAnnotation(pinAnnotation)
    }
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        
        let reuseId = "pin"
        var pinView = mapView.dequeueReusableAnnotationView(withIdentifier: reuseId) as? MKPinAnnotationView

        if pinView == nil {
            pinView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: reuseId)
            pinView!.pinTintColor = .red
            pinView!.animatesDrop = true
        }
        else {
            pinView!.annotation = annotation
        }
        
        return pinView
    }


    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        
        guard let pin = loadPin(latitude: (view.annotation?.coordinate.latitude)!, longitude: (view.annotation?.coordinate.longitude)!) else {
            self.presentAlertOnMainThread(title: "Failed core data", message: "Pin not found in database")
            return
        }
        
        if editPin {
            dataController.viewContext.delete(pin)
            saveViewContext()
            
            mapView.removeAnnotation(view.annotation!)
        } else {
            pushCollectionViewController(pin)
        }
    }
    
    // MARK: - Navigation
    func pushCollectionViewController(_ tapepdPin: Pin) {
        let photoAlbumVC = PhotoAlbumViewController()
        photoAlbumVC.showAlbumAtPin = tapepdPin
        photoAlbumVC.dataController = dataController
        navigationController?.pushViewController(photoAlbumVC, animated: true)
    }
    
    func mapView(_ mapView: MKMapView, regionDidChangeAnimated animated: Bool) {
        // save the region in user defaults
        let currentMapRegion = ["lat": mapView.centerCoordinate.latitude,
                                "long": mapView.centerCoordinate.longitude,
                                "latDelta": mapView.region.span.latitudeDelta,
                                "longDelta": mapView.region.span.longitudeDelta]
        UserDefaults.standard.set(currentMapRegion, forKey: "currentMapRegion")
    }
}

// MARK: - Core Data

extension TravelMapViewController {
    
    fileprivate func setupFetchedResultsController() {
        let fetchRequest:NSFetchRequest<Pin> = Pin.fetchRequest()
        fetchRequest.sortDescriptors = []
        
        fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: dataController.viewContext, sectionNameKeyPath: nil, cacheName: nil)
        
        fetchedResultsController.delegate = self
        
        do {
            try fetchedResultsController.performFetch()
        } catch {
            fatalError("Pin entity fetch could not be performed: \(error.localizedDescription)")
        }
    }
    
    fileprivate func setupSavedMarkers() {
        guard let fetchedPins = fetchedResultsController.fetchedObjects else {
            return  // no saved pins found in the core data
        }
        
        mapView.removeAnnotations(mapView.annotations)
        
        for pin in fetchedPins {
            placeLocationPinOnMap(coordinate: CLLocationCoordinate2D(latitude: pin.latitude, longitude: pin.longitude))
        }
    }
    
    func savePin(coordinate: CLLocationCoordinate2D) {
        let pinToSave = Pin(context: dataController.viewContext)
        pinToSave.latitude = coordinate.latitude
        pinToSave.longitude = coordinate.longitude
        saveViewContext()
    }
    
    func loadPin(latitude: Double, longitude: Double) -> Pin? {
        let fetchRequest: NSFetchRequest<Pin> = Pin.fetchRequest()
        let predicate = NSPredicate(format: "latitude == %lf AND longitude == %lf", latitude, longitude)
        fetchRequest.predicate = predicate
        
        guard let pin = (try? dataController.viewContext.fetch(fetchRequest))?.first else {
            return nil
        }
        
        return pin
    }
    
    func saveViewContext() {
        try? dataController.viewContext.save()
    }
}
