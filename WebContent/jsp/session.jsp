<%
	// Set session time out = 15 min
	session.setMaxInactiveInterval(900);
	
	// Receive request type
	String requestType = request.getParameter("requestType");

	// Actions for different request type
	
	// user session checking
	if(requestType.equals("checkUser")) {
		if(session.getAttribute("user")==null) {
			out.println("no");
		} else {
			out.println(session.getAttribute("user"));
		}
		
	// user login - create session with logged in user stored
	} else if(requestType.equals("saveUser") && request.getParameter("loggedInUser")!=null) {
		session.setAttribute("user", request.getParameter("loggedInUser"));
		
	// user logout - destroy session
	} else if(requestType.equals("logout")) {
		session.invalidate();
	}
%>