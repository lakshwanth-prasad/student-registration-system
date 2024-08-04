<%@ page import="java.sql.*, oracle.jdbc.*" %>
<%@ page import="oracle.jdbc.pool.OracleDataSource, oracle.jdbc.OracleTypes" %>
<!DOCTYPE html>
<html>
<head>
    <title>Display Course Prerequisites</title>
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
            flex-direction: column;
        }
        .container {
            background-color: #fff;
            padding: 20px;
            border-radius: 8px;
            box-shadow: 0 0 10px rgba(0, 0, 0, 0.1);
            text-align: center;
            width: 50%;
            margin-top: 20px;
        }
        label, input[type="text"], select, input[type="submit"], .back-button {
            width: 100%;
            padding: 10px;
            margin-bottom: 20px;
            border-radius: 4px;
            border: 1px solid #ccc;
            box-sizing: border-box;
        }
        input[type="submit"], .back-button {
            background-color: #4CAF50;
            color: white;
            border: none;
            border-radius: 4px;
            cursor: pointer;
            transition: background-color 0.3s;
            margin-top: 10px;
        }
        input[type="submit"]:hover, .back-button:hover {
            background-color: #45a049;
        }
        table {
            border-collapse: collapse;
            width: 100%;
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
        <h1>Course Prerequisites</h1>
        <form method="post">
            <label for="deptCode">Department Code:</label>
            <input type="text" name="deptCode" id="deptCode" required>
            <label for="courseNumber">Course Number:</label>
            <input type="text" name="courseNumber" id="courseNumber" required>
            <input type="submit" value="Show Prerequisites">
            <button type="button" class="back-button" onclick="window.location.href='dashboard.jsp';">Back to Dashboard</button>
        </form>
        <% 
        if ("POST".equalsIgnoreCase(request.getMethod())) {
            String deptCode = request.getParameter("deptCode");
            String courseNumber = request.getParameter("courseNumber");

            // Fetch database credentials from context parameters
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

                cstmt = conn.prepareCall("{call STUREG.SHOW_PREREQ(?, ?, ?)}");
                cstmt.setString(1, deptCode);
                cstmt.setString(2, courseNumber);
                cstmt.registerOutParameter(3, OracleTypes.CURSOR);
                cstmt.execute();
                rs = (ResultSet) cstmt.getObject(3);

                if (rs != null) {
                    out.println("<div class='container'><table>");
                    out.println("<tr><th>Prerequisite Courses</th></tr>");
                    while (rs.next()) {
                        out.println("<tr><td>" + rs.getString("courses") + "</td></tr>");
                    }
                    out.println("</table></div>");
                } else {
                    out.println("<div class='container'><p>No prerequisites found or invalid course details.</p></div>");
                }
            } catch (SQLException e) {
                out.println("<div class='container'><p>Error: " + e.getMessage() + "</p></div>");
            } finally {
                if (rs != null) try { rs.close(); } catch (SQLException e) {}
                if (cstmt != null) try { cstmt.close(); } catch (SQLException e) {}
                if (conn != null) try { conn.close(); } catch (SQLException e) {}
            }
        }
        %>
    </div>
</body>
</html>
