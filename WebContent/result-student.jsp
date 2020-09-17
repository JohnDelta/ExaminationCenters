
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
        <title>ΕΠΓ - Αποτέλεσμα Αναζήτησης</title>
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
                /*FIND THE STUDENT, AND IF HIS EXAM IS OVER DISPLAY HIS RESULTS
                
                  THE SUPERVISOR CAN DELETE THE STUDENT IF HE IS IN THE SAME CLASS*/
                if(request.getParameter("id_class")!=null && request.getParameter("id_student")!=null){
                    
                    Statement statement2 = connection.createStatement();
                    ResultSet rs2;
                    String username = "";
                    String name = "";
                    String lastname = "";
                    String id_class = "";
                    String id_user="";
                    String id_examination="";
                    String question="";
                    String open="";
                    String correct="";
                    String msg="";
                    String sql="";
                    ResultSet rs;
                    int c=0;
                    int i=0;
                    String mode="";
                    
                    id_user = request.getParameter("id_student").toString();
                    id_class = request.getParameter("id_class").toString();
                    sql = "select * from user where id_user = '"+id_user+"'";
                    rs = statement.executeQuery(sql);
                    if(rs.next()){
                        username = rs.getString("username");
                        name = rs.getString("name");
                        lastname = rs.getString("lastname");
                    }
                    rs.close();
                    
                    String titles="";
                    //user came here from view profil page , set-up the proper titles
                    if(request.getParameter("viewProfil")!=null){
                        if(user.equals("supervisor")){
                            titles = "Εξεταστικά κέντρα / Αναζήτηση Χρήστη / Προβολή Προφίλ";
                        }else{
                            titles = "Χρήστες / Αναζήτηση Χρήστη / Προβολή Προφίλ";
                        } 
                    }else if(request.getParameter("supervisorClass")!=null){
                        sql = "select * from class where id_class = '"+id_class+"'";
                        rs = statement.executeQuery(sql);
                        if(rs.next()){
                            titles = "Εξεταστικό Κέντρο : "+rs.getString("name")+" | Διεύθυνση : "
                                + rs.getString("address") + " | Κωδικός : "+rs.getString("id_class");
                        }
                        rs.close();
                    }
                    
                    //if the user exists
                    if(!id_user.equals("")){%>
                        <form method='POST' action='supervisor-class.jsp' id='backToClasses'>
                            <input type='hidden' name='id_class' value='<%=id_class%>'>
                        </form>
                        <form method='POST' action='view-profil.jsp' id='backToViewProfil'>
                            <input type='hidden' name='username' value='<%=username%>'>
                            <input type='hidden' name='name' value='<%=name%>'>
                            <input type='hidden' name='lastname' value='<%=lastname%>'>
                            <input type='hidden' name='goToViewProfil' value='goToViewProfil'>
                        </form>
                        <h3><%=titles%>
                        <input type='button' value='Επιστροφή' onclick='back()' style='float:right;'></h3>
                        <h3>Εξεταζόμενος : <%=name%> <%=lastname%> | username : <%=username%> | Τμήμα : <%=id_class%></h3>
                        <hr>
                        
                        <%
                        //check if the supervisor would be able to delete the student from the class
                        //they must be in the same class
                        if(user.equals("supervisor")){
                            boolean flag = true;
                            sql = "select count(*) from class_has_user where id_user = '"+id_user+"'"
                                    + "and id_class = '"+id_class+"'";
                            rs = statement.executeQuery(sql);
                            if(rs.next()){
                                if(rs.getInt("count(*)")<1){
                                    flag = false;
                                }
                            }
                            rs.close();
                            sql = "select count(*) from class_has_user where"
                                    +" id_user = '"+session.getAttribute("id_user")+"'"
                                    + "and id_class = '"+id_class+"'";
                            rs = statement.executeQuery(sql);
                            if(rs.next()){
                                if(rs.getInt("count(*)")<1){
                                    flag = false;
                                }
                            }
                            if(flag){
                                out.print("<form action='supervisor-class.jsp' method='post'>");
                                out.print("<input type='submit' name='removeStudent' value='Αφαίρεση υποψήφιου'>");
                                out.print("<input type='hidden' name='id_class' value='"+id_class+"'>");
                                out.print("<input type='hidden' name='id_student' value='"+id_user+"'>");
                                out.print("</form>");
                            }
                            rs.close();
                        }
                        
                        //get his class data
                        sql = "select * from class where id_class = '"+id_class+"'";
                        rs = statement.executeQuery(sql);
                        if(rs.next()){
                            id_examination = rs.getString("id_examination");
                        }
                        rs.close();
                        sql = "select * from examination where id_examination = '"+id_examination+"'";
                        rs = statement.executeQuery(sql);
                        if(rs.next()){
                            open = rs.getString("open");
                        }
                        rs.close();
                        //if the class is active or initial do not show exam data else show them
                        if(open.equals("1") || open.equals("0")){
                            msg = "Ο χρήστης δεν έχει βαθμολογίες. Η εξέταση δεν έχει ολοκληρωθεί";
                            out.print("<p>"+msg+"</p>");
                        }else if(open.equals("2")){
                            //check if the user participated to the exam
                            sql = "select count(*) from class_has_user where id_user = '"+id_user+"' and"
                                    + " id_class = '"+id_class+"'";
                            rs = statement.executeQuery(sql);
                            if(rs.next()){
                                c = rs.getInt("count(*)");
                            }
                            rs.close();
                            if(c==1){
                                //user does not have any questions
                                msg="Η εξέταση ολοκληρώθηκε και ο χρήστης δεν συμμετείχε";
                                out.print("<p>"+msg+"</p>");
                            }else{
                                msg="Η αναλυτική βαθμολογία του μαθητή για την εξέταση";
                                out.print("<p>"+msg+"</p>");
                                //take the user's questions
                                sql = "select * from class_has_user where id_user = '"+id_user+"' and"
                                        + " id_class = '"+id_class+"'";
                                rs = statement.executeQuery(sql);
                                i=0;
                                //set-up the table
                                %>
                                <table>
                                <tr class="table-next">
                                    <td>Ερώτηση</td>
                                    <td>Απάντηση Χρήστη</td>
                                    <td>Ημερομηνία Απάντησης</td>
                                    <td>Ορθότητα Απάντησης</td>
                                </tr>
                                </table>
                                <table class="active-table-result">
                                <%
                                while(rs.next()){
                                    //find the question
                                    sql = "select question from question where id_question = '"+rs.getString("id_question")+"'";
                                    rs2 = statement2.executeQuery(sql);
                                    if(rs2.next()){
                                        question = rs2.getString("question");
                                    }
                                    rs2.close();
                                    //set up the table - row - css - class
                                    if(i%2==0)mode="table-odd"; else mode="table-even";
                                    out.print("<tr class='"+mode+"'>");
                                    //for every user's question, check if there is an answer
                                    if(rs.getString("answer").equals("")){
                                        //there is no answer. display only the question
                                        out.print("<td>"+question+"</td>");
                                        out.print("<td> - </td>");
                                        out.print("<td> - </td>");
                                        out.print("<td> - </td>");
                                    }else{
                                        out.print("<td>"+question+"</td>");
                                        out.print("<td>"+rs.getString("answer")+"</td>");
                                        out.print("<td>"+rs.getString("date")+"</td>");
                                        //set-up correct answer
                                        if(rs.getString("correct").equals("0")) correct = "wrong";
                                        else if(rs.getString("correct").equals("1")) correct = "correct";
                                        out.print("<td>"+correct+"</td>");
                                    }
                                    out.print("</tr>");
                                    i++;
                                }
                                rs.close();
                            }
                        }   
            %>  
            </table>
            <%
                    }else{
                        out.print("<script>alert('Ο χρήστης δεν βρέθηκε!')</script>");
                        out.print("<script>window.location.replace('search-student.jsp');</script>");
                    }
                }
            %>
        </div>
        <div class="footer">
           Ιωάννης Δεληγιάννης | Copyright &copy | cs151102 | Δικτυακός προγραμματισμός 2017-2018 | Πανεπιστήμιο Δυτικής Αττικής
        </div>
        
        <script>
            function back(){
                <%
                    if(request.getParameter("submit")!=null){
                        out.print("window.location.replace('search-student.jsp');");
                    }else if(request.getParameter("id_student")!=null){
                        if(request.getParameter("viewProfil")!=null){
                            out.print("document.forms['backToViewProfil'].submit();");
                        }else{
                            out.print("document.forms['backToClasses'].submit();");
                        }
                    }
                %>
                
            }
        </script>
    </body>
</html>
<%}%>