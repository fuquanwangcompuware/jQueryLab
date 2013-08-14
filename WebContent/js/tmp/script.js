$(function(){
	// session check
	$.post("./jsp/session.jsp", {requestType:"checkUser"}, function(resp){
		resp = $.trim(resp);

		// User already logged in, retrieve the credential
		if(resp!=="no") {
			var email = resp.split(",")[0];
			var password = resp.split(",")[1];
			$("#email").val(email);
			$("#password").val(password);
			$("#login-dialog").dialog();
			$("#signInButton").trigger('click');
		}
	});

	// Initialize carousel
	$('.carousel').carousel({
		  interval: 3000
		});
	// $('.carousel-control.right').trigger('click');
});

function showLogin() {
	$("#login-dialog").dialog({
		modal : true,
		title : "Sign In",
		// closeOnEscape : false,
		resizable : false,
		width: 400
	});
};

function showUserProfile() {
	var userID = $("#logged-in-user-id").val();
	var firstName = "";
	
	$.getJSON("./jsp/userProfile.jsp", "userID="+userID, function(resp){
		$("#user-profile-dialog").dialog({
			title: "User Profile",
			modal: true,
			resizable : false,
			width: 400
		});
		
		$("#user-profile-id").val(resp.userID);
		$("#user-profile-first-name").val(resp.firstName);
		$("#user-profile-last-name").val(resp.lastName);
		$("#user-profile-email").val(resp.email);
		$("#user-profile-title").val(resp.title);
		$("#user-profile-password").val(resp.password);
	});
};

$("#signInButton").on("click", function(){
	processLogin($.trim($("#email").val()), $("#password").val());
});

function processLogin(email, password){
	if(email.length < 1 || password.length < 1) {
		$("#login-message").css({"display":"inline", "color":"red"}).html("Fields cannot be empty");
	} else {
		// Send ajax request to login.jsp
		var jqXHR = $.post("./jsp/login.jsp", {email:email, password:password})
		.success(function(resp){
			resp = $.trim(resp);
			if(resp==="%fail") {
				$("#login-message").css({"display":"inline", "color":"red"}).html("Invalid username/password");
			} else {
				$("#login-message").css({"display":"inline", "color":"green"}).html("Login Successful");
				
				$("#login-dialog").fadeOut(500, function(){$("#login-dialog").dialog("close")});
				
				$("#login-dialog").dialog({
				close: function(){
				
					// hide the slide show
					$("#myCarousel").hide();
				
					// generate the tabs
					$("#tabs").tabs({
						create: function() {
							// when tabs created, set the project id as the first element
							$("#projectID").val($("#projectIDString").val().split(',')[0]);
						},
						beforeActivate: function(event, ui){
							// set the project id according to the tabs index
							var index = ui.newTab.index();
							$("#projectID").val($("#projectIDString").val().split(',')[index]);
						}
					}).show({
						effect: "fadeIn", duration:500
					});
					
					$( "#tabs" ).tabs({ show: { effect: "slideDown", duration: 500 } });
				}
			});
				
				// Set the Login Link with user information
				$(".header").html("<span class='logo'>ExGile Project Management System</span><a href='#'><div id='header-logged-in-user' class='header-box'></div></a>");
				
				// Create & save session
				$.post("./jsp/session.jsp", {requestType:"saveUser", loggedInUser:email+","+password});
				
				if($.trim(resp).length > 1) {
					
					var userName = resp.split(",")[0];
					var userID = resp.split(",")[1];
					
					updateLoggedInLink(userName, userID);
					loadProjects(userID);
				} else {
					$("#header-logged-in-user").text("Logged In User").on("click", showUserProfile());
				}
			}
		})
		.fail(function(resp){
			$("#login-message").css({"display":"inline", "color":"red"}).html("Failed");
		});
	}
};
	
