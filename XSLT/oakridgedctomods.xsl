<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" 
    xmlns:oai_dc='http://www.openarchives.org/OAI/2.0/oai_dc/' xmlns:xlink="http://www.w3.org/1999/xlink" xmlns:dc="http://purl.org/dc/elements/1.1/"
    version="2.0" xmlns="http://www.loc.gov/mods/v3">
    
    <!-- output settings -->
    <xsl:output encoding="UTF-8" method="xml" omit-xml-declaration="yes" indent="yes"/>
    <xsl:strip-space elements="*"/>
    
    <!-- identity transform -->
    <xsl:template match="@* | node()">
        <xsl:copy>
            <xsl:apply-templates select="@* | node()"/>
        </xsl:copy>
    </xsl:template>
    
    <!-- normalize all the text! -->
    <xsl:template match="text()">
        <xsl:value-of select="normalize-space(.)"/>
    </xsl:template>
    
    <!-- match metadata -->
    <xsl:template match="oai_dc:dc">
        <!-- match the document root and return a MODS record -->
        <mods xmlns="http://www.loc.gov/mods/v3" version="3.5"
            xmlns:xlink="http://www.w3.org/1999/xlink"
            xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
            xsi:schemaLocation="http://www.loc.gov/mods/v3 http://www.loc.gov/standards/mods/v3/mods-3-5.xsd">
            
            <!-- title -->
            <xsl:apply-templates select="dc:title"/>
            
            <!-- identifier -->
            <xsl:apply-templates select="dc:identifier"/>
            
            <!-- description containing abstract info -->
            <xsl:apply-templates select="dc:description[1]"/>
            
            <!-- contributor -->
            <xsl:apply-templates select="dc:contributor"/>
            
            <!-- originInfo> -->
            <xsl:apply-templates select="dc:date"/>
            
            <!-- subject(s) -->
            <xsl:apply-templates select="dc:subject"/>
            
            <!-- typeOfResource -->
            <xsl:apply-templates select="dc:type"/>
            
            <!-- publisher or recordContentSource -->
            <xsl:apply-templates select="dc:publisher"/>
            
            <!-- rights or accessCondition -->
        
        </mods>
    </xsl:template>
    
    <!-- title -->
    <xsl:template match="dc:title">
        <xsl:choose>
            <xsl:when test="contains(., 'Edward Dougherty Collection')">    
                <relatedItem type="host" displayLabel="Project">
                    <titleInfo>
                        <title><xsl:apply-templates/></title>
                    </titleInfo>
                </relatedItem>
                <accessCondition type="use and reproduction" xlink:href="http://rightsstatements.org/vocab/InC/1.0/">In Copyright</accessCondition>
            </xsl:when>
            <xsl:when test="contains(., 'Department of Energy Photograph Collection')">    
                <relatedItem type="host" displayLabel="Project">
                    <titleInfo>
                        <title><xsl:apply-templates/></title>
                    </titleInfo>
                </relatedItem>
                <accessCondition type="use and reproduction" xlink:href="http://rightsstatements.org/vocab/NoC-US/1.0/">No Copyright - United States</accessCondition>
            </xsl:when>
            <xsl:otherwise>
                <titleInfo>
                    <title><xsl:value-of select="normalize-space(.)"/></title>
                </titleInfo>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    
    <!-- identifiers -->
    <xsl:template match='dc:identifier'>
        <xsl:choose>
            <xsl:when test="starts-with(., 'http://')">
                <xsl:variable name="identifier-preview-url" select="replace(., '/cdm/ref', '/utils/getthumbnail')"/>
                <location>
                    <url usage="primary" access="object in context"><xsl:apply-templates/></url>
                    <url access="preview"><xsl:value-of select="$identifier-preview-url"/></url>
                </location>
            </xsl:when>
            <xsl:when test="matches(., '^[A-Z]{3}')">
                <identifier><xsl:apply-templates/></identifier>
            </xsl:when>
        </xsl:choose>
    </xsl:template>
            
    <!-- abstract -->
    <xsl:template match="dc:description">
        <abstract><xsl:apply-templates/></abstract>
    </xsl:template>
    
    <!-- contributor -->
    <xsl:template match="dc:contributor">
        <name>
            <namePart><xsl:apply-templates/></namePart>
            <role>
                <roleTerm authority="marcrelator" authorityURI="http://id.loc.gov/vocabulary/relators/ctb">Contributor</roleTerm>
            </role>
        </name>
    </xsl:template>
    
    <!-- originInfo -->
    <xsl:template match="dc:date">
        <xsl:choose>
            <xsl:when test="starts-with(., '19')">
                <originInfo><dateCreated><xsl:apply-templates/></dateCreated></originInfo>
            </xsl:when>
        </xsl:choose>
    </xsl:template>
    
    <!-- subject(s) -->
    <!-- for subjects, whether they contain a ';' or not -->
    <xsl:template match="dc:subject">
        <xsl:variable name="subj-tokens" select="tokenize(., '; ')"/>
        <xsl:for-each select="$subj-tokens">
            <xsl:choose>
                <xsl:when test="ends-with(., ';')">
                    <subject>
                        <topic>
                            <xsl:value-of select="substring(., 1, string-length(.) -1)"/>
                        </topic>
                    </subject>
                </xsl:when>
                <xsl:otherwise>
                    <subject>
                        <topic><xsl:value-of select="normalize-space(.)"/></topic>
                    </subject>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:for-each>
    </xsl:template>
    
    <!-- typeOfResource -->
    <xsl:template match="dc:type">
        <xsl:choose>
            <xsl:when test="contains(., 'Photograph')">  
                <typeOfResource>still image</typeOfResource>
            </xsl:when>
            <xsl:when test="contains(.,'Image')">
                <typeOfResource>still image</typeOfResource>
            </xsl:when>
        </xsl:choose>
    </xsl:template>
    
    <!-- recordContentSource -->
    <xsl:template match="dc:publisher">
        <recordInfo><recordContentSource><xsl:apply-templates/></recordContentSource></recordInfo>
    </xsl:template>
    
</xsl:stylesheet>