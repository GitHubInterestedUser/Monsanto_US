
	<%-- $Revision: 2144 $ --%>
	<%-- $Date: 2012-06-22 02:12:46 -0700 (Fri, 22 Jun 2012) $ --%>
	<%-- $HeadURL: http://steelscm.domain.steelwedge.com:90/svn/sppm/releases/5.4.1Release/build/efmcore/src/online/app/catalog_detail.jsp $ --%>
 <!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.0  strict//EN">

<%--
  Title:        Catalog_Detail
  Description:  Presents the Catalog Detail page.

  This page may use DHTML to produce calendar pop-up and multiple select options,
  but this is unclear at the moment..

  The context request parameter is applied to the filter, but I am unclear why.

  The filterID request parameter needs to be included on the Search page.
  It is controlled through personalization (which may be "sticky" -- the
  last used filterID is reused until a new filter is applied), and through
  the use of the Filter dialog.

  Request Parameters:
    context:      catalog.  Required.

  Note that the Internet Explorer-specific showModelessDialog() function
  is used to present the Filter page.  The vArguments parameter of the
  showModelessDialog() function is used to pass parameters to the
  javascript on this page. These are available in this page's window
  as dialogArguments.

  dialogArguments Parameters:
    caller:       the document that opened this window.  Used to
                  access javascript and DHTML objects in the caller's
                  object environment.

  Author: agjerde
  Version:  $Version: $
  - Permission objects:
  -     All permission objects have the permission_object.type value "UICONTROL".
  -     These permission_object.object_pk values are present on the page:
  -             CATALOG_UPDATE

--%>
<meta http-equiv="X-UA-Compatible" content="IE=EmulateIE7" >    
<meta http-equiv="X-UA-Compatible" content="IE=6; IE=7">
<meta http-equiv="Content-Type" content="text/html;charset=UTF-8">
<%@ taglib uri="http://jakarta.apache.org/taglibs/request-1.0" prefix="req" %>
<%@ page import="com.steelwedge.web.auth.EFMAuthentication"%>
<%@ page import="com.steelwedge.web.efm.User" %>
<%@ page import="com.steelwedge.user.EFMUserException" %>
<%@ page import="com.steelwedge.user.PermissionObjectVO" %>
<%@ page import="com.steelwedge.util.Config" %>
<%@ page import="com.steelwedge.util.I18n" %>
<%@ page import="com.steelwedge.util.Log" %>
<%@ page import="com.steelwedge.web.efm.PermissionHelper" %>
<%@ page import="com.steelwedge.web.util.WebConstants" %>
<%@ page import="java.util.*" %>
<%@ page import="java.net.*" %>
<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<!--<jsp:useBean id="encodingHelper" class="com.steelwedge.web.efm.EncodingHelper" scope="page"/>-->


<%--
    Set up the filterCriteria.  Note that this is just to have access to a set
    of constants for the filter operators.
--%>
<%!
    private static Log log = new Log(__catalog_detail.class);
	ResourceBundle messages;

    private Set getGrantedObjects(User user)
            throws EFMUserException {
        PermissionHelper ph = new PermissionHelper();
        Set result = ph.getGrantedObjectPks(user, "UICONTROL");
    //  diagnostic
        StringBuffer sb = new StringBuffer(1024);
        String delim = "";
        sb.append("userId: ").append(user.getUserId()).append(" ");
        Iterator i = result.iterator();
        while (i.hasNext()) {
            sb.append(delim).append((String)i.next());
            delim = ", ";
        }
        log.debug(sb.toString());
    //  end diagnostic
        return result;
    }
%>

<%
request.setCharacterEncoding("UTF-8");
    User user = User.getInstance(request);
    Set grantedObjects = getGrantedObjects(user);

   // encodingHelper.setSelectedLocale((String)session.getAttribute("selectedLocale"));
	//encodingHelper.setSelectedCountry((String)session.getAttribute("selecteCountry"));

    String strType = request.getParameter("Type");
    int temp=0;
    String description="";
    String skuid="";
    String itemid="";
  
   if(request.getParameter("Temp")!=null && request.getParameter("Desc")!=null && request.getParameter("Sku")!=null){
	  String strTemp =request.getParameter("Temp");
	  description=request.getParameter("Desc");
	  skuid=request.getParameter("Sku");
	  itemid=request.getParameter("itemid");
	  temp=Integer.parseInt(strTemp);
  
  }
  String permission = "";
  if (grantedObjects.contains("CATALOG_UPDATE")) {
  	permission = "true";
  }
  else {
  	permission = "false";
  }

    messages = (ResourceBundle)session.getAttribute("resourceBundle");
	String logo  = messages.getString("0_logo_sm_key2");
	String close = messages.getString("buttonaction_close_key2");
	String addnew = messages.getString("buttonaction_addnew_key2");
	String save = messages.getString("buttonaction_save_key2");
    String closewidth = messages.getString("catalog_detail_close_width_key3");
	String closeheight = messages.getString("catalog_detail_close_height_key3");
	String savewidth = messages.getString("catalog_detail_save_width_key3");
	String saveheight = messages.getString("catalog_detail_save_height_key3");
	String changeStatusValue="Change "+ strType.substring(0,1).toUpperCase() + strType.substring(1) + " Status";

