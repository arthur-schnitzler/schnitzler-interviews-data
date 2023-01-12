<?xml version="1.0" encoding="utf-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:xs="http://www.w3.org/2001/XMLSchema"
                xmlns:tei="http://www.tei-c.org/ns/1.0"
                xmlns:foo="whatever"
                xmlns:fn="http://www.w3.org/2005/xpath-functions"
                exclude-result-prefixes="xs"
                version="3.0">
    <xsl:output indent="yes"/>
    <xsl:mode on-no-match="shallow-copy"/>
    
   <xsl:template match="tei:rs[not(child::*)]">
       <xsl:element name="rs" namespace="http://www.tei-c.org/ns/1.0">
           <xsl:attribute name="type">
               <xsl:value-of select="@type"/>
           </xsl:attribute>
           <xsl:attribute name="ref">
               <xsl:value-of select="@ref"/>
           </xsl:attribute>
           <xsl:if test="@subtype">
               <xsl:attribute name="subtype">
               <xsl:value-of select="@subtype"/>
               </xsl:attribute>
           </xsl:if>
           <xsl:value-of select="fn:normalize-space(.)"/>
       </xsl:element>
   </xsl:template>
</xsl:stylesheet>
