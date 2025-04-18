<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns="http://www.tei-c.org/ns/1.0"
    xmlns:tei="http://www.tei-c.org/ns/1.0" xmlns:xs="http://www.w3.org/2001/XMLSchema"
    version="3.0">
    <xsl:mode on-no-match="shallow-copy"/>
    <xsl:output method="xml" indent="yes"/>
    <!-- adds a title-element with iso-date, e.g.
    <title type="iso-date" when="1914-08-23">23. 8. 1914</title>
       
       Die Werte werden aus der correspAction[@type='sent'] bezogen, @from, @notBefore werden zu @when
    -->
    <xsl:template match="tei:titleStmt/tei:title[@type = 'iso-date']"/>
    <xsl:template match="tei:titleStmt/tei:title[@level = 'a']">
        <xsl:variable name="datum" as="xs:string">
            <xsl:choose>
                <xsl:when test="ancestor::tei:TEI/descendant::tei:sourceDesc/tei:origDate[@when]">
                    <xsl:value-of
                        select="ancestor::tei:TEI/descendant::tei:sourceDesc/tei:origDate[@when]"/>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:value-of select="ancestor::tei:TEI/descendant::tei:date[@when][1]"/>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:variable>
        <xsl:variable name="when" as="xs:date">
            <xsl:choose>
                <xsl:when test="ancestor::tei:TEI/descendant::tei:sourceDesc/tei:origDate/@when">
                    <xsl:value-of
                        select="ancestor::tei:TEI/descendant::tei:sourceDesc/tei:origDate/@when"/>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:value-of select="ancestor::tei:TEI/descendant::tei:date[@when][1]/@when"/>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:variable>
        <xsl:copy-of select="."/>
        <xsl:element name="title" namespace="http://www.tei-c.org/ns/1.0">
            <xsl:attribute name="type">
                <xsl:text>iso-date</xsl:text>
            </xsl:attribute>
            <xsl:attribute name="when-iso">
                <xsl:value-of select="$when"/>
            </xsl:attribute>
            <xsl:value-of select="$datum"/>
        </xsl:element>
    </xsl:template>
</xsl:stylesheet>