%>
<html>
<head>
<!--<meta http-equiv="Content-Type" content="<%=encodingHelper.getEncodingTechnique()%>"/>-->
<title><%=messages.getString("detail")%></title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link rel="stylesheet" type="text/css" href="/app/css/mc_css.css"/>
<script type="text/javascript" src="/app/javascript/mc_util.js"></script>
<script type="text/javascript" src="/app/javascript/tabpane.js"></script>
<link type="text/css" rel="stylesheet" href="/app/css/luna/tab.css" id="luna-tab-style-sheet" />
<link rel="stylesheet" type="text/css" href="/app/css/mc_css.css">
<link rel="stylesheet" type="text/css" href="/app/css/permission.css">
<script type="text/javascript" src="/app/javascript/mc_util.js"></script>

<link href="/app/css/style_main.css" rel="stylesheet" type="text/css" />
<link href="/app/css/ajstabs.css" rel="stylesheet" type="text/css" />
<script src="/app/javascript/jquery-1.2.6.js" type="text/javascript"></script>
<script src="/app/javascript/ui.core.js" type="text/javascript"></script>
<script src="/app/javascript/ui.tabs.js" type="text/javascript"></script>
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
<script language="JavaScript">
	var theTop = top.dialogArguments.caller;
	var target = top.dialogArguments.target;
	var param = top.dialogArguments.param;
	var pkString = param;
	var datadirty = false;
	var datadirty2 = false;
	var typeToPass = "";
	var isNew = false;
	var separator = "<%= WebConstants.MULTI_PART_DELIMITER %>";

	//alert("param: " + param);
	if(param == "pk=0")
	top.document.title = '<%=messages.getString("catalog_detail_CreateTemporaryItem")%>';
	else 
	top.document.title = '<%=messages.getString("catalogDetailPage")%>';
    top.document.onclick=top.dialogArguments.caller.doc_click;
	top.name = 'cat_detail';
	function window_onload() {
	    if(param == "pk=0")
	    document.getElementById('pageTitle').innerHTML='<%=messages.getString("catalog_detail_CreateTemporaryItem")%>';
		else
		document.getElementById('pageTitle').innerHTML='<%=messages.getString("catalog_detail_CatalogDetailPage")%>';
        //alert('Type = <%=strType%>');
		//alert("target = " + target);
		if (param == "pk=0") {
			isNew = true;
		}

		if ("<%=strType.toLowerCase()%>" == "item") {
			typeToPass = "product/ITEM";
		}
		else if ("<%=strType.toLowerCase()%>" == "bom") {
			typeToPass = "product/BOM";
		}
		else if ("<%=strType.toLowerCase()%>" == "sbom") {
			typeToPass = "product/SBOM";
		}
		else if ("<%=strType.toLowerCase()%>" == "forecaststructure") {
			typeToPass = "product/FORECASTSTRUCTURE";
		}
		else if ("<%=strType.toLowerCase()%>" == "phantom") {
			typeToPass = "product/PHANTOM";
		}
		else {
			typeToPass = "<%=strType%>";
		}
		//alert('<%=strType%>');
		document.fraDetail.location.href = target + "?" + param + "&table=Summary&type=" + typeToPass + '&permission=<%=permission%>';

		document.fraAttributes.location.href = target + "?" + param + "&table=Attributes&type=" + typeToPass + '&permission=<%=permission%>';
		if (param == "pk=0" || "<%=strType%>" == "ITEM" || "<%=strType%>" == "item"
		   || "<%=strType%>" == "business" || "<%=strType%>" == "business"
		   || "<%=strType%>" == "geography" || "<%=strType%>" == "geography"
		    || "<%=strType%>" == "market" || "<%=strType%>" == "market"
		    || "<%=strType%>" == "asset" || "<%=strType%>" == "Asset"
			|| "<%=strType%>" == "Customer" || "<%=strType%>" == "customer"
		   || "<%=strType%>" == "Sold_to" || "<%=strType%>" == "sold_to"
		    || "<%=strType%>" == "Segment" || "<%=strType%>" == "segment"
			|| "<%=strType%>" == "Region" || "<%=strType%>" == "region"
      || "<%=strType%>" == "Inventory_org" || "<%=strType%>" == "inventory_org"
	  || "<%=strType%>" == "RCU" || "<%=strType%>" == "rcu"
		   ) { //new item or non-assembly item edit..

			tabPane1.style.display='none';
			tabPane2.style.display='';
		}
		else { //existing item
			tabPane1.style.display='';
			tabPane2.style.display='none';

			//alert("in onload.. " + target + "?" + param + "&table=Components&type=&parentDesc=&parentType=<%=strType%>&permission=");
			document.fraComponents.location.href = target + "?" + param + "&table=Components&type=&parentDesc=&parentType=<%=strType%>&permission=";
		}

		if (param == "pk=0") {
			idButtons.style.display = 'none';
			idButtonsNew.style.display = '';
			if (document.getElementById('idActions')) {
    			idActions.style.display = 'none';
				idNonProductActions.style.display = 'none';
				actionDivState = 'none';
				nonActionDivState = 'none';
    		}
		}
		else if  ( "<%=strType%>" == "business" || "<%=strType%>" == "business"
		    || "<%=strType%>" == "geography" || "<%=strType%>" == "geography"
		    || "<%=strType%>" == "market" || "<%=strType%>" == "market"
		    || "<%=strType%>" == "asset" || "<%=strType%>" == "asset"
			|| "<%=strType%>" == "Customer" || "<%=strType%>" == "customer"
		   || "<%=strType%>" == "Sold_to" || "<%=strType%>" == "sold_to"
		    || "<%=strType%>" == "Segment" || "<%=strType%>" == "segment"
			|| "<%=strType%>" == "Region" || "<%=strType%>" == "region"
      || "<%=strType%>" == "Inventory_org" || "<%=strType%>" == "inventory_org"
	   || "<%=strType%>" == "RCU" || "<%=strType%>" == "rcu"
		   ) {
			idButtons.style.display = 'none';
			idButtonsNew.style.display = '';
			if (document.getElementById('idActions')) {
    			idActions.style.display = 'none';
				idNonProductActions.style.display = '';
				actionDivState = 'none';
				nonActionDivState = '';
    		}
		}
		else {
			idButtons.style.display = '';
			idButtonsNew.style.display = 'none';
			if (document.getElementById('idActions')) {
    			idActions.style.display = '';
				idNonProductActions.style.display = 'none';
				actionDivState = '';
				nonActionDivState = 'none';
    		}
		}
	}


	function onSave() {
		//str = "Save these values for ";
		if (datadirty == false) {
			//datadirty = true;
			//Populate all values in iframe in arrays..
			var nameArray = new Array();
			var valueArray = new Array();
			var oldNameArray = new Array();
			var oldValueArray = new Array();
			var updateNameArray = new Array();
			var updateValueArray = new Array();
			var updateTypeArray = new Array();
			var oldTypeArray = new Array();
			var typeArray = new Array();
			var oldLabelNameArray = new Array();
			var oldLabelArray = new Array();
			var oldRequiredArray = new Array();
			var updateLabelArray = new Array();
			var updateRequiredArray = new Array();
			var leafLabelValue = "";
			var hierarchyType = "";

			str = "";
			//summary section
			for (i=0; i< document.fraDetail.document.detailForm.length; i++) {
				if (document.fraDetail.document.detailForm.elements[i].name == "HIERARCHY_LEAF.IS_FORECASTED") {
					if (document.fraDetail.document.detailForm.elements[i].checked == true) {
						document.fraDetail.document.detailForm.elements[i].value = 1;
					}
					else {
							document.fraDetail.document.detailForm.elements[i].value = 0;
					}
				}

				nameArray[i] = document.fraDetail.document.detailForm.elements[i].name;
				valueArray[i] = document.fraDetail.document.detailForm.elements[i].value;
				typeArray[i] = document.fraDetail.document.detailForm.elements[i].size;
			}

			if (nameArray.length > 0)
				j = nameArray.length;
			else
				j = 0;

			//attribute section..
			for (i=0; i< document.fraAttributes.document.detailForm.length; i++) {
				if (document.fraAttributes.document.detailForm.elements[i].name == "HIERARCHY_LEAF.IS_FORECASTED") {
					if (document.fraAttributes.document.detailForm.elements[i].checked == true) {
						document.fraAttributes.document.detailForm.elements[i].value = 1;
					}
					else {
							document.fraAttributes.document.detailForm.elements[i].value = 0;
					}
				}

				nameArray[j] = document.fraAttributes.document.detailForm.elements[i].name;
				valueArray[j] = document.fraAttributes.document.detailForm.elements[i].value;
				typeArray[j] = document.fraAttributes.document.detailForm.elements[i].size;
				j++;
			}

			//alert(str);

			//Find values provided from server and put in arrays..
			var j = 0;
			var m =0;
			for (i=0; i < nameArray.length;i++) {
				tmpName = nameArray[i];
				if (tmpName.substring(0,3) == "hdn") {
					oldNameArray[j] = tmpName.substring(3,tmpName.length);
					oldValueArray[j] = valueArray[i];
					oldTypeArray[j] = typeArray[i];
					//str += oldNameArray[j] + " = " + oldValueArray[j] + "\n";
					j++;
				}
				if (tmpName.substring(0,3) == "lbl") {
					oldLabelNameArray[m] = tmpName.substring(3,tmpName.length);
					oldLabelArray[m] = valueArray[i];
					oldRequiredArray[m] = typeArray[i];
					m++;
				}
			}
			//alert("label array length=" + oldLabelNameArray.length + "  0=" + oldLabelNameArray[0] + "  4=" + oldLabelNameArray[4]);
			itemId = oldValueArray[0];
			periodId = oldValueArray[1];
			effPeriodId = oldValueArray[2];

			var k = 0;
			for (i=0; i< nameArray.length; i++) {
				if (nameArray[i] == 'HIERARCHY_TYPE') {
					hierarchyType = valueArray[i];
				}
				for (j=0; j< oldNameArray.length;j++) {
					if (nameArray[i] == oldNameArray[j] && nameArray[i] != 'HIERARCHY_TYPE') {
						if (valueArray[i] != oldValueArray[j]) {
							//the following are the values we want to update or insert..
							updateNameArray[k] = nameArray[i];
							updateValueArray[k] = valueArray[i];
							updateTypeArray[k] = oldTypeArray[j];
							for (n=0;n<oldLabelNameArray.length;n++) {
								if (oldLabelNameArray[n] == nameArray[i]) {
									updateLabelArray[k] = oldLabelArray[n];
									updateRequiredArray[k] = oldRequiredArray[n];
									//alert("updateLabelArray[" + k + "]=" + updateLabelArray[k] + " requiredVal=" + updateRequiredArray[k] + " updateValueArray=" + updateValueArray[k]);
									break;
								}
							}

							//value existed and is now empty, then throw an error
							if (valueArray[i] == "") {
								top.mcwarn('<%=messages.getString("warning")%>'+":",updateLabelArray[k] + ' <%=messages.getString("cannotbeempty")%>');
								datadirty = false;
								return;
							}

							//validate entries against their data type
							passValidation = true;
							if (updateValueArray[k] != "" && updateValueArray[k] != null && updateNameArray[k] != "HIERARCHY_LEAF.IS_FORECASTED") {
								passValidation = false;
								//alert(updateTypeArray[k]);
								switch (updateTypeArray[k]) {
									case 1: //number
										if (isNumeric(updateValueArray[k])) {
												passValidation = true;
										}
										else {
											top.mcwarn('<%=messages.getString("warning")%>'+":",updateLabelArray[k] + ' <%=messages.getString("requiresavalidnumericentry")%>');
											datadirty = false;
										}
										break;
									case 2: //string
										//alert("matching string..");
										if (updateNameArray[k] == "ASSEMBLY_TYPE_CD" && pkString == "pk=0") {
											//alert(updateValueArray[k]);
											leafLabelValue = updateValueArray[k];
											var leafLabelArray = leafLabelValue.split("/");
											if (leafLabelArray[1]) {
													leafLabelValue = leafLabelArray[1];
											}
											updateValueArray[k] = leafLabelValue;
											//alert("leafLabelValue = " + leafLabelValue);
										}
										passValidation = true;
										break;
									case 3: //datetime
										//alert(updateValueArray[k]);
										if (top.isDate(updateValueArray[k])) { //TODO: This needs to be more flexible, currently only accepted format is mm/dd/yy..
												passValidation = true;
										}
										else {
											top.mcwarn('<%=messages.getString("warning")%>'+":",updateLabelArray[k] + '<%=messages.getString("catalog_detail_requiresavaliddate")%>');
											datadirty = false;
											return;
										}
										break;
/*									case "4": //boolean
										if (updateValueArray[k] != 0 && updateValueArray[k] != 1) {
												top.mcwarn("Warning:",updateNameArray[k] + " requires a boolean value, i.e., 0 (false) or 1 (true).");
												datadirty = false;
										}
										else {
											passValidation = true;
										}

										break;
*/
									case 5: //datetime
										//alert(updateValueArray[k]);
										if (top.isDate(updateValueArray[k])) { //TODO: This needs to be more flexible, currently only accepted format is mm/dd/yy..
												passValidation = true;
										}
										else {
											top.mcwarn('<%=messages.getString("warning")%>'+":",updateLabelArray[k] + '<%=messages.getString("catalog_detail_requiresavaliddate")%>');
											datadirty = false;
											return;
										}
										break;
									default: //no matching data type..

										top.mcwarn('<%=messages.getString("warning")%>'+":",updateLabelArray[k] + '<%=messages.getString("hasanunknowndatatype.")%>');
										datadirty = false;
										break;
								}
								if (passValidation == false) {
									return;
								}
							}

							if (k == 0) {
								nameStr = updateNameArray[k];
								valueStr = updateValueArray[k];
								typeStr = updateTypeArray[k]
							}
							else {
								nameStr += separator + updateNameArray[k];
								valueStr += separator + updateValueArray[k];
								typeStr += separator + updateTypeArray[k];
							}
							k++;
						}
					}
				}
			}

			tmpRatioFlagNone=false;
			tmpRatioFlagValue=false;
			tmpRatioSum = 0;
			tmpRatioSumFQ = 0;
/*			for (i=0; i< document.fraAttributes.document.detailForm.length; i++) {
				tmpName = document.fraAttributes.document.detailForm.elements[i].name;
				if ("HIERARCHY_LEAF.NUMERIC" == tmpName.substring(0,22)) {
					tmpNumber = tmpName.substring(23,tmpName.length);
					if (tmpNumber-0 >= 10 && tmpNumber-0 <= 22) {
						if (document.fraAttributes.document.detailForm.elements[i].value != "") {
							tmpRatioFlagValue = true;
							tmpRatioValue = document.fraAttributes.document.detailForm.elements[i].value-0;
							tmpRatioSum = tmpRatioSum + tmpRatioValue;
						}
						else {
							tmpRatioFlagNone = true;
						}
					}
					else if (tmpNumber-0 >= 23) {
						if (document.fraAttributes.document.detailForm.elements[i].value != "") {
							tmpRatioFlagValue = true;
							tmpRatioValue = document.fraAttributes.document.detailForm.elements[i].value-0;
							tmpRatioSumFQ = tmpRatioSumFQ + tmpRatioValue;
						}
						else {
							tmpRatioFlagNone = true;
						}
					}
				}
			}
			if (tmpRatioFlagNone == true && tmpRatioFlagValue == true) {
				top.mcwarn("Warning:", "Some of the weekly ratio values are blank. These value must all be filled in, or none at all.");
				datadirty = false;
				return
			}
			else if (tmpRatioFlagValue == true && tmpRatioSum != 100) {
				top.mcwarn("Warning:", "The sum of the Current Quarter weekly ratios add up to " + tmpRatioSum + "%. These values must add up to exactly 100%.");
				datadirty = false;
				return
			}
			else if (tmpRatioFlagValue == true && tmpRatioSumFQ != 100) {
				top.mcwarn("Warning:", "The sum of the Future Quarters weekly ratios add up to " + tmpRatioSumFQ + "%. These values must add up to exactly 100%.");
				datadirty = false;
				return
			}
*/
			if (k == 0) {
				if (isNew == true) {
					top.mcwarn('<%=messages.getString("warning")%>'+":", '<%=messages.getString("catalogdetailkey1")%>');
					datadirty = false;
					return;
				}
				else {
					top.close();
				}
			}
			else {
			//	alert(nameStr + "  " + valueStr + "  " + typeStr);

				var param = new Object();
				param.caller = top;

				//validation of required fields
				for (k=0;k<nameArray.length;k++) {
					for (n=0;n<oldLabelNameArray.length;n++) {
						if (nameArray[k] == oldLabelNameArray[n]) {
						//alert("nameArray[" + k + "] = " + nameArray[k] + "  updateReq=" + oldRequiredArray[n] + "  value=" + valueArray[k]);
							if (oldRequiredArray[n] == "1" && valueArray[k] == "") {
								top.mcwarn('<%=messages.getString("warning")%>'+":",'<%=messages.getString("catalogdetailkey1")%>');
								datadirty = false;
								return;
							}
						}
					}
				}

				if (pkString == "pk=0") { //new item
					if (hierarchyType == "product/ITEM" || hierarchyType == "product/SBOM" || hierarchyType == "product/BOM") {
						isFcstString=separator + "HIERARCHY_LEAF.IS_FORECASTED";
						isFcstValue=separator + "1";
						isFcstTpe=separator + "1";
					}
					else {
						isFcstString="";
						isFcstValue="";
						isFcstTpe="";
					}
				 //   alert('insert../efm/SubmitCatalog?context=catalog&hierarchyType=' + hierarchyType + '&subcontext=newItem&' + pkString + '&effectivePeriodId=' + effPeriodId + '&periodId=' + periodId + '&nameString=' + nameStr + isFcstString + '&valueString=' + valueStr + isFcstValue +'&typeString=' + typeStr + isFcstTpe);
					submitwin = showModalDialog('/efm/SubmitCatalog?context=catalog&hierarchyType=' + hierarchyType + '&subcontext=newItem&' + pkString + '&nameString=' + nameStr + isFcstString + '&valueString=' + encodeURIComponent(valueStr) + isFcstValue + '&typeString=' + typeStr + isFcstTpe, param,'dialogHeight: 150px; dialogWidth: 300px; dialogTop: px; dialogLeft: px; center: Yes; help: No; resizable: No; status: No; scroll: No' );
				}
				else { //update
					//alert('/efm/SubmitCatalog?context=catalog&hierarchyType=<%=strType%>&subcontext=edit&' + pkString + '&nameString=' + nameStr + '&valueString=' + valueStr + '&typeString=' + typeStr);
					submitwin = showModalDialog('/efm/SubmitCatalog?context=catalog&hierarchyType=<%=strType%>&subcontext=edit&' + pkString + '&nameString=' + nameStr + '&valueString=' + encodeURIComponent(valueStr) + '&typeString=' + typeStr, param,'dialogHeight: 150px; dialogWidth: 300px; dialogTop: px; dialogLeft: px; center: Yes; help: No; resizable: No; status: No; scroll: No' );
				}


			}
		}
	}

	function changeView(val)
	{
		if (val == 'general')
		{
			if (param == "pk=0") {
			}
			else{
			idGeneral.style.display='';
            idActions.style.display= actionDivState;
			idNonProductActions.style.display = nonActionDivState;
			idComponents.style.display='none';
			}
		}
		else if (val == 'components')
		{
			idGeneral.style.display='none';
            idActions.style.display='none';
			idNonProductActions.style.display = 'none';
			idComponents.style.display='';
		}
	}

	function checkTabClick()
	{
		if (event.srcElement.url)
		{
			eval(event.srcElement.url);
		}
	}

	function AddEditComponent(oTR)
	{
		var assemblyId = "";
		parentType = "";
		parentDesc = "";
		parentSKU = "";
		for (i=0;i< document.fraDetail.document.detailForm.length;i++) {
			if (document.fraDetail.document.detailForm.elements[i].name == "hdnHIERARCHY_LEAF.DESCRIPTION") {
				parentDesc = document.fraDetail.document.detailForm.elements[i].value;
			}
			if (document.fraDetail.document.detailForm.elements[i].name == "hdnASSEMBLY_TYPE_CD") {
				parentType = document.fraDetail.document.detailForm.elements[i].value;
			}
			if (document.fraDetail.document.detailForm.elements[i].name == "hdnHIERARCHY_LEAF.LEAF_LABEL") {
				parentSKU = document.fraDetail.document.detailForm.elements[i].value;
			}

		}

		//alert("parentSKU=" + parentSKU + "  parentType=" + parentType + " " + pkString);
		if (parentType == 'SBOM') {
			var ch;
			for (var i = 0; i < pkString.length; i++) {
				ch = pkString.substr(i, 1);
				if (ch == '=') {
					parentPK = pkString.substring(i+1,pkString.length);
					break;
				}
			}

			top.openComponentSearch(top,'multiple',parentPK);
		}
		else { //BOM
			top.onAddEditComponent(pkString, 'newAssembly', assemblyId,'','','','1','0',encodeURIComponent(parentDesc),parentType,encodeURIComponent(parentSKU),top);
		}
	}

	function onView() {
		var param = new Object();
		param.caller = top;
		param.title = '<%=messages.getString("catalog_detail_ViewRelationships")%>';
		browsewin = showModalDialog('/efm/RelationshipView?' + pkString, param,'dialogHeight: 760px; dialogWidth: 960px; dialogTop: px; dialogLeft: px; center: Yes; help: No; resizable: No; status: No; scroll: Yes;' );

	}
	function onTemporary(){
		var param = new Object();
		param.caller = top;
		param.title = '<%=messages.getString("catalog_detail_EditTemporaryItem")%>';
		browsewin = showModalDialog('/efm/Temporary?SKUId='+encodeURIComponent('<%=skuid%>')+'&SKUDesc='+encodeURIComponent('<%=description%>')+'&strType=<%=strType%>&itemid=<%=itemid%>', param,'dialogHeight: 300px; dialogWidth: 520px; dialogTop: px; dialogLeft: px; center: Yes; help: No; resizable: No; status: No; scroll: Yes;' );
	}


	function onAddRelationships()
	{
		if (datadirty2 == false) {
			//datadirty2 = true;
			parentDesc="";
			parentType="";
			parentSKU= "";
			var discValue = "";
			if (document.fraDetail.document.detailForm) {
				for (i=0;i< document.fraDetail.document.detailForm.length;i++) {
					if (document.fraDetail.document.detailForm.elements[i].name == "hdnHIERARCHY_LEAF.DESCRIPTION") {
						parentDesc = document.fraDetail.document.detailForm.elements[i].value;
					}
					if (document.fraDetail.document.detailForm.elements[i].name == "hdnASSEMBLY_TYPE_CD") {
						parentType = document.fraDetail.document.detailForm.elements[i].value;
					}
					if (document.fraDetail.document.detailForm.elements[i].name == "hdnHIERARCHY_LEAF.LEAF_LABEL") {
						parentSKU = document.fraDetail.document.detailForm.elements[i].value;
					}
					if (document.fraDetail.document.detailForm.elements[i].name == "SWStatus") {
						discValue = document.fraDetail.document.detailForm.elements[i].value;
					}
				}

				//alert("pkString=" + pkString + "pDesc=" + parentDesc + "  ptype=" + parentType);
				top.AddRelationship(pkString, parentDesc, parentType, parentSKU, 720,discValue);
			}
			else {
				top.mcwarn('<%=messages.getString("warning")%>'+':', '<%=messages.getString("catalogdetailkey3")%>');
				datadirty2 = false;
			}
		}
	}

	function onViewRefRelationships()
	{
		if (datadirty2 == false) {
			//datadirty2 = true;
			parentDesc="";
			parentType="";
			parentSKU= "";
			if (document.fraDetail.document.detailForm) {
				for (i=0;i< document.fraDetail.document.detailForm.length;i++) {
					if (document.fraDetail.document.detailForm.elements[i].name == "hdnHIERARCHY_LEAF.DESCRIPTION") {
						parentDesc = document.fraDetail.document.detailForm.elements[i].value;
					}
					if (document.fraDetail.document.detailForm.elements[i].name == "hdnASSEMBLY_TYPE_CD") {
						parentType = document.fraDetail.document.detailForm.elements[i].value;
					}
					if (document.fraDetail.document.detailForm.elements[i].name == "hdnHIERARCHY_LEAF.LEAF_LABEL") {
						parentSKU = document.fraDetail.document.detailForm.elements[i].value;
					}
				}

				//alert("pkString=" + pkString + "pDesc=" + parentDesc + "  ptype=" + parentType);
				top.ViewReferenceRelationships(pkString, parentDesc, parentType, parentSKU);
			}
			else {
				top.mcwarn('<%=messages.getString("warning")%>'+":", '<%=messages.getString("catalogdetailkey3")%>');
				datadirty2 = false;
			}
		}
	}

	function afterSubmit(errorFlag,errorMsg) {
		//alert("in afterSubmit..");
		if (errorFlag != null) {
			if (errorFlag == 'true') {
				top.mcwarn('<%=messages.getString("warning")%>'+":", errorMsg);
				datadirty = false;
				datadirty2 = false;
				return;
			}
		}
		if (param != "pk=0") {
			top.close();
			thetop.focus();
		}
		else {
			datadirty = false;
			datadirty2 = false;
			//re-populates screen if create temporary..
			document.fraDetail.location.href = target + "?pk=0&table=Summary&type=product/ITEM";
			document.fraAttributes.location.href = target + "?pk=0&table=Attributes&type=product/ITEM";
		}
	}

	function refreshSummary() {
		document.fraDetail.location.href = target + "?" + param + "&table=Summary&type=" + typeToPass;
	}


	function refreshComponents() {
		//alert("in refreshComponents..");
		document.fraComponents.location.href = target + "?" + param + "&table=Components&type=&parentDesc=&parentType=<%=strType%>";
	}

	function onEditStatus() {
		try{
		var param = new Object();
		var isDisc;
		param.caller = top;
		param.title = 'Change Status';
		if (document.fraDetail.document.detailForm) {
			for (i=0; i< document.fraDetail.document.detailForm.length; i++) {
				if (document.fraDetail.document.detailForm.elements[i].name == "SWStatus") {
						isDisc = document.fraDetail.document.detailForm.elements[i].value;
				}
				if (document.fraDetail.document.detailForm.elements[i].name == "HIERARCHY_LEAF.IS_FORECASTED") {
					if (document.fraDetail.document.detailForm.elements[i].checked == true) {
						isFcst = 1;
					}
					else {
						isFcst = 0;
					}
				}
				if (document.fraDetail.document.detailForm.elements[i].name == "hdnHIERARCHY_LEAF.LEAF_LABEL") {
					product = document.fraDetail.document.detailForm.elements[i].value;
				}
			}
			//product isDisc  isFcst
			//alert('/efm/CatalogStatus?' + pkString + '&product='+product+'&isDisc='+isDisc+'&isFcst='+isFcst);


			browsewin = showModalDialog('/efm/CatalogStatus?' + pkString + '&product='+encodeURIComponent(product)+'&isDisc='+isDisc+'&isFcst=&prodType=<%=strType%>' , param,'dialogHeight: 360px; dialogWidth: 460px; dialogTop: px; dialogLeft: px; center: Yes; help: No; resizable: No; status: No; scroll: Yes;' );
		}
		else {
			top.mcwarn('<%=messages.getString("warning")%>'+":", '<%=messages.getString("catalogdetailkey3")%>');
			datadirty2 = false;
		}
		}catch(error){}
	}

