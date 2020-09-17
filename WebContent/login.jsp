
<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@include file="getUserType.jsp"%>
<%@include file="mysql-connection.jsp"%>
<%
    String msg="";
    if(request.getParameter("login")!=null){
        String username = request.getParameter("username");
        String password = request.getParameter("password");
        try{
            String sql = "select * from user where username='"+username+"' and password='"+password+"'";
            ResultSet result = statement.executeQuery(sql);
            if(result.first()){
                session.setAttribute("id_user", result.getString("id_user"));
                session.setAttribute("name", result.getString("name"));
                session.setAttribute("role", result.getString("role"));
                connection.close();
                response.sendRedirect("index.jsp");
            }else{
                msg = "<script>alert('Wrong Username or Password!');</script>";
                connection.close();
            }
        }catch(Exception e){
            e.printStackTrace();
        }
    }
%>

<!DOCTYPE html>
<html>
    <head>
        <title>ΕΠΓ - Είσοδος</title>
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
            <% 
                if(user.equals("guest")){ 
                    out.print("<a href='login.jsp' class='highlight'>Είσοδος</a>");
                }else{
                    out.print("<a href='profil.jsp'>Προφίλ</a>");
                    if(user.equals("admin")){ 
                        out.print("<a href='admin-users.jsp'>Χρήστες</a>");
                        out.print("<a href='admin-classes.jsp'>Εξεταστικά κέντρα</a>");
                        out.print("<a href='admin-exams.jsp'>Εξετάσεις</a>");
                        out.print("<a href='admin-exam.jsp'>Ερωτήσεις Εξετάσεων</a>");
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
            <div class="login">
                <div class="box">
                    <p>Εισάγεται τα στοιχεία σας για είσοδο στο σύστημα</p>
                    <form name="login" action="login.jsp" onsubmit="return validateFormLogin()" method="POST">
                        <input type="text" name="username" placeholder="Όνομα Χρήστη">
                        <input type="password" name="password" placeholder="Κωδικός Πρόσβασης">
                        <input type="submit" name="login" value="Είσοδος">
                    </form>
                    </div>
            </div>
        </div>
        
        <div class="footer">
           Ιωάννης Δεληγιάννης | Copyright &copy | cs151102 | Δικτυακός προγραμματισμός 2017-2018 | Πανεπιστήμιο Δυτικής Αττικής
        </div>
        
        <script>
            function validateFormLogin(){
                var regex = /[^a-zA-Z0-9]{1,50}/;
                var username = document.forms["login"]["username"].value;
                var password = document.forms["login"]["password"].value;
                console.log("username ; ",!regex.test(username));
                if(username==="" || password===""){
                    alert("Τα πεδία δεν μπορούν να είναι κενά!");
                    return false;
                }
                if(regex.test(username) || regex.test(password)){
                    alert("Τα πεδία πρέπει να έχουν μόνο αλφαβητικούς χαρακτήρες ή αριθμούς, από 5 και πάνω.");
                    return false;
                }
                return true;
            };
        </script>
    </body>
</html>