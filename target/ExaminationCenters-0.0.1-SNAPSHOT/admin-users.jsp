
<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@include file="getUserType.jsp"%>
<%@include file="mysql-connection.jsp"%>
<%
if(!user.equals("admin")){
    response.sendRedirect("index.jsp");
}else{
    String msg="";
    //if the form insert supervisors in submited
    if(request.getParameter("insertSupervisorsForm")!=null){
        String username = request.getParameter("username");
        String name = request.getParameter("name");
        String lastname = request.getParameter("lastname");
        String id_class = request.getParameter("id_class");
        String id_user="";
        //check if the user exists in the database
        String sql = "select count(*) from user where username = '"+username+"' and lastname = '"+lastname+"' and name = '"+name+"' and role='1'";
        ResultSet rs = statement.executeQuery(sql);
        boolean flag = true;
        if(rs.first()){
            if(rs.getInt("count(*)")==0)
                flag = false;
        }
        rs.close();
        if(flag){
            //take users id
            sql = "select * from user where username = '"+username+"'";
            rs = statement.executeQuery(sql);
            if(rs.first()){
                id_user = rs.getString("id_user");
            }
            rs.close();
            //check if the user is not already assigned to the class
            sql = "select count(*) from class_has_user where id_class = '"+id_class+"' and id_user = '"+id_user+"'";
            rs = statement.executeQuery(sql);
            flag = false;
            if(rs.first()){
                if(rs.getInt("count(*)")==0){
                    flag = true;
                }
            }
            rs.close();
            if(flag){
                //insert supervisor to the class
                sql = "insert into class_has_user(id_class,id_user) values('"+id_class+"','"+id_user+"')";
                statement.executeUpdate(sql);
                msg = "<script>alert('Η εισαγωγή του χρήστη ως υπεύθυνο τμήματος ολοκληρώθηκε');</script>";
            }else{
                msg = "<script>alert('Ο χρήστης είναι ήδη εγγεγραμμένος στο εξεταστικό κέντρο');</script>";
            }
        }else{
            msg = "<script>alert('Δεν υπάρχει χρήστης με αυτά τα στοιχεία');</script>";
        }
    }
    //if the form insert one user is submmited
    if(request.getParameter("insertUserForm")!=null){
        String username = request.getParameter("username");
        String password = request.getParameter("password");
        String name = request.getParameter("name");
        String lastname = request.getParameter("lastname");
        String role = request.getParameter("role");
        String address = request.getParameter("address");
        String phone = request.getParameter("phone");
        String email = request.getParameter("email");
        
        //check if the username does not already exists in the database
        String sql = "select count(*) from user where username = '"+username+"'";
        ResultSet rs = statement.executeQuery(sql);
        boolean flag = false;
        if(rs.first()){
            if(rs.getInt("count(*)")==0)
                flag = true;
        }
        rs.close();
        //make the insert
        if(flag){
            sql = "insert into user(username,password,name,lastname,phone,address,email,role) values"
                    + "('"+username+"','"+password+"','"+name+"','"+lastname+"','"+phone+"',"
                    + "'"+address+"','"+email+"','"+role+"')";
            statement.executeUpdate(sql);
            msg = "<script>alert('Η εισαγωγή του χρήστη πραγματοποιήθηκε');</script>";
        }else{
            msg = "<script>alert('Το όνομα λογαριασμού υπάρχει ήδη. Χρησιμοποιείστε διαφορετικό');</script>";
        }
    }
    
    //if the form delete one user is submited
    if(request.getParameter("deleteUserForm")!=null){
        String username = request.getParameter("username");
        String name = request.getParameter("name");
        String lastname = request.getParameter("lastname");
        //see if the user exists
        String sql = "select count(*) from user where username = '"+username+"'"
                + " and name = '"+name+"' and lastname = '"+lastname+"'";
        ResultSet rs = statement.executeQuery(sql);
        boolean flag = false;
        if(rs.first()){
            if(rs.getInt("count(*)")!=0)
                flag = true;
        }
        rs.close();
        //take user's id
        sql = "select * from user where username = '"+username+"'"
                + " and name = '"+name+"' and lastname = '"+lastname+"'";
        rs = statement.executeQuery(sql);
        String id_user="";
        if(rs.first()){
            id_user = rs.getString("id_user");
        }
        rs.close();
        if(flag && !id_user.equals(session.getAttribute("id_user"))){
            //check if the user is assigned to any classes
            sql = "select distinct id_class from class_has_user where id_user = '"+id_user+"'";
            rs = statement.executeQuery(sql);
            //delete user first from all his classes
            Statement statement2 = connection.createStatement();
            while(rs.next()){
                sql = "delete from class_has_user where id_class = '"+rs.getString("id_class")+"'"
                        + " and id_user = '"+id_user+"'";
                statement2.executeUpdate(sql);
            }
            rs.close();
            //delete user
            sql = "delete from user where id_user = '"+id_user+"'";
            statement.executeUpdate(sql);
            msg = "<script>alert('Η διαγραφή του χρήστη πραγματοποιήθηκε');</script>";
        }else{
            msg = "<script>alert('Δεν βρέθηκε χρήστης με αυτά τα στοιχεία');</script>";
        }
    }
%>
<!DOCTYPE html>
<html>
    <head>
        <script src="https://ajax.googleapis.com/ajax/libs/jquery/3.3.1/jquery.min.js"></script>
        <title>ΕΠΓ - Χρήστες</title>
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
            <a href='admin-users.jsp' class='highlight'>Χρήστες</a>
            <a href='admin-classes.jsp'>Εξεταστικά κέντρα</a>
            <a href='admin-exams.jsp'>Εξετάσεις</a>
            <a href='admin-subjects.jsp'>Μαθήματα</a>
            <a href='admin-questions.jsp'>Ερωτήσεις Μαθημάτων</a>
            <a href='admin-reports.jsp'>Αναφορές</a>
            <a href='logout.jsp' style='float:right;'>Αποσύνδεση</a>
        </div>
        
        <div class="context">
            <h3>Διαχείριση χρηστών</h3>
            <input type="button" id="insertUser" value="Εισαγωγή">
            <input type="button" id="deleteUser" value="Διαγραφή">
            <input type="button" id="insertSupervisors" value="Ορισμός Υπευθύνων">
            <input type="button" value="Αναζήτηση Χρήστη" style="float:right;" onclick="goToSearchUser()">
            <hr>
            <div id="userWindow">
                
            </div>
        </div>
        
        <div class="footer">
           Ιωάννης Δεληγιάννης | Copyright &copy | cs151102 | Δικτυακός προγραμματισμός 2017-2018 | Πανεπιστήμιο Δυτικής Αττικής
        </div>
        
        <script>
            function goToSearchUser(){
                document.location.replace("search-student.jsp");
            }
            
            $(document).ready(function(){
                displayInsertUser();
                $("#insertUser").click(function(){
                    displayInsertUser();
                });
                $("#deleteUser").click(function(){
                    displayDeleteUser();
                });
                $("#insertSupervisors").click(function(){
                    displayInsertSupervisors();
                });
            });
            
            function displayInsertUser(){
                $("#insertUser").addClass("highlight");
                $("#deleteUser").removeClass("highlight");
                $("#insertSupervisors").removeClass("highlight");
                var window = document.getElementById("userWindow");
                window.innerHTML = ""+
                "<div class='format-forms'>"+
                    "<form method='post' name='formInsertUser' action='admin-users.jsp' onSubmit='return formInsertUserValidation()'>"+
                        "<h4>Εισαγωγή στοιχείων από φόρμα</h4>"+
                        "<div class='profil-block'>"+
                            "<p>Επιλέξτε ρόλο χρήστη</p>"+
                            "<select style='margin-bottom:20px;' name='role'>"+
                                "<option value='2'>Εξεταζόμενος</option>"+
                                "<option value='1'>Υπεύθυνος Κέντρου</option>"+
                                "<option value='0'>Διαχειριστής</option>"+
                            "</select>"+
                            "<p>Όνομα λογαριασμού</p> <input type='text' name='username' maxlength='50'>"+
                            "<p>Κωδικός πρόσβασης</p> <input type='password' name='password' maxlength='50'>"+
                            "<p>Όνομα</p> <input type='text' name='name' maxlength='50'>"+
                            "<p>Email</p> <input type='text' name='email' maxlength='50'>"+
                        "</div><div class='profil-block'>"+
                            "<p>Επώνυμο</p> <input type='text' name='lastname' maxlength='50'>"+
                            "<p>Διεύθυνση</p> <input type='text' name='address' maxlength='50'>"+
                            "<p>Τηλέφωνο</p> <input type='text' name='phone' maxlength='50'>"+   
                        "</div>"+
                        "<input type='submit' value='Υποβολή' style='margin-bottom:20px;display:block;'>"+
                        "<input type='hidden' name='insertUserForm' value='insertUserForm'>"+
                    "</form>"+
                "</div>"+
               "<div class='format-forms' style='float:right;'>"+
                    "<h4>Εισαγωγή Στοιχείων απο αρχείο excel</h4>"+
                    "<h5>Μορφή : Ρόλος | Όνομα λογαριασμού | Κωδικός | Όνομα | Επώνυμο | Τηλέφωνο | Διεύθυνση | Email</h5>"+
                    "<h5>Η πρώτη γραμμή του αρχείου είναι για τους τίτλους και παραλείπεται</h5>"+
                   "<form method='POST' action='admin-users-insert.jsp' onsubmit='return validateFileForm()' enctype = 'multipart/form-data'>"+
                        "<input type='file' name='file' size='50' id='file'>"+
                        "<input type='submit' name='upload' value='Ανέβασμα άρχειου'>"+
                    "</form>"+
                "</div>";
            }
            
            function displayDeleteUser(){
                $("#deleteUser").addClass("highlight");
                $("#insertUser").removeClass("highlight");
                $("#insertSupervisors").removeClass("highlight");
                var window = document.getElementById("userWindow");
                window.innerHTML = ""+
                "<div class='format-forms'>"+
                    "<form name='formDeleteUser' action='admin-users.jsp' method='post' onsubmit='return formDeleteUserValidation()'>"+
                        "<h4>Εισαγωγή στοιχείων από φόρμα</h4>"+
                        "<p>Όνομα λογαριασμού</p> <input type='text' name='username' maxlength='50'>"+
                        "<p>Όνομα</p> <input type='text' name='name' maxlength='50'>"+
                        "<p>Επώνυμο</p> <input type='text' name='lastname' maxlength='50'>"+
                        "<input type='hidden' name='deleteUserForm' value='deleteUserForm'>"+
                        "<input type='submit' value='Υποβολή' style='margin-bottom:20px;'>"+
                    "</form>"+
                "</div>"+
               "<div class='format-forms' style='float:right;'>"+
                    "<h4>Εισαγωγή Στοιχείων απο αρχείο excel</h4>"+
                    "<h5>Μορφή : Όνομα λογαριασμού | Όνομα | Επώνυμο</h5>"+
                    "<h5>Η πρώτη γραμμή του αρχείου είναι για τους τίτλους και παραλείπεται</h5>"+
                   "<form method='POST' action='admin-users-delete.jsp' onsubmit='return validateFileForm()' enctype = 'multipart/form-data'>"+
                        "<input type='file' name='file' size='50' id='file'>"+
                        "<input type='submit' name='upload' value='Ανέβασμα άρχειου'>"+
                    "</form>"+
                "</div>";
            }
            
            function displayInsertSupervisors(){
                $("#insertSupervisors").addClass("highlight");
                $("#insertUser").removeClass("highlight");
                $("#deleteUser").removeClass("highlight");
                var window = document.getElementById("userWindow");
                window.innerHTML = ""+
                "<div class='format-forms'>"+
                    "<form name='formInsertSupervisors' action='admin-users.jsp' method='post' onsubmit='return formInsertSupervisorsValidation()'>"+
                        "<h4>Εισαγωγή στοιχείων από φόρμα</h4>"+
                        "<p>Όνομα λογαριασμού</p> <input type='text' name='username' maxlength='50'>"+
                        "<p>Όνομα</p> <input type='text' name='name' maxlength='50'>"+
                        "<p>Επώνυμο</p> <input type='text' name='lastname' maxlength='50'>"+
                        "<p>Κωδικός Εξεταστικού Κέντρου</p>"+
                        "<select name='id_class' size='1'>"+
                        <%  String sql = "select * from class";
                            ResultSet rs = statement.executeQuery(sql);
                            while(rs.next()){
                                out.print("\"<option value='"+rs.getString("id_class")+"'>"+rs.getString("id_class")+" | "+rs.getString("name")+"</option>\"+");
                            }
                            rs.close();
                        %>
                        "</select>"+
                        "<input type='hidden' name='insertSupervisorsForm' value='insertSupervisorsForm'>"+
                        "<input type='submit' value='Υποβολή' style='margin-bottom:20px;'>"+
                    "</form>"+
                "</div>"+
               "<div class='format-forms' style='float:right;'>"+
                    "<h4>Εισαγωγή Στοιχείων απο αρχείο excel</h4>"+
                    "<h5>Μορφή : Όνομα λογαριασμού | Όνομα | Επώνυμο | Κωδικός Κέντρου</h5>"+
                    "<h5>Η πρώτη γραμμή του αρχείου είναι για τους τίτλους και παραλείπεται</h5>"+
                   "<form method='POST' action='admin-supervisors-insert.jsp' onsubmit='return validateFileForm()' enctype = 'multipart/form-data'>"+
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
            
            function formInsertUserValidation(){
                var regex = /[^a-zA-Z0-9α-ωΑ-Ωάέίόήώύ]+/;
                var regex_em = /[^a-zA-Z0-9α-ωΑ-Ωάέίόήώύ.@]+/;
                var regex_ad = /[^a-zA-Z0-9α-ωΑ-Ωάέίόήώύ ]+/;
                var username = document.forms['formInsertUser']['username'].value;
                var role = document.forms['formInsertUser']['role'].value;
                var name = document.forms['formInsertUser']['name'].value;
                var lastname = document.forms['formInsertUser']['lastname'].value;
                var password = document.forms['formInsertUser']['password'].value;
                var address = document.forms['formInsertUser']['address'].value;
                var phone = document.forms['formInsertUser']['phone'].value;
                var email = document.forms['formInsertUser']['email'].value;
                if(username==="" || role==="" || name==="" || lastname==="" ||
                        password==="" || address==="" || phone==="" || email===""){
                    alert("Πρέπει να συμπληρώσετε όλα τα πεδία");
                    return false;
                }
                if(regex.test(username) || regex.test(name)
                    || regex.test(lastname) || regex.test(password) || regex_ad.test(address)
                    || regex.test(phone) || regex_em.test(email)){
                    alert("Δεν επιτρέπονται τα σύμβολα στα πεδία.");
                    return false;
                }
                return true;
            }
            
            function formDeleteUserValidation(){
                var regex = /[^a-zA-Z0-9α-ωΑ-Ωάέίόήώύ]+/;
                var username = document.forms['formDeleteUser']['username'].value;
                var name = document.forms['formDeleteUser']['name'].value;
                var lastname = document.forms['formDeleteUser']['lastname'].value;
                if(username==="" || name==="" || lastname===""){
                    alert("Πρέπει να συμπληρώσετε όλα τα πεδία");
                    return false;
                }
                if(regex.test(username) || regex.test(name) || regex.test(lastname)){
                    alert("Όλα τα πεδία πρέπει να έχουν μόνο αλφαβητικούς χαρακτήρες ή αριθμούς, από 5 και πάνω.");
                    return false;
                }
                return true;
            }
            
            function formInsertSupervisorsValidation(){
                var regex = /[^a-zA-Z0-9α-ωΑ-Ωάέίόήώύ]+/;
                var username = document.forms['formInsertSupervisors']['username'].value;
                var name = document.forms['formInsertSupervisors']['name'].value;
                var lastname = document.forms['formInsertSupervisors']['lastname'].value;
                var id_class = document.forms['formInsertSupervisors']['id_class'].value;
                if(username==="" || name==="" || lastname==="" || id_class===""){
                    alert("Πρέπει να συμπληρώσετε όλα τα πεδία");
                    return false;
                }
                if(regex.test(username) || regex.test(name) || regex.test(lastname)){
                    alert("Όλα τα πεδία πρέπει να έχουν μόνο αλφαβητικούς χαρακτήρες ή αριθμούς, από 5 και πάνω.");
                    return false;
                }
                return true;
            }
        </script>
    </body>
</html>
<%}%>