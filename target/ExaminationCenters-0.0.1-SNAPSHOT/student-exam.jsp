
<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@include file="getUserType.jsp"%>
<%
if(request.getParameter("id_class")==null || request.getParameter("name")==null
                    || request.getParameter("title")==null || request.getParameter("date")==null
                    || request.getParameter("open")==null || !user.equals("student")){
    response.sendRedirect("student-exams.jsp");
}else{
%>
<%@include file="mysql-connection.jsp"%>
<!DOCTYPE html>
<html>
    <head>
        <script src="https://ajax.googleapis.com/ajax/libs/jquery/3.3.1/jquery.min.js"></script>
        <title>ΕΠΓ - Εξέταση</title>
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
            <%
                //SHOW BASIC INFO OF CLASS AND EXAM
                String id_user = session.getAttribute("id_user").toString();
                String name = request.getParameter("name").toString();
                String title = request.getParameter("title").toString();
                String date = request.getParameter("date").toString();
                String open = request.getParameter("open").toString();
                String id_class = request.getParameter("id_class").toString();
                String examState=null;
                String userState=null;
                //GET THE STATE OF THE EXAM
                if(open.equals("0")) examState="Απενεργοποιημένη";
                else if(open.equals("1")) examState="Ενεργοποιημένη";
                else if(open.equals("2")) examState="Ολοκληρωμένη";
            %>
            <h3>Εξετάσεις / Εξέταση 
            <font style="float:right">Κατάσταση Εξέτασης: <%=examState%></font>
            <BR>Μάθημα: <%=title%> | Τάξη: <%=name%> | Έναρξη: <%=date%>
            <font style='float:right' id="timer" hidden></font></h3>
            <input type="button" value="Επιστροφή" onclick="back()" style="float:right;">
            <hr>
            <div id="window">
            </div>
    
        </div>
        <div class="footer">
           Ιωάννης Δεληγιάννης | Copyright &copy | cs151102 | Δικτυακός προγραμματισμός 2017-2018 | Πανεπιστήμιο Δυτικής Αττικής
        </div>
        
       <script>
            var x=0;
            startExam(x);
            /*
             * call the rest wb to get the student's quetions
             *  - the ws will return initial if the exam has not start yet
             *  - will return no-result if the student did not participate to the exam
             *  - will return the questions if the exam is start and hes not answered them
             *  - will return the results if he has participated, answered them all or the time is over
            */
            function startExam(){
                $(document).ready(function(){
                    $.ajax({
                    type:"GET",
                    url:"/WebApplication/webresources/student-exam/exam/<%=id_user%>/<%=id_class%>",
                    success: function(data){
                        //setup the countdown. 5 minutes from the start date
                        var startDate = new Date("<%=date%>").getTime();
                        var endDate = new Date(startDate+5*60000).getTime();
                        //start the counter
                        startTimer(startDate,endDate);
                        //take ws response and display the proper objects
                        if(data==="initial"){
                            $("#window").html("<p>Η εξέταση δεν έχει ανοίξει ακόμα από τον υπεύθυνο της τάξης</p>");
                        }else if(data[0]["type"]==="question"){
                            for(var i=0;i<data.length;i++){
                                if(data[i]===null) data[i]=0;
                            }
                            displayExam();

                            /*print the first question*/
                            $("#qst").html(data[x]["qst"]);
                            $("#ans1").html(data[x]["ans1"]);
                            $("#ans2").html(data[x]["ans2"]);
                            $("#ans3").html(data[x]["ans3"]);
                            $("#ans4").html(data[x]["ans4"]);

                            /*move to the next question*/
                            $("#next").click(function(){
                                displayNextQuestion(data);
                            });

                            /*take the selected answer, send it with put, remove the question, and move to next question*/
                            $("#submit").click(function(){
                                if(confirm("Επιβαβαίωση απάντησης : ")){
                                    if(!$.isEmptyObject($("#answers").val())){
                                        var dataObject = {
                                            'id_user':<%=id_user%>,
                                            'id_class':<%=id_class%>,
                                            'id_question':data[x]["id_question"],
                                            'answer':$("#answers").val(),
                                            'date':getCurrectTime()
                                        };
                                        $.ajax({
                                            type:'PUT',
                                            url:'/WebApplication/webresources/student-exam/exam/<%=id_user%>/<%=id_class%>',
                                            headers: { 
                                                'Accept': 'application/json',
                                                'Content-Type': 'application/json' 
                                            },
                                            data:JSON.stringify(dataObject),
                                            success:function(nothing){
                                                console.log('success sending the answer');
                                                data[x]=0;
                                                displayNextQuestion(data);
                                            }
                                        });
                                    }
                                    else{
                                        window.alert("First, you must select an answer!");
                                    }
                                }
                                
                            });
                        }else if(data[0]["type"]==="result"){
                            displayResult(data);
                            
                        }else if(data==="no-result"){
                            $("#window").html("<p>Δεν συμμετείχατε στην εξέταση. Έχετε μηδενικό βαθμό</p>");
                        }
                    }
                    });
                }); 
            }
            
            /*checks if there are any questions unanswered | if there is only one disables next button*/
            function checkQuestions(data){
                var t=0;
                for(var i=0;i<data.length;i++){
                    if(data[i]!==0){
                        t++;
                    }
                }
                if(t===0){
                    return false;
                }
                else if(t===1){
                    document.getElementById("next").disabled=true;
                }
                return true;
            }

            /*displays the next question if exists else hides questions*/
            function displayNextQuestion(data){
                if(checkQuestions(data)){
                    this.x++;
                    if(this.x===data.length)this.x=0;
                    while(data[this.x]===0){
                        this.x++;
                        if(this.x===data.length)this.x=0;
                    }
                    $(document).ready(function(){
                        $("#info").html("Ερώτηση "+(x+1));
                        $("#qst").fadeOut(200,function(){
                            $("#qst").html(data[x]["qst"]);
                        });
                        $("#ans1").fadeOut(200,function(){
                            $("#ans1").html(data[x]["ans1"]);
                        });
                        $("#ans2").fadeOut(200,function(){
                            $("#ans2").html(data[x]["ans2"]);
                        });
                        $("#ans3").fadeOut(200,function(){
                            $("#ans3").html(data[x]["ans3"]);
                        });
                        $("#ans4").fadeOut(200,function(){
                            $("#ans4").html(data[x]["ans4"]);
                        });
                        $("#qst").fadeIn(600);
                        $("#ans1").fadeIn(600);
                        $("#ans2").fadeIn(600);
                        $("#ans3").fadeIn(600);
                        $("#ans4").fadeIn(600);
                    });
                }
                else{
                    endQuestions();
                }
            }
        </script>
                    
        <script>
            function endQuestions(){
                $(document).ready(function(){
                    $("#qst").fadeOut(600,function(){
                    $("#qst").remove();
                    });
                    $("#info2").fadeOut(600,function(){
                        $("#info2").remove();
                    });
                    $("#answers").fadeOut(600,function(){
                        $("#answers").remove();
                    });
                    $("#submit").fadeOut(600,function(){
                        $("#submit").remove();
                    });
                    $("#next").fadeOut(600,function(){
                        $("#next").remove();
                    });
                    $("#info").fadeOut(600,function(){
                        $("#info").remove();
                    });
                    startExam();
                }); 
            }
        </script>
        
        <script>
            //get the currect time to send with the student answer to questions
            function getCurrectTime(){
                time = new Date();
                return time.getFullYear()+"/"+(time.getMonth()+1)+"/"+time.getDate()+
                        " "+time.getHours()+":"+time.getMinutes()+":"+time.getSeconds();
            }
        </script>
        
        <script>
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
            
            function back(){
                window.location.replace("http://localhost:8080/WebApplication/student-exams.jsp");
            }
            
            function displayExam(){
                
                document.getElementById("window").innerHTML="<div class='exam'>"+
                    "<h4 id='info'>Ερώτηση "+(x+1)+"</h4>"+
                    "<p id='qst'></p>"+
                    "<h4 id='info2'>Απάντηση (επέλεξε μια από τις παρακάτω)</h4>"+
                    "<select size='4' id='answers'>"+
                        "<option id='ans1'></option>"+
                        "<option id='ans2'></option>"+
                        "<option id='ans3'></option>"+
                        "<option id='ans4'></option>"+
                    "</select>"+
                    "<input id='submit' type='button' name='submit' value='Υποβολή απάντησης'>"+
                    "<input id='next'  type='button' name='next' value='Παράληψη ερώτησης'>"+
                    "</div>";
            }
            
            function displayResult(data){

                //take the results in data and print them
                document.getElementById("window").innerHTML="<div class='exam_result'>"+
                    "<h4 id='info'>Αποτελέσματα Εξέτασης</h4>"+
                    "<table>"+
                        "<tr class='table-first'>"+
                            "<td>Ερώτηση</td>"+
                            "<td>Απάντηση Χρήστη</td>"+
                            "<td>Ημερομηνία Απάντησης</td>"+
                            "<td>Ορθότητα Απάντησης</td>"+
                        "</tr>"+
                    "</table>"+
                    "<table class='active-table-result' id='table'>";
                var mode;
                for(var i=0;i<data.length;i++){
                    if(i%2===0) mode="table-odd";
                    else mode="table-even";
                    
                    var table = document.getElementById("table");
                    var row = document.createElement("TR");
                    row.className = mode;
                    var column1 = document.createElement("TD");
                    var column2 = document.createElement("TD");
                    var column3 = document.createElement("TD");
                    var column4 = document.createElement("TD");
                    column1.innerHTML = data[i]["qst"];
                    column2.innerHTML = data[i]["ans"];
                    column3.innerHTML = data[i]["date"];
                    column4.innerHTML = data[i]["correct"];
                    row.appendChild(column1);
                    row.appendChild(column2);
                    row.appendChild(column3);
                    row.appendChild(column4);
                    table.appendChild(row);
                }
                $("#window").append("</table></div>");

            }
        </script>
    </body>
</html>
<%}%>