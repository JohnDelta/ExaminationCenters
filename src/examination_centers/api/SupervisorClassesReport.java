package examination_centers.api;

import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Statement;

import com.google.gson.Gson;

import examination_centers.database.Database;
import examination_centers.entities.SupervisorClassesReportResult;

/*
 * Retrieves representation of an instance of SupervisorClassesReport
 */

public class SupervisorClassesReport {

	public String getJson(String id_user) {
		
		String result=null;
        try {
            Connection connection = new Database().getConnection();
            Statement statement = connection.createStatement();
            Statement statement2 = connection.createStatement();
            ResultSet rs,rs2;
            String role="";
            int i;
            int numberOfClasses=0;
            String numberOfStudents="0";
            //get the user's role to check if he is a supervisor (role == 1)
            String sql = "select role from user where id_user = '"+id_user+"'";
            rs = statement.executeQuery(sql);
            if(rs.next()) {
                role = rs.getString("role");
            }
            rs.close();
            if(role.equals("1")) {
                //set-up the result array
                sql = "select count(*) from class_has_user where id_user = '"+id_user+"'";
                rs = statement.executeQuery(sql);
                if(rs.next()) {
                    numberOfClasses = rs.getInt("count(*)");
                }
                rs.close();
                SupervisorClassesReportResult[] report = new SupervisorClassesReportResult[numberOfClasses];
                //get his classes
                sql = "select * from class_has_user where id_user = '"+id_user+"'";
                rs = statement.executeQuery(sql);
                i=0;
                while(rs.next()) {
                    //get number of students of every class
                    sql = "select count(distinct user.id_user) from user,class_has_user where class_has_user.id_class ="
                            + " '"+rs.getString("id_class")+"' and user.id_user = class_has_user.id_user"
                            + " and user.role = '2'";
                    rs2 = statement2.executeQuery(sql);
                    if(rs2.next()){
                        numberOfStudents = rs2.getString("count(distinct user.id_user)");
                    }
                    rs2.close();
                    //for every class find all info
                    sql = "select * from class,examination,subject where class.id_examination"
                            + " = examination.id_examination and examination.id_subject = "
                            + "subject.id_subject and class.id_class = '"+rs.getString("id_class")+"'";
                    rs2 = statement2.executeQuery(sql);
                    if(rs2.next()){
                        //create the object result
                        report[i] = new SupervisorClassesReportResult(rs2.getString("class.id_class"),rs2.getString("class.name"),
                        rs2.getString("examination.open"),rs2.getString("examination.date"),
                        rs2.getString("subject.title"),numberOfStudents);
                    }
                    rs2.close();
                    i++;
                }
                rs.close();
                if(report.length > 0) {
                	result = new Gson().toJson(report);
                }
            } else {
                result = null;
            }
            connection.close(); 
        } catch(SQLException e) {
            e.printStackTrace();
        }
        if(result==null) {
            result = new Gson().toJson("no-result");
        }
        return result;
	}
	
}
