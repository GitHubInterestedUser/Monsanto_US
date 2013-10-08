
	<%-- $Revision: 127 $ --%>
	<%-- $Date: 2012-02-08 01:30:56 -0800 (Wed, 08 Feb 2012) $ --%>
	<%-- $HeadURL: http://steelscm.domain.steelwedge.com:90/svn/sppm/releases/5.4.1Release/build/efmcore/src/online/app/search_results_singlecatalog.jsp $ --%>
<%@ page import="com.steelwedge.util.Config" %>
<%@page import="java.util.*"%>
<%@ page import="com.steelwedge.web.efm.FeatureController" %>
<jsp:useBean id="encodingHelper" class="com.steelwedge.web.efm.EncodingHelper" scope="page"/> 
<%!	
	private HashMap params = new HashMap();

	private void decodeParams(String encodedParams) {
	    String decoded = java.net.URLDecoder.decode(encodedParams);
	    //log.debug(decoded);
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
%>
<%  ResourceBundle messages;
    messages = (ResourceBundle)session.getAttribute("resourceBundle");
	encodingHelper.setSelectedLocale((String)session.getAttribute("selectedLocale")); 
	encodingHelper.setSelectedCountry((String)session.getAttribute("selecteCountry")); 
	String encodingTechnique = encodingHelper.getEncodingTechnique(); 
    //log.debug("request.getQueryString()=" + request.getQueryString());
    decodeParams(request.getQueryString());
	String sortDirection = getParam("sortDirection");
	if (sortDirection.equalsIgnoreCase("ascending")) {
		sortDirection = "descending";
	}
	else {
		sortDirection = "ascending";
	}
	String XMLPath = "";   
    File file = null;
	if(FeatureController.localeSelectOption){
		 XMLPath = "/app/FinderDisplayConfig_"+session.getAttribute("selectedLocale").toString()+"_"+session.getAttribute("selecteCountry").toString()+".xml";
	     file = new File(".\\applications\\steelwedge\\"+XMLPath).getCanonicalFile();
	     //System.out.println("file in finder  "+file.exists());
	     if(!file.exists())
		 XMLPath = "FinderDisplayConfig.xml";
	}else{
		 XMLPath = "/app/FinderDisplayConfig.xml";
	}
%>
<%@ page contentType="text/html; charset=UTF-8" %>
<?xml version="1.0" encoding="<%=encodingTechnique.substring(encodingTechnique.indexOf("=")+1,encodingTechnique.length())%>"?> 
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">

	<xsl:output method="html"/>
	<!-- store a tree fragment containing only the searchable columns in the finder display configuration: -->
	<xsl:variable name="fdc" select="document('<%=XMLPath%>')//context[@name='catalog']/search/product/column"/>
	<xsl:template match="Rows">
		<html>
			<head>
				<title><%=messages.getString("forecastSearchResults")%></title>
				<link rel="stylesheet" type="text/css" href="/app/css/mc_css.css"/>
				<script language="JavaScript">//<![CDATA[


    	var curselection = null;
		top.refreshPageNumbers('<%=getParam("count")%>');
		var alignArray = new Array();
		function window_onload() {
			//alert("resetting cursor to normal");
			top.document.body.style.cursor = "auto";
			top.datadirty=false;
			top.idBusy.style.display='none';
			top.document.searchForm.hdnSelectedType.value = top.document.searchForm.Display.value;
			//alert("display value is "+top.document.searchForm.Display.value);
			var headerRow = resultsTable.rows[0];
			lastColumn = headerRow.cells.length -1;
			for (n=0;n<headerRow.cells.length;n++) {
				//alert("cell["+ n+"]="+ headerRow.cells(n).align);
				alignArray[n] = headerRow.cells(n).align;
			}
		}

		function moveAll(){
			//alert("in moveAll..");
			theTable2 = resultsTable;
			if (theTable2.rows.length <= 2) {
				top.mcwarn('<%=messages.getString("warning")%>','<%=messages.getString("therearenosearchresultstoselect")%>');
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

    	function ValueExists(theTR){
    		theTable = top.parent.saveData1;

    		for (i=0;i<theTable.rows.length;i++){
    			if (theTable.rows[i].PK == eval("new String(theTR.PK);")){
    				return true;
    			}
    		}

    		return false;
    	}

		function onSort(col) {
		
			//alert("in onSort.. col = " + col);
			var sortCol = col;
			var sortDir = '<%=sortDirection%>';
			top.searchRequest('go', sortCol,sortDir);
		}

    	function selectRow(theTR){
        //alert("in xslt.. selectRow()" + theTR.PK + " type="+theTR.Type);
			var rowhighlight = '#D8EDF9';

			if (curselection)
			{
				curselection.style.backgroundColor = '';
			}

        	if (theTR.PK != "headerRow") {
				curselection = theTR;
				curselection.style.backgroundColor = rowhighlight;
				top.document.searchForm.hdnSelectedID.value = theTR.PK;
				//alert("pk value is  "+theTR.PK);
				
				if (theTR.Type == "" || theTR.Type == null) {
					top.document.searchForm.hdnSelectedType.value = top.document.searchForm.Display.value;
				}
			}
		}
		
		function onDoubleClick(theTR) {
			selectRow(theTR);
			top.onSingleOpen();
		}

		function moveRow(theTR){
        //alert("in moveRow.. " + theTR.PK);
		 var rows = top.parent.saveData1.rows;
		 if(rows.length > '<%= Config.get("COPYTO_LIMIT", "1") %>'){
			top.mcwarn('<%=messages.getString("warning")%>'+':','<%=messages.getString("view_catalog_detail_relationshipxsl_Youareonlypermittedtoselect")%> '+'<%= Config.get("COPYTO_LIMIT", "1") %>'+' <%=messages.getString("youareonlypermittedtoselect1producttocopyto")%>');
		 }else if(theTR.isDisc == 1){

			 top.mcwarn('<%= messages.getString("warning")%>'+':','Relationships cannot be created for discontinued items.');

		 }else{
        	if ((!ValueExists(headerRow)) && (theTR.PK != "headerRow")) {
			// add the header row
			moveRow(headerRow);
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

    			theTable = top.parent.saveData1;
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
    			oNewRow = theDoc.createElement('<tr PK="' + eval("new String(theTR.PK);") + '" onclick="selectRow(this);" onDblClick="onDoubleClick(this,saveData1,saveData2);" oncontextmenu="top.showMenu(\'cntxtMenu\',null,self);" isDisc="'+theTR.isDisc+'" class="row_off" onMouseOver="this.className=\'row_on\'" onMouseOut="this.className=\'row_off\'" onDblClick="">');
				
				otbody.appendChild(oNewRow);

				oCell = theDoc.createElement('<TD valign="top" nowrap align="center" style="PADDING-RIGHT: 10px">');
				oCell.innerHTML = '<img src="/app/images/undo2.gif" onclick="removeRow(this,\'copyTo\');" style="cursor:hand" alt=\'<%=messages.getString("view_catalog_detail_relationshipxsl_Removethisitem")%>\'>';
				oNewRow.appendChild(oCell);
				newTDStyle = ' nowrap style="padding-right:10px"';
			}

    		for (i=0;i<theTR.children.length;i++){
				theTD = theTR.childNodes(i);
				//alert(alignArray[i]);
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
				//alert(theTD.innerHTML);
				oCell.innerHTML = theTD.innerHTML;
				oNewRow.appendChild(oCell);
			}
			if (theTR.PK != "headerRow") {
				parent.tocount.innerText = parseFloat(parent.tocount.innerHTML)+1;
				parent.selectiontocount.innerText = parent.tocount.innerText;
                oNewRow.scrollIntoView(true);
			}
			if (parseFloat(parent.tocount.innerText) == 1)
			{
				parent.selectRow(oNewRow);
			}
		}
		}
		 }
		//alert("filterid =" +theTR.filterId + " searchBy=" + theTR.searchBy + " operator=" + theTR.operator + " searchValue=" + theTR.searchValue + " groupBy=" + theTR.groupBy);
	}

		function removeRows() {
		
		}

		function showOpenIcons()
		{
			var tbl = document.getElementById('resultsTable');

			for (i=0;i<openicons.length;i++)
			{
				openicons[i].style.display='';
			}
		}

		function hideOpenIcons()
		{
			var tbl = document.getElementById('resultsTable');

			for (i=0;i<openicons.length;i++)
			{
				openicons[i].style.display='none';
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
			<xsl:value-of select="display-name"/>
		</td>
	</xsl:template>
	<!-- Row data -->
	<xsl:template match="Row">

		<tr class="row_off" onclick="moveRow(this)" onmouseout="this.className='row_off'" onmouseover="this.className='row_on'">
			<xsl:attribute name="PK">
				<xsl:value-of select="Column[@name='PK.PK']"/></xsl:attribute>
			<xsl:attribute name="Type">
				<xsl:value-of select="Column[@name='VWPRODUCT_LEAF.ASSEMBLY_TYPE_CD']"/></xsl:attribute>
			<xsl:attribute name="Description">
				<xsl:value-of select="Column[@name='VWPRODUCT_LEAF.DESCRIPTION']"/></xsl:attribute>
				<xsl:attribute name="Temporary">
				<xsl:value-of select="Column[@name='VWPRODUCT_LEAF.IS_TEMPORARY']"/></xsl:attribute>
			<xsl:attribute name="ItemId">
				<xsl:value-of select="Column[@name='VWPRODUCT_LEAF.ITEM_ID']"/></xsl:attribute>
			<xsl:attribute name="SKU">
				<xsl:value-of select="Column[@name='VWPRODUCT_LEAF.LEAF_LABEL']"/></xsl:attribute>
				<xsl:attribute name="isDisc">
				<xsl:value-of select="Column[@name='VWPRODUCT_LEAF.IS_DISCONTINUED']"/></xsl:attribute>
			<xsl:attribute name="title">PK=<xsl:value-of select="Column[@name='VWPRODUCT_LEAF.LEAF_LABEL']"/></xsl:attribute>
			
			<!--td style="cursor: default">
		    <xsl:if test="$fdc/result-set-name='VWPRODUCT_LEAF.IS_FORECASTED'">
		  	    <xsl:variable name="isFcst" select="Column[@name='VWPRODUCT_LEAF.IS_FORECASTED']"/>
				<xsl:attribute name="style">PADDING-RIGHT: 10px</xsl:attribute>
				<xsl:attribute name="align">center</xsl:attribute>
				 <xsl:if test="$isFcst='1'">
						<img src="/app/images/icons/check.gif" alt="Is Forecasted" border="0" width="15" height="13"/>
				 </xsl:if>
		 	</xsl:if>
			</td-->
			<td style="cursor: default">
				<xsl:if test="current()/Column/@name='VWPRODUCT_LEAF.LEAF_LABEL'">
					<xsl:attribute name="class">normaltext</xsl:attribute>
					<xsl:attribute name="style">PADDING-RIGHT: 10px</xsl:attribute>
					<xsl:attribute name="nowrap">nowrap</xsl:attribute>
					<xsl:value-of select="Column[@name='VWPRODUCT_LEAF.LEAF_LABEL']"/>
				</xsl:if>
			</td>
			<td style="cursor: default">
				<xsl:if test="current()/Column/@name='VWPRODUCT_LEAF.DESCRIPTION'">
					<xsl:attribute name="class">normaltext</xsl:attribute>
					<xsl:attribute name="style">PADDING-RIGHT: 10px</xsl:attribute>
					<xsl:attribute name="nowrap">nowrap</xsl:attribute>
					<xsl:value-of select="Column[@name='VWPRODUCT_LEAF.DESCRIPTION']"/>
				</xsl:if>
			</td>			

<%@ include file="search_results_product_columns.jspi" %>
<xsl:choose>
		     <xsl:when test="$fdc/result-set-name='STATUS'">
		  	    <xsl:variable name="isDisc" select="Column[@name='VWPRODUCT_LEAF.IS_DISCONTINUED']"/>
				<td>
					<xsl:attribute name="style">PADDING-RIGHT: 10px</xsl:attribute>
					<xsl:attribute name="align">center</xsl:attribute>
					<xsl:choose>
					 <xsl:when test="$isDisc='1'">
						<img src="/app/images/icons/status_canceled_g.gif" border="0" alt='<%=messages.getString("search_results_source_xsl_Discontinued")%>' width="16" height="13"/>
					 </xsl:when>
					 <xsl:otherwise>
						<xsl:variable name="isInactive" select="Column[@name='VWPRODUCT_LEAF.IS_INACTIVE']"/>		
						<xsl:choose>
							<xsl:when test="$isInactive='0'">
								<img src="/app/images/icons/status_none_g.gif" border="0" alt='<%=messages.getString("search_results_source_xsl_Active")%>' width="16" height="13"/>
							</xsl:when>
							<xsl:otherwise>
								<img src="/app/images/icons/status_gear_g.gif" border="0" alt='<%=messages.getString("search_results_source_xsl_Inactive")%>' width="16" height="13"/>
							</xsl:otherwise>
						</xsl:choose>
					</xsl:otherwise>
					</xsl:choose>
				</td>
		     </xsl:when>
		 	</xsl:choose>
			
			<xsl:choose>
		     <xsl:when test="$fdc/result-set-name='VWPRODUCT_LEAF.IS_TEMPORARY'">
		  	    <xsl:variable name="isTemp" select="Column[@name='VWPRODUCT_LEAF.IS_TEMPORARY']"/>
				<xsl:variable name="isLocal" select="Column[@name='VWPRODUCT_LEAF.IS_LOCAL']"/>
				<td style="cursor: default" align="center">
					<xsl:attribute name="class">normaltext</xsl:attribute>
					<xsl:attribute name="style">PADDING-RIGHT: 10px</xsl:attribute>
					<xsl:attribute name="nowrap">nowrap</xsl:attribute>
					<xsl:choose>
					 <xsl:when test="$isTemp='0'">
							0
					 </xsl:when>
					<xsl:when test="$isTemp='1'">
							1
					 </xsl:when>
					 <xsl:otherwise>
						<xsl:if test="$isLocal='1'">
							<%=messages.getString("search_results_customer_xsl_System")%>							
						</xsl:if>
						<xsl:if test="$isLocal='0'">
							<%=messages.getString("search_results_customer_xsl_Import")%>
						</xsl:if>
					</xsl:otherwise>
					</xsl:choose>
				</td>
		     </xsl:when>
		 	</xsl:choose>

		</tr>
	</xsl:template>
	<xsl:template match="Column">
		
		<xsl:if test="$fdc/result-set-name=@name">
			<td>
				<xsl:attribute name="class">normaltext</xsl:attribute>
				<xsl:attribute name="style">PADDING-RIGHT: 10px</xsl:attribute>
				<xsl:attribute name="nowrap">nowrap</xsl:attribute>
				<xsl:value-of select="."/>
			</td>
		  
		</xsl:if>
	</xsl:template>
</xsl:stylesheet><!-- Stylus Studio meta-information - (c)1998-2002 eXcelon Corp.
<metaInformation>
<scenarios ><scenario default="yes" name="Scenario2" userelativepaths="yes" externalpreview="no" url="search_results.xml" htmlbaseurl="" outputurl="" processortype="internal" commandline="" additionalpath="" additionalclasspath="" postprocessortype="none" postprocesscommandline="" postprocessadditionalpath="" postprocessgeneratedext=""/></scenarios><MapperInfo srcSchemaPath="" srcSchemaRoot="" srcSchemaPathIsRelative="yes" srcSchemaInterpretAsXML="no" destSchemaPath="" destSchemaRoot="" destSchemaPathIsRelative="yes" destSchemaInterpretAsXML="no"/>
</metaInformation>
-->
