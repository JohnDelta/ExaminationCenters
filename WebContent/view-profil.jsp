
<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@include file="getUserType.jsp"%>
<%
if(!user.equals("supervisor") && !user.equals("admin")){
    response.sendRedirect("index.jsp");
}else{
    //DISPLAY ALL USER'S DATA 
%>
<%@include file="mysql-connection.jsp"%>

<!DOCTYPE html>
<html>
    <head>
        <title>ΕΠΓ - Προφίλ Χρήστη</title>
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
            
        <%
            String id_user="";
            String name="";
            String lastname="";
            String username="";
            String phone="";
            String address="";
            String email="";
            String role="";
            String sql;
            int i=0;
            ResultSet rs,rs2;
            Statement statement2 = connection.createStatement();
            boolean flag = true;
            if(request.getParameter("goToViewProfil")!=null){
                //get user's data
                name= request.getParameter("name");
                lastname= request.getParameter("lastname");
                username= request.getParameter("username");
                //see if the user exists
                sql = "select count(*) from user where name = '"+name+"' and username = '"+username+"'"
                        + " and lastname = '"+lastname+"'";
                rs = statement.executeQuery(sql);
                if(rs.next()){
                    if(rs.getInt("count(*)")<1)
                        flag = false;
                }
                rs.close();
                if(flag){
                    sql = "select * from user where name = '"+name+"' and username = '"+username+"'"
                        + " and lastname = '"+lastname+"'";
                    rs = statement.executeQuery(sql);
                    if(rs.next()){
                        id_user = rs.getString("id_user");
                        phone = rs.getString("phone");
                        address = rs.getString("address");
                        email = rs.getString("email");
                        if(rs.getInt("role")==1) role = "supervisor";
                        else if(rs.getInt("role")==2) role = "student";
                    }
                    rs.close();
                }else{
                    out.print("<script>alert('Δεν υπάρχει χρήστης με αυτά τα στοιχεία');</script>");
                    out.print("<script>window.location.replace('search-student.jsp');</script>");
                }
                //the user exists , show the proper titles according to user type
                if(user.equals("supervisor")){
                    out.print("<h3>Εξεταστικά κέντρα / Αναζήτηση Χρήστη / Προβολή Προφίλ");
                }else if(user.equals("admin")){
                    out.print("<h3>Χρήστες / Αναζήτηση Χρήστη / Προβολή Προφίλ");
                }
                out.print("<input type='button' value='Επιστροφή' onclick='back()' style='float:right;'></h3>");
            }
        %>
            <div class="profil-block">
                <div class="text">Όνομα Λογαριασμού</div> <input type="text" readonly value="<%=username%>">
                <div class="text">Όνομα</div> <input type="text" readonly value="<%=name%>">
                <div class="text">Επώνυμο</div> <input type="text" readonly value="<%=lastname%>">
            </div>
            <div class="profil-block">
                <div class="text">Ρόλος</div> <input type="text" readonly value="<%=role%>">
                <div class="text">Διεύθυνση</div> <input type="text" readonly value="<%=address%>">
            </div>
            <div class="profil-block">
                <div class="text">Τηλέφωνο</div> <input type="text" readonly value="<%=phone%>">
                <div class="text">Email</div> <input type="text" readonly value="<%=email%>">
            </div>
            <hr>
        <%
            if(role.equals("student")){
                //check if the student is assigned to classes
                sql = "select count(distinct id_class) from class_has_user where id_user = '"+id_user+"'";
                rs = statement.executeQuery(sql);
                flag = false;
                if(rs.next()){
                    if(rs.getInt("count(distinct id_class)")>0){
                        flag = true;
                    }
                }
                rs.close();
                if(flag){
                    out.print("<h4>Εξετάσεις στις οποίες είναι εγγεγραμμένος ο χρήστης</h4>");
                    //find all classes of student
                    sql = "select * from class_has_user,class,examination,subject where id_user = '"+id_user+"'"
                            + " and class_has_user.id_class = class.id_class and"
                            + " class.id_examination = examination.id_examination"
                            + " and examination.id_subject = subject.id_subject group by class.id_class";
                    rs = statement.executeQuery(sql);
                    out.print("<table class='table-next'><tr>"
                        + "<td>Κωδικός Κέντρου</td>"
                        + "<td>Όνομα Κέντρου</td>"
                        + "<td>Μάθημα</td>"
                        + "<td>Ημερομηνία Έναρξης</td>"
                        + "<td>Κατάσταση Εξέτασης</td></tr></table>"
                        +"<form method='POST' action='result-student.jsp' id='selectStudent'>"
                        +"<input type='hidden' name='viewProfil' value='viewProfil'>"
                        +"<input type='hidden' id='id_student' name='id_student' value=''>"
                        +"<input type='hidden' id='id_class' name='id_class' value=''>");
                    out.print("<table class='active-table'>");
                    i=0;
                    String mode = "";
                    String open = "";
                    while(rs.next()){
                        if(i%2==0) mode = "table-odd";
                        else mode = "table-even";
                        out.print("<tr class='"+mode+"' "
                            + "onClick='triggerSelectForm("+id_user+","+rs.getString("id_class")+")'>"
                            + "<td>"+rs.getString("class.id_class")+"</td>"
                            + "<td>"+rs.getString("class.name")+"</td>"
                            + "<td>"+rs.getString("subject.title")+"</td>"
                            + "<td>"+rs.getString("examination.date")+"</td>");
                            if(rs.getString("examination.open").equals("0")) open = "Αρχική - Κλειστή";
                            else if(rs.getString("examination.open").equals("1")) open = "Σε λειτουργία";
                            else if(rs.getString("examination.open").equals("2")) open = "Έχει λήξει";
                            out.print("<td>"+open+"</td></tr>");
                        i++;
                    }
                    out.print("</table></form>");
                    rs.close();
                }else{
                    out.print("<h4>Ο Εξεταζόμενος Δεν έχει Εγγραφεί σε κάποιο Εξεταστικό Κέντρο</h4>");
                }
            }else if(role.equals("supervisor")){
                //check if the supervisor is assigned to classes
                sql = "select count(distinct id_class) from class_has_user where id_user = '"+id_user+"'";
                rs = statement.executeQuery(sql);
                flag = false;
                if(rs.next()){
                    if(rs.getInt("count(distinct id_class)")>0){
                        flag = true;
                    }
                }
                rs.close();
                if(flag){
                    out.print("<h4>Εξεταστικά κέντρα στα οποία είναι εγγεγραμμένος ο χρήστης</h4>");
                    sql = "select * from class_has_user,class,examination,subject where id_user = '"+id_user+"'"
                        + " and class_has_user.id_class = class.id_class and"
                        + " class.id_examination = examination.id_examination"
                        + " and examination.id_subject = subject.id_subject";
                    rs = statement.executeQuery(sql);
                    out.print("<table class='table-next'><tr>"
                        + "<td>Κωδικός Κέντρου</td>"
                        + "<td>Εξεταστικό Κέντρο</td>"
                        + "<td>Μάθημα</td>"
                        + "<td>Ημερομηνία Έναρξης</td>"
                        + "<td>Κατάσταση Εξέτασης</td></tr></table>"
                        +"<form method='POST' action='result-student.jsp' id='selectStudent'>"
                        +"<input type='hidden' name='viewProfil' value='viewProfil'>"
                        +"<input type='hidden' id='id_student' name='id_student' value=''>"
                        +"<input type='hidden' id='id_class' name='id_class' value=''>");
                    out.print("<table class='active-table-result'>");
                    i=0;
                    String mode = "";
                    String open = "";
                    while(rs.next()){
                        if(i%2==0) mode = "table-odd";
                        else mode = "table-even";
                        out.print("<tr class='"+mode+"' "
                            + "onClick='triggerSelectForm("+id_user+","+rs.getString("id_class")+")'>"
                            + "<td>"+rs.getString("class.id_class")+"</td>"
                                    + "<td>"+rs.getString("class.name")+"</td>"
                            + "<td>"+rs.getString("subject.title")+"</td>"
                            + "<td>"+rs.getString("examination.date")+"</td>");
                            if(rs.getString("examination.open").equals("0")) open = "Αρχική - Κλειστή";
                            else if(rs.getString("examination.open").equals("1")) open = "Σε λειτουργία";
                            else if(rs.getString("examination.open").equals("2")) open = "Έχει λήξει";
                            out.print("<td>"+open+"</td></tr>");
                        i++;
                    }
                    out.print("</table></form>");
                    rs.close();
                }else{
                    out.print("<h4>Ο Υπεύθυνος Δεν έχει Εγγραφεί σε κάποιο Εξεταστικό Κέντρο</h4>");
                }
            }
        %>
        </div>
        <div class="footer">
           Ιωάννης Δεληγιάννης | Copyright &copy | cs151102 | Δικτυακός προγραμματισμός 2017-2018 | Πανεπιστήμιο Δυτικής Αττικής
        </div>
        
        <script>
            function triggerSelectForm(id_user,id_class){
                document.getElementById("id_student").value = id_user;
                document.getElementById("id_class").value = id_class;
                document.getElementById("selectStudent").submit();
            }
            function back(){
                 window.location.replace('search-student.jsp');
            }
        </script>
    </body>
</html>
<%}%>