
<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@include file="getUserType.jsp"%>
<%@include file="mysql-connection.jsp"%>
<%
if(!user.equals("supervisor") || request.getParameter("id_class")==null){
    response.sendRedirect("index.jsp");
}else{
    String id_user = session.getAttribute("id_user").toString();
    String id_class = request.getParameter("id_class").toString();
    String id_exam="";
    String sql="";
    
    //remove student from class form
    if(request.getParameter("removeStudent")!=null){
        sql = "delete from class_has_user where id_user = '"+request.getParameter("id_student")+"'"
                + " and id_class = '"+id_class+"'";
        statement.executeUpdate(sql);
        out.print("<script>alert('Ο μαθητής διαγράφηκε από το εξεταστικό κέντρο');</script>");
    }
    
    //check the forms in the submit buttons for start and close the exam
    if(request.getParameter("start")!=null){
        //start the exam - set the examination.open field to 1
        id_exam = request.getParameter("id_exam");
        sql = "update examination set open = '1' where id_examination = '"+id_exam+"'";
        statement.executeUpdate(sql);
    }
    if(request.getParameter("close")!=null){
        //close the exam - set the examination.open field to 2
        id_exam = request.getParameter("id_exam");
        sql = "update examination set open = '2' where id_examination = '"+id_exam+"'";
        statement.executeUpdate(sql);
    }
    if(request.getParameter("initial")!=null){
        //set the exam to initial state, set the examination.open field to 0
        id_exam = request.getParameter("id_exam");
        sql = "update examination set open = '0' where id_examination = '"+id_exam+"'";
        statement.executeUpdate(sql);
    }
    
    String className="";
    String classAddress="";
    String examOpen="";
    String examDate="";
    String subjectName="";
    String state="";
    //get the class - exam info
    sql = "select * from class_has_user,class,examination,subject where"
            + " class_has_user.id_class = class.id_class and class.id_examination"
            + " = examination.id_examination and examination.id_subject = subject.id_subject"
            + " and class_has_user.id_class = '"+id_class+"' and class_has_user.id_user = '"+id_user+"'";
    ResultSet rs = statement.executeQuery(sql);
    if(rs.first()){
        className = rs.getString("class.name");
        classAddress = rs.getString("class.address");
        id_exam = rs.getString("examination.id_examination");
        examOpen = rs.getString("examination.open");
        examDate = rs.getString("examination.date");
        subjectName = rs.getString("subject.title");
    }
    rs.close();
    if(examOpen.equals("0")) state="Αρχική - κλειστή";
    else if(examOpen.equals("1")) state="Σε Λειτουργία";
    else if(examOpen.equals("2")) state="Απενεργοποιημένη";
%>
<!DOCTYPE html>
<html>
    <head>
        <script src="https://ajax.googleapis.com/ajax/libs/jquery/3.3.1/jquery.min.js"></script>
        <title>ΕΠΓ - Εξεταστικό Κέντρο</title>
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
            <h3>Εξεταστικό κέντρο : <%=className%> | Διεύθυνση : <%=classAddress%> | Κωδικός : <%=id_class%>
                <input type="button" value="Επιστροφή" onclick="backToClasses()" style="float:right;"></h3>
            <h3>Εξέταση : <%=subjectName%> | Κωδικός : <%=id_exam%> | 
                Ημερομηνία Έναρξης : <%=examDate%></h3>
            <h4>Κατάσταση Εξέτασης : <%=state%> <div id='timer' style='float:right;'></div></h4>
            <hr>
            <form method='post' action='supervisor-class-insert.jsp' style='display:inline;'>
                <input type="submit" value="Εισαγωγή υποψηφίων">
                <input type='hidden' name='id_class' value='<%=id_class%>'>
            </form>
            <form method='post' action='supervisor-class-remove.jsp' style='display:inline;'>
                <input type="submit" value="Αφαίρεση υποψηφίων">
                <input type='hidden' name='id_class' value='<%=id_class%>'>
            </form>
            <%if(examOpen.equals("0")){
                out.print("<form name='startForm' method='post' action='supervisor-class.jsp' style='display:inline;'>");
                out.print("<input type='submit' name='start' value='Εναρξη Εξέτασης' style='float:right;'>");
                out.print("<input type='hidden' name='id_class' value='"+id_class+"'>");
                out.print("<input type='hidden' name='id_exam' value='"+id_exam+"'>");
                out.print("</form>");}%>
            <%if(examOpen.equals("1")){
                out.print("<form name='closeForm' method='post' action='supervisor-class.jsp' style='display:inline;'>");
                out.print("<input type='submit' name='close' value='Λήξη Εξέτασης' style='float:right;'>");
                out.print("<input type='hidden' name='id_class' value='"+id_class+"'>");
                out.print("<input type='hidden' name='id_exam' value='"+id_exam+"'>");
                out.print("</form>");}%>
            <%if(examOpen.equals("2")){
                out.print("<form name='InitialForm' method='post' action='supervisor-class.jsp' style='display:inline;'>");
                out.print("<input type='submit' name='initial' value='Επαναφορά Εξέτασης' style='float:right;'>");
                out.print("<input type='hidden' name='id_class' value='"+id_class+"'>");
                out.print("<input type='hidden' name='id_exam' value='"+id_exam+"'>");
                out.print("</form>");}%>
            
            <div id='classWindow'>  
            </div>
            
        </div>
        
        <div class="footer">
           Ιωάννης Δεληγιάννης | Copyright &copy | cs151102 | Δικτυακός προγραμματισμός 2017-2018 | Πανεπιστήμιο Δυτικής Αττικής
        </div>
        
        <script>
            
            $(document).ready(function(){
                //setup the countdown. 5 minutes from the start date
                var startDate = new Date("<%=examDate%>").getTime();
                var endDate = new Date(startDate+5*60000).getTime();
                //start the counter
                startTimer(startDate,endDate);
                
                $(document).ready(function(){
                    $.ajax({
                        type:'GET',
                        url:'/WebApplication/webresources/supervisor-class/report/<%=id_class%>',
                        success: function(data){
                            if(data!==null){
                                if(data==="no-result"){
                                    document.getElementById("classWindow").innerHTML="Η Τάξη δεν έχει ακόμα μαθητές";
                                }else{
                                    displayResult(data);
                                }
                            }else{
                                document.getElementById("classWindow").innerHTML="Η Τάξη δεν έχει ακόμα μαθητές";
                            }
                        }
                    });
                });
            });
            
            function displayResult(data){
                //take the results in data and print them
                document.getElementById("classWindow").innerHTML=""+
                    "<form method='get' action='SupervisorReportDownload'>"+
                    "<input id='download-supervisor' alt='download report' type='submit' value=''>"+
                    "<input type='hidden' name='id_class' value='<%=id_class%>'>"+
                    "</form>Η Εξεταζόμενοι που είναι εγγεγραμένοι στην τάξη"+
                    "<table>"+
                        "<tr class='table-first'>"+
                            "<td>Όνομα Λογαριασμού</td>"+
                            "<td>Όνομα</td>"+
                            "<td>Επώνυμο</td>"+
                            "<td>Βαθμός</td>"+
                        "</tr>"+
                    "</table>"+
                    "<form method='POST' action='result-student.jsp' id='selectUser'>"+
                    "<input type='hidden' name='supervisorClass' value='supervisorClass'>"+
                    "<input type='hidden' id='id_student' name='id_student' value=''>"+
                    "<input type='hidden' id='id_class' name='id_class' value=''>"+
                    "<table class='active-table' id='table'>";
                var mode;
                for(var i=0;i<data.length;i++){
                    if(i%2===0) mode="table-odd";
                    else mode="table-even";
                    $("#table").append("<tr class='"+mode+"'"+
                    "onClick='formTriggerSelectUser("+<%=id_class%>+","+data[i]["id_student"]+")'>"+
                    "<td>"+data[i]["username"]+"</td>"+
                    "<td>"+data[i]["name"]+"</td>"+
                    "<td>"+data[i]["lastname"]+"</td>"+
                    "<td>"+data[i]["score"]+"</td></tr>");
                }
            }
            
            function backToClasses(){
                window.location.replace("supervisor-classes.jsp");
            }
            function formTriggerSelectUser(j,i){
                document.getElementById("id_class").value = j;
                document.getElementById("id_student").value = i;
                document.getElementById('selectUser').submit();
            }
            
            //counter for exam to start
            function startTimer(startsAt,endsAt){
                $("#timer").removeAttr("hidden");
                var x = setInterval(function() {
                  var now = new Date().getTime();
                  var distanceToStart = startsAt - now;
                  var days = Math.floor(distanceToStart / (1000 * 60 * 60 * 24));
                  var hours = Math.floor((distanceToStart % (1000 * 60 * 60 * 24)) / (1000 * 60 * 60));
                  var minutes = Math.floor((distanceToStart % (1000 * 60 * 60)) / (1000 * 60));
                  var seconds = Math.floor((distanceToStart % (1000 * 60)) / 1000);
                  document.getElementById("timer").innerHTML = "Άνοιγμα Εξέτασης : " + days + "d " + hours + "h "
                  + minutes + "m " + seconds + "s ";
                  if (distanceToStart < 0) {
                    clearInterval(x);
                    endTimer(endsAt);
                  }
                }, 1000); 
            }
            //counter for exam to finish
            function endTimer(endsAt){
                var y = setInterval(function(){
                    var now = new Date().getTime();
                    var distanceToEnd = endsAt - now;
                    var days = Math.floor(distanceToEnd / (1000 * 60 * 60 * 24));
                    var hours = Math.floor((distanceToEnd % (1000 * 60 * 60 * 24)) / (1000 * 60 * 60));
                    var minutes = Math.floor((distanceToEnd % (1000 * 60 * 60)) / (1000 * 60));
                    var seconds = Math.floor((distanceToEnd % (1000 * 60)) / 1000);
                    $("#timer").html("Τέλος Εξέτασης : " + minutes + "m " + seconds + "s ");
                    if (distanceToEnd < 0) {
                        clearInterval(y);
                        document.getElementById("timer").innerHTML = "Ο χρόνος τελείωσε";
                    }
                }, 1000);
            }
        </script>
    </body>
</html>
<%}%>