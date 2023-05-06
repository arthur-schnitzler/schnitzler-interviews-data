<?xml version="1.0" encoding="utf-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
   xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:fn="http://www.w3.org/2005/xpath-functions"
   xmlns:foo="whatever" xmlns:tei="http://www.tei-c.org/ns/1.0" version="3.0">
   <xsl:output method="xml"/>
   <xsl:param name="chronologie" select="document('file:/Users/oldfiche/Documents/git/schnitzler-interviews-data/meta/chronologie-toc.xml')"/>
   <xsl:key name="nachher" use="text()" match="item"/>
   <xsl:template match="tei:TEI">
      <xsl:element name="TEI" namespace="http://www.tei-c.org/ns/1.0">
         <xsl:copy-of select="@*"/>
         <xsl:if test="key('nachher', @xml:id, $chronologie)/following-sibling::item[1]">
            <xsl:attribute name="next">
               <xsl:value-of
                  select="key('nachher', @xml:id, $chronologie)/following-sibling::item[1]"/>
            </xsl:attribute>
         </xsl:if>
         <xsl:if test="key('nachher', @xml:id, $chronologie)/preceding-sibling::item[1]">
            <xsl:attribute name="prev">
               <xsl:value-of
                  select="key('nachher', @xml:id, $chronologie)/preceding-sibling::item[1]"/>
            </xsl:attribute>
         </xsl:if>
         <xsl:text> </xsl:text>
         <xsl:copy-of select="*"/>
      </xsl:element>
   </xsl:template>
</xsl:stylesheet>
