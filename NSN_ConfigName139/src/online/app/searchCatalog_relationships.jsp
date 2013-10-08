
	<%-- $Revision: 127 $ --%>
	<%-- $Date: 2012-02-08 01:30:56 -0800 (Wed, 08 Feb 2012) $ --%>
	<%-- $HeadURL: http://steelscm.domain.steelwedge.com:90/svn/sppm/releases/5.4.1Release/build/efmcore/src/online/app/searchCatalog_relationships.jsp $ --%>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.0 Transitional//EN">
<!--
    $Id$
    $HeadURL: http://steelscm.domain.steelwedge.com:90/svn/sppm/releases/5.4.1Release/build/efmcore/src/online/app/searchCatalog_relationships.jsp $
-->
<%--
  Title:        Search
  Description:  Presents the Search page.  This page makes
  extensive use of DHTML to control both browser-resident
  behavior (clicking on a row in the "Search Results"
  copies the row into "Selected Records"), as well as
  handling requests to the server for new Search Results,
  presenting the Open dialog, an Expanded View of the Selected
  Records, and the Filter dialog.

  The context request parameter is applied to search requests, and specifies
  the tables and columns to be returned from the query. The
  context is also used in this JSP to conditionalize content.

  The filterID request parameter is included in Search Results requests.
  It is controlled through personalization (which may be "sticky" -- the
  last used filterID is reused until a new filter is applied), and through
  the use of the Filter dialog.

  The listID request parameter is included in Search Results requests.
  When the user provides the listID through selecting a named list from
  a list of such lists, Search Results will invoke the named list's query.

  Request Parameters:
    context:      one of catalog, forecast, worklist.  Required.
    filterID:     named filter to be applied to search. Optional.
    listID:       named list to be applied to search. Optional.

  Note that the Internet Explorer-specific showModelessDialog() function
  is used to present the Search page.  The vArguments parameter of the
  showModelessDialog() function is used to pass parameters to the
  javascript on this page. These are available in this page's window
  as dialogArguments.

  dialogArguments Parameters:
    caller:       the document that openned this window.  Used to
                  access javascript and DHTML objects in the caller's
                  object environment.
    loadexpanded: controls whether the expanded view is presented first.

  Author: cthomas
  Version:  $Version: $

--%>


<%@ taglib uri="http://jakarta.apache.org/taglibs/request-1.0" prefix="req" %>
<%@ page import="com.steelwedge.web.auth.EFMAuthentication"%>
<%@ page import="com.steelwedge.web.efm.User" %>
<%@ page import="com.steelwedge.util.Config" %>
<%@ page import="com.steelwedge.web.efm.PermissionHelper" %>
<%@ page import="com.steelwedge.user.EFMUserException" %>
<%@ page import="com.steelwedge.user.PermissionObjectVO" %>
<%@ page import="com.steelwedge.hierarchy.HierarchyAttributeVO" %>
<%@ page import="com.steelwedge.web.util.WebConstants" %>
<%@ page import="com.steelwedge.web.efm.UserState" %>
<%@ page import="java.util.*" %>
<%@ page import="com.steelwedge.web.efm.FeatureController" %>
<%@ include file="impl_hierarchy.jsp" %>
<%--
    Set up the SearchCriteria.  Note that this is just to have access to a set
    of constants for the search operators.
--%>
<jsp:useBean id="searchCriteria" class="com.steelwedge.finder.SearchCriteria" scope="page"/>
<jsp:useBean id="userState" class="com.steelwedge.web.efm.UserState" scope="page"/>
<jsp:useBean id="filterViewHelper" class="com.steelwedge.web.efm.FilterViewHelper" scope="page"/>
<jsp:useBean id="efmAuthentication" class="com.steelwedge.web.auth.EFMAuthentication" scope="page"/>
<jsp:useBean id="webConstants" class="com.steelwedge.web.util.WebConstants" scope="page"/>
<jsp:useBean id="filterValueObject" class="com.steelwedge.web.efm.FilterVO" scope="page"/>
<jsp:useBean id="filterConstants" class="com.steelwedge.web.efm.FilterConstants" scope="page"/>
<jsp:useBean id="hierarchyHelper" class="com.steelwedge.web.efm.HierarchyHelper" scope="page"/>
<!--<jsp:useBean id="encodingHelper" class="com.steelwedge.web.efm.EncodingHelper" scope="page"/>-->
<%@ page contentType="text/html; charset=UTF-8" %>
<%!
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
       
    //  end diagnostic
        return result;
    }
%>
<%  
    ResourceBundle messages;
    messages = (ResourceBundle)session.getAttribute("resourceBundle");
	//encodingHelper.setSelectedLocale((String)session.getAttribute("selectedLocale"));
	//encodingHelper.setSelectedCountry((String)session.getAttribute("selecteCountry"));
	String logo = messages.getString("0_logo_sm_key3");
	String companylogo = messages.getString("company_logo_key3");
	String arwrgt2 = messages.getString("arrow_right2_key3"); 
	String addplanitm = messages.getString("add_planning_item_key3"); 
	String butaction = messages.getString("buttonaction_actions_key3"); 
	String hide = messages.getString("hide_key3");
	String show = messages.getString("show_key3");
	String prevrec2 = messages.getString("prevrec2_key3");
	String nextrec2 = messages.getString("nextrec2_key3");
	String butselall = messages.getString("buttonaction_selectall_key3");
	String butcancel = messages.getString("buttonaction_cancel_key3");
	String butsel = messages.getString("buttonaction_select_key3");
	String butclrall = messages.getString("buttonaction_clearall_key3");
	String butcolpvw = messages.getString("buttonaction_collapseview_key3");
	String butexpvw = messages.getString("buttonaction_expandview_key3");
	String butclose = messages.getString("buttonaction_close_key3");
	String butcont = messages.getString("buttonaction_continue_key3");
	String clralcpyfrm = messages.getString("clear_all_copy_from_key3");
    String clralcpyto = messages.getString("clear_all_copy_to_key3");
    String butaddnew = messages.getString("buttonaction_addnew_key3");
	String butapply = messages.getString("buttonaction_apply_key3");
	String butsave = messages.getString("buttonaction_save_key3");
	User user = User.getInstance(request);
    String userId = user.getUserId();
    Set grantedObjects = getGrantedObjects(user);
    String fullName = user.getFullName();
    if (fullName == null) {
        // this should "never" happen...
        fullName = "Fulano de Tal";
    }
    // Properly format the possessive form of the user's full name:
    String possessiveName = fullName.endsWith("s") ? fullName + "'" : fullName + "'s";
	List Hierarchies = getHierarchyClassNames();
	String XMLPath = "";   
	File file = null;
    if(FeatureController.localeSelectOption){
		 XMLPath = "/app/searchValues_"+session.getAttribute("selectedLocale").toString()+"_"+session.getAttribute("selecteCountry").toString()+".xml";
	     file = new File(".\\applications\\steelwedge\\"+XMLPath).getCanonicalFile();
		 if(!file.exists())
		 XMLPath =  "/app/searchValues.xml";
	}else{
		 XMLPath = "/app/searchValues.xml";
	}
%>

<%
    String searchResultsURL = "/efm/SearchCatalogresults?" + request.getQueryString();
    //System.out.println("searchResultsURL coming into search.jsp.. = " + searchResultsURL);
    String context = request.getParameter("context");
    String subcontext = request.getParameter("subcontext");
    String selectedFilter = request.getParameter("info");
    //System.out.println("subcontext="+subcontext+ "   selectedFilter="+selectedFilter);
    String selectedFilter2 = "";
    if (selectedFilter.length() > 8) {
        String tmpFilter = selectedFilter.substring(0,8);
        if (tmpFilter.equals("worklist")) {
            if (selectedFilter.length() > 8) {
                //System.out.println("length=" + selectedFilter.length());
                selectedFilter = selectedFilter.substring(8,selectedFilter.length());
                selectedFilter2 = "worklist";
                //System.out.println(" selectedFilter" + selectedFilter);
            }
            else {
                selectedFilter = "worklist";
                //System.out.println(" selectedFilter" + selectedFilter);
            }
        }
    }

    String listName = request.getParameter("listName");

    String filterListURL = "/efm/FilterList?context=" + context + "&selectedFilterId=0&subcontext=" + subcontext;
    String groupByNameList = "";
    String groupByIdList = "";
    String[] hierarchyName = null;
    Integer[] hierarchyId = null;
    String forecastedHierarchyAttributeName = "";
    //get group by parameters..
    if (context.equalsIgnoreCase("forecast")) {
        Collection groupByList = null;
        HierarchyAttributeVO forecastedHierarchyAttributeVO = hierarchyHelper.getForecastedHierarchyAttribute();
        forecastedHierarchyAttributeName = forecastedHierarchyAttributeVO.getName();

        groupByList = hierarchyHelper.getHierarchyAttributes();
        //System.out.println("getHierarchyAttributes size = " + groupByList.size());

        Iterator iter = groupByList.iterator();
        hierarchyName = new String[groupByList.size()];
        hierarchyId = new Integer[groupByList.size()];
        int index = 0;
        HierarchyAttributeVO attributeValueObject = null;
        while(iter.hasNext()) {
            attributeValueObject = (HierarchyAttributeVO)iter.next();

            hierarchyName[index] = attributeValueObject.getName();
            hierarchyId[index] = attributeValueObject.getHierarchyAttributeId();

            if (index == 0) {
                groupByNameList = hierarchyName[index];
                groupByIdList = ""+hierarchyId[index];
            }
            else {
                groupByNameList += "|" + hierarchyName[index];
                groupByIdList += "|" + hierarchyId[index];
            }
            index++;
        }
        //System.out.println("groupByNameList = " + groupByNameList + " groupByIdList=" + groupByIdList);
    }
    //end group by request

    //user state
    userState.setRequest(request);
    if (context.equalsIgnoreCase("forecast") && subcontext.equalsIgnoreCase("savedFilter")) {
            userState.set("forecast", "forecastFilterName", selectedFilter);
            //System.out.println("set sticky filter to.. " + selectedFilter);
    }