$("#update-profile-submit-button").on("click", function(event){
	
	var userID = $("#user-profile-id").val();
	var firstName = $("#user-profile-first-name").val();
	var lastName = $("#user-profile-last-name").val();
	var email = $("#user-profile-email").val();
	var title = $("#user-profile-title").val();
	var password = $("#user-profile-password").val();
	
	$.post("./jsp/updateUser.jsp", 
		{
			userID : userID,
			firstName : firstName,
			lastName : lastName,
			email : email,
			title : title,
			password : password
		})
		.success(function(resp){
			resp=$.trim(resp);
			if(resp==="emailExists") {
				$("#user-profile-email").focus();
				$("#user-profile-email-div").addClass("control-group error");
				$("#update-profile-message").css({"display":"inline", "color":"red"}).html(" Email address already exists");
			} else if(resp === "success") {
				$("#user-profile-email-div").removeClass("control-group error");
				$("#update-profile-message").html("");
				
				$("#user-profile-dialog").dialog("close");
				
				$("#processing-dialog").dialog(
					{
						modal : true
					}
				);
				
				$("#processing-dialog").html("<img src='img/processing.gif'/>");
				
				setTimeout(function(){
					$("#processing-dialog").html("<img src='img/done.jpg'/> <h3>Profile Updated</h3><br><button id='processing-dialog-button' class='btn btn-primary' onclick='closeProcessingDialog();return false;'>Close</button>");
				}, 1000);
				updateLoggedInLink(firstName+" "+lastName, userID);
			}
		})
		.fail(function(){
			$("#processing-dialog").html("Operation failed").fadeOut(1000, function(){$("#processing-dialog").dialog("close")});
		});
});

