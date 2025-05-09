<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" 
    xmlns:oai_dc='http://www.openarchives.org/OAI/2.0/oai_dc/' xmlns:dc="http://purl.org/dc/elements/1.1/" 
    xsi:schemaLocation="http://www.openarchives.org/OAI/2.0/"
    version="2.0" xmlns="http://www.loc.gov/mods/v3" xmlns:xlink="http://www.w3.org/1999/xlink" exclude-result-prefixes="dc oai_dc">
    <xsl:output omit-xml-declaration="yes" method="xml" encoding="UTF-8" indent="yes"/>
    
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
            
            <!-- abstract -->
            <xsl:apply-templates select="dc:description"/>
            
            <!-- creator -->
            <xsl:apply-templates select="dc:creator"/>
            
            <!-- contributor -->
            <xsl:apply-templates select="dc:contributor"/>
            
            <!-- date -->
            <xsl:apply-templates select="dc:date"/>
            
            <!-- subject(s) -->
            <xsl:apply-templates select="dc:subject"/>
            
            <!-- note -->
            <xsl:apply-templates select="dc:source"/>
            
            <!-- typeOfResource -->
            <xsl:apply-templates select="dc:type"/>
            
            <!-- recordContentSource -->
            <recordInfo>
                <recordContentSource>Nashville Public Library</recordContentSource>
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
            <xsl:otherwise>
                <identifier><xsl:value-of select="normalize-space(.)"/></identifier>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    
    <!-- abstract -->
    <xsl:template match="dc:description">
        <abstract><xsl:value-of select="normalize-space(.)"/></abstract>
    </xsl:template>
    
    <xsl:template match='dc:creator'>
        <xsl:for-each select="tokenize(normalize-space(.), ';')">
        <xsl:variable name="vCreator" select="normalize-space(.)"/>
                <xsl:choose>
                    <xsl:when test="contains($vCreator, '(Interviewee)')">
                        <name>
                            <namePart><xsl:value-of select="substring(., 1, string-length(.) -14)"/></namePart>
                            <role>
                                <roleTerm type="text" valueURI="http://id.loc.gov/vocabulary/relators/ive">Interviewee</roleTerm>
                            </role> 
                        </name> 
                    </xsl:when>
                    <xsl:when test="contains($vCreator, '(Interviewer)')">
                        <name>
                            <namePart><xsl:value-of select="substring(., 1, string-length(.) -14)"/></namePart>
                            <role>
                                <roleTerm type="text" valueURI="http://id.loc.gov/vocabulary/relators/ivr">Interviewer</roleTerm>
                            </role> 
                        </name> 
                    </xsl:when>
                    <xsl:otherwise>
                        <name>
                            <namePart><xsl:value-of select="normalize-space(.)"/></namePart>
                            <role>
                                <roleTerm type="text" valueURI="http://id.loc.gov/vocabulary/relators/cre">Creator</roleTerm>
                            </role>
                        </name>
                    </xsl:otherwise>
                </xsl:choose>
        </xsl:for-each>
    </xsl:template>
    
    <xsl:template match='dc:contributor'>
        <xsl:for-each select="tokenize(normalize-space(.), ';')">
                    <name>
                        <namePart><xsl:value-of select="normalize-space(.)"/></namePart>
                        <role>
                            <roleTerm type="text" valueURI="http://id.loc.gov/vocabulary/relators/ctb">Contributor</roleTerm>
                        </role>
                    </name>
        </xsl:for-each>
    </xsl:template>
    
    <!-- originInfo -->
    <xsl:template match="dc:date">
        <originInfo><dateCreated><xsl:apply-templates/></dateCreated></originInfo>
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
    
    <!-- note -->
    <xsl:template match="dc:source">
        <note><xsl:apply-templates/></note>
    </xsl:template>
    
    <!-- typeOfResource -->
    <xsl:template match="dc:type">
        <xsl:choose>
            <xsl:when test="contains(., 'Image')">
                <typeOfResource>still image</typeOfResource>
            </xsl:when>
            <xsl:when test="contains(.,'Text')">
                <typeOfResource>text</typeOfResource>
            </xsl:when>
            <xsl:when test="contains(.,'Sound')">
                <typeOfResource>sound recording-nonmusical</typeOfResource>
            </xsl:when>
        </xsl:choose>
    </xsl:template>
    
    <!-- accessCondition -->
    <xsl:template match='dc:rights'>
        <xsl:variable name="vRights" select="normalize-space(.)"/>
        <xsl:choose>
            <xsl:when test="contains($vRights, 'U.S. and international copyright laws protect this digital content')">
                <accessCondition type="local rights statement"><xsl:apply-templates/></accessCondition>
            </xsl:when>
            <xsl:otherwise>
                <accessCondition type="use and reproduction" xlink:href="http://rightsstatements.org/vocab/CNE/1.0/">Copyright Not Evaluated</accessCondition>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
        
</xsl:stylesheet>