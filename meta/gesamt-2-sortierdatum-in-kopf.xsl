<?xml version="1.0" encoding="utf-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:xs="http://www.w3.org/2001/XMLSchema"
                exclude-result-prefixes="xs"
                version="2.0">
  
  <xsl:output method="xml" encoding="utf-8" indent="no"/>
  
  <!-- Identity template : copy all text nodes, elements and attributes -->  
  <xsl:template match="@*|node()">
      <xsl:copy>
         <xsl:apply-templates select="@*|node()"/>
      </xsl:copy>
  </xsl:template>
    
    <xsl:template match="TEI[starts-with(@id,'E_')]/@when|TEI[starts-with(@id,'E_')]/@n"/>
    
    <xsl:template match="TEI">
        <xsl:element name="TEI">
            <xsl:attribute name="when">
        <xsl:choose>
            <xsl:when test="starts-with(@id, 'E_')">
                <xsl:text>2023-01-01</xsl:text>
            </xsl:when>
            <xsl:otherwise>
                <xsl:value-of select="descendant::titleStmt/title[@type='iso-date']/@when-iso"/>
            </xsl:otherwise>
        </xsl:choose>
            </xsl:attribute>
            <xsl:attribute name="n">
                <xsl:choose>
                    <xsl:when test="descendant::correspDesc/correspAction[@type='sent']/date[@n]">
                        <xsl:value-of select="@n"/>
                    </xsl:when>
                    <xsl:when test="starts-with(@id, 'E_')">
                        <xsl:text>1</xsl:text>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:value-of select="descendant::titleStmt/title[@type='iso-date']/@n"/>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:attribute>
            <xsl:apply-templates select="@*|node()"/>
        </xsl:element>
    </xsl:template>
   
  
</xsl:stylesheet>
