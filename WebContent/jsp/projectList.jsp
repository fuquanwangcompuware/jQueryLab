<%@ page import="java.sql.*, org.apache.derby.jdbc.*"%>
<%@ page contentType="application/json"%>

<%

	Connection conn = null;
	
	PreparedStatement pstmt_project = null;
	ResultSet rs_project = null;
	
	PreparedStatement pstmt_user_query = null;
	ResultSet rs_user_query = null;

	PreparedStatement pstmt_milestone = null;
	ResultSet rs_milestone = null;
	
	PreparedStatement pstmt_comment = null;
	ResultSet rs_comment = null;

	String user_ID = request.getParameter("userID");

	try {
		Class.forName("org.apache.derby.jdbc.ClientDriver");
		String fullConnectionString = "jdbc:derby://localhost:1527/jQuerySprintLab";
		conn = DriverManager.getConnection(fullConnectionString);

		String sql_user_project = "SELECT u.user_id, u.first_name, u.last_name, u.email, u.title, " +
				"p.proj_id, p.owner, p.proj_name, p.proj_number, p.billing_code, p.proj_description, p.client_name, p.timeframe "+
				
				"FROM users u, projects p, project_teams t " +
				"where t.user_id = ? and t.user_id = u.user_id and t.proj_id=p.proj_id";
		
		String sql_user_query = "Select first_name, last_name from users where user_id=?";
		String sql_user_proj ="select * from projects";
		
		String sql_project_milestone = "select milestone_id, p.proj_id, milestone_date, milestone_text, entered_by from projects p, milestones m where p.proj_id = m.proj_id and m.proj_id=? order by milestone_date desc";
		
		String sql_project_comment = "select comment_id, p.proj_id, comment_date, comment_text, entered_by from projects p, comments c where p.proj_id = c.proj_id and c.proj_id=? order by comment_date desc";
		
		pstmt_project = conn.prepareStatement(sql_user_project);
		pstmt_project.setString(1, user_ID);
		rs_project = pstmt_project.executeQuery();

		String json = "";
		
		// Check if records exist
		if(rs_project.next()) {
			
			// User Table
			String userID = rs_project.getString("user_id");
			String userFirstName = rs_project.getString("first_name");
			String userLastName = rs_project.getString("last_name");
			String userEmail = rs_project.getString("email");
			String userTitle = rs_project.getString("title");
			
			// Reset Cursor
			//rs.first();
			
			json = 
			"{\n" +
			"\"userID\":\"" + userID + "\",\n"+
			"\"userFirstName\":\"" + userFirstName + "\",\n"+
			"\"userLastName\":\"" + userLastName + "\",\n"+
			"\"userEmail\":\"" + userEmail + "\",\n"+
			"\"userTitle\":\"" + userTitle + "\"";
			
			
			String projectID = rs_project.getString("proj_id");
			String projectOwner = rs_project.getString("owner");
			String projectName = rs_project.getString("proj_name");
			String projectNumber = rs_project.getString("proj_number");
			String projectBillingCode = rs_project.getString("billing_code");
			String projectDescription = rs_project.getString("proj_description");
			String projectClientName = rs_project.getString("client_name");
			String projectTimeframe = rs_project.getString("timeframe");
			
			String projectOwnerName = "";
			
			pstmt_user_query = conn.prepareStatement(sql_user_query);
			pstmt_user_query.setString(1, projectOwner);
			rs_user_query = pstmt_user_query.executeQuery();
			
			if(rs_user_query.next()) {
				json = json + ",\n";
			
				projectOwnerName = rs_project.getString("first_name") + " " + rs_project.getString("last_name");
				json = json + "\"projects\": \n  [\n";
				json = json + "    {" + 
					"\n    \"projectID\":\"" + projectID + "\","+
					"\n    \"projectOwner\":\"" + projectOwnerName + "\","+
					"\n    \"projectName\":\"" + projectName + "\","+
					"\n    \"projectNumber\":\"" + projectNumber + "\","+
					"\n    \"projectBillingCode\":\"" + projectBillingCode + "\","+
					"\n    \"projectDescription\":\"" + projectDescription + "\","+
					"\n    \"projectClientName\":\"" + projectClientName + "\","+
					"\n    \"projectTimeframe\":\"" + projectTimeframe + "\"";
					
						/*******************Milestones************************/

						pstmt_milestone = conn.prepareStatement(sql_project_milestone);
						pstmt_milestone.setString(1, projectID);
						rs_milestone = pstmt_milestone.executeQuery();
						
						String milestoneID = "";
						String milestoneDate = "";
						String milestoneText = "";
						String m_enteredBy = "";
						
						if(rs_milestone.next()) {
							json = json + ",";
							milestoneID = rs_milestone.getString("milestone_id");
							milestoneDate = rs_milestone.getString("milestone_date");
							milestoneText = rs_milestone.getString("milestone_text");
							m_enteredBy = rs_milestone.getString("entered_by");
							
							// Query User Name
							pstmt_user_query = conn.prepareStatement(sql_user_query);
							pstmt_user_query.setString(1, m_enteredBy);
							rs_user_query = pstmt_user_query.executeQuery();
							if(rs_user_query.next()) {
								m_enteredBy = rs_user_query.getString("first_name") + " " + rs_project.getString("last_name");
							}
						
							json = json + "\n    \"milestones\":" + 
							
							"\n      [" + 
							"\n        {" +		
							"\n        \"milestoneID\":\"" + milestoneID + "\"," +
							"\n        \"milestoneDate\":\"" + milestoneDate + "\"," + 
							"\n        \"milestoneText\":\"" + milestoneText + "\"," +
							"\n        \"enteredBy\":\"" + m_enteredBy + "\"" +
							"\n        }";
							
							while(rs_milestone.next()) {
								milestoneID = rs_milestone.getString("milestone_id");
								milestoneDate = rs_milestone.getString("milestone_date");
								milestoneText = rs_milestone.getString("milestone_text");
								m_enteredBy = rs_milestone.getString("entered_by");
								
								// Query User Name
								pstmt_user_query = conn.prepareStatement(sql_user_query);
								pstmt_user_query.setString(1, m_enteredBy);
								rs_user_query = pstmt_user_query.executeQuery();
								if(rs_user_query.next()) {
									m_enteredBy = rs_user_query.getString("first_name") + " " + rs_project.getString("last_name");
								}
								
								json = json + ",";
								json = json + 
								"\n        {" +		
								"\n        \"milestoneID\":\"" + milestoneID + "\"," +
								"\n        \"milestoneDate\":\"" + milestoneDate + "\"," + 
								"\n        \"milestoneText\":\"" + milestoneText + "\"," +
								"\n        \"enteredBy\":\"" + m_enteredBy + "\"" +
								"\n        }";
							}
						}
						
						json = json + "\n      ]";
						
						
						
						/*******************Comments************************/
						
						pstmt_comment = conn.prepareStatement(sql_project_comment);
						pstmt_comment.setString(1, projectID);
						rs_comment = pstmt_comment.executeQuery();
						
						String commentID = "";
						String commentDate = "";
						String commentText = "";
						String c_enteredBy = "";
						
						if(rs_comment.next()) {
							commentID = rs_comment.getString("comment_id");
							commentDate = rs_comment.getString("comment_date");
							commentText = rs_comment.getString("comment_text");
							c_enteredBy = rs_comment.getString("entered_by");
							
							// Query User Name
							pstmt_user_query = conn.prepareStatement(sql_user_query);
							pstmt_user_query.setString(1, c_enteredBy);
							rs_user_query = pstmt_user_query.executeQuery();
							if(rs_user_query.next()) {
								c_enteredBy = rs_user_query.getString("first_name") + " " + rs_project.getString("last_name");
							}
						
							json = json + ",\n\n    \"comments\":" + 
							
							"\n      [" + 
							"\n        {" +		
							"\n        \"commentID\":\"" + commentID + "\"," +
							"\n        \"commentDate\":\"" + commentDate + "\"," + 
							"\n        \"commentText\":\"" + commentText + "\"," +
							"\n        \"enteredBy\":\"" + c_enteredBy + "\"" +
							"\n        }";
							
							while(rs_comment.next()) {
								commentID = rs_comment.getString("comment_id");
								commentDate = rs_comment.getString("comment_date");
								commentText = rs_comment.getString("comment_text");
								c_enteredBy = rs_comment.getString("entered_by");
								
								// Query User Name
								pstmt_user_query = conn.prepareStatement(sql_user_query);
								pstmt_user_query.setString(1, c_enteredBy);
								rs_user_query = pstmt_user_query.executeQuery();
								if(rs_user_query.next()) {
									c_enteredBy = rs_user_query.getString("first_name") + " " + rs_project.getString("last_name");
								}
								
								json = json + ",";
								json = json + 
								"\n        {" +		
								"\n        \"commentID\":\"" + commentID + "\"," +
								"\n        \"commentDate\":\"" + commentDate + "\"," + 
								"\n        \"commentText\":\"" + commentText + "\"," +
								"\n        \"enteredBy\":\"" + c_enteredBy + "\"" +
								"\n        }";
							}
						}
						
						json = json + "\n      ]";
					
					
					json = json + "\n    }";
				
					while(rs_project.next()) {
						
						/*******************Projects************************/
						
						projectID = rs_project.getString("proj_id");
						projectOwner = rs_project.getString("owner");
						
						pstmt_user_query.setString(1, projectOwner);
						rs_user_query = pstmt_user_query.executeQuery();
						
						if(rs_user_query.next()) {
							projectOwnerName = rs_project.getString("first_name") + " " + rs_project.getString("last_name");
						}
						
						projectName = rs_project.getString("proj_name");
						projectNumber = rs_project.getString("proj_number");
						projectBillingCode = rs_project.getString("billing_code");
						projectDescription = rs_project.getString("proj_description");
						projectClientName = rs_project.getString("client_name");
						projectTimeframe = rs_project.getString("timeframe");
						json = json + ",";
						json = json + "\n    {" + 
							"\n    \"projectID\":\"" + projectID + "\","+
							"\n    \"projectOwner\":\"" + projectOwnerName + "\","+
							"\n    \"projectName\":\"" + projectName + "\","+
							"\n    \"projectNumber\":\"" + projectNumber + "\","+
							"\n    \"projectBillingCode\":\"" + projectBillingCode + "\","+
							"\n    \"projectDescription\":\"" + projectDescription + "\","+
							"\n    \"projectClientName\":\"" + projectClientName + "\","+
							"\n    \"projectTimeframe\":\"" + projectTimeframe + "\"";
						
						
						/*******************Milestones************************/
						
						pstmt_milestone = conn.prepareStatement(sql_project_milestone);
						pstmt_milestone.setString(1, projectID);
						rs_milestone = pstmt_milestone.executeQuery();
						
						milestoneID = "";
						milestoneDate = "";
						milestoneText = "";
						m_enteredBy = "";
						
						if(rs_milestone.next()) {
							json = json + ",";
							milestoneID = rs_milestone.getString("milestone_id");
							milestoneDate = rs_milestone.getString("milestone_date");
							milestoneText = rs_milestone.getString("milestone_text");
							m_enteredBy = rs_milestone.getString("entered_by");
							
							// Query User Name
							pstmt_user_query = conn.prepareStatement(sql_user_query);
							pstmt_user_query.setString(1, m_enteredBy);
							rs_user_query = pstmt_user_query.executeQuery();
							if(rs_user_query.next()) {
								m_enteredBy = rs_user_query.getString("first_name") + " " + rs_project.getString("last_name");
							}
						
							json = json + "\n    \"milestones\":" + 
							
							"\n      [" + 
							"\n        {" +		
							"\n        \"milestoneID\":\"" + milestoneID + "\"," +
							"\n        \"milestoneDate\":\"" + milestoneDate + "\"," + 
							"\n        \"milestoneText\":\"" + milestoneText + "\"," +
							"\n        \"enteredBy\":\"" + m_enteredBy + "\"" +
							"\n        }";
							
							while(rs_milestone.next()) {
								milestoneID = rs_milestone.getString("milestone_id");
								milestoneDate = rs_milestone.getString("milestone_date");
								milestoneText = rs_milestone.getString("milestone_text");
								m_enteredBy = rs_milestone.getString("entered_by");
								
								// Query User Name
								pstmt_user_query = conn.prepareStatement(sql_user_query);
								pstmt_user_query.setString(1, m_enteredBy);
								rs_user_query = pstmt_user_query.executeQuery();
								if(rs_user_query.next()) {
									m_enteredBy = rs_user_query.getString("first_name") + " " + rs_project.getString("last_name");
								}
								
								json = json + 
								"\n        ,{" +		
								"\n        \"milestoneID\":\"" + milestoneID + "\"," +
								"\n        \"milestoneDate\":\"" + milestoneDate + "\"," + 
								"\n        \"milestoneText\":\"" + milestoneText + "\"," +
								"\n        \"enteredBy\":\"" + m_enteredBy + "\"" +
								"\n        }";
							}
						}
						
						json = json + "\n      ]";
						
						
						/*******************Comments************************/
						
						pstmt_comment = conn.prepareStatement(sql_project_comment);
						pstmt_comment.setString(1, projectID);
						rs_comment = pstmt_comment.executeQuery();
						
						commentID = "";
						commentDate = "";
						commentText = "";
						c_enteredBy = "";
						
						if(rs_comment.next()) {
							commentID = rs_comment.getString("comment_id");
							commentDate = rs_comment.getString("comment_date");
							commentText = rs_comment.getString("comment_text");
							c_enteredBy = rs_comment.getString("entered_by");
							
							// Query User Name
							pstmt_user_query = conn.prepareStatement(sql_user_query);
							pstmt_user_query.setString(1, c_enteredBy);
							rs_user_query = pstmt_user_query.executeQuery();
							if(rs_user_query.next()) {
								c_enteredBy = rs_user_query.getString("first_name") + " " + rs_project.getString("last_name");
							}
						
							json = json + ",\n    \"comments\":" + 
							
							"\n      [" + 
							"\n        {" +		
							"\n        \"commentID\":\"" + commentID + "\"," +
							"\n        \"commentDate\":\"" + commentDate + "\"," + 
							"\n        \"commentText\":\"" + commentText + "\"," +
							"\n        \"enteredBy\":\"" + c_enteredBy + "\"" +
							"\n        }";
							
							while(rs_comment.next()) {
								commentID = rs_comment.getString("comment_id");
								commentDate = rs_comment.getString("comment_date");
								commentText = rs_comment.getString("comment_text");
								c_enteredBy = rs_comment.getString("entered_by");
								
								// Query User Name
								pstmt_user_query = conn.prepareStatement(sql_user_query);
								pstmt_user_query.setString(1, c_enteredBy);
								rs_user_query = pstmt_user_query.executeQuery();
								if(rs_user_query.next()) {
									c_enteredBy = rs_user_query.getString("first_name") + " " + rs_project.getString("last_name");
								}
								
								json = json + 
								"\n        ,{" +		
								"\n        \"commentID\":\"" + commentID + "\"," +
								"\n        \"commentDate\":\"" + commentDate + "\"," + 
								"\n        \"commentText\":\"" + commentText + "\"," +
								"\n        \"enteredBy\":\"" + c_enteredBy + "\"" +
								"\n        }";
							}
						}
						
						json = json + "\n      ]";
						json = json + "\n    }";
	
					}	
				}
				
			json = json+"\n  ]\n}";
			out.print(json);
			
		} else {
			out.print("%fail");
		}

	} catch (Exception e) {
		e.printStackTrace();
		out.print(e.getMessage());
	} finally {
		if (rs_project != null)
			rs_project.close();
		if (rs_user_query != null)
			rs_user_query.close();
		if (rs_milestone != null)
			rs_milestone.close();
		if (rs_comment != null)
			rs_comment.close();
		if (pstmt_project != null)
			pstmt_project.close();
		if (pstmt_user_query != null)
			pstmt_user_query.close();
		if (pstmt_milestone != null)
			pstmt_milestone.close();
		if (pstmt_comment != null)
			pstmt_comment.close();
		if (conn != null)
			conn.close();
	}
%>