<%@ page import="java.sql.*, oracle.jdbc.*" %>
<%@ page import="oracle.jdbc.pool.OracleDataSource, oracle.jdbc.OracleTypes" %>
<!DOCTYPE html>
<html>
<head>
    <title>Display Class Details</title>
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
        <form method="post">
            <h1>Class Details</h1>
            <label for="classId">Enter Class ID:</label>
            <input type="text" name="classId" id="classId" required>
            <input type="submit" value="Show Class Details">
            <button type="button" class="back-button" onclick="window.location.href='dashboard.jsp';">Back to Dashboard</button>
        </form>
    </div>

    <% if ("POST".equalsIgnoreCase(request.getMethod())) {
        String classId = request.getParameter("classId");

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

            cstmt = conn.prepareCall("{call STUREG.SHOW_CLASS_STUDENTS(?, ?)}");
            cstmt.setString(1, classId);
            cstmt.registerOutParameter(2, OracleTypes.CURSOR);
            cstmt.execute();
            rs = (ResultSet) cstmt.getObject(2);

            if (rs != null) {
                out.println("<div class='container'><table>");
                out.println("<tr><th>B#</th><th>First Name</th><th>Last Name</th></tr>");
                while (rs.next()) {
                    out.println("<tr><td>" + rs.getString("B#") + "</td>");
                    out.println("<td>" + rs.getString("first_name") + "</td>");
                    out.println("<td>" + rs.getString("last_name") + "</td></tr>");
                }
                out.println("</table></div>");
            } else {
                out.println("<div class='container'><p>The classid is invalid.</p></div>");
            }
        } catch (SQLException e) {
            out.println("<div class='container'><p>Error: " + e.getMessage() + "</p></div>");
        } finally {
            if (rs != null) try { rs.close(); } catch (SQLException e) {}
            if (cstmt != null) try { cstmt.close(); } catch (SQLException e) {}
            if (conn != null) try { conn.close(); } catch (SQLException e) {}
        }
    } %>
</body>
</html>
