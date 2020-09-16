# ExaminationCenters

## Description
Concept project of an online examinations system.

### Using ECLIPSE IDE
- Dynamic Web 4+ project
- M2Eclipse plug-in for Maven
- Have installed software: Web, XML, Java EE and OSGi Enterprise Development

## Utilized (and Dependencies):
- Server: Tomcat EE PLUS v9
- JAX-RS API: Jersey
- POM: Maven

- Database: MySQL | mysql-connector-java
- Access Microsoft Format Files: POI 3.17 & POI-OOXLM
- Json: Gson 2.8.5
- Types that extend the Java Collections Framework: Commons.Collections 4

## Package info - structure:
- WebContent
- JavaResources

## Installation (using Eclipse IDE)
- Import git project and clone

## Concept info - methods/Services

### Admin
- Create /Delete /Alter /Fetch (all & by ID) Users
- Create /Delete /Alter /Fetch (all & by ID) Courses
- Create /Delete /Alter Exams (manage from courses)
- Create /Delete /Alter Questions (manage from courses)
- Create /Delete /Alter PossibleAnswers (manage from questions)
- Create /Delete /Alter UserHasCourses (manage from courses)
- Create /Delete /Alter UserHasQuestions (manage from exams)
- Create /Delete /Alter UserHasAnswers (manage from exams)

### Querries
- Fetch users by course ID
- Fetch users by exam ID
- Fetch courses by user ID
- Fetch exams by course ID
- Fetch questions by course ID
- Fetch answers by questions ID
- Fetch user's answers and questions by user, exam ID
