
	<%-- $Revision: 1997 $ --%>
	<%-- $Date: 2012-06-15 17:10:28 +0530 (Fri, 15 Jun 2012) $ --%>
	<%-- $HeadURL: http://steelscm.domain.steelwedge.com:90/svn/sppm/releases/5.4.2Release/build/efmcore/src/online/app/submit_selected_template_email.jsp $ --%>
<%@ page import="java.util.*" %>
<%@ page import="com.steelwedge.web.efm.User" %>
<%@ page import="com.steelwedge.util.Config" %>

<%@ page contentType="text/html; charset=UTF-8" %>
<%!
    

    private String[] stringToArray(String s) {
        StringTokenizer st = new StringTokenizer(s, ",");
        int count = st.countTokens();
        String[] result = new String[count];
        // Break into tokens!
        int k = 0;
        while(st.hasMoreTokens()) {
            String t = st.nextToken();
            result[k] = (t.equalsIgnoreCase("undefined")) ? null : t;
            k++;
        }
        return result;
    }

%>


<jsp:useBean id="itemListHelper" class="com.steelwedge.web.efm.ItemListHelper" scope="page"/>
<jsp:useBean id="encodingHelper" class="com.steelwedge.web.efm.EncodingHelper" scope="page"/>

<%
    request.setCharacterEncoding("UTF-8");
	String users = request.getParameter("userArray");
	String templateLabel = request.getParameter("templateLabelArray");
	users = users.replace("!@@!","&");
	templateLabel = templateLabel.replace("!@@!","&");
	String[] userArray = stringToArray(users);
	String[] templateLabelArray = stringToArray(templateLabel);
	ResourceBundle messages;
    messages = (ResourceBundle)session.getAttribute("resourceBundle");
	encodingHelper.setSelectedLocale((String)session.getAttribute("selectedLocale")); 
	encodingHelper.setSelectedCountry((String)session.getAttribute("selecteCountry")); 
	String displayMessage = messages.getString("messagesSenttoselectedUsers");
	if(new Boolean(Config.get("scheduling.send.mail", "false")).booleanValue())
	itemListHelper.notifySelectedUsers(userArray,templateLabelArray);
	else
	displayMessage = displayMessage;
	

   
    //encodingHelper.setSelectedLocale((String)session.getAttribute("selectedLocale"));
	//encodingHelper.setSelectedCountry((String)session.getAttribute("selecteCountry"));
%>

<html>
<head>
<!--<meta http-equiv="Content-Type" content="<%=encodingHelper.getEncodingTechnique()%>"/>--> 
	<script>
	function window_onload(){
		startClock();
	}
	var x = 2 //3
		var y = 1
		 
		function startClock(){
			x = x-y
			document.pageForm.clock.value = x
		   setTimeout("self.close()", 1000)
			if(x==0){
				
				top.close(); 
			}
		}

		//window.close();
	</script>
	</head>
	<body onload='window_onload()'>
		<form name="pageForm">
			<br>
			<br>
			<INPUT TYPE="hidden" NAME="clock" SIZE=4 >

			<table align="center" width="100%" border=0>
									<td align="center" class="normaltext"><b><%=displayMessage%></b></td>
				
				
				</tr>
				
			</table>
			<br>
			
		</form>
	</body>
</html>