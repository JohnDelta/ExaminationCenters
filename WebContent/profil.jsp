
<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@include file="getUserType.jsp"%>
<%@include file="mysql-connection.jsp"%>
<%if(!user.equals("student") && !user.equals("admin") && !user.equals("supervisor")){
    response.sendRedirect("index.jsp");
}else{
%>
<%
    String sql = "select * from user where id_user="+session.getAttribute("id_user");
    ResultSet result = statement.executeQuery(sql);
    String name="";
    String lastname="";
    String phone="";
    String email="";
    String username="";
    String address="";
    if(result.next()){
        name=result.getString("name");
        username=result.getString("username");
        lastname=result.getString("lastname");
        phone=result.getString("phone");
        email=result.getString("email");
        address=result.getString("address");
    }
%>

<!DOCTYPE html>
<html>
    <head>
        <title>ΕΠΓ - Προφίλ</title>
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
                    out.print("<a href='profil.jsp' class='highlight'>Προφίλ</a>");
                    if(user.equals("admin")){ 
                        out.print("<a href='admin-users.jsp'>Χρήστες</a>");
                        out.print("<a href='admin-classes.jsp'>Εξεταστικά κέντρα</a>");
                        out.print("<a href='admin-exams.jsp'>Εξετάσεις</a>");
                        out.print("<a href='admin-subjects.jsp'>Μαθήματα</a>");
                        out.print("<a href='admin-questions.jsp'>Ερωτήσεις Μαθημάτων</a>");
                        out.print("<a href='admin-reports.jsp'>Αναφορές</a>");
                    }else if(user.equals("supervisor")){
                        out.print("<a href='supervisor-classes.jsp'>Εξεταστικά Κέντρα</a>");
                    }else if(user.equals("student")){
                        out.print("<a href='student-exams.jsp'>Εξετάσεις</a>");
                    }
                    out.print("<a href='logout.jsp' style='float:right;'>Αποσύνδεση</a>");
                } 
            %>
        </div>
        
        <div class="context">
            <h3>Στοιχεία χρήστη</h3>
            <hr>
            <div class="profil-block">
                <div class="text">Ιδιότητα</div><input type="text" name="type" readonly value="<%=user%>">
                <div class="text">Όνομα</div><input type="text" name="name" readonly value="<%=name%>">
                <div class="text">Επίθετο</div><input type="text" name="lastname" readonly value="<%=lastname%>">
                <div class="text">Όνομα λογαριασμού</div><input type="text" name="username" readonly value="<%=username%>">
                <div class="text">E-mail</div><input type="text" name="username" readonly value="<%=email%>">
            </div>
            <div class="profil-block">
                <div class="text">Διεύθυνση</div><input type="text" name="username" readonly value="<%=address%>">
                <div class="text">Τηλέφωνο</div><input type="text" name="username" readonly value="<%=phone%>">
            </div>
        </div>
        
        <div class="footer">
           Ιωάννης Δεληγιάννης | Copyright &copy | cs151102 | Δικτυακός προγραμματισμός 2017-2018 | Πανεπιστήμιο Δυτικής Αττικής
        </div>
        
    </body>
</html>
<%}%>