%>
<html>
<head>
<!--<meta http-equiv="Content-Type" content="<%=encodingHelper.getEncodingTechnique()%>"/> -->
<req:equalsParameter name="context" match="forecast">
<title><%=messages.getString("selectedRecordList")%></title>
</req:equalsParameter>
<req:equalsParameter name="context" match="catalog">
<title><%=messages.getString("selectedRecordList")%></title>
</req:equalsParameter>
<req:equalsParameter name="context" match="assembly">
<title><%=messages.getString("selectedRecordList")%></title>
</req:equalsParameter>
<link rel="stylesheet" type="text/css" href="/app/css/mc_css.css">
<script type="text/javascript" src="/app/javascript/tabpane.js"></script>
<script type="text/javascript" src="/app/javascript/mc_util.js"></script>
<link type="text/css" rel="stylesheet" href="/app/css/luna/tab.css" id="luna-tab-style-sheet" />
<xml id="stitchXML" src="<%=XMLPath%>"></xml>
<script language="JavaScript">
        var dArgs = window.dialogArguments;
        var flagCart = true;
		var flagdisplay = true;
        var copyFromDropdownValue ;
		var copyFromLevel;
        var globalOkToClose = false;        <%-- variable is referenced here in search.jsp and in auth/login.jsp to handle onbeforeunload behavior --%>
        var separator = "<%= WebConstants.MULTI_PART_DELIMITER %>";
		var copy = "copyTo";
        if (dArgs == null) {
            dialogArguments = new Object();
            dialogArguments.caller = top;
            dialogArguments.loadexpanded = false;
            dialogArguments.w=1023;
            dialogArguments.h=750;
            dialogArguments.opener='ambassador';
			var selectedRadioButtonValue;
            load_resize(dialogArguments.w, dialogArguments.h);
            top.moveTo(1,1);
        }
		function openSearch(context,loadexpanded,subcontext, info, listname, isAmbassador){
		  var param = new Object();
		  param.caller = thetop;
		  param.loadexpanded=loadexpanded;
		  if (isAmbassador) {
			param.opener = "ambassador";
		  }

		  //alert('/efm/Search?context=' + context + '&subcontext=' + subcontext + '&info=' + info);
		  searchwin = showModalDialog('/efm/SearchCatalogRelationships?context=' + context + '&subcontext=' + subcontext + '&info=' + info + '&listName=' + listname, param,'dialogHeight: 750px; dialogWidth: 1023px; dialogTop: px; dialogLeft: px; center: Yes; help: No; resizable: Yes; status: No; scroll: Yes' );
		  //was: showModelessDialog
		}

		function mcwarnOkCancel(mytitle,mymessage)
			{	//alert("inside mcwarn ok cancel button");
				if (mytitle == null)
				{
					mytitle = '<%=messages.getString("warning")%>'+':';
				}
				top.mcalert('<%=messages.getString("warning")%>',mytitle,mymessage,'<%=messages.getString("searchCatalog_relationships_bg_okcancel")%>',500,210,'sounds/error.wav');
			}
		
		 var displayNameArray = new Array();
        var displayValueArray = new Array();

		function changeShoppingCart(cart){
			//alert("selectedRadioButtonValue  "+selectedRadioButtonValue);
			//alert("111"+datadirty);
			 if (datadirty == true) {
					top.mcwarn('<%=messages.getString("warning")%>'+':','<%=messages.getString("pleasewaitforquerytocomplete")%>');
		

			for(var i=0;i<document.searchForm.copyRadio.length;i++){
				if(document.searchForm.copyRadio[i].value == selectedRadioButtonValue)
					 document.searchForm.copyRadio[i].checked=true;
			}

        return;
      }
      datadirty = false;

	  for(var i=0;i<document.searchForm.copyRadio.length;i++){
			if(document.searchForm.copyRadio[i].checked)
				 selectedRadioButtonValue = document.searchForm.copyRadio[i].value;
		}

			if(cart =='copyTo'){
				fraCopyTo.style.display='';
				selectedCT.style.display='';
				fraCopyFrom.style.display='none';
				selectedCF.style.display='none';
				fraCopyTo.style.width='662';
				fraCopyTo.style.height='130';
				document.all.fraResults.style.height='280px';
				idCopyTo.style.display='';
				idCopyFrom.style.display='none';
				recordsCount.innerHTML = '';
				idShowRelationships.style.display = '';
				clearallCTbtn.style.display='';
				clearallCFbtn.style.display = 'none';
				idDataFilter.style.display='';
				idDtafilterDropDown.style.display='';
				document.searchForm.Display.options[0] = new Option("Product","ALL_SKU");
				document.searchForm.Display.options[1] = null;
				copy='copyTo';
				document.searchForm.searchValue.value="";
				document.fraResults.location.href="/app/blank.htm";
				document.searchForm.searchBy.options[0] = new Option("Sales Item Id","VWPRODUCT_LEAF.LEAF_LABEL");
				document.searchForm.searchBy.options[1] = new Option("Sales Item Desc","VWPRODUCT_LEAF.DESCRIPTION");
				var selectSearchBy = document.getElementsByTagName('select')['searchBy']
				if(selectSearchBy[2]){
				selectSearchBy.removeChild(selectSearchBy[2]);
				selectSearchBy.removeChild(selectSearchBy[2]);
				
				}
			}else if(cart =='copyFrom'){
				
				fraCopyTo.style.display='none';
				selectedCT.style.display='none';
				fraCopyFrom.style.display='';
				fraCopyFrom.style.width='662';
				fraCopyFrom.style.height='130';
				document.all.fraResults.style.height='280px';
				selectedCF.style.display='';
				idCopyTo.style.display='none';
				clearallCFbtn.style.display = '';
				clearallCTbtn.style.display='none';
				idCopyFrom.style.display='';
				idDataFilter.style.display='none';
				idDtafilterDropDown.style.display='none';
				copy='copyFrom';
				recordsCount.innerHTML = '';
				idShowRelationships.style.display = 'none';
				buttongrp_selectall.style.display='none';
				if(flagCart){
					document.searchForm.Display.options[0] = new Option('Detail','detail');
					 /* for (i=0; i< displayNameArray.length;i++) {
					    if ('<%=subcontext%>' != 'findID') {

						document.searchForm.Display.options[1] = new Option(displayNameArray[i],displayValueArray[i]);
									//alert(""+displayNameArray[i]+"                "+displayValueArray[i]);
									break;
					    }
					 } */
					 flagCart = false;
				 }
				else{
					if(copyFromDropdownValue == 'detail'){
					        //alert("detail selected");
						document.searchForm.Display.options[0] = new Option('Detail','detail');
						 /*for (i=0; i< displayNameArray.length;i++) {
						    if ('<%=subcontext%>' != 'findID') {

							document.searchForm.Display.options[1] = new Option(displayNameArray[i],displayValueArray[i]);
										//alert(""+displayNameArray[i]+"                "+displayValueArray[i]);
										break;
					            }
					        }*/
					}
					else{	//alert("product selected");
						for (i=0; i< displayNameArray.length;i++) {
						    if ('<%=subcontext%>' != 'findID') {

							document.searchForm.Display.options[0] = new Option("Product","ALL_SKU");
										//alert(""+displayNameArray[i]+"                "+displayValueArray[i]);
										break;
					    	   }
					
					       }
					       document.searchForm.Display.options[1] = new Option('Detail','detail');
			             }
					
				}
				if(flagdisplay){
					copyFromDropdownValue = document.searchForm.Display.value;
					//alert("copyFromDropdownValue "+copyFromDropdownValue);
					flagdisplay = false;
				}
				 document.searchForm.searchValue.value="";
				document.fraResults.location.href="/app/blank.htm";
				copyFromLevel = document.searchForm.Display.value;
						document.searchForm.searchBy.options[0] = new Option("Sales Item Id","VWPRODUCT_LEAF.LEAF_LABEL");
						document.searchForm.searchBy.options[1] = new Option("Sales Item Desc","VWPRODUCT_LEAF.DESCRIPTION");
						document.searchForm.searchBy.options[2] = new Option("Group Key Id","VWCUSTOMER_LEAF.LEAF_LABEL");
						document.searchForm.searchBy.options[3] = new Option("Group Key Desc","VWCUSTOMER_LEAF.DESCRIPTION");
						
						searchByNameArray[0] = "Sales Item Id";
						searchByNameArray[1] = "Sales Item Desc";
						searchByNameArray[2] = "Group Key Id";
						searchByNameArray[3] = "Group Key Desc";
						searchByNameArray[4] = "C SubRegion Desc";
						searchByNameArray[5] = "Channel Desc";
						searchByValueArray[0] = "VWPRODUCT_LEAF.LEAF_LABEL" ;
						searchByValueArray[1] = "VWPRODUCT_LEAF.DESCRIPTION";
						searchByValueArray[2] = "VWCUSTOMER_LEAF.LEAF_LABEL";
						searchByValueArray[3] = "VWCUSTOMER_LEAF.DESCRIPTION";
						
						searchByTypeArray[0] = 2;
						searchByTypeArray[1] = 2;
						searchByTypeArray[2] = 2;
						searchByTypeArray[3] = 2;
						
			}
			//alert(document.searchForm.Display.value);
			
			
		}


        function window_close() {
            //alert("in window close.." + datadirty);
            if ('<%=subcontext%>' == 'findID' && top.dialogArguments.mode != 'single') {
                if (datadirty == true) {
                    return;
                }
            }

            globalOkToClose = true;

            if (dialogArguments.opener == 'ambassador') {
                window.external.close();
            } else {
                if ('<%=context%>' == 'forecast') {
                    if (!('<%=subcontext%>' == 'savedFilter' && ('<%=selectedFilter%>' == 'worklist' || '<%=selectedFilter2%>' == 'worklist'))) { //worklist
                        top.refreshForecastWC();
                    }
                }
                window.close();
            }
        }

    var pageSortCol="";
    var pageSortDir="";

    var thetop = top.dialogArguments.caller;
    var curtab = "";
    var changedContext = "";
    var queryDone = true; //used to manage button clicks while a query is executing..
    top.name='search';
    //alert("thetop=" + thetop.name + "  top=" +top.name);

    thetop.searchwin = self;

    var treemode = 0;
    var singlerecord = false; //top.dialogArguments.singlerecord;
    var searchByValueArray = new Array();
    var searchByNameArray = new Array();
    var searchByTypeArray = new Array();
    var pageSize = 100; //number of rows per page. Real value comes from xml config file.
    var setStart = 1; //row number for return data. This will be updated when user clicks next, prev..
    var stickySearchBy = "";
    var stickyFilterName = "";
    var pageCount = 0;
    var recordCount =0;
    var maxPageCount = 200; //max page count. Real value comes from xml config file..
    var selectedLevels = "";
    var selectedValues = "";
    var lastNodeVal = "";
    var nodeLevel = "";
    var hierarchyTp = "";
    var datadirty = false;
    var lookupField = "";
    var lookupLabel = "";
    var cancelActions = 'false';
    var savedListNameString = "";
    var info="";
    var searchTreeVal = "";
    var showMetricsVal = "yes";
    var showTreeMetricsVal = "";
    var searchValuesChanged = false;
    var currClient = "";

    //alert(singlerecord);
    if (singlerecord == null)
    {
        singlerecord = false;
    }

    //alert("subcontext = " + '<%=subcontext%>');

    // these vars are for the selected records
    // do not confuse these with the same vars in the
    // results page - as the ones on the results
    // page are for when selection one record from
    // a FIND (like from the PLM dialogs)

    var rowhighlight = '#D8EDF9'; //'#FFE3B0';
    var curselection = null;

    function selectRow(theTR)
    {
        //alert("in Search.. selectRow().." + theTR.Type);
        if (curselection)
        {
            curselection.style.backgroundColor = '';
        }
        curselection = theTR;
        curselection.style.backgroundColor = rowhighlight;
    }

    function onDoubleClick(theTR,copyToTable,copyFromTable) {
        selectRow(theTR);
		//alert("table name is  "+table)
        checkActions(copyToTable,copyFromTable);
    }

    function onSelect(selectMode) {
        if (selectMode == 'single') {
            selectedID = document.searchForm.hdnSelectedID.value; //this returns the entire pk string..
            if (selectedID == "" || selectedID == null) {
                top.mcwarn('<%=messages.getString("warning")%>'+':','<%=messages.getString("pleaseselectarow")%>');
                return;
            }

            //alert("thetop.name=" + thetop.name);
            //alert(ItemIdOnly[0]);
            thetop.document.form1.itemid.value = selectedID;
            thetop.document.form1.skuId.value = document.searchForm.hdnSelectedSKU.value;
            thetop.newData(document.searchForm.hdnSelectedDesc.value, document.searchForm.hdnSelectedType.value, document.searchForm.hdnSelectedSKU.value);
            top.window_close();
        }
        else { //multiple
            datadirty=true;
            idBusy.style.display='';
            var parentSKU = top.dialogArguments.parentSKU;
            var rows=saveData.rows;
            var PKList='';

            for (i=1;i<rows.length;i++){
                PKList = PKList + rows[i].PK + separator;
            } // end for loop

            if (rows.length > 1 && PKList != "")
            {
                if (rows.length > 101) {
                    top.mcwarn('<%=messages.getString("warning")%>'+':','<%=messages.getString("youcanonlyadd100components")%>');
                    datadirty=false;
                    idBusy.style.display='none';
                    return;
                }
                var param = new Object();
                param.caller = top;
                param.thetop = thetop;

                if (param.pkList == "") {
                    top.mcwarn('<%=messages.getString("warning")%>'+':','<%=messages.getString("youmustadditemstotheselectedrecordset")%>');
                    datadirty = false;
                    idBusy.style.display='none';
                }
                else {
                    //alert('/efm/SubmitCatalog?context=catalog&subcontext=newAssemblyList&asrpk=&pk='+parentSKU+'&nameString=' + PKList + '&assemblySignature=0&assemblyUnits=&valueString=&typeString=&hierarchyType=');
                    submitwin = showModelessDialog('/efm/SubmitCatalog?context=catalog&subcontext=newAssemblyList&asrpk=&pk='+parentSKU+'&nameString=' + PKList + '&assemblySignature=0&assemblyUnits=&valueString=&typeString=&hierarchyType=', param,'dialogHeight: 150px; dialogWidth: 300px; dialogTop: px; dialogLeft: px; center: Yes; help: No; resizable: No; status: No; scroll: No' );
                }
            }
            else {
                top.mcwarn('<%=messages.getString("warning")%>'+':','<%=messages.getString("youmustadditemstotheselectedrecordset")%>');
                datadirty=false;
                idBusy.style.display='none';
            }

        }
    }

    function onSingleOpen() {
        //selectedID = document.searchForm.hdnSelectedID.value;
        //selectedType = document.searchForm.hdnSelectedType.value;
		selectedID = document.searchForm.hdnSelectedID.value;
		//alert("selected id"+   selectedID);
        selectedType = document.searchForm.hdnSelectedType.value;
		selectedDesc = document.searchForm.hdnSelectedDesc.value;
        selectedTemp=document.searchForm.hdnSelectedTemp.value;
		selectedSKU=document.searchForm.hdnSelectedSKU.value;
		selectedItemId=document.searchForm.hdnSelectedItemid.value;

        //alert("type passed = " + selectedType);
        if ('<%=subcontext%>' == 'PLM') { //forecasting
            var param = new Object();
            param.caller = top;
            param.thetop = thetop;
            param.target = '/efm/ForecastingActions';

            if (selectedID == "" || selectedID == null) {
                    param.pkSelected = "";
                    param.pkList = "false";
                    param.filterList = "";
                    param.searchByList= "";
                    param.operatorList=  "";
                    param.searchValueList= "";
                    param.groupByList= "";
                    param.searchTypeList="";
                    param.itemNameList= "";
                    param.savedListId= "";
                    param.savedListPK=""
                    param.selectedSavedList= "";
                    param.descriptionList= "";
                    param.tooltipList= "";
                    param.itemTypesList= "";
                    param.savedListDescription= "";
                    param.savedListTooltip= "";
                    param.savedListItemTypes= "";
                    param.templateName="<%=selectedFilter%>";
                    param.subcontext="PLM";
                    param.savedListName = "";
            }
            else {
                if (document.searchForm.hdnSearchBy.value == null || document.searchForm.hdnSearchBy.value == "") {
                    searchByL = "VWPRODUCT_LEAF.SKU";
                }
                else {
                    searchByL = document.searchForm.hdnSearchBy.value;
                }
                if (document.searchForm.hdnOperator.value == "" || document.searchForm.hdnOperator.value) {
                    operatorL = "null";
                }
                else {
                    operatorL = document.searchForm.hdnOperator.value;
                }

                if (document.searchForm.hdnSearchValue.value == "" || document.searchForm.hdnSearchValue.value) {
                    searchValueL = "null";
                }
                else {
                    searchValueL = document.searchForm.hdnSearchValue.value;
                }
                if (document.searchForm.hdnSelectedType.value == null || document.searchForm.hdnSelectedType.value == "") {
                    searchTypeL = "2";
                    groupByList = "None";
                }
                else {
                    searchTypeL = document.searchForm.hdnSelectedType.value;
                    groupByL = document.searchForm.hdnGroupBy.value;
                }

                    param.pkSelected = document.searchForm.hdnSelectedID.value;
                    param.pkList = document.searchForm.hdnSelectedID.value;
                    param.filterList = document.searchForm.hdnFilterId.value;
                    param.searchByList= searchByL;
                    param.operatorList=  operatorL;
                    param.searchValueList= searchValueL;
                    param.groupByList= groupByL;
                    param.searchTypeList=searchTypeL;
                    param.itemNameList= document.searchForm.hdnSelectedSKU.value;
                    param.savedListId= "";
                    param.savedListPK=""
                    param.selectedSavedList= "";
                    param.descriptionList= document.searchForm.hdnDescription.value;
                    param.tooltipList= document.searchForm.hdnTooltip.value;
                    param.itemTypesList= "";
                    param.savedListDescription= "";
                    param.savedListTooltip= "";
                    param.savedListItemTypes= "";
                    param.templateName="<%=selectedFilter%>";
                    param.subcontext="PLM";
                    param.savedListName = savedListNameString;
            }

                //alert("param.pkSelected=" +param.pkSelected+ "  param.pkList=" + param.pkList+"  param.filterList=" + param.filterList+ "  param.descriptionList=" + param.descriptionList+"  param.tooltipList="+param.tooltipList + "  param.templateName=" + param.templateName);
                actionswin = showModalDialog('/app/forecasting_actions_shell.html', param,'dialogHeight: 550px; dialogWidth: 680px; dialogTop: px; dialogLeft: px; center: Yes; help: No; resizable: No; status: No; scroll: No' )
                window.external.close(0);
        }
        else { //catalog
            if (selectedID == "" || selectedID == null) {
                top.mcwarn('<%=messages.getString("warning")%>'+':','<%=messages.getString("thereisnocatalogitemselected")%>');
                return;
            }
            //alert("selectedId="+selectedID + "  selectedType=" + selectedType);
            if(selectedTemp!=null && selectedItemId!=null&& selectedTemp!="" && selectedItemId!=""){
	    			top.openCatalogManagerTemp(selectedID, selectedType,selectedTemp,selectedDesc,selectedSKU,selectedItemId);
	    			}
	    			else{
	    				top.openCatalogManager(selectedID, selectedType);
			}
        }
    }

    function changeView(val)
    {
        fraResults.curselection = null
        if (document.fraResults.detailForm) {
          if (document.fraResults.detailForm.length>0) {
              if (document.fraResults.detailForm.elements[0].value == 'error') {
                   //alert("resetting datadirtyflag..");
                   datadirty = false;
              }
          }
        }

        if (datadirty == true) {
            top.mcwarn('<%=messages.getString("warning")%>'+':','<%=messages.getString("pleasewaitforquerytocomplete")%>');
            if (val == 'search') {
                val = 'tree';
            }
            else {
                val = 'search';
            }
            return;
        }

        if (val == 'search')
        {

            if (document.fraResults.detailForm) {
              if (document.fraResults.detailForm.length == 0) {
                fraResults.removeRows();
              }
            }
            idShowMetrics.style.display='none';
            idSearch.style.display='';
            idTree.style.display='none';
            top.treemode = 0;
            parent.idTreeType.innerHTML = '';


        }
        else if (val == 'tree')
        {
            idSearch.style.display='none';
            idTree.style.display='';
            savedListName.style.display = 'none';
            idShowMetrics.style.display='';
            top.treemode = 1;
			searchValuesChanged = false; //bug 3251
            //top.fraTree.showMetricsVal = showTreeMetricsVal;
            if (showTreeMetricsVal == 'yes') {
                document.searchForm.showMetrics.checked = true;
            }
            else {
                document.searchForm.showMetrics.checked = false;
            }
            top.fraTree.updateSearch(top.fraTree.oTreeTable.children[0].children[top.fraTree.currTreeLevel]);
        }
    }

    function childSearch(nodeLevel) {
        top.fraTree.childSearch(nodeLevel)
    }

    function checkTabClick()
    {
        if (event.srcElement.url)
        {
            eval(event.srcElement.url);
        }
    }
    <%-- called from tabpane.js's onclick event handler, which will do nothing if there is a query active --%>
    function checkBusy() {
        return datadirty;
    }
    window.tabpaneCheckBusy = checkBusy;

    function refreshPageNumbers(recordNumbers) {
        //alert("in search.. recordNumbers=" + recordNumbers);
        if (recordNumbers < 1) {
            idBusy.style.display = 'none';
            top.mcwarn('<%=messages.getString("warning")%>'+':','<%=messages.getString("norecordsmatchyoursearchcriteria")%>');
        }
        recordsCount.innerHTML = " (" + recordNumbers + " records) ";

        if (recordNumbers != document.searchForm.hdnRecordCount.value) {
            pageCount = Math.ceil((recordNumbers-0)/pageSize);

            //alert("resetting pagenumbers.. recordNumbers=" + recordNumbers);
            document.searchForm.pageN.length = 0; //removes prior data before re-populating..
            var pageNumber =0;
            if (pageCount > maxPageCount) {
                pageCounter = maxPageCount;
                top.mcwarn('<%=messages.getString("warning")%>'+':','<%=messages.getString("thisrecordsetcontains")%>' + recordNumbers + '<%=messages.getString("rowsYoumaywanttonarrowyoursearchcriteria")%>');
            }
            else {
                pageCounter = pageCount;
            }

            for (i=0; i< pageCounter;i++) {
                pageNumber = i+1;
                document.searchForm.pageN.options[document.searchForm.pageN.length] = new Option('<%=messages.getString("search_page")%> '+ pageNumber + ' <%=messages.getString("search_of")%> ' + pageCounter,pageNumber);
            }
            if (pageCount == 0) {
                document.searchForm.pageN.options[document.searchForm.pageN.length] = new Option('<%=messages.getString("search_page")%> '+"1" + ' <%=messages.getString("search_of")%>'+" 1" ,"1");
            }
            document.searchForm.hdnRecordCount.value = recordNumbers;
            recordCount=recordNumbers;
        }
        timestampObject.endTiming("elapsedTimeSpan");
    }

    //
    // create the URL for the search results request iframe, fraResults
    function searchRequest(caller, sortCol,sortDir) {
		//alert(datadirty);
        timestampObject.startTiming("elapsedTimeSpan");
      if (searchValuesChanged == true) { //this is used in cases where user is in the middle of a recordset and selects prev/next after having changed some search criteria..
        caller = 'go';
        searchValuesChanged = false;
      }


      if (caller=='go'){
          if (sortCol!=""){
             pageSortCol = sortCol;
          }
          else {
             pageSortCol = "";
          }

          if(sortDir!=null && sortDir!=""){
             pageSortDir = sortDir;
          }
          else {
             pageSortDir = "";
          }
      }

      // 'previous' or 'next' ?
      if (caller!='go'){
          //if sortCol is empty and pageSortCol is not empty than user pageSortCol value
          if (sortCol=="" && pageSortCol!=""){
              sortCol = pageSortCol;
          }

          if ((sortDir==null || sortDir=="") && pageSortDir!=""){
              sortDir = pageSortDir;
          }

      }

      //alert("SortCol="+sortCol+", pageSortCol="+pageSortCol+"  pageSortDir="+pageSortDir);

      if (document.fraResults.detailForm) {
        if (document.fraResults.detailForm.length>0) {
            if (document.fraResults.detailForm.elements[0].value == 'error') {
                //alert("resetting datadirtyflag..");
                datadirty = false;
            }
        }
      }

      //alert("datadirty=" +datadirty);
      if (datadirty == true) {
        top.mcwarn('<%=messages.getString("warning")%>','<%=messages.getString("pleasewaitforquerytocomplete")%>');
        return;
      }
      datadirty = true;

      document.body.style.cursor = "wait";
      idBusy.style.display='';
      var passValidation = false;
      var hierarchyType = "";
      //recordCount = document.searchForm.hdnRecordCount.value;


      if (document.searchForm.curContext.value == "catalog" || document.searchForm.curContext.value == "assembly") {
      //    pageSize = 100; //set to 20..
        searchDisplay = document.searchForm.Display.value;
        searchGroupBy = '';
        hierarchyType = document.searchForm.Display.value;
        //alert("hierarchyType = " + hierarchyType);
      }
      else if ('<%=subcontext%>' == 'savedList' && changedContext == "") {
        //pageSize = 1000; //this is done in order to capture all saved list items in the shopping cart..
        searchDisplay = '';
        searchGroupBy = document.searchForm.GroupBy.value;

      }
      else {
      //    pageSize = 100;
        searchDisplay = '';
        searchGroupBy = document.searchForm.GroupBy.value;
        //alert("searchGroupBy = " + searchGroupBy);
      }


      document.searchForm.hdnSelectedID.value = "";
      document.searchForm.hdnSelectedType.value= "";

      //alert(caller);
      if (caller == "go") {
        setStart = 1;
        document.searchForm.pageN.options[0].selected = true;
      }
      else if (caller == "next") {
        //alert("setStart="+setStart + " pageSize="+pageSize+" recordCount="+recordCount);
        if (recordCount-0 >= setStart + pageSize) {
            setStart = setStart + pageSize;
            //alert("document.searchForm.pageN.value="+document.searchForm.pageN.value);
            if (Math.floor((setStart + pageSize)/pageSize) > maxPageCount) {
                top.mcwarn('<%=messages.getString("warning")%>'+':','<%=messages.getString("opportunity_search_max_page_count")%>');
                document.body.style.cursor = "auto";
                idBusy.style.display='none';
                datadirty = false;
                setStart = setStart - pageSize;
                return;
            }
            else {
                pageNumber = document.searchForm.pageN.value-0;
                document.searchForm.pageN.options[pageNumber].selected = true;
            }
            if (top.treemode == 1) {
                top.fraTree.idBusy.style.display = '';
            }
        }
        else {
            top.mcwarn('<%=messages.getString("warning")%>'+':','<%=messages.getString("opportunity_search_last_page_search_results")%>');
            document.body.style.cursor = "auto";
            idBusy.style.display='none';
            datadirty = false;
            return;

            if (pageCount > 0) {
                document.searchForm.pageN.options[pageCount-1].selected = true;
            }
    //      else if (pageCount>0) {
    //          document.searchForm.pageN.options[pageCount-1].selected = true;
    //      }
            else { //pageCount is zero..
                document.searchForm.pageN.options[pageCount].selected = true;
            }
            //return;
        }
      }
      else if (caller == "previous") {
         if ((setStart - pageSize) < 1) {
            top.mcwarn('<%=messages.getString("warning")%>'+':','<%=messages.getString("opportunity_search_first_page_search_results")%>');
            setStart = 1;
            document.searchForm.pageN.options[0].selected = true;
            document.body.style.cursor = "auto";
            idBusy.style.display='none';
            datadirty = false;
            return;
         }
         else {
            setStart = setStart - pageSize;
            pageNumber = (setStart-1)/pageSize;
            document.searchForm.pageN.options[pageNumber].selected = true;
         }
         if (top.treemode == 1) {
                top.fraTree.idBusy.style.display = '';
         }
      }
      else if (caller == "All") {
      //alert("all selected..");
        setStart = 1;
        pageSize = recordCount;
        document.searchForm.pageN.options[pageCount].selected = true;
      }
      else { //a specific page number
        callNumber = caller-0;
        setStart = callNumber * pageSize - pageSize + 1;
        //alert("callNumber=" + callNumber + "  setStart=" + setStart);
        document.searchForm.pageN.options[callNumber-1].selected = true;
        if (top.treemode == 1) {
            top.fraTree.idBusy.style.display = '';
        }
      }

      if (top.treemode == 0) {
          //getMetricsVal();
          if ('<%=subcontext%>' == 'savedList' && changedContext == "") {
             var searchParams = '&searchBy=' +
                             '&operator=' +
                             '&searchValue=' +
                             '&filterName=<%=request.getParameter("info")%>' +
                             '&type=' +
                             '&setStart=' + setStart + '&pageSize=1000' + //pageSize +
                             '&showMetricsVal=yes' + //showMetricsVal +
                             '&sortCol=' + sortCol +
                             '&sortDirection=' + sortDir +
                             '&searchDisplay=' +
                             '&searchGroupBy=';

            passValidation = true;
         }
         else {
				
            var searchParams = '&searchBy=' + document.searchForm.searchBy.value +
                             '&operator=' + document.searchForm.operator.value +
                             '&searchValue=' + encodeURIComponent(document.searchForm.searchValue.value) +
                             '&type=' + hierarchyType +
							 '&copyCart=' + copy +
                             '&setStart=' + setStart + '&pageSize=' + pageSize +
                             '&showMetricsVal=yes' + //showMetricsVal +
                             '&sortCol=' + sortCol +
                             '&sortDirection=' + sortDir +
                             '&searchDisplay=' + searchDisplay +
                             '&searchGroupBy=' + searchGroupBy +
                             '&info=' + info ;

			//alert("searchparam is  "+searchParams)
            searchParams = searchParams + '&filterName=' + document.filterNames.document.searchForm.elements[0].options[document.filterNames.document.searchForm.elements[0].options.selectedIndex].value;
            if (idShowRelationships.style.display == '') {
                hasRelationsVal = document.searchForm.showRelationships.value;
                searchParams = searchParams + '&hasRelations='+hasRelationsVal;
            }
            else {

                searchParams = searchParams + '&hasRelations=with';
            }
          //alert(searchParams);
          //validate search value entry..
          for (i=0; i < searchByValueArray.length;i++) {
            if (searchByValueArray[i] == document.searchForm.searchBy.value) {
                if (document.searchForm.searchValue.value != "" && document.searchForm.searchValue.value != null) {
                    //alert(searchByTypeArray[i]);
                    switch (searchByTypeArray[i]-0) { //converts string to integer by subtracting zero
                        case 1: //number
                            if (isNumeric(document.searchForm.searchValue.value)) {
                                if (isOperatorValid("1", document.searchForm.operator.value)) {
                                    passValidation = true;
                                    searchParams = searchParams + '&dataType=1';
                                }
                            }
                            else {
                                top.mcwarn('<%=messages.getString("warning")%>'+':','<%=messages.getString("theselectedsearchbyfieldrequiresavalidnumericentry")%>');
                            }
                            break;
                        case 2: //string
                            if (isOperatorValid("2", document.searchForm.operator.value)) {
                                passValidation = true;
                                searchParams = searchParams + '&dataType=2';
                            }
                            break;
                        case 3: //datetime
                            if (isDate(document.searchForm.searchValue.value)) { //TODO: This needs to be more flexible, currently only accepted format is mm/dd/yy..
                                if (isOperatorValid("3", document.searchForm.operator.value)) {
                                    passValidation = true;
                                    searchParams = searchParams + '&dataType=3';
                                }
                            }
                            else {
                                top.mcwarn('<%=messages.getString("warning")%>'+':','<%=messages.getString("theselectedsearchbyfieldrequiresadate")%>');
                            }
                            break;
                        case 4: //boolean
                            if (document.searchForm.searchValue.value != 0 && document.searchForm.searchValue.value != 1) {
                                    top.mcwarn('<%=messages.getString("warning")%>'+':','<%=messages.getString("theselectedsearchbyfieldrequiresabooleanvalue")%>');
                            }
                            else {
                                if (isOperatorValid("4", document.searchForm.operator.value)) {
                                    passValidation = true;
                                    searchParams = searchParams + '&dataType=4';
                                }
                            }
                            break;
                        default: //validate as a string..
                            passValidation = false;
                            //searchParams = searchParams + '&dataType=2';
                            break;
                    }
                }
                else {
                    passValidation = true;
                    searchParams = searchParams + '&dataType=2';
                }
            }
          }
        }
    }
    else { //treemode =1
        //handle next/prev etc for tree here..
        fraTree.idBusy.display = '';
        var searchParams = '&setStart=' + setStart +
                     '&pageSize=' + pageSize +
                     '&sortCol=' + sortCol +
                     '&sortDirection=' + sortDir +
                     '&filtertab=1' +
                     '&output=yes' +
                     '&getRecordCount=yes' +
                     '&hierarchyType=' + hierarchyTp +
                     '&searchVal=' + searchTreeVal +
                     '&showMetricsVal=' + showMetricsVal +
                     '&treeLevel=' + selectedLevels +
                     '&treeVal=' + selectedValues +
                     '&lastNode=' + lastNodeVal +
                     '&nodeLevel=' + nodeLevel;

        var url = '/efm/SearchTreeResults?context=forecast&subcontext=undefined&info=undefined' + searchParams; // + '&treeType=' + oTR.swTreeType + '&treeVal=' + oTR.swTreeVal;
        //alert(url);
        searchTree(url, hierarchyTp, selectedLevels, selectedValues, lastNodeVal, nodeLevel,false,searchTreeVal, showMetricsVal);
        document.body.style.cursor = "auto";
        fraTree.idBusy.display = 'none';
        idBusy.style.display='none';
        return;
    }

      if (passValidation == true && changedContext == "" && '<%=subcontext%>' != 'PLM') {
		  //alert("123");
          //alert('<%= searchResultsURL %>' + searchParams + '&filtertab=0&output=yes&getRecordCount=yes');
          document.fraResults.location.href = '<%= searchResultsURL %>' + searchParams + '&filtertab=0&output=yes&getRecordCount=yes';
		   //idBusy.style.display='none';
      }
      else if (passValidation == true && changedContext != "" && '<%=subcontext%>' != 'PLM') {
		  //alert("456");
         // alert('/efm/SearchResults?context=forecast&subcontext=undefined&info=undefined' + searchParams + '&filtertab=0&output=yes&getRecordCount=yes');
          parent.idTreeType.innerHTML = '';
          savedListName.innerHTML = '';
          document.fraResults.location.href = '/efm/SearchResults?context=forecast&subcontext=undefined&info=undefined' + searchParams + '&filtertab=0&output=yes&getRecordCount=yes';
      }
      else if (passValidation == true && '<%=subcontext%>' == 'PLM') {
          document.fraResults.location.href = '/efm/SearchResults?context=forecast&subcontext=PLM&info=<%=selectedFilter%>' + searchParams + '&filtertab=0&output=yes&getRecordCount=yes';
      }
      else if (passValidation == false) {
        document.body.style.cursor = "auto";
        idBusy.style.display='none';
        datadirty = false;
      }
      if (passValidation == true) {
        stickySearchBy = document.searchForm.searchBy.value;
        stickyOperator = document.searchForm.operator.value;
        stickyValue = document.searchForm.searchValue.value;
      }
		//idBusy.style.display='none';
    }

    function searchTree(url, hierarchyTpe, treeLevel, treeVal, lastNode, nodeLvl,checkdirtydata, treeSearchVal, treeShowMetricsVal,resetStart) {
        //alert("in search, ready to call SR with this url.. " + url);
        if (document.fraResults.detailForm) {
          if (document.fraResults.detailForm.length>0) {
            if (document.fraResults.detailForm.elements[0].value == 'error') {
                //alert("resetting datadirtyflag..");
                datadirty = false;
                idBusy.style.display='none';
            }
          }
        }

        if (datadirty == true && checkdirtydata==true) {
			//alert("before calling data dirty");
            top.mcwarn('<%=messages.getString("warning")%>'+':','<%=messages.getString("pleasewaitforquerytocomplete")%>');
            return;
        }
        datadirty = true;

        showMetricsVal = treeShowMetricsVal;
        searchTreeVal = treeSearchVal;
        selectedLevels = treeLevel;
        selectedValues = treeVal;
        lastNodeVal = lastNode;
        nodeLevel = nodeLvl;
        hierarchyTp = hierarchyTpe;
        //alert("url="+url);
        if (resetStart == "1") {
            document.searchForm.pageN.options[0].selected = true;
            setStart=1;
            //alert("setStart in searchTree =" + setStart + " url=" + url);
        }
        document.fraResults.location.href= url;
    }

    function isOperatorValid(type, operator) {
        switch (type) {
            case "1":
                if (operator == 1 || operator == 4 || operator == 3 || operator == 2)
                    return true;
                else {
                    top.mcwarn('<%=messages.getString("warning")%>'+':','<%=messages.getString("theselectedoperatorisinvalidwhenthesearchbydatatypeisnumeric")%>');
                    return false;
                }
                break;
            case "2":
                if (operator == 1 || operator == 10 || operator == 9 || operator == 2)
                    return true;
                else {
                    top.mcwarn('<%=messages.getString("warning")%>'+':','<%=messages.getString("theselectedoperatorisinvalidwhenthesearchbydatatypeisstring")%>');
                    return false;
                }
                break;
            case "3":
                if (operator == 1 || operator == 4 || operator == 3)
                    return true;
                else {
                    top.mcwarn('<%=messages.getString("warning")%>'+':','<%=messages.getString("theselectedoperatorisinvalidwhenthesearchbydatatypeisdate")%>');
                    return false;
                }
                break;
            case "4":
                if (operator == 1)
                    return true;
                else {
                    top.mcwarn('<%=messages.getString("warning")%>'+':','<%=messages.getString("theselectedoperatorisinvalidwhenthesearchbydatatypeisboolean")%>');
                    return false;
                }
                break;
            default:
                top.mcwarn('<%=messages.getString("warning")%>'+':','<%=messages.getString("theselectedsearchbydatatypeisnotrecognized")%>');
                return false;
                break;
        }

    }
    function trim(inputString) {
       
       if (typeof inputString != "string") { return inputString; }
       var retValue = inputString;
       var ch = retValue.substring(0, 1);
       while (ch == " ") { // Check for spaces at the beginning of the string
          retValue = retValue.substring(1, retValue.length);
          ch = retValue.substring(0, 1);
       }
       ch = retValue.substring(retValue.length-1, retValue.length);
       while (ch == " ") { // Check for spaces at the end of the string
          retValue = retValue.substring(0, retValue.length-1);
          ch = retValue.substring(retValue.length-1, retValue.length);
       }
       while (retValue.indexOf("  ") != -1) { // Note that there are two spaces in the string - look for multiple spaces within the string
          retValue = retValue.substring(0, retValue.indexOf("  ")) + retValue.substring(retValue.indexOf("  ")+1, retValue.length); // Again, there are two spaces in each of the strings
       }
       return retValue; // Return the trimmed string back to the user
    } 
    

	function openCustomFilterWin(){
        var param = new Object();
        this.focus();
        param.caller = top;
        param.existingFilters = document.filterNames.document.searchForm.filterNameList.value;

        //alert("top name=" + top.name);
        var f = document.filterNames.document.searchForm.elements[0].options[document.filterNames.document.searchForm.elements[0].options.selectedIndex].value;
        var fname = document.filterNames.document.searchForm.elements[0].options[document.filterNames.document.searchForm.elements[0].options.selectedIndex].text;
        var c = document.searchForm.curContext.value;
        var adhocID = 0;
        //alert("filter length = " + document.filterNames.document.searchForm.elements[0].options.length);
        for (i=0;i<document.filterNames.document.searchForm.elements[0].options.length; i++) {
            if (document.filterNames.document.searchForm.elements[0].options[i].text == "AdHoc") {
                adhocID = document.filterNames.document.searchForm.elements[0].options[i].value;
            }
        }
        var filterNames = new Array();
        var filterDesc = new Array();
        var filterNameString = document.filterNames.document.searchForm.elements[1].value;
        var filterDescString = document.filterNames.document.searchForm.elements[2].value
        filterNames = filterNameString.split("|");
        filterDesc = filterDescString.split("|");
        for (i = 0; i< filterNameString.length;i++) {
            if (trim(filterNames[i]) == trim(fname)) {
                filterDescString = filterDesc[i];
                //alert("filterDescString =" +  filterDescString);
            }
        }
        //alert('/efm/Filter?context=' + c + '&fID=' + f + '&filterName=' + fname + '&adhocID=' + adhocID + '&filterDesc=' + filterDescString);
        editfilterwin = showModalDialog('/efm/CustomFilter?context=' + c + '&fID=' + f + '&filterName=' + fname + '&adhocID=' + adhocID + '&filterDesc=' + filterDescString, param,'dialogHeight: 640px; dialogWidth: 970px; dialogTop: px; dialogLeft: px; center: Yes; help: No; resizable: No; status: No; scroll: No' );
    }

    function openFilterWin(){
        var param = new Object();
        this.focus();
        param.caller = top;
        param.existingFilters = document.filterNames.document.searchForm.filterNameList.value;

        //alert("top name=" + top.name);
        var f = document.filterNames.document.searchForm.elements[0].options[document.filterNames.document.searchForm.elements[0].options.selectedIndex].value;
        var fname = document.filterNames.document.searchForm.elements[0].options[document.filterNames.document.searchForm.elements[0].options.selectedIndex].text;
        var c = document.searchForm.curContext.value;
        var adhocID = 0;
        //alert("filter length = " + document.filterNames.document.searchForm.elements[0].options.length);
        for (i=0;i<document.filterNames.document.searchForm.elements[0].options.length; i++) {
            if (document.filterNames.document.searchForm.elements[0].options[i].text == "AdHoc") {
                adhocID = document.filterNames.document.searchForm.elements[0].options[i].value;
            }
        }
        var filterNames = new Array();
        var filterDesc = new Array();
        var filterNameString = document.filterNames.document.searchForm.elements[1].value;
        var filterDescString = document.filterNames.document.searchForm.elements[2].value
        filterNames = filterNameString.split("|");
        filterDesc = filterDescString.split("|");
        for (i = 0; i< filterNameString.length;i++) {
            if (trim(filterNames[i]) == trim(fname)) {
                filterDescString = filterDesc[i];
                //alert("filterDescString =" +  filterDescString);
            }
        }

		if(f != 0) {
		
			
			isExpertFilter = showModalDialog('/efm/CheckExpertFilter?filterid='+f,param,'dialogHeight: 10px; dialogWidth:10px; dialogTop: px; dialogLeft: px; center: Yes; help: No; resizable: No; status: No; scroll: No');

			if( isExpertFilter == "true") {
				editfilterwin = showModalDialog('/efm/CustomFilter?context=' + c + '&fID=' + f + '&filterName=' + fname + '&adhocID=' + adhocID + '&filterDesc=' + filterDescString, param,'dialogHeight: 640px; dialogWidth: 970px; dialogTop: px; dialogLeft: px; center: Yes; help: No; resizable: No; status: No; scroll: No' );
    		}else if(isExpertFilter == "FilterException"){
				top.mcwarn('<%=messages.getString("warning")%>','<%=messages.getString("workflows_reports_Thefilteryouusedforthisoperationhasbeendeletedfromthesystem")%>');
				onRefreshFilter(fname);
				
			} else {
				editfilterwin = showModalDialog('/efm/Filter?context=' + c + '&fID=' + f + '&filterName=' + fname + '&adhocID=' + adhocID + '&filterDesc=' + filterDescString, param,'dialogHeight: 640px; dialogWidth: 970px; dialogTop: px; dialogLeft: px; center: Yes; help: No; resizable: No; status: No; scroll: No' );
				if(editfilterwin == "switchfilter"){
				openNewCustomFilterWin();
				}
			}
		} else {
        //alert('/efm/Filter?context=' + c + '&fID=' + f + '&filterName=' + fname + '&adhocID=' + adhocID + '&filterDesc=' + filterDescString);
        editfilterwin = showModalDialog('/efm/Filter?context=' + c + '&fID=' + f + '&filterName=' + fname + '&adhocID=' + adhocID + '&filterDesc=' + filterDescString, param,'dialogHeight: 640px; dialogWidth: 970px; dialogTop: px; dialogLeft: px; center: Yes; help: No; resizable: No; status: No; scroll: No' );
		if(editfilterwin == "switchfilter"){
				openNewCustomFilterWin();
		}
		}
    }

    function openNewFilterWin(){
        var param = new Object();
        param.caller = top;
        param.existingFilters = document.filterNames.document.searchForm.filterNameList.value;
        //alert("in search.. existing filters=" + param.existingFilters);
        var f = "Custom"
        var c = document.searchForm.curContext.value;
        var adhocID = 0;
        //alert("filter length = " + document.filterNames.document.searchForm.elements[0].options.length);
        for (i=0;i<document.filterNames.document.searchForm.elements[0].options.length; i++) {
            if (document.filterNames.document.searchForm.elements[0].options[i].text == "AdHoc") {
                adhocID = document.filterNames.document.searchForm.elements[0].options[i].value;
                //alert("adhocID = " + adhocID);
            }
        }
        editfilterwin = showModalDialog('/efm/Filter?context=' + c + '&fID=0&filterName=' + f + '&adhocID=' + adhocID, param,'dialogHeight: 640px; dialogWidth: 970px; dialogTop: px; dialogLeft: px; center: Yes; help: No; resizable: No; status: No; scroll: No' );
		if(editfilterwin == "switchfilter"){
				openNewCustomFilterWin();
		}



    }
	function openNewCustomFilterWin(){
        var param = new Object();
        param.caller = top;
        param.existingFilters = document.filterNames.document.searchForm.filterNameList.value;
        //alert("in search.. existing filters=" + param.existingFilters);
        var f = "Custom"
        var c = document.searchForm.curContext.value;
        var adhocID = 0;
        //alert("filter length = " + document.filterNames.document.searchForm.elements[0].options.length);
        for (i=0;i<document.filterNames.document.searchForm.elements[0].options.length; i++) {
            if (document.filterNames.document.searchForm.elements[0].options[i].text == "AdHoc") {
                adhocID = document.filterNames.document.searchForm.elements[0].options[i].value;
                //alert("adhocID = " + adhocID);
            }
        }

		
        editfilterwin = showModalDialog('/efm/CustomFilter?context=' + c + '&fID=0&filterName=' + f + '&adhocID=' + adhocID, param,'dialogHeight: 640px; dialogWidth: 970px; dialogTop: px; dialogLeft: px; center: Yes; help: No; resizable: No; status: No; scroll: No' );

		if(editfilterwin == "switchfilter"){
				openNewFilterWin();
		}


    }

    function clearToRows(theTable){
        var rows=theTable.rows;
		if(rows.length == 0 || rows.length == 1){
		//top.mcwarn('Info','No items in current selection');
		  mcalert('info','<%=messages.getString("etl_job_information")%>','<%=messages.getString("search_catalog_noresults")%>','bg_ok',500,210,'sounds/cancel.wav');    
	}
		//alert("table is  "+theTable);
        for (i=1;i<rows.length;i++){
            rows[i].removeNode(true);
            i--
        }
        tocount.innerHTML = '0';
		selectiontocount.innerHTML = '0';
		
    }
	 function clearFromRows(theTable){
        var rows=theTable.rows;
		//alert("table is  "+theTable);
		if(rows.length == 0 || rows.length == 1){
		//top.mcwarn('Info','No items in current selection');
		  mcalert('info','<%=messages.getString("etl_job_information")%>','<%=messages.getString("search_catalog_noresults")%>','bg_ok',500,210,'sounds/cancel.wav');    
	}
        for (i=1;i<rows.length;i++){
            rows[i].removeNode(true);
            i--
        }
        fromcount.innerHTML = '0';
		selectionfromcount.innerHTML = '0';
    }

	 function clearAllFromRows(theTable){
        var rows=theTable.rows;
		//alert("table is  "+theTable);
        for (i=0;i<rows.length;i++){
            rows[i].removeNode(true);
            i--
        }
        fromcount.innerHTML = '0';
		selectionfromcount.innerHTML = '0';
    }

    function collapseView(){
        if ('<%=subcontext%>' != 'savedList' && '<%=subcontext%>' !='editSavedList') {
            collapsebtn.style.display='none';
            expandbtn.style.display='';
            searchResults.style.display='';
            divFilter.style.display='';
            rv_show.style.display='none';
            rv_hide.style.display='';
            document.all.fraResults.style.width='662';
            fraSelected.style.width='662';
            fraSelected.style.height='150';
            document.body.background='/app/images/wm_search.jpg';
            //parent.idTreeType.innerHTML = '';
        }
        else {
            collapsebtn.style.display='none';
            expandbtn.style.display='';
            searchResults.style.display='';
            divFilter.style.display='';
            rv_show.style.display='none';
            rv_hide.style.display='';
            fraSelected.style.width='662';
            fraSelected.style.height='150';
            document.body.background='/app/images/wm_search.jpg';
            if (treemode == 0) {
                idSearch.style.display='';
            }
            if (changedContext == "") {
                changedContext = "undefined";
                if (document.fraResults.detailForm) {
                    if (document.fraResults.detailForm.length == 0) {
                        fraResults.removeRows();
                    }
                }
            }
        }
    }

    function expandView(){
        document.body.background='';
        expandbtn.style.display='none';
        rv_show.style.display='none';
        rv_hide.style.display='';
        collapsebtn.style.display='';
        searchResults.style.display='none';
        divFilter.style.display='none';
        fraSelected.style.width='930';
        fraSelected.style.height='526';
    }
    function collapseResultsView(){
        rv_show.style.display='none';
        rv_hide.style.display='';
        divFilter.style.display='';
        fraSelected.style.width='662';
        document.all.fraResults.style.width='662px';
        document.body.background='/app/images/wm_search.jpg';
    }
    function expandResultsView(){
        rv_show.style.display='';
        rv_hide.style.display='none';
        document.body.background='';
        divFilter.style.display='none';
        document.all.fraResults.style.width='930';
        fraSelected.style.width='930';
    }
    function removeRow(r,cart){
        row = r.parentElement.parentElement;
        row.removeNode(true);
		if(cart == 'copyTo'){
			tocount.innerHTML = eval(tocount.innerHTML)-1;
			selectiontocount.innerHTML = tocount.innerHTML;
		}
		if(cart == 'copyFrom'){
			fromcount.innerHTML = eval(fromcount.innerHTML)-1;
			selectionfromcount.innerHTML = fromcount.innerHTML;
		}
    }



    function checkActions(copyToTable,copyFromTable){
        var rows=copyFromTable.rows;
		var toRows=copyToTable.rows;
		//alert("rows length is  "+rows.length);
		var toPKList= '';
        var PKList='';
		var PKList1='';
		var PKList2='';
		var PKList3='';
		var PKList4='';
        var param = new Object();

        if (document.searchForm.curContext.value == "catalog") {
            for (i=1;i<rows.length;i++){
              
                PKList = PKList + rows[i].PK;
				
				if(i<rows.length){
					PKList = PKList + ';' ;
					
				}
                
                           
            } // end for loop
			
			for (i=1;i<toRows.length;i++){
				
                toPKList = toPKList + toRows[i].PK;
				if(i<toRows.length)
					toPKList = toPKList + ';' ;
                
                           
            } // end for loop
        }

		if (rows.length > 1 && toRows.length > 1) // First row is the column labels and therefore not a data row
        {
            
            param.caller = top;
			param.thetop = thetop;
			param.target = '/efm/CopyRelationships';
          
             param.pkList = PKList;
			 
			 param.toPKList = toPKList;
			 param.level = copyFromLevel;
			 //alert("copyFromLevel  "+copyFromLevel);
			 //alert("level is  "+document.searchForm.Display.value  +""+ document.searchForm.Display.name);
			 if (param.pkList == "" || param.toPKList == "") {
				if(param.pkList == ""){
                    top.mcwarn('<%=messages.getString("warning")%>'+':','<%=messages.getString("searchCatalog_relationships_YoumustadditemstotheCopyFromshoppingcart")%>');
				}
				if(param.toPKList == ""){
                    top.mcwarn('<%=messages.getString("warning")%>'+':','<%=messages.getString("searchCatalog_relationships_YoumustadditemstotheCopyToshoppingcart")%>');
				}
             }
			 else {
				
                actionswin = showModalDialog('/app/copy_relationships_shell.html' , param ,'dialogHeight: 180px; dialogWidth: 300px; dialogTop: px; dialogLeft: px; center: Yes; help: No; resizable: No; status: No; scroll: No' )

            
        }
		}
        else {
			if(rows.length < 2 && toRows.length < 2){
				top.mcwarn('<%=messages.getString("searchCatalog_relationships_InvalidAction")%>'+':','<%=messages.getString("searchCatalog_relationships_CopyRelationshiprequiresitemstoCopyFromanditemstoCopyTo")%>');
				return;
			}
			if(toRows.length < 2){
				top.mcwarn('<%=messages.getString("searchCatalog_relationships_InvalidAction")%>'+':','<%=messages.getString("searchCatalog_relationships_CopyRelationshiprequiresatleastoneitemtoCopyTo")%>');
				return;
			}
			if(rows.length < 2){
				top.mcwarn('<%=messages.getString("searchCatalog_relationships_InvalidAction")%>'+':','<%=messages.getString("searchCatalog_relationships_CopyRelationshiprequiresatleastoneitemtoCopyFrom")%>');
				return;
			}

		
    }
	clearToRows(saveData1);
	clearFromRows(saveData2);
	
	}

	

    function window_onload(){
        document.body.background='/app/images/wm_search.jpg';
        document.body.style.cursor = "wait";
		document.all.fraResults.style.height='280px';
		
				/*idCopyTo.style.display='';
				fraCopyTo.style.display='';
				selectedCT.style.display='';
				fraCopyFrom.style.display='none';
				selectedCF.style.display='none'; */

        document.searchForm.pageN.options[0] = new Option('<%=messages.getString("search_page")%> '+"1" + ' <%=messages.getString("search_of")%>'+" 1" ,"1");

        if (top.dialogArguments.editmode == true){

            divFilter.style.display='';
            searchResults.style.display='';
            selectedRS.style.display='';
            fraSelected.style.display='';
            idEditButtons.style.display='';
            fraResults.moveAll();
            tabPane1.style.display = '';
            tabPane12.style.display = 'none';

            idListName.style.display='';
            buttongrp_selectall.style.display='';
        }
        else if (top.dialogArguments.loadexpanded == true){
            //alert("in loadexpanded..");
            selectedRS.style.display='';
            fraSelected.style.display='';
            idButtons.style.display='';
            top.expandView();
            collapsebtn.style.display='none';
            fraResults.moveAll();
            tabPane1.style.display = '';
            tabPane12.style.display = 'none';

            buttongrp_selectall.style.display='';
        }
        else if (singlerecord == true)
        {
            divFilter.style.display='';
            searchResults.style.display='';
            document.all.fraResults.height = '515';
            tabPane1.style.display = '';
            tabPane12.style.display = 'none';

            buttongrp_selectone.style.display='';
        }
        else if ('<%=subcontext%>' == 'findID')
        {
            if (top.dialogArguments.mode == 'single') { //single select
                fraSelected.style.display='none';
                document.all.fraResults.height = '475';
                buttongrp_selectall.style.display='none';
                selectedRS.style.display = 'none';
                idSelectButtons.style.display = '';
                info = 'single';
            }
            else { //multi select
                fraSelected.style.display='';
                multiSelectbtn.style.display='';
                actionbtn.style.display='none';
                buttongrp_selectall.style.display='';
                selectedRS.style.display = '';
                idButtons.style.display = '';
                info = 'multiple';
            }
            searchResults.style.display='';
            divFilter.style.display='';
            idSingleOpenPLMButtons.style.display = 'none';
            tabPane1.style.display = 'none';
            tabPane12.style.display = '';
            idGroupBy.style.display='none';
            idDisplay.style.display='';
            idShowRelationships.style.display = '';
            document.searchForm.showRelationships.value = "with";
            document.searchForm.showRelationships.disabled = true;
        }
        else if ('<%=subcontext%>' == 'newSavedList') {
            idGroupBy.style.display='';
            idDisplay.style.display='none';
            idEditButtons.style.display='';
            divFilter.style.display='';
            selectedRS.style.display='';
            fraSelected.style.display='';
            searchResults.style.display='';

            tabPane1.style.display = '';
            tabPane12.style.display = 'none';

            buttongrp_selectall.style.display='';

        }
        else if ('<%=subcontext%>' == 'savedList') {
            //alert("in savedList..");
            idSearch.style.display='none';
            selectedRS.style.display='';
            fraSelected.style.display='';
            searchResults.style.display='none';
            idButtons.style.display = '';
            tabPane1.style.display = '';
            tabPane12.style.display = 'none';
            expandbtn.style.display= 'none';
            collapsebtn.style.display = 'none';
            clearallbtn.style.display = 'none';
            fraSelected.style.width='100%';
            fraSelected.style.height='526px';
            parent.idTreeType.innerHTML = '';
            savedListName.style.display = '';
            savedListName.innerHTML = '<%=listName%>';
            savedListNameString = '<%=listName%>';
            buttongrp_selectall.style.display='';
            srcount.innerHTML = 'loading';
            document.body.background='';
        }
        else if ('<%=subcontext%>' == 'PLM') {
            idGroupBy.style.display='';
            idDisplay.style.display='none';
            fraSelected.style.display='none';
            searchResults.style.display='';
            document.all.fraResults.height = '475';
            buttongrp_selectall.style.display='none';
            divFilter.style.display='';
            selectedRS.style.display = 'none';
            idSingleOpenButtons.style.display = 'none';
            idSingleOpenPLMButtons.style.display = '';
            idButtons.style.display = 'none';
            tabPane1.style.display = 'none';
            tabPane12.style.display = '';
            idPLMText.innerHTML = '<%=messages.getString("warning")%>'+':'+'<ul><li type=circle>'+'<%=messages.getString("itemlist_search_Withoutusinganexistingitemasamodel")%>'+ '<%=messages.getString("itemlist_search_ClickContinue")%>'+'</li><li type=circle>'+'<%=messages.getString("itemlist_search_Byusinganexistingitemasamodel")%>'+ '<%=messages.getString("itemlist_search_SearchfortheexistingitemClickonitintheSearchResults")%>'+'</li></ul>'
        }
        else
        {
            divFilter.style.display='';
            selectedRS.style.display='';
            fraSelected.style.display='';
            searchResults.style.display='';

            tabPane1.style.display = '';
            tabPane12.style.display = 'none';

            buttongrp_selectall.style.display='';
        }

        if ( (document.searchForm.curContext.value == "catalog" || document.searchForm.curContext.value == "assembly") && "<%=subcontext%>" != "findID") {
            idGroupBy.style.display='none';
            idDisplay.style.display='';

            fraSelected.style.display='none';
            searchResults.style.display='';
            document.all.fraResults.height = '300';
            buttongrp_selectall.style.display='';
            divFilter.style.display='';
            selectedRS.style.display = 'none';
            idSelectButtons.style.display = 'none';
            idSingleOpenPLMButtons.style.display = 'none';
            tabPane1.style.display = 'none';
            tabPane12.style.display = '';
            idSingleOpenButtons.style.display = '';
            idButtons.style.display='none';
            idShowRelationships.style.display = '';
        }
        else {
          if ( document.searchForm.curContext.value == "forecast" && '<%=subcontext%>' != 'newSavedList' && '<%=subcontext%>' != 'editSavedList') {
            idGroupBy.style.display='';
            idDisplay.style.display='none';
            if ("<%=subcontext%>" != "PLM") {
                idButtons.style.display='';
            }
            if ("<%=subcontext%>" == "assignedItems") {
                parent.idTreeType.innerHTML = 'Assigned Items';
            }

          }
        }
        if (document.searchForm.curContext.value == "catalog") {
            stickyGroupBy = '<%=userState.get("catalog", "catalogDisplay")%>';
            //stickySearchBy = '<%=userState.get("catalog", "catalogSearchBy")%>';
            stickyOperator = '<%=userState.get("catalog", "catalogOperator")%>';
            stickyValue =unescape('<%=UserState.escapeSingleQuote(userState.get("catalog", "catalogValue"))%>');
            if (stickyValue == 'null') {
                stickyValue = '';
            }
            stickyFilterName = '<%=userState.get("catalog", "catalogFilterName")%>';
            if (stickyGroupBy == 'null') {
                idShowRelationships.style.display = '';
            }
            else if (stickyGroupBy != 'ALL_SKU' && stickyGroupBy != 'ITEM' && stickyGroupBy != 'SBOM' && stickyGroupBy != 'BOM' && stickyGroupBy != 'PHANTOM' && stickyGroupBy != 'ASSEMBLY') {
                idShowRelationships.style.display = 'none';
            }
        }
        else if (document.searchForm.curContext.value == "assembly") {
            stickyGroupBy = '<%=userState.get("catalog", "assemblyDisplay")%>';
            //stickySearchBy = '<%=userState.get("catalog", "catalogSearchBy")%>';
            stickyOperator = '<%=userState.get("catalog", "catalogOperator")%>';
            stickyValue = unescape('<%=UserState.escapeSingleQuote(userState.get("catalog", "catalogValue"))%>');
            if (stickyValue == 'null') {
                stickyValue = '';
            }
            stickyFilterName = '<%=userState.get("catalog", "catalogFilterName")%>';
            if (stickyGroupBy != 'ALL_SKU' && stickyGroupBy != 'ITEM' && stickyGroupBy != 'SBOM' && stickyGroupBy != 'BOM' && stickyGroupBy != 'PHANTOM' && stickyGroupBy != 'ASSEMBLY') {
                idShowRelationships.style.display = 'none';
            }

        }
        else if (document.searchForm.curContext.value == "forecast" && "<%=subcontext%>" != "editSavedList" && "<%=subcontext%>" != "savedFilter" && "<%=subcontext%>" != "assignedItems" && "<%=subcontext%>" != "PLM") {
            stickyGroupBy = '<%=userState.get("forecast", "forecastGroupBy")%>';
            //stickySearchBy = '<%=userState.get("forecast", "forecastSearchBy")%>';
            stickyOperator = '<%=userState.get("forecast", "forecastOperator")%>';
            stickyValue =unescape('<%=UserState.escapeSingleQuote(userState.get("forecast", "forecastValue"))%>');
            if (stickyValue == 'null') {
                stickyValue = '';
            }
            stickyFilterName = '<%=userState.get("forecast", "forecastFilterName")%>';
        }
        else if (document.searchForm.curContext.value == "forecast" && ("<%=subcontext%>" == "savedFilter" || "<%=subcontext%>" == "assignedItems")) {
            stickyGroupBy = "";
            stickySearchBy = "";
            stickyOperator = "1";
            stickyValue = "";
            stickyFilterName = '<%=selectedFilter%>';
        }
        else if (document.searchForm.curContext.value == "forecast" && "<%=subcontext%>" == "PLM") {
            stickyGroupBy = "";
			stickySearchBy = '<%=userState.get("forecastPLM", "PLMSearchBy")%>';
            stickyOperator = '<%=userState.get("forecastPLM", "PLMOperator")%>';
            stickyValue = unescape('<%=UserState.escapeSingleQuote(userState.get("forecastPLM", "PLMValue"))%>');
            if (stickyValue == 'null') {
                stickyValue = '';
            }
            stickyFilterName = '<%=userState.get("forecastPLM", "PLMFilterName")%>';
        }
        else {
            stickyGroupBy = "";
            stickySearchBy = "";
            stickyOperator = "1";
            stickyValue = "";
            stickyFilterName = "";
        }
        
        var modifiedStickyGroupBy;
        if (stickyGroupBy == 'null' || stickyGroupBy == "") {
            if (document.searchForm.curContext.value == "catalog") {
                groupById = "searchBy-ALL";
            }
            else if (document.searchForm.curContext.value == "assembly") {
                groupById = "searchBy-SKU_Assemblies";
            }
            else if (document.searchForm.curContext.value == "forecast") {
                groupById = "default-Setting";
            } else {
                groupById = "searchBy";
            }
        }
        else {
            // In the XML files groupby fields are in the folllowing format: PRODUCT--ALL--ALL 
            // and NOT in the format which the backend returns(ALL~~ALL~~ALL)
            // Hence replace the string "~~" by string "--"
            var re = /~~/g
            modifiedStickyGroupBy = stickyGroupBy.replace(re, "--");
            groupById = modifiedStickyGroupBy;
        }

        getXMLdata(groupById, 'open');

        document.title = 'Search';
        //thetop.toggleSimMode(top.div_simMode);
        if (document.searchForm.curContext.value == "catalog"  ||
            document.searchForm.curContext.value == "assembly" ) {
            
            for (i=0; i< document.searchForm.Display.options.length; i++) {
                if (document.searchForm.Display.options[i].value == modifiedStickyGroupBy) {
                    document.searchForm.Display.options[i].selected = true;
                    break;
                }
            }
        } else if (document.searchForm.curContext.value == "forecast") {
            for (i=0; i< document.searchForm.GroupBy.options.length; i++) {
                if (document.searchForm.GroupBy.options[i].value == modifiedStickyGroupBy) {
                    document.searchForm.GroupBy.options[i].selected = true;
                    break;
                }
            }
        }
/*      else { //forecasting
            if (showMetricsVal == 'yes') {
                document.searchForm.showMetrics[0].checked = true;
            }
            else {
                document.searchForm.showMetrics[1].checked = true;
            }
        }
*/
        //alert("<%=userState.get("catalog", "catalogSearchBy")%>");
        //alert("document.searchForm.searchBy.options.length = " + document.searchForm.searchBy.options.length + "  document.searchForm.searchBy.length = " + document.searchForm.searchBy.length);
       /* for (i=0; i< document.searchForm.searchBy.options.length; i++) {
            if (document.searchForm.searchBy.options[i].value == stickySearchBy) {
                document.searchForm.searchBy.options[i].selected = true;
                break;
            }
        }*/
        //alert(stickySearchBy);
        //operatorString = "";
        for (i=0; i< document.searchForm.operator.options.length; i++) {
            //operatorString += document.searchForm.operator.options[i].value + "  ";
            if (document.searchForm.operator.options[i].value == stickyOperator) {
                document.searchForm.operator.options[i].selected = true;
                break;
            }
        }
        //alert("stickyOperator = " + stickyOperator + "  operator string = " + operatorString);

        document.searchForm.searchValue.value = stickyValue;

        //filterNameString = "";
        var foundFilter = false;
		/* Following 8 lines of Code is added to restrict the data filter options to "none" for the configuration property "Copy_to_data_filter" set to "false" and all the values are displayed for the vlaue configuration property "Copy_to_data_filter" set to true */

		if(document.filterNames.document.searchForm.FilterName!=null){
	<%
			String copyToDataFilterConfigValue = Config.get("Copy_to_data_filter","false");
			if(copyToDataFilterConfigValue.equalsIgnoreCase("false")){
	%>			/*var noneOption = document.createElement("OPTION") 
				document.filterNames.document.searchForm.FilterName.options.add(noneOption) 
				noneOption.innerText = "None" 
				noneOption.Value = "0" 
				document.filterNames.document.searchForm.FilterName.length=1;	//displays option "none" only.	*/			
				document.filterNames.document.searchForm.FilterName.length=1;
	<%		}else{
			}
	%>	}
        for (i=0; i< document.filterNames.document.searchForm.elements[0].options.length; i++) {
            //filterNameString += document.searchForm.FilterName.options[i].value + "  ";

            if (document.filterNames.document.searchForm.elements[0].options[i].value == stickyFilterName) {
                document.filterNames.document.searchForm.elements[0].options[i].selected = true;
                foundFilter = true;
                break;
            }
        }

        checkLookup();
        //alert("stickyOperator = " + stickyOperator + "  operator string = " + operatorString);

        if ("<%=subcontext%>" == "savedFilter" || "<%=subcontext%>" == "savedList" || "<%=subcontext%>" == "editSavedList" || ("<%=subcontext%>" == "assignedItems" && foundFilter == true)) { //automatic search on open..
            if ('<%=selectedFilter%>' != 'worklist') {
                searchRequest('go','');
            }
            else {
                document.body.style.cursor = "auto";
            }
        }
        else if ("<%=subcontext%>" == "assignedItems" && foundFilter == false) {
            top.mcwarn('<%=messages.getString("error")%>','<%=messages.getString("thisAssignedItemFilterhasbeenremovedfromyourlist")%>');
            document.body.style.cursor = "auto";
        }
        else {
            document.body.style.cursor = "auto";
        }
		document.searchForm.searchValue.value="";
				fraCopyTo.style.display='none';
				selectedCT.style.display='none';
				fraCopyFrom.style.display='';
				selectedCF.style.display='';
				fraCopyFrom.style.width='662';
				fraCopyFrom.style.height='130';
				idCopyTo.style.display='none';
				clearallCFbtn.style.display = '';
				clearallCTbtn.style.display='none';
				idCopyFrom.style.display='';
				idDataFilter.style.display='none';
				idDtafilterDropDown.style.display='none';
				copy='copyFrom';
				recordsCount.innerHTML = '';
				idShowRelationships.style.display = 'none';
				buttongrp_selectall.style.display='none';
				if(flagCart){
					document.searchForm.Display.options[0] = new Option('Detail','detail');
					 /* for (i=0; i< displayNameArray.length;i++) {
					    if ('<%=subcontext%>' != 'findID') {

						document.searchForm.Display.options[1] = new Option(displayNameArray[i],displayValueArray[i]);
									//alert(""+displayNameArray[i]+"                "+displayValueArray[i]);
									break;
					    }
					 } */
					 flagCart = false;
				 }
				else{
					if(copyFromDropdownValue == 'detail'){
					        //alert("detail selected");
						document.searchForm.Display.options[0] = new Option('Detail','detail');
						 /*for (i=0; i< displayNameArray.length;i++) {
						    if ('<%=subcontext%>' != 'findID') {

							document.searchForm.Display.options[1] = new Option(displayNameArray[i],displayValueArray[i]);
										//alert(""+displayNameArray[i]+"                "+displayValueArray[i]);
										break;
					            }
					        }*/
					}
					else{	//alert("product selected");
						for (i=0; i< displayNameArray.length;i++) {
						    if ('<%=subcontext%>' != 'findID') {

							document.searchForm.Display.options[0] = new Option("Product","ALL_SKU");
										//alert(""+displayNameArray[i]+"                "+displayValueArray[i]);
										break;
					    	   }
					
					       }
					       document.searchForm.Display.options[1] = new Option('Detail','detail');
			             }
					
				}
				if(flagdisplay){
					copyFromDropdownValue = document.searchForm.Display.value;
					//alert("copyFromDropdownValue "+copyFromDropdownValue);
					flagdisplay = false;
				}
				 document.searchForm.searchValue.value="";
				document.fraResults.location.href="/app/blank.htm";
				copyFromLevel = document.searchForm.Display.value;

				 for(var i=0;i<document.searchForm.copyRadio.length;i++){
			if(document.searchForm.copyRadio[i].checked)
				 selectedRadioButtonValue = document.searchForm.copyRadio[i].value;
		}
		changeShoppingCart('copyTo');
    }

    function formSubmit()
    {
        form1.submit();
    }

    function getXMLdata (groupBy, mode) {

        var groupByValueArray = new Array();
        var groupByNameArray = new Array();
       
        searchByValueArray.length = 0;
        searchByNameArray.length =0;
        searchByTypeArray.length = 0;
        var m =0;
        var n = 0;
        var o = 0;
        var p = 0;
        var q = 0;
        var x = 0;
        var y = 0;
        //var c = curContext; //forecast, catalog etc..
        //alert("in getXMLdata");
        rootXML = document.all("stitchXML").XMLDocument;
        //alert("past rootXML");
        finderXML = rootXML.documentElement;
        //alert("past finderXML");
        numDiffItems = finderXML.childNodes.length;
        //alert("numDiffItems = " + numDiffItems);
        if (numDiffItems) {
            for (i=0;i<numDiffItems;i++) {
                hasItems = finderXML.childNodes[i].childNodes.length;
                if (hasItems) {
                    //alert("row 748...hasItems length = " + hasItems);
                    contextType = finderXML.childNodes[i]; //context tags
                    //alert("row 750..contextType = " + contextType.nodeName);
                    if (contextType.nodeName == document.searchForm.curContext.value) {
                        for (j = 0;j <hasItems;j++) {
                            inputField = contextType.childNodes[j]; //groupby or searchBy tags
                            //alert("row 754..inputField = " + inputField.nodeName);
                            if (inputField.childNodes.length) {
                                    for (k = 0; k< inputField.childNodes.length;k++) {
                                        dataField = inputField.childNodes[k]; //SKU or LINE tags
                                        if (dataField.childNodes.length) {
                                            for (l=0; l< dataField.childNodes.length; l++) {
                                                inputName = dataField.childNodes[l].nodeName; //result-set-name and display-name tags..
                                                inputValue = dataField.childNodes[l].firstChild.nodeValue; //node values to be used in drop-down..
                                                //alert(inputName + " = " + inputValue);
                                                if (inputField.nodeName == "groupBy") {
                                                    if (inputName == "result-set-name") {
                                                        groupByValueArray[m] = inputValue;
                                                        m++;
                                                    }
                                                    else {
                                                        groupByNameArray[n] = inputValue;
                                                        n++;
                                                    }
                                                }
                                                else {
                                                    //alert ("if inputField.nodeName [" + inputField.nodeName + "] == groupBy [" + groupBy + "]");
                                                    if (inputField.nodeName == "searchBy-" + groupBy || inputField.nodeName == groupBy) { //searchby

                                                        if (inputName == "result-set-name") {
                                                            searchByValueArray[o] = inputValue;
                                                            o++;
                                                        }
                                                        else {
                                                            if (inputName == "display-name") {
                                                                searchByNameArray[p] = inputValue;
                                                                p++;
                                                            }
                                                            else {
                                                                searchByTypeArray[q] = inputValue;
                                                                q++;
                                                            }
                                                        }
                                                    }
                                                    else {
                                                      if (inputField.nodeName == "display") { //display
                                                        if (inputName == "result-set-name") {
                                                            displayValueArray[x] = inputValue;
                                                            x++;
                                                        }
                                                        else {
                                                            displayNameArray[y] = inputValue;
                                                            y++;
                                                        }
                                                      }
                                                      else if (inputField.nodeName == "rowCount-Config") {
                                                        if (inputName == "rows-per-page") {
                                                            pageSize = inputValue-0;
                                                            //alert("pageSize=" + pageSize);
                                                        }
                                                        else if (inputName == "max-page-count") {
                                                            maxPageCount = inputValue-0;
                                                            //alert("maxPageCount=" + maxPageCount);
                                                        }
                                                        else if (inputName == "metrics-search") {
                                                            showMetricsVal = inputValue;
                                                        }
                                                        else if (inputName == "metrics-tree") {
                                                            showTreeMetricsVal = inputValue;
                                                        }
                                                        else if (inputName == "currClient") {
                                                            currClient = inputValue;
                                                        }
                                                      }
                                                    }
                                                }
                                            }
                                        }

                                    }

                            }
                        }
                    } //end if context
                }
            }
            if (mode == "open") {
                for (i=0; i< groupByNameArray.length;i++) {
                    document.searchForm.GroupBy.options[document.searchForm.GroupBy.length] = new Option(groupByNameArray[i],groupByValueArray[i]);
                }
                for (i=0; i< searchByNameArray.length;i++) {
                        //document.searchForm.searchBy.options[document.searchForm.searchBy.length] = new Option(searchByNameArray[i],searchByValueArray[i]);
						 //document.searchForm.searchBy.options[document.searchForm.searchBy.length] = new Option(searchByNameArray[i],searchByValueArray[i]);
						document.searchForm.searchBy.options[0] = new Option("Sales Item Id","VWPRODUCT_LEAF.LEAF_LABEL");
						document.searchForm.searchBy.options[1] = new Option("Sales Item Desc","VWPRODUCT_LEAF.DESCRIPTION");
						document.searchForm.searchBy.options[2] = new Option("Group Key Id","VWCUSTOMER_LEAF.LEAF_LABEL");
						document.searchForm.searchBy.options[3] = new Option("Group Key Desc","VWCUSTOMER_LEAF.DESCRIPTION");
						
						searchByNameArray[0] = "Sales Item Id";
						searchByNameArray[1] = "Sales Item Desc";
						searchByNameArray[2] = "Group Key Id";
						searchByNameArray[3] = "Group Key Desc";
						searchByNameArray[4] = "C SubRegion Desc";
						searchByNameArray[5] = "Channel Desc";
						searchByValueArray[0] = "VWPRODUCT_LEAF.LEAF_LABEL" ;
						searchByValueArray[1] = "VWPRODUCT_LEAF.DESCRIPTION";
						searchByValueArray[2] = "VWCUSTOMER_LEAF.LEAF_LABEL";
						searchByValueArray[3] = "VWCUSTOMER_LEAF.DESCRIPTION";
						
						searchByTypeArray[0] = 2;
						searchByTypeArray[1] = 2;
						searchByTypeArray[2] = 2;
						searchByTypeArray[3] = 2;
						

						//alert(""+searchByNameArray[i]+"           "+searchByValueArray[i]);
						break;
                }
                for (i=0; i< displayNameArray.length;i++) {
                    if ('<%=subcontext%>' != 'findID') {
						
                        document.searchForm.Display.options[document.searchForm.Display.length] = new Option("Product","ALL_SKU");
						//alert(""+displayNameArray[i]+"                "+displayValueArray[i]);
						break;
                    }
                    else { // add components, so only regular items are permitted..
                        if (displayValueArray[i] == 'ITEM') {
                            document.searchForm.Display.options[document.searchForm.Display.length] = new Option("Product","ALL_SKU");
                        }
                    }
                }
            }
            else { //change in display value, so only update search by drop-down..
                //alert("populate searchBy drop-down.. length = " + searchByNameArray.length);
                document.searchForm.searchBy.length = 0; //removes prior data before re-populating..
                for (i=0; i< searchByNameArray.length;i++) {
                        document.searchForm.searchBy.options[document.searchForm.searchBy.length] = new Option(searchByNameArray[i],searchByValueArray[i]);
                }
            }
        }

    }

    function onDisplayChange() {

		//alert("in display change");
		for(var i=0;i<document.searchForm.copyRadio.length;i++){
			if(document.searchForm.copyRadio[i].checked)
				var findItem = document.searchForm.copyRadio[i].value;
			if(findItem == 'copyFrom'){
				var rows = saveData2.rows;
				//alert("rows length is  "+ rows.length);
				if(rows.length>0){
					if (top.mcalert('<%=messages.getString("warning")%>','<%=messages.getString("warning")%>'+':','<%=messages.getString("searchCatalog_relationships_YoumustcleartheshoppingcartwhenchangingDisplayLevel")%>','<%=messages.getString("searchCatalog_relationships_bg_okcancel")%>',500,210,'sounds/error.wav') == 'OK'){
						recordsCount.innerHTML = '';
						document.fraResults.location.href="/app/blank.htm";
						clearAllFromRows(saveData2);
						document.searchForm.searchValue.value="";
						parent.detailtext.style.display = 'none';
						parent.producttext.style.display = 'none';
						copyFromLevel = document.searchForm.Display.value;
					}
					else{
						document.searchForm.Display.options[0] = new Option('Detail','detail');
						document.searchForm.Display.options[1] = new Option(displayNameArray[0],displayValueArray[0]);
							//alert(""+displayNameArray[i]+"                "+displayValueArray[i]);
							
						
					}
				}
					
				copyFromLevel = document.searchForm.Display.value;
				//alert("copyfrom level is  "+copyFromLevel);
			}
			copyFromDropdownValue = document.searchForm.Display.value;
			
			
		}
		
		document.searchForm.searchValue.value="";
       
    }

    function onGroupByChange() {
        var newSelection = document.searchForm.GroupBy.value;
        //alert("newSelection = " + newSelection);
        getXMLdata(newSelection, 'changeGroupBy');
        var stickySearchByExists = false;

        // first enable all the controls since we might have disabled them before.
        document.searchForm.operator.disabled = false;
        document.searchForm.searchValue.disabled = false;
        document.searchForm.searchBy.disabled = false;
        
        for (i=0; i< document.searchForm.searchBy.options.length; i++) {
            if (document.searchForm.searchBy.options[i].value == stickySearchBy) {
                document.searchForm.searchBy.options[i].selected = true;
                document.searchForm.searchValue.value= stickyValue;
                for (j=0; j< document.searchForm.operator.options.length; j++) {
                    if (document.searchForm.operator.options[j].value == stickyOperator) {
                        document.searchForm.operator.options[j].selected = true; //set the operator
                        break;
                    }
                }
                stickySearchByExists = true;
                break;
            }
        }
        
        if (stickySearchByExists == false) { // we don't have sticky values here, so need to reset to some default..
            for (i=0; i< document.searchForm.operator.options.length; i++) {
                if (document.searchForm.operator.options[i].value == 1) { //was 1
                    document.searchForm.operator.options[i].selected = true; //set the operator to equals, which is valid for any data type..
                    break;
                }
            }
            document.searchForm.searchValue.value= ""; //will return all rows
        }

        // Depending on the customer,
        // force the searchby to change when it is grouped by Product 'ALL' plane id
        top.implForceSearchBy(currClient, newSelection, stickySearchByExists, stickyValue);
        
        checkLookup();
    }

    function onRefreshFilter(fName) {
        curcontext = document.searchForm.curContext.value;
        document.all.filterNames.src="/efm/FilterList?context=" + curcontext + "&selectedFilterId=" + fName + "&subcontext="; //stickyFilterName;
        this.focus();
    }

    function onMoveAll() {
        idBusy.style.display='';
        showConfirm();

        if (document.fraResults.detailForm) {
            fraResults.moveAll();
        }
        else {
            idBusy.style.display = 'none';
            top.mcwarn('<%=messages.getString("warning")%>'+':','<%=messages.getString("therearenosearchresultstoselect")%>');
            return;
        }
        if (datadirty == false) {
            idBusy.style.display = 'none';
        }
    }

    function showConfirm() {
        w = 350;
        h = 170;
        var rowsToMove = 0;
        if (fraResults.resultsTable) {
            rowsToMove = fraResults.resultsTable.rows.length-2;
        }
        if (rowsToMove > 0) {
            var param = new Object();
            param.icon = 'info';
            param.title = '<%=messages.getString("itemlist_search_MoveAll")%>';
            param.message = '<%=messages.getString("pleasewait")%>'+'..'+'<%=messages.getString("itemlist_search_Moving")%>' + rowsToMove + '<%=messages.getString("itemlist_search_records")%>';
            param.timerDuration = 2 * 1000;

            retval = top.showModalDialog('/app/mcalert.htm', param, 'dialogHeight: ' + h + 'px; dialogWidth: ' + w + 'px; dialogTop: px; dialogLeft: px; center: Yes; help: No; resizable: No; status: No; scroll: No' );
        }
    }

    function afterSubmit() {
        if ('<%=subcontext%>' == 'findID' && top.dialogArguments.mode != 'single') {
            //alert("thetop.name" + thetop.name);
            datadirty=false;
            thetop.refreshComponents();
            top.close()
        }
        else {
            this.focus();
        }
    }

    function on_window_unload() {
        thetop.searchwin=null;
        if (dialogArguments.opener != 'ambassador'
            && document.searchForm.curContext.value == 'forecast'
            && '<%=subcontext%>' != 'savedFilter') {
            //alert("about to refresh forecast wc..");
            top.refreshForecastWC();
        }
        else if (dialogArguments.opener != 'ambassador'
            && document.searchForm.curContext.value == 'catalog') {
            if ('<%=subcontext%>' == 'findID' && top.dialogArguments.mode != 'single') {
                if (datadirty == true) {
                    top.mcwarn('<%=messages.getString("error")%>'+':','<%=messages.getString("donotclosethescreenwhentheapplicationissavingdata")%>');
                    return false;
                }
            }
        }
    }

    function check_key() {
        if (window.event) {
            window.event.cancelBubble = true;
        }
        else {
            return true;
        }
        //alert(window.event.keyCode);
        switch (window.event.keyCode) {
            case 13: { //enter
                searchRequest('go','');
            }
            return false;
        }
        return true;
    }

    function openFilterBrowser() {
        callFrom=0;
        callFromType="";
        curSelString = "";
        for (i=0;i<document.searchForm.elements.length; i++) {
            if (document.searchForm.elements[i].name == "searchValue") {
                callFrom = i;
                curSelString = document.searchForm.elements[i].value;
                break;
            }
        }
        if ("<%=context%>" == "catalog") {
            callFromType=document.searchForm.Display.value;
        }
        else { //forecast
            callFromType="forecast";
        }
        hierarchyType="product/ITEM";
        var param = new Object();
        param.caller = top;
        //alert('/efm/SingleLookup?context=<%=context%>&targetFrame=search&lookupField=' + lookupField + '&callFrom=' + callFrom + '&callFromName=' + callFromType + '&callFromLabel=' + lookupLabel + '&curSelString=' + curSelString);
        lookupwin = showModalDialog('/efm/SingleLookup?context=<%=context%>&targetFrame=search&lookupField=' + lookupField + '&callFrom=' + callFrom + '&callFromName=' + callFromType + '&callFromLabel=' + lookupLabel + '&curSelString=' + curSelString, param,'dialogHeight: 500px; dialogWidth: 380px; dialogTop: px; dialogLeft: px; center: Yes; help: No; resizable: No; status: No; scroll: Yes;' );

    }

    function checkLookup() {
        //alert("in checkLookup()");
        for (i=0; i < searchByValueArray.length;i++) {
            if (searchByValueArray[i] == document.searchForm.searchBy.value) {
                switch (searchByTypeArray[i]-0) { //converts string to integer by subtracting zero
                        case 1: //number
                            //alert("Number value="+searchByValueArray[i] + "  name="+searchByNameArray[i]);
                            if (searchByValueArray[i]=='VWPRODUCT_LEAF.IS_FORECASTED') {
                                idSearchText.innerHTML='<%=messages.getString("enter1forforecasteditemsor0fornotforecasteditems")%>';
                            }
                            else if (searchByValueArray[i]=='VWPRODUCT_LEAF.IS_NEW') {
                                idSearchText.innerHTML='<%=messages.getString("enter1fornewitemsor0forexistingitems")%>';
                            }
                            else if (searchByValueArray[i]=='VWPRODUCT_LEAF.IS_DISCONTINUED') {
                                idSearchText.innerHTML='<%=messages.getString("enter1fordiscontinueditemsor0foractiveitems")%>';
                            }
                            else {
                                idSearchText.innerHTML='';
                            }
                            idLookup.style.display = 'none';
                            break;
                        case 2:
                            //alert("String value="+searchByValueArray[i] + "  name="+searchByNameArray[i]);
                            if (searchByValueArray[i] !='STATUS') {
                                idLookup.style.display = '';
                                lookupField = searchByValueArray[i];
                                lookupLabel = searchByNameArray[i];
                                idSearchText.innerHTML='';
                            }
                            else {
                                idLookup.style.display = 'none';
                                idSearchText.innerHTML='<%=messages.getString("itemlist_search_StatuscanhavethefollowingvaluesChanged")%>';
                            }
                            break;
                        case 3:
                            idLookup.style.display = 'none';
                            idSearchText.innerHTML='';
                            break;
                        case 4:
                            idLookup.style.display = 'none';
                            idSearchText.innerHTML='';
                            break;
                }
            }
        }
        searchValueChange();
    }

