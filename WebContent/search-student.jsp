
<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@include file="getUserType.jsp"%>
<%
if(!user.equals("supervisor") && !user.equals("admin")){
    response.sendRedirect("index.jsp");
}else{
%>
<%@include file="mysql-connection.jsp"%>

<!DOCTYPE html>
<html>
    <head>
        <title>ΕΠΓ - Αναζήτηση Χρήστη</title>
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
            <% 
                if(user.equals("guest")){ 
                    out.print("<a href='login.jsp'>Είσοδος</a>");
                }else{
                    out.print("<a href='profil.jsp'>Προφίλ</a>");
                    if(user.equals("admin")){ 
                        out.print("<a href='admin-users.jsp' class='highlight'>Χρήστες</a>");
                        out.print("<a href='admin-classes.jsp'>Εξεταστικά κέντρα</a>");
                        out.print("<a href='admin-exams.jsp'>Εξετάσεις</a>");
                        out.print("<a href='admin-subjects.jsp'>Μαθήματα</a>");
                        out.print("<a href='admin-questions.jsp'>Ερωτήσεις Μαθημάτων</a>");
                        out.print("<a href='admin-reports.jsp'>Αναφορές</a>");
                    }else if(user.equals("supervisor")){
                        out.print("<a href='supervisor-classes.jsp' class='highlight'>Εξεταστικά Κέντρα</a>");
                    }else if(user.equals("student")){
                        out.print("<a href='student-exams.jsp'>Εξετάσεις</a>");
                    }
                    out.print("<a href='logout.jsp' style='float:right;'>Αποσύνδεση</a>");
                } 
            %>
        </div>
        
        <div class="context">
            <h3>Εξεταστικά κέντρα / Αναζήτηση Χρήστη
                <input type="button" value="Επιστροφή" onclick="back()" style="float:right;"></h3>
            <hr>
            
            <div class="format-forms">
                <form name="searchStudent" method="POST" action="view-profil.jsp" onsubmit="return validateStudentSearchForm()">
                    <h3>Εισαγωγή στοιχείων Χρήστη</h3>
                    <p>Όνομα λογαριασμού</p> <input type="text" name="username">
                    <p>Όνομα</p> <input type="text" name="name">
                    <p>Επώνυμο</p> <input type="text" name="lastname">
                    <input type="submit" value="Αναζήτηση" name="goToViewProfil">
                </form>
            </div>
            
        </div>
        
        <div class="footer">
           Ιωάννης Δεληγιάννης | Copyright &copy | cs151102 | Δικτυακός προγραμματισμός 2017-2018 | Πανεπιστήμιο Δυτικής Αττικής
        </div>
        
        <script>
            function validateStudentSearchForm(){
                var username = document.forms["searchStudent"]["username"].value;
                var name = document.forms["searchStudent"]["name"].value;
                var lastname = document.forms["searchStudent"]["lastname"].value;
                if(username==="" || name==="" || lastname===""){
                    alert("Πρέπει να συμπληρώσετε όλα τα πεδία για να γίνει η αναζήτηση");
                    return false;
                }else{
                    return true;
                }
            }
            function back(){
                <%
                    if(user.equals("supervisor")){
                        out.print("window.location.replace('supervisor-classes.jsp');");
                    }else if(user.equals("admin")){
                        out.print("window.location.replace('admin-users.jsp');");
                    }
                %>
            }
        </script>
    </body>
</html>
<%}%>