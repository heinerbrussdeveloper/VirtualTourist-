//
//  AppDelegate.swift
//  VirtualTourist
//
//  Created by Heiner Bruß on 27.08.20.
//  Copyright © 2020 Heiner Bruß. All rights reserved.
//

import UIKit

class CustomNavigationController: UINavigationController {
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
}

extension UINavigationController {
open override var preferredStatusBarStyle: UIStatusBarStyle {
    return .lightContent
}
}
@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    var window: UIWindow?
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        UINavigationBar.appearance().isTranslucent = false
        UINavigationBar.appearance().barTintColor = .lightRed
        UINavigationBar.appearance().backgroundColor = .lightRed
        UINavigationBar.appearance().titleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.white]
        UINavigationBar.appearance().largeTitleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.white]
        UINavigationBar.appearance().tintColor = .white
        
        window = UIWindow()
        window?.makeKeyAndVisible()
        let travelLocationsController = TravelLocationsMapViewController()
        let navController = CustomNavigationController(rootViewController: travelLocationsController)
        window?.rootViewController = navController
        
        return true
    }

    
}

