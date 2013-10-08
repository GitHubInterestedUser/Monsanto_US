
	<%-- $Revision: 127 $ --%>
	<%-- $Date: 2012-02-08 01:30:56 -0800 (Wed, 08 Feb 2012) $ --%>
	<%-- $HeadURL: http://steelscm.domain.steelwedge.com:90/svn/sppm/releases/5.4.1Release/build/efmcore/src/online/app/view_reference_relationships.jsp $ --%>
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">

<%--
  Title:        view reference relationships
  skuDescription:  Presents the view reference relatioship page.


  Author: Paul Koivula
  Version:  $Version: $
--%>

<%@ taglib uri="http://jakarta.apache.org/taglibs/request-1.0" prefix="req" %>
<%@ page import="com.steelwedge.web.auth.EFMAuthentication"%>
<%@ page import="com.steelwedge.web.efm.User" %>
<%@ page import="com.steelwedge.user.EFMUserException" %>
<%@ page import="com.steelwedge.catalogmanager.CatalogNodeSpecification" %>
<%@ page import="com.steelwedge.util.Config" %>
<%@ page import="com.steelwedge.util.I18n" %>
<%@ page import="com.steelwedge.util.Log" %>
<%@ page import="com.steelwedge.web.efm.CatalogReferenceAttributesViewHelper" %>
<%@ page import="com.steelwedge.web.efm.CatalogViewHelperException" %>
<%@ page import="com.steelwedge.web.util.WebConstants" %>
<%@ page import="java.util.*" %>

