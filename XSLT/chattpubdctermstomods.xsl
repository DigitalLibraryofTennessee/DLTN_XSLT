<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
    xmlns:xlink="http://www.w3.org/1999/xlink"
    xmlns:dcterms="http://purl.org/dc/terms/"
    xmlns:oai="http://www.openarchives.org/OAI/2.0/"
    xmlns:oai_dcterms='http://www.openarchives.org/OAI/2.0/oai_dcterms/'
    xmlns:oai_dc='http://www.openarchives.org/OAI/2.0/oai_dc/'
    xmlns="http://www.loc.gov/mods/v3"
    xpath-default-namespace="http://worldcat.org/xmlschema/qdc-1.0/"
    exclude-result-prefixes="xs xsi oai dcterms oai_dcterms oai_dc"
    version="2.0">
    
    <!-- output settings -->
    <xsl:output encoding="UTF-8" method="xml" omit-xml-declaration="yes" indent="yes"/>
    <xsl:strip-space elements="*"/>
    
    <!-- identity transform -->
    <xsl:template match="@* | node()">
        <xsl:copy>
            <xsl:apply-templates select="@* | node()"/>
        </xsl:copy>
    </xsl:template>

    <!-- match oai_dcterms:dcterms -->
    <xsl:template match="oai_dcterms:dcterms">
            
            <!-- match the document root and return a MODS record -->
            <mods xmlns="http://www.loc.gov/mods/v3" version="3.5"
                xmlns:xlink="http://www.w3.org/1999/xlink"
                xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
                xsi:schemaLocation="http://www.loc.gov/mods/v3 http://www.loc.gov/standards/mods/v3/mods-3-5.xsd">
                
                <!-- title -->
                <xsl:apply-templates select="dcterms:title"/>
                
                <!-- identifier -->
                <location><xsl:apply-templates select="dcterms:identifier"/></location>
                
                <!-- description -->
                <xsl:apply-templates select="dcterms:description"/>
                
                <!-- dateCreated -->
                <xsl:apply-templates select="dcterms:created"/>
                
                <!-- subject -->
                <subject><xsl:apply-templates select="dcterms:subject"/></subject>
                
                <!-- recordContentSource -->
                <recordInfo>
                    <recordContentSource>Chattanooga Public Library</recordContentSource>
                </recordInfo>
                
                <!-- rights -->
                <xsl:apply-templates select="dcterms:rights"/>
                
            </mods>
        
    </xsl:template>
    
    
    <!-- title -->
    <xsl:template match="dcterms:title">
        <titleInfo><title><xsl:apply-templates/></title></titleInfo>
    </xsl:template>
      
    <!-- identifiers -->
    <xsl:template match='dcterms:identifier'>
        <xsl:choose>
            <xsl:when test="contains(., 'localhistory')">
                <url usage="primary" access="object in context"><xsl:apply-templates/></url>
            </xsl:when>
        </xsl:choose>
        <xsl:choose>
            <xsl:when test="ends-with(., '.pdf')">
                <url access="preview">https://upload.wikimedia.org/wikipedia/commons/thumb/6/6c/PDF_icon.svg/1024px-PDF_icon.svg.png</url>
            </xsl:when>
            <xsl:when test="ends-with(., '.jpg')">
                <xsl:variable name="preview-url" select="replace(., 'original', 'medium')"/>
                <url access="preview"><xsl:value-of select="$preview-url"/></url>
            </xsl:when>
        </xsl:choose>
    </xsl:template>
    
    <!-- description -->
    <xsl:template match="dcterms:description">
        <abstract><xsl:apply-templates/></abstract>
    </xsl:template>
    
    <!-- dateCreated -->
    <xsl:template match="dcterms:created">
        <xsl:choose>
            <xsl:when test="contains(., 'circa')"/>
            <xsl:otherwise>   
                <originInfo><dateCreated><xsl:apply-templates/></dateCreated></originInfo>
            </xsl:otherwise> 
        </xsl:choose>
    </xsl:template>
    
    <!-- subject -->
    <xsl:template match="dcterms:subject">
        <xsl:choose>
            <xsl:when test="ends-with(., '.')">
                <topic>
                    <xsl:value-of select="substring(., 1, string-length(.) -1)"/>
                </topic>
            </xsl:when>
            <xsl:otherwise>
                <topic>
                    <xsl:apply-templates/>
                </topic>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    
    <!-- accessCondition -->
    <xsl:template match='dcterms:rights'>
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