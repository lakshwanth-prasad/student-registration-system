<%@ page import="java.sql.*, oracle.jdbc.*" %>
<%@ page import="oracle.jdbc.pool.OracleDataSource, oracle.jdbc.OracleTypes" %>
<!DOCTYPE html>
<html>
<head>
    <title>Drop Graduate Student from Class</title>
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
        }
        input[type="text"], select {
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
    </style>
</head>
<body>
    <div class="container">
        <h1>Drop Graduate Student from Class</h1>
        <form method="post">
            <label for="bid">Student B#:</label>
            <input type="text" name="bid" id="bid" required><br>

            <label for="classid">Class ID:</label>
            <input type="text" name="classid" id="classid" required><br>

            <input type="submit" value="Drop Student">
            <button type="button" class="back-button" onclick="window.location.href='dashboard.jsp';">Back to Dashboard</button>
        </form>
        <% if ("POST".equalsIgnoreCase(request.getMethod())) {
            String bid = request.getParameter("bid");
            String classid = request.getParameter("classid");

            // Fetch database credentials from context parameters
            String user = application.getInitParameter("dbUser");
            String password = application.getInitParameter("dbPassword");
            String url = application.getInitParameter("dbURL");

            OracleDataSource ds = null;
            Connection conn = null;
            CallableStatement cstmt = null;

            try {
                ds = new OracleDataSource();
                ds.setURL(url);
                conn = ds.getConnection(user, password);

                cstmt = conn.prepareCall("{call STUREG.REMOVE_GRADUATE_ENROLL(?, ?)}");
                cstmt.setString(1, bid);
                cstmt.setString(2, classid);
                cstmt.execute();

                out.println("<p>Student dropped successfully from the class!</p>");
            } catch (SQLException e) {
                out.println("<p>Error: " + e.getMessage() + "</p>");
            } catch (Exception e) {
                out.println("<p>Error: " + e.getMessage() + "</p>");
            } finally {
                if (cstmt != null) try { cstmt.close(); } catch (Exception e) {}
                if (conn != null) try { conn.close(); } catch (Exception e) {}
            }
        } %>
    </div>
</body>
</html>
