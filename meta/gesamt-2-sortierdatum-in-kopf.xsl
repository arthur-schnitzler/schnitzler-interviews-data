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
                <xsl:text>2022-01-01</xsl:text>
            </xsl:when>
            <xsl:when test="descendant::correspDesc/correspAction[@type='sent']/date[@n]">
                <xsl:variable name="datum" select="descendant::correspDesc/correspAction[@type='sent']/date[@n]"/>
                <xsl:choose>
                    <xsl:when test="$datum/@when">
                        <xsl:value-of select="$datum/@when"/>
                    </xsl:when>
                    <xsl:when test="$datum/@from">
                        <xsl:value-of select="$datum/@from"/>
                    </xsl:when>
                    <xsl:when test="$datum/@notBefore">
                        <xsl:value-of select="$datum/@notBefore"/>
                    </xsl:when>
                    <xsl:when test="$datum/@notAfter">
                        <xsl:value-of select="$datum/@notAfter"/>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:value-of select="$datum/@to"/>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:when>
            <xsl:when test="descendant::sourceDesc//origDate[@n]">
                <xsl:variable name="datum" select="descendant::sourceDesc//origDate[@n]"/>
                <xsl:choose>
                    <xsl:when test="$datum/@when">
                        <xsl:value-of select="$datum/@when"/>
                    </xsl:when>
                    <xsl:when test="$datum/@from">
                        <xsl:value-of select="$datum/@from"/>
                    </xsl:when>
                    <xsl:when test="$datum/@notBefore">
                        <xsl:value-of select="$datum/@notBefore"/>
                    </xsl:when>
                    <xsl:when test="$datum/@notAfter">
                        <xsl:value-of select="$datum/@notAfter"/>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:value-of select="$datum/@to"/>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:when>
            <xsl:when test="descendant::listBibl[1]/biblStruct[1]/monogr[1]/imprint[1]/date[@n][1]/@when">
                <xsl:value-of select="descendant::listBibl[1]/biblStruct[1]/monogr[1]/imprint[1]/date[@n][1]/@when"/>
            </xsl:when>
            <xsl:when test="(descendant::date[not(ancestor::kommentar) and ancestor::body and @n]/@when)[1]">
                <xsl:value-of select="(descendant::date[not(ancestor::kommentar) and ancestor::body]/@when)[1]"/>
            </xsl:when>
        </xsl:choose>
            </xsl:attribute>
            <xsl:attribute name="n">
                <xsl:choose>
                    <xsl:when test="descendant::correspDesc/correspAction[@type='sent']/date[@n]">
                        <xsl:value-of select="@n"/>
                    </xsl:when>
                    <xsl:when test="descendant::sourceDesc//origDate[@n]">
                        <xsl:value-of select="descendant::sourceDesc//origDate/@n"/>
                    </xsl:when>
                    <xsl:when test="descendant::listBibl[1]/biblStruct[1]/monogr[1]/imprint[1]/date[@n][1]/@when">
                        <xsl:value-of select="descendant::listBibl[1]/biblStruct[1]/monogr[1]/imprint[1]/date[1]/@n"/>
                    </xsl:when>
                    <xsl:when test="(descendant::date[not(ancestor::kommentar) and ancestor::body and @n]/@when)[1]">
                        <xsl:value-of select="(descendant::date[not(ancestor::kommentar) and ancestor::body and @when]/@n)[1]"/>
                    </xsl:when>
                    <xsl:when test="starts-with(@id, 'E_')">
                        <xsl:text>1</xsl:text>
                    </xsl:when>
                </xsl:choose>
            </xsl:attribute>
            <xsl:apply-templates select="@*|node()"/>
        </xsl:element>
    </xsl:template>
   
  
</xsl:stylesheet>