/*  function getMetricsVal() {
        if (document.searchForm.showMetrics[0].checked == true) {
            showMetricsVal = "yes";
        }
        else {
            showMetricsVal = "no";
        }
    }
*/

    document.onkeypress =
    function (evt) {
        var c = document.layers ? evt.which
            : document.all ? event.keyCode
            : evt.keyCode;
        //alert('pressed ' + String.fromCharCode(c) + '(' + c + ')');
        if (top.treemode == 0) { //doesn't work for tree search
            if (c == 13) { //Enter key
                searchRequest('go','');
            }
            return true;
        }
    };

    function closeIt() {
        if (datadirty == true && globalOkToClose == false) {
            event.returnValue = '<%=messages.getString("msg_warning")%>'+'<%=messages.getString("itemlist_search_Closingthescreenwhenthesystemisbusy")%>';
        } else if (dialogArguments.opener == 'ambassador') {
            window.external.close();
        } else if ('<%=context%>' == 'forecast') {
            if (!('<%=subcontext%>' == 'savedFilter' && ('<%=selectedFilter%>' == 'worklist' || '<%=selectedFilter2%>' == 'worklist'))) { //worklist
                top.refreshForecastWC();
            }
        }
    }

    function searchValueChange() {
        searchValuesChanged = true;
    }


    //document.onclick=top.dialogArguments.caller.doc_click;