function loadProjects(userID){
	$.getJSON("./jsp/projectList.jsp", "userID="+userID, function(resp){
		var projectID = "";
		var projectOwner = "";
		var projectName = "";
		var projectNumber = "";
		var projectBillingCode = "";
		var projectDescription = "";
		var projectClientName = "";
		var projectTimeframe = "";
		
		var milestoneID = "";
		var milestoneText = "";
		var milestoneDate = "";
		var milestoneEnteredBy = "";
		var milestoneHTML = "";
		
		var commentID = "";
		var commentText = "";
		var commentDate = "";
		var commentEnteredBy = "";
		var commentHTML = "";
		
		var projectsList="";
		
		$.each(resp.projects, function(key, value){
			$.each(value, function(k, v) {
				switch(k){
					case "projectID":
						projectID = v;
						projectsList = projectsList + projectID + ",";
						break;
					case "projectOwner":
						projectOwner = v;
						break;
					case "projectName":
						projectName = v;
						break;
					case "projectNumber":
						projectNumber = v;
						break;
					case "projectBillingCode":
						projectBillingCode = v;
						break;
					case "projectDescription":
						projectDescription = v;
						break;
					case "projectClientName":
						projectClientName = v;
						break;
					case "projectTimeframe":
						projectTimeframe = v;
						break;
					case "milestones":
						milestoneHTML = "<h3>Milestones</h3><div><p>" + 
						"<button id='add-milestone-button' class='btn btn-primary itemOpButton' onclick='javascript:addMilestoneDialog()'><i class='icon-file icon-white'></i> Create New Milestone</button>";
						$.each(v, function(mkey, mvalue){
							$.each(mvalue, function(mk, mv){
								switch(mk) {
									case "milestoneID":
										milestoneID = mv;
										break;
									case "milestoneText":
										milestoneText = mv;
										break;
									case "milestoneDate":
										milestoneDate = mv;
										break;
									case "enteredBy":
										milestoneEnteredBy = mv;
										break;
								};
							});
							
							var milestoneDivID = projectID+"_"+milestoneID+"_milestone";
							milestoneHTML = milestoneHTML + "<div class='itemBox' id="+milestoneDivID+">";
							milestoneHTML = milestoneHTML + "<h4>Milestone Date</h4><span id='"+milestoneDivID+"_date'>" + milestoneDate + "</span>" +
							"<h4>Description</h4><span id='"+milestoneDivID+"_description'>" + milestoneText + "</span>" +
							"<h4>Author</h4>" + milestoneEnteredBy;
							
							milestoneHTML = milestoneHTML + 
							"<button id='close-profile-button' class='btn btn-primary btn-mini itemOpButton' onclick='confirmDeleteMilestone(\""+milestoneID+"\",\""+milestoneDivID+"\")'><i class='icon-trash icon-white'></i> Del</button>"+
							"<span class='itemOpButton'>&nbsp;&nbsp;</span>" +
							// "<button id='close-profile-button' class='btn btn-primary btn-mini itemOpButton' onclick='updateMilestoneDialog(\""+milestoneID+"\",\""+milestoneDateLatest+"\",\""+milestoneDescriptionLatest+"\")'><i class='icon-pencil icon-white'></i> Edit</button>"+
							"<button id='close-profile-button' class='btn btn-primary btn-mini itemOpButton' onclick='updateMilestoneDialog(\""+milestoneID+"\")'><i class='icon-pencil icon-white'></i> Edit</button>"+
							
							"</div>";
						});
						milestoneHTML = milestoneHTML + "</p></div>";
						break;
					case "comments":
					
						commentHTML = "<h3>Comments</h3><div><p>" + 
						"<button id='add-comment-button' class='btn btn-primary itemOpButton' onclick='javascript:addCommentDialog()'><i class='icon-file icon-white'></i> Create New Comment</button>";;
						
						$.each(v, function(ckey, cvalue){
							$.each(cvalue, function(ck, cv){
								switch(ck) {
									case "commentID":
										commentID = cv;
										break;
									case "commentText":
										commentText = cv;
										break;
									case "commentDate":
										commentDate = cv;
										break;
									case "enteredBy":
										commentEnteredBy = cv;
										break;
								};
							});
							
							var commentDivID = projectID+"_"+commentID+"_comment";
							commentHTML = commentHTML + "<div class='itemBox' id="+commentDivID+">";
							commentHTML = commentHTML + "<h4>Comment Date</h4>" + commentDate +
							"<h4>Comment</h4><span id='"+commentDivID+"_description'>" + commentText + "</span>" +
							"<h4>Author</h4>" + commentEnteredBy;
							commentHTML = commentHTML + 
							
							"<button id='close-profile-button' class='btn btn-primary btn-mini itemOpButton' onclick='confirmDeleteComment(\""+commentID+"\",\""+commentDivID+"\")'><i class='icon-trash icon-white'></i> Del</button>"+
							"<span class='itemOpButton'>&nbsp;&nbsp;</span>" +
							// "<button id='close-profile-button' class='btn btn-primary btn-mini itemOpButton' onclick='updateCommentDialog(\""+commentID+"\",\""+commentText+"\")'><i class='icon-pencil icon-white'></i> Edit</button>"+
							"<button id='close-profile-button' class='btn btn-primary btn-mini itemOpButton' onclick='updateCommentDialog(\""+commentID+"\")'><i class='icon-pencil icon-white'></i> Edit</button>"+
							
							"</div>";
						});
						commentHTML = commentHTML + "</p></div>";
						break;
				};
			});
			$("#project-list-ul").append("<li><a href='#" + projectNumber + "'><span>" + projectName + "</span></a></li>");
			$("#tabs").append("<div id='" + projectNumber + "'>"+ 
			"<input type='hidden' id='currentProjectNumber_"+projectID+"' value="+projectNumber+">" + 
			"<div id='accordion_" + projectNumber + "'>" + 
			"<h3>Project Information</h3><div><p>" +
			"<h4>Project Number</h4>" + projectNumber +
			"<h4>Project Owner</h4>" + projectOwner + 
			"<h4>Overview</h4><span id="+projectID+"_description>" + projectDescription + "</span> <a class='btn btn-mini btn-primary' href='javascript:showEditProjectDescriptionDialog("+projectID+")'><i class='icon-pencil icon-white'></i></a>" + 
			"<h4>Project Billing Code</h4><span id="+projectID+"_billingCode>" + projectBillingCode + "</span> <a class='btn btn-mini btn-primary' href='javascript:showEditProjectBillingCodeDialog("+projectID+")'><i class='icon-pencil icon-white'></i></a>" + 
			"<h4>Project Client Name</h4><span id="+projectID+"_clientName>" + projectClientName + "</span> <a class='btn btn-mini btn-primary' href='javascript:showEditProjectClientNameDialog("+projectID+")'><i class='icon-pencil icon-white'></i></a>" + 
			"<h4>Project Timeframe</h4><span id="+projectID+"_timeFrame>" + projectTimeframe + "</span> <a class='btn btn-mini btn-primary' href='javascript:showEditProjectTimeFrameDialog("+projectID+")'><i class='icon-pencil icon-white'></i></a>" + 
			"</p></div>" 
			
			+
			
			milestoneHTML 
			
			+
			
			commentHTML
			
			+
			
			"</div></div>");
			
			$("#accordion_"+projectNumber).accordion({heightStyle: "content", collapsible: true });
		});
		
		// Save global project list
		$("#projectIDString").val(projectsList);
	})
	.fail(function(){
		console.log("fail...");
	});
};

function closeProcessingDialog(id){
	$('#processing-dialog').dialog('close');
};

function closeDialog(id){
	$('#'+id).dialog('close');
};

