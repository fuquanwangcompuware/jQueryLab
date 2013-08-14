<%@ page import="java.sql.*, org.apache.derby.jdbc.*"%>
<%
	Connection conn = null;
	PreparedStatement pstmt = null;
	ResultSet rs = null;

	String email = request.getParameter("email");
	String password = request.getParameter("password");
	

	try {
		Class.forName("org.apache.derby.jdbc.ClientDriver");
		String fullConnectionString = "jdbc:derby://localhost:1527/jQuerySprintLab";
		conn = DriverManager.getConnection(fullConnectionString);
		String sql = "SELECT * FROM users where email = ? and password = ?";
		pstmt = conn.prepareStatement(sql);
		pstmt.setString(1, email);
		pstmt.setString(2, password);

		rs = pstmt.executeQuery();

		if (rs.next()) {
			String userNameAndID = rs.getString("first_name") + " " + rs.getString("last_name") + "," + rs.getString("user_id");
			out.print(userNameAndID);
		} else {
			out.print("%fail");
		}

	} catch (Exception e) {
		e.printStackTrace();
		out.println(e.getMessage());
	} finally {
		if (rs != null)
			rs.close();
		if (pstmt != null)
			pstmt.close();
		if (conn != null)
			conn.close();
	}
%>