</script>
</head>
<body onbeforeunload="closeIt()" class="globalBody" onload="window_onload()" style="background-position: 0% 0%; background-color:transparent; background-repeat:no-repeat; background-attachment:scroll">
<table border="0" cellpadding="0" cellspacing="0" width="100%">
  <tr>
    <td width="120"><img class="swlogo" border="0" src='<%= logo %>' ondragstart="return false;"
                         onClick="document.getElementById('elapsedTimeTr').style.visibility='visible';"></td>
    <td nowrap class="headertext">
        <req:equalsParameter name="context" match="forecast">
            <%=messages.getString("searchResultsForecastItems")%>
        </req:equalsParameter>
        <req:equalsParameter name="context" match="catalog">
            <%=messages.getString("searchResultsCatalogItems")%>
        </req:equalsParameter>
        <req:equalsParameter name="context" match="assembly">
             <%=messages.getString("searchResultsCatalogItems")%>
        </req:equalsParameter>
        <font color="#ff0000"><%= (Config.get("SYSTEM_NAME","")) %></font>

        <br>
        <span id="div_simMode" style="display:none;font-family:Arial;color:red;font-size:10;font-weight:bold"></span>
    </td>
    <td align="right">
    <img class="company_logo" src='<%= companylogo %>'></td>
  </tr>
