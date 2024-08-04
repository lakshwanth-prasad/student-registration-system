<%@ page import="java.sql.*" %>
<%@ page import="oracle.jdbc.pool.OracleDataSource" %>
<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="UTF-8">
<title>Add Student Form</title>
<script>
function formatDate(input) {
    var datePart = input.split("-");
    var year = datePart[0];
    var month = datePart[1];
    var day = datePart[2];

    // Convert month from numbers to text
    var months = ["JAN", "FEB", "MAR", "APR", "MAY", "JUN",
                  "JUL", "AUG", "SEP", "OCT", "NOV", "DEC"];
    month = months[parseInt(month) - 1];

    // Convert year from YYYY to YY
    year = year.substring(2);

    return day + '-' + month + '-' + year;
}

function submitForm() {
    var dobInput = document.getElementById('dob');
    dobInput.value = formatDate(dobInput.value);
    document.getElementById('studentForm').submit();
}
</script>
</head>
<body>
<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="UTF-8">
<title>Add Student Form</title>
<script>
function submitForm() {
    var day = document.getElementById('day').value;
    var month = document.getElementById('month').value;
    var year = document.getElementById('year').value.substring(2); // Get last two digits of the year
    var formattedDate = day + '-' + month + '-' + year;
    document.getElementById('dob').value = formattedDate; // Assign the formatted date to the hidden input
    document.getElementById('studentForm').submit();
}
</script>
</head>
<body>
<form id="studentForm" method="POST">
    B#: <input type="text" name="bid"><br>
    First Name: <input type="text" name="fname"><br>
    Last Name: <input type="text" name="lname"><br>
    Level: 
    <select name="level">
        <option value="freshman">Freshman</option>
        <option value="sophomore">Sophomore</option>
        <option value="junior">Junior</option>
        <option value="senior">Senior</option>
        <option value="master">Master</option>
        <option value="PhD">PhD</option>
    </select><br>
    GPA: <input type="text" name="gpa"><br>
    Email: <input type="text" name="email"><br>
    Date of Birth: 
    <select id="day" name="day">
        <!-- Populate days -->
        <script>
        for(var i = 1; i <= 31; i++) {
            document.write('<option value="' + i + '">' + i + '</option>');
        }
        </script>
    </select>
    <select id="month" name="month">
        <!-- Populate months -->
        <option value="JAN">JAN</option>
        <option value="FEB">FEB</option>
        <option value="MAR">MAR</option>
        <option value="APR">APR</option>
        <option value="MAY">MAY</option>
        <option value="JUN">JUN</option>
        <option value="JUL">JUL</option>
        <option value="AUG">AUG</option>
        <option value="SEP">SEP</option>
        <option value="OCT">OCT</option>
        <option value="NOV">NOV</option>
        <option value="DEC">DEC</option>
    </select>
    <select id="year" name="year">
        <!-- Populate years -->
        <script>
        var year = new Date().getFullYear();
        for(var j = year; j >= 1900; j--) {
            document.write('<option value="' + j + '">' + j + '</option>');
        }
        </script>
    </select><br>
    <!-- Hidden input to hold the formatted date -->
    <input type="hidden" id="dob" name="dob">
    <button type="button" onclick="submitForm()">Add Student</button>
</form>
</body>
</html>
</body>
</html>


<%
if ("POST".equalsIgnoreCase(request.getMethod())) {
    String bid = request.getParameter("bid");
    String fname = request.getParameter("fname");
    String lname = request.getParameter("lname");
    String level = request.getParameter("level");
    float gpa = Float.parseFloat(request.getParameter("gpa"));
    String email = request.getParameter("email");
    String dob = request.getParameter("dob");

    try {
    	String user = "lkothandaram";
        String pass = "ChangeMeLKOTHANDARAM";
        OracleDataSource ds = new OracleDataSource();
        ds.setURL("jdbc:oracle:thin:@castor.cc.binghamton.edu:1521:acad111");
        Connection connection = ds.getConnection(user, pass);

        PreparedStatement pstmt = connection.prepareStatement("INSERT INTO students (B#, first_name, last_name, st_level, gpa, email, bdate) VALUES (?, ?, ?, ?, ?, ?, ?)");
        pstmt.setString(1, bid);
        pstmt.setString(2, fname);
        pstmt.setString(3, lname);
        pstmt.setString(4, level);
        pstmt.setFloat(5, gpa);
        pstmt.setString(6, email);
        pstmt.setString(7, dob);
        pstmt.executeUpdate();
        out.println("<p>Student added successfully!</p>");
        connection.close();
    } catch (Exception e) {
        out.println("<p>Error: " + e.getMessage() + "</p>");
    }
}
%>
</body>
</html>
