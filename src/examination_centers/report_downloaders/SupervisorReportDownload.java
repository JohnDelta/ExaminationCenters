package examination_centers.report_downloaders;

import java.io.File;
import java.io.FileInputStream;
import java.io.FileOutputStream;
import java.io.IOException;
import java.io.PrintWriter;
import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Statement;
import java.util.logging.Level;
import java.util.logging.Logger;
import javax.servlet.ServletException;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import org.apache.poi.ss.usermodel.Cell;
import org.apache.poi.ss.usermodel.CellStyle;
import org.apache.poi.ss.usermodel.CreationHelper;
import org.apache.poi.ss.usermodel.Font;
import org.apache.poi.ss.usermodel.IndexedColors;
import org.apache.poi.ss.usermodel.Row;
import org.apache.poi.ss.usermodel.Sheet;
import org.apache.poi.ss.usermodel.Workbook;
import org.apache.poi.xssf.usermodel.XSSFWorkbook;

import examination_centers.entities.SupervisorClassReportResult;

public class SupervisorReportDownload extends HttpServlet {
    /**
	 * 
	 */
	private static final long serialVersionUID = 2L;

	@Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        SupervisorClassReportResult[] report = null;
        String id_class = request.getParameter("id_class");
        try {
            Class.forName("com.mysql.jdbc.Driver");
            String database = "jdbc:mysql://localhost:3306/examination_centers?user=pma&password=026849";
            Connection connection = DriverManager.getConnection(database);
            Statement statement = connection.createStatement();
            /*  GET AN OBJECT OF CLASSES STUDENT'S RESULTS - START   */
            String result="";
            Statement statement2 = connection.createStatement();
            ResultSet rs,rs2;
            //get the status of the exam (initial,running,expired)
            int numberOfStudents=0;
            String open="";
            int i=0;
            String sql = "select * from class,examination where class.id_examination = "
                    + "examination.id_examination and class.id_class = '"+id_class+"'";
            rs = statement.executeQuery(sql);
            if(rs.first()){
                open = rs.getString("examination.open");
            }
            rs.close();
            //set-up result array
            sql = "select count(distinct user.id_user) from class_has_user,user where "
                    + "class_has_user.id_class = '"+id_class+"' and class_has_user.id_user = user.id_user"
                    + " and user.role = '2'";
            rs = statement.executeQuery(sql);
            if(rs.first()){
                numberOfStudents = rs.getInt("count(distinct user.id_user)");
            }
            rs.close();
            //the class must have members
            if(numberOfStudents>0){
                report = new SupervisorClassReportResult[numberOfStudents];
                //find all students of the class
                sql = "select * from class_has_user,user where class_has_user.id_user = user.id_user "
                        + "and class_has_user.id_class = '"+id_class+"' and user.role = '2'"
                        + " group by user.id_user";
                rs = statement.executeQuery(sql);
                if(open.equals("0") || open.equals("1")){
                    //there are no grades yet, show only student info
                    i=0;
                    while(rs.next()){
                        report[i] = new SupervisorClassReportResult(rs.getString("user.id_user"),rs.getString("user.username"),
                                rs.getString("user.name"),rs.getString("user.lastname")," - ");
                        i++;
                    }
                    rs.close();
                }else{
                    i=0;
                    while(rs.next()){
                        int score=0;
                        //for every student, get the results
                        sql = "select * from class_has_user where id_class = '"+id_class+"'"
                                + " and id_user = '"+rs.getString("user.id_user")+"'";
                        rs2 = statement2.executeQuery(sql);
                        //for every question of student, check if there is an answer or no
                        while(rs2.next()){
                            if(rs2.getString("correct")!=null){
                                if(rs2.getString("correct").equals("1")){
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
                //results
            }else{
                //no results
            }
            connection.close();
            
            } catch (ClassNotFoundException | SQLException ex) {
                Logger.getLogger(SupervisorReportDownload.class.getName()).log(Level.SEVERE, null, ex);
            }
            /*  GET AN OBJECT OF CLASSES STUDENT'S RESULTS - END   */
            /*  CREATE THE EXCEL FILE WITH THE RESULT OF THE OBJECT - START  */
            //excel code from : https://www.callicoder.com/java-write-excel-file-apache-poi
            String[] excelColumns = {"Account ID","Name","Lastname","Examination Center ID", "Mark"};
            if(report!=null){
                // Create a Workbook
                Workbook workbook = new XSSFWorkbook(); // new HSSFWorkbook() for generating `.xls` file
                /* CreationHelper helps us create instances of various things like DataFormat,
                Hyperlink, RichTextString etc, in a format (HSSF, XSSF) independent way */
                CreationHelper createHelper = workbook.getCreationHelper();
                // Create a Sheet
                Sheet sheet = workbook.createSheet("Students");
                // Create a Font for styling header cells
                Font headerFont = workbook.createFont();
                headerFont.setBold(true);
                headerFont.setFontHeightInPoints((short) 14);
                headerFont.setColor(IndexedColors.BLUE.getIndex());
                // Create a CellStyle with the font
                CellStyle headerCellStyle = workbook.createCellStyle();
                headerCellStyle.setFont(headerFont);
                // Create a Row
                Row headerRow = sheet.createRow(0);
                // Create cells
                for(int x = 0; x < excelColumns.length; x++) {
                    Cell cell = headerRow.createCell(x);
                    cell.setCellValue(excelColumns[x]);
                    cell.setCellStyle(headerCellStyle);
                }
                // Create Other rows and cells with students data
                int rowNum = 1;
                for(SupervisorClassReportResult student : report) {
                    Row row = sheet.createRow(rowNum++);
                    row.createCell(0).setCellValue(student.getUsername());
                    row.createCell(1).setCellValue(student.getName());
                    row.createCell(2).setCellValue(student.getLastname());
                    row.createCell(3).setCellValue(id_class);
                    row.createCell(4).setCellValue(student.getScore());
                }
                // Resize all columns to fit the content size
                for(int x = 0; x < excelColumns.length; x++) {
                    sheet.autoSizeColumn(x);
                }
                // Write the output to a file
                String uploadFolder = getServletContext().getRealPath("")+ File.separator + "repository\\";
                FileOutputStream fileOut = new FileOutputStream(uploadFolder+"studentResults.xlsx");
                workbook.write(fileOut);
                fileOut.close();
                // Closing the workbook
                workbook.close();
                /*  CREATE THE EXCEL FILE WITH THE RESULT OF THE OBJECT - END   */

                /*  DOWNLOAD THE CREATED FILE END DELETE IT - START */
                /*  START - DOWNLOAD FILE    */
                /*download file from servlet code : 
                    http://java.candidjava.com/tutorial/File-download-example-using-servlet-and-jsp.htm
                */
                // reads input file from an absolute path
                response.setContentType("text/html");
				PrintWriter out = response.getWriter();
				String filename = "studentResults.xlsx";
				String filepath = uploadFolder;
				response.setContentType("APPLICATION/OCTET-STREAM");
				response.setHeader("Content-Disposition", "attachment; filename=\""+ filename + "\"");
				// use inline if you want to view the content in browser, helpful for
				// pdf file
				// response.setHeader("Content-Disposition","inline; filename=\"" +
				// filename + "\"");
				FileInputStream fileInputStream = new FileInputStream(filepath+ filename);
				int i;
				while ((i = fileInputStream.read()) != -1) {
					out.write(i);
				}
				fileInputStream.close();
				out.close();
                /*  DOWNLOAD THE CREATED FILE END DELETE IT - END   */
                //out.print("<script>window.location.replace('supervisor-class-insert.jsp');</script>");
            }
    }

}
