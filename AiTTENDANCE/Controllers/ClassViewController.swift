//
//  ClassViewController.swift
//  AiTTENDANCE
//
//  Created by Tracy Farah on 21/07/2022.
//

import UIKit
import FirebaseAuth
import FirebaseFirestore
import SwiftyJSON

class ClassViewController: UIViewController{
    
    var className:String?
    
    var students: [Student] = [Student(firstName: "tracy", lastName: "farah", id: "201902400")]
    
    var loaded = false
    
    @IBOutlet weak var tableView: UITableView!
    
    @IBOutlet weak var addStudentButton: UIButton!
    @IBOutlet weak var takeAttendanceButton: UIButton!
    
    let db = Firestore.firestore()
    let user = Auth.auth().currentUser?.uid
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = className
        
        takeAttendanceButton.addTarget(self, action: #selector(handleTakePhoto), for: .touchUpInside)
        
        tableView.dataSource = self
        
        loadStudents()
        
    }
    
    
    //retrieve students from db and load them into tableview
    func loadStudents()
    {
        self.students = []
        self.db.collection("users").document(self.user!)
            .collection(K.FStore.collectionName)
            .document(className!)
            .addSnapshotListener { (querySnapshot, error) in
                if let e = error{
                    print("There was an error retrieving data from the database, \(e)")
                }else{
                    self.students = []
                    if let data = querySnapshot?.data(){
                        if let students = (data[K.FStore.studentCollection] as? NSArray){
                            for s in students{
                                let student = s as AnyObject
                                let firstName = student.value(forKey: K.FStore.studentFName) as! String
                                let lastName = student.value(forKey: K.FStore.studentLName) as! String
                                let studentID = student.value(forKey: K.FStore.studentID) as! String
                                let newStudent = Student(firstName: firstName , lastName: lastName, id: studentID)
                                self.students.append(newStudent)
                                DispatchQueue.main.async{
                                    self.tableView.reloadData()
                                }
                            }
                        }
                    }
                }
            }
        self.loaded = true
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == K.addStudentSegue {
            let controller = segue.destination as! StudentFormViewController
            controller.className = className
        }
    }
    
    
    
    @IBAction func addStudentPressed(_ sender: UIButton) {
        performSegue(withIdentifier: K.addStudentSegue, sender: self)
    }
    
    //take attendance button pressed
    @objc private func handleTakePhoto() {
        let alertController = UIAlertController(title: "No students", message: "There are no enrolled students in this class", preferredStyle: .alert)
        
        let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
        alertController.addAction(okAction)
        
        if students.count == 0{
            present(alertController, animated: true, completion: nil)
        }else{
            let cameraController = CustomCameraController()
            cameraController.className = className
            self.present(cameraController, animated: true, completion: nil)
        }
    }
    
    
    @IBAction func signOutPressed(_ sender: UIBarButtonItem) {
        do {
            try Auth.auth().signOut()
            navigationController?.popToRootViewController(animated: true)
        } catch let signOutError as NSError {
            print("Error signing out: %@", signOutError)
        }
    }
    
    func confirmDelete(indexPath: IndexPath) {
        let studentToDelete = [K.FStore.studentFName: self.students[indexPath.row].firstName,
            K.FStore.studentLName: self.students[indexPath.row].lastName,
        K.FStore.studentID: self.students[indexPath.row].id]
        
        let alert = UIAlertController(title: "Delete Student", message: "Are you sure you want to permanently delete student \(self.students[indexPath.row].firstName)?", preferredStyle: .actionSheet)
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        let deleteAction = UIAlertAction(title: "Delete", style: .destructive){ _ in
            
            self.db.collection("users").document(self.user!).collection(K.FStore.collectionName).document(self.className!).updateData([
                "students": FieldValue.arrayRemove([studentToDelete])])
            { err in
                if let err = err {
                    print("Error updating document: \(err)")
                } else {
                    print("Document successfully updated")
                }
            }
            self.students.remove(at: indexPath.row)
            self.tableView.deleteRows(at: [indexPath], with: .none)
            self.tableView.reloadData()
        }
        alert.addAction(deleteAction)
        alert.addAction(cancelAction)
        
        self.present(alert, animated: true, completion: nil)
    }
}

extension ClassViewController: UITableViewDataSource{
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if loaded == true && students.count == 0 {
            self.tableView.setEmptyMessage("No students added yet.")
        } else {
            self.tableView.restore()
        }
        return students.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: K.studentTableCell, for: indexPath)
        let name = students[indexPath.row].firstName.capitalized + " " + students[indexPath.row].lastName.capitalized
        cell.textLabel?.text = students[indexPath.row].id + " - " + name
        return cell
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            confirmDelete(indexPath: indexPath)
        }
    }
}
