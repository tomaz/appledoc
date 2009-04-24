<?xml version="1.0" encoding="utf-8"?>
<xsl:stylesheet xmlns:xhtml="http://www.w3.org/1999/xhtml" xmlns="http://www.w3.org/1999/xhtml" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0" exclude-result-prefixes="xhtml">
	<xsl:output method="xml" doctype-system="http://www.w3.org/TR/xhtml1/DTD/xhtml1-strict.dtd" doctype-public="-//W3C//DTD XHTML 1.0 STRICT//EN" indent="yes" />
	
	<xsl:template match="/">
		<html xmlns="http://www.w3.org/1999/xhtml" xml:lang="en" lang="en">
		<head>
			<title><xsl:apply-templates select="project" mode="title"/></title>
			<meta http-equiv="Content-Type" content="application/xhtml+xml;charset=utf-8" />
			<link rel="stylesheet" type="text/css" href="css/screen.css" />
			<meta name="generator" content="DoxyClean" />
		</head>
		<body>
			<div id="mainContainer">
				<h1><a name="title" /><xsl:apply-templates select="project" mode="title"/></h1>
				
				<xsl:if test="count(project/object[@kind='class']) > 0">
					<div class="column">
						<h5>Class References</h5>
						<ul>
							<xsl:apply-templates select="project/object[@kind='class']"/>
						</ul>
					</div>
				</xsl:if>
				
				<div class="column">
					<xsl:if test="count(project/object[@kind='protocol']) > 0">
						<h5>Protocol References</h5>
						<ul>
							<xsl:apply-templates select="project/object[@kind='protocol']"/>
						</ul>
					</xsl:if>
						
					<xsl:if test="count(project/object[@kind='category']) > 0">
						<h5>Category References</h5>
						<ul>
							<xsl:apply-templates select="project/object[@kind='category']"/>
						</ul>
					</xsl:if>
				</div>
				
				<div class="clear"></div>
				
			</div>
		</body>
		</html>
	</xsl:template>
	
	<xsl:template match="project" mode="title">
		Project Reference
	</xsl:template>
	
	<xsl:template match="object">
		<li>
			<a>
				<xsl:attribute name="href">
					<xsl:choose>
						<xsl:when test="@kind='class'">
							Classes/
						</xsl:when>
						<xsl:when test="@kind='category'">
							Categories/
						</xsl:when>
						<xsl:when test="@kind='protocol'">
							Protocols/
						</xsl:when>
					</xsl:choose>
					<xsl:value-of select="name"/>
					.html
				</xsl:attribute>
				<xsl:value-of select="name"/>
			</a>
		</li>
	</xsl:template>
	
</xsl:stylesheet>