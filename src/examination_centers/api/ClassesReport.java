package examination_centers.api;

import java.sql.Connection;

import java.sql.DriverManager;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Statement;
import java.util.ArrayList;

import com.google.gson.Gson;

import examination_centers.database.Database;
import examination_centers.entities.*;

/*
 * Finds all students whose examination is over, order them
 * by class id , finds their results and print them
 */

public class ClassesReport {

	public String getJson() {
		
		ArrayList<ClassReport> report = new ArrayList<>();
        String result = "";
        
        try{
            Connection connection = new Database().getConnection();
            Statement statement = connection.createStatement();
            Statement statement2 = connection.createStatement();
            String sql;
            ResultSet rs,rs2;
            int size=0;
            int score=0;
            String name="";
            String username="";
            String lastname="";
            String id_class="";
            String id_exam="";
            String id_class_has_user="";

            
            //get all students ordered by their exam id, where their examination is over
            sql = "select * from user,class_has_user,class,examination where user.id_user = class_has_user.id_user" +
                " and class_has_user.id_class = class.id_class and examination.id_examination = class.id_examination" +
                " and user.role = '2' and examination.open = '2'" +
                " group by user.id_user,class.id_class" +
                " order by class.id_class ";
            rs = statement.executeQuery(sql);
            
            while(rs.next()){
            	
                //for every student find the number of his answers
                sql = "select count(*) from class_has_user where id_user = '"+rs.getString("user.id_user")+"'"
                        + " and id_class = '"+rs.getString("class.id_class")+"'";
                rs2 = statement2.executeQuery(sql);
                if(rs2.first()){
                    size = rs2.getInt("count(*)");
                }
                rs2.close();
                //set-up the basic info
                username = rs.getString("user.username");
                name = rs.getString("user.name");
                lastname = rs.getString("user.lastname");
                id_class = rs.getString("class.id_class");
                id_exam = rs.getString("examination.id_examination");
                id_class_has_user = rs.getString("class_has_user.id_class_has_user");
                if(size==1) {
                    //student did not participate to the exam
                    report.add(new ClassReport(id_class_has_user,name,username,lastname,id_class,id_exam," - "));
                } else if(size==5) {
                    //for every student get all his answers
                    sql = "select * from class_has_user where id_user = '"+rs.getString("user.id_user")+"'"
                        + " and id_class = '"+rs.getString("class.id_class")+"'";
                    rs2 = statement2.executeQuery(sql);
                    score=0;
                    //check if every question has an answer. if it has, take the result, if not, count it as wrong
                    while(rs2.next()){
                        if(rs2.getString("correct")!=null){
                            if(rs2.getString("correct").equals("1")){
                                score++;
                            }
                        }
                    }
                    rs2.close();
                    report.add(new ClassReport(id_class_has_user,name,username,lastname,id_class,id_exam,String.valueOf(score)));
                }else{
                    //not student
                }
            }
            rs.close();
            
        } catch(SQLException e) {
            e.printStackTrace();
        }
        result = new Gson().toJson(report);
        return result;
	}
	
}