</table>
<div class="darkline"><img src="/app/images/blank.gif" border="0" alt="" width="1" height="1"></div>
<form name="searchForm" action="#" target="_self" method="POST">
<input type="hidden" name="curContext" value=<%=request.getParameter("context")%>>
<input type="hidden" name="hdnSelectedID" value="">
<input type="hidden" name="hdnSelectedType" value="">
<input type="hidden" name="hdnSelectedDesc" value="">
<input type="hidden" name="hdnSelectedSKU" value="">
<input type="hidden" name="hdnRecordCount" value="">
<input type="hidden" name="hdnSelectedTemp" value="">
<input type="hidden"  name="hdnSelectedItemid" value="">

<input type="hidden" name="hdnSearchBy" value="">
<input type="hidden" name="hdnOperator" value="">
<input type="hidden" name="hdnGroupBy" value="">
<input type="hidden" name="hdnFilterId" value="">
<input type="hidden" name="hdnSearchValue" value="">
<input type="hidden" name="hdnDescription" value="">
<input type="hidden" name="hdnTooltip" value="">



<table border="0" width="97%" align="center" cellpadding="0" cellspacing="5">
 <tr>
    <td id="divFilter" valign="top" style="display:none;padding-right:5;padding-left-15">
        <table border="0" cellpadding="0" cellspacing="2" width="100%">
          <tr>
            <td colspan="4">
                <table border="0" cellspacing="0" width="100%">
                    <Tr>
                        <td style="padding-top:5px">
                            <div class="tab-pane" style="display:none" id="tabPane1" onClick="checkTabClick()">
                                <div class="tab-page" id="tabPage1">
                                    <span url="changeView('search')" mctabtext='<%=messages.getString("worksheet_Search")%>' class="tab"></span>
                                </div>
                                <div class="tab-page" id="tabPage2">
                                    <span url="changeView('tree')" mctabtext='<%=messages.getString("search_Tree")%>' class="tab"></span>
                                </div>
                            </div>
                            <div class="tab-pane" style="display:none" id="tabPane12" onClick="checkTabClick()">
                                <!-- <div class="tab-page" id="tabPage1">
                                    <span url="changeView('search')" mctabtext='<%=messages.getString("worksheet_Search")%>' class="tab"></span>
                                </div> -->
                            </div>
                            <span id="rv_hide" style="display:'';position:absolute;top:97px;left:255px">
                            <img src='<%=hide %>' border="0" style="cursor:hand" onClick="expandResultsView()" width='<%=messages.getString("search_hide_width_key3")%>' height='<%=messages.getString("search_hide_height_key3")%>' ONDRAGSTART="return false"></span>
                        </td>
                    </tr>
                </table>
                <!-- <div class="darkline">
                  <img src="/app/images/blank.gif" border="0" alt="" width="1" height="1"></div> -->
            </td>
          </tr>
        </table>
        <div id="idSearch" style="display:''">
		<table width="300">
			<tr>
				<td class="fieldlabel"  width="150" valign="middle" align="left" nowrap><%=messages.getString("searchCatalog_relationships_FindItemsTo")%>:</td>
			</tr>
			<tr>
				<td class ="normaltext"><input type="radio" id="radioctbtn" name="copyRadio" checked value="copyTo" onClick="changeShoppingCart('copyTo')"><%=messages.getString("searchCatalog_relationships_CopyTo")%></td>
				<td></td>
				<td></td>
			</tr>
			<tr>
				<td class ="normaltext"><input type="radio" id="radiocfbtn" name="copyRadio"  value="copyFrom" onClick="changeShoppingCart('copyFrom')"><%=messages.getString("searchCatalog_relationships_CopyFrom")%></td>
				<td></td>
				<td></td>
			</tr>
			
			<tr>
			 <tr>
				 <td align="right" colspan="10" style="border-top:1px solid #CCCCCC;padding-top:3px;"></td>
           
           </tr>
		</table>
		
        <table border="0" cellpadding="0" cellspacing="0" width="300">
          <tr>
		   
          <td class="fieldlabel"  width="71" valign="middle" align="left" nowrap><span id="idDataFilter" style="display:''"><%=messages.getString("dataFilter")%>:</span></td>
          <td>
		 
		  <span id="idDtafilterDropDown" style="display:''"> 
           <table  align="left" border="0" cellpadding="1" cellspacing="0" width="100%">
           <tr>
            <td nowrap align="left" valign="middle">
                <iframe name="filterNames" class="iframe1" src="<%= filterListURL %>" width="180" height="27" marginheight="0" marginwidth="0" frameborder="0" align="left" scrolling="no"></iframe>
            </td>
		     <% String dataFilterConfigValue = Config.get("Copy_to_data_filter","false");
				if(dataFilterConfigValue.equalsIgnoreCase("true")){
			%>		<td valign="middle">
                <img src="/app/images/icons/mnu_edit_g.gif" border="0" style="cursor:hand"  alt='<%=messages.getString("search_admin_EditSelectedFilter")%>' onClick="openFilterWin()" ondragstart="return false">
                <img src="/app/images/icons/newxp_g.gif" border="0" style="cursor:hand" alt='<%=messages.getString("search_admin_DefineNewFilter")%>' onClick="openNewFilterWin()" ondragstart="return false">
			<%	}
			%>

            </td>
            </tr>
            </table>
			</span> 
          </td>
          </tr>
         </table>
         <div id="idGroupBy" style="display:none">
         <table border="0" cellpadding="1" cellspacing="0" width="300">
           <tr>

            <td align="left" width="70" class="fieldlabel">
                <%=messages.getString("searchCatalog_relationships_GroupBy")%>:
            </td>
            <td valign="top"><select onChange="onGroupByChange()" class="selInput_sm" name="GroupBy" style="width:175px">
                <!--option value="None">None</option-->
            </select>
            </td>
          </tr>
          <!--tr><td>&nbsp;</td></tr>
          <tr>
           <td align="left" width="70" class="fieldlabel">
            Show Metrics:
           </td>
           <td class="normaltext">&nbsp;
            <input type="radio" checked name="showMetrics" value="Yes"> Yes
            &nbsp;&nbsp;
            <input type="radio" name="showMetrics" value="No"> No
           </td>
          </tr-->
          </table>
          </div>
          <div id="idDisplay" style="display:none">
          <table border="0" cellpadding="1" cellspacing="0" width="300">
          <tr>
            <td align="left" width="70" class="fieldlabel">
                <%=messages.getString("itemlist_search_Display")%>:
            </td>
            <td valign="top"><select onChange="onDisplayChange()" class="selInput_sm" name="Display" style="width:175px">
			
            </select>
            </td>
          </tr>
          </table>
          </div>
		<br>
        <table border="0" cellpadding="0" cellspacing="2">
          <tr>
            <td valign="top" nowrap class="fieldlabel" style="padding-top:1px">
               <%=messages.getString("itemlist_search_SearchBy")%>:<br>
                <select class="selInput_sm" onChange="checkLookup()" name="searchBy" style="width:120px">
                </select>
