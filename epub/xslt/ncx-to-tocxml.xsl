<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns="http://www.tei-c.org/ns/1.0"
    xmlns:tei="http://www.tei-c.org/ns/1.0" xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:fn="http://www.w3.org/2005/xpath-functions" version="3.0">
    <xsl:mode on-no-match="shallow-skip"/>
    <xsl:output method="xml" indent="yes" omit-xml-declaration="true"/>
    
    <xsl:template match="*:navMap">
        <xsl:element name="ol">
            <xsl:attribute name="class">
                <xsl:text>toc-list</xsl:text>
            </xsl:attribute>
            <xsl:apply-templates/>
        </xsl:element>
    </xsl:template>
    
    <xsl:template match="*:navPoint">
        <xsl:element name="li">
            <xsl:element name="a">
                <xsl:element name="span">
                    <xsl:attribute name="class">
                        <xsl:text>title</xsl:text>
                    </xsl:attribute>
                    <xsl:value-of select="normalize-space(descendant::*:text[1])"/>
                </xsl:element>
            </xsl:element>
        </xsl:element>
        <xsl:apply-templates/>
    </xsl:template>
</xsl:stylesheet>
    