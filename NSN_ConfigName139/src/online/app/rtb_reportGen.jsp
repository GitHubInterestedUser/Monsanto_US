<%@page import="com.steelwedge.poi.POIReportHandlerFactory"%>
<%@page import="com.steelwedge.poi.RTBReportHandler"%>
<%@page import="com.steelwedge.poi.GenericReportHandler"%>
<%@page import="com.steelwedge.poi.SPPMPOIException" %>
<%@page import="com.steelwedge.poi.POISQLBeanReportHandler"%>
<%@page import="com.steelwedge.web.efm.User"%>
<%@page import="java.util.*"%>
<%@page import="java.io.*"%>

<%
ResourceBundle messages;
messages = (ResourceBundle)session.getAttribute("resourceBundle");
String logo = messages.getString("0_logo_sm_key3");
String reportName = request.getParameter("reportName");
System.out.println("in rtb gen report reportName :" + reportName);

User user = User.getInstance(request);
Integer accessControlFilterId = user.getAccessControlFilterId();

GenericReportHandler reph= (GenericReportHandler)POIReportHandlerFactory.getInstance().getReportHandler(reportName,null,accessControlFilterId,null,null);
//RTBReportHandler reph= (RTBReportHandler)POIReportHandlerFactory.getInstance().getReportHandler(reportName,null,null,null,null);
//template = reph.getGeneratedReport();

System.out.println("in rtb gen report handler instance :" + reph);

String template = reph.getGeneratedReport();
System.out.println("in rtb gen report template :" + template);

String fileName = template;
System.out.println("fileName :" + fileName);

String folderPath = "applications/steelwedge/app/POIReports/generated/" + reportName ;

System.out.println("folderPath :" + folderPath);

String fullPath= folderPath + "/" + fileName;

System.out.println("fullPath :" + fullPath);
File fp = new File(fullPath);
%>
	
<html>
<head>
<script language="JavaScript" src="/app/javascript/mc_util.js"></script>

<script type="text/javascript">

var thetop = top.dialogArguments.caller.dialogArguments.caller.thetop;

function setBusy(busyOn){
	top.dialogArguments.caller.setBusy(busyOn);
}

setBusy(false); 

function downloadFile(fileName){
	if('<%=fp.exists()%>' == "true"){
			document.rptform.folderPath.value = '<%=folderPath%>';
			document.rptform.action = "/downloadFile?fileName="+fileName;
			document.rptform.submit();
	}
	else{
		 top.mcalert('warning','<%=messages.getString("warning")%>','File Does not exists.','bg_ok',300,200,'');
	 }
}
</script>
</head>
<body>
<form name="rptform" method="post" target="_self">
<input type="hidden" name="folderPath" />
<table border="0" cellpadding="0" cellspacing="0" width="100%">
	  <tr>
	  <td width="2%" valign="top" style="padding-left:10px"><img src="/app/images/logo.jpg" width="178" height="84" title="Steelwedge Software"  onClick="document.getElementById('elapsedTimeTr').style.visibility='visible';"/></td>
	  <td align="left" width="40%" nowrap><b>Download Reports</b></td>
	   <td width="20%"></td>
	  <td width="2%" valign="top" style="padding-top:10px;padding-right:10px"><img src="/app/images/company_logo.gif" /></td>
	  </tr>
</table>
<table height="30">
<tr>
<td></td>
</tr>
</table>
<table border="0" width="100%">
<tr>
<td width="33%" align="center"><u onclick="downloadFile('<%=fileName%>')"><%=reportName%></u></td>
<td width="33%"></td>
<td width="33%"></td>
</tr>
</table>
</form>
</body>
</html>