
<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@include file="getUserType.jsp"%>
<%
if(!user.equals("student")){
    response.sendRedirect("index.jsp");
}else{
%>
<%@include file="mysql-connection.jsp"%>
<!DOCTYPE html>
<html>
    <head>
        <title>ΕΠΓ - Εξετάσεις</title>
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
            <a href='student-exams.jsp' class='highlight'>Εξετάσεις</a>
            <a href='logout.jsp' style='float:right;'>Αποσύνδεση</a>
        </div>
        
        <div class="context">
            <h3>Εξετάσεις στις οποίες έχετε εγγραφεί</h3>
            <hr>
            <%
                int i=0;
                String mode=null;
                String id_user = session.getAttribute("id_user").toString();
                //check if the user is assigned to exams - classes
                boolean hasClasses=false;
                String sql = "select count(*) from class_has_user where id_user = '"+id_user+"'";
                ResultSet rs = statement.executeQuery(sql);
                if(rs.next()){
                    if(rs.getInt("count(*)")>0){
                        hasClasses = true;
                    }
                }
                rs.close();
        if(hasClasses){
        %>
            <p>Όταν η κατάσταση μιας εξέτασης γίνει ανοικτή σημαίνει ότι μπορείται να δείτε τις ερωτήσεις σας.
                Απαντήστε στις ερωτήσεις μεταξύ του επιτρεπτού χρόνου εξέτασης διαφορετικά τα αποτελέσματα
                θα μετρηθούν ως λανθασμένα!</p>
            <table>
                <tr class="table-next">
                    <td>Εξεταστικό Κέντρο</td>
                    <td>Κωδικός Εξέτασης</td>
                    <td>Τίτλος Μαθήματος</td>
                    <td>Ημερομηνία Έναρξης</td>
                    <td>Κατάσταση Εξέτασης</td>
                </tr>
            </table>
            
                <table class="active-table">
                    <%
                        
                        sql="select * from user,class,examination,class_has_user,subject"
                            + " where user.id_user=class_has_user.id_user"
                            + " and class_has_user.id_class=class.id_class"
                            + " and class.id_examination = examination.id_examination"
                            + " and examination.id_subject = subject.id_subject and user.id_user = "+id_user+""
                            + " group by examination.id_examination";
                        rs = statement.executeQuery(sql);
                        while(rs.next()){
                            String highlight="";
                            if(rs.getString("examination.open").equals("1")){
                                highlight="style='background-color:#aec7ef'";
                            }
                            out.print("<form id='row"+i+"' method='POST' action='student-exam.jsp'>");
                            if(i%2==0) mode="table-odd";
                                else mode="table-even";
                            out.print("<tr class='"+mode+"' onclick='formTriggerSelectExam(\"row"+i+"\")' "+highlight+">");
                            out.print("<td>"+rs.getString("class.name")+"</td>"+
                                "<td>"+rs.getString("examination.id_examination")+"</td>"+
                                "<td>"+rs.getString("subject.title")+"</td>"+
                                "<td>"+rs.getDate("examination.date")+" "+rs.getTime("examination.date")+"</td>");
                            if(rs.getString("examination.open").equals("0") || rs.getString("examination.open").equals("2")){
                                out.print("<td>Κλειστή</td>");
                            }else if(rs.getString("examination.open").equals("1")){
                               out.print("<td>Ανοιχτή</td>"); 
                            }  
                            out.print("<input type='hidden' name='id_class' value='"+rs.getString("class.id_class")+"'>");
                            out.print("<input type='hidden' name='name' value='"+rs.getString("class.name")+"'>");
                            out.print("<input type='hidden' name='title' value='"+rs.getString("subject.title")+"'>");
                            out.print("<input type='hidden' name='date' value='"+rs.getDate("examination.date")+" "+rs.getTime("examination.date")+"'>");
                            out.print("<input type='hidden' name='open' value='"+rs.getString("examination.open")+"'></tr>");
                            out.print("</form>");
                            i++;
                        }
                        rs.close();
                        connection.close();
                    %>
                </table>
            </form>
            
        <%}
        else{
            out.print("<p>Δεν είστε ακόμα εγγεγραμμένος σε κάποια τάξη.</p>");
        }
        %>
        </div>
        
        <div class="footer">
           Ιωάννης Δεληγιάννης | Copyright &copy | cs151102 | Δικτυακός προγραμματισμός 2017-2018 | Πανεπιστήμιο Δυτικής Αττικής
        </div>
            <script>
                function formTriggerSelectExam(rowId){
                    document.getElementById(rowId).submit();
                }
            </script>
    </body>
</html>
<%}%>