<%!
    ResourceBundle messages;
    private static Log log = new Log(__view_reference_relationships.class);
    
    private String itemPK = null;
    private String itemId = null;
    private Integer accessControlFilterId = null;
    
    private String companyReferencePK = null;
    private String siteReferencePK = null;
    
    private String formatCompany() {
    
        CatalogReferenceAttributesViewHelper cravh = new CatalogReferenceAttributesViewHelper();
        cravh.setReferencePK(companyReferencePK);
        cravh.setAnchorHierarchyClassId(Integer.valueOf("1"));// product
        cravh.setAccessControlFilterId(accessControlFilterId);
        
        cravh.setAnchorItemId(Integer.valueOf(itemId));
        cravh.setAnchorItem();
        Collection relationships = null;
        try {
            relationships = cravh.getReferenceRelationships();
        } catch (CatalogViewHelperException cvhe) {
           log.error(cvhe.getMessage());
			String exceptionMessage = (cvhe.getMessage()).substring(cvhe.getMessage().indexOf(':')+1,cvhe.getMessage().length());
            return exceptionMessage;
        }
        
        StringBuffer sb = new StringBuffer(1024);
        // prepare the table header
        sb.append("<table id='custRelationsData' border='0' width='100%' cellpadding='3' cellspacing='0' style='margin-top:10px;margin-bottom:15px'>\n")
          .append("<tr><td class='tableheadercell'>").append(messages.getString("view_reference_relationships_CompanyId")).append("</td><td class='tableheadercell'>").append(messages.getString("view_reference_relationships_CompanyDescription")).append("</td>");
        Iterator e = relationships.iterator();
        while (e.hasNext()) {
            // one row for each relationship
            StringBuffer rowBuffer = new StringBuffer (256);
            rowBuffer.append("<tr valign='top' onclick='selectRow(this);event.cancelBubble=true' onDblClick='dblClick(this);event.cancelBubble=true' referencePK='" + companyReferencePK + "'");
            
            Set nodes = (Set)e.next();
            Iterator cols = nodes.iterator();
            int index = 1;
            StringBuffer colBuffer = new StringBuffer (256);
            while (cols.hasNext()) {
                CatalogNodeSpecification colNode = (CatalogNodeSpecification)cols.next();
                String pk = colNode.getItemId().toString();
                rowBuffer.append("hier").append(colNode.getHierarchyClassId()).append("Id").append("='").append(pk).append("' ");
                rowBuffer.append("hier").append(colNode.getHierarchyClassId()).append("LeafLabel").append("='").append(colNode.getLeafLabel()).append("' ");

                if (index == 1) {  // do not display prodcut info in the row
                    index++;
                    continue;
                }
                colBuffer.append("<td width='165px' class='normaltext' title='hier").append(colNode.getHierarchyClassId()).append("Id=").append(pk).append("'>").append(colNode.getLeafLabel()).append("</td>")
                         .append("<td width='265px' class='normaltext'>").append(colNode.getDescription()).append("</td>\n");
                index++;
            }
            
            rowBuffer.append(" class='row_off' onMouseOver='this.className=\"row_on\"' onMouseOut='this.className=\"row_off\"'>\n");

            sb.append(rowBuffer).append(colBuffer);
            sb.append("</tr>\n");
        }
        sb.append("</table>");
        
        log.debug("sb buffer" + sb.toString());
        return new String(sb);
    }

    private String formatSite() {
    
        CatalogReferenceAttributesViewHelper cravh = new CatalogReferenceAttributesViewHelper();
        cravh.setReferencePK(siteReferencePK);
        cravh.setAnchorHierarchyClassId(Integer.valueOf("1"));// product
        cravh.setAccessControlFilterId(accessControlFilterId);
        
        cravh.setAnchorItemId(Integer.valueOf(itemId));
        cravh.setAnchorItem();
        Collection relationships = null;
        try {
            relationships = cravh.getReferenceRelationships();
        } catch (CatalogViewHelperException cvhe) {
            log.error(cvhe.getMessage());
            return cvhe.getMessage();
        }
        
        StringBuffer sb = new StringBuffer(1024);
        // prepare the table header
        sb.append("<table id='custRelationsData' border='0' width='100%' cellpadding='3' cellspacing='0' style='margin-top:10px;margin-bottom:15px'>\n")
          .append("<tr><td class='tableheadercell'>").append(messages.getString("view_reference_relationships_SiteId")).append("</td><td class='tableheadercell'>").append(messages.getString("view_reference_relationships_SiteDescription")).append("</td>");
        Iterator e = relationships.iterator();
        while (e.hasNext()) {
            // one row for each relationship
            StringBuffer rowBuffer = new StringBuffer (256);
            rowBuffer.append("<tr valign='top' onclick='selectRow(this);event.cancelBubble=true' onDblClick='dblClick(this);event.cancelBubble=true' referencePK='" + siteReferencePK + "'");
            
            Set nodes = (Set)e.next();
            Iterator cols = nodes.iterator();
            int index = 1;
            StringBuffer colBuffer = new StringBuffer (256);
            while (cols.hasNext()) {
                CatalogNodeSpecification colNode = (CatalogNodeSpecification)cols.next();
                String pk = colNode.getItemId().toString();
                rowBuffer.append("hier").append(colNode.getHierarchyClassId()).append("Id").append("='").append(pk).append("' ");
                rowBuffer.append("hier").append(colNode.getHierarchyClassId()).append("LeafLabel").append("='").append(colNode.getLeafLabel()).append("' ");

                if (index == 1) {  // do not display prodcut info in the row
                    index++;
                    continue;
                }
                colBuffer.append("<td width='165px' class='normaltext' title='hier").append(colNode.getHierarchyClassId()).append("Id=").append(pk).append("'>").append(colNode.getLeafLabel()).append("</td>")
                         .append("<td width='265px' class='normaltext'>").append(colNode.getDescription()).append("</td>\n");
                index++;
            }
            
            rowBuffer.append(" class='row_off' onMouseOver='this.className=\"row_on\"' onMouseOut='this.className=\"row_off\"'>\n");

            sb.append(rowBuffer).append(colBuffer);
            sb.append("</tr>\n");
        }
        sb.append("</table>");
        
        log.debug("sb buffer" + sb.toString());
        return new String(sb);
    }

%>

