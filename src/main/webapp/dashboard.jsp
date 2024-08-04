<%@ page import="java.sql.*, oracle.jdbc.*" %>
<%@ page import="java.math.*, java.io.*, oracle.jdbc.pool.OracleDataSource" %>
<!DOCTYPE html>
<html>
<head>
    <title>Dashboard</title>
    <style>
    body {
        font-family: Arial, sans-serif;
        background-color: #f4f4f4;
        margin: 0;
        padding: 0;
        display: flex;
        justify-content: center;
        align-items: center;
        height: 100vh;
    }
    .container {
        background-color: #fff;
        padding: 20px;
        border-radius: 8px;
        box-shadow: 0 0 10px rgba(0, 0, 0, 0.1);
        text-align: center;
        width: 350px;
        position: absolute;
        top: 50%;
        left: 50%;
        transform: translate(-50%, -50%);
    }
    input[type="submit"], a {
        background-color: #4CAF50;
        color: white;
        padding: 10px 20px;
        border: none;
        border-radius: 4px;
        cursor: pointer;
        transition: background-color 0.3s;
        text-decoration: none;
        display: block;
        width: 100%;
        text-align: center;
        margin-bottom: 10px;
        box-sizing: border-box;
    }
    input[type="submit"]:hover, a:hover {
        background-color: #45a049;
    }
</style>
</head>
<body>
<%
    // Fetch database credentials from context parameters
    String user = application.getInitParameter("dbUser");
    String password = application.getInitParameter("dbPassword");
    String url = application.getInitParameter("dbURL");

    OracleDataSource ds = new oracle.jdbc.pool.OracleDataSource();
    ds.setURL(url);
    Connection connection = ds.getConnection(user, password);
%>
<div class="container">
    <h1>Dashboard</h1>
    <h2>Procedures</h2>
    <a href="listTables.jsp">List Tuples</a>
    <a href="showStudents.jsp">Show Students for the Class</a>
    <a href="showPrerequisites.jsp">Show Prerequisites</a>
    <a href="addStudent.jsp">Enroll Graduate Student</a>
    <a href="dropGrad.jsp">Drop Graduate Student From Class</a>
    <a href="deleteStudent.jsp">Delete Student</a>
    <a href="deleteClass.jsp">Delete Class</a>
    <a href="deleteCourse.jsp">Delete Course</a>
    <a href="checkLogs.jsp">Check Logs</a>
</div>
<%
    connection.close();
%>
</body>
</html>
