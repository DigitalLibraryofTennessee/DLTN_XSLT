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
            
            <!-- geographic> -->
            <xsl:apply-templates select="dc:coverage"/>
            
            <!-- subject(s) -->
            <xsl:apply-templates select="dc:subject"/>
            
            <!-- note -->
            <xsl:apply-templates select="dc:source"/>
            
            <!-- typeOfResource -->
            <xsl:apply-templates select="dc:type"/>
            
            <!-- recordContentSource -->
            <recordInfo>
                <recordContentSource>Digital Initiatives, James E. Walker Library, Middle Tennessee State University</recordContentSource>
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
    
    <!-- creator -->
    <xsl:template match="dc:creator">
        <name>
            <namePart><xsl:apply-templates/></namePart>
            <role>
                <roleTerm authority="marcrelator" valueURI="http://id.loc.gov/vocabulary/relators/cre">Creator</roleTerm>
            </role>
        </name>
    </xsl:template>
    
    <!-- contributor -->
    <xsl:template match="dc:contributor">
        <name>
            <namePart><xsl:apply-templates/></namePart>
            <role>
                <roleTerm authority="marcrelator" valueURI="http://id.loc.gov/vocabulary/relators/ctb">Contributor</roleTerm>
            </role>
        </name>
    </xsl:template>
    
    <!-- originInfo -->
    <xsl:template match="dc:date">
        <originInfo><dateCreated><xsl:apply-templates/></dateCreated></originInfo>
    </xsl:template>
    
    <!-- geographic -->
    <xsl:template match="dc:coverage">
        <xsl:variable name="nCoverage" select="normalize-space(.)"/>
        <xsl:choose>
            <xsl:when test="matches($nCoverage, '[0-9]')"/>
            <xsl:otherwise>
                <subject><geographic><xsl:apply-templates/></geographic></subject>
            </xsl:otherwise>
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
        </xsl:choose>
    </xsl:template>
    
    <!-- accessCondition -->
    <xsl:template match='dc:rights'>
        <xsl:variable name="vRights" select="normalize-space(.)"/>
        <xsl:choose>
            <xsl:when test="contains($vRights, 'http://rightsstatements.org/vocab/CNE/1.0/') or contains(lower-case($vRights), 'copyright not evaluated')">
                <accessCondition type="use and reproduction" xlink:href="http://rightsstatements.org/vocab/CNE/1.0/">Copyright Not Evaluated</accessCondition>
            </xsl:when>
            <xsl:when test="contains($vRights, 'http://rightsstatements.org/vocab/NoC-US/1.0/') or contains(lower-case($vRights), 'no copyright')">
                <accessCondition type="use and reproduction" xlink:href="http://rightsstatements.org/vocab/NoC-US/1.0/">No Copyright - United States</accessCondition>
            </xsl:when>
            <xsl:when test="contains($vRights, 'http://rightsstatements.org/vocab/InC/1.0/') or contains(lower-case($vRights), 'non-commercial use permitted')">
                <accessCondition type="use and reproduction" xlink:href="http://rightsstatements.org/vocab/InC-NC/1.0/">In Copyright - Non-Commercial Use Permitted</accessCondition>
            </xsl:when>
            <xsl:when test="contains($vRights, 'http://rightsstatements.org/vocab/InC/1.0/') or contains(lower-case($vRights), 'educational use permitted')">
                <accessCondition type="use and reproduction" xlink:href="http://rightsstatements.org/vocab/InC-EDU/1.0/">In Copyright - Educational Use Permitted</accessCondition>
            </xsl:when>
            <xsl:when test="contains($vRights, 'Credit')">
                <note><xsl:apply-templates/></note>
                <accessCondition type="use and reproduction" xlink:href="http://rightsstatements.org/vocab/InC/1.0/">In Copyright</accessCondition>
            </xsl:when>
            <xsl:when test="contains($vRights, 'Digital microfilm purchased from National Archives.')">
                <accessCondition type="use and reproduction" xlink:href="http://rightsstatements.org/vocab/NoC-US/1.0/">No Copyright - United States</accessCondition>
                <note>Digital microfilm purchased from National Archives.</note>
            </xsl:when>
            <xsl:when test="contains($vRights, 'Copyright of the creator, used with permission')">
                <accessCondition type="use and reproduction" xlink:href="http://rightsstatements.org/vocab/InC/1.0/">In Copyright</accessCondition>
            </xsl:when>
            <xsl:when test="contains($vRights, 'Reproduction permitted for non-profit educational and research purposes only.')"/>
            <xsl:otherwise>
                <accessCondition type="use and reproduction" xlink:href="http://rightsstatements.org/vocab/CNE/1.0/">Copyright Not Evaluated</accessCondition>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    
</xsl:stylesheet>