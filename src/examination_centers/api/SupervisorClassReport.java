package examination_centers.api;

import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Statement;

import com.google.gson.Gson;

import examination_centers.database.Database;
import examination_centers.entities.SupervisorClassReportResult;

/*
 * return the students of a class and if the exam is over their results too
 */

public class SupervisorClassReport {
	
	public String getJson(String id_class) {
		
		String result="";
        try {
            Connection connection = new Database().getConnection();
            Statement statement = connection.createStatement();
            Statement statement2 = connection.createStatement();
            ResultSet rs,rs2;
            
            //get the status of the exam (initial,running,expired)
            int numberOfStudents=0;
            String open="";
            int i=0;
            String sql = "select * from class,examination where class.id_examination = "
                    + "examination.id_examination and class.id_class = '"+id_class+"'";
            rs = statement.executeQuery(sql);
            if(rs.next()){
                open = rs.getString("examination.open");
            }
            rs.close();
            //set-up result array
            sql = "select count(distinct user.id_user) from class_has_user,user where "
                + "class_has_user.id_class = '"+id_class+"' and class_has_user.id_user = user.id_user"
                + " and user.role = '2'";
            rs = statement.executeQuery(sql);
            if(rs.next()){
                numberOfStudents = rs.getInt("count(distinct user.id_user)");
            }
            rs.close();
            //the class must have members
            if(numberOfStudents>0) {
                SupervisorClassReportResult[] report = new SupervisorClassReportResult[numberOfStudents];
                //find all students of the class
                sql = "select * from class_has_user,user where class_has_user.id_user = user.id_user "
                    + "and class_has_user.id_class = '"+id_class+"' and user.role = '2'"
                    + " group by user.id_user";
                rs = statement.executeQuery(sql);
                if(open.equals("0") || open.equals("1")) {
                    //there are no grades yet, show only student info
                    while(rs.next()) {
                        report[i] = new SupervisorClassReportResult(rs.getString("user.id_user"),rs.getString("user.username"),
                        rs.getString("user.name"),rs.getString("user.lastname")," - ");
                        i++;
                    }
                    rs.close();
                } else {
                    i=0;
                    while(rs.next()) {
                        int score=0;
                        //for every student, get the results
                        sql = "select * from class_has_user where id_class = '"+id_class+"'"
                            + " and id_user = '"+rs.getString("user.id_user")+"'";
                        rs2 = statement2.executeQuery(sql);
                        //for every question of student, check if there is an answer or no
                        while(rs2.next()) {
                            if(rs2.getString("answer")!=null) {
                                if(rs2.getString("correct").equals("1")) {
                                    score++;
                                }
                            }
                        }
                        rs2.close();
                        report[i] = new SupervisorClassReportResult(rs.getString("user.id_user"),
                            rs.getString("user.username"),rs.getString("user.name"),
                            rs.getString("user.lastname"),String.valueOf(score));
                        i++;
                    }
                    rs.close();
                }
                if(report.length > 0) {
                	result = new Gson().toJson(report);
                }
            } else {
                result = new Gson().toJson("no-result");
            }
            connection.close();
        } catch(SQLException e) {
            e.printStackTrace();
        }
        
        return result;
	}

}
