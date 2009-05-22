<?xml version="1.0" encoding="utf-8"?>
<xsl:stylesheet xmlns:xhtml="http://www.w3.org/1999/xhtml" xmlns="http://www.w3.org/1999/xhtml" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:date="http://exslt.org/dates-and-times" version="1.0" exclude-result-prefixes="xhtml" extension-element-prefixes="date">
	<xsl:output method="xml" indent="yes" doctype-system="http://www.w3.org/TR/xhtml1/DTD/xhtml1-strict.dtd" doctype-public="-//W3C//DTD XHTML 1.0 STRICT//EN" />
	
	<xsl:param name="lastUpdatedDate">%LastUpdatedDate%</xsl:param>
	
	<xsl:template match="/">	
		<html xmlns="http://www.w3.org/1999/xhtml" xml:lang="en" lang="en">
		<head>
			<title><xsl:apply-templates select="object" mode="title"/></title>
			<meta http-equiv="Content-Type" content="application/xhtml+xml;charset=utf-8" />
			<link rel="stylesheet" type="text/css" href="../css/screen.css" />
			<meta name="generator" content="DoxyClean" />
		</head>
		<body>
			<div id="mainContainer">
				
				<h1><a name="classTitle" /><xsl:apply-templates select="object" mode="title"/></h1>
				
	<!-- Info Table -->

	<xsl:variable name="headerHasInheritsFrom">
		<xsl:if test="normalize-space(object/base/text())">
			<xsl:text>YES</xsl:text>
		</xsl:if>
	</xsl:variable>
	<xsl:variable name="headerHasConformsTo">
		<xsl:if test="normalize-space(object/protocol/text())">
			<xsl:text>YES</xsl:text>
		</xsl:if>
	</xsl:variable>
	<xsl:variable name="declaredInClass">
		<xsl:choose>
			<xsl:when test="string-length($headerHasInheritsFrom)&gt;0 and string-length($headerHasConformsTo)&gt;0">
				<xsl:text>alt</xsl:text>
			</xsl:when>
			<xsl:when test="string-length($headerHasInheritsFrom)=0 and string-length($headerHasConformsTo)=0">
				<xsl:text>alt</xsl:text>
			</xsl:when>
		</xsl:choose>
	</xsl:variable>
	
	<table summary="Basic information" id="classInfo">
		<xsl:if test="$headerHasInheritsFrom = 'YES'">
			<tr class="alt">
				<td><label id="classDeclaration">Inherits from</label></td>
				<td>
					<xsl:choose>
						<xsl:when test="object/base[@id]">
							<a>
								<xsl:attribute name="href"><xsl:value-of select="object/base[@id]"/>.html</xsl:attribute>
								<xsl:apply-templates select="object/base"/>
							</a>
						</xsl:when>
						<xsl:otherwise>
							<xsl:apply-templates select="object/base"/>
						</xsl:otherwise>
					</xsl:choose>
				</td>
			</tr>
<xsl:text>
</xsl:text>
		</xsl:if>
		<xsl:if test="$headerHasConformsTo = 'YES'">
			<tr>
				<xsl:if test="not($headerHasInheritsFrom)">
					<xsl:attribute name="class">alt</xsl:attribute>
				</xsl:if>
				<td><label id="classDeclaration">Conforms to</label></td>
				<td>
					<xsl:variable name="protocolsCount" select="count(/object/protocol)"/>
					<xsl:for-each select="/object/protocol">
						<xsl:choose>
							<xsl:when test="@id">
								<a>
									<xsl:attribute name="href"><xsl:value-of select="@id"/></xsl:attribute>
									<xsl:value-of select="text()"/>
								</a>
							</xsl:when>
							<xsl:otherwise>
								<xsl:value-of select="text()"/>
							</xsl:otherwise>
						</xsl:choose>
						<xsl:if test="$protocolsCount &gt; 1 and position() &lt; $protocolsCount">
							<br/>
						</xsl:if>
					</xsl:for-each>
				</td>
			</tr>
<xsl:text>
</xsl:text>
		</xsl:if>
		<tr>
			<xsl:attribute name="class"><xsl:value-of select="$declaredInClass"/></xsl:attribute>
			<td><label id="classDeclaration">Declared in</label></td>
			<td><xsl:apply-templates select="object/file"/></td>
		</tr>
	</table>

	<!-- End Info Table -->
	
<xsl:text>
</xsl:text>
				