<%  //encodingHelper.setSelectedLocale((String)session.getAttribute("selectedLocale"));
	//encodingHelper.setSelectedCountry((String)session.getAttribute("selecteCountry"));
    messages = (ResourceBundle)session.getAttribute("resourceBundle");
    itemPK = request.getParameter("pk");
    String[] pkParts = itemPK.split(":");
    itemId = pkParts[0];
    String skuDescription = request.getParameter("skuDescription");
    String type = request.getParameter("type");
    String skuLeafLabel = request.getParameter("skuLeafLabel");
    User user = User.getInstance(request);
    accessControlFilterId = new Integer(user.getAccessControlFilterId());
	String logo  = messages.getString("0_logo_sm_key2");
    String close = messages.getString("buttonaction_close_key2");
    String open  = messages.getString("buttonaction_open_key2");
	
    
    CatalogReferenceAttributesViewHelper ch = new CatalogReferenceAttributesViewHelper();
    Collection referencePKs = ch.getReferencePKs();
    int numberOfReferences = referencePKs.size();
    Iterator iter = referencePKs.iterator();
    while (iter.hasNext()) {
        String referencePK = (String)iter.next();
        log.debug("ReferencePK: " + referencePK);
        //if (referencePK.indexOf("CUST") >= 0) {
            companyReferencePK = referencePK;
       /* }
        if (referencePK.indexOf("SITE") >= 0) {
            siteReferencePK = referencePK;
        } */
    }
    
    String errorMessage = "";
%>
<%@ page contentType="text/html; charset=UTF-8" %>
<html>

<head>

<title><%=messages.getString("view_reference_relationships_productRelationships")%></title>
<link rel="stylesheet" type="text/css" href="/app/css/mc_css.css">
<link href="/app/css/style_main.css" rel="stylesheet" type="text/css" />
<link href="/app/css/ajstabs.css" rel="stylesheet" type="text/css" />
<script src="/app/javascript/jquery-1.2.6.js" type="text/javascript"></script>
<script src="/app/javascript/ui.core.js" type="text/javascript"></script>
<script src="/app/javascript/ui.tabs.js" type="text/javascript"></script>
<script type="text/javascript" src="/app/javascript/mc_util.js"></script>
<script type="text/javascript">
<!--
$(function() {
                $('#container-1 ul').tabs();
            });

function MM_swapImgRestore() { //v3.0
  var i,x,a=document.MM_sr; for(i=0;a&&i<a.length&&(x=a[i])&&x.oSrc;i++) x.src=x.oSrc;
}

function MM_preloadImages() { //v3.0
  var d=document; if(d.images){ if(!d.MM_p) d.MM_p=new Array();
    var i,j=d.MM_p.length,a=MM_preloadImages.arguments; for(i=0; i<a.length; i++)
    if (a[i].indexOf("#")!=0){ d.MM_p[j]=new Image; d.MM_p[j++].src=a[i];}}
}

function MM_findObj(n, d) { //v4.01
  var p,i,x;  if(!d) d=document; if((p=n.indexOf("?"))>0&&parent.frames.length) {
    d=parent.frames[n.substring(p+1)].document; n=n.substring(0,p);}
  if(!(x=d[n])&&d.all) x=d.all[n]; for (i=0;!x&&i<d.forms.length;i++) x=d.forms[i][n];
  for(i=0;!x&&d.layers&&i<d.layers.length;i++) x=MM_findObj(n,d.layers[i].document);
  if(!x && d.getElementById) x=d.getElementById(n); return x;
}

function MM_swapImage() { //v3.0
  var i,j=0,x,a=MM_swapImage.arguments; document.MM_sr=new Array; for(i=0;i<(a.length-2);i+=3)
   if ((x=MM_findObj(a[i]))!=null){document.MM_sr[j++]=x; if(!x.oSrc) x.oSrc=x.src; x.src=a[i+2];}
}
//-->
</script>
<STYLE>
.waitmsg {font-family: Tahoma; font-size: 10pt; color: gray; font-weight:bold;}
.row_on_alt {
	COLOR: #333333;
	FONT-WEIGHT: normal;
	FONT-SIZE: 9pt;
	FONT-FAMILY: Arial;
	CURSOR: hand;
	BACKGROUND-COLOR: #EFEFEF;
}
.row_off_alt {
	COLOR: #333333;
	FONT-WEIGHT: normal;
	FONT-SIZE: 9pt;
	FONT-FAMILY: Arial;
	BACKGROUND-COLOR: #ccffcc;
}
</STYLE>

