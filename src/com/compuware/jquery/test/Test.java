package com.compuware.jquery.test;

import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.PreparedStatement;
import java.sql.ResultSet;

public class Test {

	static Connection conn = null;
	
	static PreparedStatement pstmt = null;
	
	static PreparedStatement pstmt_project = null;
	static ResultSet rs_project = null;
	
	static PreparedStatement pstmt_user_query = null;
	static ResultSet rs_user_query = null;

	static PreparedStatement pstmt_milestone = null;
	static ResultSet rs_milestone = null;
	
	static PreparedStatement pstmt_comment = null;
	static ResultSet rs_comment = null;
	public static void main(String[] args) throws Exception {
		try {
			Class.forName("org.apache.derby.jdbc.ClientDriver");
			String fullConnectionString = "jdbc:derby://localhost:1527/jQuerySprintLab";
			conn = DriverManager.getConnection(fullConnectionString);
			
			String sql = "INSERT INTO comments (comment_id, proj_id, comment_date, comment_text, entered_by)" +
					"VALUES (19, 1, '09/05/2013', 'Comment from user #2.', 2)";

			String sql2 = "delete from comments where comment_id=20";
			
			System.out.println(sql2);
			pstmt = conn.prepareStatement(sql2);
			pstmt.executeUpdate();
		} catch (Exception e) {
			e.printStackTrace();
			System.out.println("Failed");
		} finally {
			if (rs_project != null)
				rs_project.close();
			if (pstmt_project != null)
				pstmt_project.close();
			if (conn != null)
				conn.close();
		}
	}
}