</script>
</head>

	<body style=" background-color:#ffffff;" onload='window_onload()' >
  <form name="pageForm">
<table width="100%" border="0" align="center"  cellpadding="0" cellspacing="0">
  <tr>
    <td valign="top"><table width="100%" border="0" cellspacing="0" cellpadding="0">
      <tr>
        <td width="2%" valign="top" style="padding-left:10px"><img src="/app/images/logo.jpg" width="178" height="84" title="Steelwedge Software" /></td>
        <td width="96%">
		<table width="100%" border="0" cellspacing="0" cellpadding="0">
            <tr>
              <td valign="top" id="pageTitle" class="tophead">Catalog Detail Page</td>
            </tr>
           
        </table></td>

        <td width="2%" valign="top" style="padding-top:5px;padding-right:10px"></td>
      </tr>
    </table></td>
  </tr>
  <tr>
    <td valign="top" height="100%"><!-- Tab Content Start-->
		<div id="container-1">
		  <table width="100%" border="0" align="center" cellpadding="0" cellspacing="0">
  <tr>
    <td width="67%" valign="top" id="toptab"><!-- Main Tab Start -->
		<div id="tabPane1" ><ul> <li class="current"><a  href="#idGeneral" onClick="changeView('general')" ><span><%=messages.getString("general")%></span></a></li>
								<li><a  href="#idComponents" onClick="changeView('components')"><span><%=messages.getString("components")%></span></a></li></div>
		<div id="tabPane2"><ul>	<li><a  href="#idGeneral" onClick="changeView('general')" class="current"><span><%=messages.getString("general")%></span></a></li></ul></div>	
       
	<!-- Main Tab End -->	</td>
  
  </tr>