<!--                <option value="SKU">SKU</option>
                <option value="Long Description">Description</option>
                <option value="Product Family">Product Family</option>
                <option value="Color">Color</option>

                </select>
-->
            </td>
            <td valign="top" nowrap style="padding-top:16px">
            <select class="selInput_sm" onChange="searchValueChange()" name="operator" style="width:85px">
                <option value="<%= searchCriteria.STARTS_WITH %>"> <%=messages.getString("xsl_starts_with")%></option>
                <option value="<%= searchCriteria.EQUALS %>"><%=messages.getString("xsl_equals")%></option>
                <option value="<%= searchCriteria.GREATER_THAN %>"><%=messages.getString("xsl_greater_than")%></option>
                <option value="<%= searchCriteria.LESS_THAN %>"><%=messages.getString("xsl_less_than")%></option>
                <option value="<%= searchCriteria.NOT_EQUALS %>"><%=messages.getString("xsl_not_equal_to")%></option>
                <option value="<%= searchCriteria.LIKE %>"><%=messages.getString("xsl_contains")%></option>
<!--            <option value="<%//= searchCriteria.LESS_THAN_EQUAL %>">less than or equal to</option>
                <option value="<%//= searchCriteria.GREATER_THAN_EQUAL %>">greater than or equal to</option>
                <option value="<%//= searchCriteria.IS_NULL %>">is null</option>
                <option value="<%//= searchCriteria.IS_NOT_NULL %>">is not null</option>
                <option value="<%//= searchCriteria.LIKE %>">is like</option>
                <option value="<%//= searchCriteria.NOT_LIKE %>">is not like</option>
                <option value="<%//= searchCriteria.BETWEEN %>">between</option>
                <option value="">in</option>
