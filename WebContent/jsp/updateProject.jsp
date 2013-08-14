<%@ page import="java.sql.*, org.apache.derby.jdbc.*"%>

<%
	Connection conn = null;
	PreparedStatement pstmt = null;

	String projectID = request.getParameter("projectID");
	String newValue = request.getParameter("newValue");
	String field = request.getParameter("field");
	
	try {
		Class.forName("org.apache.derby.jdbc.ClientDriver");
		String fullConnectionString = "jdbc:derby://localhost:1527/jQuerySprintLab";
		conn = DriverManager.getConnection(fullConnectionString);
		
		String sql = "update projects set " + field + "=? where proj_id=?";
		pstmt = conn.prepareStatement(sql);
		pstmt.setString(1, newValue);
		pstmt.setString(2, projectID);
		
		pstmt.executeUpdate();
		
		out.print("success");

	} catch (Exception e) {
		e.printStackTrace();
		out.print(e.getMessage());
	} finally {
		if (pstmt != null)
			pstmt.close();
		if (conn != null)
			conn.close();
	}
%>