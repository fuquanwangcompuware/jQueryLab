<%@ page import="java.sql.*, org.apache.derby.jdbc.*, java.util.*, java.text.*"%>
<%
	Connection conn = null;
	PreparedStatement pstmt = null;
	PreparedStatement pstmt_milestone = null;
	PreparedStatement pstmt_comment = null;
	ResultSet rs =null;
	
	PreparedStatement pstmt_user_query = null;
	ResultSet rs_user_query = null;
	String sql_user_query = "Select first_name, last_name from users where user_id=?";

	String requestType = request.getParameter("requestType");
	String table = request.getParameter("table");
	System.out.println(requestType + " to " + table);	
	try {
		Class.forName("org.apache.derby.jdbc.ClientDriver");
		String fullConnectionString = "jdbc:derby://localhost:1527/jQuerySprintLab";
		conn = DriverManager.getConnection(fullConnectionString);
		
		String generate_milestone_id_sql = "select max(milestone_id) as current_id from milestones";
		String generatedMilestoneID = "";

		String generate_comment_id_sql = "select max(comment_id) as current_id from comments";
		String generatedCommentID = "";

		if(requestType.equals("delete")) {
			String field = request.getParameter("field");
			String id = request.getParameter("id");

			String sql_delete = "delete from " + table + " where "+ field +" =?";
			pstmt = conn.prepareStatement(sql_delete);
			
			pstmt.setString(1, id);
			System.out.println(sql_delete + id);
		} else if(requestType.equals("update")) {
		
			if(table.equals("milestones")) {
				String sql_update = "update milestones set milestone_date=?, milestone_text=? where milestone_id=?";
				
				pstmt = conn.prepareStatement(sql_update);
				
				String milestone_date= request.getParameter("milestone_date").trim();
				String milestone_text= request.getParameter("milestone_text").trim();
				String milestone_id= request.getParameter("milestone_id").trim();
				// String formattedDay = milestone_date.split("-")[1] + "/" +milestone_date.split("-")[2] + "/" + milestone_date.split("-")[0];
				pstmt.setString(1, milestone_date);
				pstmt.setString(2, milestone_text);
				pstmt.setString(3, milestone_id);
				System.out.println(sql_update + " " + milestone_date + " " + milestone_text + " " + milestone_id);
			} else if(table.equals("comments")) {
				String sql_update = "update comments set comment_text=? where comment_id=?";
				
				pstmt = conn.prepareStatement(sql_update);
				
				String comment_text= request.getParameter("comment_text").trim();
				String comment_id= request.getParameter("comment_id").trim();
				
				pstmt.setString(1, comment_text);
				pstmt.setString(2, comment_id);
				System.out.println(sql_update + " " + comment_text + " " + comment_id);
			}
		} else if(requestType.equals("add")) {

			if(table.equals("milestones")) {
				System.out.println("adding milestone");
				pstmt_milestone = conn.prepareStatement(generate_milestone_id_sql);
				rs = pstmt_milestone.executeQuery();
				
				if(rs.next()) {
					String currentID = rs.getString("current_id");
					generatedMilestoneID = new Integer(Integer.parseInt(currentID) + 1).toString();
				}
				System.out.println("new milestone ID " + generatedMilestoneID);
				String proj_id = request.getParameter("projectID").trim();
				String date_ = request.getParameter("milestoneDate").trim();
				String text = request.getParameter("milestoneDescription").trim();
				String entered_by = request.getParameter("enteredBy").trim();
			
				String sql_add = "insert into milestones(milestone_id, proj_id, milestone_date, milestone_text, entered_by) values(?, ?, ?, ?, ?)";
				pstmt = conn.prepareStatement(sql_add);
				
				pstmt.setString(1, generatedMilestoneID);
				pstmt.setString(2, proj_id);
				pstmt.setString(3, date_);
				pstmt.setString(4, text);
				pstmt.setString(5, entered_by);
				
				// Query User Name
				pstmt_user_query = conn.prepareStatement(sql_user_query);
				pstmt_user_query.setString(1, entered_by);
				rs_user_query = pstmt_user_query.executeQuery();
				if(rs_user_query.next()) {
					generatedMilestoneID = generatedMilestoneID + "," + rs_user_query.getString("first_name") + " " + rs_user_query.getString("last_name");
				}
				
				System.out.println(sql_add);
			} else if(table.equals("comments")) {
				System.out.println("adding comment");
				pstmt_comment = conn.prepareStatement(generate_comment_id_sql);
				rs = pstmt_comment.executeQuery();
				
				if(rs.next()) {
					String currentID = rs.getString("current_id");
					generatedCommentID = new Integer(Integer.parseInt(currentID) + 1).toString();
				}
				System.out.println("new comment ID " + generatedCommentID);
				String proj_id = request.getParameter("projectID").trim();
				
				java.util.Date today = new java.util.Date();
				SimpleDateFormat sdf = new SimpleDateFormat("YYYY-MM-dd");
				String date_ = sdf.format(today);
				
				String text = request.getParameter("commentDescription").trim();
				String entered_by = request.getParameter("enteredBy").trim();
			
				String sql_add = "insert into comments(comment_id, proj_id, comment_date, comment_text, entered_by) values(?, ?, ?, ?, ?)";
				pstmt = conn.prepareStatement(sql_add);
				
				pstmt.setString(1, generatedCommentID);
				pstmt.setString(2, proj_id);
				pstmt.setString(3, date_);
				pstmt.setString(4, text);
				pstmt.setString(5, entered_by);
				
				// Query User Name
				pstmt_user_query = conn.prepareStatement(sql_user_query);
				pstmt_user_query.setString(1, entered_by);
				rs_user_query = pstmt_user_query.executeQuery();
				if(rs_user_query.next()) {
					generatedCommentID = generatedCommentID + "," + rs_user_query.getString("first_name") + " " + rs_user_query.getString("last_name") + "," + date_;
				}
				
				System.out.println(sql_add);
			}
		}

		int rows = pstmt.executeUpdate();

		if (rows==1) {
			if(requestType.equals("add") && table.equals("milestones")) {
				out.print("success," + generatedMilestoneID);
			} else if(requestType.equals("add") && table.equals("comments")) {
				out.print("success," + generatedCommentID);
			} else {
				out.print("success");
			}
		} else {
			out.print("%fail");
		}

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