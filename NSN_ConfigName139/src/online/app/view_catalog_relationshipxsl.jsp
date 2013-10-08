
	<%-- $Revision: 127 $ --%>
	<%-- $Date: 2012-02-08 01:30:56 -0800 (Wed, 08 Feb 2012) $ --%>
	<%-- $HeadURL: http://steelscm.domain.steelwedge.com:90/svn/sppm/releases/5.4.1Release/build/efmcore/src/online/app/view_catalog_relationshipxsl.jsp $ --%>
<%@ page import="com.steelwedge.web.efm.FeatureController" %>
<%@ page import="java.util.*" %>
<jsp:useBean id="encodingHelper" class="com.steelwedge.web.efm.EncodingHelper" scope="page"/> 
<%
	String recordCount = "";
	recordCount = request.getParameter("count");
	ResourceBundle messages;
    messages = (ResourceBundle)session.getAttribute("resourceBundle");
	encodingHelper.setSelectedLocale((String)session.getAttribute("selectedLocale")); 
	encodingHelper.setSelectedCountry((String)session.getAttribute("selecteCountry")); 
	String encodingTechnique = encodingHelper.getEncodingTechnique(); 
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
		top.refreshPageNumbers('<%=recordCount%>');
		function window_onload() {
			top.document.body.style.cursor = "auto";
		}

    	function ValueExists(theTR){
    		theTable = top.parent.saveData;

    		for (i=0;i<theTable.rows.length;i++){
    			if (theTable.rows[i].PK == eval("new String(theTR.PK);")){
    				return true;
    			}
    		}

    		return false;
    	}


    	function selectRow(theTR){
        //alert("in selectRow.." + theTR.PK);
			var rowhighlight = '#D8EDF9';

			if (curselection)
			{
				curselection.style.backgroundColor = '';
			}

        	if (theTR.PK != "headerRow") {
				curselection = theTR;
				curselection.style.backgroundColor = rowhighlight;
				top.document.pageForm.hdnSelectedPK.value = theTR.PK;
				top.document.pageForm.hdnSelectedID.value = theTR.ID;
				top.document.pageForm.hdnHier1.value = theTR.hier1;
				top.document.pageForm.hdnHier2.value = theTR.hier2;
				top.document.pageForm.hdnHier3.value = theTR.hier3;
				top.document.pageForm.hdnHier4.value = theTR.hier4;
				top.document.pageForm.hdnHier5.value = theTR.hier5;
			}
		}
		
		function onDoubleClick(theTR) {
			selectRow(theTR);
			top.onOpen();
		}



		
        //]]></script>
			</head>
			<body onload="window_onload()"  style="background-color:#FFFFFF;PADDING-RIGHT: 3px; PADDING-LEFT: 3px; PADDING-BOTTOM: 3px; PADDING-TOP: 3px">
			  <form name="searchForm">
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
		<td align="left" nowrap="nowrap" onmouseout="this.className='datatitlecell_off'" style="PADDING-RIGHT: 5px" class="datatitlecell_off" onmouseover="this.className='datatitlecell_on'">
			<xsl:attribute name="title"><xsl:value-of select="display-title"/></xsl:attribute>
			<xsl:value-of select="display-name"/>
		</td>
	</xsl:template>
	<!-- Row data -->
	<xsl:template match="Row">

		<tr class="row_off" onclick="selectRow(this)" onDblClick="onDoubleClick(this)" onmouseout="this.className='row_off'" onmouseover="this.className='row_on'">
			<xsl:attribute name="PK">
				<xsl:value-of select="Column[@name='CATALOG_DETAIL.PK']"/></xsl:attribute>
			<xsl:attribute name="ID">
				<xsl:value-of select="Column[@name='CATALOG_DETAIL.DETAIL_ID']"/></xsl:attribute>
			<xsl:attribute name="hier1">
				<xsl:value-of select="Column[@name='VWPRODUCT_LEAF.LEAF_LABEL']"/></xsl:attribute>
			<xsl:attribute name="hier2">
				<xsl:value-of select="Column[@name='VWCUSTOMER_LEAF.LEAF_LABEL']"/></xsl:attribute>
			<xsl:attribute name="hier3">
				<xsl:value-of select="Column[@name='VWGEOGRAPHY_LEAF.THEATER']"/></xsl:attribute>
			<xsl:attribute name="hier4"></xsl:attribute>
			<xsl:attribute name="hier5"></xsl:attribute>
			<xsl:attribute name="title">PK=<xsl:value-of select="Column[@name='CATALOG_DETAIL.PK']"/></xsl:attribute>
			<!--xsl:apply-templates select="Column"/-->
		
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
			
			
			<td style="cursor: default">
				<xsl:if test="current()/Column/@name='VWCUSTOMER_LEAF.LEAF_LABEL'">
					<xsl:attribute name="class">normaltext</xsl:attribute>
					<xsl:attribute name="style">PADDING-RIGHT: 10px</xsl:attribute>
					<xsl:attribute name="nowrap">nowrap</xsl:attribute>
					<xsl:value-of select="Column[@name='VWCUSTOMER_LEAF.LEAF_LABEL']"/>
				</xsl:if>
			</td>
			<td style="cursor: default">
				<xsl:if test="current()/Column/@name='VWCUSTOMER_LEAF.DESCRIPTION'">
					<xsl:attribute name="class">normaltext</xsl:attribute>
					<xsl:attribute name="style">PADDING-RIGHT: 10px</xsl:attribute>
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
</xsl:stylesheet><!-- Stylus Studio meta-information - (c)1998-2002 eXcelon Corp.
<metaInformation>
<scenarios ><scenario default="yes" name="Scenario2" userelativepaths="yes" externalpreview="no" url="search_results.xml" htmlbaseurl="" outputurl="" processortype="internal" commandline="" additionalpath="" additionalclasspath="" postprocessortype="none" postprocesscommandline="" postprocessadditionalpath="" postprocessgeneratedext=""/></scenarios><MapperInfo srcSchemaPath="" srcSchemaRoot="" srcSchemaPathIsRelative="yes" srcSchemaInterpretAsXML="no" destSchemaPath="" destSchemaRoot="" destSchemaPathIsRelative="yes" destSchemaInterpretAsXML="no"/>
</metaInformation>
-->
