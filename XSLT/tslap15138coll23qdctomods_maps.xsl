<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:xlink="http://www.w3.org/1999/xlink"
    xmlns:oai_qdc="http://worldcat.org/xmlschemas/qdc-1.0/"
    xmlns:dcterms="http://purl.org/dc/terms/" xmlns:dc="http://purl.org/dc/elements/1.1/"
    xmlns:oai="http://www.openarchives.org/OAI/2.0/" xmlns="http://www.loc.gov/mods/v3"
    xmlns:dltn="https://github.com/digitallibraryoftennessee"
    xpath-default-namespace="http://worldcat.org/xmlschema/qdc-1.0/"
    exclude-result-prefixes="xs xsi oai oai_qdc dcterms dc" version="2.0">

    <!-- output settings -->
    <xsl:output encoding="UTF-8" method="xml" omit-xml-declaration="yes" indent="yes"/>
    <xsl:strip-space elements="*"/>
    
    <xsl:variable name="catalog" select="document('catalogs/tsla_catalog.xml')"/>

    <!-- includes and imports -->

    <!--
    Collection/Set = TSLA sets as Qualified Dublin Core => MODS
  -->

    <!-- variables and parameters -->
    <!--
    dc:language processing parameter: there are multiple language values in the
    QDC.
  -->

    <xsl:param name="pLang">
        <dltn:l string="eng">english</dltn:l>
        <dltn:l string="eng">en</dltn:l>
        <dltn:l string="eng">eng</dltn:l>
        <dltn:l string="deu">german</dltn:l>
        <dltn:l string="spa">spanish</dltn:l>
        <dltn:l string="zxx">zxx</dltn:l>
        <dltn:l string="zxx">no linguistic content.</dltn:l>
    </xsl:param>
    
    <xsl:param name="pType">
        <dltn:type string="still image">Still Image</dltn:type>
        <dltn:type string="text">Text</dltn:type>
        <dltn:type string="sound recording">Sound</dltn:type>
        <dltn:type string="text">Document</dltn:type>
        <dltn:type string="three dimensional object">Object</dltn:type>
        <dltn:type string="still image">Still image</dltn:type>
        <dltn:type string="still image">Image/jp2</dltn:type>
        <dltn:type string="still image">IMAGE</dltn:type>
    </xsl:param>

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

    <!-- match oai_qdc:qualifieddc -->
    <xsl:template match="oai_qdc:qualifieddc">
        <!-- match the document root and return a MODS record -->
        <xsl:if test="dc:type[contains(lower-case(normalize-space(.)), 'still image')]">
            <mods xmlns="http://www.loc.gov/mods/v3" version="3.5"
            xmlns:xlink="http://www.w3.org/1999/xlink"
            xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
            xsi:schemaLocation="http://www.loc.gov/mods/v3 http://www.loc.gov/standards/mods/v3/mods-3-5.xsd">
            <titleInfo>
                <title>
                    <xsl:apply-templates select="dc:title/text()"/>
                </title>
            </titleInfo>
          <!-- rights -->
          <xsl:apply-templates select="dc:rights"/>
          <location>
            <xsl:apply-templates select="dc:identifier[starts-with(normalize-space(.), 'http://')]"/>
          </location>
          <!-- creator(s) -->
          <xsl:apply-templates select="dc:creator"/>
          <!-- description -->
          <xsl:apply-templates select="dc:description"/>
          <!-- date -->
          <xsl:apply-templates select="dc:date"/>
          <!-- spatial -->
          <xsl:apply-templates select="dcterms:spatial"/>
          <recordInfo>
              <recordContentSource>Tennessee State Library and Archives</recordContentSource>
              <languageOfCataloging>
                  <languageTerm type="code" authority="iso639-2b">eng</languageTerm>
              </languageOfCataloging>
          </recordInfo>
          <xsl:apply-templates select="dc:subject"/>
          <xsl:apply-templates select="dc:coverage[not(starts-with(., 'Tape'))]"/>
            <xsl:apply-templates select="dc:source[not(contains(., 'Box') or contains(., 'Folder') or contains(., 'Drawer') or starts-with(., 'THS I') or starts-with(., 'XL') or starts-with(., 'VI') or starts-with(., 'RG') or starts-with(., 'IX-A'))]"/>
          <xsl:apply-templates select="dcterms:medium"/>
          <xsl:apply-templates select="dc:type"/>
          <xsl:apply-templates select="dc:language[1]"/>
        </mods>
        </xsl:if>
    </xsl:template>
    
    <!--rights-->
    <xsl:template match="dc:rights">
      <xsl:variable name="vRights" select="normalize-space(.)"/>
        <xsl:choose>
            <xsl:when test="contains($vRights, 'Copyright not evaluated: http://rightsstatements.org/vocab/CNE/1.0/')">
                <accessCondition type="use and reproduction" xlink:href="http://rightsstatements.org/vocab/CNE/1.0/">Copyright Not Evaluated</accessCondition>
            </xsl:when>
            <xsl:when test="contains($vRights, 'No copyright - United States: http://rightsstatements.org/vocab/NoC-US/1.0/')">
                <accessCondition type="use and reproduction" xlink:href="http://rightsstatements.org/vocab/NoC-US/1.0/">No Copyright - United States</accessCondition>
            </xsl:when>
            <xsl:otherwise>
                <accessCondition type="local rights statement">
                    <xsl:apply-templates/>
                </accessCondition>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
  
    <!--identifier-->
    <xsl:template match="dc:identifier[starts-with(normalize-space(.), 'http://')]">
      <xsl:variable name="identifier-preview-url" select="replace(., '/cdm/ref', '/utils/getthumbnail')"/>
      <xsl:variable name="iiif-manifest" select="concat(replace(replace(., 'cdm/ref/collection', 'digital/iiif'), '/id', ''), '/info.json')"/>
      <url usage="primary" access="object in context"><xsl:apply-templates/></url>
      <url access="preview"><xsl:value-of select="$identifier-preview-url"/></url>
      <xsl:if test="normalize-space(.) = $catalog//@id">
          <url note="iiif-manifest"><xsl:value-of select="$iiif-manifest"/></url>
      </xsl:if>
    </xsl:template>
    
    <!-- creator(s) -->
    <xsl:template match="dc:creator">
        <xsl:variable name="creator-tokens" select="tokenize(., ';')"/>
        <xsl:for-each select="$creator-tokens">
            <name>
                <namePart><xsl:value-of select="normalize-space(.)"/></namePart>
                <role>
                    <roleTerm authority="marcrelator" authorityURI="http://id.loc.gov/vocabulary/relators/cre">Creator</roleTerm>
                </role>
            </name>
        </xsl:for-each>
    </xsl:template>
    
    <!-- description -->
    <xsl:template match="dc:description">
        <abstract><xsl:apply-templates/></abstract>
    </xsl:template>
    
    <!-- date -->
    <xsl:template match="dc:date">
        <originInfo><dateCreated><xsl:apply-templates/></dateCreated></originInfo>
    </xsl:template>
    
    <!-- spatial -->
    <xsl:template match="dcterms:spatial">
        <xsl:variable name="testing" select="."/>
        <xsl:choose>
            <xsl:when test="matches(normalize-space($testing), '^[0-9]')"/>
            <xsl:when test="matches(normalize-space($testing), '^-')"/>
            <xsl:when test="matches(normalize-space($testing), 'Unknown')"/>
            <xsl:when test="matches(normalize-space($testing), 'Other')"/>
            <xsl:otherwise><subject><geographic><xsl:apply-templates/></geographic></subject></xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    
    <!-- subjects -->
    <xsl:template match="dc:subject">
        <xsl:for-each select="tokenize(normalize-space(.), ';')">
            <xsl:if test="normalize-space(.)!='' or normalize-space(.)!='unknown'">
                <subject>
                    <topic><xsl:value-of select="normalize-space(.)"/></topic>
                </subject>
            </xsl:if>
        </xsl:for-each>  
    </xsl:template>
    
    <!-- coverage -->
    <xsl:template match="dc:coverage[not(starts-with(., 'Tape'))]">
        <subject>
            <geographic>
                <xsl:apply-templates/>
            </geographic>
        </subject>
    </xsl:template>
    
    <!-- source -->
    <xsl:template match="dc:source[not(contains(., 'Box') or contains(., 'Folder') or contains(., 'Drawer') or starts-with(., 'THS I') or starts-with(., 'XL') or starts-with(., 'VI') or starts-with(., 'RG') or starts-with(., 'IX-A'))]">
        <relatedItem type="host">
            <titleInfo>
                <title>
                    <xsl:apply-templates/>
                </title>
            </titleInfo>
        </relatedItem>
    </xsl:template>
    
    <!-- medium -->
    <xsl:template match="dcterms:medium">
        <physicalDescription>
        <xsl:for-each select="tokenize(normalize-space(.), ';')">
            <form><xsl:value-of select="normalize-space(.)"/></form>
        </xsl:for-each>
        </physicalDescription>
    </xsl:template>
    
    <!-- type -->
    <xsl:template match="dc:type">
        <xsl:for-each select="tokenize(normalize-space(.), ';')">
            <xsl:variable name="current-type" select="normalize-space(.)"/>
            <xsl:if test=".='Still Image' or 'Text'">
                <xsl:choose>
                    <xsl:when test="$current-type = $pType/dltn:type">
                        <typeOfResource><xsl:value-of select="$pType/dltn:type[. = $current-type]/@string"/></typeOfResource>
                    </xsl:when>
                </xsl:choose>
            </xsl:if>
        </xsl:for-each>
    </xsl:template>
    
    <!-- language -->
    <xsl:template match="dc:language[1]">
        <xsl:variable name="lang-tokens" select="tokenize(., ';')"/>
        <xsl:for-each select="$lang-tokens">
            <xsl:variable name="ltln" select="lower-case(normalize-space(.))"/>
            <xsl:choose>
                <xsl:when test="$ltln = $pLang/dltn:l">
                    <language>
                    <languageTerm type="code" authority="iso639-2b">
                        <xsl:value-of select="$pLang/dltn:l[. = $ltln]/@string"/>
                    </languageTerm>
                    </language>
                </xsl:when>
            </xsl:choose>
        </xsl:for-each>
    </xsl:template>
</xsl:stylesheet>
