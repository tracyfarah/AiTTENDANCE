//
//  API.swift
//  AiTTENDANCE
//
//  Created by Tracy Farah on 17/07/2022.
//

import Foundation
import SwiftyJSON
import FirebaseAuth

class API{
    
    static func performRecognizeRequest(image: UIImage, classID:String){
        if let url = URL(string: K.Endpoints.attendanceURL){
            var request = URLRequest(url: url, cachePolicy: .reloadIgnoringLocalCacheData)
            request.httpMethod = "POST"
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
            
            guard let imgData = image.pngData() else { return }
            let currentUserEmail = Auth.auth().currentUser?.email
            let base64String = imgData.base64EncodedString(options: .lineLength64Characters)
            let parameters: [String: String] = [
                "email": currentUserEmail!,
                "classID": classID,
                "image": base64String
            ]
            let data = try! JSONSerialization.data(withJSONObject: parameters, options: JSONSerialization.WritingOptions.prettyPrinted)
            
            let json = NSString(data: data, encoding: String.Encoding.utf8.rawValue)
            request.httpBody = json!.data(using: String.Encoding.utf8.rawValue);
            let session = URLSession(configuration: .default)
            let task = session.dataTask(with: request , completionHandler: handle(data : response: error:))
            task.resume()
        }
    }
    
    static func performEnrollRequest(fname:String, lname:String, studentID:String, classID:String, image: UIImage){
        if let url = URL(string: K.Endpoints.enrollURL){
            var request = URLRequest(url: url, cachePolicy: .reloadIgnoringLocalCacheData)
            request.httpMethod = "POST"
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
            
            guard let imgData = image.pngData() else { return }
            let base64String = imgData.base64EncodedString(options: .lineLength64Characters)
            let parameters: [String: String] = [
                "first name": fname,
                "last name": lname,
                "id": studentID,
                "classID": classID,
                "image": base64String
            ]
            let data = try! JSONSerialization.data(withJSONObject: parameters, options: JSONSerialization.WritingOptions.prettyPrinted)
            
            let json = NSString(data: data, encoding: String.Encoding.utf8.rawValue)
            request.httpBody = json!.data(using: String.Encoding.utf8.rawValue);
            let session = URLSession(configuration: .default)
            let task = session.dataTask(with: request , completionHandler: handle(data : response: error:))
            task.resume()
        }
    }
    
    static func performDeleteRequest(fname:String, lname:String, studentID:String, classID:String){
        if let url = URL(string: K.Endpoints.deleteURL){
            var request = URLRequest(url: url, cachePolicy: .reloadIgnoringLocalCacheData)
            request.httpMethod = "DELETE"
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
            
            let parameters: [String: String] = [
                "first name": fname,
                "last name": lname,
                "id": studentID,
                "classID": classID
            ]
            let data = try! JSONSerialization.data(withJSONObject: parameters, options: JSONSerialization.WritingOptions.prettyPrinted)
            
            let json = NSString(data: data, encoding: String.Encoding.utf8.rawValue)
            request.httpBody = json!.data(using: String.Encoding.utf8.rawValue);
            let session = URLSession(configuration: .default)
            let task = session.dataTask(with: request , completionHandler: handle(data : response: error:))
            task.resume()
        }
    }
    
    static func handle(data: Data?, response:URLResponse?, error:Error?){
        if error != nil{
            print(error!)
            return
        }
        if let safeData = data {
            let dataString = String(data:safeData, encoding: .utf8)
            print(dataString!)
        }
    }
}
