package examination_centers.entities;

public class Question {
	String type;
    String id_question;
    String qst;
    String ans1;
    String ans2;
    String ans3;
    String ans4;

    public Question(String id_question, String qst, String ans1, String ans2, String ans3, String ans4) {
        this.type = "question";
        this.id_question = id_question;
        this.qst = qst;
        this.ans1 = ans1;
        this.ans2 = ans2;
        this.ans3 = ans3;
        this.ans4 = ans4;
    }  
}
