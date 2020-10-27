//
//  PictureCell.swift
//  VirtualTourist
//
//  Created by Heiner Bruß on 01.09.20.
//  Copyright © 2020 Heiner Bruß. All rights reserved.
//

import UIKit


class PictureCell: UICollectionViewCell {
    
    var activityIndicator: UIActivityIndicatorView! = {
        let activity = UIActivityIndicatorView()
        activity.hidesWhenStopped = true
        activity.color = .lightRed
        activity.style = .large
        activity.isHidden = false
        activity.translatesAutoresizingMaskIntoConstraints = false
        return activity
    }()
    
    let imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.layer.borderColor = UIColor.white.cgColor
        imageView.image = UIImage(named: "VirtualTourist_1024")
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    //MARK:- Init Methods
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        addViews()
    }
    
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override var isSelected: Bool {
        didSet {
            if self.isSelected {
                print("yes")
                self.layer.borderColor = UIColor.lightRed.cgColor
                self.layer.borderWidth = 3
            } else {
                self.layer.borderColor = UIColor.clear.cgColor
                self.layer.borderWidth = 3
                print("no")
            }
        }
    }
    
    //MARK:- setup Cell View
    func addViews() {
        
        addSubview(imageView)
        imageView.topAnchor.constraint(equalTo: self.topAnchor).isActive = true
        imageView.leftAnchor.constraint(equalTo: self.leftAnchor).isActive = true
        imageView.rightAnchor.constraint(equalTo: self.rightAnchor).isActive = true
        imageView.bottomAnchor.constraint(equalTo: self.bottomAnchor).isActive = true
        
        self.imageView.addSubview(activityIndicator)

        activityIndicator.centerYAnchor.constraint(equalTo: imageView.centerYAnchor).isActive = true
        activityIndicator.centerXAnchor.constraint(equalTo: imageView.centerXAnchor).isActive = true
    }
    
    
    func showCellWithPhoto(_ photo: Photo) {
        if photo.imageData != nil {
            DispatchQueue.main.async {
                self.imageView.image = UIImage(data: photo.imageData! as Data)
            }
        } else {
            downloadFlickrImages(photo)
        }
    }
    
    //MARK:- DownloadImages
    func downloadFlickrImages(_ photo: Photo) {
        guard let url = URL(string: photo.imageURL!) else {return}
        let task = URLSession.shared.dataTask(with: url) {(data, response, error) in
            if error == nil {
                DispatchQueue.main.async {
                    self.imageView.image = UIImage(data: data! as Data)
                    self.saveImage(photo, imageData: data! as Data)

                }
            }
        }
        task.resume()
    }
    
    func saveImage(_ photo: Photo, imageData: Data) {
        do {
            photo.imageData = imageData
            CoreDataManager.shared.save()
            
        }
    }
}