<xsl:text>
	</xsl:text><xsl:apply-templates select="object/description"/>
				
				<xsl:apply-templates select="object/sections"/>
				
				<xsl:call-template name="properties"/>
				<xsl:call-template name="classMethods"/>
				<xsl:call-template name="instanceMethods"/>
				
				<hr/>
				<p id="lastUpdated">
					Last updated: <xsl:value-of select="$lastUpdatedDate"/>
					<br/>
					Back to <a href="../Index.html">index</a>.
				</p>
				
			</div>
		</body>
		</html>
		
	</xsl:template>

	<xsl:template match="object" mode="title">
		<xsl:apply-templates select="name"/>
		<xsl:choose>
			<xsl:when test="@kind='class'"><xsl:text> Class</xsl:text></xsl:when>
			<xsl:when test="@kind='category'"><xsl:text> Category</xsl:text></xsl:when>
			<xsl:when test="@kind='protocol'"><xsl:text> Protocol</xsl:text></xsl:when>
		</xsl:choose>
		<xsl:text> Reference</xsl:text>
	</xsl:template>
	
	<!-- General Tags -->
	<xsl:template match="para">
		<p><xsl:apply-templates/></p>
	</xsl:template>
	
	<xsl:template match="code">
		<code><xsl:apply-templates/></code>
	</xsl:template>
	
	<xsl:template match="list">
		<ul>
			<xsl:apply-templates/>
		</ul>
	</xsl:template>
	<xsl:template match="list/item">
		<li><xsl:apply-templates/></li>
	</xsl:template>
	
	<xsl:template match="member" mode="details">
<xsl:text>
		</xsl:text><h3>
			<a>
				<xsl:attribute name="name">
<xsl:value-of select="name"/>
				</xsl:attribute>
			</a>
			<xsl:value-of select="name"/>
		</h3>
		
		<xsl:apply-templates select="description/brief"/>
		<code class="methodDeclaration">
			<xsl:apply-templates select="prototype"/>
		</code>
		
		<xsl:apply-templates select="parameters"/>
		<xsl:apply-templates select="exceptions"/>
		<xsl:apply-templates select="return"/>
		
		<xsl:apply-templates select="description/details"/>
		
		<xsl:apply-templates select="warning"/>
		
		<xsl:apply-templates select="bug"/>
		
		<xsl:apply-templates select="seeAlso"/>
		
		<xsl:apply-templates select="file"/>
		
<xsl:text>
</xsl:text>
		
	</xsl:template>
	
	<xsl:template match="prototype">
		<xsl:apply-templates/>
	</xsl:template>
	
	<xsl:template match="prototype/parameter">
		<span class="parameter">
			<xsl:apply-templates/>
		</span>
	</xsl:template>
	
	<xsl:template match="parameters">
<xsl:text>
		</xsl:text><h5>Parameters</h5>
		<dl class="parameterList">
			<xsl:apply-templates/>
		</dl>
	</xsl:template>
<xsl:template match="exceptions">
<xsl:text>
		</xsl:text><h5>Exceptions</h5>
		<dl class="parameterList">
			<xsl:apply-templates/>
		</dl>
	</xsl:template>	<xsl:template match="param">
		<dt>
			<xsl:apply-templates select="name"/>
		</dt>
		<dd>
			<xsl:apply-templates select="description"/>
		</dd>
	</xsl:template>
	
	<xsl:template match="return">
<xsl:text>
		</xsl:text><h5>Return Value</h5>
		<xsl:apply-templates/>
	</xsl:template>
	
	<xsl:template match="member/description/details">
		<xsl:if test="para[1]/. != ''">
<xsl:text>
		</xsl:text><h5>Discussion</h5>
			<xsl:apply-templates/>
		</xsl:if>
	</xsl:template>
	
	<xsl:template match="member/warning">
<xsl:text>
		</xsl:text><h5>Warning</h5>
		<xsl:apply-templates/>
	</xsl:template>
	
	<xsl:template match="member/bug">
<xsl:text>
		</xsl:text><h5>Bug</h5>
		<xsl:apply-templates/>
	</xsl:template>
	
	<xsl:template match="seeAlso">
		<h5>See Also</h5>
<xsl:text>
		</xsl:text><ul class="seeAlso">
			<xsl:apply-templates select="item"/>
		</ul>
	</xsl:template>
	<xsl:template match="seeAlso/item">
