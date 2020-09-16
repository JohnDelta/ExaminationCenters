
package examination_centers.entities;

public class ExamReport {
	
    private String id_class_has_user;
    private String name;
    private String username;
    private String lastname;
    private String id_class;
    private String id_exam;
    private String score;

    public ExamReport(String id_class_has_user, String name, String username, String lastname, String id_class, String id_exam, String score) {
        this.id_class_has_user = id_class_has_user;
        this.name = name;
        this.username = username;
        this.lastname = lastname;
        this.id_class = id_class;
        this.id_exam = id_exam;
        this.score = score;
    }

    public String getId_class_has_user() {
        return id_class_has_user;
    }

    public String getName() {
        return name;
    }

    public String getUsername() {
        return username;
    }

    public String getLastname() {
        return lastname;
    }

    public String getId_class() {
        return id_class;
    }

    public String getId_exam() {
        return id_exam;
    }

    public String getScore() {
        return score;
    }
    
}