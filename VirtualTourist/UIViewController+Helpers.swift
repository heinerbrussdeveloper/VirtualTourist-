//
//  UIViewController+Helpers.swift
//  VirtualTourist
//
//  Created by Heiner Bruß on 27.08.20.
//  Copyright © 2020 Heiner Bruß. All rights reserved.
//

import UIKit

extension UIViewController {
    func alert(title: String, message: String) {
        let ac = UIAlertController(title: title, message: message, preferredStyle: .alert)
        ac.addAction(UIAlertAction(title: "OK", style: .default))
        present(ac, animated: true)
    }
}
