<?xml version="1.0" encoding="utf-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
   xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:fn="http://www.w3.org/2005/xpath-functions"
    version="3.0">
   <xsl:output method="text"/>
   <xsl:strip-space elements="*"/>
   <xsl:mode on-no-match="shallow-skip"/>
     
     
  <xsl:template match="root">
     <xsl:text>DEUTSCH
     </xsl:text>
     <xsl:for-each select="*[@language='de']">
        <xsl:text> </xsl:text>
        <xsl:value-of select="normalize-space(.)"/>
        <xsl:text>&#8233;
        </xsl:text>
        
     </xsl:for-each>
  </xsl:template>
 
  
  
</xsl:stylesheet>
