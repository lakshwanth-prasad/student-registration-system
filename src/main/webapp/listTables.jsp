<%@ page import="java.sql.*, oracle.jdbc.*" %>
<%@ page import="oracle.jdbc.pool.OracleDataSource, oracle.jdbc.OracleTypes" %>
<!DOCTYPE html>
<html>
<head>
    <title>Display Table Data</title>
    <style>
        body {
            font-family: Arial, sans-serif;
            background-color: #f4f4f4;
            margin: 0;
            padding: 20px;
            display: flex;
            justify-content: center;
            align-items: center;
            height: 100vh;
            flex-direction: column;
        }
        .container {
            background-color: #fff;
            padding: 10px;
            border-radius: 8px;
            box-shadow: 0 0 10px rgba(0, 0, 0, 0.1);
            width: 100%;
            margin-bottom: 20px;
        }
        form, .results {
            text-align: center;
            margin-top: 20px;
        }
        label, select, input[type="submit"] {
            margin-bottom: 10px;
        }
        select, input[type="submit"] {
            width: 100%;
            padding: 8px;
            border-radius: 4px;
            border: 1px solid #ccc;
        }
        input[type="submit"], .back-button {
            background-color: #4CAF50;
            color: white;
            padding: 10px 20px;
            border: none;
            border-radius: 4px;
            cursor: pointer;
            transition: background-color 0.3s;
        }
        input[type="submit"]:hover, .back-button:hover {
            background-color: #45a049;
        }
        
        table {
            width: 100%;
            border-collapse: collapse;
            margin-top: 20px;
        }
        th, td {
            border: 1px solid #ddd;
            padding: 8px;
            text-align: left;
        }
        th {
            background-color: #f2f2f2;
        }
    </style>
</head>
<body>
    <div class="container">
        <h1>Display Table Data</h1>
        <form method="post">
            <label for="tableName">Choose a table:</label>
            <select name="tableName" id="tableName">
                <option value="STUDENTS">Students</option>
                <option value="COURSES">Courses</option>
                <option value="COURSE_CREDIT">Course Credit</option>
                <option value="CLASSES">Classes</option>
                <option value="G_ENROLLMENTS">Graduate Enrollments</option>
                <option value="SCORE_GRADE">Score Grades</option>
                <option value="PREREQUISITES">Prerequisites</option>
                <option value="LOGS">Logs</option>
            </select>
            <input type="submit" value="Display Content">
            <button type="button" class="back-button" onclick="window.location.href='dashboard.jsp';">Back to Dashboard</button>
        </form>
       
    </div>
    <div class="container results">
        <%
        if ("POST".equalsIgnoreCase(request.getMethod())) {
            String tableName = request.getParameter("tableName");
            String user = application.getInitParameter("dbUser");
            String password = application.getInitParameter("dbPassword");
            String url = application.getInitParameter("dbURL");
            
            OracleDataSource ds = null;
            Connection conn = null;
            CallableStatement cstmt = null;
            ResultSet rs = null;
            try {
                ds = new OracleDataSource();
                ds.setURL(url);
                conn = ds.getConnection(user, password);

                cstmt = conn.prepareCall("{call STUREG.VIEW_TABLES(?, ?)}");
                cstmt.setString(1, tableName);
                cstmt.registerOutParameter(2, OracleTypes.CURSOR);
                cstmt.execute();
                rs = (ResultSet) cstmt.getObject(2);

                ResultSetMetaData rsmd = rs.getMetaData();
                int columnCount = rsmd.getColumnCount();
                out.println("<table><tr>");
                for (int i = 1; i <= columnCount; i++) {
                    out.println("<th>" + rsmd.getColumnLabel(i) + "</th>");
                }
                out.println("</tr>");
                while (rs.next()) {
                    out.println("<tr>");
                    for (int i = 1; i <= columnCount; i++) {
                        out.println("<td>" + rs.getString(i) + "</td>");
                    }
                    out.println("</tr>");
                }
                out.println("</table>");
            } catch (Exception e) {
                out.println("Error: " + e.getMessage());
                e.printStackTrace();
            } finally {
                if (rs != null) rs.close();
                if (cstmt != null) cstmt.close();
                if (conn != null) conn.close();
            }
        }
        %>
    </div>
</body>
</html>
