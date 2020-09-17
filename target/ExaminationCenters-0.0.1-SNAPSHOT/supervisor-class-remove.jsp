%>
<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@include file="getUserType.jsp"%>
<%
if(!user.equals("supervisor")){
    response.sendRedirect("index.jsp");
}else{
%>
<%@include file="mysql-connection.jsp"%>

<%
    //id_class coming back from supervisor-class-remove-excel
    String id_class="";
    if(session.getAttribute("id_class")!=null){
        id_class = session.getAttribute("id_class").toString();
    }
    //remove student from class form
    if(request.getParameter("insert")!=null){
        String username = request.getParameter("username");
        String name = request.getParameter("name");
        String lastname = request.getParameter("lastname");
        id_class = request.getParameter("id_class");
        
        //check if the user exists
        String id_user=null;
        int alreadyIn=0;
        String sql = "select * from user where username = '"+username+"' and "
            + "name = '"+name+"' and lastname = '"+lastname+"' and role = '2'";
        ResultSet rs = statement.executeQuery(sql);
        if(rs.first()){
            if(rs.getString("id_user")!=null)
                id_user = rs.getString("id_user");
        }
        rs.close();
        if(id_user!=null){
            //check if the user is  in the class
            sql = "select count(*) from class_has_user where id_user = '"+id_user+"' and id_class = '"+id_class+"'";
            rs = statement.executeQuery(sql);
            if(rs.first()){
                alreadyIn = rs.getInt("count(*)");
            }
            rs.close();
            if(alreadyIn>0){
                //remove student
                sql = "delete from class_has_user where id_user = '"+id_user+"' and"
                        + " id_class = '"+id_class+"'";
                statement.executeUpdate(sql);
                out.print("<script>alert('Η Αφαίρεση ολοκληρώθηκε');</script>");
            }
            else{
                //user is not is the class
                out.print("<script>alert('Ο χρήστης δεν είναι εγγεγραμμένος στο εξεταστικό κέντρο');</script>");
            }
        }else{
            //user does not exists
            out.print("<script>alert('Τα στοιχεία χρήστη δεν βρέθηκαν');</script>");
        }
    }
    
    //take info coming from supervisor-classes form
    String sql="";
    ResultSet rs=null;
    String className="";
    String id_exam="";
    String subjectName="";
    String id_user = session.getAttribute("id_user").toString();
    
    if(request.getParameter("id_class")!=null){
        id_class = request.getParameter("id_class").toString();
    }
    //get the class - exam info
    sql = "select * from class_has_user,class,examination,subject where"
            + " class_has_user.id_class = class.id_class and class.id_examination"
            + " = examination.id_examination and examination.id_subject = subject.id_subject"
            + " and class_has_user.id_class = '"+id_class+"' and class_has_user.id_user = '"+id_user+"'";
    rs = statement.executeQuery(sql);
    if(rs.first()){
        className = rs.getString("class.name");
        id_exam = rs.getString("examination.id_examination");
        subjectName = rs.getString("subject.title");
    }
    rs.close();
    session.setAttribute("id_class", id_class);   
%>
<!DOCTYPE html>
<html>
    <head>
        <title>ΕΠΓ - Αφαίρεση απο Κέντρο</title>
        <meta charset="UTF-8">
        <meta name="viewport" content="width=device-width, initial-scale=1.0">
        <link rel="stylesheet" type="text/css" href="style.css">
    </head>
    <body>
        <div class="header">
            <font style="color:#448AFF;">Ε</font>ξετάσεις
            <font style="color:#448AFF;">Π</font>ιστοποίησης 
            <font style="color:#448AFF;">Γ</font>νώσεων
            <%if(!user.equals("guest")) out.print("<p>Logged in as : "+session.getAttribute("name")+"</p>");%>
        </div>
        
        <div class="nav">
            <a href="index.jsp">Αρχική</a>
            <a href='profil.jsp'>Προφίλ</a>
            <a href='supervisor-classes.jsp' class='highlight'>Εξεταστικά Κέντρα</a>
            <a href='logout.jsp' style='float:right;'>Αποσύνδεση</a>
        </div>
        
        <div class="context">
            <h4>Εξεταστικό κέντρο : <%=className%> | Κωδικός : <%=id_class%>
                | Εξέταση : <%=subjectName%> | Κωδικός : <%=id_exam%> 
                <input type="button" value="Επιστροφή" onclick="backToClass()" style="float:right;"></h4>
            <h4>Αφαίρεση Εξεταζομένων από το Εξεταστικό Κέντρο</h4>
            <hr>
            <form id='formToClass' method='post' action='supervisor-class.jsp'>
                <input type='hidden' name='id_class' value='<%=id_class%>'>
            </form>
            
            <div class="format-forms">
                <form name="formRemove" method="POST" action="supervisor-class-remove.jsp"
                      onsubmit="return validateStudentRemoveForm()">
                    <h4>Εισαγωγή στοιχείων εξεταζόμενου</h4>
                    <p>Όνομα λογαριασμού</p> <input type="text" name="username" maxlength='50'>
                    <p>Όνομα</p> <input type="text" name="name" maxlength='50'>
                    <p>Επώνυμο</p> <input type="text" name="lastname" maxlength='50'>
                    <p>Διαθέσιμο εξεταστικό κέντρο</p>
                    <select name="class">
                        <option value='<%=id_class%>'><%=className%> | <%=id_class%></option>
                    </select>
                    <input type="submit" value="Αφαίρεση" name="insert">
                    <input type='hidden' value="<%=id_class%>" name='id_class'>
                </form>
            </div>
            
            <div class="format-forms" style="float:right;">
                <h4>Εισαγωγή Εξεταζόμενου απο αρχείο excel</h4>
                <h4>Μορφή : Όνομα λογαριασμού | Όνομα | Επώνυμο | Κωδικός εξεταστικού κέντρου</h4>
                <h5>Η πρώτη γραμμή του αρχείου είναι για τους τίτλους και παραλείπεται</h5>
                <form method="POST" action="supervisor-class-remove-excel.jsp" onsubmit="return validateFileForm()" enctype = "multipart/form-data">
                    <input type="file" name="file" size="50" id="file">
                    <input type="submit" name="upload" value="Ανέβασμα άρχειου">
                </form> 
            </div>
            
        </div>
        
        <div class="footer">
           Ιωάννης Δεληγιάννης | Copyright &copy | cs151102 | Δικτυακός προγραμματισμός 2017-2018 | Πανεπιστήμιο Δυτικής Αττικής
        </div>
        
        <script>
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
            function backToClass(){
                document.getElementById('formToClass').submit();
            }
            function validateStudentRemoveForm(){
                var regex = /[^a-zA-Z0-9α-ωΑ-Ωάέίόήώύ]+/;
                var username = document.forms["formInsert"]["username"].value;
                var name = document.forms["formInsert"]["name"].value;
                var lastname = document.forms["formInsert"]["lastname"].value;
                var id_class = document.forms["formInsert"]["class"].value;
                if(username==="" || name==="" || lastname==="" || id_class===""){
                    alert("Πρέπει να συμπληρώσετε όλα τα πεδία για να γίνει η Εισαγωγή");
                    return false;
                }
                if(regex.test(username) || regex.test(name) || regex.test(lastname)){
                    alert("Δεν επιτρέπονται τα σύμβολα");
                    return false;
                }
                return true;
            }
        </script>
    </body>
</html>
<%}%>