</table>

		  
		  <!-- Tab Containt Table Start -->
		  <table width="100%" border="0" align="center" cellpadding="0" cellspacing="0">
  <tr>
    <td valign="top">
	<!-- General Content Start -->

	<fieldset style="width:470px;height:160px;float:center;padding:5px;margin-left:10px">
	  <legend class="fsheader"><%=messages.getString("itemSummary")%>:</legend>
	  <table border="0" cellpadding="2" cellspacing="0" width="100%">
		<tr><td align="center">
			<iframe name="fraDetail" class="iframe1" src="/app/blank.htm" width="100%" height="140px" frameborder="0" scrolling="no"></iframe>
		</td></tr>
	  </table>
	</fieldset>
		  <div id="idGeneral" style="display:'block'">
		<fieldset style="width:460px;height:250px;float:center;padding:10px;margin-left:10px">
		<legend class="fsheader"><%=messages.getString("attributes")%>:</legend>
	  <table align="center" border="0" cellpadding="2" cellspacing="0" width="100%" height="50px">
		<tr><td>
			<iframe name="fraAttributes" class="iframe1" src="/app/blank.htm" width="100%" height="230px" frameborder="0"></iframe>
		</td></tr>
	  </table>
	</fieldset>
	</div><!-- General End -->	</td>
  </tr>
  <tr>
    <td valign="top">
	<!-- Actions Content Start -->
	<div id="idActions" style="display:'none';">
		<fieldset style="width:460px;height:80px;float:center;padding:10px;margin-left:10px;padding-bottom:30px">
		<legend class="fsheader"><%=messages.getString("actions")%>:</legend>
	  <table align="center" border="0" cellpadding="2" cellspacing="0" width="100%" height="100%">
		<tr><td><a href="#" onclick="onAddRelationships()"><%=messages.getString("createorViewRelationships")%></a></td></tr>
		<tr><td><a href="#" onclick="onViewRefRelationships()"><%=messages.getString("editorViewMultiLeafAttributes")%></a></td></tr>

		 <%if(temp==1)
	         {
		%>

         <tr><td><button style="FONT-WEIGHT: normal;FONT-SIZE: 9pt;COLOR: #333333;FONT-FAMILY: Arial;;background-color:transparent;border-style:none;cursor:hand;width:132px" onClick="onTemporary( )"><u><%=messages.getString("editTemporaryItem")%></u></button></td></tr>
<%  }
    if (grantedObjects.contains("CATALOG_UPDATE") && grantedObjects.contains("STATUS_BUTTON")) {
      //if (false) {
%>
		<tr><td><a href="#" onclick="onEditStatus()"><%=messages.getString("changeProductStatus")%></a></td></tr>
<%
    }
