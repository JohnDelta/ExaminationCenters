
<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@include file="getUserType.jsp"%>
<%@include file="mysql-connection.jsp"%>
<%
if(!user.equals("admin")){
    response.sendRedirect("index.jsp");
}else{
    String msg="";
    //if the form insert one examination is submmited
    if(request.getParameter("insertExamsForm")!=null){
        String id_examination = request.getParameter("id_examination");
        String id_subject = request.getParameter("id_subject");
        String year = request.getParameter("year");
        String month = request.getParameter("month");
        String day = request.getParameter("day");
        String hour = request.getParameter("hour");
        String minute = request.getParameter("minute");
        String second = request.getParameter("second");
        String date = year+"/"+month+"/"+day+" "+hour+":"+minute+":"+second;
        
        //check if the examination already exists
        boolean flag = false;
        String sql = "select count(*) from examination where id_examination = '"+id_examination+"'";
        ResultSet rs = statement.executeQuery(sql);
        if(rs.first()){
            if(rs.getInt("count(*)")==0){
                flag = true;
            }
        }
        rs.close();
        if(flag){
            //insert the examination
            sql = "insert into examination(id_examination,open,date,id_subject) values"
                    + "('"+id_examination+"','0','"+date+"','"+id_subject+"')";
            statement.executeUpdate(sql);
            msg = "<script>alert('Η εισαγωγή της εξέτασης πραγματοποιήθηκε');</script>";
        }else{
            msg = "<script>alert('Η εξέταση με αυτό τον κωδικό υπάρχει ήδη');</script>";
        }
    }
    
    //if the form delete one examination is submited
    if(request.getParameter("deleteExamsForm")!=null){
        String id_examination = request.getParameter("id_examination");
        //check if the examination exists
        boolean flag = true;
        String sql = "select count(*) from examination where id_examination = '"+id_examination+"'";
        ResultSet rs = statement.executeQuery(sql);
        if(rs.first()){
            if(rs.getInt("count(*)")==0){
                flag = false;
            }
        }
        rs.close();
        if(flag){
            //check if there are classes assigned to the examination
            flag = false;
            sql = "select count(*) from class where id_examination = '"+id_examination+"'";
            rs = statement.executeQuery(sql);
            if(rs.first()){
                if(rs.getInt("count(*)")==0){
                    flag = true;
                }
            }
            rs.close();
            if(flag){
                //delete now the examination
                sql = "delete from examination where id_examination = '"+id_examination+"'";
                statement.executeUpdate(sql);
                msg = "<script>alert('Η αφαίρεση του εξεταστικού κέντρου ολοκληρώθηκε');</script>";
            }else{
                msg = "<script>alert('Η εξέταση δεν μπορεί να διαγραφεί : Υπάρχουν"
                        + " ακόμα εξεταστικά κέντρα εγγεγραμμένα σε αυτή');</script>";
            }
        }else{
            msg = "<script>alert('Το εξεταστικό κέντρο με αυτό τον κωδικό δεν υπάρχει');</script>";
        }
    }
%>
<!DOCTYPE html>
<html>
    <head>
        <script src="https://ajax.googleapis.com/ajax/libs/jquery/3.3.1/jquery.min.js"></script>
        <title>ΕΠΓ - Εξετάσεις</title>
        <meta charset="UTF-8">
        <meta name="viewport" content="width=device-width, initial-scale=1.0">
        <link rel="stylesheet" type="text/css" href="style.css">
    </head>
    <body>
        <%=msg%>
        <div class="header">
            <font style="color:#448AFF;">Ε</font>ξετάσεις
            <font style="color:#448AFF;">Π</font>ιστοποίησης 
            <font style="color:#448AFF;">Γ</font>νώσεων
            <%if(!user.equals("guest")) out.print("<p>Logged in as : "+session.getAttribute("name")+"</p>");%>
        </div>
        
        <div class="nav">
            <a href="index.jsp">Αρχική</a>
            <a href='profil.jsp'>Προφίλ</a>
            <a href='admin-users.jsp'>Χρήστες</a>
            <a href='admin-classes.jsp'>Εξεταστικά κέντρα</a>
            <a href='admin-exams.jsp' class='highlight'>Εξετάσεις</a>
            <a href='admin-subjects.jsp'>Μαθήματα</a>
            <a href='admin-questions.jsp'>Ερωτήσεις Μαθημάτων</a>
            <a href='admin-reports.jsp'>Αναφορές</a>
            <a href='logout.jsp' style='float:right;'>Αποσύνδεση</a>
        </div>
        
        <div class="context">
            <h3>Διαχείριση Εξεταστικών Κέντων</h3>
            <input type="button" id="insertExams" value="Εισαγωγή">
            <input type="button" id="deleteExams" value="Διαγραφή">
            <hr>
            <div id="examsWindow">
                
            </div>
        </div>
        
        <div class="footer">
           Ιωάννης Δεληγιάννης | Copyright &copy | cs151102 | Δικτυακός προγραμματισμός 2017-2018 | Πανεπιστήμιο Δυτικής Αττικής
        </div>
        
        <script>
            $(document).ready(function(){
                displayInsertExams();
                $("#insertExams").click(function(){
                    displayInsertExams();
                });
                $("#deleteExams").click(function(){
                    displayDeleteExams();
                });
            });
            
            function displayInsertExams(){
                $("#insertExams").addClass("highlight");
                $("#deleteExams").removeClass("highlight");
                var window = document.getElementById("examsWindow");
                window.innerHTML = ""+
                "<div class='format-forms'>"+
                    "<form method='post' name='formInsertExams' action='admin-exams.jsp' onSubmit='return formInsertExamsValidation()'>"+
                        "<h4>Εισαγωγή στοιχείων από φόρμα</h4>"+
                        "<p>Κωδικός</p> <input type='number' name='id_examination' min='0'>"+
                        "<p>Κατάσταση</p> <input type='text' name='open' value='Αρχική' readonly>"+
                        "<p>Ημερομηνία και ώρα έναρξης format(yyyy/MM/dd hh:mm:ss)</p>"+
                        "<div class='date'>"+
                            "<input id='year' type='number' name='year' min='2000' max='2030' placeholder='y'>"+
                            "<input type='number' name='month' min='1' max='12' placeholder='M'>"+
                            "<input type='number' name='day' min='1' max='31' placeholder='d' style='border:none;'>&nbsp;&nbsp;"+
                            "<input type='number' name='hour' min='0' max='59' placeholder='h'>"+
                            "<input type='number' name='minute' min='0' max='59' placeholder='m'>"+
                            "<input type='number' name='second' min='0' max='59' placeholder='s' style='border:none;'>"+
                        "</div>"+
                        "<p>Διαθέσιμο Μάθημα</p>"+
                        "<select style='margin-bottom:20px;' name='id_subject'>"+
                            <%  String sql = "select * from subject";
                                ResultSet rs = statement.executeQuery(sql);
                                while(rs.next()){
                                    out.print("\"<option value='"+rs.getString("id_subject")+"'>"
                                            + ""+rs.getString("title")+" | "+rs.getString("id_subject")+"</option>\"+");
                                }
                                rs.close(); %>
                        "</select>"+
                        "<input type='submit' value='Υποβολή' style='margin-bottom:20px;display:block;'>"+
                        "<input type='hidden' name='insertExamsForm' value='insertExamsForm'>"+
                    "</form>"+
                "</div>"+
               "<div class='format-forms' style='float:right;'>"+
                    "<h4>Εισαγωγή Στοιχείων απο αρχείο excel</h4>"+
                    "<h5>Μορφή : Κωδικός Εξέτασης | Όνομα | Ημερομηνία Έναρξης | Κωδικός Μαθήματος</h5>"+
                    "<h5>Η πρώτη γραμμή του αρχείου είναι για τους τίτλους και παραλείπεται</h5>"+
                   "<form method='POST' action='admin-exams-insert.jsp' onsubmit='return validateFileForm()' enctype = 'multipart/form-data'>"+
                        "<input type='file' name='file' size='50' id='file'>"+
                        "<input type='submit' name='upload' value='Ανέβασμα άρχειου'>"+
                    "</form>"+
                "</div>";
            }
            
            function displayDeleteExams(){
                $("#deleteExams").addClass("highlight");
                $("#insertExams").removeClass("highlight");
                var window = document.getElementById("examsWindow");
                window.innerHTML = ""+
                "<div class='format-forms'>"+
                    "<form name='formDeleteExams' action='admin-exams.jsp' method='post' onsubmit='return formDeleteExamsValidation()'>"+
                        "<h4>Εισαγωγή στοιχείων από φόρμα</h4>"+
                        "<p>Κωδικός Κέντρου</p> <input type='number' name='id_examination' min='0'>"+
                        "<input type='hidden' name='deleteExamsForm' value='deleteExamsForm'>"+
                        "<input type='submit' value='Υποβολή' style='margin-bottom:20px;'>"+
                    "</form>"+
                "</div>"+
               "<div class='format-forms' style='float:right;'>"+
                    "<h4>Εισαγωγή Στοιχείων απο αρχείο excel</h4>"+
                    "<h5>Μορφή : Κωδικός Κέντρου</h5>"+
                    "<h5>Η πρώτη γραμμή του αρχείου είναι για τους τίτλους και παραλείπεται</h5>"+
                   "<form method='POST' action='admin-exams-delete.jsp' onsubmit='return validateFileForm()' enctype = 'multipart/form-data'>"+
                        "<input type='file' name='file' size='50' id='file'>"+
                        "<input type='submit' name='upload' value='Ανέβασμα άρχειου'>"+
                    "</form>"+
                "</div>";
            }
            
            function validateFileForm(){
                var file = document.getElementById("file");
                if(file.value===null || file.value.length===0){
                    alert("Επιλέξτε αρχείο πρώτα");
                }
                else{
                    return true;
                }
                return false;
            }
            
            function formInsertExamsValidation(){
                var id_examination = document.forms['formInsertExams']['id_examination'].value;
                var year = document.forms['formInsertExams']['year'].value;
                var day = document.forms['formInsertExams']['day'].value;
                var month = document.forms['formInsertExams']['month'].value;
                var hour = document.forms['formInsertExams']['hour'].value;
                var minute = document.forms['formInsertExams']['minute'].value;
                var second = document.forms['formInsertExams']['second'].value;
                if(year==="" || day==="" || month==="" || hour==="" || minute==="" ||
                        second==="" || id_examination===""){
                    alert("Πρέπει να συμπληρώσετε όλα τα πεδία");
                    return false;
                }
                if(!/[0-9]{1,10}/.test(id_examination)){
                    alert("Επιτρέπονται μέχρι και 10 ψηφία");
                    return false;
                }
                return true;
            }
            
            function formDeleteExamsValidation(){
                var id_exam = document.forms['formDeleteExams']['id_examination'].value;
                if(id_exam===""){
                    alert("Πρέπει να συμπληρώσετε όλα τα πεδία");
                    return false;
                }
                if(!/[0-9]{1,10}/.test(id_exam)){
                    alert("Επιτρέπονται μέχρι και 10 ψηφία");
                    return false;
                }
                return true;
            }
        </script>
    </body>
</html>
<%}%>