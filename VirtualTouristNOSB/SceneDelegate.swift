//
//  SceneDelegate.swift
//  VirutalTouristNoStoryBoard
//
//  Created by LALIT JAGTAP on 5/4/20.
//  Copyright © 2020 LALIT JAGTAP. All rights reserved.
//

import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?

    let dataController = DataController(modelName: "VirtualTourist")

    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {

        guard let windowScene = (scene as? UIWindowScene) else { return }
        
        window = UIWindow(frame: windowScene.coordinateSpace.bounds)
        window?.windowScene = windowScene
        window?.rootViewController = createTravelMapViewNavigationController()
        window?.makeKeyAndVisible()
        
        configureNavigationBar()
        
        dataController.load()
        let navigationController = window?.rootViewController as! UINavigationController
        let travelMapVC = navigationController.topViewController as! TravelMapViewController
        travelMapVC.dataController = dataController
    }

    func configureNavigationBar() {
        UINavigationBar.appearance().tintColor = .systemBlue
    }
    
    func createTravelMapViewNavigationController() -> UINavigationController {
        let travelMapVC = TravelMapViewController()
        return UINavigationController(rootViewController: travelMapVC)
    }
    
    func sceneDidEnterBackground(_ scene: UIScene) {
        saveViewContext()
    }
    
    func sceneDidDisconnect(_ scene: UIScene) {
        saveViewContext()
    }
    
    func saveViewContext() {
        try? dataController.viewContext.save()
    }
}

