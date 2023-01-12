<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:fn="http://www.w3.org/2005/xpath-functions"
    xmlns:foo="whatever" xmlns:tei="http://www.tei-c.org/ns/1.0" version="3.0">
    <xsl:output method="xml" indent="true"/>
    <xsl:strip-space elements="*"/>
    <xsl:mode on-no-match="shallow-copy"/>
    
    <xsl:template match="tei:ref[@type='question']">
        <xsl:element name="ref" namespace="http://www.tei-c.org/ns/1.0">
            <xsl:copy select="@type"/>
            <xsl:attribute name="target">
                <xsl:choose>
                    <xsl:when test="string-length(@target)=1">
                        <xsl:value-of select="concat('#q00',@target)"/>
                    </xsl:when>
                    <xsl:when test="string-length(@target)=2">
                        <xsl:value-of select="concat('#q0',@target)"/>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:value-of select="concat('#q',@target)"/>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:attribute>
        </xsl:element>
        
        
        
    </xsl:template>
    
    
    
</xsl:stylesheet>