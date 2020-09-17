
<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@include file="getUserType.jsp"%>
<%@include file="mysql-connection.jsp"%>
<%
if(!user.equals("admin")){
    response.sendRedirect("index.jsp");
}else{
    String msg="";
    //if the form insert one subject is submmited
    if(request.getParameter("insertSubjectsForm")!=null){
        String id_subject = request.getParameter("id_subject");
        String title = request.getParameter("title");
        String description = request.getParameter("description");
        
        //check if the id_subject already exists
        boolean flag = false;
        String sql = "select count(*) from subject where id_subject = '"+id_subject+"'";
        ResultSet rs = statement.executeQuery(sql);
        if(rs.first()){
            if(rs.getInt("count(*)")==0){
                flag = true;
            }
        }
        rs.close();
        if(flag){
            //insert the subject
            sql = "insert into subject(id_subject,title,description) values"
                    + "('"+id_subject+"','"+title+"','"+description+"')";
            statement.executeUpdate(sql);
            msg = "<script>alert('Η εισαγωγή του μαθήματος ολοκληρώθηκε');</script>";
        }else{
            msg = "<script>alert('Το μάθημα με αυτό τον κωδικό υπάρχει ήδη');</script>";
        }
    }
    
    //if the form delete one subject is submited
    if(request.getParameter("deleteSubjectsForm")!=null){
        String id_subject = request.getParameter("id_subject");
        //check if the subject exists
        boolean flag = true;
        String sql = "select count(*) from subject where id_subject = '"+id_subject+"'";
        ResultSet rs = statement.executeQuery(sql);
        if(rs.first()){
            if(rs.getInt("count(*)")==0){
                flag = false;
            }
        }
        rs.close();
        if(flag){
            //check if there are examinations assigned to the subject
            flag = false;
            sql = "select count(*) from examination where id_subject = '"+id_subject+"'";
            rs = statement.executeQuery(sql);
            if(rs.first()){
                if(rs.getInt("count(*)")==0){
                    flag = true;
                }
            }
            rs.close();
            if(flag){
                //delete now the subject
                sql = "delete from subject where id_subject = '"+id_subject+"'";
                statement.executeUpdate(sql);
                msg = "<script>alert('Η αφαίρεση του μαθήματος ολοκληρώθηκε');</script>";
            }else{
                msg = "<script>alert('Το μάθημα δεν μπορεί να διαγραφεί : Υπάρχουν"
                        + " ακόμα εξετάσεις εγγεγραμμένες σε αυτό');</script>";
            }
        }else{
            msg = "<script>alert('Το μάθημα με αυτό τον κωδικό δεν υπάρχει');</script>";
        }
    }
%>
<!DOCTYPE html>
<html>
    <head>
        <script src="https://ajax.googleapis.com/ajax/libs/jquery/3.3.1/jquery.min.js"></script>
        <title>ΕΠΓ - Μαθήματα</title>
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
            <a href='admin-exams.jsp'>Εξετάσεις</a>
            <a href='admin-subjects.jsp' class='highlight'>Μαθήματα</a>
            <a href='admin-questions.jsp'>Ερωτήσεις Μαθημάτων</a>
            <a href='admin-reports.jsp'>Αναφορές</a>
            <a href='logout.jsp' style='float:right;'>Αποσύνδεση</a>
        </div>
        
        <div class="context">
            <h3>Διαχείριση Εξεταστικών Κέντων</h3>
            <input type="button" id="insertSubjects" value="Εισαγωγή">
            <input type="button" id="deleteSubjects" value="Διαγραφή">
            <hr>
            <div id="subjectsWindow">
                
            </div>
        </div>
        
        <div class="footer">
           Ιωάννης Δεληγιάννης | Copyright &copy | cs151102 | Δικτυακός προγραμματισμός 2017-2018 | Πανεπιστήμιο Δυτικής Αττικής
        </div>
        
        <script>
            $(document).ready(function(){
                displayInsertSubjects();
                $("#insertSubjects").click(function(){
                    displayInsertSubjects();
                });
                $("#deleteSubjects").click(function(){
                    displayDeleteSubjects();
                });
            });
            
            function displayInsertSubjects(){
                $("#insertSubjects").addClass("highlight");
                $("#deleteSubjects").removeClass("highlight");
                var window = document.getElementById("subjectsWindow");
                window.innerHTML = ""+
                "<div class='format-forms'>"+
                    "<form method='post' name='formInsertSubjects' action='admin-subjects.jsp' onSubmit='return formInsertSubjectsValidation()'>"+
                        "<h4>Εισαγωγή στοιχείων από φόρμα</h4>"+
                        "<p>Κωδικός</p> <input type='number' name='id_subject' min='0'>"+
                        "<p>Τίτλος</p> <input type='text' name='title' maxlength='50'>"+
                        "<p>Σύντομη περιγραφή</p> <textarea name='description'"+
                            "maxlength='100' rows='3' cols='30' style='resize:none;'></textarea>"+
                        "<input type='submit' value='Υποβολή' style='margin-bottom:20px;display:block;'>"+
                        "<input type='hidden' name='insertSubjectsForm' value='insertSubjectsForm'>"+
                    "</form>"+
                "</div>"+
               "<div class='format-forms' style='float:right;'>"+
                    "<h4>Εισαγωγή Στοιχείων απο αρχείο excel</h4>"+
                    "<h5>Μορφή : Κωδικός Μαθήματος | Τίτλος | Σύντομη περιγραφή</h5>"+
                    "<h5>Η πρώτη γραμμή του αρχείου είναι για τους τίτλους και παραλείπεται</h5>"+
                   "<form method='POST' action='admin-subjects-insert.jsp' onsubmit='return validateFileForm()' enctype = 'multipart/form-data'>"+
                        "<input type='file' name='file' size='50' id='file'>"+
                        "<input type='submit' name='upload' value='Ανέβασμα άρχειου'>"+
                    "</form>"+
                "</div>";
            }
            
            function displayDeleteSubjects(){
                $("#deleteSubjects").addClass("highlight");
                $("#insertSubjects").removeClass("highlight");
                var window = document.getElementById("subjectsWindow");
                window.innerHTML = ""+
                "<div class='format-forms'>"+
                    "<form name='formDeleteSubjects' action='admin-subjects.jsp' method='post' onsubmit='return formDeleteSubjectsValidation()'>"+
                        "<h4>Εισαγωγή στοιχείων από φόρμα</h4>"+
                        "<p>Κωδικός Μαθήματος</p> <input type='number' name='id_subject' min='0'>"+
                        "<input type='hidden' name='deleteSubjectsForm' value='deleteSubjectsForm'>"+
                        "<input type='submit' value='Υποβολή' style='margin-bottom:20px;'>"+
                    "</form>"+
                "</div>"+
               "<div class='format-forms' style='float:right;'>"+
                    "<h4>Εισαγωγή Στοιχείων απο αρχείο excel</h4>"+
                    "<h5>Μορφή : Κωδικός Μαθήματος</h5>"+
                    "<h5>Η πρώτη γραμμή του αρχείου είναι για τους τίτλους και παραλείπεται</h5>"+
                   "<form method='POST' action='admin-subjects-delete.jsp' onsubmit='return validateFileForm()' enctype = 'multipart/form-data'>"+
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
            
            function formInsertSubjectsValidation(){
                var regex = /[^a-zA-Z0-9α-ωΑ-Ωάέίόήώύ+,. ]+/;
                var regex_d = /[^a-zA-Z0-9α-ωΑ-Ωάέίόήώύ+,. ]+/;
                var id_subject = document.forms['formInsertSubjects']['id_subject'].value;
                var title = document.forms['formInsertSubjects']['title'].value;
                var description = document.forms['formInsertSubjects']['description'].value;
                if(title==="" || description==="" || id_subject===""){
                    alert("Πρέπει να συμπληρώσετε όλα τα πεδία");
                    return false;
                }
                if(regex_d.test(description) || regex.test(title) || !/[0-9]{1,10}/.test(id_subject)){
                    alert("Δεν επιτρέπονται τα σύμβολα εκτός +,., η περιγραφή μέχρι 100 χαρακτήρες");
                    return false;
                }
                return true;
            }
            
            function formDeleteSubjectsValidation(){
                var id_subject = document.forms['formDeleteSubjects']['id_subject'].value;
                if(id_subject===""){
                    alert("Πρέπει να συμπληρώσετε όλα τα πεδία");
                    return false;
                }
                if(!/[0-9]{1,10}/.test(id_subject)){
                    alert("Επιτρέπονται μέχρι 10 ψηφία");
                    return false;
                }
                return true;
            }
        </script>
    </body>
</html>
<%}%>