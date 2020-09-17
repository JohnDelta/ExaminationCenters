
<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@include file="getUserType.jsp"%>
<%@include file="mysql-connection.jsp"%>
<%
if(!user.equals("admin")){
    response.sendRedirect("index.jsp");
}else{
    String msg="";
    //if the form insert one class is submmited
    if(request.getParameter("insertClassForm")!=null){
        String name = request.getParameter("name");
        String address = request.getParameter("address");
        String id_class = request.getParameter("id_class");
        String id_examination = request.getParameter("id_examination");
        
        //check if the id_class already exists
        boolean flag = false;
        String sql = "select count(*) from class where id_class = '"+id_class+"'";
        ResultSet rs = statement.executeQuery(sql);
        if(rs.next()){
            if(rs.getInt("count(*)")==0){
                flag = true;
            }
        }
        rs.close();
        if(flag){
            //insert the class
            sql = "insert into class(id_class,name,address,id_examination) values"
                    + "('"+id_class+"','"+name+"','"+address+"','"+id_examination+"')";
            statement.executeUpdate(sql);
            msg = "<script>alert('Η εισαγωγή του εξεταστικού κέντρου ολοκληρώθηκε');</script>";
        }else{
            msg = "<script>alert('Το εξεταστικό κέντρο με αυτό τον κωδικό υπάρχει ήδη');</script>";
        }
    }
    
    //if the form delete one class is submited
    if(request.getParameter("deleteClassForm")!=null){
        String id_class = request.getParameter("id_class");
        //check if the class exists
        boolean flag = true;
        String sql = "select count(*) from class where id_class = '"+id_class+"'";
        ResultSet rs = statement.executeQuery(sql);
        if(rs.next()){
            if(rs.getInt("count(*)")==0){
                flag = false;
            }
        }
        rs.close();
        if(flag){
            //check if there are users assigned to the class
            flag = false;
            sql = "select count(*) from class_has_user where id_class = '"+id_class+"'";
            rs = statement.executeQuery(sql);
            if(rs.next()){
                if(rs.getInt("count(*)")==0){
                    flag = true;
                }
            }
            rs.close();
            if(flag){
                //delete now the class
                sql = "delete from class where id_class = '"+id_class+"'";
                statement.executeUpdate(sql);
                msg = "<script>alert('Η αφαίρεση του εξεταστικού κέντρου ολοκληρώθηκε');</script>";
            }else{
                msg = "<script>alert('Το εξεταστικό κέντρο δεν μπορεί να διαγραφεί : Υπάρχουν"
                        + " ακόμα χρήστες εγγεγραμμένοι σε αυτό');</script>";
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
        <title>ΕΠΓ - Κέντρα Εξέτασης</title>
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
            <a href='admin-classes.jsp' class='highlight'>Εξεταστικά κέντρα</a>
            <a href='admin-exams.jsp'>Εξετάσεις</a>
            <a href='admin-subjects.jsp'>Μαθήματα</a>
            <a href='admin-questions.jsp'>Ερωτήσεις Μαθημάτων</a>
            <a href='admin-reports.jsp'>Αναφορές</a>
            <a href='logout.jsp' style='float:right;'>Αποσύνδεση</a>
        </div>
        
        <div class="context">
            <h3>Διαχείριση Εξεταστικών Κέντων</h3>
            <input type="button" id="insertClass" value="Εισαγωγή">
            <input type="button" id="deleteClass" value="Διαγραφή">
            <hr>
            <div id="classWindow">
                
            </div>
        </div>
        
        <div class="footer">
           Ιωάννης Δεληγιάννης | Copyright &copy | cs151102 | Δικτυακός προγραμματισμός 2017-2018 | Πανεπιστήμιο Δυτικής Αττικής
        </div>
        
        <script>
            $(document).ready(function(){
                displayInsertClass();
                $("#insertClass").click(function(){
                    displayInsertClass();
                });
                $("#deleteClass").click(function(){
                    displayDeleteClass();
                });
            });
            
            function displayInsertClass(){
                $("#insertClass").addClass("highlight");
                $("#deleteClass").removeClass("highlight");
                var window = document.getElementById("classWindow");
                window.innerHTML = ""+
                "<div class='format-forms'>"+
                    "<form method='post' name='formInsertClass' action='admin-classes.jsp' onSubmit='return formInsertClassValidation()'>"+
                        "<h4>Εισαγωγή στοιχείων από φόρμα</h4>"+
                        "<p>Κωδικός</p> <input type='number' name='id_class' min='0'>"+
                        "<p>Όνομα</p> <input type='text' name='name' maxlength='50'>"+
                        "<p>Διεύθυνση</p> <input type='text' name='address' maxlength='50'>"+
                            "<p>Διαθέσιμη Εξέταση</p>"+
                            "<select style='margin-bottom:20px;' name='id_examination'>"+
                            <%  String title="";
                                String sql = "select * from examination";
                                ResultSet rs = statement.executeQuery(sql);
                                Statement statement2 = connection.createStatement();
                                while(rs.next()){
                                    sql = "select * from subject where id_subject = '"+rs.getString("id_subject")+"'";
                                    ResultSet rs2 = statement2.executeQuery(sql);
                                    if(rs2.next()){
                                        title = rs2.getString("title");
                                    }
                                    rs2.close();
                                    out.print("\"<option value='"+rs.getString("id_examination")+"'>"+
                                            title+" | "+rs.getString("id_examination")+" | "+rs.getString("date")+"</option>\"+");
                                }
                                rs.close(); %>
                            "</select>"+
                        "<input type='submit' value='Υποβολή' style='margin-bottom:20px;display:block;'>"+
                        "<input type='hidden' name='insertClassForm' value='insertClassForm'>"+
                    "</form>"+
                "</div>"+
               "<div class='format-forms' style='float:right;'>"+
                    "<h4>Εισαγωγή Στοιχείων απο αρχείο excel</h4>"+
                    "<h5>Μορφή : Κωδικός Κέντρου | Όνομα | Διεύθυνση | Κωδικός Εξέτασης</h5>"+
                    "<h5>Η πρώτη γραμμή του αρχείου είναι για τους τίτλους και παραλείπεται</h5>"+
                   "<form method='POST' action='admin-classes-insert.jsp' onsubmit='return validateFileForm()' enctype = 'multipart/form-data'>"+
                        "<input type='file' name='file' size='50' id='file'>"+
                        "<input type='submit' name='upload' value='Ανέβασμα άρχειου'>"+
                    "</form>"+
                "</div>";
            }
            
            function displayDeleteClass(){
                $("#deleteClass").addClass("highlight");
                $("#insertClass").removeClass("highlight");
                var window = document.getElementById("classWindow");
                window.innerHTML = ""+
                "<div class='format-forms'>"+
                    "<form name='formDeleteClass' action='admin-classes.jsp' method='post' onsubmit='return formDeleteClassValidation()'>"+
                        "<h4>Εισαγωγή στοιχείων από φόρμα</h4>"+
                        "<p>Κωδικός Κέντρου</p> <input type='number' name='id_class' min='0'>"+
                        "<input type='hidden' name='deleteClassForm' value='deleteClassForm'>"+
                        "<input type='submit' value='Υποβολή' style='margin-bottom:20px;'>"+
                    "</form>"+
                "</div>"+
               "<div class='format-forms' style='float:right;'>"+
                    "<h4>Εισαγωγή Στοιχείων απο αρχείο excel</h4>"+
                    "<h5>Μορφή : Κωδικός Κέντρου</h5>"+
                    "<h5>Η πρώτη γραμμή του αρχείου είναι για τους τίτλους και παραλείπεται</h5>"+
                   "<form method='POST' action='admin-classes-delete.jsp' onsubmit='return validateFileForm()' enctype = 'multipart/form-data'>"+
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
            
            function formInsertClassValidation(){
                var regex = /[^a-zA-Z0-9α-ωΑ-Ωάέίόήώύ]+/;
                var regex_ad = /[^a-zA-Z0-9α-ωΑ-Ωάέίόήώύ ,.]+/;
                var id_class = document.forms['formInsertClass']['id_class'].value;
                var name = document.forms['formInsertClass']['name'].value;
                var address = document.forms['formInsertClass']['address'].value;
                if(name==="" || address==="" || id_class===""){
                    alert("Πρέπει να συμπληρώσετε όλα τα πεδία");
                    return false;
                }
                if(regex_ad.test(address) || regex.test(name) || !/[0-9]{1,10}/.test(id_class)){
                    alert("Τα πεδία πρέπει να έχουν μόνο αλφαβητικούς χαρακτήρες ή αριθμούς, από 1 μέχρι 50.");
                    return false;
                }
                return true;
            }
            
            function formDeleteClassValidation(){
                var id_class = document.forms['formDeleteClass']['id_class'].value;
                if(id_class===""){
                    alert("Πρέπει να συμπληρώσετε όλα τα πεδία");
                    return false;
                }
                if(!/[0-9]{1,10}/.test(id_class)){
                    alert("Ο Αριθμός πρέπει να είναι μέχρι 10 ψηφία");
                    return false;
                }
                return true;
            }
        </script>
    </body>
</html>
<%}%>