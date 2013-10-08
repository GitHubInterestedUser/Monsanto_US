
	<%-- $Revision: 286 $ --%>
	<%-- $Date: 2012-03-14 04:52:55 -0700 (Wed, 14 Mar 2012) $ --%>
	<%-- $HeadURL: http://steelscm.domain.steelwedge.com:90/svn/sppm/releases/5.4.0Release/build/efmcore/src/online/app/search_results_forecast_agg_xsl.jsp $ --%>
<%@ page import="com.steelwedge.util.Log" %>
<%@page import="java.util.*"%>
<%@ page import="com.steelwedge.web.efm.FeaturePreferenceController" %>
<%@ page import="com.steelwedge.web.efm.FeatureController" 
import="com.steelwedge.web.efm.PermissionHelper"
	  import="com.steelwedge.user.EFMUserException"
	  import="com.steelwedge.web.efm.User"
	
%>


<jsp:useBean id="encodingHelper" class="com.steelwedge.web.efm.EncodingHelper" scope="page"/> 
<%!	
    private static Log log = new Log(__search_results_forecast_agg_xsl.class);
	
    private HashMap params = new HashMap();

	private void decodeParams(String encodedParams) {
	    String decoded = java.net.URLDecoder.decode(encodedParams);
        log.debug("decoded queryString = " + decoded);
        
	    StringTokenizer st = new StringTokenizer(decoded, "&");
	    while (st.hasMoreTokens()) {
	        String nameValue = st.nextToken();
	        String name = "";
	        String value = "";
	        int equals = nameValue.indexOf("=");
	        if (equals > -1) {
	            name = nameValue.substring(0, equals);
	            value = nameValue.substring(equals + 1);
	        }
	        params.put(name, value);
	       // log.debug(name + "=" + value);
	    }
	}
	private String getParam(String name) {
	    return (String)params.get(name);
	}
	
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
	 String searchValueFromSession = (String)session.getAttribute("searchValue");
	 session.removeAttribute("searchValue");
	String XMLPath = "";   
    File file = null;

	FeaturePreferenceController fpInstance = FeaturePreferenceController.getInstance();
	 boolean isUOMEnable = fpInstance.getUOMFeatureEnabled();

	if(FeatureController.localeSelectOption){
		   XMLPath = "FinderDisplayConfig_"+session.getAttribute("selectedLocale").toString()+"_"+session.getAttribute("selecteCountry").toString()+".xml";
	   file = new File(".\\applications\\steelwedge\\app\\"+XMLPath).getCanonicalFile();
	  //System.out.println("file in finder  "+file.exists());
	   if(!file.exists())
		   XMLPath = "FinderDisplayConfig.xml";
	}else{
		 XMLPath = "FinderDisplayConfig.xml";
	}
	  
	ResourceBundle messages;
    messages = (ResourceBundle)session.getAttribute("resourceBundle");
	encodingHelper.setSelectedLocale((String)session.getAttribute("selectedLocale")); 
	encodingHelper.setSelectedCountry((String)session.getAttribute("selecteCountry")); 
	String encodingTechnique = encodingHelper.getEncodingTechnique(); 
	decodeParams(request.getQueryString());
	String sortDirection = getParam("sortDirection");
	String showMetricHeader = getParam("showMetrics");
	if (sortDirection.equalsIgnoreCase("ascending")) {
		sortDirection = "descending";
	}
	else {
		sortDirection = "ascending";
	}
   	User user = User.getInstance(request);
    Set grantedObjects = getGrantedObjects(user);