-->
            </select>
            </td>
            <td valign="top" nowrap style="padding-top:16px"><input type="text" onKeyPress="return check_key();" onChange="searchValueChange()" class="selInput_sm" name="searchValue" value="" size="7"></td>
             <td valign="top" style="padding-top:16px" width="20">
                <span id="idLookup" style="display:none"><img src="/app/images/icons/lookupicon.gif" style="cursor:hand" onClick="openFilterBrowser()" border="0" alt='<%=messages.getString("itemlist_search_LookupSearchValue")%>' width="16" height="13" ONDRAGSTART="return false"/></span>
            </td>
          </tr>
		  </table>
		  <br>
		  <table>
		  <tr>
		  <td>
			<span id="idShowRelationships" style="display:'none'" class="fieldlabel">
                        <%=messages.getString("relationships")%>:&nbsp;<select name="showRelationships" onChange="searchValueChange()" style="font-family:Arial;font-size:11px;width:200px">
						<!--<option value="without"> <%//=messages.getString("searchCatalog_relationships_ItemsWithoutRelationship")%></option>
                        <option value="with"><%//=messages.getString("searchCatalog_relationships_ItemsWithRelationship")%></option>-->
						<option value="all"><%=messages.getString("allItems")%></option>
                        
                        </select>
             </span>
			 </td>
		  </tr>
           <tr>
            <td colspan="1">
                <br>
            </td>
           </tr>
		   <table>
		   <table align="right">
           <tr>
            <td align="right" colspan="1" align="right" >
                <img onClick="searchRequest('go','')" src='<%=arwrgt2 %>' border="0" alt='<%=messages.getString("filter_browse_Search")%>' style="cursor:hand" vspace="0" width='<%=messages.getString("search_go_width_key3")%>' height='<%=messages.getString("search_go_height_key3")%>' ONDRAGSTART="return false">
            </td>
           </tr>
           <tr>
           <td colspan="3" class="important_text">
           <span id="idSearchText"></span>
           </td>
           <td>&nbsp;</td>
           </tr>
           <tr>
           <td colspan="3" class="normaltext">
           <span id="idPLMText"></span>
           </td>
           </tr>
           <tr>
           <td colspan="3" align="center" class="important_text">
           <span id="idBusy" style="display:none"><%=messages.getString("pleasewait")%>..<br><img src="/app/images/loading4.gif" border="0"/></span>
           </td>
           </tr>
        </table>
		<table>
		<!--<td>Your Selection : -->
		</table>
		<br>
		<br>
		<br>
		<br>
		<br>
		<br>
		<table>
		<tr>
		<td class="fieldlabel">
			<%=messages.getString("searchCatalog_relationships_CurrentSelection")%>:
		</td>
		</tr>
		<tr>
		<td>
			<span id="selectionCT" style="display:''" class="normaltext">&nbsp;&nbsp;&nbsp;&nbsp;<%=messages.getString("searchCatalog_relationships_CopyRelationshipTo")%>:&nbsp;&nbsp;<span id="selectiontocount">0</span> <%=messages.getString("searchCatalog_relationships_Products")%></span>
			</td>
		</tr>
		<tr>
		<td>
			<span id="selectionCF" style="display:''" class="normaltext">&nbsp;&nbsp;&nbsp;&nbsp; <%=messages.getString("searchCatalog_relationships_CopyRelationshipFrom")%>:&nbsp;&nbsp;<span id="selectionfromcount">0</span><span id="detailtext" style="display:'none'" class="normaltext"><span id="detaildisplay">    <%=messages.getString("relationships")%> </span></span><span id="producttext" style="display:'none'" class="normaltext"><span id="productdisplay">   &nbsp;&nbsp;<%=messages.getString("searchCatalog_relationships_Products")%> </span></span></span>
		</td>
		</tr>
		
		</table>

        </div>
        <div id="idTree" style="display:none">
            <iframe name="fraTree" width="300" marginheight="0" marginwidth="0" src="/efm/SearchTree?context=<%=request.getParameter("context")%>" height="348" frameborder="0"></iframe>
        </div>
    </td>
    <td id="rv_show" style="display:none" valign="top" style="padding-top:4px">
    <img src='<%=show%>' border="0" style="cursor:hand" onClick="collapseResultsView()" width='<%=messages.getString("search_show_width_key3")%>' height='<%=messages.getString("search_show_height_key3")%>' ONDRAGSTART="return false">
    </td>
    <td valign="top" style="padding-top:5">
        <span id="searchResults" style="display:none">
        <table border="0" cellspacing="0" width="100%">
            <Tr>
                <td class="sectiontitle"><%=messages.getString("searchResults")%> &nbsp;<span id="recordsCount"></span>&nbsp;<span id="idTreeType"></span></td>
                <td align="right" class="normaltext" nowrap style="display:none">
                    <input type="Radio" name="mode" value="live" checked onClick="this.blur();simTypes.style.display='none'"><span style="cursor:hand" onClick="form1.mode[0].checked=true;simTypes.style.display='none'"><%=messages.getString("liveData")%></span>&nbsp;&nbsp;<input type="Radio" name="mode" value="simluation" onClick="simTypes.style.display='';form1.simType.focus()"><span style="cursor:hand" onClick="document.form1.mode[1].checked=true;simTypes.style.display='';form1.simType.focus()"><%=messages.getString("simulation")%></span>
                    <span id="simTypes" style="display:none">
                    <select name="simType" style="font-family:Arial;font-size:11px;width:130px">
                    <option><%=messages.getString("johnSimulation")%>
                    <option><%=messages.getString("mandatoryOvertime")%>
                    <option><%=messages.getString("new")%>
                    </select>
                    </span>
                </td>
            </tr>
        </table>
        <div class="darkline"><img src="/app/images/blank.gif" border="0" alt="" width="1" height="1"></div>
            <iframe name="fraResults" class="iframe1" src="<%= searchResultsURL %>" width="662" height="200" frameborder="1"></iframe>
            <br><img src="/app/images/blank.gif" height="10" width="1" border="0"><br>

            <table width="100%" cellpadding="0" cellspacing="0" border="0">
                <tr>
                    <td width="27%" class="normaltext">
                        <span id="idShowMetrics" style="display:'none'">
                        <input type="checkbox" name="showMetrics" value="">&nbsp;<%=messages.getString("showMetrics")%>
                        </span>
                        
                    </td>
                    <td width="36%" align="right">
                        <table cellpadding="0" cellspacing="0" border="0">
                            <tr>
                                <td onclick="searchRequest('previous','')" class="clsBtnOff" nowrap onmouseover="this.className='clsBtnUp';event.cancelBubble = true;" onmouseout="this.className='clsBtnOff';event.cancelBubble = true;" onmousedown="this.className='clsBtnDown';event.cancelBubble = true;" onmouseup="this.className='clsBtnUp';event.cancelBubble = true;">
                                    <img src='<%=prevrec2 %>' border="0" width='<%=messages.getString("search_prevrec2_width_key3")%>' height='<%=messages.getString("search_prevrec2_height_key3")%>' alt='<%=messages.getString("principal_search_PreviousPage")%>' ONDRAGSTART="return false">
                                </td>
                                <td>
                                    <select name="pageN" class="selInput" onChange="if (this.selectedIndex != this.options.length) { searchRequest(this.options[this.selectedIndex].value, ''); }">
                                    </select>
                                </td>
                                <td onclick="searchRequest('next','')" class="clsBtnOff" nowrap onmouseover="this.className='clsBtnUp';event.cancelBubble = true;" onmouseout="this.className='clsBtnOff';event.cancelBubble = true;" onmousedown="this.className='clsBtnDown';event.cancelBubble = true;" onmouseup="this.className='clsBtnUp';event.cancelBubble = true;">
                                    <img src='<%=nextrec2 %>' border="0" style="margin-top:2; cursor:hand;" alt='<%=messages.getString("principal_search_NextPage")%>' width='<%=messages.getString("search_nextrec2_width_key3")%>' height='<%=messages.getString("search_nextrec2_height_key3")%>' ONDRAGSTART="return false">
                                </td>
                            </tr>
                        </table>
                    </td>
                    <td width="37%" align="right">
                        <div id="buttongrp_selectall" style="display:none;">
                            <img src='<%=butselall %>' border="0" style="cursor:hand" alt='<%=messages.getString("itemlist_search_SelectAllRecords")%>' onclick="onMoveAll()" width='<%=messages.getString("search_butselall_width_key3")%>' height='<%=messages.getString("search_butselall_height_key3")%>' ONDRAGSTART="return false">
                        </div>
                        <div id="buttongrp_selectone" style="margin-top:5px; display:none;">
                            <img src='<%=butcancel %>' border="0" style="cursor:hand" alt='<%=messages.getString("user_detail_dialog_Cancel")%>' onclick="top.window_close()" width="80" height="19" ONDRAGSTART="return false">&nbsp;<img src='<%=butsel %>' border="0" style="cursor:hand" onclick="fraResults.selectOne()" width="80" height="19" ONDRAGSTART="return false">
                        </div>
                    </td>
                </tr>
            </table>
            <br>
            </span>
            <span id="selectedRS" style="display:none" class="sectiontitle"><%=messages.getString("selectedRecords")%>&nbsp;&nbsp;(<span id="srcount">0</span> <%=messages.getString("records")%>)</span>
            <div class="allborders" name="fraSelected" id="fraSelected" style="display:none;overflow-x:auto; overflow-y:auto; width:662px; height:150px;padding:10px">
                <table border="0" cellpadding="1" cellspacing="0" id="saveData">
                                    <tbody id="otbody">
                                    </tbody>
                </table>
            </div>
			<table border="0" width="100%" style="display:'none'" id="idCopyTo">
			<td>
			<span id="selectedCT" style="display:none" class="sectiontitle"><%=messages.getString("searchCatalog_relationships_CopyRelationshipTo")%>&nbsp;&nbsp;(<span id="tocount">0</span> <%=messages.getString("records")%>)</span>
			</td>
			
			</table>

			 <div class="allborders" name="fraCopyTo" id="fraCopyTo" style="display:'none';overflow-x:auto; overflow-y:auto; width:662px; height:160px;padding:10px">
                <table border="0" cellpadding="1" cellspacing="0" id="saveData1">
                                    <tbody id="otbody">
                                    </tbody>
                </table>
            </div>
			<table border="0" width="100%" style="display:'none'" id="idCopyFrom">
			<td>
			<span id="selectedCF" style="display:none" class="sectiontitle"><%=messages.getString("searchCatalog_relationships_CopyRelationshipFrom")%>&nbsp;&nbsp;(<span id="fromcount">0</span> <%=messages.getString("records")%>)</span>
			</td>
			
			</table>
			
			 <div class="allborders" name="fraCopyFrom" id="fraCopyFrom" style="display:'none';overflow-x:auto; overflow-y:auto; width:662px; height:160px;padding:10px">
                <table border="0" cellpadding="1" cellspacing="0" id="saveData2">
                                    <tbody id="otbody">
                                    </tbody>
                </table>
            </div>
			<br>
