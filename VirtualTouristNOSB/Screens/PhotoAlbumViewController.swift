//
//  PhotoAlbumViewController.swift
//  VirutalTouristNoStoryBoard
//
//  Created by LALIT JAGTAP on 5/6/20.
//  Copyright © 2020 LALIT JAGTAP. All rights reserved.
//

import UIKit
import MapKit
import CoreData

class PhotoAlbumViewController: DataLoadingViewController, NSFetchedResultsControllerDelegate {

    var dataController: DataController!
    var fetchedResultsController: NSFetchedResultsController<Photo>!
    
    var showAlbumAtPin: Pin!
    
    var editPhotos: Bool!
    var deleteLabel = LJBodyLabel(textAlignment: .center)

    var mapView: MKMapView!
    var collectionView: UICollectionView!
    var reloadButton = LJButton(backgroundColor: .systemGreen, title: "New Collection")
    var noPhotosLabel = LJBodyLabel(textAlignment: .center)

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBlue
        configureViewController()
        configureMapView()
        configureCollectionView()
        editPhotos = false
        configureDeletePrompt()
        configureReloadButton()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setupFetchedResultsController()
        
        if (showAlbumAtPin.photos!.count < 1) {
            // album is NOT persited so load photos from REST endpoint
            reloadImageCollection(nil)
        }
        reloadButton.isHidden = false
        collectionView.reloadData()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        NetworkManager.self.prevSearchResponse = nil
        fetchedResultsController = nil
    }
    
    func configureReloadButton() {
        view.addSubview(reloadButton)
        reloadButton.addTarget(self, action: #selector(reloadImageCollection), for: .touchUpInside)
        reloadButton.translatesAutoresizingMaskIntoConstraints = false
        reloadButton.backgroundColor = .systemGreen
        reloadButton.isHidden = true
        
        let padding:CGFloat = 0
        
        NSLayoutConstraint.activate([
            reloadButton.heightAnchor.constraint(equalToConstant: 60),
            reloadButton.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: padding),
            reloadButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: padding),
            reloadButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -padding)
        ])
    }
    
    func configureDeletePrompt() {
        deleteLabel.text = "Tap on photo to delete"
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
    
    func configureCollectionView() {
        let collectionViewHeight = (view.frame.height * (3 / 4))
        let collectionRect = CGRect(origin: view.frame.origin, size: CGSize(width: view.frame.size.width, height: collectionViewHeight))
        
        collectionView = UICollectionView(frame: collectionRect, collectionViewLayout: UIHelper.createThreeColumnFlowLayout(in: view))
        view.addSubview(collectionView)

        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.register(PhotoAlbumCell.self, forCellWithReuseIdentifier: PhotoAlbumCell.reuseID)

        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.backgroundColor = .systemBackground
        let padding:CGFloat = 0
        NSLayoutConstraint.activate([
            collectionView.heightAnchor.constraint(equalToConstant: collectionViewHeight),
            collectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: padding),
            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: padding),
            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -padding)
        ])

        // configure no photos label same as collection view size
        noPhotosLabel.text = "No Photos Found"
        collectionView.addSubview(noPhotosLabel)
        noPhotosLabel.translatesAutoresizingMaskIntoConstraints = false
        noPhotosLabel.backgroundColor = .systemBackground
        noPhotosLabel.isHidden = true
                
        NSLayoutConstraint.activate([
            noPhotosLabel.heightAnchor.constraint(equalToConstant: collectionViewHeight),
            noPhotosLabel.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: padding),
            noPhotosLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: padding),
            noPhotosLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -padding)
        ])
    }
    
    func configureMapView() {
        mapView = MKMapView()
        
        let mapHeight = (view.frame.height / 4)
        let mapRect = CGRect(origin: view.frame.origin, size: CGSize(width: view.frame.size.width, height: mapHeight))
        mapView.frame = mapRect
        view.addSubview(mapView)
        
        mapView.translatesAutoresizingMaskIntoConstraints = false
        mapView.backgroundColor = .systemBackground
        let padding:CGFloat = 0
        NSLayoutConstraint.activate([
            mapView.heightAnchor.constraint(equalToConstant: mapHeight),
            mapView.topAnchor.constraint(equalTo: view.topAnchor, constant: padding),
            mapView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: padding),
            mapView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -padding)
        ])

        // setup a show Album pin on the map
        let pinAnnotation = MKPointAnnotation()
        pinAnnotation.coordinate = CLLocationCoordinate2DMake(showAlbumAtPin.latitude, showAlbumAtPin.longitude)
        mapView.addAnnotation(pinAnnotation)
        mapView.setRegion(MKCoordinateRegion(center: pinAnnotation.coordinate, span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)), animated: true)
    }
    
    func configureViewController() {
        view.backgroundColor = .systemBackground
        navigationController?.setNavigationBarHidden(false, animated: true)
        self.title = "Photo Album"

        let editButton = UIBarButtonItem(barButtonSystemItem: .edit, target: self, action: #selector(setEditingMode))
        navigationItem.rightBarButtonItem = editButton
        
        let backButton = UIBarButtonItem(title: "OK", style: .done, target: self, action: #selector(returnToPrevScene))
        navigationItem.leftBarButtonItem = backButton
    }
    
    @objc func returnToPrevScene() {
        navigationController?.popViewController(animated: true)
    }
    
    //MARK: Edit Button
    @objc func setEditingMode() {
        editPhotos = !editPhotos
        deleteLabel.isHidden = !editPhotos
        reloadButton.isHidden = editPhotos
    }
    
    // MARK: Photo loading
    @objc func reloadImageCollection(_ sender: Any?) {
        showLoadingView()

        // initial state of collection view
        DispatchQueue.main.async {
            self.noPhotosLabel.isHidden = true
            self.reloadButton.isHidden = false
        }
        
        var page = 1
        if sender != nil {
            var totalPages = 2
            if NetworkManager.self.prevSearchResponse != nil {
                totalPages = NetworkManager.self.prevSearchResponse.photos.pages
                page = NetworkManager.self.prevSearchResponse.photos.page + 1
            } else {
                page += 1
            }

            if page > totalPages {
                page = 1
            }
            
            // delete existing photos
            deletePhotos()
            collectionView.reloadData()
        }
        
        guard let tappedPin = showAlbumAtPin else {
            fatalError("cannot fetch photos for blank location")
        }
        
        NetworkManager.shared.searchPhotos(lattitude: tappedPin.latitude, longitude: tappedPin.longitude, page: page) { [weak self] (result) in
            
            guard let self = self else { return }
            self.dismissLoadingView()

            switch (result) {
            case .success(let jsonPhotos):
                
                let photoArray = jsonPhotos.photo
                
                for photoObject in photoArray {
                    let imageURLString = photoObject.urlM
                    
                    let photoToSave = Photo(context: self.dataController.viewContext)
                    photoToSave.pin = self.showAlbumAtPin
                    photoToSave.imageUrl = imageURLString
                    self.saveViewContext()
                }
                
                DispatchQueue.main.async {
                    self.noPhotosLabel.isHidden = true
                    self.collectionView.reloadData()
                    self.reloadButton.isHidden = false
                }
            case .failure(let error):
                DispatchQueue.main.async {
                    self.presentAlertOnMainThread(title: "No photos data", message: error.rawValue)
                    self.noPhotosLabel.isHidden = false
                    self.reloadButton.isEnabled = false
                    return
                }
            }
        }
    }
}

// MARK: - ColleactionView delegates

extension PhotoAlbumViewController: UICollectionViewDataSource, UICollectionViewDelegate {

    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return fetchedResultsController.sections?.count ?? 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return fetchedResultsController.sections?[section].numberOfObjects ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let photo = fetchedResultsController.object(at: indexPath)
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: PhotoAlbumCell.reuseID, for: indexPath) as! PhotoAlbumCell
        
        if let imageData = photo.image {
            cell.albumImageView.image = UIImage(data: imageData)
        } else {
            guard let imageURL = photo.imageUrl else {
                fatalError("abort : the imageURL is missing for this photo \(photo)")
            }

            DispatchQueue.main.async {
                cell.albumImageView.image = UIImage(named: "placeholder-image")
            }
            
            // load the image data from REST endpoint
            NetworkManager.shared.downloadRawImageData(from: imageURL, completed: { [weak self] (data) in
                
                guard let self = self else { return }
                
                if let data = data {
                    // update the image on the collection View
                    DispatchQueue.main.async {
                        cell.albumImageView.image = UIImage(data: data)
                    }

                    // save the imagge data to Core Data
                    photo.image = data
                    self.saveViewContext()
                }
            })
        }
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if editPhotos {
            let photo = fetchedResultsController.object(at: indexPath)
            dataController.viewContext.delete(photo)
            saveViewContext()
        }
    }
}

