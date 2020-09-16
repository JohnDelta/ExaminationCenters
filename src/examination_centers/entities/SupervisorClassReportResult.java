package examination_centers.entities;

public class SupervisorClassReportResult {
	
    String id_student;
    String username;
    String name;
    String lastname;
    String score;

    public SupervisorClassReportResult(String id_student, String username, String name, String lastname, String score) {
        this.id_student = id_student;
        this.username = username;
        this.name = name;
        this.lastname = lastname;
        this.score = score;
    }

    public String getId_student() {
        return id_student;
    }

    public String getUsername() {
        return username;
    }

    public String getName() {
        return name;
    }

    public String getLastname() {
        return lastname;
    }

    public String getScore() {
        return score;
    }
    
}