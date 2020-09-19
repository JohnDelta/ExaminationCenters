package examination_centers.entities;

public class Results {
	String type;
    String qst;
    String ans;
    String date;
    String correct;

    public Results(String qst, String ans, String date, String correct) {
        this.type = "result";
        this.qst = qst;
        this.ans = ans;
        this.date = date;
        this.correct = correct;
    }
}
