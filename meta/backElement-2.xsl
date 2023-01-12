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
    <xsl:template match="back/listPerson[not(child::*)]"/>
    <xsl:template match="back/listPlace[not(child::*)]"/>
    <xsl:template match="back/listOrg[not(child::*)]"/>
    <xsl:template match="back/listBibl[not(child::*)]"/>
    <xsl:template match="comment() | processing-instruction()" mode="copy-no-namespaces">
        <xsl:copy/>
    </xsl:template>
    <xsl:template match="back/listPerson[child::*]">
        <xsl:element name="listPerson" xmlns="">
            <xsl:for-each select="distinct-values(person/@xml:id)">
                <xsl:choose>
                    <xsl:when test=". = '2121'">
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
                        <xsl:variable name="nummer" select="substring-after(., 'pmb')"/>
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
            </xsl:for-each>
        </xsl:element>
    </xsl:template>
    <xsl:template match="back/listBibl[child::*]">
        <xsl:element name="listBibl" xmlns="">
            <xsl:for-each select="distinct-values(bibl/@xml:id)">
                <xsl:variable name="nummer" select="substring-after(., 'pmb')"/>
                <xsl:variable name="eintrag"
                    select="fn:escape-html-uri(concat('https://pmb.acdh.oeaw.ac.at/apis/entities/tei/work/', $nummer))"
                    as="xs:string"/>
                <xsl:choose>
                    <xsl:when test="doc-available($eintrag)">
                        <xsl:element name="bibl" xmlns="">
                            <xsl:attribute name="xml:id">
                                <xsl:value-of select="concat('pmb', $nummer)"/>
                            </xsl:attribute>
                            <xsl:variable name="eintrag_inhalt" select="document($eintrag)/bibl"/>
                            <xsl:copy-of
                                select="$eintrag_inhalt/title[not(@type = 'loschen')] | $eintrag_inhalt/author | $eintrag_inhalt/date | $eintrag_inhalt/note[@type] | $eintrag_inhalt/idno"
                                />
                        </xsl:element>
                        <!--<xsl:apply-templates select="document($eintrag)" mode="copy-no-namespaces"/>-->
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:element name="error">
                            <xsl:attribute name="type">
                                <xsl:text>bibl</xsl:text>
                            </xsl:attribute>
                            <xsl:value-of select="$nummer"/>
                        </xsl:element>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:for-each>
        </xsl:element>
    </xsl:template>
    <xsl:template match="back/listPlace[child::*]">
        <xsl:element name="listPlace" xmlns="">
            <xsl:for-each select="distinct-values(place/@xml:id)">
                <xsl:variable name="nummer" select="substring-after(., 'pmb')"/>
                <xsl:variable name="eintrag"
                    select="fn:escape-html-uri(concat('https://pmb.acdh.oeaw.ac.at/apis/entities/tei/place/', $nummer))"
                    as="xs:string"/>
                <xsl:choose>
                    <xsl:when test="doc-available($eintrag)">
                        <xsl:apply-templates select="document($eintrag)" mode="copy-no-namespaces"/>
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
            </xsl:for-each>
        </xsl:element>
    </xsl:template>
    <xsl:template match="back/listOrg[child::*]">
        <xsl:element name="listOrg" xmlns="">
            <xsl:for-each select="distinct-values(org/@xml:id)">
                <xsl:variable name="nummer" select="substring-after(., 'pmb')"/>
                <xsl:variable name="eintrag"
                    select="fn:escape-html-uri(concat('https://pmb.acdh.oeaw.ac.at/apis/entities/tei/org/', $nummer))"
                    as="xs:string"/>
                <xsl:choose>
                    <xsl:when test="doc-available($eintrag)">
                        <xsl:apply-templates select="document($eintrag)" mode="copy-no-namespaces"/>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:element name="error">
                            <xsl:attribute name="type">
                                <xsl:text>org</xsl:text>
                            </xsl:attribute>
                            <xsl:value-of select="$nummer"/>
                        </xsl:element>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:for-each>
        </xsl:element>
    </xsl:template>
</xsl:stylesheet>
