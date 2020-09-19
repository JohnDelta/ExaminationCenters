package examination_centers.entities;

public class Answer {
    public String id_user;
    public String id_class;
    public String id_question;
    public String answer;
    public String date;
    public String correct;

    public Answer(String id_user, String id_class, String id_question, String answer, String date, String correct) {
        this.id_user = id_user;
        this.id_class = id_class;
        this.id_question = id_question;
        this.answer = answer;
        this.date = date;
        this.correct = correct;
    }
}
