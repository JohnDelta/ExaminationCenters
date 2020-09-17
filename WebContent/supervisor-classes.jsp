
<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@include file="getUserType.jsp"%>
<%
if(!user.equals("supervisor")){
    response.sendRedirect("index.jsp");
}else{
    String id_user = session.getAttribute("id_user").toString();
%>
<!DOCTYPE html>
<html>
    <head>
        <script src="https://ajax.googleapis.com/ajax/libs/jquery/3.3.1/jquery.min.js"></script>
        <title>ΕΠΓ - Εξεταστικά Κέντρα</title>
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
            <h3>Εξεταστικά κέντρα στα οποία είστε υπεύθυνος
            <input type="button" value="Αναζήτηση Χρήστη" style="float:right;" onclick="goToSearchUser()"></h3>
            <hr>
            <p>Επιλέξτε κάποιο από τα εξεταστικά κέντρα για να δείτε περισσότερες πληροφορίες για αυτό και τους
            εξεταζόμενους</p>
            <div id="classesWindow">
            </div>
        </div>
        <div class="footer">
           Ιωάννης Δεληγιάννης | Copyright &copy | cs151102 | Δικτυακός προγραμματισμός 2017-2018 | Πανεπιστήμιο Δυτικής Αττικής
        </div>
        <script>
            function formTriggerSelectClass(i){
                document.getElementById("id_class").value = i;
                document.getElementById('selectClass').submit();
            }
            function goToSearchUser(){
                document.location.replace("search-student.jsp");
            }
            function displayResult(data){
                //take the results in data and print them
                document.getElementById("classesWindow").innerHTML=""+
                    "<table>"+
                        "<tr class='table-first'>"+
                            "<td>Όνομα</td>"+
                            "<td>Κατάσταση Εξέτασης</td>"+
                            "<td>Ημερομηνία Εξέτασης</td>"+
                            "<td>Τίτλος Μαθήματος</td>"+
                            "<td>Αριθμός Εξεταζόμενων</td>"+
                        "</tr>"+
                    "</table>"+
                    "<form method='POST' action='supervisor-class.jsp' id='selectClass'>"+
                    "<input type='hidden' id='id_class' name='id_class' value=''>"+
                    "<table class='active-table' id='table'>";
                var mode;
                var state;
                for(var i=0;i<data.length;i++){
                    if(i%2===1) mode="table-odd";
                    else mode="table-even";
                    if(data[i]["examOpen"]==="0") state="Αρχική";
                    else if(data[i]["examOpen"]==="1") state="Σε Λειτουργία";
                    else if(data[i]["examOpen"]==="2") state="Ολοκληρωμένη";
                    $("#table").append("<tr class='"+mode+"'"+
                    "onClick='formTriggerSelectClass("+data[i]["id_class"]+")'>"+
                    "<td>"+data[i]["className"]+"</td>"+
                    "<td>"+state+"</td>"+
                    "<td>"+data[i]["examDate"]+"</td>"+
                    "<td>"+data[i]["subjectTitle"]+"</td>"+
                    "<td>"+data[i]["numberOfStudents"]+"</td></tr>");
                }
            }
            
            $(document).ready(function(){
                $.ajax({
                    type:'GET',
                    url:'/WebApplication/webresources/supervisor-classes/report/<%=id_user%>',
                    success: function(data){
                        if(data!==null){
                            var mode="table-odd";
                            displayResult(data);
                        }
                    }
                });
            });
        </script>
    </body>
</html>
<%}%>