function updateLoggedInLink(userName, userID) {
	var userLoginButton = 
	"<div class='btn-group'>" +
	
	  "<a class='btn btn-primary' href='#'><i class='icon-user icon-white'></i> "+userName+"</a>" +
	  "<a class='btn btn-primary dropdown-toggle' data-toggle='dropdown' href='#'><span class='caret'></span></a>" +
	  "<ul class='dropdown-menu'>" +
		"<li><a href='javascript:showUserProfile()'><i class='icon-pencil'></i> Edit</a></li>" +
		"<li class='divider'></li>" +
		"<li><a href='javascript:logout()'><i class='icon-ban-circle'></i> Logout</a></li>" +
	  "</ul>" +
	"</div>";
	$("#header-logged-in-user").html(userLoginButton + "<input id='logged-in-user-id' type='hidden'>");
	$("#logged-in-user-id").val(userID);
};

function showEditProjectDescriptionDialog(projectID) {
	var oldDescription = $("#"+projectID+"_description").text();
	
	$("#edit-project-description-dialog textarea").val(oldDescription);
	$("#edit-project-description-dialog").dialog({
		modal:true,
		title: "Edit Project Descrption",
		width: 320,
		height: 250,
		resizable: false
	});
};

function showEditProjectBillingCodeDialog(projectID) {
	var oldBillingCode = $("#"+projectID+"_billingCode").text();
	
	$("#edit-project-billing-code-dialog input").val(oldBillingCode);
	$("#edit-project-billing-code-dialog").dialog({
		modal:true,
		title: "Edit Project Billing Code",
		width: 320,
		height: 150,
		resizable: false
	});
};

function showEditProjectClientNameDialog(projectID) {
	var oldClientName = $("#"+projectID+"_clientName").text();
	
	$("#edit-project-client-name-dialog input").val(oldClientName);
	$("#edit-project-client-name-dialog").dialog({
		modal:true,
		title: "Edit Project Client Name",
		width: 320,
		height: 150,
		resizable: false
	});
};

function showEditProjectTimeFrameDialog(projectID) {
	var oldTimeFrame = $("#"+projectID+"_timeFrame").text();
	
	$("#edit-project-time-frame-dialog input").val(oldTimeFrame);
	$("#edit-project-time-frame-dialog").dialog({
		modal:true,
		title: "Edit Project Time Frame",
		width: 320,
		height: 150,
		resizable: false
	});
};

function saveProjectDescription() {
	var newValue = $.trim($("#edit-project-description-dialog textarea").val());
	var projectID = $("#projectID").val();
	
	$.post("./jsp/updateProject.jsp", {projectID:projectID, field:"proj_description", newValue:newValue})
		.success(function(resp){
			closeDialog("edit-project-description-dialog");
			// showSuccessDialog("operation-success-dialog", "Project Description Updated");
			animateNewValue(projectID+"_description", newValue);
		});
};

function saveProjectBillingCode() {
	var newValue = $.trim($("#edit-project-billing-code-dialog input").val());
	var projectID = $("#projectID").val();
	
	$.post("./jsp/updateProject.jsp", {projectID:projectID, field:"billing_code", newValue:newValue})
		.success(function(resp){
			closeDialog("edit-project-billing-code-dialog");
			animateNewValue(projectID+"_billingCode", newValue);
		});
};

function saveProjectClientName() {
	var newValue = $.trim($("#edit-project-client-name-dialog input").val());
	var projectID = $("#projectID").val();
	
	$.post("./jsp/updateProject.jsp", {projectID:projectID, field:"client_name", newValue:newValue})
		.success(function(resp){
			closeDialog("edit-project-client-name-dialog");
			animateNewValue(projectID+"_clientName", newValue);
		});
};

function saveProjectTimeFrame() {
	var newValue = $.trim($("#edit-project-time-frame-dialog input").val());
	var projectID = $("#projectID").val();
	
	$.post("./jsp/updateProject.jsp", {projectID:projectID, field:"timeframe", newValue:newValue})
		.success(function(resp){
			closeDialog("edit-project-time-frame-dialog");
			animateNewValue(projectID+"_timeFrame", newValue);
		});
};

function animateNewValue(field, newValue) {
	$("#"+field).fadeOut(500, function(){
		$("#"+field).text(newValue).css("background-color", "green").fadeIn(1000, function(){
			$("#"+field).css("background-color", "")
		});
	});
}

function showSuccessDialog(id, text){
	$("#"+id+" div").text(text);
	$("#"+id).dialog({modal:true, title:"Success"});
};

function logout() {
	$("#confirm-logout-dialog").dialog({
		modal: true,
		title: "Logout",
		resizable: false
	});
}

