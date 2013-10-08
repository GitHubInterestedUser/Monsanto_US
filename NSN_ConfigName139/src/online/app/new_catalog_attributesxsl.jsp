
	<%-- $Revision: 127 $ --%>
	<%-- $Date: 2012-02-08 01:30:56 -0800 (Wed, 08 Feb 2012) $ --%>
	<%-- $HeadURL: http://steelscm.domain.steelwedge.com:90/svn/sppm/releases/5.4.1Release/build/efmcore/src/online/app/new_catalog_attributesxsl.jsp $ --%>
<%@ page import="java.util.*" %>
<%@ page import="com.steelwedge.web.efm.FeatureController" %>
<jsp:useBean id="encodingHelper" class="com.steelwedge.web.efm.EncodingHelper" scope="page"/> 

	<%
		ResourceBundle messages;
	    messages = (ResourceBundle)session.getAttribute("resourceBundle");
		encodingHelper.setSelectedLocale((String)session.getAttribute("selectedLocale")); 
	    encodingHelper.setSelectedCountry((String)session.getAttribute("selecteCountry")); 
	    String encodingTechnique = encodingHelper.getEncodingTechnique(); 
	%>
	<%  String XMLPath = "";   
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

<?xml version="1.0" encoding="<%=encodingTechnique.substring(encodingTechnique.indexOf("=")+1,encodingTechnique.length())%>"?> 
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">

    <xsl:output method="html"/>
    <xsl:variable name="fdc" select="document('<%=XMLPath%>')//context[@name='catalog']/detail/<%=request.getParameter("type")%>/column"/>
    <xsl:template match="Rows">
        <html>
            <head>
			 
                <title><%=messages.getString("new_catalog_attributexsl_catalogManager")%></title>
                <link rel="stylesheet" type="text/css" href="/app/css/mc_css.css"/>

                <script language="JavaScript">//<![CDATA[
                function window_onload(){
                    if (document.detailForm.elements.length > 0) {
						footnote.style.display = '';
					}
					if (document.detailForm.ASSEMBLY_TYPE_CD) {
						for (i=0;i< document.detailForm.ASSEMBLY_TYPE_CD.length;i++) {
							if (document.detailForm.ASSEMBLY_TYPE_CD.options[i].value == '<%=request.getParameter("type")%>') {
								//alert("match.. " + document.detailForm.ASSEMBLY_TYPE.options[i].value  + " == " + '<%=request.getParameter("type")%>');
								document.detailForm.ASSEMBLY_TYPE_CD.options[i].selected = true;
							}
						}
					}
                }
				
				function onTypeChange() {
					newType = document.detailForm.ASSEMBLY_TYPE_CD.value;
					//alert("newType = " + newType);
					top.document.fraAttributes.location.href = "/efm/CatalogManager?pk=0&table=Attributes&type=" + newType;
				}
				
				function openFilterBrowser(callFrom,label,lookupField) {
					//alert("current callFrom=" + callFrom);
					callFromId = 0;
					callFromLabel=label;
					for (i=0;i< document.detailForm.elements.length;i++) {
						if (document.detailForm.elements[i].name == callFrom) {
							callFromId = i;
							curSelString = document.detailForm.elements[i].value;
							break;
						}
					}
					var param = new Object();
					param.caller = top;
					//alert('/efm/SingleLookup?context=catalog&targetFrame=fraAttributes&lookupField=' + lookupField + '&callFrom=' + callFromId + '&callFromName=' + callFrom + '&callFromLabel=' + callFromLabel + '&curSelString=' + curSelString);
					browsewin = showModalDialog('/efm/SingleLookup?context=catalog&targetFrame=fraAttributes&lookupField=' + lookupField + '&callFrom=' + callFromId + '&callFromName=' + callFrom + '&callFromLabel=' + encodeURIComponent(callFromLabel) + '&curSelString=' + curSelString, param,'dialogHeight: 500px; dialogWidth: 380px; dialogTop: px; dialogLeft: px; center: Yes; help: No; resizable: No; status: No; scroll: Yes;' );					
				}

                //document.onclick=top.dialogArguments.caller.doc_click;
    //]]></script>
            </head>
            <body onLoad="window_onload()" style="background-position: 0% 0%; background-color:#FFFFFF; background-repeat:no-repeat; background-attachment:scroll">

                <form name="detailForm" action="#" target="_self" method="POST">
                <table border="0" cellpadding="2" cellspacing="0" width="90%">
				<% 
				String hierarchyType = request.getParameter("type");
				
				if (!hierarchyType.equalsIgnoreCase("customer") && !hierarchyType.equalsIgnoreCase("geography") && !hierarchyType.equalsIgnoreCase("business") && !hierarchyType.equalsIgnoreCase("location")) { %>
				<tr>
				  <td class="sectiontitle"><%=messages.getString("new_catalog_attributexsl_sWProdType*")%></td>
				  <td>
					  	<select name="ASSEMBLY_TYPE_CD" onChange="onTypeChange()">
							<!--xsl:attribute name="disabled">disabled</xsl:attribute-->
							<option value="product/ITEM"><%=messages.getString("new_catalog_attributexsl_item")%></option>
							<!--option value="product/BOM">BOM</option-->
							<option value="product/SBOM"><%=messages.getString("new_catalog_attributexsl_sbom")%></option>
<!--							<option value="product/FORECASTSTRUCTURE">Forecast Structure</option>-->
<!--							<option value="product/PHANTOM">Phantom</option>-->
				  		</select>
				  </td>
				  <td><input type="hidden" name="hdnASSEMBLY_TYPE_CD" valeu="" size="2"/>
				      <input type="hidden">
						<xsl:attribute name="value">Type</xsl:attribute>
						<xsl:attribute name="name">lblASSEMBLY_TYPE_CD</xsl:attribute>
						<xsl:attribute name="size">1</xsl:attribute>
					 </input>
				  </td>
				</tr>
				<% 
				} 
				%>
				    <xsl:apply-templates select="Row" mode="LHS"/>
				<tr><td colspan="2"> </td></tr>
				<tr><td colspan="2"> </td></tr>
				<tr><td colspan="2" class="sectiontitle"><span id="footnote" style="display:'none'">   <%=messages.getString("new_catalog_attributexsl_requiredfieldscannotbeblank")%></span></td></tr>
                </table>
                </form>
            </body>
        </html>
    </xsl:template>

    <xsl:template match="Row" mode="LHS">
	<xsl:apply-templates select="Column" mode="LHS"/>
    </xsl:template>

    <xsl:template match="Column" mode="LHS">
	 <xsl:choose>
	  <xsl:when test="$fdc[./update-table=current()/@name]/@attribute='attribute'">
	   <xsl:if test="$fdc[./update-table=current()/@name]/@display='true'">
	   <tr>
	   <xsl:choose>
	   <xsl:when test="current()/@name='HIERARCHY_LEAF.IS_FORECASTED'">
							    	 <td style="cursor: default">
									  <xsl:attribute name="class">sectiontitle</xsl:attribute>
										<xsl:attribute name="title"><%=messages.getString("new_catalog_attributexsl_xsl_isForecasted")%></xsl:attribute>
									   <%=messages.getString("new_catalog_attributexsl_xsl_isForecasted")%>
									</td>
									 <td><input type="checkbox">
								    	 <xsl:attribute name="value">1</xsl:attribute>
								    	 <xsl:attribute name="name"><xsl:value-of select="$fdc[./update-table=current()/@name]/update-table"/></xsl:attribute>
								    	 <xsl:variable name="selected" select="."/>
								    	 <xsl:attribute name="checked">checked</xsl:attribute>
								    	 </input>
								     </td>

								     <td><input type="hidden">
								    	<xsl:attribute name="value"><xsl:value-of select="."/></xsl:attribute>
								    	<xsl:attribute name="name">hdn<xsl:value-of select="$fdc[./update-table=current()/@name]/update-table"/></xsl:attribute>
								    	<xsl:attribute name="size"><xsl:value-of select="current()/@type"/></xsl:attribute>
								    	</input>
										<input type="hidden">
								    	<xsl:attribute name="value"><xsl:value-of select="$fdc[./update-table=current()/@name]/display-name"/></xsl:attribute>
								    	<xsl:attribute name="name">lbl<xsl:value-of select="$fdc[./update-table=current()/@name]/update-table"/></xsl:attribute>
										<xsl:choose>
										<xsl:when test="$fdc[./update-table=current()/@name]/@required='true'">
										  <xsl:attribute name="size">1</xsl:attribute>
										</xsl:when>
										<xsl:otherwise>
										  <xsl:attribute name="size">2</xsl:attribute>
										</xsl:otherwise>
										</xsl:choose>
								    	</input>
								    </td>

	   </xsl:when>
	   <xsl:otherwise>
	   <!--xsl:if test="$fdc[./update-table=current()/@name]/@editable='true'"-->
		
			<xsl:if test="$fdc/update-table=@name">
		    <td style="cursor: default">
			<xsl:choose>
			<xsl:when test="$fdc[./update-table=current()/@name]/@required='true'">
			  <xsl:attribute name="class">sectiontitle</xsl:attribute>
			  <xsl:attribute name="title"><xsl:value-of select="$fdc[./update-table=current()/@name]/display-title"/></xsl:attribute>
			  <xsl:value-of select="$fdc[./update-table=current()/@name]/display-name"/>*
			</xsl:when>
			<xsl:otherwise>
			  <xsl:attribute name="class">normaltext</xsl:attribute>
			  <xsl:attribute name="title"><xsl:value-of select="$fdc[./update-table=current()/@name]/display-title"/></xsl:attribute>
			  <xsl:value-of select="$fdc[./update-table=current()/@name]/display-name"/>
			</xsl:otherwise>
			</xsl:choose>
		    </td>
		    
			    <td>
				<xsl:choose>
				<xsl:when test="$fdc[./update-table=current()/@name]/@editnew='true'">
					<input type="text">
			    	<xsl:attribute name="value"><xsl:value-of select="."/></xsl:attribute>
			    	<xsl:attribute name="name"><xsl:value-of select="$fdc[./update-table=current()/@name]/update-table"/></xsl:attribute>
					<xsl:variable name="maxsize" select="$fdc[./update-table=current()/@name]/@maxlength"/>
					<xsl:if test="$maxsize != ''">
						<xsl:attribute name="maxlength"><xsl:value-of select="$maxsize"/></xsl:attribute>
					</xsl:if>
			    	</input>
				</xsl:when>
				<xsl:otherwise>
					<input type="text">
			    	<xsl:attribute name="value"><xsl:value-of select="."/></xsl:attribute>
					<xsl:attribute name="disabled">disabled</xsl:attribute>
			    	<xsl:attribute name="name"><xsl:value-of select="$fdc[./update-table=current()/@name]/update-table"/></xsl:attribute>
			    	</input>				
				</xsl:otherwise>
				</xsl:choose>
				<xsl:if test="$fdc[./update-table=current()/@name]/@searchable='true'">
					<img src="/app/images/icons/lookupicon.gif" style="cursor:hand" border="0" alt="" width="16" height="13" ONDRAGSTART="return false">
						<xsl:attribute name="onclick">javascript:openFilterBrowser('<xsl:value-of select="$fdc[./update-table=current()/@name]/update-table"/>',"<xsl:value-of select="$fdc[./update-table=current()/@name]/display-name"/>",'<xsl:value-of select="$fdc[./update-table=current()/@name]/result-set-name"/>','fromBackend')
						</xsl:attribute>
					</img>
				</xsl:if>
			    </td>
			    <td><input type="hidden">
			    	<xsl:attribute name="value"><xsl:value-of select="."/></xsl:attribute>
			    	<xsl:attribute name="name">hdn<xsl:value-of select="$fdc[./update-table=current()/@name]/update-table"/></xsl:attribute>
			    	<xsl:attribute name="size"><xsl:value-of select="current()/@type"/></xsl:attribute>
			    	</input>
					<input type="hidden">
					<xsl:attribute name="value"><xsl:value-of select="$fdc[./update-table=current()/@name]/display-name"/></xsl:attribute>
					<xsl:attribute name="name">lbl<xsl:value-of select="$fdc[./update-table=current()/@name]/update-table"/></xsl:attribute>
					<xsl:choose>
					<xsl:when test="$fdc[./update-table=current()/@name]/@required='true'">
					  <xsl:attribute name="size">1</xsl:attribute>
					</xsl:when>
					<xsl:otherwise>
					  <xsl:attribute name="size">2</xsl:attribute>
					</xsl:otherwise>
					</xsl:choose>
					</input>
			    </td>
				
			
			</xsl:if>
		</xsl:otherwise>
		</xsl:choose>
	   </tr>
	   </xsl:if>
	  </xsl:when>
	 </xsl:choose>
    </xsl:template>


</xsl:stylesheet><!-- Stylus Studio meta-information - (c)1998-2002 eXcelon Corp.
<metaInformation>
<scenarios ><scenario default="yes" name="Scenario1" userelativepaths="yes" externalpreview="no" url="newcatalog_attributes.xml" htmlbaseurl="" outputurl="" processortype="internal" commandline="" additionalpath="" additionalclasspath="" postprocessortype="none" postprocesscommandline="" postprocessadditionalpath="" postprocessgeneratedext=""/></scenarios><MapperInfo srcSchemaPath="" srcSchemaRoot="" srcSchemaPathIsRelative="yes" srcSchemaInterpretAsXML="no" destSchemaPath="" destSchemaRoot="" destSchemaPathIsRelative="yes" destSchemaInterpretAsXML="no"/>
</metaInformation>
-->