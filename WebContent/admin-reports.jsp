
<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@include file="getUserType.jsp"%>
<%
if(!user.equals("admin")){
    response.sendRedirect("index.jsp");
}else{%>
<!DOCTYPE html>
<html>
    <head>
        <script src="https://ajax.googleapis.com/ajax/libs/jquery/3.3.1/jquery.min.js"></script>
        <title>ΕΠΓ - Αναφορές</title>
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
            <a href='admin-users.jsp'>Χρήστες</a>
            <a href='admin-classes.jsp'>Εξεταστικά κέντρα</a>
            <a href='admin-exams.jsp'>Εξετάσεις</a>
            <a href='admin-subjects.jsp'>Μαθήματα</a>
            <a href='admin-questions.jsp'>Ερωτήσεις Μαθημάτων</a>
            <a href='admin-reports.jsp' class='highlight'>Αναφορές</a>
            <a href='logout.jsp' style='float:right;'>Αποσύνδεση</a>
        </div>
        
        <div class="context">
            <div class="report-options">
                <input id="studentsReport" type="button" value="Εξεταζόμενοι">
                <input id="classesReport" type="button" value="Εξεταστικά κέντρα">
                <input id="examsReport" type="button" value="Εξετάσεις">
                <hr>
                <h4 id="title"></h4>
            </div>
            
            <form method="get" action="AdminReportDownload">
                <input id="downloadType" type="hidden" name="downloadType" value="">
                <input id="download-admin" name="downloadReport" type="submit" value="" style="float:right;">
            </form>
            
            <table id="tableReport">
                <tr id="titlesReport" class="table-first">
                </tr>
            </table>

        </div>
        
        <div class="footer">
           Ιωάννης Δεληγιάννης | Copyright &copy | cs151102 | Δικτυακός προγραμματισμός 2017-2018 | Πανεπιστήμιο Δυτικής Αττικής
        </div>
        
        <script>
            $(document).ready(function(){
                displayStudentsReport();
                $("#examsReport").click(function(){
                    displayExamsReport();
                });
                $("#studentsReport").click(function(){
                    displayStudentsReport();
                });
                $("#classesReport").click(function(){
                    displayClassesReport();
                });
                
                function displayExamsReport(){
                    $("#tableReport").fadeToggle(200,function(){
                        $("#titlesReport").html("");
                        $(".table-even").html("");
                        $(".table-odd").html("");
                        $("#downloadType").val("exam");
                        $("#title").html("Αποτελέσματα Εξεταζόμενων ανά Εξέταση");
                        $("#examsReport").addClass("highlight");
                        $("#classesReport").removeClass("highlight");
                        $("#studentsReport").removeClass("highlight");
                        $.ajax({
                            type:'GET',
                            url:'/WebApplication/webresources/admin-reports/examsReport',
                            success:function(studentData){
                                    if(studentData.length>0){
                                        $("#titlesReport").append(
                                        "<td>Κωδικός Εξέτασης</td>"+
                                        "<td>Λογαριασμός</td>"+
                                        "<td>Όνομα</td>"+
                                        "<td>Επίθετο</td>"+
                                        "<td>Κωδ.Κέντρου</td>"+
                                        "<td>Βαθμός</td>");
                                    var mode="";
                                    for(var i=0;i<studentData.length;i++){
                                        if(i%2===0) mode="table-odd";
                                        else mode="table-even";
                                        $("#tableReport").append("<tr class="+mode+">"+
                                            "<td style='background-color:#aec7ef;'>"+studentData[i]["id_exam"]+"</td>"+
                                            "<td>"+studentData[i]["username"]+"</td>"+
                                            "<td>"+studentData[i]["name"]+"</td>"+
                                            "<td>"+studentData[i]["lastname"]+"</td>"+
                                            "<td>"+studentData[i]["id_class"]+"</td>"+
                                            "<td>"+studentData[i]["score"]+"</td>"+
                                            "</tr>");
                                    }
                                }else{
                                 //den yparxoyn dedomena
                                    $("#title").html("Δεν Υπάρχουν Αποτελέσματα Εξεταζόμενων ανά Εξέταση");
                                }
                            }
                        });
                    });
                    $("#tableReport").fadeToggle(400);
                }
                
                function displayStudentsReport(){
                    $("#tableReport").fadeToggle(200,function(){
                        $("#titlesReport").html("");
                        $(".table-even").html("");
                        $(".table-odd").html("");
                        $("#downloadType").val("student");
                        $("#title").html("Αποτελέσματα Εξεταζόμενων ανά Κωδικό Εξέτασης τους");
                        $("#studentsReport").addClass("highlight");
                        $("#classesReport").removeClass("highlight");
                        $("#examsReport").removeClass("highlight");
                        $.ajax({
                            type:'GET',
                            url:'/WebApplication/webresources/admin-reports/studentsReport',
                            success:function(studentData){
                                    if(studentData.length>0){
                                        $("#titlesReport").append(
                                        "<td>Κωδ.Εξέτασης<BR>Μαθητή</td>"+
                                        "<td>Λογαριασμός</td>"+
                                        "<td>Όνομα</td>"+
                                        "<td>Επίθετο</td>"+
                                        "<td>Κωδ.Κέντρου</td>"+
                                        "<td>Κωδ.Εξέτασης</td>"+
                                        "<td>Βαθμός</td>");
                                    var mode="";
                                    for(var i=0;i<studentData.length;i++){
                                        if(i%2===0) mode="table-odd";
                                        else mode="table-even";
                                        $("#tableReport").append("<tr class="+mode+">"+
                                            "<td style='background-color:#aec7ef;'>"+studentData[i]["id_class_has_user"]+"</td>"+
                                            "<td>"+studentData[i]["username"]+"</td>"+
                                            "<td>"+studentData[i]["name"]+"</td>"+
                                            "<td>"+studentData[i]["lastname"]+"</td>"+
                                            "<td>"+studentData[i]["id_class"]+"</td>"+
                                            "<td>"+studentData[i]["id_exam"]+"</td>"+
                                            "<td>"+studentData[i]["score"]+"</td>"+
                                            "</tr>");
                                    }
                                }else{
                                 //den yparxoyn dedomena
                                    $("#title").html("Δεν Υπάρχουν Αποτελέσματα Εξεταζόμενων ανά κωδικός Εξέτασης τους");
                                }
                            }
                        });
                    });
                    $("#tableReport").fadeToggle(400);
                }
                
                function displayClassesReport(){
                    $("#tableReport").fadeToggle(200,function(){
                        $("#titlesReport").html("");
                        $(".table-even").html("");
                        $(".table-odd").html("");
                        $("#downloadType").val("class");
                        $("#title").html("Αποτελέσματα Εξεταζόμενων ανά Κωδικό Εξεταστικού Κέντρου");
                        $("#classesReport").addClass("highlight");
                        $("#studentsReport").removeClass("highlight");
                        $("#examsReport").removeClass("highlight");
                        $.ajax({
                            type:'GET',
                            url:'/WebApplication/webresources/admin-reports/classesReport',
                            success:function(studentData){
                                    if(studentData.length>0){
                                        $("#titlesReport").append(
                                        "<td>Κωδ.Κέντρου</td>"+
                                        "<td>Λογαριασμός</td>"+
                                        "<td>Όνομα</td>"+
                                        "<td>Επίθετο</td>"+
                                        "<td>Κωδ.Εξέτασης</td>"+
                                        "<td>Βαθμός</td>");
                                    var mode="";
                                    for(var i=0;i<studentData.length;i++){
                                        if(i%2===0) mode="table-odd";
                                        else mode="table-even";
                                        $("#tableReport").append("<tr class="+mode+">"+
                                            "<td style='background-color:#aec7ef;'>"+studentData[i]["id_class"]+"</td>"+
                                            "<td>"+studentData[i]["username"]+"</td>"+
                                            "<td>"+studentData[i]["name"]+"</td>"+
                                            "<td>"+studentData[i]["lastname"]+"</td>"+
                                            "<td>"+studentData[i]["id_exam"]+"</td>"+
                                            "<td>"+studentData[i]["score"]+"</td>"+
                                            "</tr>");
                                    }
                                }else{
                                 //den yparxoyn dedomena
                                    $("#title").html("Δεν Υπάρχουν Αποτελέσματα Εξεταζόμενων ανά Κωδικό Εξεταστικού Κέντρου");
                                }
                            }
                        });
                    });
                    $("#tableReport").fadeToggle(400);
                }
            });
        </script>
    </body>
</html>
<%}%>