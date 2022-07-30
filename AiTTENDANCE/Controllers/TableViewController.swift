//
//  ClassesViewController.swift
//  AiTTENDANCE
//
//  Created by Tracy Farah on 16/07/2022.
//

import UIKit
import FirebaseAuth
import FirebaseFirestore

class TableViewController: UIViewController{
    
    @IBOutlet weak var tableView: UITableView!
    
    var loaded = false
    let db = Firestore.firestore()
    let user = Auth.auth().currentUser?.uid
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Classes"
        navigationItem.hidesBackButton = true
        tableView.dataSource = self
        tableView.delegate = self
        
        loadClasses()
        
    }
    var classes: [Class] = []
    
    
    //retrieve classes from db and load them into tableview
    func loadClasses(){
        self.classes = []
        db.collection("users").document(self.user!)
            .collection(K.FStore.collectionName)
            .order(by: K.FStore.dateField, descending: true)
            .addSnapshotListener { (querySnapshot, error) in
                if let e = error{
                    print("There was a error retrieving data from the database, \(e)")
                }else{
                    self.classes = []
                    if let snapshotDocuments = querySnapshot?.documents{
                        for doc in snapshotDocuments{
                            let data = doc.data()
                            if let name = data[K.FStore.className] as? String, let time = data[K.FStore.classTime] as? String{
                                let newClass = Class(title: name, time: time, students: [])
                                self.classes.append(newClass)
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
    
    //add new class
    @IBAction func handleAdd(_ sender : UIButton){
        let alertController = UIAlertController(title: "Add a new class", message: "Enter class details", preferredStyle: .alert)
        
        alertController.addTextField { (textField) in
            textField.placeholder = "Title"
        }
        alertController.addTextField { (textField) in
            textField.placeholder = "Time"
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        let saveAction = UIAlertAction(title: "Save", style: .default) { _ in
            
            if let className = alertController.textFields![0].text, let classTime  = alertController.textFields![1].text{
                self.db
                    .collection("users")
                    .document(self.user!)
                    .collection(K.FStore.collectionName)
                    .document(className)
                    .setData([K.FStore.className: className,
                              K.FStore.classTime: classTime,
                              K.FStore.dateField: Date.timeIntervalSinceReferenceDate,
                              K.FStore.studentCollection: [:]])
                {(error) in
                    if let e = error{
                        print("There was an issue saving data to the firestore, \(e)")
                    }else{
                        print("Successfuly saved data")
                    }
                }
            }
        }
        alertController.addAction(cancelAction)
        alertController.addAction(saveAction)
        
        present(alertController, animated: true, completion: nil)
    }
    
    
    //sign out user
    @IBAction func signOutPressed(_ sender: UIBarButtonItem) {
        do {
            try Auth.auth().signOut()
            navigationController?.popToRootViewController(animated: true)
        } catch let signOutError as NSError {
            print("Error signing out: %@", signOutError)
        }
    }
    
    func confirmDelete(indexPath: IndexPath) {
        let alert = UIAlertController(title: "Delete Student", message: "Are you sure you want to permanently delete \(self.classes[indexPath.row].title)?", preferredStyle: .actionSheet)
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        let deleteAction = UIAlertAction(title: "Delete", style: .destructive){ _ in
            
            print("Deleted")
            self.db.collection("users").document(self.user!).collection(K.FStore.collectionName).document(self.classes[indexPath.row].title).delete() { err in
                if let err = err {
                    print("Error removing document: \(err)")
                } else {
                    print("Document successfully removed!")
                }
            }
            self.classes.remove(at: indexPath.row)
            self.tableView.deleteRows(at: [indexPath], with: .none)
            self.tableView.reloadData()
        }
        alert.addAction(deleteAction)
        alert.addAction(cancelAction)
        
        self.present(alert, animated: true, completion: nil)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == K.tableCellSegue {
            if let indexPath = self.tableView.indexPathForSelectedRow {
                let controller = segue.destination as! ClassViewController
                controller.className = classes[indexPath.row].title //pass classname of selected class to next controller
            }
        }
    }
}

extension TableViewController: UITableViewDataSource{
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if loaded == true && classes.count == 0 {
            self.tableView.setEmptyMessage("No classes added yet.")
        } else {
            self.tableView.restore()
        }
        return classes.count
    }
    
    //display tableview cells
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: K.cellIdentifier, for: indexPath)
        cell.textLabel?.text = classes[indexPath.row].title + " " + classes[indexPath.row].time
        return cell
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath){
        if editingStyle == .delete {
            confirmDelete(indexPath: indexPath)
        }
    }
}

extension TableViewController: UITableViewDelegate{
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print(indexPath.row)
        performSegue(withIdentifier: K.tableCellSegue, sender: self)
    }
}

extension UITableView {
    
    func setEmptyMessage(_ message: String) {
        let messageLabel = UILabel(frame: CGRect(x: 0, y: 0, width: self.bounds.size.width, height: self.bounds.size.height))
        messageLabel.text = message
        messageLabel.textColor = .black
        messageLabel.numberOfLines = 0
        messageLabel.textAlignment = .center
        messageLabel.font = UIFont(name: "TrebuchetMS", size: 15)
        messageLabel.sizeToFit()
        
        self.backgroundView = messageLabel
        self.separatorStyle = .none
    }
    
    func restore() {
        self.backgroundView = nil
        self.separatorStyle = .singleLine
    }
}
