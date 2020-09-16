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
import java.util.ArrayList;
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

import examination_centers.entities.AdminReport;

public class AdminReportDownload extends HttpServlet {

    /**
	 * 
	 */
	private static final long serialVersionUID = 1L;

	@Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        if(request.getParameter("downloadType")!=null){
            /*  GET AN OBJECT OF STUDENT'S RESULTS - START   */
            ArrayList<AdminReport> report = new ArrayList<>();
            //get the order type
            String downloadType = request.getParameter("downloadType");
            String type="user.id_user";
            if(downloadType.equals("student")) type = "class_has_user.id_class_has_user";
            else if(downloadType.equals("class")) type = "class.id_class";
            else if(downloadType.equals("exam")) type = "examination.id_examination";
            try{
                Class.forName("com.mysql.jdbc.Driver");
                String database = "jdbc:mysql://localhost:3306/examination_centers?user=pma&password=026849";
                Connection connection = DriverManager.getConnection(database);
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
                    " order by "+type;
                rs = statement.executeQuery(sql);
                while(rs.next()) {
                    //for every student find the number of his answers
                    sql = "select count(*) from class_has_user where id_user = '"+rs.getString("user.id_user")+"'"
                        + " and id_class = '"+rs.getString("class.id_class")+"'";
                    rs2 = statement2.executeQuery(sql);
                    if(rs2.first()) {
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
                        report.add(new AdminReport(id_class_has_user,name,username,lastname,id_class,id_exam," - "));
                    } else if(size==5) {
                        //for every student get all his answers
                        sql = "select * from class_has_user where id_user = '"+rs.getString("user.id_user")+"'"
                             + " and id_class = '"+rs.getString("class.id_class")+"'";
                        rs2 = statement2.executeQuery(sql);
                        score=0;
                        //check if every question has an answer. if it has, take the result, if not, count it as wrong
                        while(rs2.next()) {
                            if(rs2.getString("correct")!=null) {
                                if(rs2.getString("correct").equals("1")) {
                                    score++;
                                }
                            }
                        }
                        rs2.close();
                        report.add(new AdminReport(id_class_has_user,name,username,lastname,id_class,id_exam,String.valueOf(score)));
                    } else {
                        //not student
                    }
                }
                rs.close();
            } catch(SQLException | ClassNotFoundException e) {
                e.printStackTrace();
            }
            /*  GET AN OBJECT OF CLASSES STUDENT'S RESULTS - END   */
            
            /*  CREATE THE EXCEL FILE WITH THE RESULT OF THE OBJECT - START  */
            //excel code from : https://www.callicoder.com/java-write-excel-file-apache-poi
            String[] excelColumns = new String[7];
            if(downloadType.equals("student")){
                excelColumns[0]="Exam ID of Student";
                excelColumns[1]="Account ID";
                excelColumns[2]="Name";
                excelColumns[3]="Lastname";
                excelColumns[4]="Examination Center ID";
                excelColumns[5]="Examination ID";
                excelColumns[6]="Mark";
            }else if(downloadType.equals("exam")){
                excelColumns[0]="Examination ID";
                excelColumns[1]="Account ID";
                excelColumns[2]="Name";
                excelColumns[3]="Lastname";
                excelColumns[4]="Examination Center ID";
                excelColumns[5]="Mark";
            }else if(downloadType.equals("class")){
                excelColumns[0]="Examination Center ID";
                excelColumns[1]="Account ID";
                excelColumns[2]="Name";
                excelColumns[3]="Lastname";
                excelColumns[4]="Examination ID";
                excelColumns[5]="Mark";
            }
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
                for(AdminReport student : report) {
                    Row row = sheet.createRow(rowNum++);
                    if(downloadType.equals("student")){
                        row.createCell(0).setCellValue(student.getId_class_has_user());
                        row.createCell(1).setCellValue(student.getUsername());
                        row.createCell(2).setCellValue(student.getName());
                        row.createCell(3).setCellValue(student.getLastname());
                        row.createCell(4).setCellValue(student.getId_class());
                        row.createCell(5).setCellValue(student.getId_exam());
                        row.createCell(6).setCellValue(student.getScore());
                    }else if(downloadType.equals("exam")){
                        row.createCell(0).setCellValue(student.getId_exam());
                        row.createCell(1).setCellValue(student.getUsername());
                        row.createCell(2).setCellValue(student.getName());
                        row.createCell(3).setCellValue(student.getLastname());
                        row.createCell(4).setCellValue(student.getId_class());
                        row.createCell(5).setCellValue(student.getScore());
                    }else if(downloadType.equals("class")){
                        row.createCell(0).setCellValue(student.getId_class());
                        row.createCell(1).setCellValue(student.getUsername());
                        row.createCell(2).setCellValue(student.getName());
                        row.createCell(3).setCellValue(student.getLastname());
                        row.createCell(4).setCellValue(student.getId_exam());
                        row.createCell(5).setCellValue(student.getScore());
                    }
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
}