%>
<%@ page contentType="text/html; charset=UTF-8" %>
<?xml version="1.0" encoding="<%=encodingTechnique.substring(encodingTechnique.indexOf("=")+1,encodingTechnique.length())%>"?> 
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">

	<xsl:output method="html"/>
	<!-- store a tree fragment containing only the searchable columns in the finder display configuration: -->
	<xsl:variable name="fdc" select="document('<%=XMLPath%>')//context[@name='forecast']/search/multiple/column"/>
	<xsl:template match="Rows">
		<html>
			<head>
				<title><%=messages.getString("forecastSearchResults")%></title>
				<link rel="stylesheet" type="text/css" href="/app/css/mc_css.css"/>
				<script language="JavaScript">//<![CDATA[
    	var filterId = "";
		var alignArray = new Array();	
		var criteriaString = "";
		
		top.refreshPageNumbers('<%=getParam("count")%>');
		function window_onload() {
			
			//get alignment..
			var headerRow = resultsTable.rows[0];
			lastColumn = headerRow.cells.length -1;
			for (n=0;n<headerRow.cells.length;n++) {
				//alert("cell["+ n+"]="+ headerRow.cells(n).align);
				alignArray[n] = headerRow.cells(n).align;
				//alert("alignArray["+n+"]="+alignArray[n]);
			}
			
			getTooltip();
			
			//headerRow = resultsTable.rows[2];
			//for (i=2;i<resultsTable.rows.length;i++) { //populate criteria cell in resultsTable
				//resultsTable.rows[i].cells(lastColumn).innerHTML = criteriaString;
			//}
			
			top.document.body.style.cursor = "auto";
			if (top.document.fraTree.document) {
				top.document.fraTree.document.body.style.cursor = "auto";
			}
			top.datadirty = false;
			top.idBusy.style.display='none';
		}
		
		function getTooltip() {
			criteriaString = "";
			theTable = resultsTable;
			if (theTable.rows.length > 2) {
					tmpTooltip = theTable.rows[2].tooltip; //first row - need one row only since all rows are the same..
					tmpTooltipArray = tmpTooltip.split("[criteria=");
			
				for (i=1;i<tmpTooltipArray.length;i++) { //avoid element 0 - not useful
					tmpArrayElement = tmpTooltipArray[i];
					tmpArrayElementArray = tmpArrayElement.split("]");
					if (i == 1) {
						criteriaString = tmpArrayElementArray[0];
					} 
					else {
						criteriaString = criteriaString + "|" + tmpArrayElementArray[0];
					}
				}
			}
			//alert(criteriaString);
		}

		function ValueExists(theTR){
    		theTable = top.parent.saveData;

    		for (i=0;i<theTable.rows.length;i++){
    			if (decodeURIComponent(theTable.rows[i].PK) == eval("new String(theTR.PK);")){
    				return true;
    			}
    		}

    		return false;
    	}

		function checkTreeMode(obj)
		{
			if (parent.treemode == 1)
			{
				if (top.fraTree.currTreeLevel == top.fraTree.oTreeTable.children[0].children.length-1)
				{
					thetop.setcontextmenuitem('DISABLED',mnuDrillDown);
				}

				if (top.fraTree.currTreeLevel == 0)
				{
					thetop.setcontextmenuitem('DISABLED',mnuMoveUpLevel);
				}

				thetop.showMenu('cntxtMenuTop',null,self);
			}
		}

		function moveAll(){
			//alert("in moveAll..");
			theTable2 = resultsTable;
			if (theTable2.rows.length <= 2) {
				top.mcwarn('<%=messages.getString("warning")%>'+':','<%=messages.getString("therearenosearchresultstoselect")%>');
			}
    		else {
				for (j=2;j<theTable2.rows.length;j++){
    				moveRow(theTable2.rows[j]);
    			}
			}
			if (top.datadirty==false) {
				top.document.body.style.cursor = "auto";
			}
    	}
				
    	function moveRow(theTR){
			
			 if((parent.isPlanningsetSearch=="true") && parent.document.getElementById("saveData").rows.length>1){
				 top.mcwarn('<%=messages.getString("warning")%>'+':','<%=messages.getString("search_results_forecast_agg_xsl_oneitemwillbeadded")%>');
			 }
			 else{
				 
        //alert("in moveRow.. " + theTR.PK);
        	if ((!ValueExists(headerRow)) && (theTR.PK != "headerRow")) {
			// add the header row
			moveRow(headerRow);
	        }else {
				//top.mcwarn('<%=messages.getString("warning")%>'+':','<%=messages.getString("search_results_forecast_agg_xsl_duplicate")%>');

			}
                if (parent.singlerecord == true)
		{

			if (curselection)
			{
				curselection.style.backgroundColor = '';
			}

			curselection = theTR;
			curselection.style.backgroundColor = rowhighlight;
		}
		else
		{

    		if (!ValueExists(theTR)){

    			theTable = top.parent.saveData;
    			theDoc = top.parent.document;
    			otbody = theTable.children[0];
   			if (theTR.PK == "headerRow") {
   	    			oNewRow = theDoc.createElement('<tr PK="headerRow">');
   	    			otbody.appendChild(oNewRow);
	    			newTDStyle = ' nowrap class="datatitlecell_off"; style="padding-right:10px"';
	    		}
	    		else {
				 var biz = 'null';
				 if (theTR.bizunit != null && theTR.bizunit != '') {
					//alert(theTR.bizunit);
					biz = theTR.bizunit;
				 }
				 //alert(theTR.psID);
    			oNewRow = theDoc.createElement('<tr PK="' + eval("new String(encodeURIComponent(theTR.PK));") +'" planningSetId="'+ eval("new String(encodeURIComponent(theTR.psID));") +'" filter="' + eval("new String(theTR.filterId);") + '" searchBy="' + eval("new String(theTR.searchBy);") + '" operator="' + eval("new String(theTR.operator);") + '" searchValue="' + eval("new String(theTR.searchValue);") + '" searchType="' + eval("new String(theTR.searchType);") + '" groupBy="' + eval("new String(theTR.groupBy);") + '" itemName="' + eval("new String(theTR.itemName);") + '"  description="' + eval("new String(theTR.description);") + '"  uom="' + eval("new String(theTR.uom);") +'" tooltip="' + eval("new String(theTR.tooltip);") + '" itemtypes="' + eval("new String(theTR.itemtypes);") + '" bizUnit="' + biz + '" assemblyType="' + eval("new String(theTR.assemblytypes);") + '" tempTooltip="' + eval("new String(theTR.tooltip);") + '" onclick="selectRow(this);" onDblClick="onDoubleClick(this);" oncontextmenu="top.showMenu(\'cntxtMenu\',null,self);" class="row_off" onMouseOver="showToolTip(this)" onMouseOut="this.className=\'row_off\'" onDblClick="">');
				//oNewRow = theDoc.createElement('<tr PK="' + eval("new String(theTR.PK);") + '" onclick="selectRow(this);" oncontextmenu="top.dialogArguments.caller.showMenu(\'cntxtMenu\',null,self);" class="row_off" onMouseOver="this.className=\'row_on\'" onMouseOut="this.className=\'row_off\'" onDblClick="">');
				otbody.appendChild(oNewRow);

				oCell = theDoc.createElement('<TD valign="top" nowrap align="center" style="PADDING-RIGHT: 10px">');
				oCell.innerHTML = '<img src="/app/images/undo2.gif" onclick="removeRow(this);" style="cursor:hand" alt="Remove this item">';
				oNewRow.appendChild(oCell);
				newTDStyle = ' nowrap style="padding-right:10px"';
			}

    		for (i=0;i<theTR.children.length;i++){
				theTD = theTR.childNodes(i);
				alignVal = ' align="' +alignArray[i] + '"';
				if (i==0){
					if (theTR.PK == "headerRow") {
					    oCell = theDoc.createElement('<td width="15" ' + alignVal + '>');
					    oNewRow.appendChild(oCell);
					    oCell = theDoc.createElement('<TD' + newTDStyle + alignVal + '>');
					} else {
	                     oCell = theDoc.createElement('<TD style="padding-right:10px" nowrap ' + alignVal + '>');
					}
				}
				else{
					oCell = theDoc.createElement('<TD' + newTDStyle + alignVal + '>');
				}
				oCell.innerHTML = theTD.innerHTML;
				oNewRow.appendChild(oCell);
			}
			if (theTR.PK != "headerRow") {
				parent.srcount.innerText = parseFloat(parent.srcount.innerHTML)+1;
                oNewRow.scrollIntoView(true);
			}
			if (parseFloat(parent.srcount.innerText) == 1)
			{
				parent.selectRow(oNewRow);
			}
		}
		}
			 }//end of else of planningsets search.
		//alert("filterid =" +theTR.filterId + " searchBy=" + theTR.searchBy + " operator=" + theTR.operator + " searchValue=" + theTR.searchValue + " groupBy=" + theTR.groupBy);
	}

		function drilldown(obj)
		{
			// ensure the event does not bubble or the selected row will move down to your 'shopping cart'
			if (event)
			{
				event.cancelBubble = true;
			}
			if (parent.treemode == 1)
			{
				if (top.fraTree.currTreeLevel+1 < top.fraTree.oTreeTable.children[0].children.length)
				{
					top.fraTree.currTreeLevel++;

					var oTR = top.fraTree.oTreeTable.children[0].children[top.fraTree.currTreeLevel];
					if (oTR)
					{
						curselection = null

						oTR.children[1].innerHTML = oTR.swTreeType + ': ' + obj.children[2].innerHTML;
						oTR.style.display='';
						oTR.treeVal = obj.PK;

						if (parent.fraTree.lastTreeType != null)
						{
							parent.fraTree.lastTreeType.style.fontWeight = 'normal';
						}

						oTR.style.fontWeight = 'bold';
						parent.fraTree.lastTreeType = oTR;

						parent.idTreeType.innerHTML = '&nbsp;('+ oTR.swNextTreeType+')';
						parent.fraTree.currTreeType = oTR.swTreeType; // remove after demo
						self.location.href='/efm/SearchResults?treeType=' + oTR.swTreeType + '&treeVal=' + obj.PK;
					}
				}
			}
		}

		function moveuplevel()
		{
			if (top.fraTree.currTreeLevel > 0)
			{
				var oTR = top.fraTree.oTreeTable.children[0].children[top.fraTree.currTreeLevel];
				if (oTR)
				{
					curselection = null

					oTR.style.display='none';
					var oTR = top.fraTree.oTreeTable.children[0].children[top.fraTree.currTreeLevel-1];
					parent.fraTree.updateSearch(oTR);
				}
			}
		}


		function showOpenIcons()
		{
			var tbl = document.getElementById('resultsTable');

			for (i=0;i<openicons.length;i++)
			{
				openicons[i].style.display='';
			}
		}

		function onSort(col) {
		
			//alert("in onSort.. col = " + col);
			var sortCol = col;
			var sortDir = '<%=sortDirection%>';
			top.searchRequest('go', sortCol, sortDir);
		}

		function hideOpenIcons()
		{
			var tbl = document.getElementById('resultsTable');

			for (i=0;i<openicons.length;i++)
			{
				openicons[i].style.display='none';
			}
		}
		
		function removeRows(){
		   var table = document.getElementById('resultsTable');
			if (table.rows.length <= 0) {
				//top.mcwarn('<%=messages.getString("warning")%>'+':','<%=messages.getString("therearenosearchresultstoselect")%>');
			}
    		else {
				for (r=(table.rows.length-1);r>=0;r--){
    				table.deleteRow(r);
    			}
			}
		}
		
        //]]></script>
			</head>
			<body onLoad="window_onload()"  style="background-color:#ffffff;PADDING-RIGHT: 3px; PADDING-LEFT: 3px; PADDING-BOTTOM: 3px; PADDING-TOP: 3px">
			  <form name="detailForm">
				<table cellSpacing="0" name="resultsTable" id="resultsTable" border="0" cellPadding="1">
					<tr name="headerRow" id="headerRow" PK="headerRow">
						<!-- header row -->
						<xsl:apply-templates select="$fdc" mode="headings">
							<xsl:sort select="@position" data-type="number" order="ascending"/>
						</xsl:apply-templates>
					</tr>
					<tr>
						<td style="BORDER-TOP: #efefef 1px solid">
							<xsl:attribute name="colspan"><xsl:value-of select="count($fdc)"/></xsl:attribute>
							<img width="1" src="/app/images/blank.gif" border="0" height="1"/>
						</td>
					</tr>
					<xsl:apply-templates select="Row">
					</xsl:apply-templates>
				</table>
			  </form>	
			</body>
		</html>
	</xsl:template>
	<!-- Column headings -->
	<xsl:template match="column" mode="headings">
		<td nowrap="nowrap" onmouseout="this.className='datatitlecell_off'" style="PADDING-RIGHT: 10px" class="datatitlecell_off" onmouseover="this.className='datatitlecell_on'">
			<xsl:attribute name="align"><xsl:value-of select="@align"/></xsl:attribute>
			<xsl:attribute name="onclick">onSort('<xsl:value-of select="sort-column"/>')</xsl:attribute>
			<xsl:attribute name="title"><xsl:value-of select="display-title"/></xsl:attribute>
			<xsl:variable name="display3"><xsl:value-of select="update-table"/></xsl:variable>
			<xsl:variable name="display4"><xsl:value-of select="result-set-name"/></xsl:variable>
			<xsl:choose>
				<xsl:when test="'<%= showMetricHeader %>' != 'true'">
					<xsl:choose>
						<xsl:when test="starts-with($display3,'METRICS')">
						</xsl:when>
						<xsl:when test="starts-with($display3,'MAPE3')">
						</xsl:when>
						<xsl:when test="starts-with($display4,'VWPRODUCT_LEAF')">
						</xsl:when>
						<xsl:otherwise>
							<xsl:value-of select="display-name"/>
						</xsl:otherwise>
					</xsl:choose>
				</xsl:when>
				<xsl:otherwise>
					<xsl:value-of select="display-name"/>
				</xsl:otherwise>
			</xsl:choose>
		</td>
	</xsl:template>
	<!-- Row data -->
	<xsl:template match="Row">

		<tr class="row_off" onclick="moveRow(this)" onmouseout="this.className='row_off'" onmouseover="this.className='row_on'">
