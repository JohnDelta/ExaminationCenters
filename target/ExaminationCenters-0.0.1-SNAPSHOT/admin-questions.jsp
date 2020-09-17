
<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@include file="getUserType.jsp"%>
<%@include file="mysql-connection.jsp"%>
<%
if(!user.equals("admin")){
    response.sendRedirect("index.jsp");
}else{
    String msg="";
    //if the form insert one question is submmited
    if(request.getParameter("insertQuestionsForm")!=null){
        String id_question = request.getParameter("id_question");
        String question = request.getParameter("question");
        String answer1 = request.getParameter("answer1");
        String answer2 = request.getParameter("answer2");
        String answer3 = request.getParameter("answer3");
        String answer4 = request.getParameter("answer4");
        String correct = request.getParameter("correct");
        String id_subject = request.getParameter("id_subject");
        
        //check if the id_question already exists
        boolean flag = false;
        String sql = "select count(*) from question where id_question = '"+id_question+"'";
        ResultSet rs = statement.executeQuery(sql);
        if(rs.first()){
            if(rs.getInt("count(*)")==0){
                flag = true;
            }
        }
        rs.close();
        if(flag){
            //insert the question
            sql = "insert into question(id_question,question,answer1,answer2,answer3,answer4,correct,id_subject) values"
                    + "('"+id_question+"','"+question+"','"+answer1+"','"+answer2+"',"
                    + "'"+answer3+"','"+answer4+"','"+correct+"','"+id_subject+"')";
            statement.executeUpdate(sql);
            msg = "<script>alert('Η εισαγωγή της ερώτησης ολοκληρώθηκε');</script>";
        }else{
            msg = "<script>alert('Η ερώτηση με αυτό το κωδικό υπάρχει ήδη');</script>";
        }
    }
    
    //if the form delete one question is submited
    if(request.getParameter("deleteQuestionsForm")!=null){
        String id_question = request.getParameter("id_question");
        //check if the question exists
        boolean flag = true;
        String sql = "select count(*) from question where id_question = '"+id_question+"'";
        ResultSet rs = statement.executeQuery(sql);
        if(rs.first()){
            if(rs.getInt("count(*)")==0){
                flag = false;
            }
        }
        rs.close();
        if(flag){
            //check if there are users assigned(answered) to the question
            flag = false;
            sql = "select count(*) from class_has_user where id_question = '"+id_question+"'";
            rs = statement.executeQuery(sql);
            if(rs.first()){
                if(rs.getInt("count(*)")==0){
                    flag = true;
                }
            }
            rs.close();
            if(flag){
                //delete now the class
                sql = "delete from question where id_question = '"+id_question+"'";
                statement.executeUpdate(sql);
                msg = "<script>alert('Η αφαίρεση της ερώτησης ολοκληρώθηκε');</script>";
            }else{
                msg = "<script>alert('Η ερώτηση δεν μπορεί να διαγραφεί : Υπάρχουν"
                        + " ακόμα χρήστες εγγεγραμμένοι σε αυτή');</script>";
            }
        }else{
            msg = "<script>alert('Η ερώτηση με αυτό τον κωδικό δεν υπάρχει');</script>";
        }
    }
%>
<!DOCTYPE html>
<html>
    <head>
        <script src="https://ajax.googleapis.com/ajax/libs/jquery/3.3.1/jquery.min.js"></script>
        <title>ΕΠΓ - Ερωτήσεις Μαθημάτων</title>
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
            <a href='profil.jsp'>Προφίλ</a>
            <a href='admin-users.jsp'>Χρήστες</a>
            <a href='admin-classes.jsp'>Εξεταστικά κέντρα</a>
            <a href='admin-exams.jsp'>Εξετάσεις</a>
            <a href='admin-subjects.jsp'>Μαθήματα</a>
            <a href='admin-questions.jsp' class='highlight'>Ερωτήσεις Μαθημάτων</a>
            <a href='admin-reports.jsp'>Αναφορές</a>
            <a href='logout.jsp' style='float:right;'>Αποσύνδεση</a>
        </div>
        
        <div class="context">
            <h3>Διαχείριση Εξεταστικών Κέντων</h3>
            <input type="button" id="insertQuestions" value="Εισαγωγή">
            <input type="button" id="deleteQuestions" value="Διαγραφή">
            <hr>
            <div id="questionsWindow">
                
            </div>
        </div>
        
        <div class="footer">
           Ιωάννης Δεληγιάννης | Copyright &copy | cs151102 | Δικτυακός προγραμματισμός 2017-2018 | Πανεπιστήμιο Δυτικής Αττικής
        </div>
        
        <script>
            $(document).ready(function(){
                displayInsertQuestions();
                $("#insertQuestions").click(function(){
                    displayInsertQuestions();
                });
                $("#deleteQuestions").click(function(){
                    displayDeleteQuestions();
                });
            });
            
            function displayInsertQuestions(){
                $("#insertQuestions").addClass("highlight");
                $("#deleteQuestions").removeClass("highlight");
                var window = document.getElementById("questionsWindow");
                window.innerHTML = ""+
                "<div class='format-forms'>"+
                    "<form method='post' name='formInsertQuestions' action='admin-questions.jsp' onSubmit='return formInsertQuestionsValidation()'>"+
                        "<h4>Εισαγωγή στοιχείων από φόρμα</h4>"+
                        "<p>Κωδικός</p> <input type='number' name='id_question' min='0'>"+
                        "<p>Ερώτηση</p> <textarea name='question'"+
                            "maxlength='490' rows='5' cols='70' style='resize:none;'></textarea>"+
                        "<p>Πιθανή Απάντηση 1</p> <textarea name='answer1'"+
                            "maxlength='90' rows='2' cols='70' style='resize:none;'></textarea>"+
                        "<p>Πιθανή Απάντηση 2</p> <textarea name='answer2'"+
                            "maxlength='90' rows='2' cols='70' style='resize:none;'></textarea>"+
                        "<p>Πιθανή Απάντηση 3</p> <textarea name='answer3'"+
                            "maxlength='90' rows='2' cols='70' style='resize:none;'></textarea>"+
                        "<p>Πιθανή Απάντηση 4</p> <textarea name='answer4'"+
                            "maxlength='90' rows='2' cols='70' style='resize:none;'></textarea>"+
                        "<p>Σωστή Απάντηση</p> <textarea name='correct'"+
                            "maxlength='90' rows='2' cols='70' style='resize:none;'></textarea>"+
                        "<p>Διαθέσιμο Μάθημα</p>"+
                        "<select style='margin-bottom:20px;' name='id_subject'>"+
                            <%  String sql = "select * from subject";
                                ResultSet rs = statement.executeQuery(sql);
                                while(rs.next()){
                                    out.print("\"<option value='"+rs.getString("id_subject")+"'>"
                                            + ""+rs.getString("title")+" | "+rs.getString("id_subject")+"</option>\"+");
                                }
                                rs.close(); %>
                        "</select>"+
                        "<input type='hidden' name='insertQuestionsForm' value='insertQuestionsForm'>"+
                        "<input type='submit' value='Υποβολή' style='margin-bottom:20px;display:block;'>"+
                    "</form>"+
                "</div>"+
               "<div class='format-forms' style='float:right;'>"+
                    "<h4>Εισαγωγή Στοιχείων απο αρχείο excel</h4>"+
                    "<h5>Μορφή : Κωδικός | Ερώτηση | Απ.1 | Απ.2 | Απ.3 | Απ.4 | Σωστή Απ. | Κωδικός Μαθήματος</h5>"+
                    "<h5>Η πρώτη γραμμή του αρχείου είναι για τους τίτλους και παραλείπεται</h5>"+
                   "<form method='POST' action='admin-questions-insert.jsp' onsubmit='return validateFileForm()' enctype = 'multipart/form-data'>"+
                        "<input type='file' name='file' size='50' id='file'>"+
                        "<input type='submit' name='upload' value='Ανέβασμα άρχειου'>"+
                    "</form>"+
                "</div>";
            }
            
            function displayDeleteQuestions(){
                $("#deleteQuestions").addClass("highlight");
                $("#insertQuestions").removeClass("highlight");
                var window = document.getElementById("questionsWindow");
                window.innerHTML = ""+
                "<div class='format-forms'>"+
                    "<form name='formDeleteQuestions' action='admin-questions.jsp' method='post' onsubmit='return formDeleteQuestionsValidation()'>"+
                        "<h4>Εισαγωγή στοιχείων από φόρμα</h4>"+
                        "<p>Κωδικός Μαθήματος</p> <input type='number' name='id_question' min='0'>"+
                        "<input type='hidden' name='deleteQuestionsForm' value='deleteQuestionsForm'>"+
                        "<input type='submit' value='Υποβολή' style='margin-bottom:20px;'>"+
                    "</form>"+
                "</div>"+
               "<div class='format-forms' style='float:right;'>"+
                    "<h4>Εισαγωγή Στοιχείων απο αρχείο excel</h4>"+
                    "<h5>Μορφή : Κωδικός Μαθήματος</h5>"+
                    "<h5>Η πρώτη γραμμή του αρχείου είναι για τους τίτλους και παραλείπεται</h5>"+
                   "<form method='POST' action='admin-questions-delete.jsp' onsubmit='return validateFileForm()' enctype = 'multipart/form-data'>"+
                        "<input type='file' name='file' size='50' id='file'>"+
                        "<input type='submit' name='upload' value='Ανέβασμα άρχειου'>"+
                    "</form>"+
                "</div>";
            }
            
            function validateFileForm(){
                var file = document.getElementById("file");
                if(file.value===null || file.value.length===0){
                    alert("Επιλέξτε αρχείο πρώτα");
                }
                else{
                    return true;
                }
                return false;
            }
            
            function formInsertQuestionsValidation(){
                var regex = /[^a-zA-Z0-9α-ωΑ-Ωάέίόήώύ+,.?; ]+/;
                var regex_q = /[^a-zA-Z0-9α-ωΑ-Ωάέίόήώύ+,.?; ]+/;
                var id_question = document.forms['formInsertQuestions']['id_question'].value;
                var answer1 = document.forms['formInsertQuestions']['answer1'].value;
                var answer2 = document.forms['formInsertQuestions']['answer2'].value;
                var answer3 = document.forms['formInsertQuestions']['answer3'].value;
                var answer4 = document.forms['formInsertQuestions']['answer4'].value;
                var correct = document.forms['formInsertQuestions']['correct'].value;
                var question = document.forms['formInsertQuestions']['question'].value;
                
                if(id_question==="" || answer1==="" || answer2==="" || answer3===""
                         || answer4==="" || correct==="" || question===""){
                    alert("Πρέπει να συμπληρώσετε όλα τα πεδία");
                    return false;
                }
                if(regex.test(answer1) || regex.test(answer2) || regex.test(answer3) || !/[0-9]{1,10}/.test(id_question)
                         || regex.test(answer4) || regex.test(correct) || regex_q.test(question)){
                    alert("Τα πεδία δεν μπορούν να περιέχουν σύμβολα εκτός ,.?; Η ερώτηση μέχρι 500 χαρακτήες, οι απαντήσεις μέχρι 100");
                    return false;
                }
                return true;
            }
            
            function formDeleteQuestionsValidation(){
                var id_question = document.forms['formDeleteQuestions']['id_question'].value;
                if(id_question===""){
                    alert("Πρέπει να συμπληρώσετε όλα τα πεδία");
                    return false;
                }
                if(!/[0-9]{1,10}/.test(id_question)){
                    alert("Πρέπει να είναι μέχρι 10 ψηφία");
                    return false;
                }
                return true;
            }
        </script>
    </body>
</html>
<%}%>