package examination_centers.api;

import java.io.IOException;
import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Statement;
import java.util.Date;
import java.util.Random;

import com.google.gson.Gson;

import examination_centers.database.Database;
import examination_centers.entities.Answer;
import examination_centers.entities.Question;
import examination_centers.entities.Results;

/*
 * This web service is used by the students.
 * The student sends the id_user and the id_class.
 * 
 * On GET Method The WS checks the examination of the class and depending on the state (initial , running , end)
 * and the state of the student (did not participate , participate and answer few questions , answered all questions)
 * creates the proper json file with the results from questions or results from answers
 * 
 * On PUT Method the WS takes the id_user, id_class,id_question,date and answer
 * then checks if the answer is correct and stores it to database
 * 
 */

public class Exam {
	
	public String getJson(String id_user, String id_class) {
		
		String result=null;
        try {
            Connection connection = new Database().getConnection();
            
            Statement statement = connection.createStatement();
            Statement statement2 = connection.createStatement();
            Statement statement3 = connection.createStatement();
            ResultSet[] rs = new ResultSet[16];
            String sql=null;
            int i=0;
            int open=0;
            String id_subject="";
            int count=0;
            
            //CHECK THE STATE OF THE EXAM
            sql="select examination.open, examination.id_subject from class,examination "
                    + "where class.id_examination = examination.id_examination "
                    + "and class.id_class = "+id_class+"";
            rs[0] = statement.executeQuery(sql);
            if(rs[0].next()){
                open = rs[0].getInt("examination.open");
                id_subject = rs[0].getString("examination.id_subject");
            }
            rs[0].close();
            sql = "select count(*) from class_has_user where id_user = '"+id_user+"' "
                    + "and id_class = '"+id_class+"'";
            rs[1] = statement.executeQuery(sql);
            if(rs[1].next()){
                count = rs[1].getInt("count(*)");
            }
            rs[1].close();
            switch (open) {
                case 0:
                //ON 0 THE EXAM IS IN INITIAL CLOSED STATE
                    result=new Gson().toJson("initial");
                    break;
                case 2:
                //ON 2 THE EXAM IS COMPLETED
                    //check if the user has questions - participate to the Exam
                    if(count==1) {
                        //user did not participated to the Exam
                        result=new Gson().toJson("no-result");
                    } else {
                        //send results
                        Results results[] = new Results[5]; 
                        //take user's questions
                        sql = "select * from class_has_user where id_user = '"+id_user+"' "
                            + "and id_class = '"+id_class+"'";
                        rs[3] = statement.executeQuery(sql);
                        i=0;
                        String check="";
                        String question="";
                        String userAnswer="";
                        String date="";
                        String correctAnswer="";
                        String correct = "0";
                        
                        while(rs[3].next()) {
                        	
                            String id_question = rs[3].getString("id_question");
                            userAnswer = rs[3].getString("answer");
                            date = rs[3].getString("date");
                            //check if the user answered the question
                            sql = "select correct from class_has_user where id_user = '"+id_user+"' "
                                    + "and id_class = '"+id_class+"' and id_question = '"+id_question+"'";
                            rs[15] = statement2.executeQuery(sql);
                            if(rs[15].next()){
                                correct = rs[15].getString("correct");
                            }
                            rs[15].close();
                            //take the question and the right answer
                            sql = "select * from question where id_question = '"+id_question+"'";
                            rs[4] = statement2.executeQuery(sql);
                            if(rs[4].next()) {
                                question = rs[4].getString("question");
                                correctAnswer = rs[4].getString("correct");
                            }
                            rs[4].close();
                            if(correct==null) {
                                //student did not answer
                                correct = "wrong";
                                userAnswer = " - ";
                                date = " - ";
                            } else {
                                //student answered
                                if(correct.equals("0")) correct = "wrong";
                                else if(correct.equals("1")) correct = "correct";
                            }
                            //create each result
                            results[i] = new Results(question,userAnswer,date,correct);
                            i++; 
                        }
                        rs[3].close();
                        result = new Gson().toJson(results);
                    }
                    break;
                    
                case 1:
                //ON 1 THE EXAM IS RUNNING
                    //next check the user state (Exam started, Exam continue, Exam complete)
                    if(count==1){
                        //GENERATE USER'S QUESTIONS
                        //get number of total questions
                        int n=0;
                        sql="select count(*) from question where id_subject = '"+id_subject+"'";
                        rs[5] = statement.executeQuery(sql);
                        if(rs[5].next()){
                            n = rs[5].getInt("count(*)");
                        }
                        rs[5].close();
                        //create a random number
                        Random r = new Random();
                        int Low = 1;
                        int High = n;
                        boolean flag=true;
                        //find 5 different questions and insert them to user
                        for(i=0;i<5;i++) {
                            flag=true;
                            while(flag) {
                                int random = r.nextInt(High-Low) + Low;
                                //select the random question
                                sql = "select id_question from question where id_subject = '"+id_subject+"'"
                                        + " LIMIT "+random+",1";
                                rs[6] = statement.executeQuery(sql);
                                String id_question="";
                                if(rs[6].next()){
                                    id_question = rs[6].getString("id_question");
                                }
                                rs[6].close();
                                //check if the user already has the random question
                                sql = "select count(*) from class_has_user where id_user = '"+id_user+"'"
                                            + " and id_class = '"+id_class+"' and id_question = '"+id_question+"'"; 
                                rs[7] = statement.executeQuery(sql);
                                if(rs[7].next()){
                                    if(rs[7].getInt("count(*)") ==0 ){
                                        if(i==0){
                                            //user the existant next row of user to store the question
                                            sql = "update class_has_user set id_question = '"+id_question+"'"
                                                    + " where id_class='"+id_class+"' and id_user = '"+id_user+"'";
                                        }else{
                                            //create 4 new entries for the rest of the questions
                                            sql = "insert into class_has_user (id_class,id_user,id_question) "
                                                + "values ('"+id_class+"','"+id_user+"','"+id_question+"')";
                                        }
                                        statement.executeUpdate(sql);
                                        flag=false; 
                                    }
                                }
                                rs[7].close();
                            } 
                        }
                        //take the questions and send them to user
                        sql = "select * from class_has_user where id_class = '"+id_class+"'"
                                + " and id_user = '"+id_user+"'";
                        rs[8] = statement.executeQuery(sql);
                        Question questions[] = new Question[5];
                        i=0;
                        while(rs[8].next()) {
                            sql = "select * from question where id_question = '"+rs[8].getString("id_question")+"'";
                            rs[9] = statement2.executeQuery(sql);
                            if(rs[9].next()){
                                questions[i] = new Question(rs[8].getString("id_question"),rs[9].getString("question"),
                                        rs[9].getString("answer1"),rs[9].getString("answer2"),
                                        rs[9].getString("answer3"),rs[9].getString("answer4"));
                                i++; 
                            }
                            rs[9].close();
                        }
                        rs[8].close();
                        result = new Gson().toJson(questions);
                    } else {
                        //CHECK IF THE QUESTIONS ARE ANSWERED
                        //get user's answered questions
                        sql = "select count(*) from class_has_user where id_user = '"+id_user+"' and "
                                + "id_class = '"+id_class+"' and answer is not null";
                        rs[10] = statement.executeQuery(sql);
                        if(rs[10].next()){
                            count = rs[10].getInt("count(*)");
                        }
                        rs[10].close();
                        if(count==5) {
                            //all questions answered , send the results
                            Results results2[] = new Results[5]; 
                            //take user's questions
                            sql = "select * from class_has_user where id_user = '"+id_user+"' and "
                                + "id_class = '"+id_class+"'";
                            rs[11] = statement.executeQuery(sql);
                            i=0;
                            String question="";
                            String correct="";
                            while(rs[11].next()){
                                String id_question = rs[11].getString("id_question");
                                correct = rs[11].getString("correct");
                                //get the question
                                sql = "select * from question where id_question = '"+id_question+"'";
                                rs[12] = statement2.executeQuery(sql);
                                if(rs[12].next()){
                                    question = rs[12].getString("question");
                                }
                                rs[12].close();
                                if(correct.equals("0")) correct = "wrong";
                                else if(correct.equals("1")) correct = "correct";
                                //create each result
                                results2[i] = new Results(question,rs[11].getString("answer"),
                                    rs[11].getString("date"),correct);
                                i++; 
                            }
                            rs[11].close();
                            result = new Gson().toJson(results2);
                        } else {
                            //send the rest of the questions
                            
                            sql = "select * from class_has_user where id_class = '"+id_class+"'"
                                + " and id_user = '"+id_user+"' and answer is null";
                            rs[13] = statement.executeQuery(sql);
                            Question questions[] = new Question[5];
                            i=0;
                            while(rs[13].next()){
                                sql = "select * from question where id_question = '"+rs[13].getString("id_question")+"'";
                                rs[14] = statement2.executeQuery(sql);
                                if(rs[14].next()){
                                    questions[i] = new Question(rs[13].getString("id_question"),rs[14].getString("question"),
                                            rs[14].getString("answer1"),rs[14].getString("answer2"),
                                            rs[14].getString("answer3"),rs[14].getString("answer4"));
                                    i++;
                                }
                                rs[14].close();
                            }
                            rs[13].close();
                            result = new Gson().toJson(questions);
                        }
                    }
                break;
            }
            
            statement.close();
            statement2.close();
            statement3.close();
            connection.close();
            
        } catch(SQLException e) {
        	e.printStackTrace();
        }
        
        return result;
	}
	
	
	public String putJson(String json) {
		Answer answer = new Gson().fromJson(json, Answer.class);
        try{
            Connection connection = new Database().getConnection();
            Statement statement = connection.createStatement();
            ResultSet rs = null;
            ResultSet rs2 = null;
            String correct = null;
            Date startDate = null;
            
            //get the exam start time
            String sql = "select examination.date from class,examination"
                    + " where id_class = '"+answer.id_class+"' and class.id_examination = examination.id_examination";
            int MINUTE_IN_MILLIS = 60000;
            rs = statement.executeQuery(sql);
            if(rs.next()){
                startDate = new Date(rs.getTimestamp("date").getTime() - MINUTE_IN_MILLIS * 60);
            }
            rs.close();
            //check if the student's answer is correct and answered in time
            sql = "select * from question where id_question = '"+answer.id_question+"'";
            rs2 = statement.executeQuery(sql);
            if(rs2.next()){
                Date endDate = new Date(startDate.getTime()+5*MINUTE_IN_MILLIS);
                Date answerDate = new Date(answer.date);
                //the answer time must be between start and end to be correct
                if(rs2.getString("correct").equals(answer.answer) && 
                    startDate.before(answerDate) && answerDate.before(endDate)){
                        correct = "1";
                }else{
                    correct = "0";
                }
            }
            rs2.close();
            
            //insert the result to db
            sql = "update class_has_user set answer = '"+answer.answer+"',"
                    + " date = '"+answer.date+"', correct = '"+correct+"'"
                    + " where id_user = '"+answer.id_user+"'"
                    + " and id_class = '"+answer.id_class+"'"
                    + " and id_question = '"+answer.id_question+"'";
            statement.executeUpdate(sql);
            statement.close();
            connection.close();
            
            //Take the students answer and save it to an exams log file.
            //Every log file contains all student's answers
            //on a specific class - exam that he is participated
            //Path to log file : NetBeansProjects\\WebApplication\\web\\repository
            //Format of student's log file : idClass_idUser.txt | example : 1_50.txt
//            String path = "C:\\Users\\devmode\\Documents\\NetBeansProjects\\WebApplication\\web\\repository\\";
//            try {
//            	
//                //create the student's file if it doesn't exists
//                File log = new File(path+"LOG_FILE_"+answer.id_class+"_"+answer.id_user+".txt");
//                log.createNewFile();
//                //append to it the user's answer
//                BufferedWriter writer = new BufferedWriter(new FileWriter(log,true));
//                writer.append("Answer : "+answer.answer);
//                writer.newLine();
//                writer.append("Id_question : "+answer.id_question);
//                writer.newLine();
//                writer.append("Date : "+answer.date);
//                writer.newLine();
//                writer.append("Correct : "+correct);
//                writer.newLine();
//                writer.newLine();
//                writer.close();
//            } catch (IOException ex) {
//	                ex.printStackTrace();
//            }
        } catch(SQLException e) {
            e.printStackTrace();
        }
        return new Gson().toJson("OK");
	}
}
