<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
     xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:fn="http://www.w3.org/2005/xpath-functions" version="3.0">
    <xsl:mode on-no-match="shallow-copy"/>
    <xsl:output method="xml" indent="yes"/>
   
   <xsl:template match="listPerson">
       <xsl:element name="listPerson" xmlns="">
           <xsl:copy-of select="person"/>
           <xsl:copy-of select="following-sibling::listBibl/bibl/author/person"/>
       </xsl:element>
   </xsl:template>
    
   <xsl:template match="author[person]">
       <xsl:element name="author" xmlns="">
           <xsl:copy-of select="@*"/>
           <xsl:value-of select="descendant::persName[1]/surname[1]"/><xsl:text>, </xsl:text><xsl:value-of select="descendant::persName[1]/forename[1]"/>
       </xsl:element>
   </xsl:template>
   
</xsl:stylesheet>