<script language="JavaScript">
    var thetop;
    if (top.dialogArguments) {
	var thetop = top.dialogArguments.caller.thetop;
    } else {
        thetop = top;
    }
    var rowhighlight = '#D8EDF9';
    var curselection = null;
   
    var hierPK = new Array();
    var hierLeafLabel = new Array();
    var referencePK = null;
    
    for (count=0; count < 5; count++) {
        hierPK[count] = null;
        hierLeafLabel[count] = null;
    }
    
    
	function selectedTab() {
	    if (tabPage1.style.display=='none') {
	        return 'customer'
	    } else {
   	        return 'com'
	    }
	}
    function changeView(val) {
        for (count=0; count < 5; count++) {
            hierPK[count] = null;
            hierLeafLabel[count] = null;
        }
	    
        if (curselection) {
            curselection.style.backgroundColor = '';
        }
        if (val == 'com') {
	    idCompany.style.display='';
           // idSite.style.display='none';
        } else if (val == 'customer') {
       	    idCompany.style.display='none';
          //  idSite.style.display='';
        }
    }

    function checkTabClick() {
        if (event.srcElement.url) {
            eval(event.srcElement.url);
        }
    }


    function selectRow(oTr) {
        if (curselection) {
            curselection.style.backgroundColor = '';
        }
        curselection = oTr;
        curselection.style.backgroundColor = rowhighlight;
        hierPK[0] = curselection.hier1Id;
        hierPK[1] = curselection.hier2Id;
        hierPK[2] = curselection.hier3Id;
        hierPK[3] = curselection.hier4Id;
        hierPK[4] = curselection.hier5Id;
        
        hierLeafLabel[0] = curselection.hier1LeafLabel;
        hierLeafLabel[1] = curselection.hier2LeafLabel;
        hierLeafLabel[2] = curselection.hier3LeafLabel;
        hierLeafLabel[3] = curselection.hier4LeafLabel;
        hierLeafLabel[4] = curselection.hier5LeafLabel;
        
        referencePK = curselection.referencePK;
        
    }
    
    function dblClick(oTr) {
        selectRow(oTr);
        editClick();
    }
    
    function editClick() {
        
        if (hierPK[1] == null && hierPK[2] == null && hierPK[3] == null && hierPK[4] == null) {
			mcinfo('info','<%=messages.getString("view_reference_relationships_Thereisnoreferencerelationshipselected")%>');
        } else {
            type = selectedTab();
            openEditWindow('update', type, hierPK, hierLeafLabel);
        }
    }

    function openEditWindow(mode, type, PK, leafLabel) {
        var param = new Object();
        param.caller = top;
        param.type = type;
        param.changed = false;
        param.title = '<%=messages.getString("reference_attributes_ProductMultileafattributes")%>';
        
        var paramPK = '';
        var paramLeafLabel = '';
        for (count=0; count < 5; count++) {
            if (PK[count] == "undefined" || PK[count] == null) {
                paramPK = paramPK + ":";
                paramLeafLabel = paramLeafLabel+ "|";
            } else {
                paramPK = paramPK + ":" + PK[count];
                paramLeafLabel = paramLeafLabel+ "|" + leafLabel[count];
            }
        }
        
        var queryString = "?type=" + type + "&action=" + mode;
        if (paramPK != null) {
            queryString = queryString.concat("&pk=" + paramPK + "&referencePK=" + referencePK + "&leafLabel=" + paramLeafLabel);
        }

        target = "/efm/ViewReferenceAttributes";
        editwin = showModalDialog(target + queryString, param, 'dialogHeight: 480px; dialogWidth: 540px; dialogTop: px; dialogLeft: px; center: Yes; help: No; resizable: No; status: No; scroll: No' );
    }

    function post_tab_setup() {
    	changeView(selectedTab());
	if ("<%= errorMessage %>" != "") {
		alert('<%= errorMessage %>');
	}
    }
    window.postTabSetup = post_tab_setup;
    
