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

  <xsl:template match="/">
      <root>
         <xsl:copy>
            <xsl:apply-templates select="root/TEI[@id='E_toDo']"/>
            <xsl:apply-templates select="root/TEI[@id='E_danksagung']"/>
         </xsl:copy>
         <xsl:copy>
            <xsl:apply-templates select="root/TEI[starts-with(@id,'I')]">
               <xsl:sort select="tokenize(@when, '-')[1]"/>
               <xsl:sort select="tokenize(@when, '-')[2]"/>
               <xsl:sort select="tokenize(@when, '-')[3]"/>
               <xsl:sort select="xs:integer(@n)"/>
            </xsl:apply-templates>
         </xsl:copy>
         <xsl:copy>
            <xsl:apply-templates select="root/TEI[starts-with(@id,'M')]">
               <xsl:sort select="tokenize(@when, '-')[1]"/>
               <xsl:sort select="tokenize(@when, '-')[2]"/>
               <xsl:sort select="tokenize(@when, '-')[3]"/>
               <xsl:sort select="xs:integer(@n)"/>
            </xsl:apply-templates>
         </xsl:copy>
         <xsl:copy>
            <xsl:apply-templates select="root/TEI[starts-with(@id,'P')]">
               <xsl:sort select="tokenize(@when, '-')[1]"/>
               <xsl:sort select="tokenize(@when, '-')[2]"/>
               <xsl:sort select="tokenize(@when, '-')[3]"/>
               <xsl:sort select="xs:integer(@n)"/>
            </xsl:apply-templates>
         </xsl:copy>
         <xsl:copy>
            <xsl:apply-templates select="root/TEI[@id='E_textauswahl']"/>
            <xsl:apply-templates select="root/TEI[@id='E_editorisch']"/>
            <xsl:apply-templates select="root/TEI[@id='E_literatur']"/>
            <xsl:apply-templates select="root/TEI[@id='E_nachwort']"/>
            <!--<xsl:apply-templates select="root/TEI[@id='E_nachwort-entwuerfe']"/>-->
         </xsl:copy>
      </root>
  </xsl:template> 
 
 
</xsl:stylesheet>
