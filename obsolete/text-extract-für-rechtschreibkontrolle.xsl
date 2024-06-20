<?xml version="1.0" encoding="utf-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
   xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:fn="http://www.w3.org/2005/xpath-functions"
   xmlns:foo="whatever" xmlns:tei="http://www.tei-c.org/ns/1.0" version="3.0">
   <xsl:output method="xml" indent="false"/>
   <xsl:strip-space elements="*"/>
     
  <xsl:template match="root">
     <root>
        <xsl:for-each select="TEI[not(starts-with(@id, 'E_'))]">
           <xsl:apply-templates select="descendant::div"/>
        </xsl:for-each>
     </root>
  </xsl:template>
   
   <xsl:template match="div">
     <xsl:variable name="id" select="ancestor::TEI/@id"/>
      <xsl:variable name="lang">
         <xsl:choose>
            <xsl:when test="@language">
               <xsl:value-of select="substring(@language,1,2)"/>
            </xsl:when>
            <xsl:when test="ancestor::TEI/descendant::profileDesc/langUsage/language">
               <xsl:value-of select="substring(ancestor::TEI/descendant::profileDesc/langUsage/language/@ident, 1,2)"/>
            </xsl:when>
            <xsl:otherwise>
               <xsl:text>de</xsl:text>
            </xsl:otherwise>
         </xsl:choose>
      </xsl:variable>
      <xsl:for-each select="descendant::p">
         <xsl:text> </xsl:text>
         <xsl:element name="p">
           <xsl:attribute name="id">
              <xsl:value-of select="$id"/>
           </xsl:attribute>
           <xsl:if test="not($lang='')">
           <xsl:attribute name="language">
              <xsl:value-of select="$lang"/>
           </xsl:attribute>
           </xsl:if>
           <xsl:apply-templates select="*[not(self::note)]"/>
        </xsl:element>
     </xsl:for-each>
      <xsl:for-each select="descendant::head">
         <xsl:text> </xsl:text>
         <xsl:element name="head">
            <xsl:attribute name="id">
               <xsl:value-of select="$id"/>
            </xsl:attribute>
            <xsl:if test="not($lang='')">
               <xsl:attribute name="language">
                  <xsl:value-of select="$lang"/>
               </xsl:attribute>
            </xsl:if>
            <xsl:apply-templates/>
         </xsl:element>
      </xsl:for-each>
      <xsl:for-each select="descendant::note[not(@type='textConst')]">
         <xsl:text> </xsl:text>
         <xsl:element name="note">
            <xsl:attribute name="id">
               <xsl:value-of select="$id"/>
            </xsl:attribute>
            <xsl:if test="not($lang='')">
               <xsl:attribute name="language">
                  <xsl:value-of select="$lang"/>
               </xsl:attribute>
            </xsl:if>
            
            <xsl:apply-templates/>
         </xsl:element>
      </xsl:for-each>
   </xsl:template>
   
   <xsl:template match="space">
      <xsl:text> </xsl:text>
   </xsl:template>
  <!--
   <xsl:template match="p|dateline|salute|l">
      <xsl:text> </xsl:text>
      <xsl:apply-templates/>
      <xsl:text> </xsl:text>
   </xsl:template>-->
   
   <xsl:template match="del"/>
   
   <xsl:template match="text()">
      <xsl:value-of select="."/>
   </xsl:template>
 
  
  
</xsl:stylesheet>