function continueToLogout() {
	$("#confirm-logout-dialog").fadeOut(500, function(){
		$.post("./jsp/session.jsp", {requestType:"logout"})
			.success(function(){
				location.reload();
			});
	});
};

function confirmDeleteMilestone(milestoneID, milestoneDivID) {

	$("#confirm-delete-milestone-dialog").dialog({
		modal: true,
		title: "Delete",
		resizable: false
	});
	$("#milestoneID").val(milestoneID);
	$("#milestoneDivID").val($.trim(milestoneDivID));
}

function confirmDeleteComment(commentID, commentDivID) {

	$("#confirm-delete-comment-dialog").dialog({
		modal: true,
		title: "Delete",
		resizable: false
	});
	$("#commentID").val(commentID);
	$("#commentDivID").val($.trim(commentDivID));
}

function continueToDeleteMilestone() {
	$.post("./jsp/projectOperation.jsp", {requestType:"delete", table:"milestones", field:"milestone_id", id:$.trim($("#milestoneID").val())})
	.success(function(resp){
		if($.trim(resp)==="success") {
			$("#confirm-delete-milestone-dialog").dialog("close");
			var divID = $("#milestoneDivID").val();
			$("#"+divID).slideUp(500, function(){$("#"+divID).detach()});
		}
	});
};

function continueToDeleteComment() {
	$.post("./jsp/projectOperation.jsp", {requestType:"delete", table:"comments", field:"comment_id", id:$.trim($("#commentID").val())})
	.success(function(resp){
		if($.trim(resp)==="success") {
			$("#confirm-delete-comment-dialog").dialog("close");
			var divID = $("#commentDivID").val();
			$("#"+divID).slideUp(500, function(){$("#"+divID).detach()});
		}
	});
};

function updateMilestoneDialog(id) {
	$("#update-milestone-dialog").dialog({
		modal: true,
		title: "Update Milestone",
		width: 320
	});
	
	var projectID = $("#projectID").val();
	// var milestoneID = $.trim($("#"+id).text());
	
	var milestoneDivID = projectID+"_"+id+"_milestone";
	$("#milestoneID").val(id);
	$("#update-milestone-date").val($("#"+milestoneDivID+"_date").text());
	$("#update-milestone-description").val($("#"+milestoneDivID+"_description").text());
};

function updateCommentDialog(id) {
	$("#update-comment-dialog").dialog({
		modal: true,
		title: "Update Comment",
		width: 320
	});
	
	var projectID = $("#projectID").val();
	
	var commentDivID = projectID+"_"+id+"_comment";
	
	$("#commentID").val(id);
	$("#update-comment-description").val($("#"+commentDivID+"_description").text());
};

function continueToUpdateMilestone() {

	var projectID = $("#projectID").val();
	var milestoneID = $("#milestoneID").val();
	var newDate = $("#update-milestone-date").val();
	var newDescription = $("#update-milestone-description").val();
	
	$.post("./jsp/projectOperation.jsp", {requestType:"update", table:"milestones", milestone_date:newDate, milestone_text:newDescription, milestone_id:milestoneID})
	.success(function(resp){
		if($.trim(resp)==="success") {
			var divID = projectID+"_"+milestoneID+"_milestone";
			$("#update-milestone-dialog").dialog("close");
			animateNewValue(divID+"_date", newDate);
			animateNewValue(divID+"_description", newDescription);
		}
	});
};

function continueToUpdateComment() {

	var projectID = $("#projectID").val();
	var commentID = $("#commentID").val();
	var newDescription = $("#update-comment-description").val();
	
	$.post("./jsp/projectOperation.jsp", {requestType:"update", table:"comments", comment_text:newDescription, comment_id:commentID})
	.success(function(resp){
		if($.trim(resp)==="success") {
			var divID = projectID+"_"+commentID+"_comment";
			$("#update-comment-dialog").dialog("close");
			animateNewValue(divID+"_description", newDescription);
		}
	});
};

function addMilestoneDialog() {
	$("#add-milestone-dialog").dialog({
		modal: true,
		title: "Add Milestone",
		width: 320
	});
}

function addCommentDialog() {
	$("#add-comment-dialog").dialog({
		modal: true,
		title: "Add Comment",
		width: 320
	});
}

