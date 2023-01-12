<?xml version="1.0" encoding="utf-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:fn="http://www.w3.org/2005/xpath-functions"
    xmlns:foo="whatever" xmlns:tei="http://www.tei-c.org/ns/1.0" version="3.0"
    >
    <xsl:output method="html" indent="no" encoding="UTF-8"/>
    <xsl:strip-space elements="*"/>
  
<xsl:template match="tei:teiHeader"/>
    

   

<xsl:template match="tei:body">
    <xsl:text disable-output-escaping='yes'>&lt;!DOCTYPE html&gt;</xsl:text>
    <xsl:element name="HTML">
        <xsl:element name="header">
            <xsl:element name="meta">
                <xsl:attribute name="charset">
                    <xsl:text>utf-8</xsl:text>
                </xsl:attribute>
            </xsl:element>
            <xsl:element name="title">
                <xsl:value-of select="fn:document-uri()"/>
            </xsl:element>
        </xsl:element>
        <xsl:apply-templates select="tei:div[@type='original']"/>
    </xsl:element>
</xsl:template>

<xsl:template match="tei:div[@type='original']">
    <xsl:element name="table">
        <xsl:apply-templates/>
    </xsl:element>
</xsl:template>  

    <xsl:template match="tei:p[ancestor::tei:div[@type='original']]|tei:head[ancestor::tei:div[@type='original']]">
    <xsl:variable name="posit" select="position()"/>
   <xsl:element name="tr"> 
   <xsl:element name="td">
       <xsl:attribute name="lang">
           <xsl:text>sv-SE</xsl:text>
       </xsl:attribute>
       <xsl:attribute name="xml:lang">
           <xsl:text>sv-SE</xsl:text>
       </xsl:attribute>
       <xsl:element name="p">
        <xsl:apply-templates/>
       </xsl:element>
    </xsl:element>
    <xsl:element name="td">
        <xsl:attribute name="lang">
            <xsl:text>de-DE</xsl:text>
        </xsl:attribute>
        <xsl:attribute name="xml:lang">
            <xsl:text>de-DE</xsl:text>
        </xsl:attribute>
        <xsl:element name="p">
        <xsl:apply-templates select="ancestor::tei:body/tei:div[@type='translation']/*[$posit]"/>
        </xsl:element>
    </xsl:element></xsl:element>
</xsl:template>
    
<xsl:template match="tei:hi[@rend='italics']">
    <xsl:element name="i"><xsl:apply-templates/></xsl:element>
</xsl:template>
    

<xsl:template match="tei:note"/>
    <xsl:template match="tei:div[@type='translation']"/>
</xsl:stylesheet>
