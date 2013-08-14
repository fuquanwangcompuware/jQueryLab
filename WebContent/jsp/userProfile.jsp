<%@ page import="java.sql.*, org.apache.derby.jdbc.*"%>
<%@ page contentType="application/json"%>

<%

	Connection conn = null;
	PreparedStatement pstmt = null;
	ResultSet rs = null;

	String userID = request.getParameter("userID");

	try {
		Class.forName("org.apache.derby.jdbc.ClientDriver");
		String fullConnectionString = "jdbc:derby://localhost:1527/jQuerySprintLab";
		conn = DriverManager.getConnection(fullConnectionString);
		String sql = "SELECT * FROM users where user_id = ?";
		pstmt = conn.prepareStatement(sql);

		pstmt.setString(1, userID);

		rs = pstmt.executeQuery();

		if (rs.next()) {
		
			String firstName = rs.getString("first_name");
			String lastName = rs.getString("last_name");
			String email = rs.getString("email");
			String title = rs.getString("title");
			String password = rs.getString("password");
			
			String json = "{\"userID\":\"" + userID +"\", \"firstName\":\"" + firstName +"\", \"lastName\":\"" + lastName +"\", \"email\":\"" + email +"\", \"title\":\"" + title +"\", \"password\":\"" + password +"\"}";
			out.print(json);
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