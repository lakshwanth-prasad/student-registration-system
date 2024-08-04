<%@ page import="java.sql.*, oracle.jdbc.*" %>
<%@ page import="oracle.jdbc.pool.OracleDataSource, oracle.jdbc.OracleTypes" %>
<!DOCTYPE html>
<html>
<head>
    <title>View Logs</title>
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
            width: 70%;
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
        <h1>View Logs</h1>
        <form method="post">
            <input type="submit" value="Display Logs">
            <button type="button" class="back-button" onclick="window.location.href='dashboard.jsp';">Back to Dashboard</button>
        </form>
        <% 
        if ("POST".equalsIgnoreCase(request.getMethod())) {
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

                cstmt = conn.prepareCall("{call STUREG.VIEW_TABLES('LOGS', ?)}");
                cstmt.registerOutParameter(1, OracleTypes.CURSOR);
                cstmt.execute();
                rs = (ResultSet) cstmt.getObject(1);

                if (rs != null) {
                    out.println("<div class='container'><table>");
                    out.println("<tr><th>Log ID</th><th>User Name</th><th>Operation Time</th><th>Table Name</th><th>Operation</th><th>Tuple Key</th></tr>");
                    while (rs.next()) {
                        out.println("<tr><td>" + rs.getString("LOG#") + "</td><td>" + rs.getString("USER_NAME") + "</td><td>" + rs.getString("OP_TIME") +
                                    "</td><td>" + rs.getString("TABLE_NAME") + "</td><td>" + rs.getString("OPERATION") + "</td><td>" + rs.getString("TUPLE_KEYVALUE") + "</td></tr>");
                    }
                    out.println("</table></div>");
                } else {
                    out.println("<div class='container'><p>No logs found or invalid query.</p></div>");
                }
            } catch (SQLException e) {
                out.println("<div class='container'><p>Error: " + e.getMessage() + "</p></div>");
                e.printStackTrace();
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
