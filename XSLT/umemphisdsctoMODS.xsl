<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" 
    xmlns:oai_dc='http://www.openarchives.org/OAI/2.0/oai_dc/' xmlns:xlink="http://www.w3.org/1999/xlink" xmlns:dc="http://purl.org/dc/elements/1.1/"
    version="2.0" xmlns="http://www.loc.gov/mods/v3"
    exclude-result-prefixes="dc oai_dc">
    
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
            
            <xsl:apply-templates select="dc:description[1]"/>
            
            <xsl:if test="dc:identifier|dc:description">
                <location>
                    <xsl:for-each select="dc:identifier[starts-with(., 'https:')]">
                        <url usage="primary" access="object in context"><xsl:value-of select="normalize-space(.)"/></url>
                    </xsl:for-each>
                    <xsl:for-each select="dc:description[starts-with(., 'https:')]">
                        <url access="preview"><xsl:value-of select="normalize-space(.)"/></url>
                    </xsl:for-each>
                </location>
            </xsl:if>
            
            <!-- typeOfResource -->
            <xsl:apply-templates select="dc:type"/>
            
            <!-- recordContentSource -->
            <recordInfo>
                <recordContentSource>University of Memphis. Special Collections</recordContentSource>
            </recordInfo>
            
            <!-- accessCondition -->
            <xsl:apply-templates select="dc:rights"/>
            
        </mods>
    </xsl:template>
    
    <!-- title -->
    <xsl:template match="dc:title">
        <titleInfo>
            <title><xsl:value-of select="normalize-space(.)"/></title>
        </titleInfo>
    </xsl:template>
    
    <!-- abstract -->
    <xsl:template match="dc:description[1]">
        <abstract><xsl:value-of select="substring(., 1, string-length(.))"/></abstract>
    </xsl:template>
    
    <!-- typeOfResource -->
    <xsl:template match="dc:type">
        <xsl:choose>
            <xsl:when test="contains(., 'Image')">
                <typeOfResource>still image</typeOfResource>
            </xsl:when>
            <xsl:when test="contains(.,'Audio')">
                <typeOfResource>sound recording-nonmusical</typeOfResource>
            </xsl:when>
            <xsl:when test="contains(.,'Text')">
                <typeOfResource>text</typeOfResource>
            </xsl:when>
            <xsl:when test="contains(.,'Book')">
                <typeOfResource>text</typeOfResource>
            </xsl:when>
        </xsl:choose>
    </xsl:template>
    
    <!-- accessCondition -->
    <xsl:template match='dc:rights'>
        <xsl:variable name="vRights" select="normalize-space(.)"/>
        <xsl:choose>
            <xsl:when test="contains($vRights, 'http://rightsstatements.org/vocab/CNE/1.0/')">
                <accessCondition type="use and reproduction" xlink:href="http://rightsstatements.org/vocab/CNE/1.0/">Copyright Not Evaluated</accessCondition>
            </xsl:when>
            <xsl:when test="contains($vRights, 'http://rightsstatements.org/vocab/NoC-US/1.0/')">
                <accessCondition type="use and reproduction" xlink:href="http://rightsstatements.org/vocab/NoC-US/1.0/">No Copyright - United States</accessCondition>
            </xsl:when>
            <xsl:when test="contains($vRights, 'http://rightsstatements.org/vocab/InC/1.0/')">
                <accessCondition type="use and reproduction" xlink:href="http://rightsstatements.org/vocab/InC/1.0/">In Copyright</accessCondition>
            </xsl:when>
            <xsl:when test="contains($vRights, 'http://rightsstatements.org/vocab/UND/1.0/')">
                <accessCondition type="use and reproduction" xlink:href="http://rightsstatements.org/vocab/UND/1.0/">Copyright Undetermined</accessCondition>
            </xsl:when>
            <xsl:when test="contains($vRights, 'http://rightsstatements.org/vocab/NKC/1.0/')">
                <accessCondition type="use and reproduction" xlink:href="http://rightsstatements.org/vocab/NKC/1.0/">No Known Copyright</accessCondition>
            </xsl:when>
            <xsl:when test="contains($vRights, 'http://rightsstatements.org/vocab/InC-EDU/1.0/')">
                <accessCondition type="use and reproduction" xlink:href="http://rightsstatements.org/vocab/InC-EDU/1.0/">In Copyright - Educational Use Permitted</accessCondition>
            </xsl:when>
            <xsl:when test="contains($vRights, 'http://rightsstatements.org/vocab/InC-NC/1.0/')">
                <accessCondition type="use and reproduction" xlink:href="http://rightsstatements.org/vocab/InC-NC/1.0/">In Copyright - Non-Commercial Use Permitted</accessCondition>
            </xsl:when>
            <xsl:otherwise>
                <accessCondition type="use and reproduction" xlink:href="http://rightsstatements.org/vocab/CNE/1.0/">Copyright Not Evaluated</accessCondition>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
</xsl:stylesheet>