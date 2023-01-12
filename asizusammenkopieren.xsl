<?xml version="1.0" encoding="utf-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:xs="http://www.w3.org/2001/XMLSchema"
                xmlns:fn="http://www.w3.org/2005/xpath-functions"
                xmlns:tei="http://www.w3.org/2001/XMLSchema"
                version="2.0"
                exclude-result-prefixes="tei">
    <xsl:output method="xml" omit-xml-declaration="yes"/>
    
    <xsl:template match="/">
        <xsl:copy>
                <xsl:apply-templates mode="rootcopy"/>
        </xsl:copy>
    </xsl:template>
    
    <xsl:template match="node()" mode="rootcopy">
        <xsl:copy>
            <xsl:variable name="folderURI" select="resolve-uri('.',base-uri())"/>
           <xsl:for-each select="collection(concat($folderURI, '?select=I*.xml;recurse=yes'))/node()">
                <xsl:apply-templates mode="copy" select="."/>
            </xsl:for-each>
            <xsl:for-each select="collection(concat($folderURI, '?select=P*.xml;recurse=yes'))/node()">
                <xsl:apply-templates mode="copy" select="."/>
            </xsl:for-each>
            <xsl:for-each select="collection(concat($folderURI, '?select=M*.xml;recurse=yes'))/node()">
                <xsl:apply-templates mode="copy" select="."/>
            </xsl:for-each>
            <xsl:for-each select="collection(concat($folderURI, '?select=E_*.xml;recurse=yes'))/node()">
                <xsl:apply-templates mode="copy" select="."/>
            </xsl:for-each>
            
        </xsl:copy>    
    </xsl:template>
    
    <!-- Deep copy template -->
    <xsl:template match="node()|@*" mode="copy">
        <xsl:copy>
            <xsl:apply-templates mode="copy" select="@*"/>
            <xsl:apply-templates mode="copy"/>
        </xsl:copy>
    </xsl:template>
    
    <xsl:template match="/*">
        <xsl:element name="TEI">
            <xsl:copy-of select="@*"/>
            <xsl:attribute name="noNamespaceSchemaLocation"
                        namespace="http://www.w3.org/2001/XMLSchema-instance">your-value</xsl:attribute>
            <xsl:apply-templates/>
        </xsl:element>
    </xsl:template>
</xsl:stylesheet>
