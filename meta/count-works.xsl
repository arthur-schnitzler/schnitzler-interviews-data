<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:tei="http://www.tei-c.org/ns/1.0"
    exclude-result-prefixes="xs" version="3.0">
    <xsl:mode on-no-match="shallow-skip"/>
    <xsl:output indent="yes"/>
    <xsl:param name="workname-refs" select="document('../../../../../Documents/schnitzler-git/PMB-csv_to_TEI-list/werke/listwork-pmb.xml')"/>
    <xsl:key name="werktyp" match="tei:bibl" use="@xml:id"/>
  
  <xsl:template match="tei:list">
      <xsl:element name="list" namespace="http://www.tei-c.org/ns/1.0">
          <xsl:apply-templates select="tei:item[not(@n =preceding-sibling::tei:item/@n)]">
          </xsl:apply-templates>
      </xsl:element>
  </xsl:template>
  <xsl:template match="tei:item[@n =following-sibling::tei:item/@n]">
      <xsl:variable name="current" select="@n"/>
      <xsl:if test="key('werktyp', concat('pmb', $current), $workname-refs)/tei:author/tei:idno[@type='pmb'] = 'pmb2121'">
      <xsl:element name="item" namespace="http://www.tei-c.org/ns/1.0">
          <xsl:value-of select="."/>
          <xsl:attribute name="ana">
              <xsl:variable name="conte" select="count(following-sibling::tei:item[@n=$current])"/>
              <xsl:choose>
                  <xsl:when test="$conte &lt; 10">
                      <xsl:value-of select="concat('00', $conte)"/>
                  </xsl:when>
                  <xsl:when test="$conte &lt; 100">
                      <xsl:value-of select="concat('0', $conte)"/>
                  </xsl:when>
                  <xsl:otherwise>
                      <xsl:value-of select="$conte"/>
                  </xsl:otherwise>
              </xsl:choose>
          </xsl:attribute>
          <xsl:value-of select="key('werktyp', concat('pmb', $current), $workname-refs)/tei:title"/>
      </xsl:element>
      </xsl:if>
  </xsl:template>
  
</xsl:stylesheet>
