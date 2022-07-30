//
//  PhotoPreviewView.swift
//  AiTTENDANCE
//
//  Created by Tracy Farah on 16/07/2022.

import UIKit
import Photos
import SwiftyJSON
import FirebaseCore
import FirebaseFirestore
import FirebaseAuth

class PhotoPreviewView: UIView {
    
    var className: String?
    
    let photoImageView: UIImageView = {
        let imageView = UIImageView(frame: .zero)
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        return imageView
    }()
    
    lazy private var cancelButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(UIImage(systemName: "xmark"), for: .normal)
        button.addTarget(self, action: #selector(handleCancel), for: .touchUpInside)
        button.tintColor = .white
        return button
    }()
    
    lazy private var uploadPhotoButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(UIImage(systemName: "square.and.arrow.up"), for: .normal)
        button.addTarget(self, action: #selector(handleUploadPhoto), for: .touchUpInside)
        button.tintColor = .white
        return button
    }()
    
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        addSubviews(photoImageView, cancelButton, uploadPhotoButton)
        
        photoImageView.makeConstraints(top: topAnchor, left: leftAnchor, right: rightAnchor, bottom: bottomAnchor, topMargin: 0, leftMargin: 0, rightMargin: 0, bottomMargin: 0, width: 0, height: 0)
        
        cancelButton.makeConstraints(top: safeAreaLayoutGuide.topAnchor, left: nil, right: rightAnchor, bottom: nil, topMargin: 15, leftMargin: 0, rightMargin: 10, bottomMargin: 0, width: 50, height: 50)
        
        uploadPhotoButton.makeConstraints(top: nil, left: nil, right: cancelButton.leftAnchor, bottom: nil, topMargin: 0, leftMargin: 0, rightMargin: 5, bottomMargin: 0, width: 50, height: 50)
        uploadPhotoButton.centerYAnchor.constraint(equalTo: cancelButton.centerYAnchor).isActive = true
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    @objc private func handleCancel() {
        DispatchQueue.main.async {
            self.removeFromSuperview()
        }
    }
    
    //perform post request to add students and save their face encodings
    @objc func handleUploadPhoto() {
        guard let previewImage = self.photoImageView.image else { return } //uiimage to send
        API.performRecognizeRequest(image: previewImage, classID: className!)
        let vc: UIViewController = self.parentViewController!
        vc.dismiss(animated: true)
        let alert = UIAlertController(title: "Attendance taken", message: "Kindly check your email inbox for the attendance sheet.", preferredStyle: .alert)
        vc.parentViewController!.present(alert, animated: true, completion: nil)
        let when = DispatchTime.now() + 3
        DispatchQueue.main.asyncAfter(deadline: when){
            alert.dismiss(animated: true, completion: nil)
        }
        
    }
}
extension UIResponder {
    public var parentViewController: UIViewController? {
        return next as? UIViewController ?? next?.parentViewController
    }
}

