<%@ page import="java.sql.*, org.apache.derby.jdbc.*"%>
<%
	Connection conn = null;
	PreparedStatement pstmt = null;
	ResultSet rs = null;

	String userID = request.getParameter("userID").trim();
	String firstName = request.getParameter("firstName").trim();
	String lastName = request.getParameter("lastName").trim();
	String email = request.getParameter("email").trim();
	String title = request.getParameter("title").trim();
	String password = request.getParameter("password").trim();

	try {
		Class.forName("org.apache.derby.jdbc.ClientDriver");
		String fullConnectionString = "jdbc:derby://localhost:1527/jQuerySprintLab";
		conn = DriverManager.getConnection(fullConnectionString);
		
		String sql = "SELECT * from users where email = ? and user_id <> ?";
		
		pstmt = conn.prepareStatement(sql);

		pstmt.setString(1, email);
		pstmt.setString(2, userID);

		rs = pstmt.executeQuery();

		if (rs.next()) {
			out.print("emailExists");
		} else {
			sql = "UPDATE users set first_name=?, last_name=?, email=?, title=?, password=? where user_id = ?";
			
			pstmt = conn.prepareStatement(sql);
			
			pstmt.setString(1, firstName);
			pstmt.setString(2, lastName);
			pstmt.setString(3, email);
			pstmt.setString(4, title);
			pstmt.setString(5, password);
			pstmt.setString(6, userID);
			
			pstmt.executeUpdate();
			
			out.print("success");
			
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