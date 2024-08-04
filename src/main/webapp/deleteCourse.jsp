<%@ page import="java.sql.*, oracle.jdbc.pool.OracleDataSource" %>
<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="UTF-8">
<title>Delete Course</title>
<style>
    body {
        font-family: Arial, sans-serif;
        background-color: #f4f4f4;
        padding: 20px;
        display: flex;
        justify-content: center;
        align-items: center;
        height: 100vh;
    }
    form {
        background-color: #fff;
        padding: 20px;
        border-radius: 8px;
        box-shadow: 0 0 10px rgba(0, 0, 0, 0.1);
        text-align: center;
        width: 300px;
    }
    input, button {
        width: 100%;
        padding: 10px;
        margin-top: 10px;
        border-radius: 4px;
    }
    button {
        background-color: #4CAF50;
        color: white;
        border: none;
        cursor: pointer;
    }
    button:hover {
        background-color: #45a049;
    }
</style>
</head>
<body>
<form action="" method="post">
    <h2>Delete Course</h2>
    Department Code: <input type="text" name="deptCode" required><br>
    Course #: <input type="text" name="courseNum" required><br>
    <button type="submit">Delete Course</button>
</form>

<%
if ("POST".equalsIgnoreCase(request.getMethod())) {
    String deptCode = request.getParameter("deptCode");
    String courseNum = request.getParameter("courseNum");

    try {
        String user = application.getInitParameter("dbUser");
        String password = application.getInitParameter("dbPassword");
        String url = application.getInitParameter("dbURL");

        OracleDataSource ds = new OracleDataSource();
        ds.setURL(url);
        Connection conn = ds.getConnection(user, password);

        PreparedStatement pstmt = conn.prepareStatement("DELETE FROM courses WHERE dept_code = ? AND course# = ?");
        pstmt.setString(1, deptCode);
        pstmt.setString(2, courseNum);
        int rows = pstmt.executeUpdate();
        
        if (rows > 0) {
            out.println("<p>Course deleted successfully.</p>");
        } else {
            out.println("<p>No course found with the specified details.</p>");
        }
        conn.close();
    } catch (Exception e) {
        out.println("<p>Error: " + e.getMessage() + "</p>");
    }
}
%>
</body>
</html>
