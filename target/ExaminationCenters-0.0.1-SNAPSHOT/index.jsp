
<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@include file="getUserType.jsp"%>

<!DOCTYPE html>
<html>
    <head>
        <title>ΕΠΓ - Αρχική</title>
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
            <a href="index.jsp" class="highlight">Αρχική</a>
            <% 
                if(user.equals("guest")){ 
                    out.print("<a href='login.jsp'>Είσοδος</a>");
                }else{
                    out.print("<a href='profil.jsp'>Προφίλ</a>");
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
        
        <div class="container">
            <div class="container-main">
                <h2>Καλώς Ορίσατε στα Κέντρα Εξέτασης Πιστοποίησης Γνώσεων</h2>
                <p style="text-align:center;">Εδώ μπορείτε να αξιολογήσετε τις γνώσεις σας μέσα από μια μεγάλη ποικιλία πολλαπλών ερωτήσεων για κάθε μάθημα της επιλογής σας.</p>
            </div>

            <div class="container-menu">
                <div class="container-menu-block">
                    <h3>Εξεταστείτε Ηλεκτρονικά</h3>
                    <p>Μπορείτε να βλέπετε τις διαθέσιμες εξετάσεις στις οποίες είστε εγγεγραμένοι, 
                        Μόλις κάποια εξέταση ξεκινήσει θα υπάρξει ένδειξη στον πίνακα εξετάσεων. 
                        Μόλις μπείτε στην εξέταση μπορείτε να δείτε τις ερωτήσεις σας και τον χρόνο έναρξης της εξέτασης. 
                        Μόλις ξεκινήσει ο χρόνος μπορείτε να απαντήσετε. 
                        Στο τέλος τον ερωτήσεων θα μπορείτε αυτόματα να δείτε τα αποτελέσματα σας.</p> 
                </div>

                <div class="container-menu-block" style="float:right;">
                    <h3>Αφήστε τα υπόλοιπα σε εμάς</h3>
                    <p>Μόλις λάβουμε τα στοιχεία σας, ο διαχειριστής του συστήματος θα δημιουργήσει τον λογαριασμό σας.
                        Στην συνέχεια οι υπεύθυνοι εξετστικών κέντρων θα σας τοποθετήσουν στις εξετάσεις τις επιλογής σας,
                        και θα ανοίξουν την εξέταση σας στην ώρα έναρξης.</p> 
                </div>
            </div>    
        </div>
            
        <div class="footer">
           Ιωάννης Δεληγιάννης | Copyright &copy | cs151102 | Δικτυακός προγραμματισμός 2017-2018 | Πανεπιστήμιο Δυτικής Αττικής
        </div>
    </body>
</html>