<req:equalsParameter name="context" match="forecast">
<%
    if(subcontext.equalsIgnoreCase("undefined") ||
        subcontext.equalsIgnoreCase("savedFilter") ||
        subcontext.equalsIgnoreCase("savedList") ||
        subcontext.equalsIgnoreCase("editSavedList") ||
        subcontext.equalsIgnoreCase("assignedItems")) {
%>
            <br><%-- Right Mouse Context Menu --%>
                <div id="cntxtMenu" onClick="top.clickMenu('editmenu',self);event.returnValue=0;" onmouseover="top.dialogArguments.caller.toggleMenu(self)" onmouseout="top.dialogArguments.caller.toggleMenu(self)" oncontextmenu="return false;" style="display:none;z-index:100;position:absolute;background-Color:#FEFEFE; height:45px; width:150px; border: 2px outset #FFFFFF; padding-top:5; padding-bottom:5;overflow-y:none;background-image: url('/app/images/menuleftbg5.gif')">
<%
        if (subcontext.equalsIgnoreCase("savedList") ||
            subcontext.equalsIgnoreCase("editSavedList")) {
%>
                <!--    <table cellpadding="0" cellspacing="0">
                    <tr><td><img src="/app/images/icons/excel_g_sm.gif" style="margin-left:3;margin-right:9;" width="17" height="14"></td>
                        <td class="menuItemImg" id="mnuExcelOpen">Open in Excel</td>
                    </tr></table>-->
                    <!--table cellpadding="0" cellspacing="0">
                    <tr><td><img src="/app/images/icons/mnu_save_g.gif" style="margin-left:3;margin-right:9;" width="15" height="13"></td>
                        <td class="menuItemImg" id="mnuAddsavedList">Add Item to Saved List</td>
                    </tr></table-->
                    <table cellpadding="0" cellspacing="0">
                    <tr><td><img src="/app/images/icons/mnu_delete_g.gif" style="margin-left:3;margin-right:9;" width="15" height="13"></td>
                        <td class="menuItemImg" id="mnuRemoveFromSavedList"><%=messages.getString("removeItemfromSavedList")%></td>
                    </tr></table>
                    <div class="menuItemHR" id="mnuLine"><hr size="1" class="menuhr"></div>
                    <div class="menuItem" id="mnuCloseMenu"><%=messages.getString("closeMenu")%></div>

<%
        } else {
%>
                <!--
                    <table cellpadding="0" cellspacing="0">
                    <tr><td><img src="/app/images/mnu_edit_g.gif" style="margin-left:3;margin-right:9;" width="16" height="13"></td>
                        <td class="menuItemImg" id="mnuEditPriority">Edit Priority</td>
                    </tr></table>
                    <table cellpadding="0" cellspacing="0">
                    <tr><td><img src="/app/images/mnu_edit_g.gif" style="margin-left:3;margin-right:9;" width="16" height="13"></td>
                        <td class="menuItemImg" id="mnuEditCatalogItem">View Catalog Item</td>
                    </tr></table>-->
                 <!--   <table cellpadding="0" cellspacing="0">
                   <tr><td><img src="/app/images/icons/excel_g_sm.gif" style="margin-left:3;margin-right:9;" width="17" height="14"></td>
                        <td class="menuItemImg" id="mnuExcelOpen">Open in Excel</td>
                    </tr></table>-->
                    <table cellpadding="0" cellspacing="0">
                    <tr><td><img src="/app/images/icons/mnu_save_g.gif" style="margin-left:3;margin-right:9;" width="15" height="13"></td>
                        <td class="menuItemImg" id="mnuAddsavedList"><%=messages.getString("addItemtoSavedList")%></td>
                    </tr></table>
                    <div class="menuItemHR" id="mnuLine"><hr size="1" class="menuhr"></div>
                    <div class="menuItem" id="mnuCloseMenu"><%=messages.getString("closeMenu")%></div>

<%
        }
    }
%>
            </div>
</req:equalsParameter>
            <%-- Right Mouse Context Menu --%>
                <div id="cntxtMenuTop" onClick="top.clickMenu('editmenu',self);event.returnValue=0;" onmouseover="top.dialogArguments.caller.toggleMenu(self)" onmouseout="top.dialogArguments.caller.toggleMenu(self)" oncontextmenu="return false;" style="display:none;z-index:100;position:absolute;background-Color:#FEFEFE; height:45px; width:150px; border: 2px outset #FFFFFF; padding-top:5; padding-bottom:5;overflow-y:none;background-image: url('/app/images/menuleftbg5.gif')">
                    <table cellpadding="0" cellspacing="0"><tr><td>
                    <img src="/app/images/icons/mnu_moveup.gif" style="margin-left:3;margin-right:9;" width="16" height="18" ONDRAGSTART="return false"></td><td class="menuItemImg" id="mnuMoveUpLevel"><%=messages.getString("itemlist_search_Moveuplevel")%></td></tr></table>
                    <table cellpadding="0" cellspacing="0"><tr><td>
                    <img src="/app/images/icons/closedxp_o.gif" style="margin-left:3;margin-right:9;" width="16" height="13" ONDRAGSTART="return false"></td><td class="menuItemImg" id="mnuDrillDown"><%=messages.getString("panebar_Open")%></td></tr></table>
                    <div class="menuItemHR" id="mnuLine"><hr size="1" class="menuhr"></div>
                    <div class="menuItem" id="mnuCloseMenu"><%=messages.getString("closeMenu")%></div>
                </div>

            <table border="0" width="100%" style="display:none" id="idButtons">
                <tr>
                    <td>
                        <span id="clearallbtn" style="position:relative;display:''">
                        <img src='<%=butclrall %>' border="0" style="cursor:hand" alt='<%=messages.getString("itemlist_search_ClearSelectedRecords")%>' onclick="clearRows(saveData)" width='<%=messages.getString("search_butclrall_width_key3")%>' height='<%=messages.getString("search_butclrall_height_key3")%>' ONDRAGSTART="return false"></span>
                        <span id="collapsebtn" style="position:relative;left:4;display:none">
                        <img src='<%=butcolpvw %>' border="0" style="cursor:hand" alt='<%=messages.getString("itemlist_search_ReduceTableSize")%>' onclick="collapseView()" width="87" height="19" ONDRAGSTART="return false"></span>
                        <span id="expandbtn" style="position:relative;display:''">
                        <img src='<%=butexpvw %>' border="0" style="cursor:hand" alt='<%=messages.getString("itemlist_search_ExpandSelectedRecordsTable")%>' onclick="expandView()" width="83" height="19" ONDRAGSTART="return false"></span>
                    </td>
                    <td align="right" width="300" nowrap>
                        <img src='<%=butclose %>' border="0" style="cursor:hand" alt='<%=messages.getString("forecasting_actions_CloseScreen")%>' onClick="top.window_close()" width='<%=messages.getString("search_butclose_width_key3")%>' height='<%=messages.getString("search_butclose_height_key3")%>' ONDRAGSTART="return false">
						<%
							if (grantedObjects.contains("COPY_RELATION_FWC")) {
							//if(true){
						%>
							<span id="addNewItembtn" style="position:relative;display:''">
							<img src='<%=butaddnew  %>' border="0" style="cursor:hand" alt='<%=messages.getString("search_ActonSelectedItems")%>' onClick="top.openSearch('catalog',false);" width="83" height="19" ONDRAGSTART="return false"></span>
						<%
							}
						%>
                        <span id="actionbtn" style="position:relative;display:''">
                        <img src='<%=butaction %>' border="0" style="cursor:hand" alt='<%=messages.getString("search_ActonSelectedItems")%>' onClick="top.checkActions(saveData)" width='<%=messages.getString("search_butaction_width_key3")%>' height='<%=messages.getString("search_butaction_height_key3")%>' ONDRAGSTART="return false"></span>
                        <span id="multiSelectbtn" style="position:relative;display:none">
                        <img src='<%=butapply  %>' border="0" style="cursor:hand" alt='<%=messages.getString("itemlist_search_SelectItems")%>' onClick="onSelect('multiple')" width="83" height="19" ONDRAGSTART="return false"></span>

                    </td>
                </tr>
                <tr id="elapsedTimeTr" style="visibility:hidden">
                    <td colspan="2" align="right" class="normaltext"><span id="elapsedTimeSpan"></span></td>
                </tr>
            </table>
            <table border="0" width="100%" style="display:none" id="idEditButtons">
                <tr>
                    <td align="right">
                        <img src='<%=butclose %>' border="0" style="cursor:hand" alt='<%=messages.getString("forecasting_actions_CloseScreen")%>' onClick="top.window_close()" width='<%=messages.getString("search_butclose_width_key3")%>' height='<%=messages.getString("search_butclose_height_key3")%>' ONDRAGSTART="return false">
                        <img src='<%=butsave  %>' border="0" style="cursor:hand" alt='<%=messages.getString("principal_search_SaveData")%>' onClick="top.checkActions(saveData)" width='<%=messages.getString("buttonaction_save_key3_width")%>' height='<%=messages.getString("buttonaction_save_key3_height")%>' ONDRAGSTART="return false">
                    </td>
                </tr>
            </table>
            <table border="0" width="100%" style="display:none" id="idSelectButtons">
                <tr>
                    <td align="right">
                        <img src='<%=butcancel %>' border="0" style="cursor:hand" alt='<%=messages.getString("filter_browse_CancelandCloseScreen")%>' onClick="top.window_close()" width="80" height="19" ONDRAGSTART="return false">
                        <img src='<%=butsel %>' border="0" style="cursor:hand" alt='<%=messages.getString("itemlist_search_SelectItem")%>' onClick="onSelect('single')" width="83" height="19" ONDRAGSTART="return false">
                    </td>
                </tr>
            </table>
            <table border="0" width="100%" style="display:none" id="idSingleOpenButtons">
                <tr>
					<td align="left" width="300" nowrap>
					<span id="clearallCFbtn" style="position:relative;display:'none'">
                        <img src='<%=clralcpyfrm %>' border="0" style="cursor:hand" alt='<%=messages.getString("itemlist_search_ClearSelectedRecords")%>' onclick="clearFromRows(saveData2)" width='<%=messages.getString("searchCatalog_relationships_clralcpyfrm_width")%>' height='<%=messages.getString("searchCatalog_relationships_clralcpyfrm_height")%>' ONDRAGSTART="return false"></span>
						
				<span id="clearallCTbtn" style="position:relative;display:''">
                        <img src='<%=clralcpyto %>' border="0" style="cursor:hand" alt='<%=messages.getString("itemlist_search_ClearSelectedRecords")%>' onclick="clearToRows(saveData1)" width='<%=messages.getString("searchCatalog_relationships_clralcpyto_width")%>' height='<%=messages.getString("searchCatalog_relationships_clralcpyto_height")%>' ONDRAGSTART="return false"></span>
			
					</td>
                    <td align="right">
                        <img src='<%=addplanitm %>' border="0" style="cursor:hand" alt='<%=messages.getString("search_CreateaPlanningItembylinkingproductstocustomers")%>' onClick="checkActions(saveData1,saveData2)" width='<%=messages.getString("search_addplanitm_width_key3")%>' height='<%=messages.getString("search_addplanitm_height_key3")%>' ONDRAGSTART="return false">
                        <img src='<%=butclose %>' border="0" style="cursor:hand" alt='<%=messages.getString("forecasting_actions_CloseScreen")%>' onClick="top.window_close()" width='<%=messages.getString("search_butclose_width_key3")%>' height='<%=messages.getString("search_butclose_height_key3")%>' ONDRAGSTART="return false">
                    </td>
                </tr>
            </table>
            <table border="0" width="100%" style="display:none" id="idSingleOpenPLMButtons">
                <tr>
                    <td align="right">
                        <img src='<%=butclose %>' border="0" style="cursor:hand" alt='<%=messages.getString("forecasting_actions_CloseScreen")%>' onClick="top.window_close()" width='<%=messages.getString("search_butclose_width_key3")%>'  height='<%=messages.getString("search_butclose_height_key3")%>' ONDRAGSTART="return false">
                        <img src='<%=butcont  %>' border="0" style="cursor:hand" alt='<%=messages.getString("itemlist_search_Continue")%>' onClick="onSingleOpen()" width="83" height="19" ONDRAGSTART="return false">
                    </td>
                </tr>
            </table>
    </td>
  </tr>
</table>
</form>
</body>
</html>