%>
	  </table>
	</fieldset>
							</div>
					
	<!-- Non Product Actions Content Start -->
	<div id="idNonProductActions" style="display:'none';">
		<fieldset style="width:460px;height:80px;float:center;padding:10px;margin-left:10px;padding-bottom:30px">
		<legend class="fsheader"><%=messages.getString("actions")%>:</legend>
	  <table align="center" border="0" cellpadding="2" cellspacing="0" width="100%" height="100%">
	
<%  
    if (grantedObjects.contains("CATALOG_UPDATE") && grantedObjects.contains("STATUS_BUTTON")) {
      //if (false) {
%>
		<tr><td><a href="#" onclick="onEditStatus()"><%=changeStatusValue%></a></td></tr>
<%
    }
%>
	  </table>
	</fieldset>
	</div>
	 <!--Non Product Actions Content End -->
	
	</td>
  </tr>
  
  <tr>
    <td valign="top">
	<!-- Components Content Start -->
	<div id="idComponents" style="display:'none'">
		<fieldset style="width:460px;height:330px;float:center;padding:10px;margin-left:10px;padding-bottom:30px">
		<legend class="fsheader"><%=messages.getString("components")%>:</legend>
		<table align="center" border="0" cellpadding="2" cellspacing="0" width="100%" height="87%">
		  <tr><td>
			<span id="loadingComp" style="display:''" class="important_text"><%=messages.getString("loadingcomponents")%></span>
			<iframe name="fraComponents" src="/app/blank.htm" class="iframe1" width="100%" height="87%" frameborder="0"></iframe>
		  </td></tr>
	  </table>
	  <br>
 	<%
	  if (grantedObjects.contains("CATALOG_UPDATE")) {
	  
	%>
	  	<img src='<%= addnew%>' style="cursor:hand" alt='<%=messages.getString("addComponent")%>' onClick="AddEditComponent(null);" width='<%=messages.getString("admin_template_addnew_width_key3")%>' height='<%=messages.getString("admin_template_addnew_height_key3")%>' ONDRAGSTART="return false">
	<%
	  }
	%>
	</fieldset>
	<!-- Components Content End -->	</td>
  </tr>
 