<%		if(isUOMEnable){%>
		    <xsl:variable name="isUOM" select="'true'"/>
		   <%}else{%>
             <xsl:variable name="isUOM" select="'false'"/>
		   <%} %>

			<xsl:attribute name="PK">
				<xsl:value-of select="Column[@name='PK.PK']"/></xsl:attribute>
			<xsl:attribute name="filterId"><%=getParam("filter")%></xsl:attribute>
			<xsl:attribute name="searchBy"><%=getParam("searchBy")%></xsl:attribute>
			<xsl:attribute name="operator"><%=getParam("operator")%></xsl:attribute>
			<xsl:attribute name="searchValue"><%=searchValueFromSession%></xsl:attribute>
			<xsl:attribute name="groupBy"><%=getParam("groupBy")%></xsl:attribute>
			<xsl:attribute name="searchType"><%=getParam("type")%></xsl:attribute>
			<xsl:attribute name="itemName"><xsl:value-of select="Column[@name='NAVPK.NAVPK']"/></xsl:attribute>
			<xsl:attribute name="description"><xsl:value-of select="Column[@name='DISPLAY.DESCRIPTION_ALIAS']"/>-<xsl:value-of select="Column[@name='DISPLAY.LONG_DESCRIPTION_ALIAS']"/></xsl:attribute>
			<xsl:attribute name="uom"><xsl:value-of select="Column[@name='DISPLAY.PLANNING_UOM']"/></xsl:attribute>
			<xsl:attribute name="bizunit"><xsl:value-of select="Column[@name='NAVPK.BUSINESS_UNIT']"/></xsl:attribute>
			<xsl:attribute name="itemtypes"><xsl:value-of select="Column[@name='DISPLAY.TYPE_ALIAS']"/></xsl:attribute>
			<xsl:attribute name="assemblytypes"><xsl:value-of select="Column[@name='DISPLAY.ASSEMBLYTYPE_ALIAS']"/></xsl:attribute>
			<xsl:attribute name="tooltip"><xsl:value-of select="Column[@name='DISPLAY.TOOLTIP']"/></xsl:attribute>
			<xsl:attribute name="psID"><xsl:value-of select="Column[@name='NAVPK.PLANNING_SET_ID']"/></xsl:attribute>
			<!--<xsl:attribute name="title"><xsl:value-of select="Column[@name='DISPLAY.TOOLTIP']"/></xsl:attribute>-->
			<!--xsl:choose>
		     <xsl:when test="$fdc/result-set-name='DISPLAY.STATUS'">
		  	    <xsl:variable name="isDisc" select="Column[@name='DISPLAY.STATUS']"/>
				<td align="center">
					<xsl:choose>
					<xsl:when test="$isDisc='Changed'">
								<img src="/app/images/icons/status_closed_g.gif" border="0" alt="Changed" width="16" height="13"/>
					</xsl:when>
					<xsl:otherwise>
						<xsl:choose>
						<xsl:when test="$isDisc='Reviewed'">
								<img src="/app/images/icons/mnu_find_g.gif" border="0" alt="Reviewed" width="16" height="13"/>
						</xsl:when>
						<xsl:otherwise>
							<xsl:choose>
							<xsl:when test="$isDisc='Submitted Change'">
								<img src="/app/images/icons/status_gear_g.gif" border="0" alt="Submitted" width="16" height="13"/>
							</xsl:when>
							<xsl:otherwise>
								<img src="/app/images/icons/status_none_g.gif" border="0" alt="Not Reviewed" width="16" height="13"/>
							</xsl:otherwise>
							</xsl:choose>
						</xsl:otherwise>
						</xsl:choose>
					</xsl:otherwise>
					</xsl:choose>
				</td>
		     </xsl:when>
		 	</xsl:choose-->
			
			<td style="cursor: default">
			  	<xsl:if test="current()/Column/@name='DISPLAY.DESCRIPTION_ALIAS'">
					<xsl:attribute name="class">normaltext</xsl:attribute>
					<xsl:attribute name="style">PADDING-RIGHT: 10px</xsl:attribute>
					<xsl:attribute name="nowrap">nowrap</xsl:attribute>
					<xsl:value-of select="Column[@name='DISPLAY.DESCRIPTION_ALIAS']"/>
				</xsl:if>
			</td>
			<td style="cursor: default">
			  	<xsl:if test="current()/Column/@name='DISPLAY.LONG_DESCRIPTION_ALIAS'">
					<xsl:attribute name="class">normaltext</xsl:attribute>
					<xsl:attribute name="style">PADDING-RIGHT: 10px</xsl:attribute>
					<xsl:attribute name="nowrap">nowrap</xsl:attribute>
					<xsl:value-of select="Column[@name='DISPLAY.LONG_DESCRIPTION_ALIAS']"/>
				</xsl:if>
			</td>
			<%if(isUOMEnable){%>
          			 <td style="cursor: default">
			  	<xsl:if test="current()/Column/@name='DISPLAY.PLANNING_UOM'">
				  <xsl:if test="$isUOM='true'">
				 	<xsl:attribute name="class">normaltext</xsl:attribute>
					<xsl:attribute name="style">PADDING-RIGHT: 10px</xsl:attribute>
					<xsl:attribute name="nowrap">nowrap</xsl:attribute>
					<xsl:value-of select="Column[@name='DISPLAY.PLANNING_UOM']"/>
					</xsl:if>
				</xsl:if>
			</td>
			<%}%>
