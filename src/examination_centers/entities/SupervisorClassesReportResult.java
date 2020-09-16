
package examination_centers.entities;

public class SupervisorClassesReportResult {
	
    String id_class;
    String className;
    String examOpen;
    String examDate;
    String subjectTitle;
    String numberOfStudents;

    public SupervisorClassesReportResult(String id_class, String className, String examOpen, String examDate, String subjectTitle, String numberOfStudents) {
        this.id_class = id_class;
        this.className = className;
        this.examOpen = examOpen;
        this.examDate = examDate;
        this.subjectTitle = subjectTitle;
        this.numberOfStudents = numberOfStudents;
    }

    public String getId_class() {
        return id_class;
    }

    public String getClassName() {
        return className;
    }

    public String getExamOpen() {
        return examOpen;
    }

    public String getExamDate() {
        return examDate;
    }

    public String getSubjectTitle() {
        return subjectTitle;
    }

    public String getNumberOfStudents() {
        return numberOfStudents;
    }
    
}