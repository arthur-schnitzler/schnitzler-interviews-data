<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:tei="http://www.tei-c.org/ns/1.0"
    exclude-result-prefixes="xs" version="3.0">
    <xsl:mode on-no-match="shallow-skip"/>
    <xsl:output indent="yes"/>
  
  <xsl:template match="list">
      <xsl:element name="list">
      <xsl:apply-templates select="item">
          <xsl:sort select="@ana" order="descending"/>
      </xsl:apply-templates>
      </xsl:element>
  </xsl:template>
  
  <xsl:template match="item">
      <xsl:copy-of select="."></xsl:copy-of>
  </xsl:template>
  
</xsl:stylesheet>