</table>
		  <!-- Tab Containt Table End -->
</div>
</div><!-- Tab Content End --></td>
  </tr>
 
    </table></td>
  </tr>

</table>
	<br>
	<table id="idButtons" style="display:none" border="0" cellpadding="0" width="100%" cellspacing="5">
	  <tr>
	    <td align="right" colspan="2" style="padding-right:10px">
		    	<img src='<%= close %>' border="0" style="cursor:hand" alt='<%=messages.getString("cancelandCloseScreen")%>' onClick="top.close()" width='<%=closewidth %>' height='<%=closeheight %>' ONDRAGSTART="return false">
		    <%
				if (grantedObjects.contains("CATALOG_UPDATE")) {
			%>
				<img src='<%= save%>'border="0" style="cursor:hand" alt='<%=messages.getString("saveChanges")%>' onClick="onSave()" width='<%=savewidth %>' height='<%=saveheight %>' ONDRAGSTART="return false">
			<%
				}
			%>
		</td>
  	  </tr>
	</table>
		<table id="idButtonsNew" style="display:none" border="0" cellpadding="0" width="100%" cellspacing="5">
	  <tr>
	    <td style="padding-left:3px">

	    </td>
	    <td align="right" colspan="2" style="padding-right:10px">
		    	<img src='<%= close %>' border="0" style="cursor:hand" alt='<%=messages.getString("closeScreen")%>' onClick="top.close()" width='<%=closewidth%>' height='<%=closeheight%>' ONDRAGSTART="return false">
		    <%
				if (grantedObjects.contains("CATALOG_UPDATE")) {
			%>
		    	<img src='<%= save%>' border="0" style="cursor:hand" alt='<%=messages.getString("saveNewProduct")%>' onClick="onSave()" width='<%=savewidth %>' height='<%=saveheight %>' ONDRAGSTART="return false">
			<%
				}
			%>
		</td>
  	  </tr>
	</table>

</form>
</body>


</html>
