# ExaminationCenters

## Description
Concept project of an online examinations system.

### Using ECLIPSE IDE
- Dynamic Web 4+ project
- M2Eclipse plug-in for Maven
- Have installed software: Web, XML, Java EE and OSGi Enterprise Development
- Window Builder (for the Swing GUI build)

## Utilized (and Dependencies):
- JDK 1.8
- Server: Tomcat EE PLUS v9
- JAX-RS API: Jersey
- Jaxb api for data binding
- POM: Maven
- Swing GUI framework
- Database: MySQL | mysql-connector-java
- Access Microsoft Format Files: POI 3.17 & POI-OOXLM
- Json: Gson 2.8.5
- Types that extend the Java Collections Framework: Commons.Collections 4, Commons.io, Commons.fileupload
- Jquery (for the website. Using CDN to import it)

## Package info - structure:
- WebContent (website)
- examination_centers.api (restfull web services, application and their endpoints)
- examination_centers.database contains (database configuration file)
- examination_centers.desktop_app (desktop application in Swing GUI)
- examination_centers.entities (database entities to manage data to/from json requests)
- examination_centers.report_downloaders (servlets handling the downloading of reports - queries)

## Installation (using Eclipse IDE)
- Import git project and clone it
- Go to DatabaseInfo folder, take the db script and run the query into your localhost database
- Go to examination_centers.database package and change the host database, password and username with your localhost credencials
- Start a TomEE PLUS 9v server (because we're using Jax-rs for the restfull wb)
- Create an Admin record in your database (role field = 0) to access the system as admin
- Start the Login.java file from the examination_centers.desktop_app to open the desktop application of the project
- Type http://localhost:8080/ExaminationCenters/index.jsp to start the web application of the system
- As an admin, you can go to the DatabaseInfo/ExcelDataFillers folder to upload records of data and not insert them hard-coded

## Info about the project's concept

### System roles
- Admin (role field = 0)
- Supervisor (role field = 1)
- Student (role field = 2)

### Admin (Access both with Desktop Application and the website)
- System Login/Logout
- View their profil
- Searches and views users
- Creates & Removes new users from form and excel file
- Declares users as supervisors of examination centers for form and excel
- Creates & Removes classes from form and excel file
- Creates & Removes questions from form and excel file
- Creates & Removes exams from form and excel file
- Creates & removes examination centers from form and excel file
- Views & Downloads to excel examination reports from student's based on the user ID
- Views & Downloads to excel examination reports from students based on the examination ID
- Views & Downloads to excel examination reports from students based on the examination centers ID

### Supervisor (Access both with Desktop Application and the website)
- System Login/Logout
- View their profil
- Views All examination centers which are under the supervision of them
- Inserts & Removes students to one of their examination centers from form and excel file
- Views students who are assigned on one of their examination centers
- Starts/ Stops/ Resets examination states, from examinations which are under their supervision
- Views and Download Examinations results
- Views Students answers from an examinations

### Student (Access only from the website)
- Views examinations in which his assigned
- View their profil
- Participates in exams when the exam is in state (running)

























