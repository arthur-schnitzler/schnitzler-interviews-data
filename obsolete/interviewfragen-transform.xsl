<?xml version="1.0" encoding="utf-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
   xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:fn="http://www.w3.org/2005/xpath-functions"
   xmlns:foo="whatever" xmlns:tei="http://www.tei-c.org/ns/1.0" version="3.0">
   <xsl:output method="xml" indent="true"/>
   <xsl:strip-space elements="*"/>
     
  <xsl:template match="root">
     <xsl:element name="list">

       <xsl:apply-templates>
          <xsl:sort select="descendant::Heading2"/>
          <xsl:sort select="descendant::Frage"/>
       </xsl:apply-templates>
     </xsl:element>
  </xsl:template>
   
   <xsl:template match="row">
      
      <xsl:element name="item">
         <xsl:attribute name="n">
            <xsl:choose>
               <xsl:when test="string-length(Nummer)=1">
                  <xsl:value-of select="concat('q00',Nummer)"/>
               </xsl:when>
               <xsl:when test="string-length(Nummer)=2">
                  <xsl:value-of select="concat('q0',Nummer)"/>
               </xsl:when>
               <xsl:otherwise>
                     <xsl:value-of select="concat('q',Nummer)"/>
               </xsl:otherwise>
            </xsl:choose>
         </xsl:attribute>
         <xsl:attribute name="type">
            <xsl:value-of select="Heading2"/>
         </xsl:attribute>
         <xsl:value-of select="Frage"/>
      </xsl:element>
   </xsl:template>
   
  
  
  
</xsl:stylesheet>