<%@ include file="search_results_forecast_agg_columns.jspi" %>

			<td style="cursor: default" align="center">
			  	<xsl:if test="current()/Column/@name='DISPLAY.TYPE_ALIAS'">
					<xsl:attribute name="class">normaltext</xsl:attribute>
					<xsl:attribute name="style">PADDING-RIGHT: 10px</xsl:attribute>
					<xsl:attribute name="nowrap">nowrap</xsl:attribute>
					<xsl:value-of select="Column[@name='DISPLAY.TYPE_ALIAS']"/>
				</xsl:if>
			</td>			
					
<!--			<xsl:apply-templates select="Column"/>
-->
		</tr>
	</xsl:template>
	<xsl:template match="Column">
		<xsl:if test="$fdc/result-set-name=@name">
		  <xsl:choose>
		   <xsl:when test="current()/@name='VWPRODUCT_LEAF.IS_DISCONTINUED'">
			<xsl:variable name="fStatus" select="."/>
			<td>
				<xsl:choose>
				 <xsl:when test="$fStatus='1'">
					<img src="/app/images/icons/status_none_g.gif" border="0" alt='<%=messages.getString("search_results_PLM_xsl_Nottouchedreviewed")%>' width="16" height="13"/>
				 </xsl:when>
				 <xsl:otherwise>
					<img src="/app/images/icons/mnu_find_g.gif" border="0" alt='<%=messages.getString("search_results_PLM_xsl_ReviewedbutUnchanged")%>' width="16" height="13"/>
				 </xsl:otherwise>
				</xsl:choose>
			</td>
		   </xsl:when>
		   <xsl:otherwise>

			<td>
				<xsl:attribute name="class">normaltext</xsl:attribute>
				<xsl:value-of select="."/>
			</td>
		   </xsl:otherwise>
		  </xsl:choose>
		</xsl:if>
	</xsl:template>
</xsl:stylesheet><!-- Stylus Studio meta-information - (c)1998-2002 eXcelon Corp.
<metaInformation>
<scenarios ><scenario default="yes" name="Scenario2" userelativepaths="yes" externalpreview="no" url="search_results_forecast.xml" htmlbaseurl="" outputurl="" processortype="internal" commandline="" additionalpath="" additionalclasspath="" postprocessortype="none" postprocesscommandline="" postprocessadditionalpath="" postprocessgeneratedext=""/></scenarios><MapperInfo srcSchemaPath="" srcSchemaRoot="" srcSchemaPathIsRelative="yes" srcSchemaInterpretAsXML="no" destSchemaPath="" destSchemaRoot="" destSchemaPathIsRelative="yes" destSchemaInterpretAsXML="no"/>
</metaInformation>
-->