// MARK: - Core Data

extension PhotoAlbumViewController {
    
    fileprivate func setupFetchedResultsController() {
        let fetchRequest:NSFetchRequest<Photo> = Photo.fetchRequest()
        fetchRequest.sortDescriptors = []
        
        let predicate = NSPredicate(format: "pin == %@", showAlbumAtPin)
        fetchRequest.predicate = predicate
        
        fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: dataController.viewContext, sectionNameKeyPath: nil, cacheName: nil)
        
        fetchedResultsController.delegate = self
        
        do {
            try fetchedResultsController.performFetch()
        } catch {
            fatalError("Photo entity fetch could not be performed: \(error.localizedDescription)")
        }
    }
    
    fileprivate func savePhotos(photos: NSArray) {
        
    }
    
    fileprivate func deletePhotos() {
        guard let fetchedPhotos = fetchedResultsController.fetchedObjects else {
            return  // no saved photos found in the core data
        }
        
        for photo in fetchedPhotos {
            dataController.viewContext.delete(photo)
            saveViewContext()
        }
    }
    
    func saveViewContext() {
        try? dataController.viewContext.save()
    }
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        
        switch type {
        case .insert:
            collectionView.insertItems(at: [newIndexPath!])
            break
        case .delete:
            collectionView.deleteItems(at: [indexPath!])
        case .update:
            collectionView.reloadItems(at: [indexPath!])
        default:
            break
        }
    }
}
