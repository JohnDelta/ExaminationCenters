

<%@page contentType="text/html" pageEncoding="UTF-8"%>
<% request.setCharacterEncoding("UTF-8"); %>
<%  /*CHECKS THE USER MODE (GUEST, STUDENT, SUPERVISOR, ADMIN) TO DISPLAY THE PROPER MENU BAR*/
    String user="guest";
    String check="";
    if(session.getAttribute("id_user")!=null && session.getAttribute("name")!=null && session.getAttribute("role")!=null){
        check = session.getAttribute("role").toString();
        if(check.equals("0")){
            user="admin";
        }else if(check.equals("1")){
            user="supervisor";
        }else if(check.equals("2")){
            user="student";
        }
    }
%>