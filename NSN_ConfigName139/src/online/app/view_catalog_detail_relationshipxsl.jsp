
	<%-- $Revision: 127 $ --%>
	<%-- $Date: 2012-02-08 01:30:56 -0800 (Wed, 08 Feb 2012) $ --%>
	<%-- $HeadURL: http://steelscm.domain.steelwedge.com:90/svn/sppm/releases/5.4.1Release/build/efmcore/src/online/app/view_catalog_detail_relationshipxsl.jsp $ --%>
<%@ page import="com.steelwedge.web.efm.FeatureController" %>
<%@ page import="com.steelwedge.util.Config" %>
<jsp:useBean id="encodingHelper" class="com.steelwedge.web.efm.EncodingHelper" scope="page"/> 
<%@page import="java.util.*"%>
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
	decodeParams(request.getQueryString());
	String sortDirection = getParam("sortDirection");
	//System.out.println("sort direction is   "+sortDirection);
	if (sortDirection.equalsIgnoreCase("ascending")) {
		sortDirection = "descending";
	}
	else {
		sortDirection = "ascending";
	}
	String recordCount = "";
	recordCount = getParam("count");
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
	<xsl:variable name="fdc" select="document('<%=XMLPath%>')//context[@name='catalog']/search/relationship/column"/>
	<xsl:template match="Rows">
		<html>
			<head>
				<title><%=messages.getString("view_catalog_relationshipxsl_relationshipSearchResults")%></title>
				<link rel="stylesheet" type="text/css" href="/app/css/mc_css.css"/>
				<script language="JavaScript">//<![CDATA[


    	var curselection = null;
		var alignArray = new Array();
		top.refreshPageNumbers('<%=recordCount%>');
		function window_onload() {

			top.document.body.style.cursor = "auto";
			top.datadirty=false;
			top.idBusy.style.display='none';

			var headerRow = resultsTable.rows[0];
			lastColumn = headerRow.cells.length -1;
			for (n=0;n<headerRow.cells.length;n++) {
				//alert("cell["+ n+"]="+ headerRow.cells(n).align);
				alignArray[n] = headerRow.cells(n).align;
			}
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
				
				if (theTR.Type == "" || theTR.Type == null) {
					top.document.searchForm.hdnSelectedType.value = top.document.searchForm.Display.value;
				}
			}
		}
		function onSort(col) {
		
			//alert("in onSort.. col = " + col);
			var sortCol = col;
			var sortDir = '<%=sortDirection%>';
			//top.datadirty=true;
			top.searchRequest('go', sortCol,sortDir);
			top.datadirty=true;
		}

    	function ValueExists(theTR){
    		theTable = top.parent.saveData2;

    		for (i=0;i<theTable.rows.length;i++){
    			if (theTable.rows[i].PK == eval("new String(theTR.PK);")){
    				return true;
    			}
    		}

    		return false;
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

    	function ValueExists(theTR){
    		theTable = top.parent.saveData2;

    		for (i=0;i<theTable.rows.length;i++){
    			if (theTable.rows[i].PK == eval("new String(theTR.PK);")){
    				return true;
    			}
    		}

    		return false;
    	}

		function moveRow(theTR){
        //alert("in moveRow.. " + theTR.PK1);
			 var rows = top.parent.saveData2.rows;
		 if(rows.length > '<%= Config.get("COPYFROM_LIMIT", "1") %>'){
			top.mcwarn('<%=messages.getString("warning")%>'+':','<%=messages.getString("view_catalog_detail_relationshipxsl_Youareonlypermittedtoselect")%> '+'<%= Config.get("COPYFROM_LIMIT", "1") %>'+' <%=messages.getString("view_catalog_detail_relationshipxsl_detailsstocopyfrom")%>');
		 } else{
			parent.detailtext.style.display = '';
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

    			theTable = top.parent.saveData2;
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
    			oNewRow = theDoc.createElement('<tr PK="' + eval("new String(theTR.PK);") + '" onclick="selectRow(this);" onDblClick="onDoubleClick(this,saveData1,saveData2);" oncontextmenu="top.showMenu(\'cntxtMenu\',null,self);" class="row_off" onMouseOver="this.className=\'row_on\'" onMouseOut="this.className=\'row_off\'" onDblClick="">');
			
				otbody.appendChild(oNewRow);

				oCell = theDoc.createElement('<TD valign="top" nowrap align="center" style="PADDING-RIGHT: 10px">');
				oCell.innerHTML = '<img src="/app/images/undo2.gif" onclick="removeRow(this,\'copyFrom\');" style="cursor:hand" alt="Remove this item">';
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
				parent.fromcount.innerText = parseFloat(parent.fromcount.innerHTML)+1;
				parent.selectionfromcount.innerText = parent.fromcount.innerText;
                oNewRow.scrollIntoView(true);
			}
			if (parseFloat(parent.fromcount.innerText) == 1)
			{
				parent.selectRow(oNewRow);
			}
		}
		}
		 }
		//alert("filterid =" +theTR.filterId + " searchBy=" + theTR.searchBy + " operator=" + theTR.operator + " searchValue=" + theTR.searchValue + " groupBy=" + theTR.groupBy);
	}




    	
		function onDoubleClick(theTR) {
			selectRow(theTR);
			top.onOpen();
		}



		
        //]]></script>
			</head>
			<body onload="window_onload()"  style="background-color:#FFFFFF;PADDING-RIGHT: 3px; PADDING-LEFT: 3px; PADDING-BOTTOM: 3px; PADDING-TOP: 3px">
			  <form name="detailForm">
				<table width="626" cellSpacing="0" name="resultsTable" id="resultsTable" border="0" cellPadding="1">
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
					<xsl:apply-templates select="Row"/>
				</table>
			  </form>
			</body>
		</html>
	</xsl:template>
	<!-- Column headings -->
	<xsl:template match="column" mode="headings">
	<xsl:variable name="displayName" select="display-name"/>
		<xsl:choose>
			<xsl:when test="$displayName='C SubRegion ID'">
			</xsl:when>
			<xsl:when test="$displayName='Channel ID'">
			</xsl:when>
			<xsl:otherwise>
				<td align="left" nowrap="nowrap" onmouseout="this.className='datatitlecell_off'" style="PADDING-RIGHT: 4px" class="datatitlecell_off" onmouseover="this.className='datatitlecell_on'">
				<xsl:attribute name="align"><xsl:value-of select="@align"/></xsl:attribute>
				<xsl:attribute name="align">left</xsl:attribute>
				<xsl:attribute name="onclick">onSort('<xsl:value-of select="sort-column"/>')</xsl:attribute>
				<xsl:attribute name="title"><xsl:value-of select="display-title"/></xsl:attribute>
				<xsl:value-of select="display-name"/>
				</td>
			</xsl:otherwise>
		</xsl:choose>	
	</xsl:template>
	<!-- Row data -->
	<xsl:template match="Row">

		<tr class="row_off" onclick="moveRow(this)" onmouseout="this.className='row_off'" onmouseover="this.className='row_on'">
			<xsl:attribute name="PK">
				<xsl:value-of select="Column[@name='CATALOG_DETAIL.PK']"/></xsl:attribute>
			<xsl:attribute name="ID">
				<xsl:value-of select="Column[@name='CATALOG_DETAIL.DETAIL_ID']"/></xsl:attribute>
			<xsl:attribute name="hier1">
				<xsl:value-of select="Column[@name='VWPRODUCT_LEAF.LEAF_LABEL']"/></xsl:attribute>
			<xsl:attribute name="hier2">
				<xsl:value-of select="Column[@name='VWCUSTOMER_LEAF.LEAF_LABEL']"/></xsl:attribute>
			<xsl:attribute name="hier3">
				</xsl:attribute>
			<xsl:attribute name="hier4">
				</xsl:attribute>
			<xsl:attribute name="hier5">
				</xsl:attribute>
			<xsl:attribute name="title">PK=<xsl:value-of select="Column[@name='CATALOG_DETAIL.PK']"/></xsl:attribute>
			<!--xsl:apply-templates select="Column"/-->
			<td style="cursor: default">
				<xsl:if test="current()/Column/@name='VWPRODUCT_LEAF.LEAF_LABEL'">
					<xsl:attribute name="class">normaltext</xsl:attribute>
					<xsl:attribute name="style">PADDING-RIGHT: 10px</xsl:attribute>
					<xsl:attribute name="align">left</xsl:attribute>
					<xsl:attribute name="nowrap">nowrap</xsl:attribute>
					<xsl:value-of select="Column[@name='VWPRODUCT_LEAF.LEAF_LABEL']"/>
				</xsl:if>
			</td>
			<td style="cursor: default">
				<xsl:if test="current()/Column/@name='VWPRODUCT_LEAF.DESCRIPTION'">
					<xsl:attribute name="class">normaltext</xsl:attribute>
					<xsl:attribute name="style">PADDING-RIGHT: 10px</xsl:attribute>
					<xsl:attribute name="align">left</xsl:attribute>
					<xsl:attribute name="nowrap">nowrap</xsl:attribute>
					<xsl:value-of select="Column[@name='VWPRODUCT_LEAF.DESCRIPTION']"/>
				</xsl:if>
			</td>
			<td style="cursor: default">
				<xsl:if test="current()/Column/@name='VWCUSTOMER_LEAF.LEAF_LABEL'">
					<xsl:attribute name="class">normaltext</xsl:attribute>
					<xsl:attribute name="style">PADDING-RIGHT: 10px</xsl:attribute>
					<xsl:attribute name="align">left</xsl:attribute>
					<xsl:attribute name="nowrap">nowrap</xsl:attribute>
					<xsl:value-of select="Column[@name='VWCUSTOMER_LEAF.LEAF_LABEL']"/>
				</xsl:if>
			</td>
			<td style="cursor: default">
				<xsl:if test="current()/Column/@name='VWCUSTOMER_LEAF.DESCRIPTION'">
					<xsl:attribute name="class">normaltext</xsl:attribute>
					<xsl:attribute name="style">PADDING-RIGHT: 10px</xsl:attribute>
					<xsl:attribute name="align">left</xsl:attribute>
					<xsl:attribute name="nowrap">nowrap</xsl:attribute>
					<xsl:value-of select="Column[@name='VWCUSTOMER_LEAF.DESCRIPTION']"/>
				</xsl:if>
			</td>
			
			
		</tr>
	</xsl:template>
	<!--xsl:template match="Column">
		<xsl:if test="$fdc/result-set-name=@name">
		  <xsl:choose>
		   <xsl:when test="$fdc[./result-set-name=current()/@name]/@editable='true'">	
			<td><input type="text">
			    	<xsl:attribute name="value"><xsl:value-of select="."/></xsl:attribute>
			    	<xsl:attribute name="name"><xsl:value-of select="$fdc[./result-set-name=current()/@name]/result-set-name"/></xsl:attribute>
					<xsl:attribute name="size">10</xsl:attribute>
			    </input>
				<input type="hidden">
			    	<xsl:attribute name="value"><xsl:value-of select="."/></xsl:attribute>
			    	<xsl:attribute name="name">hdn<xsl:value-of select="$fdc[./result-set-name=current()/@name]/result-set-name"/></xsl:attribute>
			    	<xsl:attribute name="size"><xsl:value-of select="current()/@type"/></xsl:attribute>
			    </input>
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
	</xsl:template-->
</xsl:stylesheet>
