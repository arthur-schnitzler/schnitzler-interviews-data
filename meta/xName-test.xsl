<?xml version="1.0" encoding="utf-8"?>
<!-- Dieses XSL testet die vergebenen @keys bei persName, orgName, placeName und workName auf Übereinstimmungen
mit den Einträgen in den Referenzdateien-->
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:xs="http://www.w3.org/2001/XMLSchema"
                xmlns:fn="http://www.w3.org/2005/xpath-functions"
                xmlns:foo="whatever"
                xmlns:tei="http://www.tei-c.org/ns/1.0"
                version="3.0">
    <xsl:output method="xml"/>
    <xsl:strip-space elements="*"/>
    <!-- subst root persName address body div sourceDesc physDesc witList msIdentifier fileDesc teiHeader correspDesc sender addressee placeSender placeAddressee context date witnessdate -->
    
    <!-- Globale Parameter -->
    
    <xsl:param name="persons" select="document('persName.xml')"/>
    <xsl:param name="works" select="document('workName.xml')"/>
    <xsl:param name="orgs" select="document('orgName.xml')"/>
    <xsl:param name="places" select="document('placeName.xml')"/>
    <xsl:param name="sigle" select="document('siglen.xml')"/>
    
    <xsl:key name="person-lookup" match="row" use="Nummer"/>
    <xsl:key name="work-lookup" match="row" use="Nummer"/>
    <xsl:key name="org-lookup" match="row" use="Nummer"/>
    <xsl:key name="place-lookup" match="row" use="Nummer"/>
    <xsl:key name="sigle-lookup" match="row" use="siglekey"/>


    <xsl:template match="start">
        <xsl:apply-templates select="//persName/@key"/>
    </xsl:template>
    
    <!-- Ersetzt im übergegeben String die Umlaute mit ae, oe, ue etc. -->
    <xsl:function name="foo:umlaute-entfernen">
        <xsl:param name="umlautstring"/>
        <xsl:value-of select="replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace($umlautstring,'ä','ae'), 'ö', 'oe'), 'ü', 'ue'), 'ß', 'ss'), 'Ä', 'Ae'), 'Ü', 'Ue'), 'Ö', 'Oe'), 'é', 'e'), 'è', 'e'), 'É', 'E'), 'È', 'E'),'ò', 'o'), 'Č', 'C'), 'D’','D'), 'd’','D'), 'Ś', 'S'), '’', ' '), '&amp;', 'und'), 'ë', 'e'), '!', ''), 'č', 'c'), 'à', 'a'), 'á', 'a')"/>
    </xsl:function>
    
    <!-- Ersetzt im übergegeben String die Kaufmannsund -->
    <xsl:function name="foo:sonderzeichen-ersetzen">
        <xsl:param name="sonderzeichen"/>
        <xsl:value-of select="replace(replace($sonderzeichen, '&amp;', '{\\kaufmannsund} '), '!', '{\\rufezeichen}')"/>
    </xsl:function>
    
    <xsl:function name="foo:vergleichsstring">
        <xsl:param name="input" as="xs:string"/>
        <xsl:choose>
            <xsl:when test="string-length($input) &gt; 4">
                <xsl:value-of select="substring(foo:sonderzeichen-ersetzen(foo:umlaute-entfernen(lower-case($input))), 1, string-length(foo:sonderzeichen-ersetzen(foo:umlaute-entfernen(lower-case($input)))) - 1)"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:value-of select="foo:sonderzeichen-ersetzen(foo:umlaute-entfernen(lower-case($input)))"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:function>
    
    <xsl:function name="foo:persNameCheck">
        <xsl:param name="first" as="xs:string?"/>
        <xsl:param name="dernode" as="xs:string?"/>
        <xsl:variable name="indexkey"
                    select="key('person-lookup', $first, $persons)"
                    as="node()?"/>
        <xsl:variable name="kNachname"
                    as="xs:string?"
                    select="normalize-space($indexkey/Nachname)"/>
        <xsl:variable name="kVorname"
                    as="xs:string?"
                    select="normalize-space(replace($indexkey/Vorname, '^ von', ''))"/>
        <xsl:variable name="kZusatz"
                    as="xs:string?"
                    select="normalize-space($indexkey/Zusatz)"/>
        <xsl:choose>
            <xsl:when test="contains(foo:vergleichsstring($dernode), foo:vergleichsstring($kNachname))"/>
            <xsl:when test="contains(foo:vergleichsstring($dernode), foo:vergleichsstring($kVorname))"/>
            <xsl:when test="contains(foo:vergleichsstring($kNachname), foo:vergleichsstring($dernode))"/>
            <xsl:when test="contains(foo:vergleichsstring($kVorname), foo:vergleichsstring($dernode))"/>
            <xsl:when test="contains(foo:vergleichsstring($kZusatz), foo:vergleichsstring($dernode))"/>
            <xsl:when test="string-length($dernode) = 1 and substring($kNachname, 1, 1) = $dernode"/>
            <xsl:when test="string-length($dernode) = 2 and ends-with($dernode, '.') and substring($kNachname, 1, 1) = substring($dernode, 1, 1)"/>    
            <xsl:when test="string-length($dernode) = 3 and ends-with($dernode, '.') and substring($kNachname, 1, 2) = substring($dernode, 1, 2)"/>    
            <xsl:otherwise>
                <xsl:value-of select="$dernode"/>
                <xsl:text> TxxI </xsl:text>
                <xsl:value-of select="concat($kVorname, ' ', $kNachname)"/>
                <xsl:text>
             </xsl:text>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:function>
    
    <xsl:function name="foo:workNameCheck">
        <xsl:param name="first" as="xs:string?"/>
        <xsl:param name="dernode" as="xs:string?"/>
        <xsl:variable name="indexkey"
                    select="key('work-lookup', $first, $works)"
                    as="node()?"/>
        <xsl:variable name="kTitel"
                    as="xs:string?"
                    select="normalize-space($indexkey/Titel)"/>
        <xsl:choose>
            <xsl:when test="contains(foo:vergleichsstring($dernode), foo:vergleichsstring($kTitel))"/>
            <xsl:when test="contains(foo:vergleichsstring($kTitel), foo:vergleichsstring($dernode))"/>
            <xsl:otherwise>
                <xsl:value-of select="$dernode"/>
                <xsl:text> TxxI </xsl:text>
                <xsl:value-of select="$kTitel"/>
                <xsl:text>
             </xsl:text>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:function>
    
    <xsl:function name="foo:keyeinzeln">
        <xsl:param name="tfirst" as="xs:string?"/>
        <xsl:param name="trest" as="xs:string?"/>
        <xsl:param name="tdernode" as="xs:string?"/>
        <xsl:variable name="first" select="string($tfirst)"/>
        <xsl:variable name="rest" select="string($trest)"/>
        <xsl:variable name="dernode" select="string($tdernode)"/>
     <xsl:choose>
         <xsl:when test="starts-with($first, 'A002') or starts-with($first, 'A003') or starts-with($first, 'A004')">
             <xsl:value-of select="foo:persNameCheck($first, $dernode)"/>
         </xsl:when>
         <xsl:when test="starts-with($first, 'A020') or starts-with($first, 'A021')">
             <xsl:value-of select="foo:workNameCheck($first, $dernode)"/>
         </xsl:when>
     </xsl:choose>
      <xsl:if test="count(normalize-space($rest)) &gt; 6">
         <xsl:value-of select="foo:keyeinzeln(substring(normalize-space($rest), 1, 7), substring($rest, 8), $dernode)"/>
     </xsl:if>   
    </xsl:function>
    
    
   <xsl:template match="@key">
      <xsl:choose>
         <xsl:when test="parent::title"/>
         <xsl:when test="parent::rs"/>
         <xsl:otherwise>
            <xsl:variable name="dernode" as="xs:string?" select="string(parent::*)"/>
                 <xsl:value-of select="foo:keyeinzeln(substring(., 1, 7), substring(., 8), $dernode)"/>
         </xsl:otherwise>
      </xsl:choose>   
   </xsl:template>
    
    
</xsl:stylesheet>
