
<% request.setCharacterEncoding("UTF-8"); %>
<%@page import="java.sql.*" %>
<%@page import="java.util.*"%>
<%@page contentType="text/html" pageEncoding="UTF-8"%>

<%
	class Database {
		private String hostName = "localhost";
		private String databaseName = "examination_centers";
		private String username = "pma";
		private String password = "026849";
		
		private Connection connection = null;
		
		public Connection getConnection() {
			
			try {
				Class.forName("com.mysql.cj.jdbc.Driver").newInstance();
				connection = DriverManager
	                    .getConnection("jdbc:mysql://"+hostName+"/"+databaseName+""
	                    		+ "?user="+username
	                    		+ "&password="+password
	                    		+ "&useUnicode=true"
	                    		+ "&characterEncoding=UTF8"
	                    		+ "&sessionVariables=default_storage_engine=InnoDB"
	                    		+ "&serverTimezone=UTC");
				
			} catch(Exception e) {
				System.out.println("Error in Database.java | Exception message: " + e.getMessage());
			}
			
			return connection;
		}
	}

    Connection connection = new Database().getConnection();
    // Create object to execute statements
    Statement statement = connection.createStatement();
    
%>