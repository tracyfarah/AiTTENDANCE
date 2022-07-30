# AiTTENDANCE

## About the Project
The project is an AI-based iOS mobile application that makes use of facial recognition technology to identify and verify a person and mark attendance automatically. <br />The main objective of this project is to make the attendance marking and management efficient, time saving, simple and easy. The user will only need to open the app, scan the faces using the device camera and the attendance will immediately be sent after facial recognition and verification. <br />The app uses Firebase for user authentication and storing data. The face recognition algorithms are connected to the app by a REST API running on a python Flask server.

## How to install and run the project
1- Clone the repo:
```
git clone https://github.com/tracyfarah/AiTTENDANCE.git
```
2- Open a terminal at the project directory and run `pod install` to install all the dependencies
```
pod install
```
3- Run the python script to open a connection to the server locally on your machine.
```
python app.py
```
4- Inside the XCode project (open AiTTENDANCE.xcodeproj), go to the Constants.swift file and change the two API endpoints URLs (the part before /enroll and /recognize) to the IP address that your server is running on.<br /><br />

5- Build and run the app.<br /><br />

## How to use the app
1- Login or register if you are a new user by entering your email and password.<br /><br />

2- The first time you are using the app:<br />
• Add your classes<br />
• Add all the students enrolled in that class by entering their first and last name, student ID number, and by uploading a clear picture of their face.<br /><br />

3- Choose the class you want and simply take attendance by clicking on 'Take Attendance'.<br /><br />

4- Take a picture of the class, showing the student's faces.<br />

You should then receive an email with the Excel attendance sheet on the same email you are logged in with.<br /><br />

Contact
Author: Tracy Farah - tracy.farah@gmail.com <br /><br />
LinkedIn: https://linkedin.com/in/tracyfarah
Project link: https://github.com/tracyfarah/AiTTENDANCE/
