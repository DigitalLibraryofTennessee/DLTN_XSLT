<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" 
    xmlns:oai_dc='http://www.openarchives.org/OAI/2.0/oai_dc/' xmlns:dc="http://purl.org/dc/elements/1.1/" 
    xmlns:oai="http://www.openarchives.org/OAI/2.0/"
    version="2.0" xmlns="http://www.loc.gov/mods/v3">
    <xsl:output omit-xml-declaration="yes" method="xml" encoding="UTF-8" indent="yes"/>
    
    <xsl:include href="memphisdctomods.xsl"/>
    
    <xsl:template match="text()|@*"/>    
    <xsl:template match="//oai_dc:dc">
        <mods xmlns:xlink="http://www.w3.org/1999/xlink" 
            xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" 
            xmlns="http://www.loc.gov/mods/v3" version="3.5" 
            xsi:schemaLocation="http://www.loc.gov/mods/v3 http://www.loc.gov/standards/mods/v3/mods-3-5.xsd">
            <xsl:apply-templates select="dc:title"/> <!-- titleInfo/title and part/detail|date parsed out -->
            <xsl:apply-templates select="dc:identifier"/> <!-- identifier -->
            <xsl:apply-templates select="dc:contributor" /> <!-- name/role -->
            <xsl:apply-templates select="dc:creator" /> <!-- name/role -->
            
            <xsl:if test="dc:date|dc:publisher">
                <originInfo> 
                    <xsl:apply-templates select="dc:date"/> <!-- date (text + key) -->
                    <xsl:apply-templates select="dc:contributor" mode="publisher"/> <!-- publisher parsed from contributor -->
                    <xsl:apply-templates select="dc:publisher"/> <!-- place of origin - publishers all repositories -->
                </originInfo>
            </xsl:if>
            
            <xsl:if test="dc:format">
                <physicalDescription>
                    <xsl:apply-templates select="dc:format"/> <!-- extent, internetMediaTypes -->
                </physicalDescription>
            </xsl:if>
            
            <xsl:if test="dc:identifier">
                <location>
                    <xsl:apply-templates select="dc:identifier" mode="URL"/> <!-- object in context URL -->
                    <xsl:apply-templates select="dc:identifier" mode="locationurl"/> <!-- thumbnail url -->
                    <xsl:apply-templates select="dc:source" mode="repository"/><!-- physicalLocation-->
                </location>
            </xsl:if>
            
            <xsl:apply-templates select="dc:description"/> <!-- abstract -->
            <xsl:apply-templates select="dc:relation" /> <!-- collections -->
            <xsl:apply-templates select="dc:rights"/> <!-- accessCondition -->
            <xsl:apply-templates select="dc:subject"/> <!-- subjects -->
            <xsl:apply-templates select="dc:coverage"/> <!-- geographic, temporal subject info -->
            <xsl:apply-templates select="dc:format" mode="genre"/>
            <xsl:apply-templates select="dc:type"/> <!-- item types -->
            <xsl:apply-templates select="dc:source"/> <!-- collections -->
            <relatedItem type='host' displayLabel="Project">
                <titleInfo>
                    <title>Britton Duke</title>
                </titleInfo>
                <abstract>The Britton Duke Papers are a chronicle of an early Germantown, Tennessee, family. The papers were donated to the Memphis and Shelby County Room by Louise Duke Bedford, great granddaughter of Britton Duke, and her nephew, Edward C. Duke. The collection primarily consists of correspondence and business papers which belonged to Britton Duke. Duke, a prominent cotton planter and civic leader, owned property in Shelby County which was adjacent to the Nashoba Plantation, a utopian community founded by Frances Wright. The Duke property, which ran from Massey Road in East Memphis to Poplar Estates and from U.S. Highway 72 to the Wolf River, joined Nashoba on the east. Britton Duke immigrated from Scotland Neck, North Carolina, to Shelby County in 1830. He was accompanied by his second wife, Mary Louise Duke. On their way to Pea Ridge (sometimes called Pea Mount and now a part of Germantown) the Dukes delayed their trip at LaGrange, Tennessee, where their first daughter was born. Once he arrived in Shelby County, Duke immediately established himself as a leading citizen of the area, where he often acted as an agent or witness for his less wealthy and illiterate neighbors. Britton and Mary Louise Duke had seven children. Britton was very interested in the education of his own family and served as a long-time school commissioner for the 11th district of Shelby County. The papers include correspondence relating to his role as school commissioner, school schedules and receipts for the Duke children's tuition and school supplies. The collection, which was previously called The Duke-Bedford Family Papers, serves as a valuable resource on the Nashoba Plantation and Frances Wright. The collection includes a receipt written to Duke for $20 for timber cut from Nashoba, an 1854 newspaper advertisement for Nashoba and correspondence regarding the Nashoba land. In addition to numerous receipts for farming equipment and household supplies, the collection provides important information on slavery, including bills of sale for slaves which list the slaves by name.</abstract>
                <location>
                    <url>http://cdm16108.contentdm.oclc.org/cdm/landingpage/collection/p15342coll1</url>
                </location>
            </relatedItem>
            <xsl:call-template name="recordInfo"/>
        </mods>
    </xsl:template>
    
    <xsl:template match="dc:coverage"> <!-- Subject headings/Geographic Names present, but uniquely formulated - can't currently parse -->
        <xsl:for-each select="tokenize(normalize-space(.), ';')">
            <xsl:if test="normalize-space(.)!='' and normalize-space(lower-case(.))!='n/a'">
                <xsl:choose>
                    <xsl:when test="matches(normalize-space(.), '^\d{4}s$') or matches(normalize-space(.), '^\d{4}s to \d{4}s$')">
                        <subject>
                            <temporal><xsl:value-of select="."/></temporal>
                        </subject>
                    </xsl:when>
                    <xsl:otherwise>
                        <subject>
                            <topic><xsl:value-of select="normalize-space(.)"/></topic>
                        </subject>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:if>
        </xsl:for-each>
    </xsl:template>
    
    <xsl:template match="dc:format">
        <xsl:for-each select="tokenize(normalize-space(lower-case(.)), ';')">
            <xsl:for-each select="tokenize(., ',')">
                <xsl:if test="normalize-space(.)!=''">
                    <xsl:choose>
                        <xsl:when test="contains(., 'jpeg') or contains(., 'jpg')">
                            <internetMediaType>image/jpeg</internetMediaType>
                        </xsl:when>
                        <xsl:when test="matches(., '\d+.+')">
                            <extent><xsl:value-of select="normalize-space(.)"/></extent>
                        </xsl:when>
                        <xsl:when test="contains(., 'handwritten') or contains(., 'two-sided')">
                            <note><xsl:value-of select="normalize-space(.)"/></note>
                        </xsl:when>
                        <xsl:otherwise>
                            <form><xsl:value-of select="normalize-space(.)"/></form>
                        </xsl:otherwise>
                    </xsl:choose>
                </xsl:if>
            </xsl:for-each>
        </xsl:for-each>
    </xsl:template>
    
</xsl:stylesheet>
