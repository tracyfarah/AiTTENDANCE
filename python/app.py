import face_recognition
from flask import Flask, jsonify, request, redirect
from flask_restful import Resource, Api, reqparse
import json
import smtplib
import csv
import os
from email.message import EmailMessage
from datetime import date
import base64
import numpy as np

app = Flask(__name__)
api = Api(app)

today = date.today().strftime("%d_%m_%Y")

#generate a csv file with the attendance records
def generateReport(recognized, classID):
    filename = "AttendanceSheet_" + classID + "_" + today + ".csv"
    with open("encodings.json") as json_file:
        data = json.load(json_file)
        with open(filename, "w") as file:
            writer = csv.writer(file, delimiter=",", lineterminator="\n")
            writer.writerow(["ID", "Name", "Attendance"])
            for i in range(len(data[classID])):
                present = False
                student = data[classID][i].get("name")
                id = data[classID][i].get("id")
                if student in recognized:
                    present = True
                if present:
                    writer.writerow([id, student, "Present"])
                else:
                    writer.writerow([id, student, "Absent"])
    return filename


#send an email to the user
def sendMail(filename, email):
    email_sender = ""
    password = "" #removed for security purpose
    receiver = email
    subject = "Attendance Report for " + date.today().strftime("%d/%m/%Y")
    body = "Kindly find the attendance sheet attached below"

    em = EmailMessage()
    em["From"] = email_sender
    em["To"] = receiver
    em["Subject"] = subject
    em.set_content(body)
    em.add_attachment(open(filename, "r").read(), filename=filename)

    with smtplib.SMTP("smtp.gmail.com", 587) as smtp:
        smtp.ehlo()
        smtp.starttls()
        smtp.ehlo()

        smtp.login(email_sender, password)
        print("logged in")
        smtp.sendmail(email_sender, receiver, em.as_string())
        print("email sent")
        smtp.quit()


def addNewStudent(id, name, classID, file):
    img = face_recognition.load_image_file(file)
    unknown_face_encodings = face_recognition.face_encodings(img)[0].tolist()  # first encoding index 0 because we are adding single image of student
    jsonData = {"id": id, "name": name, "encodings": unknown_face_encodings}
    write_json(jsonData, classID)


def detect_faces_in_image(file_stream, classID):
    # Load the uploaded image file
    img = face_recognition.load_image_file(file_stream)
    # Get 128-dimension face encodings for any faces in the uploaded image
    unknown_face_encodings = face_recognition.face_encodings(img)
    present = []

    face_found = False
    has_match = False

    if len(unknown_face_encodings) > 0:
        face_found = True

        with open("encodings.json") as json_file:
            data = json.load(json_file)
            for encoding in unknown_face_encodings:
                for person in data[classID]:
                #Compare a list of face encodings against a candidate encoding to see if they match.
                    match_results = face_recognition.compare_faces(
                        [np.array(person.get("encodings"))], encoding
                    )
                    if match_results[0]:
                        has_match = True
                        present.append(person.get("name"))
    return present

#insert new data into the file
def write_json(new_data, classID):
    with open("encodings.json", "r+") as file:
        # First we load existing data into a dict.
        file_data = json.load(file)
        # Join new_data with file_data
        if classID not in file_data:
            file_data[classID] = []
        if new_data not in file_data[classID]:
            file_data[classID].append(new_data)
        # Sets file's current position at offset.
        file.seek(0)
        # convert back to json and add to file.
        json.dump(file_data, file, indent=4)
        
#delete student from a class
def delete_student(classID, std, id):
    with open("encodings.json", "r+") as file:
        # First we load existing data into a dict.
        file_data = json.load(file)
        students = file_data[classID]
        print(students)
        for student in students:
            if student.get("name") == std and student.get("id") == id:
                students.pop(students.index(student))
                file_data[classID] = students
    with open("encodings.json", "w") as file:
        file.seek(0)
        file.write(json.dumps(file_data))


# API ENDPOINTS

class ProcessImage(Resource):
    def post(self):
        people = []
        data = json.loads(request.data)
        base64str = data["image"]
        classID = data["classID"]
        email = data["email"]
        filename = data["classID"] + ".png"
        with open(filename, "wb") as fh:
            fh.write(base64.b64decode(base64str))
        with open(filename, "rb") as file:
            people = detect_faces_in_image(file, classID)
            os.remove(filename)
        filename = generateReport(people, classID)
        sendMail(filename, email)
        return people


class EnrollStudent(Resource):
    def post(self):
        data = json.loads(request.data)
        fname = data["first name"]
        lname = data["last name"]
        name = fname + " " + lname
        studentID = data["id"]
        classID = data["classID"]
        base64str = data["image"]
        filename = name + ".png"
        with open(filename, "wb") as fh:
            fh.write(base64.b64decode(base64str))
        with open(filename, "rb") as file:
            addNewStudent(studentID, name, classID, file)
            os.remove(filename)

class DeleteStudent(Resource):
    def delete(self):
        data = json.loads(request.data)
        firstname = data["first name"]
        lastname = data["last name"]
        studentID = data["id"]
        classID = data["classID"]
        fullname = firstname +" "+ lastname
        delete_student(classID, fullname, studentID)

api.add_resource(ProcessImage, "/recognize")
api.add_resource(EnrollStudent, "/enroll")
api.add_resource(DeleteStudent, "/delete")

if __name__ == "__main__":
    app.run(host="0.0.0.0", port=5001, debug=True)


