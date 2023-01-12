<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
     xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:fn="http://www.w3.org/2005/xpath-functions" version="3.0">
    <xsl:mode on-no-match="shallow-copy"/>
    <xsl:output method="xml" indent="yes"/>
    <!-- Das hier tut nur den PMB-import etwas anpassen -->
    <xsl:template match="@when-iso">
        <xsl:attribute name="when">
            <xsl:choose>
                <xsl:when test="string-length(substring-before(., '-')) = 4">
                    <xsl:value-of select="."/>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:choose>
                        <xsl:when test="string-length(substring-before(., '-')) = 3">
                            <xsl:value-of select="concat('0', .)"/>
                        </xsl:when>
                        <xsl:when test="string-length(substring-before(., '-')) = 2">
                            <xsl:value-of select="concat('00', .)"/>
                        </xsl:when>
                        <xsl:when test="string-length(substring-before(., '-')) = 1">
                            <xsl:value-of select="concat('000', .)"/>
                        </xsl:when>
                    </xsl:choose>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:attribute>
    </xsl:template>
    <xsl:template match="@notAfter-iso">
        <xsl:attribute name="notAfter">
            <xsl:choose>
                <xsl:when test="string-length(substring-before(., '-')) = 4">
                    <xsl:value-of select="."/>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:choose>
                        <xsl:when test="string-length(substring-before(., '-')) = 3">
                            <xsl:value-of select="concat('0', .)"/>
                        </xsl:when>
                        <xsl:when test="string-length(substring-before(., '-')) = 2">
                            <xsl:value-of select="concat('00', .)"/>
                        </xsl:when>
                        <xsl:when test="string-length(substring-before(., '-')) = 1">
                            <xsl:value-of select="concat('000', .)"/>
                        </xsl:when>
                    </xsl:choose>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:attribute>
    </xsl:template>
    <xsl:template match="@to-iso">
        <xsl:attribute name="to-iso">
            <xsl:choose>
                <xsl:when test="string-length(substring-before(., '-')) = 4">
                    <xsl:value-of select="."/>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:choose>
                        <xsl:when test="string-length(substring-before(., '-')) = 3">
                            <xsl:value-of select="concat('0', .)"/>
                        </xsl:when>
                        <xsl:when test="string-length(substring-before(., '-')) = 2">
                            <xsl:value-of select="concat('00', .)"/>
                        </xsl:when>
                        <xsl:when test="string-length(substring-before(., '-')) = 1">
                            <xsl:value-of select="concat('000', .)"/>
                        </xsl:when>
                    </xsl:choose>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:attribute>
    </xsl:template>
    <xsl:template match="@from-iso">
        <xsl:attribute name="from-iso">
            <xsl:choose>
                <xsl:when test="string-length(substring-before(., '-')) = 4">
                    <xsl:value-of select="."/>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:choose>
                        <xsl:when test="string-length(substring-before(., '-')) = 3">
                            <xsl:value-of select="concat('0', .)"/>
                        </xsl:when>
                        <xsl:when test="string-length(substring-before(., '-')) = 2">
                            <xsl:value-of select="concat('00', .)"/>
                        </xsl:when>
                        <xsl:when test="string-length(substring-before(., '-')) = 1">
                            <xsl:value-of select="concat('000', .)"/>
                        </xsl:when>
                    </xsl:choose>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:attribute>
    </xsl:template>
    
    <xsl:template match="date">
        <xsl:element name="date" xmlns="">
            <xsl:apply-templates select="@when-iso|@notBefore-iso|@notAfter-iso|@from-iso|@to-iso"/>
        <xsl:choose>
            <xsl:when test=".='0363-06-26'">
                <xsl:text>26.{\,}6.{\,}363</xsl:text>
            </xsl:when>
            <xsl:when test="contains(.,'um') or contains(.,'zwischen')">
                <xsl:value-of select="normalize-space(.)"/>
            </xsl:when>
            <xsl:when test="contains(.,'&lt;')">
                <xsl:value-of select="substring-before(.,'&lt;')"/>
            </xsl:when>
            <xsl:when test="contains(.,'?')">
                <xsl:value-of select="replace(., '. ', '.{\,}')"/>
            </xsl:when>
            <xsl:when test="contains(.,'Z.')">
                <xsl:value-of select="replace(., 'v. u. Z.', 'v.{\,}u.{\,}Z.')"/>
            </xsl:when>
            <xsl:when test="@notBefore-iso and @when-iso">
                <xsl:value-of select="."/>
            </xsl:when>
            <xsl:when test="matches(.,'^[12][0-9]{3}$')">
            <xsl:value-of select="."/>    
            </xsl:when>
            <xsl:when test="@when-iso = .">
                <xsl:value-of select="fn:day-from-date(@when-iso)"/><xsl:text>.{\,}</xsl:text>
                <xsl:value-of select="fn:month-from-date(@when-iso)"/><xsl:text>.{\,}</xsl:text>
                <xsl:value-of select="fn:year-from-date(@when-iso)"/>
            </xsl:when>
            <xsl:when test="matches(.,'^(?:(?:31(/|-|\.)(?:0?[13578]|1[02]))\1|(?:(?:29|30)(/|-|\.)(?:0?[13-9]|1[0-2])\2))(?:(?:1[1-9]|[2-9]\d)?\d{2})$|^(?:29(/|-|\.)0?2\3(?:(?:(?:1[1-9]|[2-9]\d)?(?:0[48]|[2468][048]|[13579][26])|(?:(?:16|[2468][048]|[3579][26])00))))$|^(?:0?[1-9]|1\d|2[0-8])(/|-|\.)(?:(?:0?[1-9])|(?:1[0-2]))\4(?:(?:1[1-9]|[2-9]\d)?\d{2})$') and @when-iso">
                <xsl:value-of select="fn:day-from-date(@when-iso)"/><xsl:text>.{\,}</xsl:text>
                <xsl:value-of select="fn:month-from-date(@when-iso)"/><xsl:text>.{\,}</xsl:text>
                <xsl:value-of select="fn:year-from-date(@when-iso)"/>
            </xsl:when>
            <xsl:when test="@when-iso='1048-05-24'">
                <xsl:text>24.{\,}5.{\,}1048</xsl:text>
            </xsl:when>
            
            <xsl:when test=".='Juli 1931'">
                <xsl:text>Juli 1931</xsl:text>
            </xsl:when>
            <xsl:otherwise>
                <xsl:value-of select="."/><xsl:text>XXXX SOX</xsl:text>
            </xsl:otherwise>
        </xsl:choose>
        
        
        </xsl:element>
            
    </xsl:template>
    
    
    <xsl:template match="@notBefore-iso">
        <xsl:attribute name="notBefore">
            <xsl:choose>
                <xsl:when test="string-length(substring-before(., '-')) = 4">
                    <xsl:value-of select="."/>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:choose>
                        <xsl:when test="string-length(substring-before(., '-')) = 3">
                            <xsl:value-of select="concat('0', .)"/>
                        </xsl:when>
                        <xsl:when test="string-length(substring-before(., '-')) = 2">
                            <xsl:value-of select="concat('00', .)"/>
                        </xsl:when>
                        <xsl:when test="string-length(substring-before(., '-')) = 1">
                            <xsl:value-of select="concat('000', .)"/>
                        </xsl:when>
                    </xsl:choose>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:attribute>
    </xsl:template>
    <xsl:template match="@key">
        <xsl:attribute name="ref">
            <xsl:value-of select="concat('pmb', .)"/>
        </xsl:attribute>
    </xsl:template>
    <xsl:template match="placeName/@ref[contains(.,'place__')]|placeName/@key[contains(.,'place__')]">
        <xsl:attribute name="ref">
            <xsl:value-of select="concat('pmb', replace(.,'place__',''))"/>
        </xsl:attribute>
    </xsl:template>
    <xsl:template match="back//title/@type[. = 'main']"/>
    <xsl:template match="back//bibl/author/@ref|back//bibl/author/@key">
        <xsl:attribute name="ref">
            <xsl:choose>
                <xsl:when test="contains(., 'person__')">
                    <xsl:value-of select="concat('pmb', substring-after(., 'person__'))"/>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:value-of select="."/>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:attribute>
    </xsl:template>
    <xsl:template match="back//idno[@type = 'URL']">
        <xsl:element name="idno" xmlns="">
            <xsl:attribute name="type">
                <xsl:text>URL</xsl:text>
            </xsl:attribute>
            <xsl:attribute name="subtype">
                <xsl:choose>
                    <xsl:when test="contains(., 'wikipedia')">
                        <xsl:text>wikipedia</xsl:text>
                    </xsl:when>
                    <xsl:when test="contains(., 'geonames')">
                        <xsl:text>geonames</xsl:text>
                    </xsl:when>
                    <xsl:when test="contains(., 'gnd')">
                        <xsl:text>gnd</xsl:text>
                    </xsl:when>
                    <xsl:when test="contains(., 'anno.')">
                        <xsl:text>anno</xsl:text>
                    </xsl:when>
                    <xsl:when test="starts-with(., 'https://pmb.acdh.')">
                        <xsl:text>pmb</xsl:text>
                    </xsl:when>
                    <xsl:when test="starts-with(., 'https://www.')">
                        <xsl:value-of
                            select="substring-before(substring-after(., 'https://www.'), '.')"/>
                    </xsl:when>
                    <xsl:when test="starts-with(., 'http://www.')">
                        <xsl:value-of
                            select="substring-before(substring-after(., 'http://www.'), '.')"/>
                    </xsl:when>
                    <xsl:when test="starts-with(., 'https://')">
                        <xsl:value-of select="substring-before(substring-after(., 'https://'), '.')"
                        />
                    </xsl:when>
                    <xsl:when test="starts-with(., 'http://')">
                        <xsl:value-of select="substring-before(substring-after(., 'https://'), '.')"
                        />
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:value-of select="substring-before(., '.')"/>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:attribute>
            <xsl:value-of select="."/>
        </xsl:element>
    </xsl:template>
    <xsl:template match="back//listBibl[bibl/@type = 'collections']"/>
    <xsl:template match="back//bibl/note[@type = 'collections']"/>
    <xsl:template match="back//listBibl/bibl/@xml:id">
        <xsl:attribute name="xml:id">
            <xsl:choose>
                <xsl:when test="contains(., 'work__')">
                    <xsl:value-of select="concat('pmb', substring-after(., 'work__'))"/>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:value-of select="."/>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:attribute>
    </xsl:template>
    <xsl:template match="back//listPerson/person/@xml:id">
        <xsl:attribute name="xml:id">
            <xsl:choose>
                <xsl:when test="contains(., 'person__')">
                    <xsl:value-of select="concat('pmb', substring-after(., 'person__'))"/>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:value-of select="."/>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:attribute>
    </xsl:template>
    <xsl:template match="back//listPlace/place/@xml:id">
        <xsl:attribute name="xml:id">
            <xsl:choose>
                <xsl:when test="contains(., 'place__')">
                    <xsl:value-of select="concat('pmb', substring-after(., 'place__'))"/>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:value-of select="."/>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:attribute>
    </xsl:template>
    <xsl:template match="back//listOrg/org/@xml:id">
        <xsl:attribute name="xml:id">
            <xsl:choose>
                <xsl:when test="contains(., 'org__')">
                    <xsl:value-of select="concat('pmb', substring-after(., 'org__'))"/>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:value-of select="."/>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:attribute>
    </xsl:template>
    <xsl:template match="back//note[@type = 'IDNO']">
        <xsl:element name="idno" xmlns="">
            <xsl:attribute name="type">
                <xsl:text>URL</xsl:text>
            </xsl:attribute>
            <xsl:attribute name="subtype">
                <xsl:choose>
                    <xsl:when test="contains(., 'wikipedia')">
                        <xsl:text>wikipedia</xsl:text>
                    </xsl:when>
                    <xsl:when test="contains(., 'wikidata')">
                        <xsl:text>wikidata</xsl:text>
                    </xsl:when>
                    <xsl:when test="contains(., 'geonames')">
                        <xsl:text>geonames</xsl:text>
                    </xsl:when>
                    <xsl:when test="starts-with(., 'https://')">
                        <xsl:value-of select="substring-before(substring-after(., 'https://'), '.')"
                        />
                    </xsl:when>
                    <xsl:when test="starts-with(., 'http://')">
                        <xsl:value-of select="substring-before(substring-after(., 'https://'), '.')"
                        />
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:value-of select="substring-before(., '.')"/>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:attribute>
            <xsl:value-of select="."/>
        </xsl:element>
    </xsl:template>
    <xsl:template match="back//orgName[contains(@type, 'uri')]">
        <xsl:element name="idno" xmlns="">
            <xsl:attribute name="type">
                <xsl:text>URL</xsl:text>
            </xsl:attribute>
            <xsl:attribute name="subtype">
                <xsl:choose>
                    <xsl:when test="contains(., 'wikipedia')">
                        <xsl:text>wikipedia</xsl:text>
                    </xsl:when>
                    <xsl:when test="contains(., 'wikidata')">
                        <xsl:text>wikidata</xsl:text>
                    </xsl:when>
                    <xsl:when test="contains(., 'geonames')">
                        <xsl:text>geonames</xsl:text>
                    </xsl:when>
                    <xsl:when test="starts-with(., 'https://')">
                        <xsl:value-of select="substring-before(substring-after(., 'https://'), '.')"
                        />
                    </xsl:when>
                    <xsl:when test="starts-with(., 'http://')">
                        <xsl:value-of select="substring-before(substring-after(., 'https://'), '.')"
                        />
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:value-of select="substring-before(., '.')"/>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:attribute>
            <xsl:value-of select="."/>
        </xsl:element>
    </xsl:template>
    <xsl:template match="title[@type = 'bibliografische_angabe']">
        <xsl:element name="note" xmlns="">
            <xsl:attribute name="type">
                <xsl:text>bibliografische_angabe</xsl:text>
            </xsl:attribute>
            <xsl:value-of select="."/>
        </xsl:element>
    </xsl:template>
    <xsl:template match="title[@type = 'uri_worklink']">
        <xsl:element name="note" xmlns="">
            <xsl:attribute name="type">
                <xsl:text>uri_worklink</xsl:text>
            </xsl:attribute>
            <xsl:value-of select="."/>
        </xsl:element>
    </xsl:template>
    <xsl:template match="title[contains(@type, 'wikipedia')]">
        <xsl:element name="idno" xmlns="">
            <xsl:attribute name="type">
                <xsl:text>URL</xsl:text>
            </xsl:attribute>
            <xsl:attribute name="subtype">
                <xsl:choose>
                    <xsl:when test="contains(., 'wikipedia')">
                        <xsl:text>wikipedia</xsl:text>
                    </xsl:when>
                    <xsl:when test="contains(., 'wikidata')">
                        <xsl:text>wikidata</xsl:text>
                    </xsl:when>
                    <xsl:when test="contains(., 'geonames')">
                        <xsl:text>geonames</xsl:text>
                    </xsl:when>
                    <xsl:when test="starts-with(., 'https://')">
                        <xsl:value-of select="substring-before(substring-after(., 'https://'), '.')"
                        />
                    </xsl:when>
                    <xsl:when test="starts-with(., 'http://')">
                        <xsl:value-of select="substring-before(substring-after(., 'https://'), '.')"
                        />
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:value-of select="substring-before(., '.')"/>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:attribute>
            <xsl:value-of select="."/>
        </xsl:element>
    </xsl:template>
    <xsl:template match="back//placeName[. = preceding-sibling::placeName/.]"/>
    <xsl:template match="back//listEvent"/>
    <xsl:template
        match="listOrg[not(child::*)] | listBibl[not(child::*)] | listPerson[not(child::*)] | listPlace[not(child::*)]"
    />
    
    <xsl:template match="back//occupation">
        <xsl:element name="occupation" xmlns="">
            <xsl:copy select="@*"/>
            <xsl:variable name="beruf">
            <xsl:choose>
                <xsl:when test="contains(.,'&gt;&gt;')">
                    <xsl:value-of select="normalize-space(tokenize(.,'&gt;&gt;')[last()])"/>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:value-of select="."/>
                </xsl:otherwise>
            </xsl:choose>          
            </xsl:variable>
                <xsl:choose>
                <xsl:when test="parent::person/sex/@value='male' and contains($beruf, '/')">
                    <xsl:value-of select="fn:substring-before($beruf,'/')"/>
                </xsl:when>
                    <xsl:when test="parent::person/sex/@value='female'  and contains($beruf, '/')">
                    <xsl:value-of select="fn:substring-after($beruf,'/')"/>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:value-of select="$beruf"/>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:element>
    </xsl:template>
    
    <xsl:template match="desc[@type='entity_type']">
        <xsl:element name="desc" xmlns="">
            <xsl:attribute name="type">
                <xsl:text>entity_type</xsl:text>
            </xsl:attribute>
            <xsl:choose>
                <xsl:when test="contains(., ' (')">
                    <xsl:value-of select="normalize-space(substring-before(., ' ('))"/>
                </xsl:when>
                <xsl:when test="contains(., 'geonames.org/ontology')">
                    <xsl:choose>
                        <xsl:when test="ends-with(., '#P.PPLC')">
                            <xsl:text>Hauptstadt</xsl:text>
                        </xsl:when>
                        <xsl:when test="ends-with(., '#A.ADM4')">
                            <xsl:text>Gemeinde</xsl:text>
                        </xsl:when>
                        <xsl:when test="ends-with(., '#A.PCLI')">
                            <xsl:text>Land</xsl:text>
                        </xsl:when>
                        <xsl:when test="ends-with(., '#P.PPLA')">
                            <xsl:text>Besiedelter Ort</xsl:text>
                        </xsl:when>
                        <xsl:when test="ends-with(., '#P.PPL')">
                            <xsl:text>Besiedelter Ort</xsl:text>
                        </xsl:when>
                        <xsl:when test="ends-with(., '#A.ADM3')">
                            <xsl:text>Ort</xsl:text>
                        </xsl:when>
                        <xsl:when test="ends-with(., '#P.PPLA3')">
                            <xsl:text>Besiedelter Ort</xsl:text>
                        </xsl:when>
                        <xsl:when test="ends-with(., '#P.PPLA2')">
                            <xsl:text>Besiedelter Ort</xsl:text>
                        </xsl:when>
                        <xsl:when test="ends-with(., '#A.ADM2')">
                            <xsl:text>Region</xsl:text>
                        </xsl:when>
                        <xsl:when test="ends-with(., '#A.ADM1')">
                            <xsl:text>Region</xsl:text>
                        </xsl:when>
                        <xsl:when test="ends-with(., '#T.VAL')">
                            <xsl:text>Tal</xsl:text>
                        </xsl:when>
                        <xsl:when test="ends-with(., '#P.PPLA4')">
                            <xsl:text>Besiedelter Ort</xsl:text>
                        </xsl:when>
                        <xsl:when test="ends-with(., '#P.PPLX')">
                            <xsl:text>Ortsteil</xsl:text>
                        </xsl:when>
                        <xsl:when test="ends-with(., '#S.UNIV')">
                            <xsl:text>Hochschule</xsl:text>
                        </xsl:when>
                        <xsl:when test="ends-with(., '#L.RGNE')">
                            <xsl:text>Region</xsl:text>
                        </xsl:when>
                        <xsl:when test="ends-with(., '#A.PCLD')">
                            <xsl:text>Gegend</xsl:text>
                        </xsl:when>
                        <xsl:when test="ends-with(., '#L.RGN')">
                            <xsl:text>Region</xsl:text>
                        </xsl:when>
                        <xsl:when test="ends-with(., '#A.ADM3H')">
                            <xsl:text>Ehemaliger Ort</xsl:text>
                        </xsl:when>
                        <xsl:when test="ends-with(., '#A.PCLH')">
                            <xsl:text>Ehemaliges Land</xsl:text>
                        </xsl:when>
                        <xsl:when test="ends-with(., '#A.ADMD')">
                            <xsl:text>Gegend</xsl:text>
                        </xsl:when>
                        <xsl:when test="ends-with(., '#P.PPLA3')">
                            <xsl:text>Besiedelter Ort</xsl:text>
                        </xsl:when>
                        
                        <xsl:when test="ends-with(., '#A.ADM3')">
                            <xsl:text>A.ADM3</xsl:text>
                        </xsl:when>
                        <xsl:when test="ends-with(., '#A.ADM2')">
                            <xsl:text>A.ADM2</xsl:text>
                        </xsl:when>
                        <xsl:when test="ends-with(., '#A.PCLS')">
                            <xsl:text>Ort</xsl:text>
                        </xsl:when>
                        <xsl:when test="ends-with(., '#P.PPLA4')">
                            <xsl:text>P.PPLA4</xsl:text>
                        </xsl:when>
                        <xsl:when test="ends-with(., '#A.ADM1')">
                            <xsl:text>A.ADM1</xsl:text>
                        </xsl:when>
                        <xsl:when test="ends-with(., '#A.ADMD')">
                            <xsl:text>A.ADMD</xsl:text>
                        </xsl:when>
                        <xsl:when test="ends-with(., '#P.PPLX')">
                            <xsl:text>P.PPLX</xsl:text>
                        </xsl:when>
                        <xsl:when test="ends-with(., '#T.VAL')">
                            <xsl:text>T.VAL</xsl:text>
                        </xsl:when>
                        <xsl:when test="ends-with(., '#A.PCLD')">
                            <xsl:text>A.PCLD</xsl:text>
                        </xsl:when>
                        <xsl:when test="ends-with(., '#L.RGN')">
                            <xsl:text>L.RGN</xsl:text>
                        </xsl:when>
                        <xsl:when test="ends-with(., '#S.ANS')">
                            <xsl:text>Archäologische Ausgrabungsstätte</xsl:text>
                        </xsl:when>
                        <xsl:when test="ends-with(., '#L.CONT')">
                            <xsl:text>Kontinent</xsl:text>
                        </xsl:when>
                        <xsl:when test="ends-with(., '#A.ADM4H')">
                            <xsl:text>Ehemaliger Ort</xsl:text>
                        </xsl:when>
                        <xsl:when test="ends-with(., '#S.MSTY')">
                            <xsl:text>Kloster</xsl:text>
                        </xsl:when>
                        <xsl:when test="ends-with(., '#T.ISL')">
                            <xsl:text>Insel</xsl:text>
                        </xsl:when>
                        <xsl:when test="ends-with(., '#H.STM')">
                            <xsl:text>Fluss</xsl:text>
                        </xsl:when>
                        <xsl:when test="ends-with(., '#S.HSE')">
                            <xsl:text>Gebäude</xsl:text>
                        </xsl:when>
                        <xsl:when test="ends-with(., '#A.ADM4')">
                            <xsl:text>A.ADM4</xsl:text>
                        </xsl:when>
                        <xsl:when test="ends-with(., '#S.CSTL')">
                            <xsl:text>Schloss</xsl:text>
                        </xsl:when>
                        <xsl:when test="ends-with(., '#A.PCL')">
                            <xsl:text>Ort</xsl:text>
                        </xsl:when>
                        <xsl:when test="ends-with(., '#S.FRM')">
                            <xsl:text>Bauernhof</xsl:text>
                        </xsl:when>
                        <xsl:when test="ends-with(., '#T.ISLS')">
                            <xsl:text>Inseln</xsl:text>
                        </xsl:when>
                        <xsl:when test="ends-with(., '#T.VLC')">
                            <xsl:text>Vulkan</xsl:text>
                        </xsl:when>
                        <xsl:when test="ends-with(., '#A.PCLIX')">
                            <xsl:text>Ortsteil</xsl:text>
                        </xsl:when>
                        <xsl:when test="ends-with(., '#T.CAPE')">
                            <xsl:text>Kapp</xsl:text>
                        </xsl:when>
                        <xsl:when test="ends-with(., '#H.LK')">
                            <xsl:text>See</xsl:text>
                        </xsl:when>
                        <xsl:when test="ends-with(., '#T.MTS')">
                            <xsl:text>Berge</xsl:text>
                        </xsl:when>
                        <xsl:when test="ends-with(., '#T.PK')">
                            <xsl:text>Berggipfel</xsl:text>
                        </xsl:when>
                        <xsl:when test="ends-with(., '#T.MT')">
                            <xsl:text>Berg</xsl:text>
                        </xsl:when>
                        <xsl:when test="ends-with(., '#H.OCN')">
                            <xsl:text>Ozean</xsl:text>
                        </xsl:when>
                        <xsl:when test="ends-with(., '#A.TERR')">
                            <xsl:text>Territorium</xsl:text>
                        </xsl:when>
                        <xsl:when test="ends-with(., '#L.RGNH')">
                            <xsl:text>Ehemalige Region</xsl:text>
                        </xsl:when>
                        <xsl:when test="ends-with(., '#S.RUIN')">
                            <xsl:text>Ruine</xsl:text>
                        </xsl:when>
                        
                        <xsl:otherwise>
                            <xsl:value-of select="substring-after(., 'geonames.org/ontology')"/>
                        </xsl:otherwise>
                    </xsl:choose>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:value-of select="."/>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:element>
    </xsl:template>
    
</xsl:stylesheet>
