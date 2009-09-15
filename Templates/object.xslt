<?xml version="1.0" encoding="utf-8"?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
	<xsl:output method="xml" indent="yes"/>
	<xsl:strip-space elements="*"/>
	<xsl:template match="/">
		<xsl:apply-templates select="doxygen/compounddef"/>
	</xsl:template>
	
	<!-- General "Functions" -->
	<xsl:template name="filename">
		<xsl:param name="path"/>
		<xsl:choose>
			<xsl:when test="contains($path,'/')">
				<xsl:call-template name="filename">
					<xsl:with-param name="path" select="substring-after($path,'/')"/>
				</xsl:call-template>
			</xsl:when>
			<xsl:otherwise>
				<xsl:value-of select="$path"/>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>
	
	<!-- Prototype -->
	<xsl:template name="prototype">
		<xsl:choose>
			<xsl:when test="@kind='property'">@property <xsl:apply-templates select="type"/>
					
				<xsl:choose>
					<xsl:when test="substring(type, string-length(type)-1, 2)=' *'">
						
					</xsl:when>
					<xsl:otherwise>
						<xsl:text> </xsl:text>
					</xsl:otherwise>
				</xsl:choose>
					
				<xsl:value-of select="name"/>
			</xsl:when>
			<xsl:when test="@kind='function'">
				<xsl:choose>
					<xsl:when test="@static='no'">- </xsl:when>
					<xsl:when test="@static='yes'">+ </xsl:when>
				</xsl:choose>(<xsl:apply-templates select="type"/>)<xsl:call-template name="prototypeWithArguments">
					<xsl:with-param name="string" select="name"/>
				</xsl:call-template>
			</xsl:when>
		</xsl:choose>
	</xsl:template>
	<xsl:template name="prototypeWithArguments">
		<xsl:param name="string"/>
		<xsl:choose>
			<xsl:when test="contains($string,':')">
				<xsl:value-of select="substring($string,0,string-length(substring-before($string,':'))+2)"/>
				<xsl:variable name="attribute">
					<xsl:text>[</xsl:text><xsl:value-of select="substring-before($string,':')"/><xsl:text>]</xsl:text>
				</xsl:variable>
				<xsl:choose>
					<xsl:when test="param[attributes=$attribute]">(<xsl:apply-templates select="param[attributes=$attribute]/type"/>)<parameter><xsl:value-of select="param[attributes=$attribute]/declname"/></parameter>
					</xsl:when>
					<xsl:otherwise>(<xsl:apply-templates select="param[1]/type"/>)<parameter><xsl:value-of select="param[1]/declname"/></parameter>
					</xsl:otherwise>
				</xsl:choose>
				<xsl:text> </xsl:text>
				<xsl:call-template name="prototypeWithArguments">
					<xsl:with-param name="string" select="substring-after($string,':')"/>
				</xsl:call-template>
					
			</xsl:when>
			<xsl:otherwise>
				<xsl:value-of select="$string"/>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>
	
	<xsl:template match="type">
		<!-- Remove the spaces from the protocol declarations on data types -->
		<xsl:variable name="leftProtocolSpaceRemoved">
			<xsl:call-template name="replace-string"> <!-- imported template -->
			    <xsl:with-param name="text" select="."/>
				<xsl:with-param name="replace" select="'&lt; '"/>
	        	<xsl:with-param name="with" select="'&lt;'"/>
			</xsl:call-template>
		</xsl:variable>
		<xsl:call-template name="replace-string"> <!-- imported template -->
		    <xsl:with-param name="text" select="$leftProtocolSpaceRemoved"/>
			<xsl:with-param name="replace" select="' &gt;'"/>
        	<xsl:with-param name="with" select="'&gt;'"/>
		</xsl:call-template>
	</xsl:template>
	
	<!-- General String Replacement -->
	<xsl:template name="replace-string">
	    <xsl:param name="text"/>
	    <xsl:param name="replace"/>
	    <xsl:param name="with"/>
	    <xsl:choose>
	      <xsl:when test="contains($text,$replace)">
	        <xsl:value-of select="substring-before($text,$replace)"/>
	        <xsl:value-of select="$with"/>
	        <xsl:call-template name="replace-string">
	          <xsl:with-param name="text" select="substring-after($text,$replace)"/>
	          <xsl:with-param name="replace" select="$replace"/>
	          <xsl:with-param name="with" select="$with"/>
	        </xsl:call-template>
	      </xsl:when>
	      <xsl:otherwise>
	        <xsl:value-of select="$text"/>
	      </xsl:otherwise>
	    </xsl:choose>
	  </xsl:template>
	
	
	
	<!-- Basic Tags -->
	<!--<xsl:template match="*">
		<xsl:copy>
			<xsl:copy-of select="@*"/>
			<xsl:apply-templates/>
		</xsl:copy>
    </xsl:template>-->

	<xsl:template match="ref">		
		<ref>
	    <!--  <xsl:attribute name="id">
	        <xsl:value-of select="text()"/>
	      </xsl:attribute>
	      <xsl:attribute name="kind">
	        <xsl:value-of select="@kindref"/>
	      </xsl:attribute>-->
	      <xsl:apply-templates/>
	    </ref>
	</xsl:template>
	
	<xsl:template match="bold">
		<strong><xsl:apply-templates/></strong>
	</xsl:template>
	
	<xsl:template match="emphasis">
		<emphasis><xsl:apply-templates/></emphasis>
	</xsl:template>
	
	<xsl:template match="para">
		<xsl:choose>
			<xsl:when test="count(verbatim) > 0">
				<example><xsl:apply-templates select="verbatim"/></example>
			</xsl:when>
			<xsl:otherwise>
				<para><xsl:apply-templates/></para>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>
	
	<xsl:template match="computeroutput">
		<code><xsl:apply-templates/></code>
	</xsl:template>
	
	<xsl:template match="itemizedlist">
		<list>
			<xsl:apply-templates/>
		</list>
	</xsl:template>
	<xsl:template match="listitem">
		<item>
			<xsl:apply-templates/>
		</item>
	</xsl:template>
	
	<!-- Formatting -->
	
	<xsl:template match="compounddef">
		<object>
			<!-- UPDATE 2008-09-02: doxygen marks categories as classes, so we have
				 to make further tests - if the name includes parenthesis, then this is
				 not a class but is category instead! -->
			<xsl:attribute name="kind">
				<xsl:choose>
					<xsl:when test="contains(compoundname,'(')">
						<xsl:text>category</xsl:text>
					</xsl:when>
					<xsl:otherwise>
						<xsl:value-of select="@kind"/>
					</xsl:otherwise>
				</xsl:choose>				
			</xsl:attribute>
			<!-- ENDUPDATE -->
			<name>
				<xsl:apply-templates select="compoundname"/>
			</name>
			<file>
				<xsl:call-template name="filename">
					<xsl:with-param name="path" select="location/@file"/>
				</xsl:call-template>
			</file>
			<xsl:apply-templates select="basecompoundref"/>
			<xsl:apply-templates select="detaileddescription/para/simplesect[@kind='author']/para"/>
			<description>
				<xsl:apply-templates select="briefdescription"/>
				<xsl:apply-templates select="detaileddescription"/>
			</description>
			<xsl:apply-templates select="detaileddescription/para" mode="seeAlso"/>
			<sections>
				<xsl:apply-templates select="sectiondef"/>
			</sections>
		</object>
	</xsl:template>
	
	<xsl:template match="basecompoundref">
		<base>
			<xsl:value-of select="text()"/>
		</base>
	</xsl:template>
	
	<xsl:template match="compoundname">
		<!-- Fix protocol names: They have a dangling -p at the end of the name -->
		<xsl:choose>
			<xsl:when test="../@kind='protocol'">
				<xsl:value-of select="substring(.,0,string-length(.)-1)"/>
			</xsl:when>
			<xsl:otherwise>
				<xsl:apply-templates/>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>

	<xsl:template match="briefdescription">
		<brief><xsl:apply-templates/></brief>
	</xsl:template>
	
	<xsl:template match="detaileddescription">
		<details><xsl:apply-templates/></details>
	</xsl:template>
	<xsl:template match="detaileddescription/para/simplesect">
	</xsl:template>
	<xsl:template match="detaileddescription/para/parameterlist">
	</xsl:template>
	<xsl:template match="detaileddescription/para/xrefsect">
	</xsl:template>
	
	<xsl:template match="simplesect[@kind='author']/para">
		<author><xsl:apply-templates/></author>
	</xsl:template>
	
	<xsl:template match="sectiondef">
		<xsl:apply-templates select="@kind='user-defined'"/>
		<xsl:apply-templates select="@kind!='user-defined'"/>
	</xsl:template>
	
	<xsl:template match="sectiondef[@kind='user-defined']">
		<section>
			<name><xsl:apply-templates select="header"/></name>
			<xsl:apply-templates select="memberdef[briefdescription/para or detaileddescription/para]"/>
		</section>
	</xsl:template>
	
	<xsl:template match="sectiondef[@kind!='user-defined']">
		<xsl:if test="count(memberdef[@kind!='variable' and (briefdescription/para or detaileddescription/para)]) > 0">
			<section>
				<name>Other</name>
				<xsl:apply-templates select="memberdef[@kind!='variable' and (briefdescription/para or detaileddescription/para)]"/>
			</section>
		</xsl:if>
	</xsl:template>
	
	<xsl:template match="memberdef">
		<member>
			<xsl:choose>
				<xsl:when test="@kind='function' and @static='yes' and @const='no'">
					<xsl:attribute name="kind">class-method</xsl:attribute>
				</xsl:when>
				<xsl:when test="@kind='function' and @static='no' and @const='no'">
					<xsl:attribute name="kind">instance-method</xsl:attribute>
				</xsl:when>
				<xsl:when test="@kind='property'">
					<xsl:attribute name="kind">property</xsl:attribute>
				</xsl:when>
			</xsl:choose>
			<name><xsl:apply-templates select="name"/></name>
			<type><xsl:apply-templates select="type"/></type>
			<prototype><xsl:call-template name="prototype"/></prototype>
			<file>
				<xsl:call-template name="filename">
					<xsl:with-param name="path" select="location/@file"/>
				</xsl:call-template>
			</file>
			<description>
				<xsl:apply-templates select="briefdescription"/>
				<xsl:apply-templates select="detaileddescription"/>
			</description>
			<xsl:apply-templates select="detaileddescription/para/simplesect[@kind='warning']" mode="warning"/>
			<xsl:apply-templates select="detaileddescription/para/xrefsect" mode="bug"/>
			<xsl:apply-templates select="detaileddescription/para/parameterlist[@kind='param']" mode="parameters"/>
			<xsl:apply-templates select="detaileddescription/para/parameterlist[@kind='exception']" mode="exceptions"/>
			<xsl:apply-templates select="detaileddescription/para" mode="return"/>
			<xsl:apply-templates select="detaileddescription/para" mode="seeAlso"/>
		</member>
	</xsl:template>
	
	<xsl:template match="detaileddescription/para/parameterlist" mode="parameters">
		<parameters>
			<xsl:apply-templates/>
		</parameters>
	</xsl:template>
	<xsl:template match="detaileddescription/para/parameterlist" mode="exceptions">
		<exceptions>
			<xsl:apply-templates/>
		</exceptions>
	</xsl:template>
	<xsl:template match="parameteritem">
		<param>
			<name>
				<xsl:apply-templates select="parameternamelist"/>
			</name>
			<description>
				<xsl:apply-templates select="parameterdescription"/>
			</description>
		</param>
	</xsl:template>
	
	<xsl:template match="detaileddescription/para" mode="seeAlso">
		<xsl:if test="simplesect[@kind='see']">
			<seeAlso>
				<xsl:apply-templates select="simplesect[@kind='see']/para"/>
			</seeAlso>
		</xsl:if>
	</xsl:template>
	<xsl:template match="simplesect[@kind='see']/para">
		<item><xsl:apply-templates/></item>
	</xsl:template>
	
	<xsl:template match="detaileddescription/para" mode="return">
		<xsl:if test="simplesect[@kind='return']">
			<return>
				<xsl:apply-templates select="simplesect[@kind='return']/para"/>
			</return>
		</xsl:if>
	</xsl:template>
	
	<xsl:template match="detaileddescription/para/simplesect[@kind='warning']" mode="warning">
		<warning>
			<xsl:apply-templates/>
		</warning>
	</xsl:template>
	
	<xsl:template match="detaileddescription/para/xrefsect" mode="bug">
		<bug>
			<xsl:apply-templates select="xrefdescription"/>
		</bug>
	</xsl:template>
	<xsl:template match="xrefdescription">
		<xsl:apply-templates/>
	</xsl:template>
	
</xsl:stylesheet>
