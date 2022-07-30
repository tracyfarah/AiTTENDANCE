//
//  Constants.swift
//  AiTTENDANCE
//
//  Created by Tracy Farah on 10/07/2022.
//

struct K {
    static let appName = "AiTTENDANCE"
    static let registerSegue = "RegistrationSuccessful"
    static let loginSegue = "LoginSuccessful"
    static let authError = "Invalid Credentials"
    static let cellIdentifier = "ReusableCell"
    static let studentTableCell = "StudentCell"
    static let tableCellSegue = "ClassSelectedSegue"
    static let addStudentSegue = "AddStudent"
    static let attendanceSegue = "TakeAttendance"
    
    struct Endpoints{
        static let attendanceURL = "http://192.168.1.104:5001/recognize"
        static let enrollURL = "http://192.168.1.104:5001/enroll"
    }
    
    struct BrandColors {
        static let blue = "BrandBlue"
        static let lighBlue = "BrandLightBlue"
    }
    
    struct FStore {
        static let collectionName = "classes"
        static let className = "className"
        static let classTime = "classTime"
        static let dateField = "date"
        static let studentCollection = "students"
        static let studentFName = "firstName"
        static let studentLName = "lastName"
        static let studentID = "studentID"
        static let studentImg = "image"
    }
}

