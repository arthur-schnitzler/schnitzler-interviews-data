<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns="http://www.tei-c.org/ns/1.0"
    xmlns:tei="http://www.tei-c.org/ns/1.0" xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:fn="http://www.w3.org/2005/xpath-functions" version="3.0">
    <xsl:mode on-no-match="shallow-copy"/>
    <xsl:output method="xml" indent="yes"/>
    <xsl:template match="*" mode="copy-no-namespaces">
        <xsl:element name="{local-name()}">
            <xsl:copy-of select="@*"/>
            <xsl:apply-templates select="node()" mode="copy-no-namespaces"/>
        </xsl:element>
    </xsl:template>
    <xsl:template match="comment() | processing-instruction()" mode="copy-no-namespaces">
        <xsl:copy/>
    </xsl:template>
    <xsl:template match="author">
        <xsl:element name="author" xmlns="">
            <xsl:copy-of select="@role"/>
            <xsl:variable name="reffi">
                <xsl:choose>
                    <xsl:when test="contains(@key,'person__')">
                        <xsl:value-of select="concat('pmb', fn:substring-after(@key,'person__'))"/>
                    </xsl:when>
                    <xsl:when test="not(contains(@key,'pmb'))">
                        <xsl:value-of select="concat('pmb', @key)"/>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:value-of select="@key"/>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:variable>
            <xsl:attribute name="ref">
                <xsl:value-of select="$reffi"/>
            </xsl:attribute>
            <xsl:choose>
                <xsl:when test="ancestor::back/listPerson/person[@xml:id = $reffi]">
                    <xsl:value-of select="."/>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:choose>
                        <xsl:when test="$reffi = 'pmb2121'">
                            <person xml:id="pmb2121">
                                <!-- Sonderregel für Schnitzler -->
                                <persName>
                                    <surname>Schnitzler</surname>
                                    <forename>Arthur</forename>
                                </persName>
                                <birth>
                                    <date when="1862-05-15">15. 5. 1862</date>
                                    <placeName ref="#pmb50">Wien</placeName>
                                </birth>
                                <death>
                                    <date when="1931-10-21">21. 10. 1931</date>
                                    <placeName ref="#pmb50">Wien</placeName>
                                </death>
                                <occupation code="90">Schriftsteller*in</occupation>
                                <occupation code="97">Mediziner*in</occupation>
                                <idno type="gnd">https://d-nb.info/gnd/118609807/</idno>
                            </person>
                        </xsl:when>
                        <xsl:otherwise>
                            <xsl:variable name="nummer" select="substring-after($reffi, 'pmb')"/>
                            <xsl:variable name="eintrag"
                                select="fn:escape-html-uri(concat('https://pmb.acdh.oeaw.ac.at/apis/entities/tei/person/', $nummer))"
                                as="xs:string"/>
                            <xsl:choose>
                                <xsl:when test="doc-available($eintrag)">
                                    <xsl:element name="person" xmlns="">
                                        <xsl:attribute name="xml:id">
                                            <xsl:value-of select="concat('pmb', $nummer)"/>
                                        </xsl:attribute>
                                        <xsl:variable name="eintrag_inhalt"
                                            select="document($eintrag)/person"/>
                                        <xsl:apply-templates
                                            select="$eintrag_inhalt/persName[not(@type = 'loschen')] | $eintrag_inhalt/birth | $eintrag_inhalt/death | $eintrag_inhalt/sex | $eintrag_inhalt/occupation | $eintrag_inhalt/idno"
                                            mode="copy-no-namespaces"/>
                                    </xsl:element>
                                    <!--<xsl:apply-templates select="document($eintrag)" mode="copy-no-namespaces"/>-->
                                </xsl:when>
                                <xsl:otherwise>
                                    <xsl:element name="error">
                                        <xsl:attribute name="type">
                                            <xsl:text>person</xsl:text>
                                        </xsl:attribute>
                                        <xsl:value-of select="$nummer"/>
                                    </xsl:element>
                                </xsl:otherwise>
                            </xsl:choose>
                        </xsl:otherwise>
                    </xsl:choose>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:element>
    </xsl:template>
    
    <xsl:template match="location[@type='located_in_place']">
        <xsl:element name="location">
            <xsl:copy-of select="@*|*"/>
            <xsl:variable name="nummer">
                <xsl:choose>
                    <xsl:when test="contains(placeName/@key, 'place__')">
                        <xsl:value-of select="substring-after(placeName/@key, 'place__')"/>
                    </xsl:when>
                    <xsl:when test="contains(placeName/@key, 'pmb')">
                        <xsl:value-of select="substring-after(placeName/@key, 'pmb')"/>
                    </xsl:when>
                    <xsl:when test="contains(placeName/@ref, 'place__')">
                        <xsl:value-of select="substring-after(placeName/@ref, 'place__')"/>
                    </xsl:when>
                    <xsl:when test="contains(placeName/@ref, 'pmb')">
                        <xsl:value-of select="substring-after(placeName/@ref, 'pmb')"/>
                    </xsl:when>
                    <xsl:when test="placeName/@ref">
                        <xsl:value-of select="placeName/@ref"/>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:value-of select="placeName/@key"/>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:variable>
            <xsl:variable name="eintrag"
                select="fn:escape-html-uri(concat('https://pmb.acdh.oeaw.ac.at/apis/entities/tei/place/', $nummer))"
                as="xs:string"/>
            <xsl:choose>
                <xsl:when test="doc-available($eintrag)">
                        <xsl:variable name="eintrag_inhalt"
                            select="document($eintrag)/place"/>
                        <xsl:apply-templates
                            select="$eintrag_inhalt/desc[contains(@type,'entity_type')]"
                            mode="copy-no-namespaces"/>
                    
                </xsl:when>
                <xsl:otherwise>
                    <xsl:element name="error">
                        <xsl:attribute name="type">
                            <xsl:text>place</xsl:text>
                        </xsl:attribute>
                        <xsl:value-of select="$nummer"/>
                    </xsl:element>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:element>
        
    </xsl:template>
 
</xsl:stylesheet>
