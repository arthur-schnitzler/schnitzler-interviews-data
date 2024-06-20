<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:fn="http://www.w3.org/2005/xpath-functions"
    xmlns:foo="whatever" xmlns:tei="http://www.tei-c.org/ns/1.0" version="3.0">
    <xsl:output method="xml" indent="true"/>
    <xsl:strip-space elements="*"/>
    <xsl:mode on-no-match="shallow-skip"/>
    
    <xsl:template match="root">
        <list>
            <xsl:apply-templates select="*:TEI"/>
        </list>
    </xsl:template>
    
    <xsl:template match="*:TEI[descendant::div/@type='original' and descendant::div/@type='translation']">
        <item><xsl:attribute name="id"><xsl:value-of select="@xml:id"/></xsl:attribute>
        <xsl:variable name="translationdots" as="node()">
            <list>
                <xsl:for-each select="descendant::div[@type='translation']//c[@rendition='#dots' and not(ancestor::note)]">
                    <n><xsl:attribute name="p" select="ancestor::p/count(preceding-sibling::p)"></xsl:attribute>
                        <xsl:value-of select="@n"/></n>
                </xsl:for-each>
            </list>
        </xsl:variable>
            <xsl:variable name="originaldots" as="node()">
                <list>
                    <xsl:for-each select="descendant::div[@type='original']//c[@rendition='#dots' and not(ancestor::note)]">
                        <n><xsl:attribute name="p" select="ancestor::p/count(preceding-sibling::p)"></xsl:attribute><xsl:value-of select="@n"/></n>
                    </xsl:for-each>
                </list>
            </xsl:variable> 
            <xsl:if test="$originaldots != $translationdots">
                <t><xsl:copy-of select="$translationdots"/></t>
                <o><xsl:copy-of select="$originaldots"/></o>
            </xsl:if>
            


        </item>
    </xsl:template>
    
    
</xsl:stylesheet>