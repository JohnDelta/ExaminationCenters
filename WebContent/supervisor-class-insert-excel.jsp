
<%@page import="org.apache.commons.fileupload.FileUploadException"%>
<%@page import="org.apache.commons.fileupload.disk.DiskFileItemFactory"%>
<%@page import="org.apache.commons.fileupload.servlet.ServletFileUpload"%>
<%@page import="org.apache.commons.fileupload.FileItem"%>
<%@page import="java.util.List"%>
<%@page import="java.util.Iterator"%>
<%@page import="java.io.InputStream"%>
<%@page import="org.apache.poi.openxml4j.exceptions.InvalidFormatException"%>
<%@page import="org.apache.poi.ss.usermodel.DataFormatter"%>
<%@page import="org.apache.poi.ss.usermodel.Cell"%>
<%@page import="org.apache.poi.ss.usermodel.Row"%>
<%@page import="org.apache.poi.ss.usermodel.Sheet"%>
<%@page import="org.apache.poi.ss.usermodel.WorkbookFactory"%>
<%@page import="org.apache.poi.ss.usermodel.Workbook"%>
<%@page import="java.io.File"%>
<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@include file="getUserType.jsp"%>
<%
if(!user.equals("supervisor") && session.getAttribute("id_class")!=null){
    response.sendRedirect("index.jsp");
}else{
    /*      READ EXCEL FILE IN FORM - USERNAME,NAME,LASTNAME   
            AND INSERT THE STUDENT TO THE CLASS
            OTHER CELLS AFTER THEM WILL NOT COUNT           */
%>
<%@include file="mysql-connection.jsp"%>
<!DOCTYPE html>
<html>
    <head>
        <title>TODO supply a title</title>
        <meta charset="UTF-8">
        <meta name="viewport" content="width=device-width, initial-scale=1.0">
    </head>
    <body>
<%
    //download apache commons.io && commons.fileupload libraries to upload files
    //download apache poi 3.17, extract it , find .jar and open it here.. to read excel
    //download xmlbeans
    //download commons collections 4
    /*
        UPLOAD FILE TO SERVER IN PATH : webb\repository\
        CHECK IF THE FILE IS EXCEL AND READ IT
    */
    String DATA_DIRECTORY = "repository";
    int MAX_MEMORY_SIZE = 5000*1024;
    int MAX_REQUEST_SIZE = 5000*1024;
    File uploadedFile=null;
    boolean isMultipart = ServletFileUpload.isMultipartContent(request);
        if (isMultipart) {
            // Create a factory for disk-based file items
            DiskFileItemFactory factory = new DiskFileItemFactory();
            // Sets the size threshold beyond which files are written directly to
            // disk.
            factory.setSizeThreshold(MAX_MEMORY_SIZE);
            // Sets the directory used to temporarily store files that are larger
            // than the configured size threshold. We use temporary directory for
            // java
            factory.setRepository(new File(System.getProperty("java.io.tmpdir")));
            // constructs the folder where uploaded file will be stored
            String uploadFolder = getServletContext().getRealPath("")+ File.separator + DATA_DIRECTORY;
            // Create a new file upload handler
            ServletFileUpload upload = new ServletFileUpload(factory);
            // Set overall request size constraint
            upload.setSizeMax(MAX_REQUEST_SIZE);
            try {
                // Parse the request
                List items = upload.parseRequest(request);
                Iterator iter = items.iterator();
                while (iter.hasNext()) {
                    FileItem item = (FileItem) iter.next();
                    if (!item.isFormField()) {
                        String fileName = new File(item.getName()).getName();
                        String filePath = uploadFolder + File.separator + fileName;
                        uploadedFile = new File(filePath);
                        //saves the file to upload directory
                        item.write(uploadedFile);
                        /*      OPEN EXCEL FILE HERE   -  START        */
                        //set auto commit to false, make sure all entries will insert before commiting
                        connection.setAutoCommit(false);
                        String msg="";
                        Workbook workbook=null;
                        try{
                            //entries : number of uploaded and inserted to database rows
                            int entries=0;
                            workbook = WorkbookFactory.create(uploadedFile);
                            Sheet sheet = workbook.getSheetAt(0);
                            DataFormatter dataFormatter = new DataFormatter();
                            for (Row row: sheet) {
                                if(row.getLastCellNum()>=3 && row.getRowNum()>0){
                                    /*  OPEN DATABASE - CHECK LOGICAL CONNECTION - INSERT ENTRIES - START   */
                                    String usernameExcel = row.getCell(0).toString();
                                    String nameExcel = row.getCell(1).toString();
                                    String lastnameExcel = row.getCell(2).toString();
                                    String id_classExcel = session.getAttribute("id_class").toString();
                                    //check if the user exists
                                    String id_userExcel=null;
                                    int alreadyInExcel=0;
                                    String sql = "select * from user where username = '"+usernameExcel+"' and "
                                        + "name = '"+nameExcel+"' and lastname = '"+lastnameExcel+"' and role = '2'";
                                    ResultSet rs = statement.executeQuery(sql);
                                    if(rs.next()){
                                        if(rs.getString("id_user")!=null)
                                            id_userExcel = rs.getString("id_user");
                                    }
                                    rs.close();
                                    if(id_userExcel!=null){
                                        //check if the user is already in the class
                                        sql = "select count(*) from class_has_user where id_user = '"+id_userExcel+"'"
                                                + " and id_class = '"+id_classExcel+"'";
                                        rs = statement.executeQuery(sql);
                                        if(rs.next()){
                                            alreadyInExcel = rs.getInt("count(*)");
                                        }
                                        rs.close();
                                        if(alreadyInExcel>0){
                                            //user already in
                                        }
                                        else{
                                            //insert user
                                            sql = "insert into class_has_user(id_user,id_class) values"
                                                    + "('"+id_userExcel+"','"+id_classExcel+"')";
                                            statement.executeUpdate(sql);
                                            entries++;
                                        }
                                    }else{
                                        //user does not exists
                                    }
                                    /*  OPEN DATABASE - CHECK LOGICAL CONNECTION - INSERT ENTRIES - END     */
                                }
                            }
                            int rows = sheet.getPhysicalNumberOfRows();
                            if(rows<2){
                                msg="Η διαδικασία δεν ολοκληρώθηκε : Δεν υπάρχουν εγγραφές";
                                connection.rollback();
                            }else{
                                if(entries==(rows-1)){
                                    msg="Η διαδικασία ολοκληρώθηκε : "+entries+" εγγραφές προσθέθηκαν";
                                    connection.commit();
                                }else{
                                    connection.rollback();
                                    msg="Η διαδικασία δεν ολοκληρώθηκε : Κάποιες έγγραφές είναι λάθος"
                                            + " ή υπάρχουν";
                                }
                            }
                            connection.setAutoCommit(true);
                            workbook.close();
                            uploadedFile.delete();
                            out.print("<script>alert('"+msg+"');</script>");
                        }catch(Exception e){
                            connection.rollback();
                            connection.setAutoCommit(true);
                            workbook.close();
                            uploadedFile.delete();
                            e.printStackTrace();
                            out.print("<script>alert('Η διαδικασία δεν ολοκληρώθηκε : Το αρχείο δεν είναι excel "
                                    + "ή οι εγγραφές είναι λάθος');</script>");
                        }
                        //delete downloaded file
                        workbook.close();
                        uploadedFile.delete();
                        /*      OPEN EXCEL FILE HERE   -  END        */
                        connection.close();
                        out.print("<script>window.location.replace('supervisor-class-insert.jsp');</script>");
                    }
                }
            } catch (FileUploadException ex) {
                uploadedFile.delete();
                out.print("<script>alert('Η διαδικασία δεν ολοκληρώθηκε : Το αρχείο δεν είναι excel "
                                    + "ή οι εγγραφές είναι λάθος');</script>");
                ex.printStackTrace();
                out.print("<script>window.location.replace('supervisor-class-insert.jsp');</script>");
            } catch (Exception ex) {
                uploadedFile.delete();
                out.print("<script>alert('Η διαδικασία δεν ολοκληρώθηκε : Το αρχείο δεν είναι excel "
                                    + "ή οι εγγραφές είναι λάθος');</script>");
                ex.printStackTrace();
                out.print("<script>window.location.replace('supervisor-class-insert.jsp');</script>");
            }
        }
}
%>
</body>
</html>