function addMilestone() {
console.log("adding mile");
	var userID = $("#logged-in-user-id").val();
	var milestoneDate = $("#add-milestone-date").val();
	var milestoneDescription = $("#add-milestone-description").val();
	var projectID = $("#projectID").val();
	
	$.post("./jsp/projectOperation.jsp", {requestType:"add",table:"milestones",projectID:projectID,milestoneDate:milestoneDate,milestoneDescription:milestoneDescription, enteredBy:userID})
	.success(function(resp){
		if($.trim(resp).split(",")[0]==="success") {
		
			$("#add-milestone-dialog").dialog("close");
			var newGeneratedMilestoneID = $.trim(resp).split(",")[1];

			var newMilestoneDivID = projectID+"_"+newGeneratedMilestoneID+"_milestone";
			var newMilestoneDateDivID = newMilestoneDivID + "_date";
			var newMilestoneDescriptionDivID = newMilestoneDivID + "_description";
			
			var author = $.trim(resp).split(",")[2];
			
			var newMilestoneDiv = "<div class='itemBox' id='"+newMilestoneDivID+"'>" + 
				"<h4>Milestone Date</h4><span id='"+newMilestoneDateDivID+"'>" + milestoneDate + "</span>" +
				"<h4>Description</h4><span id='"+newMilestoneDescriptionDivID+"'>" + milestoneDescription + "</span>" +
				"<h4>Author</h4>" + author +
				"<button class='btn btn-primary btn-mini itemOpButton' onclick='confirmDeleteMilestone(\""+newGeneratedMilestoneID+"\",\""+newMilestoneDivID+"\")'><i class='icon-trash icon-white'></i> Del</button>"+
				"<span class='itemOpButton'>&nbsp;&nbsp;</span>" +
				// "<button class='btn btn-primary btn-mini itemOpButton' onclick='updateMilestoneDialog(\""+newGeneratedMilestoneID+"\",\""+milestoneDate+"\",\""+milestoneDescription+"\")'><i class='icon-pencil icon-white'></i> Edit</button>"+
				"<button class='btn btn-primary btn-mini itemOpButton' onclick='updateMilestoneDialog(\""+newGeneratedMilestoneID+"\")'><i class='icon-pencil icon-white'></i> Edit</button>"+
				"</div>";
			var currentProjectNumber = $.trim($("#currentProjectNumber_"+projectID).val());
			$("#ui-accordion-accordion_"+currentProjectNumber+"-panel-1 p:first-child").after(newMilestoneDiv);
			$("#"+newMilestoneDivID).hide().slideDown(500);
		}
	});
};

function addComment() {

	var userID = $("#logged-in-user-id").val();
	var commentDescription = $("#add-comment-description").val();
	var projectID = $("#projectID").val();
	
	$.post("./jsp/projectOperation.jsp", {requestType:"add",table:"comments",projectID:projectID,commentDescription:commentDescription, enteredBy:userID})
	.success(function(resp){
		if($.trim(resp).split(",")[0]==="success") {
		
			$("#add-comment-dialog").dialog("close");
			var newGeneratedCommentID = $.trim(resp).split(",")[1];

			var newCommentDivID = projectID+"_"+newGeneratedCommentID+"_comment";
			var newCommentDescriptionDivID = newCommentDivID + "_description";
			
			var author = $.trim(resp).split(",")[2];
			var commentDate = $.trim(resp).split(",")[3];
			
			var newCommentDiv = "<div class='itemBox' id='"+newCommentDivID+"'>" + 
				"<h4>Comment Date</h4>" + commentDate  +
				"<h4>Description</h4><span id='"+newCommentDescriptionDivID+"'>" + commentDescription + "</span>" +
				"<h4>Author</h4>" + author +
				"<button class='btn btn-primary btn-mini itemOpButton' onclick='confirmDeleteComment(\""+newGeneratedCommentID+"\",\""+newCommentDivID+"\")'><i class='icon-trash icon-white'></i> Del</button>"+
				"<span class='itemOpButton'>&nbsp;&nbsp;</span>" +
				// "<button class='btn btn-primary btn-mini itemOpButton' onclick='updateCommentDialog(\""+newGeneratedCommentID+"\",\""+commentDescription+"\")'><i class='icon-pencil icon-white'></i> Edit</button>"+
				"<button class='btn btn-primary btn-mini itemOpButton' onclick='updateCommentDialog(\""+newGeneratedCommentID+"\")'><i class='icon-pencil icon-white'></i> Edit</button>"+
				"</div>";
			var currentProjectNumber = $.trim($("#currentProjectNumber_"+projectID).val());
			$("#ui-accordion-accordion_"+currentProjectNumber+"-panel-2 p:first-child").after(newCommentDiv);
			$("#"+newCommentDivID).hide().slideDown(500);
		}
	});
};