</script>
<script type="text/javascript" src="/app/javascript/tabpane.js"></script>
<link type="text/css" rel="stylesheet" href="/app/css/luna/tab.css" id="luna-tab-style-sheet" />
</head>
<body  style="background-color:#ffffff;margin:0">
	<form name="pageForm" action="#" target="_self" method="POST">
	<table width="100%" border="0" align="center" cellpadding="0" cellspacing="0">
		<tr>
    <td valign="top"><table width="100%" border="0" cellspacing="0" cellpadding="0">
      <tr>
        <td width="2%" valign="top" style="padding-left:10px"><img src="/app/images/logo.jpg" width="178" height="84" title="Steelwedge Software" /></td>
        <td width="96%">
		<table width="100%" border="0" cellspacing="0" cellpadding="0">
            <tr>
              <td valign="top" id="pageTitle" class="tophead"><%=messages.getString("view_reference_relationships_productRelationships")%></td>
            </tr>
           
        </table></td>

        <td width="2%" valign="top" style="padding-top:10px;padding-right:10px"></td>
      </tr>
    </table></td>
  </tr>
		<table border="0" cellspacing="0" width="100%">
		  	<tr>
		  		<td class="sectiontitle"><div id="idRowCount"></div></td>
			</tr>
		</table>
  <tr>
    <td valign="top" height="100%"><!-- Tab Content Start-->
		<div id="container-1">
          
		  <table width="100%" border="0" align="center" cellpadding="0" cellspacing="0">
  <tr>
    <td width="67%" valign="top" id="toptab">
	 <div id="tabPage1">
	<!-- Main Tab Start -->
	<ul>
				<li><a  href="#idCompany" onClick="changeView('com')"><span><%=messages.getString("view_reference_relationships_Customers")%></span></a></li>
				
          </ul>
	<!-- Main Tab End -->	</td>
  
  </tr>
</table>

		<table width="100%" border="0" cellpadding="2" cellspacing="0" style="margin-top:5px;margin-bottom:5px">
		<tr>
          <td class="fieldlabel" align="right" width="70" nowrap><%=messages.getString("view_reference_relationships_sKUID")%>:</td>
          <td class="normalText" width="400"><%=skuLeafLabel%>&nbsp;/&nbsp;<%=skuDescription%></td>
        </tr>
    </table>
	 <table width="100%" border="0" align="center" cellpadding="0" cellspacing="0">
  <tr>
    <td valign="top">
    			<div id="idCompany" style="display:'none'">
    				<fieldset style="width:100%;float:center;padding:10;margin-left:10px;margin-right:15px">
    					<legend class="fsheader"><%=messages.getString("view_reference_relationships_productCustomerRelationships")%>:</legend>
    					<div id="idCompanyContent" style="overflow-y:auto;height:440px;overflow-x:auto;width:500px">
    					<%= formatCompany() %>
    					</div>
    				</fieldset>
    			</div>
            </div>
         </td>
  </tr>
    	
		<table id="idButtonsNew" border="0" cellpadding="0" width="100%" cellspacing="5">
		  <tr>
			<td style="padding-left:3px">

			</td>
			<td align="right" colspan="2" style="padding-right:10px">
					<img src='<%=open%>' alt='<%=messages.getString("view_reference_relationships_VieworUpdateReferenceAttributes")%>' border="0" style="cursor:hand" onClick="editClick()" width="83" height="19" ONDRAGSTART="return false">
					<img src='<%=close%>' alt='<%=messages.getString("forecasting_actions_CloseScreen")%>' border="0" style="cursor:hand" onClick="top.close()" width='<%=messages.getString("search_butclose_width_key3")%>' height='<%=messages.getString("search_butclose_height_key3")%>' ONDRAGSTART="return false">
			</td>
		  </tr>
		</table>
</form>
</body>
</html>
