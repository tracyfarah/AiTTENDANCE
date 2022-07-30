//
//  StudentFormViewController.swift
//  AiTTENDANCE
//
//  Created by Tracy Farah on 21/07/2022.
//

import UIKit
import FirebaseAuth
import FirebaseFirestore
import Photos


class StudentFormViewController: UIViewController, UITextFieldDelegate{
    
    var className:String?
    @IBOutlet weak var firstNameTextField: UITextField!
    
    @IBOutlet weak var attachementLabel: UILabel!
    @IBOutlet weak var lastNameTextField: UITextField!
    @IBOutlet weak var idTextField: UITextField!
    
    let db = Firestore.firestore()
    let user = Auth.auth().currentUser?.uid
    
    var image : UIImage?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        attachementLabel.text = ""
        title = "New Student"
        firstNameTextField.autocapitalizationType = .words;
        lastNameTextField.autocapitalizationType = .words;
        
    }
    
    var students: [Student] = []
    
    @IBAction func handleUploadImage(_ sender: UIButton) {
        let picker = UIImagePickerController()
        picker.delegate = self
        picker.allowsEditing = false
        let alert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        alert.addAction(UIAlertAction(title: "Camera", style: .default, handler: {
            action in
            picker.sourceType = .camera
            self.present(picker, animated: true, completion: nil)
        }))
        alert.addAction(UIAlertAction(title: "Photo Library", style: .default, handler: {
            action in
            picker.sourceType = .photoLibrary
            self.present(picker, animated: true, completion: nil)
        }))
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        PHPhotoLibrary.requestAuthorization { (status) in
            if status == .authorized {
                DispatchQueue.main.async {
                    self.present(alert, animated: true, completion: nil)
                }
            }
        }
    }
    
    
    @IBAction func saveStudentPressed(_ sender: UIBarButtonItem) {
        let alertController = UIAlertController(title: "Blank Fields", message: "Please fill in all the required fields and upload a valid image.", preferredStyle: .alert)
        
        let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
        alertController.addAction(okAction)
        
        let firstName = firstNameTextField.text?.capitalized
        let lastName = lastNameTextField.text?.capitalized
        let studentID = idTextField.text?.capitalized
        
        if firstName == "" || lastName == "" || studentID == "" || image == nil{
            present(alertController, animated: true, completion: nil)
        } else{
            API.performEnrollRequest(fname: firstName!, lname: lastName!, studentID: studentID!, classID: className!, image: image!)
            
            print("enrolled")
            let student = [K.FStore.studentFName: firstName,
                           K.FStore.studentLName: lastName,
                           K.FStore.studentID: studentID]
            self.db
                .collection("users")
                .document(self.user!)
                .collection(K.FStore.collectionName)
                .document(className!)
                .updateData([K.FStore.studentCollection: FieldValue.arrayUnion([student])])
            {(error) in
                if let e = error{
                    print("There was an issue saving data to the firestore, \(e)")
                }else{
                    print("Successfuly saved data")
                }
            }
        }
        _ = navigationController?.popViewController(animated: true)
    }
}

extension StudentFormViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let imageURL = info[UIImagePickerController.InfoKey.referenceURL] as? URL {
            let result = PHAsset.fetchAssets(withALAssetURLs: [imageURL], options: nil)
            let asset = result.firstObject!
            let img = (info[.originalImage] as? UIImage)
            image = img
            attachementLabel.text = ((asset.value(forKey: "filename")!) as! String)
            print(className!)
        }
        
        dismiss(animated: true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
}