<xsl:text>
			</xsl:text><li>
			<code>
				<a>
					<xsl:attribute name="href">#<xsl:value-of select="normalize-space(translate(.,'-+',''))"/></xsl:attribute>
					<xsl:apply-templates/>
				</a>
			</code>
		</li>
	</xsl:template>
	
	<xsl:template match="ref">
		<code>
			<xsl:choose>
				<xsl:when test="/object/name != @id">
					<!-- UPDATED 2008-09-03: Python script is responsible for creating actual link for us - it's simpler that way... -->
		<a><xsl:attribute name="href"><xsl:text></xsl:text><xsl:value-of select="@id"/></xsl:attribute><xsl:apply-templates/></a>
<!--					<xsl:choose>
						<xsl:when test="@kind = 'class'">
		<a><xsl:attribute name="href"><xsl:value-of select="@id"/>.html</xsl:attribute><xsl:apply-templates/></a>
						</xsl:when>
						<xsl:otherwise>
		<a><xsl:attribute name="href"><xsl:text></xsl:text><xsl:value-of select="@id"/></xsl:attribute><xsl:apply-templates/></a>
						</xsl:otherwise>
					</xsl:choose> -->
					<!-- ENDUPDATE -->
				</xsl:when>
				<xsl:otherwise>
					<xsl:apply-templates/>
				</xsl:otherwise>
			</xsl:choose>
		</code>
	</xsl:template>
	
	<xsl:template match="member/file">
<xsl:text>
		</xsl:text><h5>Declared In</h5>
		<code>
			<xsl:apply-templates/>
		</code>
	</xsl:template>
	
	<!-- Overview -->
	<xsl:template match="object/description">
		<xsl:if test="brief or details">
			<h2>Overview</h2>
			<xsl:apply-templates select="brief"/>
			<xsl:apply-templates select="details"/>
		</xsl:if>
	</xsl:template>
	
	<!-- Sections -->
	<xsl:template match="sections">
		<xsl:if test="count(section) > 0">
<xsl:text>
	</xsl:text><h2>Tasks</h2>	
			<xsl:apply-templates select="section"/>
		</xsl:if>
	</xsl:template>
	
	<xsl:template match="section">
		<xsl:if test="count(member) > 0">
<xsl:text>
	</xsl:text><h3><xsl:apply-templates select="name"/></h3>
<xsl:text>
	</xsl:text><ul class="methods">
				<xsl:apply-templates select="member" mode="index"/>
<xsl:text>
	</xsl:text></ul>
<xsl:text>
</xsl:text>
		</xsl:if>
	</xsl:template>
	
	<xsl:template match="member" mode="index">
<xsl:text>
			</xsl:text><li>
			<span class="tooltipRegion">
				<code>
					<a>
						<xsl:attribute name="href">#<xsl:value-of select="name"/></xsl:attribute>
						<xsl:choose>
							<xsl:when test="@kind='class-method'">+ </xsl:when>
							<xsl:when test="@kind='instance-method'">- </xsl:when>
						</xsl:choose>
						<xsl:apply-templates select="name"/>
					</a>
				</code>
			
				<xsl:choose>
					<xsl:when test="@kind='property'">
						<xsl:text> </xsl:text><span class="specialType">property</span>
					</xsl:when>
				</xsl:choose>
				
				<span class="tooltip"><xsl:value-of select="description/brief"/></span>
			</span>
			
		</li>
	</xsl:template>
	
	<!-- Properties -->
	<xsl:template name="properties">
		<xsl:if test="count(object/sections/section/member[@kind='property']) > 0">
<xsl:text>
		</xsl:text><h2>Properties</h2>
			<xsl:apply-templates select="object/sections/section/member[@kind='property']" mode="details"/>
		</xsl:if>
	</xsl:template>
	
	<!-- Class Methods -->
	<xsl:template name="classMethods">
		<xsl:if test="count(object/sections/section/member[@kind='class-method']) > 0">
<xsl:text>
		</xsl:text><h2>Class Methods</h2>
			<xsl:apply-templates select="object/sections/section/member[@kind='class-method']" mode="details"/>
		</xsl:if>
	</xsl:template>
	
	<!-- Instance Methods -->
	<xsl:template name="instanceMethods">
		<xsl:if test="count(object/sections/section/member[@kind='instance-method']) > 0">
<xsl:text>
		</xsl:text><h2>Instance Methods</h2>
			<xsl:apply-templates select="object/sections/section/member[@kind='instance-method']" mode="details"/>
		</xsl:if>
	</xsl:template>
	
</xsl:stylesheet>