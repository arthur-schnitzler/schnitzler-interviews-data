<?xml version="1.0" encoding="utf-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
   xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:fn="http://www.w3.org/2005/xpath-functions"
   xmlns:foo="whatever" xmlns:tei="http://www.tei-c.org/ns/1.0" version="3.0">
   <xsl:output method="xml"/>
   <xsl:strip-space elements="*"/>
   <!-- subst root persName address body div sourceDesc physDesc witList msIdentifier fileDesc teiHeader correspDesc correspAction date witnessdate -->
   <xsl:import href="partial/date-format-for-print.xsl"/>
   <!-- Globale Parameter -->
   <xsl:param name="persons" select="document('../meta/back.xml')"/>
   <xsl:key name="person-lookup" match="person" use="replace(@xml:id, 'pmb', '#pmb')"/>
   <xsl:param name="works" select="document('../meta/back.xml')"/>
   <xsl:key name="work-lookup" match="bibl" use="replace(@xml:id, 'pmb', '#pmb')"/>
   <xsl:param name="orgs" select="document('../meta/back.xml')"/>
   <xsl:key name="org-lookup" match="org" use="replace(@xml:id, 'pmb', '#pmb')"/>
   <xsl:param name="places" select="document('../meta/back.xml')"/>
   <xsl:key name="place-lookup" match="place" use="replace(@xml:id, 'pmb', '#pmb')"/>
   <xsl:param name="placework" select="document('../meta/placework.xml')"/>
   <xsl:key name="placework-lookup" match="item" use="related_work_id"/>
   <xsl:param name="sigle" select="document('../indices/siglen.xml')"/>
   <xsl:param name="interviewfragen" select="document('../indices/questions.xml')"/>
   <xsl:key name="sigle-lookup" match="row" use="siglekey"/>
   <xsl:key name="question-lookup" match="tei:item" use="@xml:id"/>
   <!-- Funktionen -->
   <!-- Ersetzt im übergegeben String die Umlaute mit ae, oe, ue etc. -->
   <xsl:function name="foo:umlaute-entfernen">
      <xsl:param name="umlautstring"/>
      <xsl:variable name="umlaut1" select="replace($umlautstring, 'ä', 'ae')" />
      <xsl:variable name="umlaut2" select="replace($umlaut1, 'ö', 'oe')" />
      <xsl:variable name="umlaut3" select="replace($umlaut2, 'ü', 'ue')" />
      <xsl:variable name="umlaut4" select="replace($umlaut3, 'ß', 'ss')" />
      <xsl:variable name="umlaut5" select="replace($umlaut4, 'Ä', 'Ae')" />
      <xsl:variable name="umlaut6" select="replace($umlaut5, 'Ü', 'Ue')" />
      <xsl:variable name="umlaut7" select="replace($umlaut6, 'Ö', 'Oe')" />
      <xsl:variable name="umlaut8" select="replace($umlaut7, 'é', 'e')" />
      <xsl:variable name="umlaut9" select="replace($umlaut8, 'è', 'e')" />
      <xsl:variable name="umlaut10" select="replace($umlaut9, 'É', 'E')" />
      <xsl:variable name="umlaut11" select="replace($umlaut10, 'ò', 'o')" />
      <xsl:variable name="umlaut12" select="replace($umlaut11, 'Č', 'C')" />
      <xsl:variable name="umlaut13" select="replace($umlaut12, 'D’', 'D')" />
      <xsl:variable name="umlaut14" select="replace($umlaut13, 'd’', 'D')" />
      <xsl:variable name="umlaut15" select="replace($umlaut14, 'Ś', 'S')" />
      <xsl:variable name="umlaut16" select="replace($umlaut15, '’', ' ')" />
      <xsl:variable name="umlaut17" select="replace($umlaut16, '&amp;', 'und')" />
      <xsl:variable name="umlaut18" select="replace($umlaut17, 'ë', 'e')" />
      <xsl:variable name="umlaut19" select="replace($umlaut18, '!', '')" />
      <xsl:variable name="umlaut20" select="replace($umlaut19, 'č', 'c')" />
      <xsl:variable name="umlaut21" select="replace($umlaut20, 'Ł', 'L')" />
      <xsl:variable name="umlaut22" select="replace($umlaut21, 'ø', 'zo')" />
      <xsl:variable name="umlaut23" select="replace($umlaut22, 'Ø', 'ZO')" />
      <xsl:variable name="umlaut24" select="replace($umlaut23, 'å', 'zza')" />
      <xsl:variable name="umlaut25" select="replace($umlaut24, 'Å', 'ZZA')" />
      
      <xsl:value-of select="$umlaut25" />
      
      
      
      <!--<xsl:value-of
         select="replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace(replace($umlautstring,'ä','ae'), 'ö', 'oe'), 'ü', 'ue'), 'ß', 'ss'), 'Ä', 'Ae'), 'Ü', 'Ue'), 'Ö', 'Oe'), 'é', 'e'), 'è', 'e'), 'É', 'E')"
      />-->
   </xsl:function>
   <!-- Ersetzt im übergegeben String die Kaufmannsund -->
   <xsl:function name="foo:sonderzeichen-ersetzen">
      <xsl:param name="sonderzeichen"/>
      <xsl:value-of
         select="replace(replace($sonderzeichen, '&amp;', '{\\kaufmannsund} '), '!', '{\\rufezeichen}')"
      />
   </xsl:function>
   <!-- Gibt zwei Werte zurück: Den Indexeintrag zum sortieren und den, wie er erscheinen soll -->
   <xsl:function name="foo:index-sortiert">
      <xsl:param name="index-sortieren" as="xs:string"/>
      <xsl:param name="shape" as="xs:string"/>
      <xsl:value-of select="foo:umlaute-entfernen(foo:werk-um-artikel-kuerzen($index-sortieren))"/>
      <xsl:text>@</xsl:text>
      <xsl:choose>
         <xsl:when test="$shape = 'sc'">
            <xsl:text>\textsc{</xsl:text>
            <xsl:value-of select="foo:sonderzeichen-ersetzen($index-sortieren)"/>
            <xsl:text>}</xsl:text>
         </xsl:when>
         <xsl:when test="$shape = 'it'">
            <xsl:text>\emph{</xsl:text>
            <xsl:value-of select="foo:sonderzeichen-ersetzen($index-sortieren)"/>
            <xsl:text>}</xsl:text>
         </xsl:when>
         <xsl:when test="$shape = 'bf'">
            <xsl:text>\textbf{</xsl:text>
            <xsl:value-of select="foo:sonderzeichen-ersetzen($index-sortieren)"/>
            <xsl:text>}</xsl:text>
         </xsl:when>
         <xsl:otherwise>
            <xsl:value-of select="foo:sonderzeichen-ersetzen($index-sortieren)"/>
         </xsl:otherwise>
      </xsl:choose>
   </xsl:function>
   <xsl:function name="foo:date-iso">
      <xsl:param name="iso-datum" as="xs:string"/>
      <xsl:variable name="iso-year" as="xs:string?" select="tokenize($iso-datum, '-')[1]"/>
      <xsl:variable name="iso-month" as="xs:string?" select="tokenize($iso-datum, '-')[2]"/>
      <xsl:variable name="iso-day" as="xs:string?" select="tokenize($iso-datum, '-')[last()]"/>
      <xsl:choose>
         <xsl:when test="$iso-day = '00' and $iso-month = '00'">
            <xsl:value-of select="number($iso-year)"/>
         </xsl:when>
         <xsl:when test="$iso-day = '00'">
            <xsl:value-of select="foo:Monatsname($iso-month)"/>
            <xsl:text> </xsl:text>
            <xsl:value-of select="$iso-year"/>
         </xsl:when>
         <xsl:otherwise>
            <xsl:value-of select="number($iso-day)"/>
            <xsl:text>.{\,}</xsl:text>
            <xsl:value-of select="number($iso-month)"/>
            <xsl:text>.{\,}</xsl:text>
            <xsl:value-of select="number($iso-year)"/>
         </xsl:otherwise>
      </xsl:choose>
   </xsl:function>
   <!-- Diese Funktion setzt den Inhalt eines Index-Eintrags einer Person. Übergeben wird nur der key -->
   <xsl:function name="foo:person-fuer-index">
      <xsl:param name="xkey" as="xs:string"/>
      <xsl:variable name="indexkey" select="key('person-lookup', $xkey, $persons)[1]" as="node()?"/>
      <xsl:variable name="kName" as="xs:string?"
         select="normalize-space($indexkey/persName[1]/surname[1])"/>
      <xsl:variable name="kforename" as="xs:string?"
         select="normalize-space($indexkey/persName[1]/forename[1])"/>
      <xsl:variable name="gesamterName" as="xs:string">
         <xsl:choose>
            <xsl:when test="not($kName = '') and not($kforename = '')">
               <xsl:value-of select="concat($kName, ', ', $kforename)"/>
            </xsl:when>
            <xsl:when test="not($kName = '')">
               <xsl:value-of select="$kName"/>
            </xsl:when>
            <xsl:when test="not($kforename = '')">
               <xsl:value-of select="$kforename"/>
            </xsl:when>
            <xsl:otherwise>
               <xsl:text>XXXX NAME1</xsl:text>
            </xsl:otherwise>
         </xsl:choose>
      </xsl:variable>
      <xsl:variable name="kBeruf" as="xs:boolean">
         <xsl:choose>
            <xsl:when
               test="$indexkey/occupation[1] and not(starts-with($indexkey/persName[1]/surname[1], '??'))">
               <xsl:value-of select="true()"/>
            </xsl:when>
            <xsl:otherwise>
               <xsl:value-of select="false()"/>
            </xsl:otherwise>
         </xsl:choose>
      </xsl:variable>
      <xsl:variable name="kTodesort" as="xs:string?">
         <xsl:choose>
            <xsl:when test="$indexkey/death/settlement/placeName">
               <xsl:value-of select="fn:normalize-space($indexkey/death/settlement[1]/placeName[1])"
               />
            </xsl:when>
            <xsl:when test="$indexkey/death/placeName[@type = 'deportation']">
               <xsl:value-of
                  select="concat('deportiert ', fn:normalize-space($indexkey/death/placeName[1]/settlement[1]))"
               />
            </xsl:when>
            <xsl:when test="$indexkey/death/placeName[@type = 'burial']">
               <xsl:value-of
                  select="concat('beerdigt ', fn:normalize-space($indexkey/death/placeName[1]/settlement[1]))"
               />
            </xsl:when>
         </xsl:choose>
      </xsl:variable>
      <xsl:variable name="kGeburtsort" as="xs:string?"
         select="$indexkey/birth/settlement[1]/placeName[1]"/>
      <xsl:variable name="birth_day" as="xs:string?">
         <xsl:variable name="burtstag">
            <xsl:value-of select="foo:date-translate($indexkey[1]/birth[1]/date[1]/text())"/>
         </xsl:variable>
         <xsl:choose>
            <xsl:when test="string-length($kGeburtsort) &gt; 0">
               <xsl:value-of select="concat($burtstag, ' ', $kGeburtsort)"/>
            </xsl:when>
            <xsl:otherwise>
               <xsl:value-of select="$burtstag"/>
            </xsl:otherwise>
         </xsl:choose>
      </xsl:variable>
      <xsl:variable name="ebenda" as="xs:boolean"
         select="$kGeburtsort = $kTodesort and fn:string-length($kGeburtsort) &gt; 1"/>
      <xsl:variable name="death_day" as="xs:string?">
         <xsl:variable name="tottag">
            <xsl:value-of select="foo:date-translate($indexkey[1]/death[1]/date[1]/text())"/>
         </xsl:variable>
         <xsl:choose>
            <xsl:when test="$ebenda">
               <xsl:value-of select="concat($tottag, ' ebd.')"/>
            </xsl:when>
            <xsl:when test="string-length($kTodesort) &gt; 0">
               <xsl:value-of select="concat($tottag, ' ', $kTodesort)"/>
            </xsl:when>
            <xsl:otherwise>
               <xsl:value-of select="$tottag"/>
            </xsl:otherwise>
         </xsl:choose>
      </xsl:variable>
      <xsl:variable name="lebensdaten" as="xs:string?">
         <xsl:choose>
            <xsl:when test="contains($birth_day, 'Jh.')">
               <xsl:value-of select="$birth_day"/>
            </xsl:when>
            <xsl:when test="string-length($birth_day) &gt; 1 and string-length($death_day) &gt; 1">
               <xsl:value-of select="concat($birth_day, ' – ', $death_day)"/>
            </xsl:when>
            <xsl:when test="string-length($birth_day) &gt; 1">
               <xsl:value-of select="concat('*~', $birth_day)"/>
            </xsl:when>
            <xsl:when test="string-length($death_day) &gt; 1">
               <xsl:value-of select="concat('†~', $death_day)"/>
            </xsl:when>
         </xsl:choose>
      </xsl:variable>
      <xsl:choose>
         <xsl:when test="fn:starts-with($indexkey/persName/surname, '??')">
            <!-- Sonderfall, nicht namentlich identifizierte Personen -->
            <xsl:text>?? Person@Nicht ermittelte Personen!</xsl:text>
            <xsl:value-of select="foo:index-sortiert($indexkey/persName/surname, 'sc')"/>
         </xsl:when>
         <xsl:when test="$kforename != '' and $kName != ''">
            <xsl:variable name="ganzer-name" select="concat($kforename, ' ', $kName)"/>
            <xsl:variable name="ganzer-geburtsname" as="xs:string?">
               <xsl:choose>
                  <xsl:when
                     test="$indexkey/persName[@type = 'person_geburtsname_nachname'][1] and $indexkey/persName[@type = 'person_geburtsname-vorname'][1]">
                     <xsl:variable name="name-zusammen"
                        select="concat($indexkey/persName[@type = 'person_geburtsname-vorname'][1], ' ', $indexkey/persName[@type = 'person_geburtsname_nachname'][1])"/>
                     <xsl:if test="not($name-zusammen = $ganzer-name)">
                        <xsl:value-of select="$name-zusammen"/>
                     </xsl:if>
                  </xsl:when>
                  <xsl:when test="$indexkey/persName[@type = 'person_geburtsname-vorname'][1]">
                     <xsl:if
                        test="not($kforename = $indexkey/persName[@type = 'person_geburtsname-vorname'][1])">
                        <xsl:value-of
                           select="concat($indexkey/persName[@type = 'person_geburtsname-vorname'][1], ' ', substring($kName, 1, 1), '.')"
                        />
                     </xsl:if>
                  </xsl:when>
                  <xsl:when test="$indexkey/persName[@type = 'person_geburtsname_nachname'][1]">
                     <xsl:if
                        test="not($kName = $indexkey/persName[@type = 'person_geburtsname_nachname'][1])">
                        <xsl:value-of
                           select="concat(substring($kforename, 1, 1), '. ', $indexkey/persName[@type = 'person_geburtsname_nachname'][1])"
                        />
                     </xsl:if>
                  </xsl:when>
                  <xsl:otherwise>
                     <xsl:text>XXXX SELTSAM</xsl:text>
                  </xsl:otherwise>
               </xsl:choose>
            </xsl:variable>
            <xsl:value-of select="foo:index-sortiert($gesamterName, 'sc')"/>
            <xsl:if
               test="$indexkey/persName[contains(@type, 'geburt')] and not(normalize-space($ganzer-geburtsname) = '' or empty($ganzer-geburtsname))">
               <xsl:text>, geb. \textsc{</xsl:text>
               <xsl:value-of select="$ganzer-geburtsname"/>
               <xsl:text>}</xsl:text>
            </xsl:if>
            <xsl:if test="$indexkey/persName[contains(@type, 'namensvariante')]">
               <xsl:choose>
                  <xsl:when
                     test="$indexkey/persName[@type = 'namensvariante'] = 'Hofmannsthal, Hugo'"/>
                  <xsl:otherwise>
                     <xsl:text>, auch \textsc{</xsl:text>
                     <xsl:for-each select="$indexkey/persName[contains(@type, 'namensvariante')]">
                        <xsl:value-of select="."/>
                        <xsl:if test="not(fn:position() = last())">
                           <xsl:text>, </xsl:text>
                        </xsl:if>
                     </xsl:for-each>
                     <xsl:text>}</xsl:text>
                  </xsl:otherwise>
               </xsl:choose>
            </xsl:if>
            <xsl:if test="$indexkey/persName[@type = 'person_rufname']">
               <xsl:text>, gen. \textsc{</xsl:text>
               <xsl:for-each select="$indexkey/persName[@type = 'person_rufname']">
                  <xsl:value-of select="."/>
                  <xsl:if test="not(fn:position() = last())">
                     <xsl:text>, </xsl:text>
                  </xsl:if>
               </xsl:for-each>
               <xsl:text>}</xsl:text>
            </xsl:if>
            <xsl:if test="$indexkey/persName[@type = 'person_geschieden']">
               <xsl:text>, geschied. \textsc{</xsl:text>
               <xsl:for-each select="$indexkey/persName[@type = 'person_geschieden']">
                  <xsl:value-of select="."/>
                  <xsl:if test="not(fn:position() = last())">
                     <xsl:text>, </xsl:text>
                  </xsl:if>
               </xsl:for-each>
               <xsl:text>}</xsl:text>
            </xsl:if>
            <xsl:if test="$indexkey/persName[@type = 'person_verwitwet']">
               <xsl:text>, verwitw. \textsc{</xsl:text>
               <xsl:for-each select="$indexkey/persName[@type = 'person_verwitwet']">
                  <xsl:value-of select="."/>
                  <xsl:if test="not(fn:position() = last())">
                     <xsl:text>, </xsl:text>
                  </xsl:if>
               </xsl:for-each>
               <xsl:text>}</xsl:text>
            </xsl:if>
            <xsl:if test="$indexkey/persName[@type = 'person_ehename']">
               <xsl:text>, verh. \textsc{</xsl:text>
               <xsl:for-each select="$indexkey/persName[@type = 'person_ehename']">
                  <xsl:value-of select="."/>
                  <xsl:if test="not(fn:position() = last())">
                     <xsl:text>, </xsl:text>
                  </xsl:if>
               </xsl:for-each>
               <xsl:text>}</xsl:text>
            </xsl:if>
            <xsl:if
               test="$indexkey/persName[@type = 'person_pseudonym'] and not($indexkey/persName[@type = 'person_pseudonym'] = $ganzer-name)">
               <xsl:text>, Pseud. \textsc{</xsl:text>
               <xsl:for-each select="$indexkey/persName[@type = 'person_pseudonym']">
                  <xsl:value-of select="."/>
                  <xsl:if test="not(fn:position() = last())">
                     <xsl:text>, </xsl:text>
                  </xsl:if>
               </xsl:for-each>
               <xsl:text>}</xsl:text>
            </xsl:if>
         </xsl:when>
         <xsl:when test="not($kforename = '') and $kName = ''">
            <xsl:value-of select="foo:index-sortiert(($kforename), 'sc')"/>
         </xsl:when>
         <xsl:when test="$kforename = '' and not($kName = '')">
            <xsl:value-of select="foo:index-sortiert(($kName), 'sc')"/>
         </xsl:when>
         <xsl:otherwise>
            <xsl:text>\textcolor{red}{\textsuperscript{XXXX1 indx}}</xsl:text>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:if test="fn:string-length($lebensdaten) &gt; 1">
         <xsl:text> (</xsl:text>
         <xsl:value-of select="$lebensdaten"/>
         <xsl:text>)</xsl:text>
      </xsl:if>
      <xsl:if test="$kBeruf and not($kName = '??')">
         <xsl:variable name="gender" as="xs:string" select="$indexkey/sex/@value"/>
         <xsl:text>, \emph{</xsl:text>
         <xsl:for-each select="$indexkey/occupation">
            <xsl:if test="fn:position() &lt; 4">
               <!-- Nur drei Berufe aufnehmen -->
               <xsl:variable name="unterster-beruf">
                  <xsl:choose>
                     <xsl:when test="contains(., '&gt;&gt;')">
                        <xsl:value-of select="tokenize(., ' ')[last()]"/>
                     </xsl:when>
                     <xsl:otherwise>
                        <xsl:value-of select="."/>
                     </xsl:otherwise>
                  </xsl:choose>
               </xsl:variable>
               <xsl:choose>
                  <xsl:when test="$gender = 'male'">
                     <xsl:value-of select="normalize-space(substring-before($unterster-beruf, '/'))"
                     />
                  </xsl:when>
                  <xsl:when test="$gender = 'female'">
                     <xsl:value-of select="normalize-space(substring-after($unterster-beruf, '/'))"
                     />
                  </xsl:when>
                  <xsl:otherwise>
                     <xsl:value-of select="normalize-space($unterster-beruf)"/>
                  </xsl:otherwise>
               </xsl:choose>
               <xsl:if test="not(fn:position() = last()) and not(fn:position() = 3)">
                  <!-- 2. Teil von nur drei Berufe -->
                  <xsl:text>, </xsl:text>
               </xsl:if>
            </xsl:if>
         </xsl:for-each>
         <xsl:text>}</xsl:text>
         <xsl:text/>
      </xsl:if>
   </xsl:function>
   <xsl:function name="foo:person-in-index">
      <xsl:param name="indexkey" as="xs:string?"/>
      <xsl:param name="endung" as="xs:string"/>
      <xsl:param name="endung-setzen" as="xs:boolean"/>
      <xsl:choose>
         <xsl:when test="$indexkey = '#pmb2121' and $endung-setzen"/>
         <!-- Schnitzler als Person raus -->
         <xsl:when test="$indexkey = ''"/>
         <xsl:otherwise>
            <xsl:text>\pwindex{</xsl:text>
            <xsl:value-of select="foo:person-fuer-index($indexkey)"/>
            <xsl:if test="$endung-setzen">
               <xsl:value-of select="$endung"/>
            </xsl:if>
         </xsl:otherwise>
      </xsl:choose>
   </xsl:function>
   <xsl:function name="foo:werk-um-artikel-kuerzen">
      <xsl:param name="string" as="xs:string?"/>
      <xsl:choose>
         <xsl:when test="starts-with($string, 'Der ')">
            <xsl:value-of select="substring-after($string, 'Der ')"/>
         </xsl:when>
         <xsl:when test="starts-with($string, 'Das ')">
            <xsl:value-of select="substring-after($string, 'Das ')"/>
         </xsl:when>
         <xsl:when test="starts-with($string, 'Die ')">
            <xsl:value-of select="substring-after($string, 'Die ')"/>
         </xsl:when>
         <xsl:when test="starts-with($string, 'The ')">
            <xsl:value-of select="substring-after($string, 'The ')"/>
         </xsl:when>
         <xsl:when test="starts-with($string, 'Ein ')">
            <xsl:value-of select="substring-after($string, 'Ein ')"/>
         </xsl:when>
         <xsl:when test="starts-with($string, 'An ')">
            <xsl:choose>
               <xsl:when
                  test="starts-with($string, 'An die') or starts-with($string, 'An ein') or starts-with($string, 'An den') or starts-with($string, 'An das')">
                  <xsl:value-of select="$string"/>
               </xsl:when>
               <xsl:otherwise>
                  <xsl:value-of select="substring-after($string, 'An ')"/>
               </xsl:otherwise>
            </xsl:choose>
         </xsl:when>
         <xsl:when test="starts-with($string, 'A ')">
            <xsl:value-of select="substring-after($string, 'A ')"/>
         </xsl:when>
         <xsl:when test="starts-with($string, 'La ')">
            <xsl:value-of select="substring-after($string, 'La ')"/>
         </xsl:when>
         <xsl:when test="starts-with($string, 'Il ')">
            <xsl:value-of select="substring-after($string, 'Il ')"/>
         </xsl:when>
         <xsl:when test="starts-with($string, 'Les ')">
            <xsl:value-of select="substring-after($string, 'Les ')"/>
         </xsl:when>
         <xsl:when test="starts-with($string, 'L’')">
            <xsl:value-of select="substring-after($string, 'L’')"/>
         </xsl:when>
         <xsl:when test="starts-with($string, '‹s')">
            <xsl:value-of select="substring-after($string, '‹s')"/>
         </xsl:when>
         <xsl:when test="starts-with($string, '‹s')">
            <xsl:value-of select="substring-after($string, '‹s')"/>
         </xsl:when>
         <xsl:otherwise>
            <xsl:value-of select="$string"/>
         </xsl:otherwise>
      </xsl:choose>
   </xsl:function>
   <xsl:function name="foo:werk-kuerzen">
      <xsl:param name="string" as="xs:string?"/>
      <xsl:choose>
         <xsl:when test="substring($string, 1, 1) = '»'">
            <xsl:value-of select="foo:werk-kuerzen(substring($string, 2))"/>
         </xsl:when>
         <xsl:when test="substring($string, 1, 1) = '['">
            <xsl:choose>
               <!-- Das unterscheidet ob Autorangabe [H. B.:] oder unechter Titel [Jugend in Wien] -->
               <xsl:when test="contains($string, ':]')">
                  <xsl:value-of select="foo:werk-kuerzen(substring-after($string, ':] '))"/>
               </xsl:when>
               <xsl:otherwise>
                  <xsl:value-of select="foo:werk-kuerzen(substring($string, 2))"/>
               </xsl:otherwise>
            </xsl:choose>
         </xsl:when>
         <xsl:otherwise>
            <xsl:value-of select="foo:umlaute-entfernen(foo:werk-um-artikel-kuerzen($string))"/>
         </xsl:otherwise>
      </xsl:choose>
   </xsl:function>
   <!-- <xsl:if test="tokenize(">
        
      </xsl:if>  -->
   <xsl:function name="foo:werk-metadaten-in-index">
      <xsl:param name="typ" as="xs:string?"/>
      <xsl:param name="datum" as="xs:string?"/>
      <xsl:param name="role" as="xs:string?"/>
      <xsl:variable name="role-ausgeschrieben" as="xs:string?">
         <xsl:choose>
            <xsl:when test="$role = 'hat-geschaffen'"/>
            <xsl:when test="$role = 'hat-unter-einem-kurzel-veroffentlicht'"/>
            <xsl:when test="$role = 'hat-anonym-veroffentlicht'"/>
            <xsl:when test="$role = 'hat-unter-pseudonym-geschrieben'"/>
            <xsl:when test="$role = 'hat-ubersetzt'">
               <xsl:text>Übersetzung</xsl:text>
            </xsl:when>
            <xsl:when test="$role = 'hat-illustriert'">
               <xsl:text>Illustration</xsl:text>
            </xsl:when>
            <xsl:when test="$role = 'hat-vertont'">
               <xsl:text>Vertonung</xsl:text>
            </xsl:when>
            <xsl:when test="$role = 'hat-herausgegeben'">
               <xsl:text>Hrsg.</xsl:text>
            </xsl:when>
            <xsl:when
               test="$role = 'hat-ein-vorwortnachwort-verfasst-zu' or $role = 'ist-beitragerin-zu'">
               <xsl:text>Beitrag</xsl:text>
            </xsl:when>
         </xsl:choose>
      </xsl:variable>
      <xsl:variable name="vorhanden-typ" as="xs:boolean">
         <xsl:choose>
            <xsl:when test="not(fn:normalize-space($typ) = '')">
               <xsl:value-of select="true()"/>
            </xsl:when>
            <xsl:otherwise>
               <xsl:value-of select="false()"/>
            </xsl:otherwise>
         </xsl:choose>
      </xsl:variable>
      <xsl:variable name="vorhanden-datum" as="xs:boolean">
         <xsl:choose>
            <xsl:when test="not(fn:normalize-space($datum) = '')">
               <xsl:value-of select="true()"/>
            </xsl:when>
            <xsl:otherwise>
               <xsl:value-of select="false()"/>
            </xsl:otherwise>
         </xsl:choose>
      </xsl:variable>
      <xsl:variable name="vorhanden-role-ausgeschrieben" as="xs:boolean">
         <xsl:choose>
            <xsl:when test="not(fn:normalize-space($role-ausgeschrieben) = '')">
               <xsl:value-of select="true()"/>
            </xsl:when>
            <xsl:otherwise>
               <xsl:value-of select="false()"/>
            </xsl:otherwise>
         </xsl:choose>
      </xsl:variable>
      <xsl:if test="$vorhanden-typ or $vorhanden-role-ausgeschrieben or $vorhanden-datum">
         <xsl:text> {[}</xsl:text>
      </xsl:if>
      <xsl:choose>
         <xsl:when test="$vorhanden-typ and $vorhanden-role-ausgeschrieben and $vorhanden-datum">
            <xsl:value-of select="normalize-space($role-ausgeschrieben)"/>
            <xsl:text>, </xsl:text>
            <xsl:value-of select="normalize-space($typ)"/>
            <xsl:text>, </xsl:text>
            <xsl:value-of select="$datum"/>
         </xsl:when>
         <xsl:when test="$vorhanden-typ and $vorhanden-role-ausgeschrieben">
            <xsl:value-of select="normalize-space($role-ausgeschrieben)"/>
            <xsl:text>, </xsl:text>
            <xsl:value-of select="normalize-space($typ)"/>
         </xsl:when>
         <xsl:when test="$vorhanden-typ and $vorhanden-datum">
            <xsl:value-of select="normalize-space($typ)"/>
            <xsl:text>, </xsl:text>
            <xsl:value-of select="$datum"/>
         </xsl:when>
         <xsl:when test="$vorhanden-role-ausgeschrieben and $vorhanden-datum">
            <xsl:value-of select="normalize-space($role-ausgeschrieben)"/>
            <xsl:text>, </xsl:text>
            <xsl:value-of select="$datum"/>
         </xsl:when>
         <xsl:when test="$vorhanden-role-ausgeschrieben">
            <xsl:value-of select="normalize-space($role-ausgeschrieben)"/>
         </xsl:when>
         <xsl:when test="$vorhanden-datum">
            <xsl:value-of select="$datum"/>
         </xsl:when>
      </xsl:choose>
      <xsl:if test="$vorhanden-typ or $vorhanden-role-ausgeschrieben or $vorhanden-datum">
         <xsl:text>{]}</xsl:text>
      </xsl:if>
   </xsl:function>
   <xsl:function name="foo:indexstring-ohne-raute-und-pmb" as="xs:string">
      <xsl:param name="first" as="xs:string"/>
      <xsl:choose>
         <xsl:when test="contains($first, '#pmb')">
            <xsl:value-of select="replace($first, '#pmb', '')"/>
         </xsl:when>
         <xsl:when test="contains($first, 'pmb')">
            <xsl:value-of select="replace($first, 'pmb', '')"/>
         </xsl:when>
         <xsl:when test="contains($first, '#pmb')">
            <xsl:value-of select="replace($first, '#pmb', '')"/>
         </xsl:when>
         <xsl:otherwise>
            <xsl:value-of select="$first"/>
         </xsl:otherwise>
      </xsl:choose>
   </xsl:function>
   <xsl:function name="foo:werk-in-index">
      <xsl:param name="first" as="xs:string"/>
      <xsl:param name="endung" as="xs:string"/>
      <xsl:param name="author-zaehler" as="xs:integer"/>
      <xsl:variable name="work-entry" select="key('work-lookup', $first, $works)[1]"/>
      <xsl:choose>
         <xsl:when test="$first = '' or empty($first)">
            <xsl:text>\textcolor{red}{\textsuperscript{\textbf{KEY}}}</xsl:text>
         </xsl:when>
         <xsl:when test="not(starts-with($first, '#pmb'))">
            <xsl:text>\textcolor{red}{FEHLER2}</xsl:text>
         </xsl:when>
         <xsl:when test="empty($work-entry)">
            <xsl:text>\textcolor{red}{XXXX}</xsl:text>
         </xsl:when>
         <xsl:when test="$work-entry[contains(note[@type = 'work_kind'], 'Tageszeitung')]">
            <!-- Tageszeitungen zum Ort -->
            <xsl:text>\pwindex{</xsl:text>
            <xsl:variable name="ort"
               select="concat('#pmb', key('placework-lookup', foo:indexstring-ohne-raute-und-pmb($first), $placework)/related_place)"/>
            <xsl:variable name="ort-name"
               select="key('place-lookup', $ort, $places)/placeName[1]/text()" as="xs:string?"/>
            <xsl:choose>
               <xsl:when test="$ort-name = '' or not($ort-name)">
                  <xsl:variable name="eintrag"
                     select="fn:escape-html-uri(concat('https://pmb.acdh.oeaw.ac.at/apis/entities/tei/place/', foo:indexstring-ohne-raute-und-pmb($ort)))"
                     as="xs:string"/>
                  <xsl:value-of
                     select="foo:index-sortiert(document($eintrag)/place/placeName[1]/text(), 'bf')"
                  />
               </xsl:when>
               <xsl:otherwise>
                  <xsl:value-of select="foo:index-sortiert($ort-name, 'bf')"/>
               </xsl:otherwise>
            </xsl:choose>
            <xsl:text>!</xsl:text>
         </xsl:when>
         <xsl:when test="$work-entry[contains(note[@type = 'work_kind'], 'Publikationsorgan')]">
            <!-- Zeitschriften bekommen keinen Autor- oder Hrsg. Name -->
            <xsl:text>\pwindex{</xsl:text>
         </xsl:when>
         <xsl:when test="$work-entry/author[$author-zaehler]">
            <xsl:text>\pwindex{</xsl:text>
            <xsl:variable name="author-ref" as="xs:string">
               <xsl:choose>
                  <xsl:when test="$work-entry/author[$author-zaehler]/@ref">
                     <xsl:value-of
                        select="replace($work-entry/author[$author-zaehler]/@ref, 'pmb', '#pmb')"/>
                  </xsl:when>
                  <xsl:otherwise>
                     <xsl:text>XXXX3 AUTHORREF</xsl:text>
                  </xsl:otherwise>
               </xsl:choose>
            </xsl:variable>
            <xsl:value-of select="foo:person-fuer-index($author-ref)"/>
            <xsl:text>!</xsl:text>
         </xsl:when>
         <xsl:when test="not($work-entry/author)">
            <xsl:text>\pwindex{</xsl:text>
            <xsl:text>?? Werk@Nicht ermittelte Verfasserinnen und Verfasser!</xsl:text>
         </xsl:when>
         <xsl:otherwise>
            <xsl:text>\pwindex{</xsl:text>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="foo:werk-kuerzen($work-entry/title[1])"/>
      <xsl:variable name="werk-datum-ohne-pmb-iso-zusatz">
         <xsl:choose>
            <xsl:when test="contains($work-entry/date[1], '&lt;')">
               <xsl:value-of select="substring-before($work-entry/date[1], '&lt;')"/>
            </xsl:when>
            <xsl:otherwise>
               <xsl:value-of select="$work-entry/date[1]"/>
            </xsl:otherwise>
         </xsl:choose>
      </xsl:variable>
      <xsl:choose>
         <xsl:when
            test="empty($werk-datum-ohne-pmb-iso-zusatz) or $werk-datum-ohne-pmb-iso-zusatz = ''"/>
         <xsl:otherwise>
            <xsl:choose>
               <xsl:when test="contains($werk-datum-ohne-pmb-iso-zusatz[1], ' – ')">
                  <xsl:variable name="datum1">
                     <xsl:value-of
                        select="foo:date-translate(substring-before($werk-datum-ohne-pmb-iso-zusatz[1], ' – '))"
                     />
                  </xsl:variable>
                  <xsl:variable name="datum2">
                     <xsl:value-of
                        select="foo:date-translate(substring-after($werk-datum-ohne-pmb-iso-zusatz[1], ' – '))"
                     />
                  </xsl:variable>
                  <xsl:choose>
                     <xsl:when test="string-length($datum1) = 4 or string-length($datum2) = 4">
                        <xsl:value-of select="concat($datum1, '–', $datum2)"/>
                        <xsl:text>–</xsl:text>
                     </xsl:when>
                     <xsl:otherwise>
                        <xsl:value-of select="concat($datum1, '–', $datum2)"/>
                        <xsl:text> – </xsl:text>
                     </xsl:otherwise>
                  </xsl:choose>
               </xsl:when>
               <xsl:otherwise>
                  <xsl:value-of select="foo:date-translate($werk-datum-ohne-pmb-iso-zusatz[1])"/>
               </xsl:otherwise>
            </xsl:choose>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:choose>
         <xsl:when
            test="$work-entry[contains(note[@type = 'work_kind'], 'Tageszeitung')] or $work-entry[contains(note[@type = 'work_kind'], 'Publikationsorgan')]">
            <xsl:text>@\emph{</xsl:text>
         </xsl:when>
         <xsl:when test="$work-entry/author and not($author-zaehler = 0)">
            <xsl:text>@\strich\emph{</xsl:text>
         </xsl:when>
         <xsl:otherwise>
            <xsl:text>@\emph{</xsl:text>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:choose>
         <xsl:when
            test="$work-entry/author/@xml:id = 'A002003' and contains($work-entry/title[1], 'O. V.:')">
            <xsl:apply-templates
               select="normalize-space(substring(foo:sonderzeichen-ersetzen($work-entry/title[1]), 9))"
            />
         </xsl:when>
         <xsl:otherwise>
            <xsl:apply-templates
               select="normalize-space(foo:sonderzeichen-ersetzen($work-entry/title[1]))"/>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:text>}</xsl:text>
      <xsl:if test="not($work-entry[contains(note[@type = 'work_kind'], 'Publikationsorgan')])">
         <xsl:variable name="datum" select="foo:date-translate($work-entry[1]/date[1]/text())"
            as="xs:string?"/>
         <xsl:value-of
            select="foo:werk-metadaten-in-index($work-entry/Typ, $datum, $work-entry/author[$author-zaehler]/@role)"
         />
      </xsl:if>
      <xsl:value-of select="$endung"/>
   </xsl:function>
   <xsl:function name="foo:org-in-index">
      <xsl:param name="first" as="xs:string"/>
      <xsl:param name="endung" as="xs:string"/>
      <xsl:variable name="org-entry" select="key('org-lookup', ($first), $orgs)"/>
      <xsl:variable name="typ" select="$org-entry/*:desc[@type = 'entity_type'][1]"/>
      <xsl:choose>
         <xsl:when test="string-length($org-entry/*:orgName[1]) = 0">
            <xsl:text>\textcolor{red}{XXXX ORGangabe fehlt}</xsl:text>
         </xsl:when>
         <xsl:when test="$first = ''">
            <xsl:text>\textcolor{red}{ORGNR INHALT FEHLT}</xsl:text>
         </xsl:when>
         <xsl:when test="not($org-entry/*:location[@type = 'located_in_place']) or ($org-entry/*:desc[@type='entity_type'][1]/. ='Verlag') or
            contains($org-entry/*:desc[@type='entity_type'][1]/. , 'Zeitschrift') or contains($org-entry/*:desc[@type='entity_type'][1]/. , 'Wochenschrift') or
            contains($org-entry/*:desc[@type='entity_type'][1]/. , 'Monatsschrift')">
            <xsl:text>\orgindex{</xsl:text>
            <xsl:value-of
               select="foo:index-sortiert(normalize-space($org-entry/*:orgName[1]), 'up')"/>
            <xsl:value-of select="$endung"/>
         </xsl:when>
         <xsl:when
            test="$org-entry/*:location[@type = 'located_in_place'] and $org-entry/*:desc[@type = 'entity_type'][contains(., 'Tageszeitungsr')]">
            <!-- Tageszeitungen werden
         nur am 1. Ort ausgegeben-->
            <xsl:variable name="ort" select="$org-entry/*:location[@type = 'located_in_place'][1]" as="node()"/>
            <xsl:variable name="entitytype" select="$ort/*:desc[@type='entity_type_id']/text()" as="text()"/>
            <xsl:text>\orgindex{</xsl:text>
            <xsl:choose>
               <!--<xsl:when
                  test="not(foo:wienerBezirke($org-entry/*:location[1]/placeName/@ref) = 'keinBezirk')">
                  <xsl:value-of select="foo:index-sortiert('Wien', 'bf')"/>
                  <xsl:text>!</xsl:text>
                  <xsl:value-of select="foo:wienerBezirke($org-entry/*:location[1]/placeName/@ref)"/>
                  <xsl:value-of
                     select="foo:index-sortiert($org-entry/*:location[1]/placeName, 'bf')"/>
                  <xsl:text>!</xsl:text>
               </xsl:when>-->
               <xsl:when test="$ort/*:placeName/@ref = 'pmb50'">
                  <xsl:value-of select="foo:index-sortiert('Wien', 'bf')"/>
                  <xsl:text>!</xsl:text>
               </xsl:when>
               <xsl:when test="$entitytype = '1418' or $entitytype ='1419' or $entitytype='14' or $entitytype='1412' or $entitytype ='1103' or
                  $entitytype ='1415'">
                  <xsl:value-of
                     select="foo:index-sortiert($org-entry/*:location[1]/placeName, 'bf')"/>
                  <xsl:text>!</xsl:text>
               </xsl:when>
            </xsl:choose>
            <xsl:value-of select="foo:index-sortiert($org-entry/orgName[1], 'up')"/>
            <xsl:value-of select="$endung"/>
         </xsl:when>
         
         <xsl:when test="$org-entry/*:location[@type = 'located_in_place']">
            <xsl:for-each select="$org-entry/*:location[@type = 'located_in_place']">
               <xsl:text>\orgindex{</xsl:text>
               <xsl:variable name="ort" select="$org-entry/*:location[@type = 'located_in_place'][1]" as="node()"/>
               <xsl:variable name="entitytype" select="$ort/*:desc[@type='entity_type_id']/text()" as="text()?"/>
               <xsl:choose>
                  <xsl:when test="not(foo:wienerBezirke(placeName/@ref) = 'keinBezirk')">
                     <xsl:value-of select="foo:index-sortiert('Wien', 'bf')"/>
                     <xsl:text>!</xsl:text>
                     <xsl:value-of select="foo:wienerBezirke(placeName/@ref)"/>
                     <xsl:value-of select="foo:index-sortiert(placeName, 'bf')"/>
                     <xsl:text>!</xsl:text>
                  </xsl:when>
                  <xsl:when test="placeName/@ref = '#pmb50'">
                     <xsl:value-of select="foo:index-sortiert('Wien', 'bf')"/>
                     <xsl:text>!</xsl:text>
                  </xsl:when>
                  <xsl:when test="$entitytype = '1418' or $entitytype ='1419' or $entitytype='14' or $entitytype='1412' or $entitytype ='1103' or
                     $entitytype ='1415'">
                     <xsl:value-of
                        select="foo:index-sortiert($org-entry/*:location[1]/placeName, 'bf')"/>
                     <xsl:text>!</xsl:text>
                  </xsl:when>
                  <xsl:when test="
                        desc[@type = 'entity_type'] = 'Hauptstadt' or
                        desc[@type = 'entity_type'] = 'Gemeinde'
                        or desc[@type = 'entity_type'] = 'Besiedelter Ort' or desc[@type = 'entity_type'] = 'Ort'">
                     <xsl:value-of select="foo:index-sortiert(placeName, 'bf')"/>
                     <xsl:text>!</xsl:text>
                  </xsl:when>
               </xsl:choose>
               <xsl:value-of select="foo:index-sortiert($org-entry/orgName[1], 'up')"/>
               <xsl:value-of select="$endung"/>
            </xsl:for-each>
         </xsl:when>
         <xsl:otherwise>
            <xsl:text>SEXSEX XXXX</xsl:text>
         </xsl:otherwise>
      </xsl:choose>
   </xsl:function>
   <xsl:function name="foo:absatz-position-vorne">
      <xsl:param name="rend" as="xs:string"/>
      <xsl:choose>
         <xsl:when test="$rend = 'center'">
            <xsl:text>\centering{}</xsl:text>
         </xsl:when>
         <xsl:when test="$rend = 'right'">
            <xsl:text>\raggedleft{}</xsl:text>
         </xsl:when>
      </xsl:choose>
   </xsl:function>
   <xsl:function name="foo:absatz-position-hinten">
      <xsl:param name="rend" as="xs:string"/>
      <xsl:choose>
         <xsl:when test="$rend = 'center'">
            <xsl:text/>
         </xsl:when>
         <xsl:when test="$rend = 'right'">
            <xsl:text/>
         </xsl:when>
      </xsl:choose>
   </xsl:function>
   <!-- Dient dazu, in der Kopfzeile »März 1890« erscheinen zu lassen -->
   <xsl:function name="foo:Monatsname">
      <xsl:param name="monat" as="xs:string"/>
      <xsl:choose>
         <xsl:when test="$monat = '01'">
            <xsl:text>Januar </xsl:text>
         </xsl:when>
         <xsl:when test="$monat = '02'">
            <xsl:text>Februar </xsl:text>
         </xsl:when>
         <xsl:when test="$monat = '03'">
            <xsl:text>März </xsl:text>
         </xsl:when>
         <xsl:when test="$monat = '04'">
            <xsl:text>April </xsl:text>
         </xsl:when>
         <xsl:when test="$monat = '05'">
            <xsl:text>Mai </xsl:text>
         </xsl:when>
         <xsl:when test="$monat = '06'">
            <xsl:text>Juni </xsl:text>
         </xsl:when>
         <xsl:when test="$monat = '07'">
            <xsl:text>Juli </xsl:text>
         </xsl:when>
         <xsl:when test="$monat = '08'">
            <xsl:text>August </xsl:text>
         </xsl:when>
         <xsl:when test="$monat = '09'">
            <xsl:text>September </xsl:text>
         </xsl:when>
         <xsl:when test="$monat = '10'">
            <xsl:text>Oktober </xsl:text>
         </xsl:when>
         <xsl:when test="$monat = '11'">
            <xsl:text>November </xsl:text>
         </xsl:when>
         <xsl:when test="$monat = '12'">
            <xsl:text>Dezember </xsl:text>
         </xsl:when>
      </xsl:choose>
   </xsl:function>
   <!-- Dient dazu, in der Kopfzeile »März 1890« erscheinen zu lassen -->
   <xsl:function name="foo:monatUndJahrInKopfzeile">
      <xsl:param name="datum" as="xs:string"/>
      <xsl:variable name="monat" as="xs:string?" select="substring($datum, 5, 2)"/>
      <xsl:text>\lohead{\textsc{</xsl:text>
      <xsl:choose>
         <xsl:when test="$monat = '01'">
            <xsl:text>januar </xsl:text>
         </xsl:when>
         <xsl:when test="$monat = '02'">
            <xsl:text>februar </xsl:text>
         </xsl:when>
         <xsl:when test="$monat = '03'">
            <xsl:text>märz </xsl:text>
         </xsl:when>
         <xsl:when test="$monat = '04'">
            <xsl:text>april </xsl:text>
         </xsl:when>
         <xsl:when test="$monat = '05'">
            <xsl:text>mai </xsl:text>
         </xsl:when>
         <xsl:when test="$monat = '06'">
            <xsl:text>juni </xsl:text>
         </xsl:when>
         <xsl:when test="$monat = '07'">
            <xsl:text>juli </xsl:text>
         </xsl:when>
         <xsl:when test="$monat = '08'">
            <xsl:text>august </xsl:text>
         </xsl:when>
         <xsl:when test="$monat = '09'">
            <xsl:text>september </xsl:text>
         </xsl:when>
         <xsl:when test="$monat = '10'">
            <xsl:text>oktober </xsl:text>
         </xsl:when>
         <xsl:when test="$monat = '11'">
            <xsl:text>november </xsl:text>
         </xsl:when>
         <xsl:when test="$monat = '12'">
            <xsl:text>dezember </xsl:text>
         </xsl:when>
      </xsl:choose>
      <xsl:value-of select="substring($datum, 1, 4)"/>
      <xsl:text>}}</xsl:text>
   </xsl:function>
   <xsl:function name="foo:section-titel-token">
      <!-- Das gibt den Titel für das Inhaltsverzeichnis aus. Immer nach 55 Zeichen wird umgebrochen -->
      <xsl:param name="titel" as="xs:string"/>
      <xsl:param name="position" as="xs:integer"/>
      <xsl:param name="bereitsausgegeben" as="xs:integer"/>
      <xsl:choose>
         <xsl:when
            test="string-length(substring(substring-before($titel, tokenize($titel, ' ')[$position + 1]), $bereitsausgegeben)) &lt; 55">
            <xsl:value-of
               select="replace(replace(tokenize($titel, ' ')[$position], '\[', '{[}'), '\]', '{]}')"/>
            <xsl:choose>
               <xsl:when
                  test="not(tokenize($titel, ' ')[$position] = tokenize($titel, ' ')[last()])">
                  <xsl:text> </xsl:text>
                  <xsl:value-of
                     select="foo:section-titel-token($titel, $position + 1, $bereitsausgegeben)"/>
               </xsl:when>
            </xsl:choose>
         </xsl:when>
         <xsl:otherwise>
            <xsl:text>\\{}</xsl:text>
            <xsl:value-of
               select="replace(replace(tokenize($titel, ' ')[$position], '\[', '{[}'), '\]', '{]}')"/>
            <xsl:choose>
               <xsl:when
                  test="not(tokenize($titel, ' ')[$position] = tokenize($titel, ' ')[last()])">
                  <xsl:text> </xsl:text>
                  <xsl:value-of
                     select="foo:section-titel-token($titel, $position + 1, string-length(substring-before($titel, tokenize($titel, ' ')[$position + 1])))"
                  />
               </xsl:when>
            </xsl:choose>
         </xsl:otherwise>
      </xsl:choose>
   </xsl:function>
   <xsl:function name="foo:sectionInToc">
      <xsl:param name="titel" as="xs:string"/>
      <xsl:param name="counter" as="xs:integer"/>
      <xsl:param name="gesamt" as="xs:integer"/>
      <xsl:variable name="titelminusdatum" as="xs:string"
         select="substring-before(normalize-space($titel), tokenize(normalize-space($titel), ',')[last()])"/>
      <xsl:variable name="datum" as="xs:string"
         select="tokenize(normalize-space($titel), ', ')[last()]"/>
      <xsl:value-of select="replace(replace($titelminusdatum, '\[', '{[}'), '\]', '{]}')"/>
      <!--<xsl:value-of select="foo:section-titel-token($titelminusdatum,1,0)"/>-->
      <xsl:text> </xsl:text>
      <xsl:value-of select="foo:date-translate($datum)"/>
      <!-- </xsl:otherwise>
       </xsl:choose>-->
   </xsl:function>
   <xsl:function name="foo:latexAnhang">
      <xsl:param name="nur-eine-id-fuer-unique-labels" as="xs:string"/>
      <xsl:text>&#10;\setcounter{secnumdepth}{-\maxdimen}</xsl:text>
      <xsl:text>&#10;\rehead{\textsc{anhang}}</xsl:text>
      <xsl:text>&#10;\renewcommand*{\partpagestyle}{empty}</xsl:text>
      <xsl:text>&#10;\renewcommand*{\raggedsection}{% &#10;\CenteringLeftskip=1cm plus 1em\relax &#10;\CenteringRightskip=1cm plus 1em\relax &#10;\Centering }</xsl:text>
      <xsl:text>&#10;\cleardoublepage\part*{Anhang}\cleardoublepage</xsl:text>
      <xsl:text>&#10;\addtocontents{toc}{% &#10;\protect\contentsline{part}{Anhang}}</xsl:text>
      <xsl:text>&#10;\clearpage </xsl:text>
      <xsl:text>&#10;\setcounter{footnote}{0}</xsl:text>
      <xsl:text>&#10;\counterwithout{footnote}{chapter}</xsl:text>
      <xsl:text>&#10;\addtokomafont{section}{\normalsize\normalsize\centering\textit}</xsl:text>
      <xsl:text>&#10;\small</xsl:text>
      <xsl:text>&#10;\addchap{Quellennachweis und Erläuterungen}</xsl:text>
      <xsl:value-of select="concat('\label{annex_', $nur-eine-id-fuer-unique-labels, '}')"/>
      <xsl:text>&#10;\lohead{\textsc{quellennachweis und erläuterungen}}</xsl:text>
      <xsl:text>&#10;\noindent{}</xsl:text>
      <xsl:text>&#10;\begin{description}[font=\normalsize\upshape, labelwidth=3.4em, itemsep=0em,leftmargin=2.4em]</xsl:text>
      <!--<xsl:text>\item[\symstandort]{Standort im Archiv}</xsl:text>-->
      <xsl:text>&#10;\item[\symweiteredrucke]{Weitere Drucke}</xsl:text>
      <xsl:text>&#10;\item[\symhead]{Biografische Zeugnisse}</xsl:text>
      <xsl:text>&#10;\end{description}</xsl:text>
      <xsl:text>&#10;\bigskip</xsl:text>
      <xsl:text>&#10;\setlength{\parindent}{0em}</xsl:text>
      <xsl:text>&#10;\doendnotes{C}\setcounter{alte-seitenzahl-vor-neuen-titelseiten}{\value{page}}</xsl:text>
      <xsl:text>&#10;\addtokomafont{section}{\normalsize\normalsize\centering}</xsl:text>
      <xsl:text>&#10;\normalsize</xsl:text>
      <xsl:text>&#10;\lohead{}</xsl:text>
      <xsl:text>&#10;\setlength{\parindent}{1em}</xsl:text>
      <!--<xsl:text>&#10;\renewcommand{\partpagestyle}{\partpagestylesave}</xsl:text>-->
   </xsl:function>
   <!-- HAUPT -->
   <xsl:template match="root">
      <root>
         <!-- Einbinden der Titelseite -->
         <xsl:text>\setlength{\voffset}{0cm}</xsl:text>
         <xsl:text>\setlength{\hoffset}{0cm}</xsl:text>
         <xsl:text>\setcounter{secnumdepth}{\sectionnumdepth}</xsl:text>
         <xsl:text>\includepdf[pages=1-3]{asi-titelseiten/verlag_titeleien_band1.pdf}</xsl:text>
         <xsl:text>\includepdf[pages={4}]{asi-titelseiten/asi-titelseiten.pdf}</xsl:text>
         <xsl:text>\setlength{\voffset}{\originalVOffset}</xsl:text>
         <xsl:text>\setlength{\hoffset}{\originalHOffset}</xsl:text>
         <!--<xsl:apply-templates select="TEI[@id = 'E_toDo']"/>-->
         <xsl:text>&#10;\ihead{}</xsl:text>
         <xsl:text>&#10;\sloppy</xsl:text>
         <xsl:text>&#10;\idxlayout{columns=1, itemlayout=relhang,hangindent=1em, subindent=1em, subsubindent=2em, justific=RaggedRight, indentunit=1em, totoc=true, unbalanced=true}</xsl:text>
         <xsl:text>\setindexprenote{\small\noindent In Abwandlung eines Sachregisters werden die tatsächlichen und mutmaßlichen Fragen
         verzeichnet, auf die Schnitzler in seinen Interviews antwortet 
         oder zumindest zu antworten scheint. Verwandte Fragen wurden
         teilweise verallgemeinert, um Variationen derselben Frage 
         zu vermeiden.\enlargethispage{-1em}}</xsl:text>
         <xsl:text>&#10;\normalsize{}</xsl:text>
         
         <xsl:text>&#10;\part*{Interviews}\cleardoublepage </xsl:text>
         <!--<xsl:text>\addcontentsline{toc}{part}{Interviews}</xsl:text>-->
         <xsl:text>&#10;\addtocontents{toc}{%
  \protect\contentsline{part}{Interviews}}</xsl:text>
         <xsl:text>&#10;\counterwithin*{footnote}{section}</xsl:text>
         <!-- keine Seitenzahl im Inhaltsverzeichnis -->
         <xsl:apply-templates select="TEI[starts-with(@id, 'I')]"/>
         <xsl:value-of select="foo:latexAnhang('I')"/>
         <xsl:text>&#10;\lohead{\textsc{1937}}\clearpage</xsl:text>
         <xsl:text>&#10;\footnotesize</xsl:text>
<xsl:text>&#10;\lohead{\textsc{fragen}}</xsl:text>         
         <xsl:text>&#10;\printindex[question]</xsl:text>
         <xsl:text>&#10;\normalsize</xsl:text>
         <!--<xsl:text>&#10;\cleardoubleevenpage</xsl:text>
         <xsl:text>&#10;\ihead{}</xsl:text>
         <xsl:text>&#10;\setlength{\voffset}{0cm}</xsl:text>
         <xsl:text>&#10;\setlength{\hoffset}{0cm}</xsl:text>
         <xsl:text>&#10;\setcounter{page}{0}</xsl:text>
         <xsl:text>&#10;\renewcommand*{\raggedsection}{% &#10;\CenteringLeftskip=1cm plus 1em\relax &#10;\CenteringRightskip=1cm plus 1em\relax}</xsl:text>
         <xsl:text>&#10;\setcounter{secnumdepth}{\sectionnumdepth}</xsl:text>
         <xsl:text>&#10;\includepdf[pages=5-8]{asi-titelseiten/asi-titelseiten.pdf}</xsl:text>
         <xsl:text>&#10;\setlength{\voffset}{\originalVOffset}</xsl:text>
         <xsl:text>&#10;\setlength{\hoffset}{\originalHOffset}</xsl:text>
         <xsl:text>&#10;\setcounter{page}{\value{alte-seitenzahl-vor-neuen-titelseiten}+1}</xsl:text>
         <xsl:text>&#10;\counterwithin*{footnote}{section}</xsl:text>-->
         <xsl:text>&#10;\addtocontents{toc}{% &#10;\protect\contentsline{part}{Meinungen}}</xsl:text>
         <!-- keine Seitenzahl im Inhaltsverzeichnis -->
         <xsl:text>&#10;\cleardoublepage\part*{Meinungen} </xsl:text>
         <xsl:text>&#10;\cleardoublepage </xsl:text>
         <xsl:apply-templates select="TEI[starts-with(@id, 'M')]"/>
         <xsl:text>&#10;\addtocontents{toc}{% &#10;\protect\contentsline{part}{Proteste}}</xsl:text>
         <!-- keine Seitenzahl im Inhaltsverzeichnis -->
         <xsl:text>&#10;\cleardoublepage\part*{Proteste} </xsl:text>
         <xsl:text>&#10;\cleardoublepage </xsl:text>
         <xsl:apply-templates select="TEI[starts-with(@id, 'P')]"/>
         <xsl:text>&#10;\makeatletter
         </xsl:text><xsl:text>&#10;\makeatother </xsl:text>
         <xsl:value-of select="foo:latexAnhang('P')"/>
         <xsl:text>&#10;\lohead{\textsc{1931}}\clearpage</xsl:text>
         <xsl:text>&#10;\deffootnote[1.5em]{1.5em}{1.5em}{\textsuperscript{\thefootnotemark}\enskip}</xsl:text>
         <!--<xsl:text>\backmatter</xsl:text>-->
         <!-- <xsl:text>\addtocontents{toc}{%
  \protect\contentsline{part}{Anhang}}</xsl:text>
         <xsl:text>\renewcommand*{\raggedsection}{%
 \CenteringLeftskip=1cm plus 1em\relax 
 \CenteringRightskip=1cm plus 1em\relax 
 \Centering }</xsl:text>
         <xsl:text>\setcounter{secnumdepth}{-\maxdimen}</xsl:text>
         <xsl:text>\rehead{\textsc{anhang}}</xsl:text>-->
         <xsl:text>&#10;\normalsize </xsl:text>
         
         <xsl:apply-templates select="TEI[@id = 'E_textauswahl']"/>
         <xsl:apply-templates select="TEI[@id = 'E_editorisch']"/>
         <xsl:text>\small
         </xsl:text>
         <xsl:apply-templates select="TEI[@id = 'E_literatur']"/>
         <!-- Herausgebereingriffe-->
         
         <xsl:text>&#10;\renewcommand{\printnpnum}[1]{\textbf{\printnpnumSave{#1}}}</xsl:text>
         <xsl:text>&#10;\addchap{Emendationen}\lohead{\textsc{emendationen}}\mylabel{E_texteingriffe}</xsl:text>
         <xsl:text>&#10;\renewcommand{\printnpnum}{\printnpnumSave}</xsl:text>
<xsl:text>&#10;\Xendbeforepagenumber{}</xsl:text>
<xsl:text>&#10;\Xendboxlinenum[A]{0em}</xsl:text>
<xsl:text>&#10;\Xendhangindent[A]{4em}</xsl:text>
<xsl:text>&#10;\Xendlemmafont[A]{\normalfont}</xsl:text>
<xsl:text>&#10;\Xendlemmaseparator{$\rbracket$}</xsl:text>
<xsl:text>&#10;\Xendlineprefixmore[A]{\footnotesize}</xsl:text>
<xsl:text>&#10;\Xendlineprefixsingle[A]{\footnotesize}</xsl:text>
<xsl:text>&#10;\Xendnotefontsize[A]{\footnotesize}</xsl:text>
<xsl:text>&#10;\Xendnotenumfont[A]{\footnotesize}</xsl:text>
<xsl:text>&#10;\Xendparagraph[A]</xsl:text>
<xsl:text>&#10;\Xendsep{}</xsl:text>
<xsl:text>&#10;\Xendbeforepagenumber{\bfseries}</xsl:text>
<xsl:text></xsl:text>&#10;\Xendafterpagenumber{\normalfont,\,}
         <xsl:text>&#10;\noindent Es folgen die vorgenommenen Eingriffe in den ursprünglichen Text unter Angabe von fett gedruckter Seitenzahl und Zeilennummer. 
            Als Lemma gesetzt sind die emendierten, rechts davon die ursprünglichen Fassungen. Kommentare sind in eckige Klammern gefügt.\par
            &#10;\bigskip\small
            &#10;\noindent\doendnotes{A}
         </xsl:text>
         <xsl:text>\normalsize</xsl:text>
         <!--<xsl:text>\lohead{\textsc{nachwort}}</xsl:text>-->
         <xsl:apply-templates select="TEI[@id = 'E_nachwort']"/>
         <xsl:text>\newpage</xsl:text>
         <xsl:apply-templates select="TEI[@id = 'E_danksagung']"/>
         <xsl:text>\newpage
         </xsl:text>
         <!-- Entfernt Seitenzahlen der Parts -->
         <xsl:text>\lohead{\textsc{inhalt}}</xsl:text>
         <xsl:text>\small</xsl:text>
         <xsl:text>\tableofcontents{}</xsl:text>
      </root>
   </xsl:template>
   <xsl:template match="TEI[starts-with(@id, 'E_')]">
      <root>
         <xsl:text>&#10;\addchap{</xsl:text>
         <xsl:value-of
            select="normalize-space(teiHeader[1]/fileDesc[1]/titleStmt[1]/title[@level = 'a'])"/>
         <xsl:text>}</xsl:text>
         <xsl:text>\lohead{\textsc{</xsl:text>
         <xsl:value-of
            select="lower-case(descendant::titleStmt/title[@level = 'a']/fn:normalize-space(.))"/>
         <xsl:text>}}</xsl:text>
         <xsl:text>\mylabel{</xsl:text>
         <xsl:value-of select="concat(foo:umlaute-entfernen(@id), 'v')"/>
         <xsl:text>}</xsl:text>
         <xsl:apply-templates select="text"/>
         <xsl:text>\mylabel{</xsl:text>
         <xsl:value-of select="concat(foo:umlaute-entfernen(@id), 'h')"/>
         <xsl:text>}</xsl:text>
         <xsl:text>\vspace{0.4em}</xsl:text>
      </root>
   </xsl:template>
   <xsl:template match="TEI[not(starts-with(@id, 'E_'))]">
      <xsl:choose>
         <xsl:when test="@latex = '\vspace*{1em} \enlargethispage{-1em}'">
            <xsl:text>\vspace*{1em} \enlargethispage{-1em} </xsl:text>
         </xsl:when>
         <xsl:when test="@latex">
            <xsl:value-of select="concat('{', @latex, '}')"/>
            <xsl:text>&#10;</xsl:text>
         </xsl:when>
      </xsl:choose>
      <xsl:variable name="jahr-davor" as="xs:string"
         select="substring(preceding-sibling::TEI[1]/@when, 1, 4)"/>
      <xsl:variable name="correspAction-date">
         <!-- Datum für die Sortierung -->
         <xsl:choose>
            <xsl:when test="descendant::correspDesc/correspAction[@type = 'sent']">
               <xsl:variable name="correspDate"
                  select="descendant::correspDesc/correspAction[@type = 'sent']/date"/>
               <xsl:choose>
                  <xsl:when test="@when">
                     <xsl:value-of select="@when"/>
                  </xsl:when>
                  <xsl:when test="@from">
                     <xsl:value-of select="@from"/>
                  </xsl:when>
                  <xsl:when test="@notBefore">
                     <xsl:value-of select="@notBefore"/>
                  </xsl:when>
                  <xsl:when test="@to">
                     <xsl:value-of select="@to"/>
                  </xsl:when>
                  <xsl:when test="@notAfter">
                     <xsl:value-of select="@notAfter"/>
                  </xsl:when>
                  <xsl:otherwise>
                     <xsl:text>XXXX Datumsproblem in correspDesc</xsl:text>
                  </xsl:otherwise>
               </xsl:choose>
            </xsl:when>
            <xsl:when test="descendant::sourceDesc[1]/listWit/witness">
               <xsl:choose>
                  <xsl:when test="descendant::sourceDesc[1]/listWit/witness//date/@when">
                     <xsl:value-of select="descendant::sourceDesc[1]/listWit/witness//date/@when"/>
                  </xsl:when>
                  <xsl:otherwise>
                     <xsl:text>XXXX Datumsproblem beim Archivzeugen</xsl:text>
                  </xsl:otherwise>
               </xsl:choose>
            </xsl:when>
            <xsl:when test="descendant::sourceDesc[1]/listBibl[1]//origDate[1]/@when">
               <xsl:value-of select="descendant::sourceDesc[1]/listBibl[1]//origDate[1]/@when"/>
            </xsl:when>
            <xsl:when test="descendant::sourceDesc[1]/listBibl[1]/biblStruct[1]/date/@when">
               <xsl:value-of select="descendant::sourceDesc[1]/listBibl[1]/biblStruct[1]/date/@when"
               />
            </xsl:when>
            <xsl:otherwise>
               <xsl:text>XXXX Datumsproblem </xsl:text>
            </xsl:otherwise>
         </xsl:choose>
      </xsl:variable>
      <xsl:variable name="dokument-id" select="@id"/>
      <xsl:variable name="dokument-typ" select="substring($dokument-id, 1,1)"/>
      <xsl:choose>
         <xsl:when
            test="$dokument-typ= 'I' and substring(@when, 1, 4) != $jahr-davor">
            <xsl:text>&#10;\addchap*{</xsl:text>
            <xsl:value-of select="substring(@when, 1, 4)"/>
            <xsl:text>}</xsl:text>
            <xsl:text>\rehead{\textsc{interviews}}\lohead{\textsc{</xsl:text>
            <xsl:value-of select="substring(@when, 1, 4)"/>
            <xsl:text>}}</xsl:text>
         </xsl:when>
         <xsl:when
            test="$dokument-typ = 'M' and substring(@when, 1, 4) != $jahr-davor">
            <xsl:text>&#10;\addchap*{</xsl:text>
            <xsl:value-of select="substring(@when, 1, 4)"/>
            <xsl:text>}</xsl:text>
            <xsl:text>\rehead{\textsc{meinungen}}\lohead{\textsc{</xsl:text>
            <xsl:value-of select="substring(@when, 1, 4)"/>
            <xsl:text>}}</xsl:text>
            
         </xsl:when>
         <xsl:when test="substring(@when, 1, 4) != $jahr-davor">
            <xsl:text>&#10;\addchap*{</xsl:text>
            <!-- before: \leavevmode -->
            <xsl:value-of select="substring(@when, 1, 4)"/>
            <xsl:text>}</xsl:text>
            <xsl:text>\rehead{\textsc{proteste}}\lohead{\textsc{</xsl:text>
            <xsl:value-of select="substring(@when, 1, 4)"/>
            <xsl:text>}}</xsl:text>
            
         </xsl:when>
      </xsl:choose>
      <xsl:choose>
         <xsl:when test="starts-with($dokument-id, 'E_')">
            <!-- Herausgeber*innentext -->
            
            <xsl:text>&#10;\addchap{</xsl:text>
            <!-- zuvor: \leavevmode -->
            <xsl:value-of
               select="normalize-space(teiHeader[1]/fileDesc[1]/titleStmt[1]/title[@level = 'a'])"/>
            <xsl:text>}</xsl:text>
         </xsl:when>
         <xsl:otherwise>
            <xsl:text>&#10;\section*</xsl:text>
            <xsl:text>{</xsl:text>
            <xsl:value-of select="count(preceding-sibling::TEI)"/>
            <xsl:text>.</xsl:text>
            <!--<xsl:value-of select="$dokument-id"/>-->
            <!-- HIER DER TITEL FÜR DIE ÜBERSCHRIFT AUSKOMMENTIERT 
                    <xsl:value-of
                     select="substring-before(teiHeader/fileDesc/titleStmt/title[@level = 'a'], tokenize(teiHeader/fileDesc/titleStmt/title[@level = 'a'], ',')[last()])"/>
                  <xsl:value-of
                     select="foo:date-translate(tokenize(teiHeader/fileDesc/titleStmt/title[@level = 'a'], ',')[last()])"
                  />-->
            <!-- Hier Entscheidung, ob Unveröffentlicht seitlich in der Marginalspalte steht -->
            <xsl:choose>
               <xsl:when test="descendant::listWit">
                  <xsl:choose>
                     <xsl:when test="ancestor::TEI/@id = 'M144'"/>
                     <!-- Eingriff für den Tschechow-Text, der wohl erschienen ist -->
                     <xsl:when test="not(descendant::listBibl[1][not(ancestor::back)])">
                        <xsl:text>\unveroeffentlicht</xsl:text>
                     </xsl:when>
                     <xsl:when test="descendant::listBibl[1][not(ancestor::back)]/biblStruct">
                        <xsl:variable name="zuLebzeiten"
                           select="descendant::listBibl[1][not(ancestor::back)]/biblStruct[1]/monogr[1]/imprint[1]/date[1]/substring(@when, 1, 4)"
                           as="xs:string?"/>
                        <xsl:if test="number($zuLebzeiten) &gt; 1932">
                           <xsl:text>\unveroeffentlicht</xsl:text>
                        </xsl:if>
                     </xsl:when>
                  </xsl:choose>
               </xsl:when>
               <xsl:when test="descendant::listBibl[not(ancestor::back)]">
                  <xsl:variable name="zuLebzeiten"
                     select="descendant::listBibl[1][not(ancestor::back)]/biblStruct[1]/monogr[1]/imprint[1]/date[1]/substring(@when, 1, 4)"
                     as="xs:string?"/>
                  <xsl:if test="number($zuLebzeiten) &gt; 1937">
                     <xsl:text>\unveroeffentlicht</xsl:text>
                  </xsl:if>
               </xsl:when>
            </xsl:choose>
            <xsl:text>}</xsl:text>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:variable name="preceding" select="count(preceding::TEI)"/>
      <xsl:text>\addcontentsline{toc}{chapter}{\makebox[</xsl:text>
      <xsl:choose>
         <xsl:when test="$preceding &lt; 95">
            <xsl:text>9pt</xsl:text>
         </xsl:when>
         <xsl:otherwise>
            <xsl:text>13.5pt</xsl:text>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:text>][r]{</xsl:text>
      <xsl:value-of select="$preceding"/>
      <xsl:text>}. </xsl:text>
      <xsl:value-of
         select="foo:sectionInToc(teiHeader/fileDesc/titleStmt/title[@level = 'a'], 0, count(contains(teiHeader/fileDesc/titleStmt/title[@level = 'a'], ',')))"/>
      <xsl:text>}</xsl:text>
      <xsl:text>\nopagebreak\mylabel{</xsl:text>
      <xsl:value-of select="concat($dokument-id, 'v')"/>
      <xsl:text>}\stepcounter{countcount}</xsl:text>
      <!-- Kopfzeilen -->
      <!--<xsl:text>\rehead{\textsc{</xsl:text>
      <xsl:choose>
         <xsl:when test="starts-with(@id, 'I')">
            <xsl:text>interviews</xsl:text>
         </xsl:when>
         <xsl:when test="starts-with(@id, 'P')">
            <xsl:text>proteste</xsl:text>
         </xsl:when>
         <xsl:when test="starts-with(@id, 'M')">
            <xsl:text>meinungen</xsl:text>
         </xsl:when>
      </xsl:choose>
      <xsl:value-of
         select="concat(key('person-lookup', (@bw), $persons)/forename, ' ', key('person-lookup', (@bw), $persons)/persName/surname)"/>
      <xsl:text>}}</xsl:text>-->
      <!--<xsl:value-of select="foo:monatUndJahrInKopfzeile(@when)"/>-->
      <xsl:apply-templates select="image"/>
      <xsl:apply-templates select="text"/>
      <xsl:if test="descendant::sourceDesc/listWit/witness[1] or descendant::sourceDesc[not(listWit)]/listBibl/biblStruct[1]">
         <xsl:text>\begin{footnotesize}</xsl:text>
         <xsl:choose>
            <xsl:when test="descendant::sourceDesc/listWit/witness[1]">
               <xsl:value-of
                  select="foo:witnessAlsSectionAnhang(descendant::sourceDesc/listWit/witness[1], true())"/>
            </xsl:when>
            <xsl:when test="descendant::sourceDesc[not(listWit)]/listBibl/biblStruct[1]">
               <xsl:value-of
                  select="foo:buchAlsSectionAnhang(descendant::sourceDesc[not(listWit)]/listBibl, true())"/>
            </xsl:when>
         </xsl:choose>
         <xsl:text>\end{footnotesize}</xsl:text>
      </xsl:if>
      <!--<xsl:if test="descendant::sourceDesc[not(listWit)]/listBibl/biblStruct[1]">
         <xsl:text>\begin{footnotesize}</xsl:text>
         <xsl:value-of
            select="foo:buchAlsSectionAnhang(descendant::sourceDesc[not(listWit)]/listBibl, true())"/>
         <xsl:text>\end{footnotesize}</xsl:text>
      </xsl:if>-->
      <xsl:text>\mylabel{</xsl:text>
      <xsl:value-of select="concat($dokument-id, 'h')"/>
      <xsl:text>}</xsl:text>
      <xsl:choose>
         <xsl:when test="not(descendant::revisionDesc/change[text() = 'Index check'])">
            <xsl:text>\begin{anhang}</xsl:text>
            <xsl:apply-templates select="teiHeader"/>
            <xsl:text>\subsection*{Index}</xsl:text>
            <xsl:text>\doendnotes{B}</xsl:text>
            <xsl:text>\end{anhang}</xsl:text>
         </xsl:when>
         <xsl:otherwise><xsl:apply-templates select="teiHeader"/></xsl:otherwise>
      </xsl:choose>
      <!-- Das hier setzt den Anhang ans Ende von Interviews und Proteste -->
      <!--  <xsl:variable name="id-typ" select="substring(@id, 1, 1)" as="xs:string"/>
      <xsl:choose>
         <xsl:when test="$id-typ = 'I' and following-sibling::TEI[1]/starts-with(@id, 'M')">
            <xsl:value-of select="foo:latexAnhang($id-typ)"/>
         </xsl:when>
         <xsl:when test="$id-typ = 'P' and not(following-sibling::TEI[1]/starts-with(@id, 'P'))">
            <xsl:value-of select="foo:latexAnhang($id-typ)"/>
         </xsl:when>
      </xsl:choose>-->
   </xsl:template>
   <xsl:template match="teiHeader">
      <xsl:apply-templates/>
   </xsl:template>
   <xsl:template match="origDate"/>
   <xsl:template match="text">
      <xsl:apply-templates/>
   </xsl:template>
   <xsl:template match="div[@type = 'biographical']"/>
   <xsl:template match="div[@type = 'biographical']" mode="fuer-anhang">
      <!-- Unter der Annahme, dass nur ein Archivzeuge oder Druck als Vorlage dient, kommt kein Abstand. Sonst schon -->
      <xsl:if
         test="ancestor::TEI[descendant::listWit and descendant::listBibl] or ancestor::TEI[descendant::listWit/witness[2]] or ancestor::TEI[descendant::listBibl/biblStruct[2]]"> </xsl:if>
      <xsl:text>{</xsl:text>
      <xsl:apply-templates select="div1"/>
      <xsl:text>}</xsl:text>
   </xsl:template>
   <xsl:template
      match="div[not(@type = 'biographical' or @type = 'image') and not(ancestor::TEI/starts-with(@id, 'E_'))]">
      <xsl:variable name="lunguage"
         select="ancestor::TEI[1]/teiHeader[1]/profileDesc[1]/langUsage[1]/language[1]" as="node()?"/>
      <xsl:variable name="language" as="xs:string">
         <xsl:choose>
            <xsl:when test="not(@lang)">
               <xsl:choose>
                  <xsl:when test="contains($lunguage[1]/@ident, '-')">
                     <xsl:value-of select="substring-before($lunguage[1]/@ident, '-')"/>
                  </xsl:when>
                  <xsl:when test="$lunguage/@ident">
                     <xsl:value-of select="$lunguage/@ident"/>
                  </xsl:when>
                  <xsl:otherwise>
                     <xsl:text>de</xsl:text>
                  </xsl:otherwise>
               </xsl:choose>
            </xsl:when>
            <xsl:when test="contains(@lang, '-')">
               <xsl:value-of select="substring-before(@lang, '-')"/>
            </xsl:when>
            <xsl:otherwise>
               <xsl:value-of select="@lang"/>
            </xsl:otherwise>
         </xsl:choose>
      </xsl:variable>
      <xsl:choose>
         <xsl:when test="@type = 'original' and following-sibling::div[@type = 'translation']">
            <xsl:text>&#10;\begin{pairs}\RaggedRight&#10;\begin{Leftside}\footnotesize </xsl:text>
         </xsl:when>
         <xsl:when test="@type = 'translation' and preceding-sibling::div[@type = 'original']">
            <xsl:text>\begin{pairs}\RaggedRight&#10;\begin{Rightside}\footnotesize </xsl:text>
         </xsl:when>
      </xsl:choose>
      <xsl:choose>
         <xsl:when test="$language = 'ru'">
            <xsl:text>\selectlanguage{russian}</xsl:text>
         </xsl:when>
         <xsl:when
            test="$language = 'de' and (@ana = 'alte-rechtschreibung' or $lunguage/@ana = 'alte-rechtschreibung')">
            <xsl:text>\selectlanguage{german}</xsl:text>
         </xsl:when>
         <xsl:when test="$language = 'de'">
            <xsl:text>\selectlanguage{ngerman}</xsl:text>
         </xsl:when>
         <xsl:when test="$language = 'en'">
            <xsl:text>\selectlanguage{english}\frenchspacing </xsl:text>
         </xsl:when>
         <xsl:when test="$language = 'fr'">
            <xsl:text>\selectlanguage{french} </xsl:text>
         </xsl:when>
         <xsl:when test="$language = 'it'">
            <xsl:text>\selectlanguage{italian}</xsl:text>
         </xsl:when>
         <xsl:when test="$language = 'hu'">
            <xsl:text>\selectlanguage{magyar}</xsl:text>
         </xsl:when>
         <xsl:when test="$language = 'dk'">
            <xsl:text>\selectlanguage{danish}</xsl:text>
         </xsl:when>
         <xsl:when test="$language = 'sv'">
            <xsl:text>\selectlanguage{swedish}</xsl:text>
         </xsl:when>
         <xsl:when test="$language = 'el'">
            <xsl:text>\selectlanguage{greek}</xsl:text>
         </xsl:when>
         <xsl:when test="$language = 'nl'">
            <xsl:text>\selectlanguage{dutch}</xsl:text>
         </xsl:when>
         <xsl:otherwise>
            <xsl:text>\textcolor{red}{XXXX SPRACHE ÜBERPRÜFEN}</xsl:text>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:text>&#10;\beginnumbering</xsl:text>
      <!-- Hier nun im Fall, dass wir im ersten div sind, die Archivsignaturen in den Anhang -->
      <xsl:if test="position() = 1 or (position() = 2 and preceding-sibling::div[@type = 'image'])">
         <xsl:variable name="quellen" as="node()"
            select="ancestor::TEI/teiHeader/fileDesc/sourceDesc"/>
         <xsl:variable name="titel" as="xs:string"
            select="ancestor::TEI/teiHeader/fileDesc/titleStmt/title[@level = 'a']"/>
         <xsl:variable name="titel-ohne-datum" as="xs:string"
            select="substring-before($titel, tokenize($titel, ',')[last()])"/>
         <xsl:variable name="datum" as="xs:string"
            select="substring(substring-after($titel, tokenize($titel, ',')[last() - 1]), 2)"/>
         <!-- Wenn es gedruckte und oder archivquellen gibt (bei ASI mehr als 1, sonst mehr als 0) ist die variable positiv -->
         <xsl:variable name="mehr-quellen" as="xs:boolean">
            <xsl:choose>
               <xsl:when test="$quellen/listBibl[1]/biblStruct[2]">
                  <xsl:value-of select="true()"/>
               </xsl:when>
               <xsl:when
                  test="ancestor::TEI/teiHeader/fileDesc/sourceDesc/listWit[1]/witness[1]/msDesc/physDesc/p">
                  <xsl:value-of select="true()"/>
               </xsl:when>
               <xsl:otherwise>
                  <xsl:value-of select="false()"/>
               </xsl:otherwise>
            </xsl:choose>
         </xsl:variable>
         <xsl:variable name="bibliographical-vorhanden" as="xs:boolean">
            <xsl:choose>
               <xsl:when test="parent::body/div[@type = 'biographical']">
                  <xsl:value-of select="true()"/>
               </xsl:when>
               <xsl:otherwise>
                  <xsl:value-of select="false()"/>
               </xsl:otherwise>
            </xsl:choose>
         </xsl:variable>
         <xsl:variable name="kommentar-vorhanden" as="xs:boolean">
            <!-- für asi, wo textconst anderswohin landet -->
            <xsl:choose>
               <xsl:when test="ancestor::body/descendant::note[@type = 'commentary'][1]">
                  <xsl:value-of select="true()"/>
               </xsl:when>
               <xsl:when test="ancestor::body/descendant::hi[@rend = 'underline' and (@n &gt; 2)]">
                  <xsl:value-of select="true()"/>
               </xsl:when>
               <xsl:otherwise>
                  <xsl:value-of select="false()"/>
               </xsl:otherwise>
            </xsl:choose>
            <!--Alternative, wenn es auch textConst im Kommentarbereich gibt <xsl:value-of select="descendant::note or descendant::hi[@rend = 'underline' and (@n &gt; 2)]"/>-->
         </xsl:variable>
         <xsl:variable name="physDesc-vorhanden" as="xs:boolean" >
            <xsl:choose>
               <xsl:when test="ancestor::TEI/teiHeader/fileDesc/sourceDesc/listWit[1]/witness[1]/msDesc/physDesc/p">
                  <xsl:value-of select="true()"/>
               </xsl:when>
               <xsl:otherwise>
                  <xsl:value-of select="false()"/>
               </xsl:otherwise>
            </xsl:choose>
         </xsl:variable>
         <!-- Das Folgende schreibt Titel in den Anhang zum Kommentar -->
         <!-- Zuerst mal Abstand, ob klein oder groß, je nachdem, ob Archivsignatur und Kommentar war -->
         <xsl:choose>
            <xsl:when
               test="ancestor::TEI/preceding-sibling::TEI[1]/teiHeader/fileDesc/sourceDesc/listBibl/biblStruct[1]/monogr/imprint/date/xs:integer(substring(@when, 1, 4)) &lt; 1935">
               <xsl:text>&#10;\toendnotes[C]{\flexvspace}</xsl:text>
            </xsl:when>
            <xsl:when
               test="ancestor::TEI/preceding-sibling::TEI[1]/teiHeader/fileDesc/sourceDesc/listWit">
               <xsl:text>&#10;\toendnotes[C]{\flexvspace}</xsl:text>
            </xsl:when>
            <xsl:when test="ancestor::TEI/preceding-sibling::TEI[1]/body//*[@subtype]">
               <xsl:text>&#10;\toendnotes[C]{\flexvspace}</xsl:text>
            </xsl:when>
            <xsl:when
               test="ancestor::TEI/preceding-sibling::TEI[1]/body//descendant::note[@type = 'commentary' or @type = 'textConst']">
               <xsl:text>&#10;\toendnotes[C]{\flexvspace}</xsl:text>
            </xsl:when>
            <xsl:when
               test="ancestor::TEI/preceding-sibling::TEI[1]/body//descendant::div[@type = 'biographical']">
               <xsl:text>&#10;\toendnotes[C]{\flexvspace}</xsl:text>
            </xsl:when>
            <xsl:otherwise>
               <xsl:text>&#10;\toendnotes[C]{\smallbreak\goodbreak}</xsl:text>
            </xsl:otherwise>
         </xsl:choose>
         <xsl:text>&#10;\anhangTitel{</xsl:text>
         <xsl:text>\myrangeref{</xsl:text>
         <xsl:value-of select="concat(ancestor::TEI/@id, 'v')"/>
         <xsl:text>}</xsl:text>
         <xsl:text>{</xsl:text>
         <xsl:value-of select="concat(ancestor::TEI/@id, 'h')"/>
         <xsl:text>}</xsl:text>
         <xsl:text>}{</xsl:text>
         <!--Einfügen des Dateinamens <xsl:value-of select="ancestor::TEI/@id"/>
         <xsl:text> </xsl:text>-->
         <xsl:value-of select="$titel-ohne-datum"/>
         <xsl:text> </xsl:text>
         <xsl:value-of select="foo:date-translate($datum)"/>
         <xsl:text>\nopagebreak}</xsl:text>
         <xsl:text>&#10;\datumImAnhang{</xsl:text>
         <xsl:choose>
            <xsl:when test="ancestor::TEI/@id='I024'">
               <xsl:text>\lohead{\textsc{s1909}}</xsl:text>
            </xsl:when>
            <xsl:when test="ancestor::TEI/@id='I014'">
               <xsl:text>\lohead{\textsc{s1921}}</xsl:text>
            </xsl:when>
            <xsl:when test="ancestor::TEI/@id='M110'">
               <xsl:text>\lohead{\textsc{s1920}}</xsl:text>
            </xsl:when>
            <xsl:when test="ancestor::TEI/@id='M169'">
               <xsl:text>\lohead{\textsc{1925}}</xsl:text>
            </xsl:when>
            <xsl:when test="ancestor::TEI/@id='M062'">
               <xsl:text>\lohead{\textsc{1925}}</xsl:text>
            </xsl:when>
            <xsl:when test="ancestor::TEI/@id='P123'">
               <xsl:text>\lohead{\textsc{1903}}</xsl:text>
            </xsl:when>
            <xsl:when test="ancestor::TEI/@id='P080'">
               <xsl:text>\lohead{\textsc{1913}}</xsl:text>
            </xsl:when>
            <xsl:otherwise>
               <xsl:value-of select="foo:monatUndJahrInKopfzeile(ancestor::TEI/@when)"/>
            </xsl:otherwise>
         </xsl:choose>
         <xsl:text>}</xsl:text>
         <xsl:if test="$kommentar-vorhanden or $mehr-quellen or $bibliographical-vorhanden or $physDesc-vorhanden">
            <!--<xsl:text>\toendnotes[C]{\unskip\nopagebreak[4]\smallbreak\nopagebreak[4]}</xsl:text>-->
            <xsl:text>&#10;\toendnotes[C]{\nopagebreak[4]}</xsl:text>
         </xsl:if>
         <!-- noch etwas näher zum Titel rutschen -->
         <!-- Zuerst die Archivsignaturen  -->
         <xsl:if test="ancestor::TEI/teiHeader/fileDesc/sourceDesc/listWit">
            <xsl:choose>
               <xsl:when test="count($quellen/listWit/witness) = 1">
                  <xsl:apply-templates select="$quellen/listWit/witness[1]"/>
               </xsl:when>
               <xsl:otherwise>
                  <xsl:apply-templates
                     select="foo:mehrere-witnesse(count($quellen/listWit/witness), count($quellen/listWit/witness), $quellen/listWit)"
                  />
               </xsl:otherwise>
            </xsl:choose>
         </xsl:if>
         <!-- Alternativ noch testen, ob es gedruckt wurde -->
         <xsl:if test="$quellen/listBibl">
            <xsl:choose>
               <!-- Gibt es kein listWit ist das erste biblStruct die Quelle -->
               <xsl:when
                  test="not(ancestor::TEI/teiHeader/fileDesc/sourceDesc/listWit) and $quellen/listBibl/biblStruct">
                  <xsl:value-of select="foo:buchAlsQuelle($quellen/listBibl, true())"/>
               </xsl:when>
               <xsl:otherwise>
                  <xsl:value-of select="foo:buchAlsQuelle($quellen/listBibl, false())"/>
               </xsl:otherwise>
            </xsl:choose>
         </xsl:if>
         <!-- Abstände zwischen Quellen, biographical und Kommentar -->
         <xsl:if test="($mehr-quellen or $physDesc-vorhanden) and $bibliographical-vorhanden">
            <xsl:text>&#10;\toendnotes[C]{\smallbreak}</xsl:text>
         </xsl:if>
         <xsl:if test="$bibliographical-vorhanden">
            <xsl:apply-templates select="following-sibling::div[@type = 'biographical']"
               mode="fuer-anhang"/>
         </xsl:if>
         <xsl:if test="$kommentar-vorhanden and ($mehr-quellen or $physDesc-vorhanden or $bibliographical-vorhanden)">
            <xsl:text>&#10;\toendnotes[C]{\smallbreak}</xsl:text>
         </xsl:if>
         
         <!--<xsl:choose>
            <xsl:when test="($mehr-quellen or $physDesc-vorhanden) and $bibliographical-vorhanden and $kommentar-vorhanden">
               
               
               <xsl:text>&#10;\toendnotes[C]{\smallbreak}</xsl:text>
            </xsl:when>
            <xsl:when test="($mehr-quellen or $physDesc-vorhanden) and $bibliographical-vorhanden">
               <xsl:text>&#10;\toendnotes[C]{\smallbreak}</xsl:text>
               <xsl:apply-templates select="following-sibling::div[@type = 'biographical']"
                  mode="fuer-anhang"/>
            </xsl:when>
            <xsl:when test="($mehr-quellen or $physDesc-vorhanden) and $kommentar-vorhanden">
               <xsl:text>&#10;\toendnotes[C]{\smallbreak}</xsl:text>
            </xsl:when>
            <xsl:when test="$bibliographical-vorhanden and $kommentar-vorhanden">
               <xsl:apply-templates select="following-sibling::div[@type = 'biographical']"
                  mode="fuer-anhang"/>
               <xsl:text>&#10;\toendnotes[C]{\smallbreak}</xsl:text>
            </xsl:when>
            <xsl:when test="$bibliographical-vorhanden">
               <xsl:apply-templates select="following-sibling::div[@type = 'biographical']"
                  mode="fuer-anhang"/>
            </xsl:when>
            <xsl:otherwise/>
         </xsl:choose>-->
      </xsl:if>
      <!-- Ende der Signaturen in den Anhang -->
      <xsl:choose>
         <xsl:when test="@type = 'writingSession' and ancestor::*[self::text[@type = 'dedication']]">
            <xsl:text>&#10;\centerline{\begin{minipage}{0.5\textwidth}</xsl:text>
            <xsl:apply-templates/>
            <xsl:text>&#10;\end{minipage}}</xsl:text>
         </xsl:when>
         <xsl:otherwise>
            <xsl:apply-templates/>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:text>&#10;\endnumbering</xsl:text>
      <xsl:choose>
         <xsl:when test="@type = 'original' and following-sibling::div[@type = 'translation']">
            <xsl:text>&#10;\normalsize\end{Leftside}\justifying
            \end{pairs}</xsl:text>
         </xsl:when>
         <xsl:when test="@type = 'translation' and preceding-sibling::div[@type = 'original']">
            <xsl:text>&#10;\normalsize\end{Rightside}\justifying
            \end{pairs}\Columns </xsl:text>
         </xsl:when>
      </xsl:choose>
      <xsl:if test="@language">
         <xsl:text>\selectlanguage{ngerman}</xsl:text>
      </xsl:if>
   </xsl:template>
   <xsl:template match="title"/>
   <xsl:template match="frame">
      <xsl:text>\begin{mdbar}</xsl:text>
      <xsl:apply-templates/>
      <xsl:text>\end{mdbar}</xsl:text>
   </xsl:template>
   <xsl:template match="funder"/>
   <xsl:template match="editionStmt"/>
   <xsl:template match="seriesStmt"/>
   <xsl:template match="publicationStmt"/>
   <xsl:function name="foo:witnesse-als-item">
      <xsl:param name="witness-count" as="xs:integer"/>
      <xsl:param name="witnesse" as="xs:integer"/>
      <xsl:param name="listWitnode" as="node()"/>
      <xsl:text>\item </xsl:text>
      <xsl:apply-templates select="$listWitnode/witness[$witness-count - $witnesse + 1]"/>
      <xsl:if test="$witnesse &gt; 1">
         <xsl:apply-templates
            select="foo:witnesse-als-item($witness-count, $witnesse - 1, $listWitnode)"/>
      </xsl:if>
   </xsl:function>
   <xsl:template match="sourceDesc"/>
   <xsl:template match="profileDesc"/>
   <xsl:function name="foo:briefsender-rekursiv">
      <xsl:param name="empfaenger" as="node()"/>
      <xsl:param name="empfaengernummer" as="xs:integer"/>
      <xsl:param name="sender-key" as="xs:string"/>
      <xsl:param name="date-sort" as="xs:integer"/>
      <xsl:param name="date-n" as="xs:integer"/>
      <xsl:param name="datum" as="xs:string"/>
      <xsl:param name="vorne" as="xs:boolean"/>
      <xsl:value-of
         select="foo:briefsenderindex($sender-key, $empfaenger/persName[$empfaengernummer]/@ref, $date-sort, $date-n, $datum, $vorne)"/>
      <xsl:if test="$empfaengernummer &gt; 1">
         <xsl:value-of
            select="foo:briefsender-rekursiv($empfaenger, $empfaengernummer - 1, $sender-key, $date-sort, $date-n, $datum, $vorne)"
         />
      </xsl:if>
   </xsl:function>
   <xsl:function name="foo:sender-empfaenger-in-personenindex-rekursiv">
      <xsl:param name="sender-empfaenger" as="node()"/>
      <xsl:param name="sender-nichtempfaenger" as="xs:boolean"/>
      <xsl:param name="nummer" as="xs:integer"/>
      <!--    <xsl:value-of select="foo:sender-empfaenger-in-personenindex($sender-empfaenger/persName[$nummer]/@ref, $sender-nichtempfaenger)"/>
      <xsl:if test="$nummer &gt; 1">
         <xsl:value-of select="foo:sender-empfaenger-in-personenindex-rekursiv($sender-empfaenger, $sender-nichtempfaenger, $nummer - 1)"/>
      </xsl:if>-->
   </xsl:function>
   <xsl:function name="foo:sender-empfaenger-in-personenindex">
      <xsl:param name="sender-key" as="xs:string"/>
      <xsl:param name="sender-nichtempfaenger" as="xs:boolean"/>
      <xsl:choose>
         <!-- Briefsender fett in den Personenindex -->
         <xsl:when test="not($sender-key = '#pmb2121')">
            <!-- Schnitzler und Bahr nicht -->
            <xsl:text>\pwindex{</xsl:text>
            <xsl:value-of select="foo:person-fuer-index($sender-key)"/>
            <xsl:choose>
               <xsl:when test="$sender-nichtempfaenger = true()">
                  <xsl:text>|pws</xsl:text>
               </xsl:when>
               <xsl:when test="$sender-nichtempfaenger = false()">
                  <xsl:text>|pwe</xsl:text>
               </xsl:when>
            </xsl:choose>
            <xsl:text>}</xsl:text>
         </xsl:when>
      </xsl:choose>
   </xsl:function>
   <xsl:function name="foo:briefsenderindex">
      <xsl:param name="sender-key" as="xs:string"/>
      <xsl:param name="empfaenger-key" as="xs:string"/>
      <xsl:param name="date-sort" as="xs:integer"/>
      <xsl:param name="date-n" as="xs:integer"/>
      <xsl:param name="datum" as="xs:string"/>
      <xsl:param name="vorne" as="xs:boolean"/>
      <xsl:text>\briefsenderindex{</xsl:text>
      <xsl:value-of
         select="foo:index-sortiert(concat(normalize-space(key('person-lookup', ($sender-key), $persons)/tei:persName/tei:surname), ', ', normalize-space(key('person-lookup', ($sender-key), $persons)/tei:persName/tei:forename)), 'sc')"/>
      <xsl:text>!</xsl:text>
      <xsl:value-of
         select="foo:umlaute-entfernen(concat(normalize-space(key('person-lookup', ($empfaenger-key), $persons)/tei:persName/tei:surname), ', ', normalize-space(key('person-lookup', ($empfaenger-key), $persons)/tei:persName/tei:forename)))"/>
      <xsl:text>@\emph{an </xsl:text>
      <xsl:value-of
         select="concat(normalize-space(key('person-lookup', ($empfaenger-key), $persons)/tei:persName/tei:forename), ' ', normalize-space(key('person-lookup', ($empfaenger-key), $persons)/tei:persName/tei:surname))"/>
      <xsl:text>}!</xsl:text>
      <xsl:value-of select="$date-sort"/>
      <xsl:value-of select="$date-n"/>
      <xsl:text>@{</xsl:text>
      <xsl:value-of select="foo:date-translate($datum)"/>
      <xsl:text>}</xsl:text>
      <xsl:value-of select="foo:vorne-hinten($vorne)"/>
      <xsl:text>bs}</xsl:text>
   </xsl:function>
   <xsl:function name="foo:briefempfaenger-rekursiv">
      <xsl:param name="sender" as="node()"/>
      <xsl:param name="sendernummer" as="xs:integer"/>
      <xsl:param name="empfaenger-key" as="xs:string"/>
      <xsl:param name="date-sort" as="xs:integer"/>
      <xsl:param name="date-n" as="xs:integer"/>
      <xsl:param name="datum" as="xs:string"/>
      <xsl:param name="vorne" as="xs:boolean"/>
      <xsl:value-of
         select="foo:briefempfaengerindex($empfaenger-key, $sender/persName[$sendernummer]/@ref, $date-sort, $date-n, $datum, $vorne)"/>
      <xsl:if test="$sendernummer &gt; 1">
         <xsl:value-of
            select="foo:briefempfaenger-rekursiv($sender, $sendernummer - 1, $empfaenger-key, $date-sort, $date-n, $datum, $vorne)"
         />
      </xsl:if>
   </xsl:function>
   <xsl:function name="foo:briefempfaengerindex">
      <xsl:param name="empfaenger-key" as="xs:string"/>
      <xsl:param name="sender-key" as="xs:string"/>
      <xsl:param name="date-sort" as="xs:integer"/>
      <xsl:param name="date-n" as="xs:integer"/>
      <xsl:param name="datum" as="xs:string"/>
      <xsl:param name="vorne" as="xs:boolean"/>
      <xsl:text>\briefempfaengerindex{</xsl:text>
      <xsl:value-of
         select="foo:index-sortiert(concat(normalize-space(key('person-lookup', ($empfaenger-key), $persons)/tei:persName/tei:surname), ', ', normalize-space(key('person-lookup', ($empfaenger-key), $persons)/tei:persName/tei:forename)), 'sc')"/>
      <xsl:text>!zzz</xsl:text>
      <xsl:value-of
         select="foo:umlaute-entfernen(concat(normalize-space(key('person-lookup', ($sender-key), $persons)/tei:persName/tei:surname), ', ', normalize-space(key('person-lookup', ($sender-key), $persons)/tei:persName/tei:forename)))"/>
      <xsl:text>@\emph{von </xsl:text>
      <xsl:choose>
         <!-- Sonderregel für Hofmannsthal sen. -->
         <xsl:when
            test="ends-with(key('person-lookup', $sender-key, $persons)/tei:persName/tei:forename, ' (sen.)')">
            <xsl:value-of
               select="concat(substring-before(normalize-space(key('person-lookup', ($sender-key), $persons)/tei:persName/tei:forename), ' (sen.)'), ' ', normalize-space(key('person-lookup', ($sender-key), $persons)/tei:persName/tei:surname))"/>
            <xsl:text> (sen.)</xsl:text>
         </xsl:when>
         <xsl:otherwise>
            <xsl:value-of
               select="concat(normalize-space(key('person-lookup', ($sender-key), $persons)/tei:persName/tei:forename), ' ', normalize-space(key('person-lookup', ($sender-key), $persons)/tei:persName/tei:surname))"
            />
         </xsl:otherwise>
      </xsl:choose>
      <xsl:text>}</xsl:text>
      <!--Das hier würde das Datum der Korrespondenzstücke der Briefempfänger einfügen. Momentan nur der Name-->
      <xsl:text>!</xsl:text>
      <xsl:value-of select="$date-sort"/>
      <xsl:value-of select="$date-n"/>
      <xsl:text>@{</xsl:text>
      <xsl:value-of select="foo:date-translate($datum)"/>
      <xsl:text>}</xsl:text>
      <xsl:value-of select="foo:vorne-hinten($vorne)"/>
      <xsl:text>be}</xsl:text>
   </xsl:function>
   <xsl:template match="msIdentifier/country"/>
   <xsl:template match="incident">
      <xsl:apply-templates select="desc"/>
   </xsl:template>
   <xsl:template match="additions">
      <xsl:apply-templates select="incident[@type = 'supplement']"/>
      <xsl:apply-templates select="incident[@type = 'postal']"/>
      <xsl:apply-templates select="incident[@type = 'receiver']"/>
      <xsl:apply-templates select="incident[@type = 'archival']"/>
      <xsl:apply-templates select="incident[@type = 'additional-information']"/>
      <xsl:apply-templates select="incident[@type = 'editorial']"/>
   </xsl:template>
   <xsl:template match="incident[@type = 'supplement']/desc">
      <xsl:variable name="poschitzion"
         select="count(parent::incident/preceding-sibling::incident[@type = 'supplement'])"/>
      <xsl:choose>
         <xsl:when test="$poschitzion &gt; 0">
            <xsl:value-of select="$poschitzion + 1"/>
            <xsl:text>)&#160;</xsl:text>
            <xsl:apply-templates/>
         </xsl:when>
         <xsl:when
            test="$poschitzion = 0 and not(parent::incident/following-sibling::incident[@type = 'supplement'])">
            <xsl:text>\newline{}Beilage: </xsl:text>
            <xsl:apply-templates/>
            <xsl:text> </xsl:text>
         </xsl:when>
         <xsl:when
            test="$poschitzion = 0 and parent::incident/following-sibling::incident[@type = 'supplement']">
            <xsl:text>\newline{}Beilagen: </xsl:text>
            <xsl:value-of select="$poschitzion + 1"/>
            <xsl:text>)&#160;</xsl:text>
            <xsl:apply-templates/>
            <xsl:text> </xsl:text>
         </xsl:when>
      </xsl:choose>
   </xsl:template>
   <xsl:template match="desc[parent::incident[@type = 'postal']]">
      <xsl:variable name="poschitzion"
         select="count(parent::incident/preceding-sibling::incident[@type = 'postal'])"/>
      <xsl:choose>
         <xsl:when test="$poschitzion &gt; 0">
            <xsl:value-of select="$poschitzion + 1"/>
            <xsl:text>)&#160;</xsl:text>
            <xsl:apply-templates/>
         </xsl:when>
         <xsl:when
            test="$poschitzion = 0 and not(parent::incident/following-sibling::incident[@type = 'postal'])">
            <xsl:text>\newline{}Versand: </xsl:text>
            <xsl:apply-templates/>
            <xsl:text> </xsl:text>
         </xsl:when>
         <xsl:when
            test="$poschitzion = 0 and parent::incident/following-sibling::incident[@type = 'postal']">
            <xsl:text>\newline{}Versand: </xsl:text>
            <xsl:value-of select="$poschitzion + 1"/>
            <xsl:text>)&#160;</xsl:text>
            <xsl:apply-templates/>
            <xsl:text> </xsl:text>
         </xsl:when>
      </xsl:choose>
   </xsl:template>
   <xsl:template match="incident[@type = 'receiver']/desc">
      <xsl:variable name="receiver"
         select="substring-before(ancestor::teiHeader//correspDesc/correspAction[@type = 'received']/persName[1], ',')"/>
      <xsl:variable name="poschitzion"
         select="count(parent::incident/preceding-sibling::incident[@type = 'receiver'])"/>
      <xsl:choose>
         <xsl:when test="$poschitzion &gt; 0">
            <xsl:value-of select="$poschitzion + 1"/>
            <xsl:text>)&#160;</xsl:text>
            <xsl:apply-templates/>
         </xsl:when>
         <xsl:when
            test="$poschitzion = 0 and parent::incident/following-sibling::incident[@type = 'receiver']">
            <xsl:text>
\newline{}</xsl:text>
            <xsl:value-of select="$receiver"/>
            <xsl:text>: </xsl:text>
            <xsl:value-of select="$poschitzion + 1"/>
            <xsl:text>)&#160;</xsl:text>
            <xsl:apply-templates/>
            <xsl:text> </xsl:text>
         </xsl:when>
         <xsl:otherwise>
            <xsl:text>
\newline{}</xsl:text>
            <xsl:value-of select="$receiver"/>
            <xsl:text>: </xsl:text>
            <xsl:apply-templates/>
            <xsl:text> </xsl:text>
         </xsl:otherwise>
      </xsl:choose>
   </xsl:template>
   <xsl:template match="desc[parent::incident[@type = 'archival']]">
      <xsl:variable name="poschitzion"
         select="count(parent::incident/preceding-sibling::incident[@type = 'archival'])"/>
      <xsl:choose>
         <xsl:when test="$poschitzion &gt; 0">
            <xsl:value-of select="$poschitzion + 1"/>
            <xsl:text>)&#160;</xsl:text>
            <xsl:apply-templates/>
         </xsl:when>
         <xsl:when
            test="$poschitzion = 0 and not(parent::incident/following-sibling::incident[@type = 'archival'])">
            <xsl:text>\newline{}Ordnung: </xsl:text>
            <xsl:apply-templates/>
            <xsl:text> </xsl:text>
         </xsl:when>
         <xsl:when
            test="$poschitzion = 0 and parent::incident/following-sibling::incident[@type = 'archival']">
            <xsl:text>\newline{}Ordnung: </xsl:text>
            <xsl:value-of select="$poschitzion + 1"/>
            <xsl:text>)&#160;</xsl:text>
            <xsl:apply-templates/>
            <xsl:text> </xsl:text>
         </xsl:when>
      </xsl:choose>
   </xsl:template>
   <xsl:template match="desc[parent::incident[@type = 'additional-information']]">
      <xsl:variable name="poschitzion"
         select="count(parent::incident/preceding-sibling::incident[@type = 'additional-information'])"/>
      <xsl:choose>
         <xsl:when test="$poschitzion &gt; 0">
            <xsl:value-of select="$poschitzion + 1"/>
            <xsl:text>)&#160;</xsl:text>
            <xsl:apply-templates/>
         </xsl:when>
         <xsl:when
            test="$poschitzion = 0 and not(parent::incident/following-sibling::incident[@type = 'additional-information'])">
            <xsl:text>\newline{}Zusatz: </xsl:text>
            <xsl:apply-templates/>
            <xsl:text> </xsl:text>
         </xsl:when>
         <xsl:when
            test="$poschitzion = 0 and parent::incident/following-sibling::incident[@type = 'additional-information']">
            <xsl:text>\newline{}Zusatz: </xsl:text>
            <xsl:value-of select="$poschitzion + 1"/>
            <xsl:text>)&#160;</xsl:text>
            <xsl:apply-templates/>
            <xsl:text> </xsl:text>
         </xsl:when>
      </xsl:choose>
   </xsl:template>
   <xsl:template match="desc[parent::incident[@type = 'editorial']]">
      <xsl:variable name="poschitzion"
         select="count(parent::incident/preceding-sibling::incident[@type = 'editorial'])"/>
      <xsl:choose>
         <xsl:when test="$poschitzion &gt; 0">
            <xsl:value-of select="$poschitzion + 1"/>
            <xsl:text>)&#160;</xsl:text>
            <xsl:apply-templates/>
         </xsl:when>
         <xsl:when
            test="$poschitzion = 0 and not(parent::incident/following-sibling::incident[@type = 'editorial'])">
            <xsl:text>\newline{}Editorischer Hinweis: </xsl:text>
            <xsl:apply-templates/>
            <xsl:text> </xsl:text>
         </xsl:when>
         <xsl:when
            test="$poschitzion = 0 and parent::incident/following-sibling::incident[@type = 'editorial']">
            <xsl:text>\newline{}Editorischer Hinweise: </xsl:text>
            <xsl:value-of select="$poschitzion + 1"/>
            <xsl:text>)&#160;</xsl:text>
            <xsl:apply-templates/>
            <xsl:text> </xsl:text>
         </xsl:when>
      </xsl:choose>
   </xsl:template>
   <xsl:template match="typeDesc">
      <xsl:apply-templates/>
   </xsl:template>
   <xsl:template match="typeDesc/p">
      <xsl:apply-templates/>
   </xsl:template>
   <xsl:template match="handDesc">
      <xsl:choose>
         <!-- Nur eine Handschrift, diese demnach vom Autor/der Autorin: -->
         <xsl:when
            test="not(child::handNote[2]) and (not(child::handNote/@corresp) or handNote[1]/@corresp = ancestor::TEI/teiHeader[1]/fileDesc[1]/titleStmt[1][not(child::author[2])]/author[1]/@ref)">
            <xsl:text>Handschrift: </xsl:text>
            <xsl:value-of select="foo:handNote(handNote)"/>
         </xsl:when>
         <!-- Der Hauptautor, aber mit mehr Schriften -->
         <xsl:when
            test="count(distinct-values(handNote/@corresp)) = 1 and handNote[1]/@corresp = ancestor::TEI/teiHeader[1]/fileDesc[1]/titleStmt[1][not(child::author[2])]/author[1]/@ref">
            <xsl:variable name="handDesc-v" select="current()"/>
            <xsl:for-each select="distinct-values(handNote/@corresp)">
               <xsl:variable name="corespi" select="."/>
               <xsl:text>Handschrift: </xsl:text>
               <xsl:choose>
                  <xsl:when test="count($handDesc-v/handNote[@corresp = $corespi]) = 1">
                     <xsl:value-of select="foo:handNote($handDesc-v/handNote[@corresp = $corespi])"
                     />
                  </xsl:when>
                  <xsl:otherwise>
                     <xsl:for-each select="$handDesc-v/handNote[@corresp = $corespi]">
                        <xsl:variable name="poschitzon" select="position()"/>
                        <xsl:value-of select="$poschitzon"/>
                        <xsl:text>)&#160;</xsl:text>
                        <xsl:value-of select="foo:handNote(current())"/>
                        <xsl:text>\hspace{1em}</xsl:text>
                     </xsl:for-each>
                  </xsl:otherwise>
               </xsl:choose>
               <xsl:if test="not(position() = last())">
                  <xsl:text>\newline{}</xsl:text>
               </xsl:if>
            </xsl:for-each>
         </xsl:when>
         <!-- Nur eine Handschrift, diese nicht vom Autor/der Autorin: -->
         <xsl:when test="not(child::handNote[2]) and (handNote/@corresp)">
            <xsl:text>Handschrift </xsl:text>
            <xsl:choose>
               <xsl:when test="handNote/@corresp = 'schreibkraft'">
                  <xsl:text>einer Schreibkraft: </xsl:text>
                  <xsl:value-of select="foo:handNote(handNote)"/>
               </xsl:when>
               <xsl:otherwise>
                  <xsl:variable name="corespi-name"
                     select="key('person-lookup', (handNote/@corresp), $persons)/persName"
                     as="node()?"/>
                  <xsl:value-of select="concat($corespi-name/forename, ' ', $corespi-name/surname)"/>
                  <xsl:text>: </xsl:text>
                  <xsl:value-of select="foo:handNote(handNote)"/>
               </xsl:otherwise>
            </xsl:choose>
         </xsl:when>
         <xsl:otherwise>
            <xsl:variable name="handDesc-v" select="current()"/>
            <xsl:for-each select="distinct-values(handNote/@corresp)">
               <xsl:variable name="corespi" select="."/>
               <xsl:variable name="corespi-name"
                  select="key('person-lookup', ($corespi), $persons)/persName" as="node()?"/>
               <xsl:text>Handschrift </xsl:text>
               <xsl:value-of select="concat($corespi-name/forename, ' ', $corespi-name/surname)"/>
               <xsl:text>: </xsl:text>
               <xsl:choose>
                  <xsl:when test="count($handDesc-v/handNote[@corresp = $corespi]) = 1">
                     <xsl:value-of select="foo:handNote($handDesc-v/handNote[@corresp = $corespi])"
                     />
                  </xsl:when>
                  <xsl:otherwise>
                     <xsl:for-each select="$handDesc-v/handNote[@corresp = $corespi]">
                        <xsl:variable name="poschitzon" select="position()"/>
                        <xsl:value-of select="$poschitzon"/>
                        <xsl:text>)&#160;</xsl:text>
                        <xsl:value-of select="foo:handNote(current())"/>
                        <xsl:text>\hspace{1em}</xsl:text>
                     </xsl:for-each>
                  </xsl:otherwise>
               </xsl:choose>
               <xsl:if test="not(position() = last())">
                  <xsl:text>\newline{}</xsl:text>
               </xsl:if>
            </xsl:for-each>
         </xsl:otherwise>
      </xsl:choose>
   </xsl:template>
   <xsl:function name="foo:handNote">
      <xsl:param name="entry" as="node()"/>
      <xsl:choose>
         <xsl:when test="$entry/@medium = 'bleistift'">
            <xsl:text>Bleistift</xsl:text>
         </xsl:when>
         <xsl:when test="$entry/@medium = 'roter_buntstift'">
            <xsl:text>roter Buntstift</xsl:text>
         </xsl:when>
         <xsl:when test="$entry/@medium = 'blauer_buntstift'">
            <xsl:text>blauer Buntstift</xsl:text>
         </xsl:when>
         <xsl:when test="$entry/@medium = 'gruener_buntstift'">
            <xsl:text>grüner Buntstift</xsl:text>
         </xsl:when>
         <xsl:when test="$entry/@medium = 'schwarze_tinte'">
            <xsl:text>schwarze Tinte</xsl:text>
         </xsl:when>
         <xsl:when test="$entry/@medium = 'blaue_tinte'">
            <xsl:text>blaue Tinte</xsl:text>
         </xsl:when>
         <xsl:when test="$entry/@medium = 'gruene_tinte'">
            <xsl:text>grüne Tinte</xsl:text>
         </xsl:when>
         <xsl:when test="$entry/@medium = 'rote_tinte'">
            <xsl:text>rote Tinte</xsl:text>
         </xsl:when>
         <xsl:when test="$entry/@medium = 'anderes'">
            <xsl:text>anderes Schreibmittel</xsl:text>
         </xsl:when>
      </xsl:choose>
      <xsl:if test="not($entry/@style = 'nicht_anzuwenden')">
         <xsl:text>, </xsl:text>
      </xsl:if>
      <xsl:choose>
         <xsl:when test="$entry/@style = 'deutsche-kurrent'">
            <xsl:text>deutsche Kurrent</xsl:text>
         </xsl:when>
         <xsl:when test="$entry/@style = 'lateinische-kurrent'">
            <xsl:text>lateinische Kurrent</xsl:text>
         </xsl:when>
         <xsl:when test="$entry/@style = 'gabelsberger'">
            <xsl:text>Gabelsberger Kurzschrift</xsl:text>
         </xsl:when>
      </xsl:choose>
      <xsl:if test="string-length(normalize-space($entry/.)) &gt; 1">
         <xsl:text> (</xsl:text>
         <xsl:apply-templates select="$entry"/>
         <xsl:text>)</xsl:text>
      </xsl:if>
   </xsl:function>
   <xsl:template match="objectDesc/desc[@type = '_blaetter']">
      <xsl:choose>
         <xsl:when test="parent::objectDesc/desc/@type = 'karte'">
            <xsl:choose>
               <xsl:when test="@n = '1'">
                  <xsl:value-of select="concat(@n, '&#160;Karte')"/>
               </xsl:when>
               <xsl:otherwise>
                  <xsl:value-of select="concat(@n, '&#160;Karten')"/>
               </xsl:otherwise>
            </xsl:choose>
         </xsl:when>
         <xsl:otherwise>
            <xsl:choose>
               <xsl:when test="@n = '1'">
                  <xsl:value-of select="concat(@n, '&#160;Blatt')"/>
               </xsl:when>
               <xsl:otherwise>
                  <xsl:value-of select="concat(@n, '&#160;Blätter')"/>
               </xsl:otherwise>
            </xsl:choose>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:if test="string-length(.) &gt; 1">
         <xsl:text> (</xsl:text>
         <xsl:value-of select="normalize-space(.)"/>
         <xsl:text>)</xsl:text>
      </xsl:if>
   </xsl:template>
   <xsl:template match="objectDesc/desc[@type = '_seiten']">
      <xsl:text>, </xsl:text>
      <xsl:choose>
         <xsl:when test="@n = '1'">
            <xsl:value-of select="concat(@n, '&#160;Seite')"/>
         </xsl:when>
         <xsl:otherwise>
            <xsl:value-of select="concat(@n, '&#160;Seiten')"/>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:if test="string-length(.) &gt; 1">
         <xsl:text> (</xsl:text>
         <xsl:value-of select="normalize-space(.)"/>
         <xsl:text>)</xsl:text>
      </xsl:if>
      <xsl:if
         test="preceding-sibling::desc[@type = 'umschlag' or @type = 'fragment' or @type = 'entwurf' or @type = 'reproduktion'] or following-sibling::desc[@type = 'umschlag' or @type = 'fragment' or @type = 'entwurf' or @type = 'reproduktion']">
         <xsl:text>, </xsl:text>
      </xsl:if>
   </xsl:template>
   <xsl:template match="objectDesc">
      <xsl:apply-templates select="
            desc[@type = 'karte' or @type = 'bild'
            or @type = 'kartenbrief'
            or @type = 'brief'
            or @type = 'telegramm'
            or @type = 'widmung'
            or @type = 'anderes']"/>
      <xsl:apply-templates select="desc[@type = '_blaetter']"/>
      <xsl:apply-templates select="desc[@type = '_seiten']"/>
      <xsl:apply-templates select="desc[@type = 'umschlag']"/>
      <xsl:apply-templates select="desc[@type = 'reproduktion']"/>
      <xsl:apply-templates select="desc[@type = 'entwurf']"/>
      <xsl:apply-templates select="desc[@type = 'fragment']"/>
   </xsl:template>
   <xsl:template match="objectDesc/desc[@type = 'karte']">
      <xsl:choose>
         <xsl:when test="string-length(normalize-space(.)) &gt; 1">
            <xsl:value-of select="normalize-space(.)"/>
         </xsl:when>
         <xsl:when test="@subtype = 'bildpostkarte'">
            <xsl:text>Bildpostkarte</xsl:text>
         </xsl:when>
         <xsl:when test="@subtype = 'postkarte'">
            <xsl:text>Postkarte</xsl:text>
         </xsl:when>
         <xsl:when test="@subtype = 'briefkarte'">
            <xsl:text>Briefkarte</xsl:text>
         </xsl:when>
         <xsl:when test="@subtype = 'visitenkarte'">
            <xsl:text>Visitenkarte</xsl:text>
         </xsl:when>
         <xsl:otherwise>
            <xsl:text>Karte</xsl:text>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:if
         test="(following-sibling::desc[@type = 'umschlag' or @type = 'fragment' or @type = 'reproduktion' or @type = 'entwurf' or @type = '_blaetter' or @type = '_seiten']) or (preceding-sibling::desc[@type = 'umschlag' or @type = 'fragment' or @type = 'reproduktion' or @type = 'entwurf' or @type = '_blaetter' or @type = '_seiten'])">
         <xsl:text>, </xsl:text>
      </xsl:if>
   </xsl:template>
   <xsl:template match="objectDesc/desc[@type = 'reproduktion']">
      <xsl:choose>
         <xsl:when test="string-length(normalize-space(.)) &gt; 1">
            <xsl:value-of select="normalize-space(.)"/>
         </xsl:when>
         <xsl:when test="@subtype = 'fotokopie'">
            <xsl:text>Fotokopie</xsl:text>
         </xsl:when>
         <xsl:when test="@subtype = 'fotografische_vervielfaeltigung'">
            <xsl:text>fotografische Vervielfältigung</xsl:text>
         </xsl:when>
         <xsl:when test="@subtype = 'ms_abschrift'">
            <xsl:text>maschinelle Abschrift</xsl:text>
         </xsl:when>
         <xsl:when test="@subtype = 'hs_abschrift'">
            <xsl:text>handschriftliche Abschrift</xsl:text>
         </xsl:when>
         <xsl:when test="@subtype = 'durchschlag'">
            <xsl:text>maschineller Durchschlag</xsl:text>
         </xsl:when>
         <xsl:otherwise>
            <xsl:text>Reproduktion</xsl:text>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:if
         test="(following-sibling::desc[@type = 'fragment' or @type = 'entwurf']) or (preceding-sibling::desc[@type = 'fragment' or @type = 'entwurf'])">
         <xsl:text>, </xsl:text>
      </xsl:if>
   </xsl:template>
   <xsl:template match="objectDesc/desc[@type = 'widmung']">
      <xsl:choose>
         <xsl:when test="string-length(normalize-space(.)) &gt; 1">
            <xsl:value-of select="normalize-space(.)"/>
         </xsl:when>
         <xsl:when test="@subtype = 'widmung_vorsatzblatt'">
            <xsl:text>Widmung am Vorsatzblatt</xsl:text>
         </xsl:when>
         <xsl:when test="@subtype = 'widmung_titelblatt'">
            <xsl:text>Widmung am Titelblatt</xsl:text>
         </xsl:when>
         <xsl:when test="@subtype = 'widmung_vortitel'">
            <xsl:text>Widmung am Vortitel</xsl:text>
         </xsl:when>
         <xsl:when test="@subtype = 'widmung_schmutztitel'">
            <xsl:text>Widmung am Schmutztitel</xsl:text>
         </xsl:when>
         <xsl:when test="@subtype = 'widmung_umschlag'">
            <xsl:text>Widmung am Umschlag</xsl:text>
         </xsl:when>
         <xsl:otherwise>
            <xsl:text>Widmung</xsl:text>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:if
         test="(following-sibling::desc[@type = 'umschlag' or @type = 'fragment' or @type = 'reproduktion' or @type = 'entwurf']) or (preceding-sibling::desc[@type = 'umschlag' or @type = 'fragment' or @type = 'reproduktion' or @type = 'entwurf'])">
         <xsl:text>, </xsl:text>
      </xsl:if>
   </xsl:template>
   <xsl:template match="objectDesc/desc[@type = 'brief']">
      <xsl:choose>
         <xsl:when test="string-length(normalize-space(.)) &gt; 1">
            <xsl:value-of select="normalize-space(.)"/>
         </xsl:when>
         <xsl:otherwise>
            <xsl:text>Brief</xsl:text>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:if
         test="(following-sibling::desc[@type = 'umschlag' or @type = 'fragment' or @type = 'reproduktion' or @type = 'entwurf' or @type = '_blaetter']) or (preceding-sibling::desc[@type = 'umschlag' or @type = 'fragment' or @type = 'reproduktion' or @type = 'entwurf' or @type = '_blaetter'])">
         <xsl:text>, </xsl:text>
      </xsl:if>
   </xsl:template>
   <xsl:template match="objectDesc/desc[@type = 'bild']">
      <xsl:choose>
         <xsl:when test="string-length(normalize-space(.)) &gt; 1">
            <xsl:value-of select="normalize-space(.)"/>
         </xsl:when>
         <xsl:when test="@subtype = 'fotografie'">
            <xsl:text>Fotografie</xsl:text>
         </xsl:when>
         <xsl:otherwise>
            <xsl:text>Bild</xsl:text>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:if
         test="(following-sibling::desc[@type = 'umschlag' or @type = 'fragment' or @type = 'reproduktion' or @type = 'entwurf']) or (preceding-sibling::desc[@type = 'umschlag' or @type = 'fragment' or @type = 'reproduktion' or @type = 'entwurf'])">
         <xsl:text>, </xsl:text>
      </xsl:if>
   </xsl:template>
   <xsl:template match="objectDesc/desc[@type = 'kartenbrief']">
      <xsl:choose>
         <xsl:when test="string-length(normalize-space(.)) &gt; 1">
            <xsl:value-of select="normalize-space(.)"/>
         </xsl:when>
         <xsl:otherwise>
            <xsl:text>Kartenbrief</xsl:text>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:if
         test="(following-sibling::desc[@type = 'umschlag' or @type = 'fragment' or @type = 'reproduktion' or @type = 'entwurf' or @type = '_blaetter' or @type = '_seiten']) or (preceding-sibling::desc[@type = 'umschlag' or @type = 'fragment' or @type = 'reproduktion' or @type = 'entwurf' or @type = '_blaetter' or @type = '_seiten'])">
         <xsl:text>, </xsl:text>
      </xsl:if>
   </xsl:template>
   <xsl:template match="objectDesc/desc[@type = 'umschlag']">
      <xsl:choose>
         <xsl:when test="string-length(normalize-space(.)) &gt; 1">
            <xsl:value-of select="normalize-space(.)"/>
         </xsl:when>
         <xsl:otherwise>
            <xsl:text>Umschlag</xsl:text>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:if
         test="(following-sibling::desc[@type = 'umschlag' or @type = 'fragment' or @type = 'reproduktion' or @type = 'entwurf']) or (preceding-sibling::desc[@type = 'umschlag' or @type = 'fragment' or @type = 'reproduktion' or @type = 'entwurf'])">
         <xsl:text>, </xsl:text>
      </xsl:if>
   </xsl:template>
   <xsl:template match="objectDesc/desc[@type = 'telegramm']">
      <xsl:choose>
         <xsl:when test="string-length(normalize-space(.)) &gt; 1">
            <xsl:value-of select="normalize-space(.)"/>
         </xsl:when>
         <xsl:otherwise>
            <xsl:text>Telegramm</xsl:text>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:if
         test="(following-sibling::desc[@type = 'umschlag' or @type = 'fragment' or @type = 'reproduktion' or @type = 'entwurf']) or (preceding-sibling::desc[@type = 'umschlag' or @type = 'fragment' or @type = 'reproduktion' or @type = 'entwurf'])">
         <xsl:text>, </xsl:text>
      </xsl:if>
   </xsl:template>
   <xsl:template match="objectDesc/desc[@type = 'anderes']">
      <xsl:choose>
         <xsl:when test="string-length(normalize-space(.)) &gt; 1">
            <xsl:value-of select="normalize-space(.)"/>
         </xsl:when>
         <xsl:otherwise>
            <xsl:text>XXXXAnderes</xsl:text>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:if
         test="(following-sibling::desc[@type = 'umschlag' or @type = 'fragment' or @type = 'reproduktion' or @type = 'entwurf']) or (preceding-sibling::desc[@type = 'umschlag' or @type = 'fragment' or @type = 'reproduktion' or @type = 'entwurf'])">
         <xsl:text>, </xsl:text>
      </xsl:if>
   </xsl:template>
   <xsl:template match="objectDesc/desc[@type = 'entwurf']">
      <xsl:choose>
         <xsl:when test="string-length(normalize-space(.)) &gt; 1">
            <xsl:value-of select="normalize-space(.)"/>
         </xsl:when>
         <xsl:otherwise>
            <xsl:text>Entwurf</xsl:text>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:if
         test="(following-sibling::desc[@type = 'fragment']) or (preceding-sibling::desc[@type = 'fragment'])">
         <xsl:text>, </xsl:text>
      </xsl:if>
   </xsl:template>
   <xsl:template match="objectDesc/desc[@type = 'fragment']">
      <xsl:choose>
         <xsl:when test="string-length(normalize-space(.)) &gt; 1">
            <xsl:value-of select="normalize-space(.)"/>
         </xsl:when>
         <xsl:otherwise>
            <xsl:text>Fragment</xsl:text>
         </xsl:otherwise>
      </xsl:choose>
   </xsl:template>
   <xsl:template match="objectDesc/desc[not(@type)]">
      <xsl:text>XXXX desc-Fehler</xsl:text>
   </xsl:template>
   <xsl:template match="physDesc">
      <xsl:text>
\physDesc{</xsl:text>
      <xsl:choose>
         <xsl:when
            test="child::objectDesc or child::typeDesc or child::handDesc or child::additions">
            <xsl:if test="objectDesc">
               <xsl:apply-templates select="objectDesc"/>
               <xsl:if test="typeDesc or handDesc">
                  <xsl:text>
\newline{}</xsl:text>
               </xsl:if>
            </xsl:if>
            <xsl:if test="typeDesc">
               <xsl:apply-templates select="typeDesc"/>
               <xsl:if test="handDesc">
                  <xsl:text>
\newline{}</xsl:text>
               </xsl:if>
            </xsl:if>
            <xsl:if test="handDesc">
               <xsl:apply-templates select="handDesc"/>
            </xsl:if>
            <xsl:if test="additions">
               <xsl:apply-templates select="additions"/>
            </xsl:if>
         </xsl:when>
         <xsl:when test="child::p">
            <xsl:apply-templates/>
         </xsl:when>
         <xsl:otherwise>
            <xsl:text>XXXX PHYSDESC FEHLER</xsl:text>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:text>}</xsl:text>
   </xsl:template>
   <xsl:template match="listBibl">
      <xsl:apply-templates/>
   </xsl:template>
   <xsl:template match="biblStruct">
      <xsl:apply-templates/>
   </xsl:template>
   <xsl:template match="monogr">
      <xsl:apply-templates/>
   </xsl:template>
   <xsl:template match="monogr/author">
      <xsl:apply-templates/>
      <xsl:text>: </xsl:text>
   </xsl:template>
   <xsl:template match="monogr/title[@level = 'm']">
      <xsl:apply-templates/>
      <xsl:text>. </xsl:text>
   </xsl:template>
   <xsl:template match="editor"/>
   <xsl:template match="biblScope[@unit = 'pp']">
      <xsl:text>, S.{\,}</xsl:text>
      <xsl:apply-templates/>
   </xsl:template>
   <xsl:template match="biblScope[@unit = 'col']">
      <xsl:text>, Sp.{\,}</xsl:text>
      <xsl:apply-templates/>
   </xsl:template>
   <xsl:template match="biblScope[@unit = 'vol']">
      <xsl:text>, Bd.{\,}</xsl:text>
      <xsl:apply-templates/>
   </xsl:template>
   <xsl:template match="biblScope[@unit = 'jg']">
      <xsl:text>, Jg.{\,}</xsl:text>
      <xsl:apply-templates/>
   </xsl:template>
   <xsl:template match="biblScope[@unit = 'nr']">
      <xsl:text>, Nr.{\,}</xsl:text>
      <xsl:apply-templates/>
   </xsl:template>
   <xsl:template match="biblScope[@unit = 'sec']">
      <xsl:text>, Sec.{\,}</xsl:text>
      <xsl:apply-templates/>
   </xsl:template>
   <xsl:template match="imprint/date">
      <xsl:text> </xsl:text>
      <xsl:apply-templates/>
   </xsl:template>
   <xsl:template match="imprint/pubPlace">
      <xsl:text> </xsl:text>
      <xsl:apply-templates/>
      <xsl:text>: </xsl:text>
   </xsl:template>
   <xsl:template match="imprint/publisher">
      <xsl:apply-templates/>
   </xsl:template>
   <xsl:template match="stamp">
      <xsl:text>Stempel: »\nobreak{}</xsl:text>
      <xsl:apply-templates/>
      <xsl:text>\nobreak{}«. </xsl:text>
   </xsl:template>
   <xsl:template match="time">
      <xsl:apply-templates/>
   </xsl:template>
   <xsl:template match="stamp/placeName | addSpan | stamp/date | stamp/time">
      <xsl:if test="current() != ''">
         <xsl:choose>
            <xsl:when test="self::placeName and @ref = '#pmb50'"/>
            <!-- Wien raus -->
            <xsl:when test="self::placeName and ((@ref = '') or empty(@ref))">
               <xsl:text>\textcolor{red}{\textsuperscript{\textbf{KEY}}}</xsl:text>
            </xsl:when>
            <xsl:when test="self::placeName">
               <xsl:variable name="endung" as="xs:string" select="'|pwk}'"/>
               <xsl:value-of
                  select="foo:indexName-Routine('place', tokenize(@ref, ' ')[1], substring-after(@ref, ' '), $endung)"
               />
            </xsl:when>
         </xsl:choose>
         <xsl:choose>
            <xsl:when test="self::date and not(child::*)">
               <xsl:value-of select="foo:date-translate(.)"/>
            </xsl:when>
            <xsl:otherwise>
               <xsl:apply-templates/>
            </xsl:otherwise>
         </xsl:choose>
         <xsl:choose>
            <xsl:when test="position() = last()">
               <xsl:if test="not(ends-with(self::*, '.'))">
                  <xsl:text>.</xsl:text>
               </xsl:if>
            </xsl:when>
            <xsl:otherwise>
               <xsl:text>, </xsl:text>
            </xsl:otherwise>
         </xsl:choose>
      </xsl:if>
   </xsl:template>
   <xsl:template match="dateSender/date"/>
   <!-- Autoren in den Index -->
   <xsl:template match="author[not(ancestor::biblStruct)]"/>
   <xsl:template match="correspDesc">
      <xsl:apply-templates/>
   </xsl:template>
   <xsl:template match="listWit">
      <xsl:apply-templates/>
   </xsl:template>
   <xsl:template match="witness">
      <xsl:apply-templates/>
   </xsl:template>
   <xsl:template match="msDesc">
      <xsl:apply-templates/>
   </xsl:template>
   <xsl:template match="witness[(fn:position()=1)]/msDesc[1]/msIdentifier"/>
   <xsl:template match="witness[not(fn:position()=1)]/msDesc[1]/msIdentifier"><!-- hier reingepfuscht,
   damit bei ASI der Standort vorne nach dem Text stehen kann-->
      <xsl:text>\Standort{</xsl:text>
      <xsl:apply-templates/>
      <!-- Kürzel für bestimmte Archive : -->
      <!--<xsl:choose>
         <xsl:when test="settlement = 'Cambridge'">
            <xsl:text>CUL, </xsl:text>
            <xsl:apply-templates select="idno"/>
         </xsl:when>
         <xsl:when test="repository = 'Theatermuseum'">
            <xsl:text>TMW, </xsl:text>
            <xsl:apply-templates select="idno"/>
         </xsl:when>
         <xsl:when test="repository = 'Deutsches Literaturarchiv'">
            <xsl:text>DLA, </xsl:text>
            <xsl:apply-templates select="idno"/>
         </xsl:when>
         <xsl:when test="repository = 'Beinecke Rare Book and Manuscript Library'">
            <xsl:text>YCGL, </xsl:text>
            <xsl:apply-templates select="idno"/>
         </xsl:when>
         <xsl:when test="repository = 'Freies Deutsches Hochstift'">
            <xsl:text>FDH, </xsl:text>
            <xsl:apply-templates select="idno"/>
         </xsl:when>
         <xsl:otherwise>
            <xsl:apply-templates/>
         </xsl:otherwise>
      </xsl:choose>-->
      <xsl:text>}</xsl:text>
   </xsl:template>
   <xsl:template match="msIdentifier/settlement">
      <xsl:choose>
         <xsl:when test="contains(parent::msIdentifier/repository, .)"/>
         <xsl:otherwise>
            <xsl:apply-templates/>
            <xsl:text>, </xsl:text>
         </xsl:otherwise>
      </xsl:choose>
   </xsl:template>
   <xsl:template match="msIdentifier/repository">
      <xsl:apply-templates/>
      <xsl:text>, </xsl:text>
   </xsl:template>
   <xsl:template match="msIdentifier/idno">
      <xsl:choose>
         <xsl:when test="starts-with(normalize-space(.), 'Yale Collection of German Literature, ')">
            <xsl:value-of
               select="fn:substring-after(normalize-space(.), 'Yale Collection of German Literature, ')"
            />
         </xsl:when>
         <xsl:otherwise>
            <xsl:value-of select="fn:normalize-space(.)"/>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:choose>
         <xsl:when test="ends-with(normalize-space(.), '.')"/>
         <xsl:otherwise>
            <xsl:text>.</xsl:text>
         </xsl:otherwise>
      </xsl:choose>
   </xsl:template>
   <xsl:template match="revisionDesc"/>
   <xsl:template match="change"/>
   <xsl:template match="front"/>
   <xsl:template match="back"/>
   <xsl:function name="foo:briefempfaenger-mehrere-persName-rekursiv">
      <xsl:param name="briefempfaenger" as="node()"/>
      <xsl:param name="briefempfaenger-anzahl" as="xs:integer"/>
      <xsl:param name="briefsender" as="node()"/>
      <xsl:param name="date" as="xs:integer"/>
      <xsl:param name="date-n" as="xs:integer"/>
      <xsl:param name="datum" as="xs:string"/>
      <xsl:param name="vorne" as="xs:boolean"/>
      <xsl:value-of
         select="foo:briefempfaenger-rekursiv($briefsender, count($briefsender/persName), $briefempfaenger/persName[$briefempfaenger-anzahl]/@ref, $date, $date-n, $datum, $vorne)"/>
      <xsl:if test="$briefempfaenger-anzahl &gt; 1">
         <xsl:value-of
            select="foo:briefempfaenger-mehrere-persName-rekursiv($briefempfaenger, $briefempfaenger-anzahl - 1, $briefsender, $date, $date-n, $datum, $vorne)"
         />
      </xsl:if>
   </xsl:function>
   <xsl:template match="date">
      <xsl:choose>
         <xsl:when test="child::*">
            <xsl:apply-templates/>
         </xsl:when>
         <xsl:otherwise>
            <xsl:value-of select="foo:date-translate(.)"/>
         </xsl:otherwise>
      </xsl:choose>
   </xsl:template>
   <!--<xsl:function name="foo:briefsender-mehrere-persName-rekursiv">
      <xsl:param name="briefsender" as="node()"/>
      <xsl:param name="briefsender-anzahl" as="xs:integer"/>
      <xsl:param name="briefempfaenger" as="node()"/>
      <xsl:param name="date" as="xs:integer"/>
      <xsl:param name="date-n" as="xs:integer"/>
      <xsl:param name="datum" as="xs:string"/>
      <xsl:param name="vorne" as="xs:boolean"/>
      <!-\- Briefe Schnitzlers an Bahr raus, aber wenn mehrere Absender diese rein -\->
      <!-\- <xsl:if test="not($briefsender/persName[$briefsender-anzahl]/@ref = '#pmb2121' and $briefempfaenger/persName[1]/@ref='#10815')">
      <xsl:value-of select="foo:briefsender-rekursiv($briefempfaenger, count($briefempfaenger/persName), $briefsender/persName[$briefsender-anzahl]/@ref, $date, $date-n, $datum, $vorne)"/>
     </xsl:if>-\->
      <xsl:if test="$briefsender-anzahl &gt; 1">
         <xsl:value-of
            select="foo:briefsender-mehrere-persName-rekursiv($briefsender, $briefsender-anzahl - 1, $briefempfaenger, $date, $date-n, $datum, $vorne)"
         />
      </xsl:if>
   </xsl:function>-->
   <xsl:function name="foo:seitenzahlen-ordnen">
      <xsl:param name="seitenzahl-vorne" as="xs:integer"/>
      <xsl:param name="seitenzahl-hinten" as="xs:integer"/>
      <xsl:value-of select="format-number($seitenzahl-vorne, '00000')"/>
      <xsl:text>–</xsl:text>
      <xsl:choose>
         <xsl:when test="empty($seitenzahl-hinten)">
            <xsl:text>00000</xsl:text>
         </xsl:when>
         <xsl:otherwise>
            <xsl:value-of select="format-number($seitenzahl-hinten, '00000')"/>
         </xsl:otherwise>
      </xsl:choose>
   </xsl:function>
   <xsl:function name="foo:quellen-titel-kuerzen">
      <xsl:param name="titel" as="xs:string"/>
      <xsl:choose>
         <xsl:when test="starts-with($titel, 'Tagebuch von Schnitzler')">
            <xsl:value-of select="replace($titel, 'Tagebuch von Schnitzler,', 'Eintrag vom')"/>
         </xsl:when>
         <xsl:when test="contains($titel, 'vor dem 21. 6. 1897')">
            <xsl:value-of select="replace($titel, 'Aufzeichnung von Bahr, ', 'Aufzeichnung, ')"/>
         </xsl:when>
         <xsl:when test="starts-with($titel, 'Tagebuch von Bahr')">
            <xsl:value-of select="replace($titel, 'Tagebuch von Bahr, ', 'Tagebucheintrag vom ')"/>
         </xsl:when>
         <xsl:when test="starts-with($titel, 'Bahr: ')">
            <xsl:value-of select="replace($titel, 'Bahr: ', '')"/>
         </xsl:when>
         <xsl:when test="starts-with($titel, 'Notizheft von Bahr: ')">
            <xsl:value-of select="replace($titel, 'Notizheft von Bahr: ', 'Notizheft, ')"/>
         </xsl:when>
         <xsl:when test="starts-with($titel, 'Kalendereintrag von Bahr, ')">
            <xsl:value-of
               select="replace($titel, 'Kalendereintrag von Bahr, ', 'Kalendereintrag, ')"/>
         </xsl:when>
         <xsl:when test="starts-with($titel, 'Aufzeichnung von Bahr')">
            <xsl:value-of select="replace($titel, 'Aufzeichnung von Bahr, ', 'Aufzeichnung, ')"/>
         </xsl:when>
         <xsl:when test="starts-with($titel, 'Olga Schnitzler: Spiegelbild der Freundschaft')">
            <xsl:value-of
               select="replace($titel, 'Olga Schnitzler: Spiegelbild der Freundschaft, ', '')"/>
         </xsl:when>
         <xsl:when test="starts-with($titel, 'Schnitzler: Leutnant Gustl. Äußere Schicksale,')">
            <xsl:value-of
               select="replace($titel, 'Schnitzler: Leutnant Gustl. Äußere Schicksale, ', 'Leutnant Gustl. Äußere Schicksale, ')"
            />
         </xsl:when>
         <xsl:when test="starts-with($titel, 'Brief an Bahr, Anfang Juli')">
            <xsl:value-of select="replace($titel, 'Schnitzler: ', '')"/>
         </xsl:when>
         <xsl:when test="contains($titel, 'Leseliste')">
            <xsl:value-of select="replace($titel, 'Schnitzler: ', '')"/>
         </xsl:when>
         <xsl:otherwise>
            <xsl:value-of select="$titel"/>
         </xsl:otherwise>
      </xsl:choose>
   </xsl:function>
   <xsl:template match="publisher[parent::bibl]">
      <xsl:text>\emph{</xsl:text>
      <xsl:apply-templates/>
      <xsl:text>}</xsl:text>
   </xsl:template>
   <xsl:template match="title[parent::bibl]">
      <xsl:text>\emph{</xsl:text>
      <xsl:apply-templates/>
      <xsl:text>}</xsl:text>
   </xsl:template>
   <xsl:function name="foo:imprint-in-index">
      <xsl:param name="monogr" as="node()"/>
      <xsl:variable name="imprint" as="node()" select="$monogr/imprint"/>
      <xsl:choose>
         <xsl:when test="$imprint/pubPlace != ''">
            <xsl:value-of select="$imprint/pubPlace" separator=", "/>
            <xsl:choose>
               <xsl:when test="$imprint/publisher != ''">
                  <xsl:text>: \emph{</xsl:text>
                  <xsl:value-of select="$imprint/publisher"/>
                  <xsl:text>}</xsl:text>
                  <xsl:choose>
                     <xsl:when test="$imprint/date != ''">
                        <xsl:text> </xsl:text>
                        <xsl:value-of select="$imprint/date"/>
                     </xsl:when>
                  </xsl:choose>
               </xsl:when>
               <xsl:when test="$imprint/date != ''">
                  <xsl:text>: </xsl:text>
                  <xsl:value-of select="$imprint/date"/>
               </xsl:when>
            </xsl:choose>
         </xsl:when>
         <xsl:otherwise>
            <xsl:choose>
               <xsl:when test="$imprint/publisher != ''">
                  <xsl:value-of select="$imprint/publisher"/>
                  <xsl:choose>
                     <xsl:when test="$imprint/date != ''">
                        <xsl:text> </xsl:text>
                        <xsl:value-of select="$imprint/date"/>
                     </xsl:when>
                  </xsl:choose>
               </xsl:when>
               <xsl:when test="$imprint/date != ''">
                  <xsl:text>(</xsl:text>
                  <xsl:value-of select="$imprint/date"/>
                  <xsl:text>)</xsl:text>
               </xsl:when>
            </xsl:choose>
         </xsl:otherwise>
      </xsl:choose>
   </xsl:function>
   <xsl:function name="foo:jg-bd-nr">
      <xsl:param name="monogr" as="node()"/>
      <!-- Ist Jahrgang vorhanden, stehts als erstes -->
      <xsl:if test="$monogr//biblScope[@unit = 'jg']">
         <xsl:text>, Jg.{\,}</xsl:text>
         <xsl:value-of select="$monogr//biblScope[@unit = 'jg']"/>
      </xsl:if>
      <!-- Ist Band vorhanden, stets auch -->
      <xsl:if test="$monogr//biblScope[@unit = 'vol']">
         <xsl:text>, Bd.{\,}</xsl:text>
         <xsl:value-of select="$monogr//biblScope[@unit = 'vol']"/>
      </xsl:if>
      <!-- Jetzt abfragen, wie viel vom Datum vorhanden: vier Stellen=Jahr, sechs Stellen: Jahr und Monat, acht Stellen: komplettes Datum
              Damit entscheidet sich, wo das Datum platziert wird, vor der Nr. oder danach, oder mit Komma am Schluss -->
      <xsl:choose>
         <xsl:when test="string-length($monogr/imprint/date/@when) = 4">
            <xsl:text> (</xsl:text>
            <xsl:value-of select="$monogr/imprint/date"/>
            <xsl:text>)</xsl:text>
            <xsl:if test="$monogr//biblScope[@unit = 'nr']">
               <xsl:text> Nr.{\,}</xsl:text>
               <xsl:value-of select="$monogr//biblScope[@unit = 'nr']"/>
            </xsl:if>
         </xsl:when>
         <xsl:when test="string-length($monogr/imprint/date/@when) = 6">
            <xsl:if test="$monogr//biblScope[@unit = 'nr']">
               <xsl:text>, Nr.{\,}</xsl:text>
               <xsl:value-of select="$monogr//biblScope[@unit = 'nr']"/>
            </xsl:if>
            <xsl:text> (</xsl:text>
            <xsl:value-of select="normalize-space(foo:date-translate($monogr/imprint/date))"/>
            <xsl:text>)</xsl:text>
         </xsl:when>
         <xsl:otherwise>
            <xsl:if test="$monogr//biblScope[@unit = 'nr']">
               <xsl:text>, Nr.{\,}</xsl:text>
               <xsl:value-of select="$monogr//biblScope[@unit = 'nr']"/>
            </xsl:if>
            <xsl:if test="$monogr/imprint/date">
               <xsl:text>, </xsl:text>
               <xsl:value-of select="normalize-space(foo:date-translate($monogr/imprint/date))"/>
            </xsl:if>
         </xsl:otherwise>
      </xsl:choose>
   </xsl:function>
   <xsl:function name="foo:monogr-angabe">
      <xsl:param name="monogr" as="node()"/>
      <xsl:choose>
         <xsl:when test="count($monogr/author) &gt; 0">
            <xsl:value-of
               select="foo:autor-rekursion($monogr, count($monogr/author), count($monogr/author), false(), true())"/>
            <xsl:text>: </xsl:text>
         </xsl:when>
      </xsl:choose>
      <!--   <xsl:choose>
                <xsl:when test="substring($monogr/title/@ref, 1, 3) ='A08' or $monogr/title/@level='j'">-->
      <xsl:text>\emph{</xsl:text>
      <xsl:value-of select="$monogr/title"/>
      <xsl:text>}</xsl:text>
      <!--  </xsl:when>
                <xsl:otherwise>
                   <xsl:value-of select="$monogr/title"/>
                </xsl:otherwise>
             </xsl:choose>-->
      <xsl:if test="$monogr/editor[1]">
         <xsl:text>. </xsl:text>
         <xsl:choose>
            <xsl:when test="$monogr/editor[2]">
               <xsl:text>Hg. </xsl:text>
               <xsl:for-each select="$monogr/editor">
                  <xsl:choose>
                     <xsl:when test="contains(., ', ')">
                        <xsl:value-of select="normalize-space(substring-after(., ', '))"/>
                        <xsl:text> </xsl:text>
                        <xsl:value-of select="normalize-space(substring-before(., ', '))"/>
                     </xsl:when>
                  </xsl:choose>
                  <xsl:choose>
                     <xsl:when test="position() = last()"/>
                     <xsl:when test="not(position() = last() - 1)">
                        <xsl:text>, </xsl:text>
                     </xsl:when>
                     <xsl:otherwise>
                        <xsl:text> und </xsl:text>
                     </xsl:otherwise>
                  </xsl:choose>
               </xsl:for-each>
            </xsl:when>
            <xsl:otherwise>
               <xsl:value-of select="$monogr/editor"/>
            </xsl:otherwise>
         </xsl:choose>
         <xsl:if test="count($monogr/editor/persName/@ref) &gt; 0">
            <xsl:for-each select="$monogr/editor/persName/@ref">
               <xsl:value-of
                  select="foo:person-in-index($monogr/editor/persName/@ref, '|pwk}', true())"/>
            </xsl:for-each>
         </xsl:if>
      </xsl:if>
      <xsl:if test="$monogr/edition">
         <xsl:text>. </xsl:text>
         <xsl:value-of select="$monogr/edition"/>
      </xsl:if>
      <xsl:choose>
         <!-- Hier Abfrage, ob es ein Journal ist -->
         <xsl:when test="$monogr/title[@level = 'j']">
            <xsl:value-of select="foo:jg-bd-nr($monogr)"/>
         </xsl:when>
         <!-- Im anderen Fall müsste es ein 'm' für monographic sein -->
         <xsl:otherwise>
            <xsl:if test="$monogr[child::imprint]">
               <xsl:text>. </xsl:text>
               <xsl:value-of select="foo:imprint-in-index($monogr)"/>
            </xsl:if>
            <xsl:if test="$monogr/biblScope/@unit = 'vol'">
               <xsl:text>, </xsl:text>
               <xsl:value-of select="$monogr/biblScope[@unit = 'vol']"/>
            </xsl:if>
         </xsl:otherwise>
      </xsl:choose>
   </xsl:function>
   <xsl:function name="foo:vorname-vor-nachname">
      <xsl:param name="autorname" as="xs:string"/>
      <xsl:choose>
         <xsl:when test="contains($autorname, ', ')">
            <xsl:value-of select="substring-after($autorname, ', ')"/>
            <xsl:text> </xsl:text>
            <xsl:value-of select="substring-before($autorname, ', ')"/>
         </xsl:when>
         <xsl:otherwise>
            <xsl:value-of select="$autorname"/>
         </xsl:otherwise>
      </xsl:choose>
   </xsl:function>
   <xsl:function name="foo:autor-rekursion">
      <xsl:param name="monogr" as="node()"/>
      <xsl:param name="autor-count" as="xs:integer"/>
      <xsl:param name="autor-count-gesamt" as="xs:integer"/>
      <xsl:param name="keystattwert" as="xs:boolean"/>
      <xsl:param name="vorname-vor-nachname" as="xs:boolean"/>
      <!-- in den Fällen, wo ein Text unter einem Kürzel erschien, wird zum sortieren der key-Wert verwendet -->
      <xsl:variable name="autor" select="$monogr/author"/>
      <xsl:choose>
         <xsl:when
            test="$keystattwert and $monogr/author[$autor-count-gesamt - $autor-count + 1]/@ref">
            <xsl:choose>
               <xsl:when test="$vorname-vor-nachname">
                  <xsl:value-of
                     select="foo:index-sortiert(concat(normalize-space(key('person-lookup', ($monogr/author[$autor-count-gesamt - $autor-count + 1]/@ref), $persons)/persName/forename), ' ', normalize-space(key('person-lookup', ($monogr/author[$autor-count-gesamt - $autor-count + 1]/@ref), $persons)/persName/surname)), 'sc')"
                  />
               </xsl:when>
               <xsl:otherwise>
                  <xsl:value-of
                     select="foo:index-sortiert(concat(normalize-space(key('person-lookup', ($monogr/author[$autor-count-gesamt - $autor-count + 1]/@ref, $persons)/persName/surname)), ', ', normalize-space(key('person-lookup', ($monogr/author[$autor-count-gesamt - $autor-count + 1]/@ref), $persons)/persName/forename)), 'sc')"
                  />
               </xsl:otherwise>
            </xsl:choose>
         </xsl:when>
         <xsl:otherwise>
            <xsl:choose>
               <xsl:when test="$vorname-vor-nachname">
                  <xsl:value-of
                     select="foo:vorname-vor-nachname($autor[$autor-count-gesamt - $autor-count + 1])"
                  />
               </xsl:when>
               <xsl:otherwise>
                  <xsl:value-of
                     select="foo:index-sortiert($autor[$autor-count-gesamt - $autor-count + 1], 'sc')"
                  />
               </xsl:otherwise>
            </xsl:choose>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:if test="$autor-count &gt; 1">
         <xsl:text>, </xsl:text>
         <xsl:value-of
            select="foo:autor-rekursion($monogr, $autor-count - 1, $autor-count-gesamt, $keystattwert, $vorname-vor-nachname)"
         />
      </xsl:if>
   </xsl:function>
   <xsl:function name="foo:herausgeber-nach-dem-titel">
      <xsl:param name="monogr" as="node()"/>
      <xsl:if test="$monogr/editor != '' and $monogr/author != ''">
         <xsl:value-of select="$monogr/editor"/>
      </xsl:if>
   </xsl:function>
   <xsl:function name="foo:analytic-angabe">
      <xsl:param name="gedruckte-quellen" as="node()"/>
      <!--  <xsl:param name="vor-dem-at" as="xs:boolean"/> <!-\- Der Parameter ist gesetzt, wenn auch der Sortierungsinhalt vor dem @ ausgegeben werden soll -\->
       <xsl:param name="quelle-oder-literaturliste" as="xs:boolean"/> <!-\- Ists Quelle, kommt der Titel kursiv und der Autor forename Name -\->-->
      <xsl:variable name="analytic" as="node()" select="$gedruckte-quellen/analytic"/>
      <xsl:choose>
         <xsl:when test="$analytic/author[1]/@ref = 'A002003'">
            <xsl:text>[O.{\,}V.:] </xsl:text>
         </xsl:when>
         <xsl:when test="$analytic/author[1]">
            <xsl:value-of
               select="foo:autor-rekursion($analytic, count($analytic/author), count($analytic/author), false(), true())"/>
            <xsl:text>: </xsl:text>
         </xsl:when>
      </xsl:choose>
      <xsl:choose>
         <xsl:when test="not($analytic/title/@type = 'j')">
            <xsl:text>\emph{</xsl:text>
            <xsl:value-of select="normalize-space(foo:sonderzeichen-ersetzen($analytic/title))"/>
            <xsl:choose>
               <xsl:when test="ends-with(normalize-space($analytic/title), '!')"/>
               <xsl:when test="ends-with(normalize-space($analytic/title), '?')"/>
               <xsl:otherwise>
                  <xsl:text>.</xsl:text>
               </xsl:otherwise>
            </xsl:choose>
            <xsl:text>}</xsl:text>
         </xsl:when>
         <xsl:otherwise>
            <xsl:value-of select="normalize-space(foo:sonderzeichen-ersetzen($analytic/title))"/>
            <xsl:choose>
               <xsl:when test="ends-with(normalize-space($analytic/title), '!')"/>
               <xsl:when test="ends-with(normalize-space($analytic/title), '?')"/>
               <xsl:otherwise>
                  <xsl:text>.</xsl:text>
               </xsl:otherwise>
            </xsl:choose>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:if test="$analytic/editor[1]">
         <xsl:text> </xsl:text>
         <xsl:value-of select="$analytic/editor"/>
         <xsl:text>.</xsl:text>
      </xsl:if>
   </xsl:function>
   <xsl:function name="foo:nach-dem-rufezeichen">
      <xsl:param name="titel" as="xs:string"/>
      <xsl:param name="gedruckte-quellen" as="node()"/>
      <xsl:param name="gedruckte-quellen-count" as="xs:integer"/>
      <xsl:value-of select="$gedruckte-quellen/ancestor::TEI/@when"/>
      <xsl:text>@</xsl:text>
      <xsl:choose>
         <!-- Hier auszeichnen ob es Archivzeugen gibt -->
         <xsl:when test="boolean($gedruckte-quellen/listWit)">
            <xsl:text>\emph{</xsl:text>
            <xsl:value-of select="foo:quellen-titel-kuerzen($titel)"/>
            <xsl:text>}</xsl:text>
         </xsl:when>
         <xsl:when test="$gedruckte-quellen-count = 1 and not(boolean($gedruckte-quellen/listWit))">
            <xsl:text>\emph{\textbf{</xsl:text>
            <xsl:value-of select="foo:quellen-titel-kuerzen($titel)"/>
            <xsl:text>}}</xsl:text>
         </xsl:when>
         <xsl:otherwise>
            <xsl:text>\emph{</xsl:text>
            <xsl:value-of select="foo:quellen-titel-kuerzen($titel)"/>
            <xsl:text>}</xsl:text>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:if
         test="not(empty($gedruckte-quellen/listBibl/biblStruct[$gedruckte-quellen-count]/monogr//biblScope[@unit = 'pp']))">
         <xsl:text> (S. </xsl:text>
         <xsl:value-of
            select="$gedruckte-quellen/listBibl/biblStruct[$gedruckte-quellen-count]/monogr//biblScope[@unit = 'pp']"/>
         <xsl:text>)</xsl:text>
      </xsl:if>
   </xsl:function>
   <xsl:function name="foo:vorne-hinten">
      <xsl:param name="vorne" as="xs:boolean"/>
      <xsl:choose>
         <xsl:when test="$vorne">
            <xsl:text>|(</xsl:text>
         </xsl:when>
         <xsl:otherwise>
            <xsl:text>|)</xsl:text>
         </xsl:otherwise>
      </xsl:choose>
   </xsl:function>
   <xsl:function name="foo:weitere-drucke">
      <xsl:param name="gedruckte-quellen" as="node()"/>
      <xsl:param name="anzahl-drucke" as="xs:integer"/>
      <xsl:param name="drucke-zaehler" as="xs:integer"/>
      <xsl:param name="erster-druck-druckvorlage" as="xs:boolean"/>
      <xsl:variable name="seitenangabe" as="xs:string?"
         select="$gedruckte-quellen/biblStruct[$drucke-zaehler]//biblScope[@unit = 'pp'][1]"/>
      <xsl:text>\weitereDrucke{</xsl:text>
      <xsl:if
         test="($anzahl-drucke &gt; 1 and not($erster-druck-druckvorlage)) or ($anzahl-drucke &gt; 2 and $erster-druck-druckvorlage)">
         <xsl:choose>
            <xsl:when test="$erster-druck-druckvorlage">
               <xsl:value-of select="$drucke-zaehler - 1"/>
            </xsl:when>
            <xsl:otherwise>
               <xsl:value-of select="$drucke-zaehler"/>
            </xsl:otherwise>
         </xsl:choose>
         <xsl:text>) </xsl:text>
      </xsl:if>
      <xsl:choose>
         <xsl:when test="$gedruckte-quellen/biblStruct[$drucke-zaehler]/@corresp">
            <xsl:if
               test="not(empty($gedruckte-quellen/biblStruct[$drucke-zaehler]/monogr/title[@level = 'm']/@ref))">
               <xsl:value-of
                  select="foo:werk-indexName-Routine-autoren($gedruckte-quellen/biblStruct[$drucke-zaehler]/monogr/title[@level = 'm']/@ref, '|pwk')"
               />
            </xsl:if>
            <xsl:choose>
               <xsl:when test="empty($seitenangabe)">
                  <xsl:value-of
                     select="foo:sigle-schreiben($gedruckte-quellen/biblStruct[$drucke-zaehler]/@corresp, '')"
                  />
               </xsl:when>
               <xsl:otherwise>
                  <xsl:value-of
                     select="foo:sigle-schreiben($gedruckte-quellen/biblStruct[$drucke-zaehler]/@corresp, $seitenangabe)"
                  />
               </xsl:otherwise>
            </xsl:choose>
         </xsl:when>
         <xsl:otherwise>
            <xsl:choose>
               <xsl:when test="$drucke-zaehler = 1">
                  <xsl:value-of
                     select="foo:bibliographische-angabe($gedruckte-quellen/biblStruct[$drucke-zaehler], true(), true())"
                  />
               </xsl:when>
               <xsl:otherwise>
                  <xsl:choose>
                     <xsl:when
                        test="$gedruckte-quellen/biblStruct[1]/analytic = $gedruckte-quellen/biblStruct[$drucke-zaehler]">
                        <xsl:value-of
                           select="foo:bibliographische-angabe($gedruckte-quellen/biblStruct[$drucke-zaehler], false(), true())"
                        />
                     </xsl:when>
                     <xsl:otherwise>
                        <xsl:value-of
                           select="foo:bibliographische-angabe($gedruckte-quellen/biblStruct[$drucke-zaehler], true(), true())"
                        />
                     </xsl:otherwise>
                  </xsl:choose>
               </xsl:otherwise>
            </xsl:choose>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:text>} </xsl:text>
      <xsl:if test="$drucke-zaehler &lt; $anzahl-drucke">
         <xsl:value-of
            select="foo:weitere-drucke($gedruckte-quellen, $anzahl-drucke, $drucke-zaehler + 1, $erster-druck-druckvorlage)"
         />
      </xsl:if>
   </xsl:function>
   <xsl:function name="foo:sigle-schreiben">
      <xsl:param name="siglen-wert" as="xs:string"/>
      <xsl:param name="seitenangabe" as="xs:string"/>
      <xsl:variable name="sigle-eintrag" select="key('sigle-lookup', $siglen-wert, $sigle)"
         as="node()?"/>
      <xsl:if
         test="$sigle-eintrag/sigle-vorne and not(normalize-space($sigle-eintrag/sigle-vorne) = '')">
         <xsl:value-of select="$sigle-eintrag/sigle-vorne"/>
         <xsl:text> </xsl:text>
      </xsl:if>
      <xsl:text>\emph{</xsl:text>
      <xsl:value-of select="normalize-space($sigle-eintrag/sigle-mitte)"/>
      <xsl:text>}</xsl:text>
      <xsl:if test="$sigle-eintrag/sigle-hinten">
         <xsl:text> </xsl:text>
         <xsl:value-of select="normalize-space($sigle-eintrag/sigle-hinten)"/>
      </xsl:if>
      <xsl:choose>
         <xsl:when test="(not(normalize-space($sigle-eintrag/sigle-band) = ''))">
            <xsl:text> </xsl:text>
            <xsl:value-of select="normalize-space($sigle-eintrag/sigle-band)"/>
            <xsl:if test="not(empty($seitenangabe) or $seitenangabe = '')">
               <xsl:text>, S.&#160;</xsl:text>
               <xsl:value-of select="$seitenangabe"/>
            </xsl:if>
         </xsl:when>
         <xsl:when test="not(empty($seitenangabe) or $seitenangabe = '')">
            <xsl:text> </xsl:text>
            <xsl:value-of select="$seitenangabe"/>
         </xsl:when>
      </xsl:choose>
      <xsl:text>. </xsl:text>
   </xsl:function>
   <!-- Sonderfunktion für ASI, wo der erste Zeuge nach dem Text steht -->
   <xsl:function name="foo:witnessAlsSectionAnhang">
      <xsl:param name="witness-quellen" as="node()"/>
      <xsl:param name="ists-druckvorlage" as="xs:boolean"/>
      <xsl:variable name="msIdentify" select="$witness-quellen//msIdentifier[1]"/>
      <!-- wenn hier true ist, dann wird die erste bibliografische Angabe als Druckvorlage ausgewiesen -->
      <xsl:text>\bigskip</xsl:text>
      <xsl:text>\begin{addmargin}[2cm]{0cm}\begin{flushleft}</xsl:text>
      <xsl:text>Archivquelle: </xsl:text>
      <xsl:value-of select="normalize-space($msIdentify/settlement)"/><xsl:text>, </xsl:text>
      <xsl:value-of select="normalize-space($msIdentify/repository)"/><xsl:text>, </xsl:text>
      <xsl:value-of select="normalize-space($msIdentify/idno)"/><xsl:text>.</xsl:text>
      <xsl:text>\end{flushleft}\end{addmargin}</xsl:text>
   </xsl:function>
   <xsl:function name="foo:buchAlsSectionAnhang">
      <xsl:param name="gedruckte-quellen" as="node()"/>
      <xsl:param name="ists-druckvorlage" as="xs:boolean"/>
      <!-- wenn hier true ist, dann wird die erste bibliografische Angabe als Druckvorlage ausgewiesen -->
      <xsl:text>\bigskip</xsl:text>
      <xsl:text>\begin{addmargin}[2cm]{0cm}\begin{flushleft}</xsl:text>
      <xsl:choose>
         <xsl:when
            test="$ists-druckvorlage and not($gedruckte-quellen/biblStruct[1]/@corresp = 'ASTB')">
            <!-- Schnitzlers Tagebuch kommt nicht rein -->
            <xsl:text>{</xsl:text>
            <xsl:choose>
               <!-- Für denn Fall, dass es sich um siglierte Literatur handelt: -->
               <xsl:when test="$gedruckte-quellen/biblStruct[1]/@corresp">
                  <!-- Siglierte Literatur -->
                  <xsl:variable name="seitenangabe" as="xs:string?"
                     select="$gedruckte-quellen/biblStruct[1]/descendant::biblScope[@unit = 'pp']"/>
                  <!-- Zuerst indizierte Werke in den Index: -->
                  <xsl:for-each select="$gedruckte-quellen/biblStruct[1]//title/@ref">
                     <xsl:value-of select="foo:werk-indexName-Routine-autoren(., '|pw}')"/>
                  </xsl:for-each>
                  <!-- Hier nun der Abdruck der bibliografischen Angabe nach dem Text -->
                  <xsl:choose>
                     <!-- Der Analytic-Teil wird auch bei siglierter Literatur ausgegeben -->
                     <xsl:when test="$gedruckte-quellen/biblStruct[1]/analytic">
                        <xsl:value-of select="foo:analytic-angabe($gedruckte-quellen/biblStruct[1])"/>
                        <xsl:text>In: </xsl:text>
                        <xsl:choose>
                           <xsl:when test="$seitenangabe">
                              <xsl:value-of
                                 select="foo:sigle-schreiben($gedruckte-quellen/biblStruct[1]/@corresp, $seitenangabe)"
                              />
                           </xsl:when>
                           <xsl:otherwise>
                              <xsl:value-of
                                 select="foo:sigle-schreiben($gedruckte-quellen/biblStruct[1]/@corresp, '')"
                              />
                           </xsl:otherwise>
                        </xsl:choose>
                     </xsl:when>
                     <!-- Kein analytic aber sigliert -->
                     <xsl:otherwise>
                        <xsl:choose>
                           <xsl:when test="$seitenangabe">
                              <xsl:value-of
                                 select="foo:sigle-schreiben($gedruckte-quellen/biblStruct[1]/@corresp, $seitenangabe)"
                              />
                           </xsl:when>
                           <xsl:otherwise>
                              <xsl:value-of
                                 select="foo:sigle-schreiben($gedruckte-quellen/biblStruct[1]/@corresp, '')"
                              />
                           </xsl:otherwise>
                        </xsl:choose>
                     </xsl:otherwise>
                  </xsl:choose>
               </xsl:when>
               <!-- Hier der nicht siglierte Teil -->
               <xsl:otherwise>
                  <xsl:value-of
                     select="foo:bibliographische-angabe($gedruckte-quellen/biblStruct[1], true(), false())"
                  />
               </xsl:otherwise>
            </xsl:choose>
            <xsl:text>}</xsl:text>
         </xsl:when>
      </xsl:choose>
      <xsl:text>\end{flushleft}\end{addmargin}</xsl:text>
   </xsl:function>
   <!-- Diese Funktion dient dazu, jene Publikationen in die Endnote zu setzen, die als vollständige Quelle wiedergegeben werden, wenn es keine Archivsignatur gibt -->
   <xsl:function name="foo:buchAlsQuelle">
      <xsl:param name="gedruckte-quellen" as="node()"/>
      <xsl:param name="ists-druckvorlage" as="xs:boolean"/>
      <!-- wenn hier true ist, dann wird die erste bibliografische Angabe als Druckvorlage ausgewiesen -->
      <!-- ASI SPEZIAL: NACHDEM DIE QUELLE UNTERHALB DES FLIESSTEXTES STEHT, WIRD SIE HIER NIE WIEDERGEGEBEN, DRUM NÄCHSTES IF AUSKOMMENTIERT -->
      <xsl:choose>
         <xsl:when
            test="($ists-druckvorlage and $gedruckte-quellen/biblStruct[2]) or (not($ists-druckvorlage) and $gedruckte-quellen/biblStruct[1])">
            <xsl:text>\buchAbdrucke{</xsl:text>
            <xsl:choose>
               <xsl:when test="$ists-druckvorlage and $gedruckte-quellen/biblStruct[2]">
                  <xsl:value-of
                     select="foo:weitere-drucke($gedruckte-quellen, count($gedruckte-quellen/biblStruct), 2, true())"
                  />
               </xsl:when>
               <xsl:otherwise>
                  <xsl:value-of
                     select="foo:weitere-drucke($gedruckte-quellen, count($gedruckte-quellen/biblStruct), 1, false())"
                  />
               </xsl:otherwise>
            </xsl:choose>
            <xsl:text>}</xsl:text>
         </xsl:when>
      </xsl:choose>
   </xsl:function>
   <xsl:function name="foo:bibliographische-angabe">
      <xsl:param name="biblstruct" as="node()"/>
      <xsl:param name="mit-analytic" as="xs:boolean"/>
      <xsl:param name="kommentarbereich" as="xs:boolean"/>
      <!-- Wenn mehrere Abdrucke und da der analytic-Teil gleich, dann braucht der nicht wiederholt werden, dann mit-analytic -->
      <!-- Zuerst das in den Index schreiben von Autor, Zeitschrift etc. -->
      <xsl:for-each select="$biblstruct//title/@ref">
         <xsl:choose>
            <xsl:when test="$kommentarbereich">
               <xsl:value-of select="foo:indexName-Routine('work', ., '', '|pwk}')"/>
            </xsl:when>
            <xsl:otherwise>
               <xsl:value-of select="foo:indexName-Routine('work', ., '', '|pwt}')"/>
            </xsl:otherwise>
         </xsl:choose>
      </xsl:for-each>
      <!--
         Hier kann man es sich sparen, den Autor in den Index zu setzen, da ja das Werk verzeichnet wird
         <xsl:for-each select="$biblstruct//author/@ref">
         <xsl:value-of select="foo:indexName-Routine('person', ., '', '|pwk}')"/>
      </xsl:for-each>-->
      <xsl:choose>
         <!-- Zuerst Analytic -->
         <xsl:when test="$biblstruct/analytic">
            <xsl:choose>
               <xsl:when test="$mit-analytic">
                  <xsl:value-of select="foo:analytic-angabe($biblstruct)"/>
                  <xsl:text> </xsl:text>
               </xsl:when>
            </xsl:choose>
            <xsl:text>In: </xsl:text>
            <xsl:value-of select="foo:monogr-angabe($biblstruct/monogr[last()])"/>
         </xsl:when>
         <!-- Jetzt abfragen ob mehrere monogr -->
         <xsl:when test="count($biblstruct/monogr) = 2">
            <xsl:value-of select="foo:monogr-angabe($biblstruct/monogr[last()])"/>
            <xsl:text>.{\,}Band</xsl:text>
            <!-- <xsl:if test="$biblstruct/monogr[last()]/biblScope/@unit='vol'">
                  <xsl:text> </xsl:text>
                  <xsl:value-of select="$biblstruct/monogr[last()]/biblScope[@unit='vol']"/>
               </xsl:if>-->
            <xsl:text>: </xsl:text>
            <xsl:value-of select="foo:monogr-angabe($biblstruct/monogr[1])"/>
         </xsl:when>
         <!-- Ansonsten ist es eine einzelne monogr -->
         <xsl:otherwise>
            <xsl:value-of select="foo:monogr-angabe($biblstruct/monogr[last()])"/>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:if test="not(empty($biblstruct/monogr//biblScope[@unit = 'sec']))">
         <xsl:text>, Sec.{\,}</xsl:text>
         <xsl:value-of select="$biblstruct/monogr//biblScope[@unit = 'sec']"/>
      </xsl:if>
      <xsl:if test="not(empty($biblstruct/monogr//biblScope[@unit = 'pp']))">
         <xsl:text>, S.{\,}</xsl:text>
         <xsl:value-of select="$biblstruct/monogr//biblScope[@unit = 'pp']"/>
      </xsl:if>
      <xsl:if test="not(empty($biblstruct/monogr//biblScope[@unit = 'col']))">
         <xsl:text>, Sp.{\,}</xsl:text>
         <xsl:value-of select="$biblstruct/monogr//biblScope[@unit = 'col']"/>
      </xsl:if>
      <xsl:if test="not(empty($biblstruct/series))">
         <xsl:text> (</xsl:text>
         <xsl:value-of select="$biblstruct/series/title"/>
         <xsl:if test="$biblstruct/series/biblScope">
            <xsl:text>, </xsl:text>
            <xsl:value-of select="$biblstruct/series/biblScope"/>
         </xsl:if>
         <xsl:text>)</xsl:text>
      </xsl:if>
      <xsl:text>.</xsl:text>
   </xsl:function>
   <xsl:function name="foo:mehrere-witnesse">
      <xsl:param name="witness-count" as="xs:integer"/>
      <xsl:param name="witnesse" as="xs:integer"/>
      <xsl:param name="listWitnode" as="node()"/>
      <!-- <xsl:text>\emph{Standort </xsl:text>
      <xsl:value-of select="$witness-count -$witnesse +1"/>
      <xsl:text>:} </xsl:text>-->
      <xsl:apply-templates select="$listWitnode/witness[$witness-count - $witnesse + 1]"/>
      <xsl:if test="$witnesse &gt; 1">
         <!--<xsl:text>\\{}</xsl:text>-->
         <xsl:apply-templates
            select="foo:mehrere-witnesse($witness-count, $witnesse - 1, $listWitnode)"/>
      </xsl:if>
   </xsl:function>
   <xsl:template match="div1">
      <xsl:choose>
         <xsl:when test="position() = 1">
            <xsl:text>\biographical{</xsl:text>
         </xsl:when>
         <xsl:otherwise>
            <xsl:text>\biographicalOhne{</xsl:text>
            <!-- Das setzt das kleine Köpfchen nur beim ersten Vorkommen einer biografischen Note -->
         </xsl:otherwise>
      </xsl:choose>
      <xsl:choose>
         <xsl:when test="ref[@type = 'schnitzler-tagebuch']">
            <xsl:text>\emph{Tagebuch}, </xsl:text>
            <xsl:value-of select="
                  format-date(ref[@type = 'schnitzler-tagebuch']/@target,
                  '[D1].{\,}[M1].{\,}[Y0001]')"/>
            <xsl:text>: </xsl:text>
         </xsl:when>
         <xsl:when test="bibl">
            <xsl:text>\emph{</xsl:text>
            <xsl:apply-templates select="bibl"/>
            <xsl:text>}: </xsl:text>
         </xsl:when>
         <xsl:otherwise>
            <xsl:text>\textcolor{red}{FEHLER QUELLENANGABE}</xsl:text>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:text>»</xsl:text>
      <xsl:choose>
         <xsl:when test="quote/p">
            <xsl:for-each select="quote/p[not(position() = last())]">
               <xsl:apply-templates/>
               <xsl:text>{ / }</xsl:text>
            </xsl:for-each>
            <xsl:apply-templates select="quote/p[(position() = last())]"/>
         </xsl:when>
         <xsl:otherwise>
            <xsl:apply-templates select="quote"/>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:text>«</xsl:text>
      <xsl:if test="
            not(substring(normalize-space(quote), string-length(normalize-space(quote)), 1) = '.' or substring(normalize-space(quote), string-length(normalize-space(quote)), 1) = '?' or substring(normalize-space(quote), string-length(normalize-space(quote)), 1) = '!'
            or quote/node()[position() = last()]/self::dots or substring(normalize-space(quote), string-length(normalize-space(quote)) - 1, 2) = '.–')">
         <xsl:text>.</xsl:text>
      </xsl:if>
      <xsl:text>}</xsl:text>
   </xsl:template>
   <!-- eigentlicher Fließtext root -->
   <xsl:template match="body">
      <xsl:variable name="correspAction-date" as="node()">
         <xsl:choose>
            <xsl:when
               test="ancestor::TEI/descendant::correspDesc/correspAction[@type = 'sent']/date">
               <xsl:apply-templates
                  select="ancestor::TEI/descendant::correspDesc/correspAction[@type = 'sent']/date"
               />
            </xsl:when>
            <xsl:otherwise>
               <xsl:text>EDITI</xsl:text>
            </xsl:otherwise>
         </xsl:choose>
      </xsl:variable>
      <xsl:variable name="dokument-id" select="ancestor::TEI/@id"/>
      <!-- Hier komplett abgedruckte Texte fett in den Index -->
      <xsl:if
         test="starts-with(ancestor::TEI/teiHeader/fileDesc/titleStmt/title[@level = 'a']/@ref, '#pmb')">
         <xsl:value-of
            select="foo:abgedruckte-workNameRoutine(ancestor::TEI/teiHeader/fileDesc/titleStmt/title[@level = 'a']/@ref, true())"
         />
      </xsl:if>
      <!-- Hier Briefe bei den Personen in den Personenindex -->
      <xsl:if test="ancestor::TEI[starts-with(@id, 'L')]">
         <xsl:value-of
            select="foo:sender-empfaenger-in-personenindex-rekursiv(ancestor::TEI/teiHeader/profileDesc/correspDesc/correspAction[@type = 'sent'], true(), count(ancestor::TEI/teiHeader/profileDesc/correspDesc/correspAction[@type = 'sent']/persName))"/>
         <xsl:value-of
            select="foo:sender-empfaenger-in-personenindex-rekursiv(ancestor::TEI/teiHeader/profileDesc/correspDesc/correspAction[@type = 'received'], false(), count(ancestor::TEI/teiHeader/profileDesc/correspDesc/correspAction[@type = 'received']/persName))"
         />
      </xsl:if>
      <xsl:apply-templates/>
      <xsl:if
         test="starts-with(ancestor::TEI/teiHeader/fileDesc/titleStmt/title[@level = 'a']/@ref, '#pmb')">
         <xsl:value-of
            select="foo:abgedruckte-workNameRoutine(ancestor::TEI/teiHeader/fileDesc/titleStmt/title[@level = 'a']/@ref, false())"
         />
      </xsl:if>
   </xsl:template>
   <!-- Das ist speziell für die Behandlung von Bildern, der eigentliche body für alles andere kommt danach -->
   <xsl:template match="image">
      <xsl:apply-templates/>
   </xsl:template>
   <!-- body und Absätze von Hrsg-Texten -->
   <xsl:template match="body[ancestor::TEI[starts-with(@id, 'E_')]]">
      <xsl:apply-templates/>
   </xsl:template>
   <!-- body -->
   <xsl:template match="div[@type = 'address']/address">
      <xsl:apply-templates/>
   </xsl:template>
   <xsl:template match="lb">
      <xsl:text>{\\}</xsl:text>
      <!--<xsl:text>{\\[\baselineskip]}</xsl:text>-->
   </xsl:template>
   <xsl:template match="lb[parent::item]">
      <xsl:text>{\newline}</xsl:text>
   </xsl:template>
   <xsl:template match="note[@type = 'footnote' and ancestor::text/body]">
      <xsl:text>\footnote{</xsl:text>
      <xsl:for-each select="p">
         <xsl:apply-templates select="."/>
         <xsl:if test="not(position() = last())">\par\noindent </xsl:if>
      </xsl:for-each>
      <xsl:text>}</xsl:text>
   </xsl:template>
   <xsl:template
      match="p[ancestor::TEI[starts-with(@id, 'E_')] and not(child::*[1] = space[@dim] and not(child::*[2]) and (fn:normalize-space(.) = ''))]">
      <xsl:if test="self::p[@rend = 'inline']">
         <xsl:text>\leftskip=3em{}</xsl:text>
      </xsl:if>
      <xsl:choose>
         <xsl:when test="ancestor::quote[ancestor::physDesc] and not(position() = 1)">
            <xsl:text>{ / }</xsl:text>
         </xsl:when>
         <xsl:when test="not(@rend) and not(preceding-sibling::p[1])">
            <xsl:text>\noindent{}</xsl:text>
         </xsl:when>
         <xsl:when test="@rend and not(preceding-sibling::p[1]/@rend = @rend)">
            <xsl:text>\noindent{}</xsl:text>
         </xsl:when>
      </xsl:choose>
      <xsl:choose>
         <xsl:when test="@rend = 'center'">
            <xsl:text>\begin{center}</xsl:text>
         </xsl:when>
         <xsl:when test="@rend = 'right'">
            <xsl:text>\begin{flushright}</xsl:text>
         </xsl:when>
      </xsl:choose>
      <xsl:apply-templates/>
      <xsl:choose>
         <xsl:when test="@rend = 'center'">
            <xsl:text>\end{center}</xsl:text>
         </xsl:when>
         <xsl:when test="@rend = 'right'">
            <xsl:text>\end{flushright}</xsl:text>
         </xsl:when>
      </xsl:choose>
      <xsl:choose>
         <xsl:when test="not(fn:position() = last())">
            <xsl:text>\par
      </xsl:text>
         </xsl:when>
      </xsl:choose>
      <xsl:if test="self::p[@rend = 'inline']">\leftskip=0em{}</xsl:if>
   </xsl:template>
   <xsl:template match="p">
      <xsl:choose>
         <xsl:when test="ancestor::quote[ancestor::physDesc] and not(position() = 1)">
            <xsl:text>{ / }</xsl:text>
         </xsl:when>
         <xsl:when test="not(@rend) and not(preceding-sibling::p[1])">
            <xsl:text>\noindent{}</xsl:text>
         </xsl:when>
         <xsl:when test="@rend and not(preceding-sibling::p[1]/@rend = @rend)">
            <xsl:text>\noindent{}</xsl:text>
         </xsl:when>
      </xsl:choose>
      <xsl:choose>
         <xsl:when test="@rend = 'center'">
            <xsl:text>\begin{center}</xsl:text>
         </xsl:when>
         <xsl:when test="@rend = 'right'">
            <xsl:text>\begin{flushright}</xsl:text>
         </xsl:when>
      </xsl:choose>
      <xsl:apply-templates/>
      <xsl:choose>
         <xsl:when test="@rend = 'center'">
            <xsl:text>\end{center}</xsl:text>
         </xsl:when>
         <xsl:when test="@rend = 'right'">
            <xsl:text>\end{flushright}</xsl:text>
         </xsl:when>
      </xsl:choose>
   </xsl:template>
   <xsl:template match="seg">
      <xsl:apply-templates/>
      <xsl:if test="@rend = 'left'">
         <xsl:text>\hfill </xsl:text>
      </xsl:if>
   </xsl:template>
   <xsl:template
      match="p[(ancestor::body and not(ancestor::TEI[starts-with(@id, 'E')]) and not(child::space[@dim] and not(child::*[2]) and empty(text())) and not(ancestor::div[@type = 'biographical']) and not(parent::note[@type = 'footnote']))] | closer | dateline">
      <!--     <xsl:if test="self::closer">\leftskip=1em{}</xsl:if>
-->
      <xsl:if test="self::p[@rend = 'inline']">
         <xsl:text>\leftskip=3em{}</xsl:text>
      </xsl:if>
      <xsl:choose>
         <xsl:when test="table"/>
         <xsl:when test="textkonstitution/zu-anmerken/table"/>
         <xsl:when test="ancestor::quote[ancestor::note] | ancestor::quote[ancestor::physDesc]">
            <xsl:if test="not(position() = 1)">
               <xsl:text>{ / }</xsl:text>
            </xsl:if>
         </xsl:when>
         <xsl:otherwise>
            <xsl:text>&#10;\pstart
           </xsl:text>
            <xsl:choose>
               <xsl:when test="(self::p and position() = 1) or (self::p and position() = 2 and preceding-sibling::latex)">
                  <xsl:text>\noindent{}</xsl:text>
               </xsl:when>
               <xsl:when test="self::p and preceding-sibling::*[not(name()='latex')][1] = preceding-sibling::head[1]">
                  <xsl:text>\noindent{}</xsl:text>
               </xsl:when>
               <xsl:when test="parent::div[child::*[not(name()='latex')][1]] = self::p">
                  <xsl:text>\noindent{}</xsl:text>
               </xsl:when>
               <xsl:when
                  test="self::p and preceding-sibling::*[not(name()='latex')][1] = preceding-sibling::p[@rend = 'right' or @rend = 'center']">
                  <xsl:text>\noindent{}</xsl:text>
               </xsl:when>
               <xsl:when
                  test="self::p[not(@rend = 'inline')] and preceding-sibling::*[not(name()='latex')][1] = preceding-sibling::p[@rend = 'inline']">
                  <xsl:text>\noindent{}</xsl:text>
               </xsl:when>
               <xsl:when
                  test="self::p[preceding-sibling::*[not(name()='latex')][1][self::p[(descendant::*[not(name()='latex')][1] = space[@dim = 'vertical']) and not(descendant::*[not(name()='latex')][2]) and empty(text())]]]">
                  <xsl:text>\noindent{}</xsl:text>
               </xsl:when>
               <xsl:when
                  test="self::p[@rend = 'inline'] and (preceding-sibling::*[not(name()='latex')][1]/not(@rend = 'inline') or preceding-sibling::*[not(name()='latex')][1]/not(@rend))">
                  <xsl:text>\noindent{}</xsl:text>
               </xsl:when>
               <xsl:when
                  test="ancestor::body[child::div[@type = 'original'] and child::div[@type = 'translation']] and not(ancestor::div[@type = 'biographical'] or ancestor::note)">
                  <xsl:text>\einruecken{}</xsl:text>
               </xsl:when>
            </xsl:choose>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:choose>
         <!-- Das hier dient dazu, leere Zeilen, Zeilen mit Trennstrich und weggelassene Absätze (Zeile mit Absatzzeichen in eckiger Klammer) nicht in der Zeilenzählung zu berücksichtigen  -->
         <xsl:when
            test="string-length(normalize-space(self::*)) = 0 and child::*[1] = space[@unit = 'chars' and @quantity = '1'] and not(child::*[2])">
            <xsl:text>\numberlinefalse{}</xsl:text>
         </xsl:when>
         <xsl:when
            test="string-length(normalize-space(self::*)) = 1 and node() = '–' and not(child::*)">
            <xsl:text>\numberlinefalse{}</xsl:text>
         </xsl:when>
         <xsl:when test="missing-paragraph">
            <xsl:text>\numberlinefalse{}</xsl:text>
         </xsl:when>
      </xsl:choose>
      <xsl:choose>
         <xsl:when test="table"/>
         <xsl:when test="closer"/>
         <xsl:when test="postcript"/>
      </xsl:choose>
      <xsl:if test="@rend">
         <xsl:value-of select="foo:absatz-position-vorne(@rend)"/>
      </xsl:if>
      <xsl:choose>
         <xsl:when test="missing-paragraph">
            <xsl:text>\noindent{[}{{\,}\footnotesize\textparagraph\normalsize{\,}}{]}</xsl:text>
         </xsl:when>
      </xsl:choose>
      <xsl:apply-templates/>
      <xsl:if test="@rend">
         <xsl:value-of select="foo:absatz-position-hinten(@rend)"/>
      </xsl:if>
      <xsl:if test="ancestor::TEI[starts-with(@id, 'L')]">
         <xsl:value-of
            select="foo:sender-empfaenger-in-personenindex-rekursiv(ancestor::TEI/teiHeader/profileDesc/correspDesc/correspAction[@type = 'sent'], true(), count(ancestor::TEI/teiHeader/profileDesc/correspDesc/correspAction[@type = 'sent']/persName))"/>
         <xsl:value-of
            select="foo:sender-empfaenger-in-personenindex-rekursiv(ancestor::TEI/teiHeader/profileDesc/correspDesc/correspAction[@type = 'received'], false(), count(ancestor::TEI/teiHeader/profileDesc/correspDesc/correspAction[@type = 'received']/persName))"
         />
      </xsl:if>
      <xsl:choose>
         <!-- Das hier dient dazu, leere Zeilen, Zeilen mit Trennstrich und weggelassene Absätze (Zeile mit Absatzzeichen in eckiger Klammer) nicht in der Zeilenzählung zu berücksichtigen  -->
         <xsl:when
            test="string-length(normalize-space(self::*)) = 0 and child::*[1] = space[@unit = 'chars' and @quantity = '1'] and not(child::*[2])">
            <xsl:text>\numberlinetrue{}</xsl:text>
         </xsl:when>
         <xsl:when
            test="string-length(normalize-space(self::*)) = 1 and node() = '–' and not(child::*)">
            <xsl:text>\numberlinetrue{}</xsl:text>
         </xsl:when>
         <xsl:when test="missing-paragraph">
            <xsl:text>\numberlinetrue{}</xsl:text>
         </xsl:when>
      </xsl:choose>
      <xsl:choose>
         <xsl:when test="table"/>
         <xsl:when test="textkonstitution/zu-anmerken/table"/>
         <xsl:when test="ancestor::quote[ancestor::note] | ancestor::quote[ancestor::physDesc]"/>
         <xsl:otherwise>
            <xsl:text>\pend
           </xsl:text>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:if test="self::closer | self::p[@rend = 'inline']">\leftskip=0em{}</xsl:if>
   </xsl:template>
   <!-- <xsl:template match="opener/p|dateline">
      <xsl:text>&#10;\pstart</xsl:text>
      <xsl:choose>
         <xsl:when test="@rend='right'">
            <xsl:text>\raggedleft</xsl:text>
         </xsl:when>
         <xsl:when test="@rend='center'">
            <xsl:text>\center</xsl:text>
         </xsl:when>
      </xsl:choose>
      <xsl:text>{}</xsl:text>
      <xsl:apply-templates/>
      <xsl:text>\pend</xsl:text>
   </xsl:template>-->
   <xsl:template match="salute[parent::opener]">
      <xsl:text>&#10;\pstart</xsl:text>
      <xsl:choose>
         <xsl:when test="@rend = 'right'">
            <xsl:text>\raggedleft</xsl:text>
         </xsl:when>
         <xsl:when test="@rend = 'center'">
            <xsl:text>\center</xsl:text>
         </xsl:when>
      </xsl:choose>
      <xsl:text>{}</xsl:text>
      <xsl:apply-templates/>
      <xsl:text>\pend</xsl:text>
   </xsl:template>
   <xsl:template match="salute">
      <xsl:apply-templates/>
   </xsl:template>
   <xsl:function name="foo:tabellenspalten">
      <xsl:param name="spaltenanzahl" as="xs:integer"/>
      <xsl:text>l</xsl:text>
      <xsl:if test="$spaltenanzahl &gt; 1">
         <xsl:value-of select="foo:tabellenspalten($spaltenanzahl - 1)"/>
      </xsl:if>
   </xsl:function>
   <xsl:template match="closer[not(child::lb)]">
      <xsl:text>&#10;\pstart <!--\raggedleft\hspace{1em}--></xsl:text>
      <xsl:apply-templates/>
      <xsl:text>\pend{}</xsl:text>
   </xsl:template>
   <xsl:template match="closer/lb">
      <xsl:choose>
         <xsl:when test="following-sibling::*[1] = signed">
            <xsl:apply-templates/>
         </xsl:when>
         <xsl:otherwise>
            <xsl:text>{\\[\baselineskip]}</xsl:text>
            <xsl:apply-templates/>
         </xsl:otherwise>
      </xsl:choose>
   </xsl:template>
   <!--  <xsl:template match="closer/lb[not(last())]">
      <xsl:text>{\\[\baselineskip]}</xsl:text>
      <xsl:apply-templates/>
   </xsl:template>
   
   <xsl:template match="closer/lb[last()][following-sibling::signed]">
<xsl:choose>
   <xsl:when test="not(following-sibling::node()[not(self::signed)])">
      <xsl:apply-templates/>
   </xsl:when>
   <xsl:otherwise>
      <xsl:text>{\\[\baselineskip]}</xsl:text>
      <xsl:apply-templates/>
   </xsl:otherwise>
</xsl:choose>
   </xsl:template>
   
   <xsl:template match="closer/lb[last()][not(following-sibling::signed)]">
      <!-\-      <xsl:text>\pend\pstart\raggedleft\hspace{1em}</xsl:text>
-\->      <xsl:text>{\\[\baselineskip]}</xsl:text>
      <xsl:apply-templates/>
   </xsl:template>
   -->
   <xsl:template match="*" mode="no-comments">
      <xsl:value-of select="text()"/>
   </xsl:template>
   <xsl:template match="table">
      <xsl:variable name="longest1">
         <xsl:variable name="sorted-cells" as="element(cell)*">
            <xsl:perform-sort select="row/cell[1]">
               <xsl:sort
                  select="string-length(string-join(descendant::text()[not(ancestor::note)], '')) + count(descendant::space[not(ancestor::note)]) + count(descendant::c[not(ancestor::note)])"/>
               <!-- das findet die Textlänge ohne den in note enthaltenen Text plus Leerzeichen und Sonderzeichen, die als Elemente codiert sind -->
            </xsl:perform-sort>
         </xsl:variable>
         <xsl:copy-of select="$sorted-cells[last()]"/>
      </xsl:variable>
      <xsl:variable name="longest2">
         <xsl:variable name="sorted-cells" as="element(cell)*">
            <xsl:perform-sort select="row/cell[2]">
               <xsl:sort
                  select="string-length(string-join(descendant::text()[not(ancestor::note)], '')) + count(descendant::space[not(ancestor::note)]) + count(descendant::c[not(ancestor::note)])"
               />
            </xsl:perform-sort>
         </xsl:variable>
         <xsl:copy-of select="$sorted-cells[last()]"/>
      </xsl:variable>
      <xsl:variable name="longest3">
         <xsl:variable name="sorted-cells" as="element(cell)*">
            <xsl:perform-sort select="row/cell[3]">
               <xsl:sort
                  select="string-length(string-join(descendant::text()[not(ancestor::note)], '')) + count(descendant::space[not(ancestor::note)]) + count(descendant::c[not(ancestor::note)])"
               />
            </xsl:perform-sort>
         </xsl:variable>
         <xsl:copy-of select="$sorted-cells[last()]"/>
      </xsl:variable>
      <xsl:variable name="longest4">
         <xsl:variable name="sorted-cells" as="element(cell)*">
            <xsl:perform-sort select="row/cell[4]">
               <xsl:sort
                  select="string-length(string-join(descendant::text()[not(ancestor::note)], '')) + count(descendant::space[not(ancestor::note)]) + count(descendant::c[not(ancestor::note)])"
               />
            </xsl:perform-sort>
         </xsl:variable>
         <xsl:copy-of select="$sorted-cells[last()]"/>
      </xsl:variable>
      <xsl:variable name="longest5">
         <xsl:variable name="sorted-cells" as="element(cell)*">
            <xsl:perform-sort select="row/cell[5]">
               <xsl:sort
                  select="string-length(string-join(descendant::text()[not(ancestor::note)], '')) + count(descendant::space[not(ancestor::note)]) + count(descendant::c[not(ancestor::note)])"
               />
            </xsl:perform-sort>
         </xsl:variable>
         <xsl:copy-of select="$sorted-cells[last()]"/>
      </xsl:variable>
      <xsl:variable name="tabellen-anzahl" as="xs:integer" select="count(ancestor::body//table)"/>
      <xsl:variable name="xml-id-part" as="xs:string" select="ancestor::TEI/@id"/>
      <xsl:text>\settowidth{\longeste}{</xsl:text>
      <xsl:value-of select="normalize-space($longest1)"/>
      <xsl:text>}</xsl:text>
      <xsl:if
         test="normalize-space($longest1) = 'Schnitzler' and normalize-space($longest2) = 'Erziehung zur Ehe'">
         <!-- Sonderfall einer Tabelle, wo eigentlich das vorletze Element länger ist -->
         <xsl:text>\addtolength\longeste{0.2em}</xsl:text>
      </xsl:if>
      <xsl:if test="contains(normalize-space($longest1), 'Morren')">
         <!-- Sonderfall einer Tabelle, wo eigentlich das vorletze Element länger ist -->
         <xsl:text>\settowidth\longeste{ABCDEFGHIJ}</xsl:text>
      </xsl:if>
      <xsl:text>\settowidth{\longestz}{</xsl:text>
      <xsl:value-of select="normalize-space($longest2)"/>
      <xsl:text>}</xsl:text>
      <xsl:text>\settowidth{\longestd}{</xsl:text>
      <xsl:value-of select="normalize-space($longest3)"/>
      <xsl:text>}</xsl:text>
      <xsl:text>\settowidth{\longestv}{</xsl:text>
      <xsl:value-of select="normalize-space($longest4)"/>
      <xsl:text>}</xsl:text>
      <xsl:text>\settowidth{\longestf}{</xsl:text>
      <xsl:value-of select="normalize-space($longest5)"/>
      <xsl:text>}</xsl:text>
      <xsl:choose>
         <xsl:when test="string-length($longest5) &gt; 0">
            <xsl:text>\addtolength\longeste{1em}
        \addtolength\longestz{0.5em}
        \addtolength\longestd{0.5em}
        \addtolength\longestv{0.5em}
        \addtolength\longestf{0.5em}</xsl:text>
         </xsl:when>
         <xsl:when test="string-length($longest4) &gt; 0">
            <xsl:text>\addtolength\longeste{1em}
        \addtolength\longestz{1em}
        \addtolength\longestd{1em}
        \addtolength\longestv{1em}
      </xsl:text>
         </xsl:when>
         <xsl:when test="string-length($longest3) &gt; 0">
            <xsl:text>\addtolength\longeste{1em}
        \addtolength\longestz{1em}
        \addtolength\longestd{1em}
      </xsl:text>
         </xsl:when>
         <xsl:otherwise>
            <xsl:text>\addtolength\longeste{1em}
        \addtolength\longestz{1em}
      </xsl:text>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:choose>
         <xsl:when test="starts-with($longest1, 'Chiav')">
            <xsl:text>\addtolength\longeste{2em}</xsl:text>
         </xsl:when>
      </xsl:choose>
      <xsl:choose>
         <xsl:when test="@cols &gt; 5">
            <xsl:text>\textcolor{red}{Tabellen mit mehr als fünf Spalten bislang nicht vorgesehen XXXXX}</xsl:text>
         </xsl:when>
         <xsl:otherwise>
            <xsl:for-each select="row">
               <xsl:text>&#10;\pstart\noindent</xsl:text>
               <xsl:text>\makebox[</xsl:text>
               <xsl:text>\the\longeste</xsl:text>
               <xsl:text>][l]{</xsl:text>
               <xsl:apply-templates select="cell[1]"/>
               <xsl:text>}</xsl:text>
               <xsl:text>\makebox[</xsl:text>
               <xsl:text>\the\longestz</xsl:text>
               <xsl:text>][l]{</xsl:text>
               <xsl:apply-templates select="cell[2]"/>
               <xsl:text>}
                  </xsl:text>
               <xsl:if test="string-length($longest3) &gt; 0">
                  <xsl:text>\makebox[</xsl:text>
                  <xsl:text>\the\longestd</xsl:text>
                  <xsl:text>][l]{</xsl:text>
                  <xsl:apply-templates select="cell[3]"/>
                  <xsl:text>}</xsl:text>
               </xsl:if>
               <xsl:if test="string-length($longest4) &gt; 0">
                  <xsl:text>\makebox[</xsl:text>
                  <xsl:text>\the\longestd</xsl:text>
                  <xsl:text>][l]{</xsl:text>
                  <xsl:apply-templates select="cell[4]"/>
                  <xsl:text>}</xsl:text>
               </xsl:if>
               <xsl:if test="string-length($longest5) &gt; 0">
                  <xsl:text>\makebox[</xsl:text>
                  <xsl:text>\the\longestd</xsl:text>
                  <xsl:text>][l]{</xsl:text>
                  <xsl:apply-templates select="cell[5]"/>
                  <xsl:text>}</xsl:text>
               </xsl:if>
               <xsl:text>\pend</xsl:text>
            </xsl:for-each>
         </xsl:otherwise>
      </xsl:choose>
   </xsl:template>
   <xsl:template match="table[@rend = 'group']">
      <xsl:text>\smallskip\hspace{-5.75em}\begin{tabular}{</xsl:text>
      <xsl:choose>
         <xsl:when test="@cols = 1">
            <xsl:text>l</xsl:text>
         </xsl:when>
         <xsl:when test="@cols = 2">
            <xsl:text>ll</xsl:text>
         </xsl:when>
         <xsl:when test="@cols = 3">
            <xsl:text>lll</xsl:text>
         </xsl:when>
      </xsl:choose>
      <xsl:text>}</xsl:text>
      <xsl:apply-templates/>
      <xsl:text>\end{tabular}</xsl:text>
   </xsl:template>
   <xsl:template match="table[ancestor::table]">
      <xsl:text>\begin{tabular}{</xsl:text>
      <xsl:choose>
         <xsl:when test="@cols = 1">
            <xsl:text>l</xsl:text>
         </xsl:when>
         <xsl:when test="@cols = 2">
            <xsl:text>ll</xsl:text>
         </xsl:when>
         <xsl:when test="@cols = 3">
            <xsl:text>lll</xsl:text>
         </xsl:when>
      </xsl:choose>
      <xsl:text>}</xsl:text>
      <xsl:apply-templates/>
      <xsl:text>\end{tabular}</xsl:text>
   </xsl:template>
   <xsl:template match="row[parent::table[@rend = 'group']]">
      <xsl:choose>
         <!-- Eine Klammer kriegen nur die, die auch mehr als zwei Zeilen haben -->
         <xsl:when test="child::cell/@role = 'label' and child::cell/table/row[2]">
            <xsl:text>$\left.</xsl:text>
            <xsl:apply-templates select="cell[not(@role = 'label')]"/>
            <xsl:text>\right\}$ </xsl:text>
            <xsl:apply-templates select="cell[@role = 'label']"/>
         </xsl:when>
         <xsl:when test="child::cell/@role = 'label' and not(child::cell/table/row[2])">
            <xsl:text>$\left.</xsl:text>
            <xsl:apply-templates select="cell[not(@role = 'label')]"/>
            <xsl:text>\right.$\hspace{0.9em}</xsl:text>
            <xsl:apply-templates select="cell[@role = 'label']"/>
         </xsl:when>
         <xsl:otherwise>
            <xsl:apply-templates/>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:choose>
         <xsl:when test="position() = last()"/>
         <xsl:otherwise>
            <xsl:text>\\ </xsl:text>
         </xsl:otherwise>
      </xsl:choose>
   </xsl:template>
   <xsl:template
      match="row[parent::table[not(@rend = 'group')] and ancestor::table[@rend = 'group']]">
      <xsl:apply-templates/>
      <xsl:choose>
         <xsl:when test="position() = last"/>
         <xsl:otherwise>
            <xsl:text>\\ </xsl:text>
         </xsl:otherwise>
      </xsl:choose>
   </xsl:template>
   <!-- Sonderfall anchors, die einen Text umrahmen, damit man auf eine Textstelle verweisen kann -->
   <xsl:template match="anchor[@type = 'label']">
      <xsl:choose>
         <xsl:when test="ends-with(@id, 'v') or ends-with(@id, 'h')">
            <xsl:text>\label{</xsl:text>
            <xsl:value-of select="@id"/>
            <xsl:text>}</xsl:text>
            <xsl:apply-templates/>
         </xsl:when>
         <xsl:otherwise>
            <xsl:text>\label{</xsl:text>
            <xsl:value-of select="@id"/>
            <xsl:text>v}</xsl:text>
            <xsl:apply-templates/>
            <xsl:text>\label{</xsl:text>
            <xsl:value-of select="@id"/>
            <xsl:text>h}</xsl:text>
         </xsl:otherwise>
      </xsl:choose>
   </xsl:template>
   <!-- anchors in Fussnoten, sehr seltener Fall-->
   <xsl:template
      match="anchor[(@type = 'textConst' or @type = 'commentary') and ancestor::note[@type = 'footnote']]">
      <xsl:variable name="xmlid" select="concat(@id, 'h')"/>
      <xsl:text>\label{</xsl:text>
      <xsl:value-of select="@id"/>
      <xsl:text>v}</xsl:text>
      <xsl:apply-templates/>
      <xsl:text>\toendnotes[C]{\footnotesize\hangpara{4em}{1}{\makebox[4em][l]{\makebox[3.6em][l]\zeilennummerierungsschrift{}\scriptsize Fußnote}}#1\endgraf}}\textit{</xsl:text>
      <xsl:for-each-group select="following-sibling::node()"
         group-ending-with="note[@type = 'commentary']">
         <xsl:if test="position() eq 1">
            <xsl:apply-templates select="current-group()[position() != last()]" mode="lemma"/>
            <xsl:text>}\,{]} </xsl:text>
            <xsl:apply-templates select="current-group()[position() = last()]" mode="text"/>
            <xsl:text>\endgraf}}</xsl:text>
         </xsl:if>
      </xsl:for-each-group>
   </xsl:template>
   <!-- Normaler anchor, Inhalt leer -->
   <xsl:template
      match="anchor[(@type = 'textConst' or @type = 'commentary') and not(ancestor::note[@type = 'footnote'])]">
      <xsl:text>\label{</xsl:text>
      <xsl:value-of select="@id"/>
      <xsl:text>v}</xsl:text>
      <xsl:text>\edtext{</xsl:text>
      <xsl:apply-templates/>
   </xsl:template>
   <xsl:template
      match="note[(@type = 'textConst' or @type = 'commentary') and not(ancestor::note[@type = 'footnote'])]"
      mode="lemma"/>
   <xsl:template match="space[@unit = 'chars' and @quantity = '1']" mode="lemma">
      <xsl:text> </xsl:text>
   </xsl:template>
   <xsl:template
      match="note[(@type = 'textConst' or @type = 'commentary') and not(ancestor::note[@type = 'footnote'])]">
      <xsl:text>}{</xsl:text>
      <!-- Der Teil hier bildet das Lemma und kürzt es -->
      <xsl:variable name="lemma-start" as="xs:string"
         select="substring(@id, 1, string-length(@id) - 1)"/>
      <xsl:variable name="lemma-end" as="xs:string" select="@id"/>
      <xsl:variable name="lemmaganz">
         <xsl:for-each-group
            select="ancestor::*/anchor[@id = $lemma-start]/following-sibling::node()"
            group-ending-with="note[@id = $lemma-end]">
            <xsl:if test="position() eq 1">
               <xsl:apply-templates select="current-group()[position() != last()]" mode="lemma"/>
            </xsl:if>
         </xsl:for-each-group>
      </xsl:variable>
      <xsl:variable name="lemma" as="xs:string">
         <xsl:choose>
            <xsl:when test="not(contains($lemmaganz, ' '))">
               <xsl:value-of select="$lemmaganz"/>
            </xsl:when>
            <xsl:when test="string-length(normalize-space($lemmaganz)) &gt; 24">
               <xsl:variable name="lemma-kurz"
                  select="concat(tokenize(normalize-space($lemmaganz), ' ')[1], ' … ', tokenize(normalize-space($lemmaganz), ' ')[last()])"/>
               <xsl:choose>
                  <xsl:when
                     test="string-length(normalize-space($lemmaganz)) - string-length($lemma-kurz) &lt; 5">
                     <xsl:value-of select="normalize-space($lemmaganz)"/>
                  </xsl:when>
                  <xsl:otherwise>
                     <xsl:value-of select="$lemma-kurz"/>
                  </xsl:otherwise>
               </xsl:choose>
            </xsl:when>
            <xsl:otherwise>
               <xsl:value-of select="$lemmaganz"/>
            </xsl:otherwise>
         </xsl:choose>
      </xsl:variable>
      <xsl:text>\lemma{\textnormal{\emph{</xsl:text>
      <xsl:choose>
         <xsl:when test="Lemma">
            <xsl:value-of select="Lemma"/>
         </xsl:when>
         <xsl:otherwise>
            <xsl:choose>
               <xsl:when test="string-length($lemma) &gt; 0">
                  <xsl:value-of select="$lemma"/>
               </xsl:when>
               <xsl:otherwise>
                  <xsl:text>XXXX Lemmafehler</xsl:text>
               </xsl:otherwise>
            </xsl:choose>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:text>}}}</xsl:text>
      <xsl:choose>
         <xsl:when test="@type = 'textConst'">
            <!-- Trennt TextConst und Kommentar auf, sonst nur CendNote  -->
            <xsl:text>\Aendnote{\textnormal{</xsl:text>
         </xsl:when>
         <xsl:otherwise>
            <xsl:text>\Cendnote{\foreignlanguage{ngerman}{\textnormal{</xsl:text>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="node() except Lemma"/>
      <xsl:choose>
         <xsl:when test="@type = 'textConst'">
            <!-- Trennt TextConst und Kommentar auf, sonst nur CendNote  -->
            <xsl:text>}}}</xsl:text>
         </xsl:when>
         <xsl:otherwise>
            <xsl:text>}}}}</xsl:text>
            <!-- eins mehr wegen foreignlanguage -->
         </xsl:otherwise>
      </xsl:choose>
      <!--<xsl:choose>
         <xsl:when test="ancestor::"></xsl:when>
      </xsl:choose>-->
      <xsl:text>\label{</xsl:text>
      <xsl:value-of select="@id"/>
      <xsl:text>}</xsl:text>
   </xsl:template>
   <xsl:template
      match="note[(@type = 'textConst' or @type = 'commentary') and (ancestor::note[@type = 'footnote'])]">
      <!--     <xsl:text>\toendnotes[C]{</xsl:text>
      <xsl:apply-templates/>
      <xsl:text>\par}</xsl:text>-->
      <xsl:text>\label{</xsl:text>
      <xsl:value-of select="@id"/>
      <xsl:text>}</xsl:text>
   </xsl:template>
   <xsl:template match="ptr">
      <xsl:text>XXXXXXXXXX</xsl:text>
      <xsl:if test="not(@arrow = 'no')">
         <xsl:text>$\triangleright$</xsl:text>
      </xsl:if>
      <xsl:text>\myrangeref{</xsl:text>
      <xsl:value-of select="@target"/>
      <xsl:text>v}{</xsl:text>
      <xsl:value-of select="@target"/>
      <xsl:text>h}</xsl:text>
   </xsl:template>
   <xsl:template match="cell[parent::row[parent::table[@rend = 'group']]]">
      <xsl:apply-templates/>
      <xsl:if test="following-sibling::cell">
         <xsl:text> </xsl:text>
      </xsl:if>
   </xsl:template>
   <xsl:template
      match="cell[parent::row[parent::table[not(@rend = 'group')]] and ancestor::table[@rend = 'group']]">
      <xsl:choose>
         <xsl:when test="position() = 1">
            <xsl:text>\makebox[0.2\textwidth][r]{</xsl:text>
            <xsl:apply-templates/>
            <xsl:text>}</xsl:text>
         </xsl:when>
         <xsl:when test="position() = 2">
            <xsl:text>\makebox[0.5\textwidth][l]{</xsl:text>
            <xsl:apply-templates/>
            <xsl:text>}</xsl:text>
         </xsl:when>
         <xsl:otherwise>
            <xsl:apply-templates/>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:if test="following-sibling::cell">
         <xsl:text>\newcell </xsl:text>
      </xsl:if>
   </xsl:template>
   <xsl:template match="opener">
      <xsl:apply-templates/>
   </xsl:template>
   <xsl:template match="encodingDesc/refsDecl/ab"/>
   <!-- Titel -->
   <xsl:template match="head">
      
      <xsl:choose>
         <xsl:when test="not(preceding-sibling::*)">
            <xsl:text>\nopagebreak[4] </xsl:text>
         </xsl:when>
         <xsl:otherwise>
            <xsl:text>\pagebreak[2] </xsl:text>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:if test=" ancestor::TEI/@id='P054'"><!-- der chronique theatrale eingriff -->
         <xsl:text> \vspace{-1.75cm}</xsl:text>
      </xsl:if>
      <xsl:choose>
         <xsl:when
            test="not(position() = 1) and not(preceding-sibling::*[1][self::head]) and @type = 'sub'">
            <!-- Es befindet sich im Text und direkt davor steht nicht schon ein head -->
            <xsl:text>&#10;{\centering\pstart[\vspace{0.25\baselineskip}]\noindent\leftskip=3em plus1fill\rightskip\leftskip
            </xsl:text>
         </xsl:when>
         <xsl:when test="not(position() = 1) and not(preceding-sibling::*[1][self::head])">
            <!-- Es befindet sich im Text und direkt davor steht nicht schon ein head -->
            <xsl:text>&#10;{\centering\pstart[\vspace{0.75\baselineskip}]\noindent\leftskip=3em plus1fill\rightskip\leftskip
            </xsl:text>
         </xsl:when>
         <xsl:otherwise>
            <!-- kein Abstand davor wenn es das erste Element-->
            <xsl:text>&#10;{\centering\pstart\noindent\leftskip=3em plus1fill\rightskip\leftskip
            </xsl:text>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:if test="not(@type = 'sub')">
         <xsl:text/>
         <xsl:text>\textbf{</xsl:text>
      </xsl:if>
      <xsl:apply-templates/>
      <xsl:if test="not(@type = 'sub')">
         <xsl:text>}</xsl:text>
      </xsl:if>
      <xsl:choose>
         <xsl:when test="not(following-sibling::*[1][self::head]) and @type = 'sub'">
            <xsl:text>&#10;\pend[\vspace{0.15\baselineskip}]}</xsl:text>
         </xsl:when>
         <xsl:when test="not(following-sibling::*[1][self::head])">
            <xsl:text>&#10;\pend[\vspace{0.5\baselineskip}]}</xsl:text>
         </xsl:when>
         <xsl:otherwise>
            <xsl:text>&#10;\pend}
            </xsl:text>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:text>&#10;\nopagebreak[4] </xsl:text>
   </xsl:template>
   <xsl:template match="head[ancestor::TEI[starts-with(@id, 'E_')]]">
      <xsl:choose>
         <xsl:when test="@type = 'sub'">
            <xsl:text>&#10;\subsection{</xsl:text>
         </xsl:when>
         <xsl:otherwise>
            <xsl:text>&#10;\section*{</xsl:text>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates/>
      <xsl:text>}\noindent{}</xsl:text>
   </xsl:template>
   <xsl:template match="div[@type = 'image']">
      <xsl:apply-templates select="figure"/>
   </xsl:template>
   <xsl:template match="address">
      <xsl:apply-templates/>
      <xsl:text>&#10;{\bigskip}</xsl:text>
   </xsl:template>
   <xsl:template match="addrLine">
      <xsl:text>&#10;\pstart{}</xsl:text>
      <xsl:apply-templates/>
      <xsl:text>&#10;\pend{}</xsl:text>
   </xsl:template>
   <xsl:template match="postscript">
      <!--<xsl:text>\noindent{}</xsl:text>-->
      <xsl:apply-templates/>
   </xsl:template>
   <xsl:template match="quote">
      <xsl:if test="not(child::foreign)">
         <xsl:text>\foreignlanguage{german}{</xsl:text>
      </xsl:if>
      <xsl:choose>
         <xsl:when
            test="ancestor::physDesc | ancestor::note[@type = 'commentary'] | ancestor::note[@type = 'textConst'] | ancestor::div[@type = 'biographical']">
            <xsl:apply-templates/>
         </xsl:when>
         <xsl:when test="ancestor::TEI[substring(@id, 1, 1) = 'E']">
            <xsl:choose>
               <xsl:when test="substring(current(), 1, 1) = '»' and @type = 'poem'">
                  <xsl:text>&#10;\begin{quoting}[leftmargin=5em]\noindent{}</xsl:text>
                  <xsl:apply-templates/>
                  <xsl:text>&#10;\normalsize\end{quoting}</xsl:text>
               </xsl:when>
               <xsl:when test="substring(current(), 1, 1) = '»'">
                  <xsl:text>&#10;\begin{quoting}\noindent{}</xsl:text>
                  <xsl:apply-templates/>
                  <xsl:text>&#10;\normalsize\end{quoting}</xsl:text>
               </xsl:when>
               <xsl:otherwise>
                  <xsl:apply-templates/>
               </xsl:otherwise>
            </xsl:choose>
         </xsl:when>
         <xsl:otherwise>
            <xsl:text>&#10;\begin{quotation}\noindent{}</xsl:text>
            <xsl:apply-templates/>
            <xsl:text>&#10;\end{quotation}</xsl:text>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:if test="not(child::foreign)">
         <xsl:text>}</xsl:text>
      </xsl:if>
   </xsl:template>
   <xsl:template match="lg[@type = 'poem']">
      <xsl:choose>
         <xsl:when test="@latex">
            <xsl:text>&#10;\settowidth{\mylength}{</xsl:text>
            <xsl:value-of select="@latex"/>
            <xsl:text>}</xsl:text>
            <xsl:text>&#10;\setlength{\remainingwidth}{\dimexpr 0.5\fullwidth - 0.5\mylength \relax}</xsl:text>
            <xsl:text>&#10;\setlength{\stanzaindentbase}{\remainingwidth}</xsl:text>
         </xsl:when>
         <xsl:otherwise>
            <xsl:text>&#10;\setlength{\stanzaindentbase}{20pt}</xsl:text>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:choose>
         <xsl:when test="child::lg[@type = 'stanza']">
            <xsl:apply-templates/>
         </xsl:when>
         <xsl:otherwise>
            <xsl:text>\stanza[\vspace{\parskip}]{}</xsl:text>
            <xsl:apply-templates/>
            <xsl:text>\stanzaend[\vspace{\parskip}]{}</xsl:text>
         </xsl:otherwise>
      </xsl:choose>
   </xsl:template>
   <xsl:template match="lg[@type = 'stanza']">
      <xsl:text>\stanza[\vspace\parskip]{{}</xsl:text>
      <xsl:apply-templates/>
      <xsl:text>\stanzaend[\vspace\parskip]{{}</xsl:text>
   </xsl:template>
   <xsl:template match="l[ancestor::lg[@type = 'poem']]">
      <xsl:if test="@rend = 'inline'">
         <xsl:text>\stanzaindent{2}</xsl:text>
      </xsl:if>
      <xsl:if test="@rend = 'center'">
         <xsl:text>\centering{}</xsl:text>
      </xsl:if>
      <xsl:apply-templates/>
      <xsl:if test="following-sibling::l">
         <xsl:text>\newverse{}</xsl:text>
      </xsl:if>
   </xsl:template>
   <!-- Pagebreaks -->
   <xsl:template match="pb">
      <xsl:text>{\pb}</xsl:text>
   </xsl:template>
   <!-- Kaufmanns-Und & -->
   <xsl:template match="c[@rendition = '#kaufmannsund']">
      <xsl:text>{\kaufmannsund}</xsl:text>
   </xsl:template>
   <xsl:template match="c[@rendition = '#ornament']">
      <xsl:text>\vspace{0.75\baselineskip}</xsl:text>
      <xsl:text>\hspace{-1em}\raisebox{1pt}{*}\hspace{1em}\raisebox{-2pt}{*}\hspace{1em}\raisebox{1pt}{*}</xsl:text>
      <xsl:text>\vspace{1.25\baselineskip}</xsl:text>
   </xsl:template>
   <xsl:template match="c[@rendition = '#geschwungene-klammer-auf']">
      <xsl:text>{\{}</xsl:text>
   </xsl:template>
   <xsl:template match="c[@rendition = '#geschwungene-klammer-zu']">
      <xsl:text>{\}}</xsl:text>
   </xsl:template>
   <!-- Geminationsstriche -->
   <xsl:template match="c[@rendition = '#gemination-m']">
      <xsl:text>{\geminationm}</xsl:text>
   </xsl:template>
   <xsl:template match="c[@rendition = '#gemination-n']">
      <xsl:text>{\geminationn}</xsl:text>
   </xsl:template>
   <!-- Prozentzeichen % -->
   <xsl:template match="c[@rendition = '#prozent']">
      <xsl:text>{\%}</xsl:text>
   </xsl:template>
   <!-- Dollarzeichen $ -->
   <xsl:template match="c[@rendition = '#dollar']">
      <xsl:text>{\$}</xsl:text>
   </xsl:template>
   <!-- Unterstreichung -->
   <xsl:template match="hi[@rend = 'underline']">
      <xsl:choose>
         <xsl:when
            test="parent::hi[@rend = 'superscript'] | parent::hi[parent::signed and @rend = 'overline'] | ancestor::addrLine">
            <xsl:apply-templates/>
         </xsl:when>
         <xsl:when test="not(@n)">
            <xsl:text>\textcolor{red}{UNTERSTREICHUNG FEHLER:</xsl:text>
            <xsl:apply-templates/>
            <xsl:text>}</xsl:text>
         </xsl:when>
         <xsl:when test="@hand or @n = '1'">
            <xsl:choose>
               <xsl:when
                  test="contains(., 'y') or contains(., 'g') or contains(., 'p') or contains(., 'q')">
                  <xsl:text>\setul{}{0.3pt}\setuldepth{ygpq}</xsl:text>
                  <xsl:text>\ul{</xsl:text>
                  <xsl:apply-templates/>
                  <xsl:text>}\setuldepth{a}</xsl:text>
               </xsl:when>
               <xsl:when test="contains(., ',') or contains(., ';')">
                  <xsl:text>\setul{}{0.3pt}\setuldepth{,;}</xsl:text>
                  <xsl:text>\ul{</xsl:text>
                  <xsl:apply-templates/>
                  <xsl:text>}\setuldepth{a}</xsl:text>
               </xsl:when>
               <xsl:otherwise>
                  <xsl:text>\ul{</xsl:text>
                  <xsl:apply-templates/>
                  <xsl:text>}</xsl:text>
               </xsl:otherwise>
            </xsl:choose>
         </xsl:when>
         <xsl:when test="@n = '2'">
            <xsl:text>\uuline{</xsl:text>
            <xsl:apply-templates/>
            <xsl:text>}</xsl:text>
         </xsl:when>
         <xsl:otherwise>
            <xsl:text>\uuline{\edtext{</xsl:text>
            <xsl:apply-templates/>
            <xsl:text>}{</xsl:text>
            <xsl:if test="@n &gt; 2">
               <xsl:text>\Cendnote{</xsl:text>
               <xsl:choose>
                  <xsl:when test="@n = 3">
                     <xsl:text>Drei</xsl:text>
                  </xsl:when>
                  <xsl:when test="@n = 4">
                     <xsl:text>Vier</xsl:text>
                  </xsl:when>
                  <xsl:when test="@n = 5">
                     <xsl:text>Fünf</xsl:text>
                  </xsl:when>
                  <xsl:when test="@n = 6">
                     <xsl:text>Sechs</xsl:text>
                  </xsl:when>
                  <xsl:when test="@n = 7">
                     <xsl:text>Sieben</xsl:text>
                  </xsl:when>
                  <xsl:when test="@n = 8">
                     <xsl:text>Acht</xsl:text>
                  </xsl:when>
                  <xsl:when test="@n &gt; 8">
                     <xsl:text>Unendlich viele Quatrillionentrilliarden und noch viel mehrmal unterstrichen</xsl:text>
                  </xsl:when>
               </xsl:choose>
               <xsl:text>fach unterstrichen.</xsl:text>
               <xsl:text>}}}</xsl:text>
            </xsl:if>
         </xsl:otherwise>
      </xsl:choose>
   </xsl:template>
   <xsl:template match="hi[@rend = 'overline']">
      <xsl:choose>
         <xsl:when test="parent::signed | ancestor::addressLine">
            <xsl:apply-templates/>
         </xsl:when>
         <xsl:otherwise>
            <xsl:text>\textoverline{</xsl:text>
            <xsl:apply-templates/>
            <xsl:text>}</xsl:text>
         </xsl:otherwise>
      </xsl:choose>
   </xsl:template>
   <!-- Herausgebereingriff -->
   <xsl:template match="supplied[not(parent::damage)]">
      <xsl:text disable-output-escaping="yes">{[}</xsl:text>
      <xsl:apply-templates/>
      <xsl:text disable-output-escaping="yes">{]}</xsl:text>
   </xsl:template>
   <!-- Unleserlich, unsicher Entziffertes -->
   <xsl:template match="unclear">
      <xsl:text>\textcolor{gray}{</xsl:text>
      <xsl:apply-templates/>
      <xsl:text>}</xsl:text>
   </xsl:template>
   <!-- Durch Zerstörung unleserlich. Text ist stets Herausgebereingriff -->
   <xsl:template match="damage">
      <xsl:text>\damage{</xsl:text>
      <xsl:apply-templates/>
      <xsl:text>}</xsl:text>
   </xsl:template>
   <!-- Loch / Unentziffertes -->
   <xsl:function name="foo:gapigap">
      <xsl:param name="gapchars" as="xs:integer"/>
      <xsl:text>\textcolor{gray}{×}</xsl:text>
      <xsl:if test="$gapchars &gt; 1">
         <xsl:text>\-</xsl:text>
         <xsl:value-of select="foo:gapigap($gapchars - 1)"/>
      </xsl:if>
   </xsl:function>
   <xsl:template match="gap[@unit = 'chars' and @reason = 'illegible']">
      <xsl:value-of select="foo:gapigap(@quantity)"/>
   </xsl:template>
   <xsl:template match="gap[@unit = 'lines' and @reason = 'illegible']">
      <xsl:text>\textcolor{gray}{[</xsl:text>
      <xsl:value-of select="@quantity"/>
      <xsl:text> Zeilen unleserlich{]} </xsl:text>
      <xsl:text>}</xsl:text>
   </xsl:template>
   <xsl:template match="gap[@reason = 'outOfScope']">
      <xsl:text>{[}\ldots{]}</xsl:text>
   </xsl:template>
   <xsl:template match="gap[@reason = 'gabelsberger']">
      <xsl:text>\textcolor{BurntOrange}{[Gabelsberger]}</xsl:text>
   </xsl:template>
   <xsl:function name="foo:punkte">
      <xsl:param name="nona" as="xs:integer"/>
      <xsl:text>.</xsl:text>
      <xsl:if test="$nona - 1 &gt; 0">
         <xsl:value-of select="foo:punkte($nona - 1)"/>
      </xsl:if>
   </xsl:function>
   <!-- Auslassungszeichen, drei Punkte, mehr Punkte -->
   <xsl:template match="c[@rendition = '#dots']">
      <!-- <xsl:choose>-->
      <!-- <xsl:when test="@place='center'">-->
      <xsl:choose>
         <xsl:when test="@n = '3'">
            <xsl:text>{\dots}</xsl:text>
         </xsl:when>
         <xsl:when test="@n = '4'">
            <xsl:text>{\dotsfour}</xsl:text>
         </xsl:when>
         <xsl:when test="@n = '5'">
            <xsl:text>{\dotsfive}</xsl:text>
         </xsl:when>
         <xsl:when test="@n = '6'">
            <xsl:text>{\dotssix}</xsl:text>
         </xsl:when>
         <xsl:when test="@n = '7'">
            <xsl:text>{\dotsseven}</xsl:text>
         </xsl:when>
         <xsl:when test="@n = '2'">
            <xsl:text>{\dotstwo}</xsl:text>
         </xsl:when>
         <xsl:otherwise>
            <xsl:value-of select="foo:punkte(@n)"/>
         </xsl:otherwise>
      </xsl:choose>
      <!--</xsl:when>-->
      <!--<xsl:otherwise>
            <xsl:choose>
               <xsl:when test="@n='3'">
                  <xsl:text>\dots </xsl:text>
               </xsl:when>
               <xsl:when test="@n='4'">
                  <xsl:text>\dotsfour </xsl:text>
               </xsl:when>
               <xsl:when test="@n='5'">
                  <xsl:text>\dotsfive </xsl:text>
               </xsl:when>
               <xsl:when test="@n='6'">
                  <xsl:text>\dotssix </xsl:text>
               </xsl:when>
               <xsl:when test="@n='7'">
                  <xsl:text>\dotsseven </xsl:text>
               </xsl:when>
               <xsl:when test="@n='2'">
                  <xsl:text>\dotstwo </xsl:text>
               </xsl:when>
               <xsl:otherwise>
                  <xsl:text>\textcolor{red}{XXXX Punkte Fehler!!!}</xsl:text>
               </xsl:otherwise>
            </xsl:choose>
         </xsl:otherwise>
      </xsl:choose>-->
   </xsl:template>
   <xsl:template match="p[child::space[@dim] and not(child::*[2]) and empty(text())]">
      <xsl:text>{\bigskip}</xsl:text>
   </xsl:template>
   <xsl:template match="space[@dim = 'vertical']">
      <xsl:text>{\vspace{</xsl:text>
      <xsl:value-of select="@quantity"/>
      <xsl:text>\baselineskip}}</xsl:text>
   </xsl:template>
   <xsl:template match="space[@unit = 'chars']">
      <xsl:choose>
         <xsl:when test="@style = 'hfill' and not(following-sibling::node()[1][self::signed])"/>
         <xsl:when
            test="@quantity = 1 and not(string-length(normalize-space(parent::p)) = 0 and parent::p[child::*[1] = space[@unit = 'chars' and @quantity = '1']] and parent::p[not(child::*[2])])">
            <xsl:text>{ }</xsl:text>
         </xsl:when>
         <xsl:otherwise>
            <xsl:text>\hspace*{</xsl:text>
            <xsl:value-of select="0.5 * @quantity"/>
            <xsl:text>em}</xsl:text>
         </xsl:otherwise>
      </xsl:choose>
   </xsl:template>
   <xsl:template match="signed">
      <xsl:text>\spacefill</xsl:text>
      <xsl:text>\mbox{</xsl:text>
      <xsl:apply-templates/>
      <xsl:text>}</xsl:text>
   </xsl:template>
   <!-- Hinzufügung im Text -->
   <xsl:template match="add[@place and not(parent::subst)]">
      <xsl:text>\introOben{}</xsl:text>
      <xsl:apply-templates/>
      <xsl:text>\introOben{}</xsl:text>
   </xsl:template>
   <!-- Streichung -->
   <xsl:template match="del[not(parent::subst)]">
      <xsl:text>\setul{-3pt}{0.3pt}\ul{</xsl:text>
      <xsl:apply-templates/>
      <xsl:text>}\resetul{}</xsl:text>
   </xsl:template>
   <xsl:template match="del[parent::subst]">
      <xsl:apply-templates/>
   </xsl:template>
   <xsl:template match="hyphenation">
      <xsl:choose>
         <xsl:when test="@alt">
            <xsl:value-of select="@alt"/>
         </xsl:when>
         <xsl:otherwise>
            <xsl:apply-templates/>
         </xsl:otherwise>
      </xsl:choose>
   </xsl:template>
   <!-- Substi -->
   <xsl:template match="subst">
      <xsl:text>\substVorne{}\textsuperscript{</xsl:text>
      <xsl:apply-templates select="del"/>
      <xsl:text>}</xsl:text>
      <xsl:if test="string-length(del) &gt; 5">
         <xsl:text>{\allowbreak}</xsl:text>
      </xsl:if>
      <xsl:text>\substDazwischen{}</xsl:text>
      <xsl:apply-templates select="add"/>
      <xsl:text>\substHinten{}</xsl:text>
   </xsl:template>
   <!-- Wechsel der Schreiber <handShift -->
   <xsl:template match="handShift[not(@scribe)]">
      <xsl:choose>
         <xsl:when test="@medium = 'typewriter'">
            <xsl:text>{[}ms.:{]} </xsl:text>
         </xsl:when>
         <xsl:otherwise>
            <xsl:text>{[}hs.:{]} </xsl:text>
         </xsl:otherwise>
      </xsl:choose>
   </xsl:template>
   <xsl:template match="handShift[@scribe]">
      <xsl:text>{[}hs. </xsl:text>
      <xsl:choose>
         <!-- Sonderregel für den von Hermine Benedict und  Hofmansnthal verfassten Brief -->
         <xsl:when test="ancestor::TEI[@id = 'L042294'] and @scribe = 'A002011'">
            <xsl:text>H.</xsl:text>
         </xsl:when>
         <xsl:when test="ancestor::TEI[@id = 'L042294'] and @scribe = 'A002406'">
            <xsl:text>B.</xsl:text>
         </xsl:when>
         <!-- Sonderregel für Gerty Schlesinger -->
         <xsl:when
            test="ancestor::TEI[@id = 'L041802'] and (@scribe = 'A003800' or @scribe = 'A004750' or @scribe = 'A004756')">
            <xsl:value-of
               select="substring(normalize-space(key('person-lookup', (@scribe), $persons)/tei:persName/tei:forename), 1)"/>
            <xsl:text> </xsl:text>
            <xsl:value-of
               select="substring(normalize-space(key('person-lookup', (@scribe), $persons)/tei:persName/tei:surname), 1)"
            />
         </xsl:when>
         <xsl:when
            test="@scribe = 'A002134' and ancestor::TEI/teiHeader[1]/fileDesc[1]/sourceDesc[1]/correspDesc[1]/dateSender[1]/date[1][starts-with(@when, '18')]">
            <xsl:text>G. Schlesinger</xsl:text>
         </xsl:when>
         <xsl:when test="@scribe = 'A003025'">
            <xsl:text>Georg von Franckenstein</xsl:text>
         </xsl:when>
         <xsl:otherwise>
            <xsl:choose>
               <!-- Sonderregeln wenn Gerty, Julie Wassermann, Mary Mell und Olga im gleichen Brief vorkommen wie Schnitzler und Hofmannsthal -->
               <xsl:when
                  test="@scribe = '#pmb2173' and ancestor::TEI/teiHeader[1]/fileDesc[1]/titleStmt[1]/author/@ref = '#pmb2121'">
                  <xsl:value-of
                     select="substring(normalize-space(key('person-lookup', (@scribe), $persons)/tei:persName/tei:forename), 1, 1)"/>
                  <xsl:text>. </xsl:text>
               </xsl:when>
               <!-- Wassermann: -->
               <xsl:when
                  test="@scribe = '#pmb13058' and ancestor::TEI/teiHeader[1]/fileDesc[1]/titleStmt[1]/author/@ref = '#pmb13055'">
                  <xsl:value-of
                     select="normalize-space(key('person-lookup', (@scribe), $persons)/tei:persName/tei:forename)"
                  />
               </xsl:when>
               <!-- Mary Mell -->
               <xsl:when
                  test="@scribe = '#pmb5765' and ancestor::TEI/teiHeader[1]/fileDesc[1]/titleStmt[1]/author/@ref = '#pmb12225'">
                  <xsl:value-of
                     select="normalize-space(key('person-lookup', (@scribe), $persons)/tei:persName/tei:forename)"
                  />
               </xsl:when>
               <xsl:when
                  test="@scribe = '#pmb2292' and ancestor::TEI/teiHeader[1]/fileDesc[1]/titleStmt[1]/author/@ref = '#pmb11740'">
                  <xsl:value-of
                     select="substring(normalize-space(key('person-lookup', (@scribe), $persons)/tei:persName/tei:forename), 1, 1)"/>
                  <xsl:text>. </xsl:text>
               </xsl:when>
               <xsl:when
                  test="@scribe = '#pmb27886' and ancestor::TEI/teiHeader[1]/fileDesc[1]/titleStmt[1]/author/@ref = '#pmb27882'">
                  <xsl:value-of
                     select="substring(normalize-space(key('person-lookup', (@scribe), $persons)/tei:persName/tei:forename), 1, 1)"/>
                  <xsl:text>. </xsl:text>
               </xsl:when>
               <xsl:when
                  test="@scribe = '#pmb23918' and ancestor::TEI/teiHeader[1]/fileDesc[1]/titleStmt[1]/author/@ref = '#pmb2167'">
                  <xsl:value-of
                     select="substring(normalize-space(key('person-lookup', (@scribe), $persons)/tei:persName/tei:forename), 1, 1)"/>
                  <xsl:text>. </xsl:text>
               </xsl:when>
            </xsl:choose>
            <xsl:value-of
               select="normalize-space(key('person-lookup', (@scribe), $persons)/tei:persName/tei:surname)"/>
            <!-- Sonderregel für Hofmannsthal senior -->
            <xsl:if test="@scribe = '#pmb11737'">
               <xsl:text> (sen.)</xsl:text>
            </xsl:if>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:text>:{]} </xsl:text>
      <!--  <xsl:if test="ancestor::TEI/teiHeader/fileDesc/titleStmt/author/@ref != @scribe">
      <xsl:value-of select="foo:person-in-index(@scribe,true())"/>
      <xsl:text>}</xsl:text>
      </xsl:if>-->
   </xsl:template>
   <!-- Kursiver Text für Schriftwechsel in den Handschriften-->
   <xsl:template match="hi[@rend = 'latintype']">
      <xsl:choose>
         <xsl:when test="ancestor::signed">
            <xsl:apply-templates/>
         </xsl:when>
         <xsl:otherwise>
            <xsl:text>\textsc{</xsl:text>
            <xsl:apply-templates/>
            <xsl:text>}</xsl:text>
         </xsl:otherwise>
      </xsl:choose>
   </xsl:template>
   <!-- Fett und grau für Vorgedrucktes-->
   <xsl:template match="hi[@rend = 'pre-print']">
      <xsl:text>\textcolor{gray}{</xsl:text>
      <xsl:text>\textbf{</xsl:text>
      <xsl:apply-templates/>
      <xsl:text>}}</xsl:text>
   </xsl:template>
   <!-- Fett, grau und kursiv für Stempel-->
   <xsl:template match="hi[@rend = 'stamp']">
      <xsl:text>\textcolor{gray}{</xsl:text>
      <xsl:text>\textbf{\textit{</xsl:text>
      <xsl:apply-templates/>
      <xsl:text>}}}</xsl:text>
   </xsl:template>
   <!-- Gabelsberger, wird derzeit Orange ausgewiesen -->
   <xsl:template match="hi[@rend = 'gabelsberger']">
      <xsl:apply-templates/>
   </xsl:template>
   <!-- Kursiver Text für Schriftwechsel im gedruckten Text-->
   <xsl:template match="hi[@rend = 'antiqua']">
      <xsl:text>\textsc{</xsl:text>
      <xsl:apply-templates/>
      <xsl:text>}</xsl:text>
   </xsl:template>
   <!-- Kursiver Text -->
   <xsl:template match="hi[@rend = 'italics']">
      <xsl:text>\emph{</xsl:text>
      <xsl:apply-templates/>
      <xsl:text>}</xsl:text>
   </xsl:template>
   <!-- Fetter Text -->
   <xsl:template match="hi[@rend = 'bold']">
      <xsl:choose>
         <xsl:when test="ancestor::head | parent::signed">
            <xsl:apply-templates/>
         </xsl:when>
         <xsl:otherwise>
            <xsl:text>\textbf{</xsl:text>
            <xsl:apply-templates/>
            <xsl:text>}</xsl:text>
         </xsl:otherwise>
      </xsl:choose>
   </xsl:template>
   <!-- Kapitälchen -->
   <xsl:template match="hi[@rend = 'small_caps']">
      <xsl:text>\textsc{</xsl:text>
      <xsl:apply-templates/>
      <xsl:text>}</xsl:text>
   </xsl:template>
   <!-- Großbuchstaben -->
   <xsl:template
      match="hi[@rend = 'capitals' and not(descendant::note or descendant::note[@type = 'footnote'])]//text()">
      <xsl:value-of select="upper-case(.)"/>
   </xsl:template>
   <xsl:template
      match="hi[@rend = 'capitals' and (descendant::note or descendant::note[@type = 'footnote'])]//text()">
      <xsl:choose>
         <xsl:when
            test="ancestor-or-self::note[@type = 'footnote' and not(descendant::hi[@rend = 'capitals'])] | ancestor-or-self::note[not(descendant::hi[@rend = 'capitals'])]">
            <xsl:value-of select="."/>
         </xsl:when>
         <xsl:otherwise>
            <xsl:value-of select="upper-case(.)"/>
         </xsl:otherwise>
      </xsl:choose>
   </xsl:template>
   <!-- Gesperrter Text -->
   <xsl:template match="hi[@rend = 'spaced_out']">
      <xsl:choose>
         <xsl:when test="ancestor::TEI/descendant::hi[@rend = 'italics'] or @n='latex'">
            <xsl:text>\so{</xsl:text>
            <xsl:apply-templates/>
            <xsl:text>}</xsl:text>
         </xsl:when>
         <xsl:otherwise>
            <xsl:text>\emph{</xsl:text>
            <xsl:apply-templates/>
            <xsl:text>}</xsl:text>
         </xsl:otherwise>
      </xsl:choose>
      <!--  
         <xsl:when test="not(child::*[1])">
            <xsl:text>\so{</xsl:text>
            <xsl:choose>
               <xsl:when test="starts-with(text(), ' ')">
                  <xsl:text> </xsl:text>
                  <xsl:value-of select="normalize-space(text())"/>
               </xsl:when>
               <xsl:otherwise>
                  <xsl:value-of select="normalize-space(text())"/>
               </xsl:otherwise>
            </xsl:choose>
            <xsl:if test="ends-with(text(), ' ')">
               <xsl:text> </xsl:text>
            </xsl:if>
            <xsl:text>}</xsl:text>
         </xsl:when>
         <xsl:otherwise>
            <xsl:text>\so{</xsl:text>
            <xsl:apply-templates/>
            <xsl:text>}</xsl:text>
         </xsl:otherwise>
      </xsl:choose>-->
   </xsl:template>
   <!-- Hochstellung -->
   <xsl:template match="hi[@rend = 'superscript']">
      <xsl:text>\textsuperscript{</xsl:text>
      <xsl:apply-templates/>
      <xsl:text>}</xsl:text>
   </xsl:template>
   <!-- Tiefstellung -->
   <xsl:template match="hi[@rend = 'subscript']">
      <xsl:text>\textsubscript{</xsl:text>
      <xsl:apply-templates/>
      <xsl:text>}</xsl:text>
   </xsl:template>
   <xsl:template match="note[@type = 'introduction']">
      <xsl:text>[</xsl:text>
      <xsl:apply-templates/>
      <xsl:text>] </xsl:text>
   </xsl:template>
   <!-- Dieses Template bereitet den Schriftwechsel für griechische Zeichen vor -->
   <xsl:template match="foreign[starts-with(@lang, 'el') or starts-with(@xml:lang, 'el')]">
      <xsl:text>\griechisch{</xsl:text>
      <xsl:apply-templates/>
      <xsl:text>}</xsl:text>
   </xsl:template>
   <xsl:template match="foreign[starts-with(@lang, 'en') or starts-with(@xml:lang, 'en')]">
      <xsl:text>\begin{otherlanguage}{english}</xsl:text>
      <xsl:apply-templates/>
      <xsl:text>\end{otherlanguage}</xsl:text>
   </xsl:template>
   <xsl:template match="foreign[starts-with(@lang, 'fr') or starts-with(@xml:lang, 'fr')]">
      <xsl:text>\begin{otherlanguage}{french}</xsl:text>
      <xsl:apply-templates/>
      <xsl:text>\end{otherlanguage}</xsl:text>
   </xsl:template>
   <xsl:template match="foreign[starts-with(@lang, 'ru') or starts-with(@xml:lang, 'ru')]">
      <xsl:text>\begin{otherlanguage}{russian}\cyrillic{</xsl:text>
      <xsl:apply-templates/>
      <xsl:text>}\end{otherlanguage}</xsl:text>
   </xsl:template>
   <xsl:template match="foreign[starts-with(@lang, 'hu') or starts-with(@xml:lang, 'hu')]">
      <xsl:text>\begin{otherlanguage}{magyar}</xsl:text>
      <xsl:apply-templates/>
      <xsl:text>\end{otherlanguage}</xsl:text>
   </xsl:template>
   <xsl:template match="foreign[starts-with(@xml:lang, 'dk') or starts-with(@lang, 'dk')]">
      <xsl:text>\begin{otherlanguage}{dansk}</xsl:text>
      <xsl:apply-templates/>
      <xsl:text>\end{otherlanguage}</xsl:text>
   </xsl:template>
   <xsl:template match="foreign[starts-with(@xml:lang, 'nl') or starts-with(@lang, 'nl')]">
      <xsl:text>\begin{otherlanguage}{dutch}</xsl:text>
      <xsl:apply-templates/>
      <xsl:text>\end{otherlanguage}</xsl:text>
   </xsl:template>
   <xsl:template match="foreign[starts-with(@xml:lang, 'sv') or starts-with(@lang, 'sv')]">
      <xsl:text>\begin{otherlanguage}{swedish}</xsl:text>
      <xsl:apply-templates/>
      <xsl:text>\end{otherlanguage}</xsl:text>
   </xsl:template>
   <xsl:template match="foreign[starts-with(@xml:lang, 'it') or starts-with(@lang, 'it')]">
      <xsl:text>\begin{otherlanguage}{italian}</xsl:text>
      <xsl:apply-templates/>
      <xsl:text>\end{otherlanguage}</xsl:text>
   </xsl:template>
   <!-- Ab hier PERSONENINDEX, WERKINDEX UND ORTSINDEX -->
   <!-- Diese Funktion setzt die Fußnoten und Indexeinträge der Personen, wobei übergeben wird, ob man sich gerade im 
  Fließtext oder in Paratexten befindet und ob die Person namentlich genannt oder nur auf sie verwiesen wird -->
   <!-- Diese Funktion setzt das lemma -->
   <xsl:function name="foo:lemma">
      <xsl:param name="lemmatext" as="xs:string"/>
      <xsl:text>\lemma{</xsl:text>
      <xsl:choose>
         <xsl:when
            test="string-length(normalize-space($lemmatext)) gt 30 and count(tokenize($lemmatext, ' ')) gt 5">
            <xsl:value-of select="tokenize($lemmatext, ' ')[1]"/>
            <xsl:choose>
               <xsl:when test="tokenize($lemmatext, ' ')[2] = ':'">
                  <xsl:value-of select="tokenize($lemmatext, ' ')[2]"/>
                  <xsl:text> </xsl:text>
                  <xsl:value-of select="tokenize($lemmatext, ' ')[3]"/>
               </xsl:when>
               <xsl:when test="tokenize($lemmatext, ' ')[2] = ';'">
                  <xsl:value-of select="tokenize($lemmatext, ' ')[2]"/>
                  <xsl:text> </xsl:text>
                  <xsl:value-of select="tokenize($lemmatext, ' ')[3]"/>
               </xsl:when>
               <xsl:when test="tokenize($lemmatext, ' ')[2] = '!'">
                  <xsl:value-of select="tokenize($lemmatext, ' ')[2]"/>
                  <xsl:text> </xsl:text>
                  <xsl:value-of select="tokenize($lemmatext, ' ')[3]"/>
               </xsl:when>
               <xsl:when test="tokenize($lemmatext, ' ')[2] = '«'">
                  <xsl:value-of select="tokenize($lemmatext, ' ')[2]"/>
                  <xsl:text> </xsl:text>
                  <xsl:value-of select="tokenize($lemmatext, ' ')[3]"/>
               </xsl:when>
               <xsl:when test="tokenize($lemmatext, ' ')[2] = '.'">
                  <xsl:value-of select="tokenize($lemmatext, ' ')[2]"/>
                  <xsl:text> </xsl:text>
                  <xsl:value-of select="tokenize($lemmatext, ' ')[3]"/>
               </xsl:when>
               <xsl:otherwise>
                  <xsl:text> </xsl:text>
                  <xsl:value-of select="tokenize($lemmatext, ' ')[2]"/>
               </xsl:otherwise>
            </xsl:choose>
            <xsl:text> {\mdseries\ldots} </xsl:text>
            <xsl:value-of select="tokenize($lemmatext, ' ')[last()]"/>
         </xsl:when>
         <xsl:otherwise>
            <xsl:value-of select="$lemmatext"/>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:text>}</xsl:text>
   </xsl:function>
   <xsl:function name="foo:personInEndnote">
      <xsl:param name="first" as="xs:string"/>
      <xsl:param name="verweis" as="xs:boolean"/>
      <xsl:variable name="entry" select="key('person-lookup', $first, $persons)"/>
      <xsl:if test="$verweis">
         <xsl:text>$\rightarrow$</xsl:text>
      </xsl:if>
      <xsl:choose>
         <xsl:when test="$first = ''">
            <xsl:text>\textsuperscript{\textbf{\textcolor{red}{PERSON OFFEN}}}</xsl:text>
         </xsl:when>
         <xsl:otherwise>
            <xsl:choose>
               <xsl:when
                  test="empty($entry/tei:persName/tei:forename) and not(empty($entry/tei:persName/tei:surname))">
                  <xsl:value-of select="normalize-space($entry[1]/tei:persName/tei:surname)"/>
               </xsl:when>
               <xsl:when
                  test="empty($entry/tei:persName/tei:surname) and not(empty($entry/tei:persName/tei:forename))">
                  <xsl:value-of select="normalize-space($entry[1]/tei:persName/tei:forename)"/>
               </xsl:when>
               <xsl:otherwise>
                  <xsl:value-of
                     select="concat(normalize-space($entry[1]/tei:persName/tei:forename[1]), ' ', normalize-space($entry[1]/tei:persName/tei:surname))"
                  />
               </xsl:otherwise>
            </xsl:choose>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:text>.</xsl:text>
   </xsl:function>
   <xsl:function name="foo:indexName-EndnoteRoutine">
      <xsl:param name="typ" as="xs:string"/>
      <xsl:param name="verweis" as="xs:boolean"/>
      <xsl:param name="first" as="xs:string"/>
      <xsl:param name="rest" as="xs:string"/>
      <xsl:choose>
         <xsl:when test="not(starts-with($first, '#pmb'))">
            <xsl:text>\textcolor{red}{KEY PROBLEM}</xsl:text>
         </xsl:when>
         <xsl:when test="$typ = 'person'">
            <xsl:value-of select="foo:personInEndnote($first, $verweis)"/>
         </xsl:when>
         <xsl:when test="$typ = 'work'">
            <xsl:value-of select="foo:werkInEndnote($first, $verweis)"/>
         </xsl:when>
         <xsl:when test="$typ = 'org'">
            <xsl:value-of select="foo:orgInEndnote($first, $verweis)"/>
         </xsl:when>
         <xsl:when test="$typ = 'place'">
            <xsl:value-of select="foo:placeInEndnote($first, $verweis)"/>
         </xsl:when>
      </xsl:choose>
      <xsl:if test="$rest != ''">
         <xsl:text>{\newline}</xsl:text>
         <xsl:value-of
            select="foo:indexName-EndnoteRoutine($typ, $verweis, tokenize($rest, ' ')[1], substring-after($rest, ' '))"
         />
      </xsl:if>
   </xsl:function>
   <xsl:function name="foo:indexeintrag-hinten">
      <xsl:param name="first" as="xs:string"/>
      <xsl:param name="verweis" as="xs:boolean"/>
      <xsl:param name="im-text" as="xs:boolean"/>
      <xsl:param name="certlow" as="xs:boolean"/>
      <xsl:param name="kommentar-oder-hrsg" as="xs:boolean"/>
      <xsl:choose>
         <xsl:when test="$certlow = true()">
            <xsl:text>u</xsl:text>
         </xsl:when>
      </xsl:choose>
      <xsl:choose>
         <xsl:when test="$kommentar-oder-hrsg">
            <xsl:text>k</xsl:text>
         </xsl:when>
      </xsl:choose>
      <xsl:choose>
         <xsl:when test="$verweis">
            <xsl:text>v</xsl:text>
         </xsl:when>
      </xsl:choose>
      <xsl:text>}</xsl:text>
   </xsl:function>
   <xsl:function name="foo:stripHash">
      <xsl:param name="first" as="xs:string"/>
      <xsl:value-of select="substring-after($first, '#pmb')"/>
   </xsl:function>
   <xsl:function name="foo:werk-indexName-Routine-autoren">
      <!-- Das soll die Varianten abfangen, dass mehrere Verfasser an einem Werk beteiligt sein können -->
      <xsl:param name="first" as="xs:string"/>
      <xsl:param name="endung" as="xs:string"/>
      <xsl:variable name="work-entry-authors"
         select="key('work-lookup', $first, $works)/author[@ref = 'pmb2121' or not(@role = 'hat-einen-beitrag-geschaffen-zu')]"/>
      <xsl:variable name="work-entry-authors-count" select="count($work-entry-authors)"/>
      <xsl:choose>
         <xsl:when test="not(key('work-lookup', $first, $works))">
            <xsl:text>\textcolor{red}{\textsuperscript{XXXX2 indx}}</xsl:text>
         </xsl:when>
         <xsl:when test="$work-entry-authors-count = 0">
            <xsl:value-of select="foo:werk-in-index($first, $endung, 0)"/>
         </xsl:when>
         <xsl:otherwise>
            <xsl:for-each select="$work-entry-authors">
               <xsl:value-of select="foo:werk-in-index($first, $endung, position())"/>
            </xsl:for-each>
         </xsl:otherwise>
      </xsl:choose>
   </xsl:function>
   <xsl:function name="foo:indexName-Routine">
      <xsl:param name="typ" as="xs:string"/>
      <xsl:param name="first" as="xs:string"/>
      <xsl:param name="rest" as="xs:string"/>
      <xsl:param name="endung" as="xs:string"/>
      <xsl:choose>
         <xsl:when test="$first = '' or empty($first)">
            <xsl:text>\textcolor{red}{\textsuperscript{\textbf{KEY}}}</xsl:text>
         </xsl:when>
         <xsl:when test="$typ = 'person'">
            <xsl:value-of select="foo:person-in-index($first, $endung, true())"/>
         </xsl:when>
         <xsl:when test="$typ = 'work'">
            <xsl:value-of select="foo:werk-indexName-Routine-autoren($first, $endung)"/>
         </xsl:when>
         <xsl:when test="$typ = 'org'">
            <xsl:value-of select="foo:org-in-index($first, $endung)"/>
         </xsl:when>
         <xsl:when test="$typ = 'place'">
            <xsl:value-of select="foo:place-in-index($first, $endung, true())"/>
         </xsl:when>
      </xsl:choose>
      <xsl:if test="normalize-space($rest) != ''">
         <xsl:value-of
            select="foo:indexName-Routine($typ, tokenize($rest, ' ')[1], substring-after($rest, ' '), $endung)"
         />
      </xsl:if>
   </xsl:function>
   <xsl:template match="persName | workName | orgName | placeName | rs">
      <xsl:variable name="first" select="tokenize(@ref, ' ')[1]" as="xs:string?"/>
      <xsl:variable name="rest" select="substring-after(@ref, concat($first, ' '))" as="xs:string"/>
      <xsl:variable name="index-test-bestanden" as="xs:boolean"
         select="count(ancestor::TEI/teiHeader/revisionDesc/change[contains(text(), 'Index check')]) &gt; 0"/>
      <xsl:variable name="candidate" as="xs:boolean"
         select="ancestor::TEI/teiHeader/revisionDesc/@status = 'approved' or ancestor::TEI/teiHeader/revisionDesc/@status = 'candidate' or ancestor::TEI/teiHeader/revisionDesc/change[contains(text(), 'Index check')]"/>
      <!-- In diesen Fällen befindet sich das rs im Text: -->
      <xsl:variable name="im-text" as="xs:boolean"
         select="ancestor::body and not(ancestor::note) and not(ancestor::caption) and not(parent::bibl) and not(ancestor::TEI[starts-with(@id, 'E')]) and not(ancestor::div[@type = 'biographical'])"/>
      <!-- In diesen Fällen werden orgs und titel kursiv geschrieben: -->
      <xsl:variable name="kommentar-herausgeber" as="xs:boolean"
         select="((ancestor::note[@type = 'commentary'] or ancestor::note[@type = 'textConst'] or ancestor::TEI[starts-with(@id, 'E')] or ancestor::tei:bibl or ancestor::div[@type = 'biographical']) and not(ancestor::quote)) or parent::bibl"/>
      <!-- Ist's implizit vorkommend -->
      <xsl:variable name="verweis" as="xs:boolean" select="@subtype = 'implied'"/>
      <!-- Kursiv ja / nein -->
      <xsl:variable name="emph"
         select="not(@subtype = 'implied') and $kommentar-herausgeber and (@type = 'work' or @type = 'org')"/>
      <xsl:variable name="cert" as="xs:boolean" select="(@cert = 'low') or (@cert = 'medium')"/>
      <xsl:variable name="endung-index" as="xs:string">
         <xsl:choose>
            <xsl:when test="$cert and $verweis and $kommentar-herausgeber">
               <xsl:text>|pwuvk}</xsl:text>
            </xsl:when>
            <xsl:when test="$cert and $verweis">
               <xsl:text>|pwuv}</xsl:text>
            </xsl:when>
            <xsl:when test="$cert and $kommentar-herausgeber">
               <xsl:text>|pwuk}</xsl:text>
            </xsl:when>
            <xsl:when test="$cert">
               <xsl:text>|pwu}</xsl:text>
            </xsl:when>
            <xsl:when test="$verweis and $kommentar-herausgeber">
               <xsl:text>|pwkv}</xsl:text>
            </xsl:when>
            <xsl:when test="$verweis">
               <xsl:text>|pwv}</xsl:text>
            </xsl:when>
            <xsl:when test="$kommentar-herausgeber">
               <xsl:text>|pwk}</xsl:text>
            </xsl:when>
            <xsl:otherwise>
               <xsl:text>|pw}</xsl:text>
            </xsl:otherwise>
         </xsl:choose>
      </xsl:variable>
      <xsl:choose>
         <xsl:when test="$first = '' or empty($first)">
            <!-- Hier der Fall, dass die @ref-Nummer fehlt -->
            <xsl:apply-templates/>
            <xsl:text>\textcolor{red}{\textsuperscript{\textbf{KEY}}}</xsl:text>
         </xsl:when>
         <xsl:otherwise>
            <xsl:choose>
               <xsl:when test="$candidate">
                  <xsl:if test="$emph">
                     <xsl:text>\emph{</xsl:text>
                  </xsl:if>
                  <xsl:apply-templates/>
                  <xsl:if test="$emph">
                     <xsl:text>}</xsl:text>
                  </xsl:if>
                  <xsl:value-of
                     select="foo:indexName-Routine(@type, tokenize(@ref, ' ')[1], substring-after(@ref, ' '), $endung-index)"
                  />
               </xsl:when>
               <xsl:otherwise>
                  <xsl:if
                     test="$im-text and not(@ref = '#pmb2121' or @ref = '#pmb50') and not($index-test-bestanden)">
                     <xsl:text>\edtext{</xsl:text>
                  </xsl:if>
                  <xsl:if test="$emph">
                     <xsl:text>\emph{</xsl:text>
                  </xsl:if>
                  <!-- Wenn der Index schon überprüft wurde, aber der Text noch nicht abgeschlossen, erscheinen
              die indizierten Begriffe bunt-->
                  <xsl:choose>
                     <xsl:when test="@type = 'person'">
                        <xsl:text>\textcolor{blue}{</xsl:text>
                     </xsl:when>
                     <xsl:when test="@type = 'work'">
                        <xsl:text>\textcolor{green}{</xsl:text>
                     </xsl:when>
                     <xsl:when test="@type = 'org'">
                        <xsl:text>\textcolor{brown}{</xsl:text>
                     </xsl:when>
                     <xsl:when test="@type = 'place'">
                        <xsl:text>\textcolor{pink}{</xsl:text>
                     </xsl:when>
                  </xsl:choose>
                  <xsl:apply-templates/>
                  <xsl:text>}</xsl:text>
                  <xsl:value-of
                     select="foo:indexName-Routine(@type, tokenize(@ref, ' ')[1], substring-after(@ref, ' '), $endung-index)"/>
                  <xsl:choose>
                     <xsl:when
                        test="$im-text and not(@ref = '#pmb2121' or @ref = '#pmb50') and not($index-test-bestanden)">
                        <xsl:text>}{</xsl:text>
                        <xsl:value-of select="foo:lemma(.)"/>
                        <xsl:text>\Bendnote{</xsl:text>
                        <xsl:value-of
                           select="foo:indexName-EndnoteRoutine(@type, $verweis, $first, $rest)"/>
                        <xsl:text>}}</xsl:text>
                     </xsl:when>
                  </xsl:choose>
                  <xsl:if test="$emph">
                     <xsl:text>}</xsl:text>
                  </xsl:if>
               </xsl:otherwise>
            </xsl:choose>
         </xsl:otherwise>
      </xsl:choose>
   </xsl:template>
   <!-- Hier wird, je nachdem ob es sich um vorne oder hinten im Text handelt, ein Indexmarker gesetzt, der zeigt,
   dass ein Werk über mehrere Seiten geht bzw. dieser geschlossen -->
   <xsl:function name="foo:abgedruckte-workNameRoutine">
      <xsl:param name="first" as="xs:string"/>
      <xsl:param name="vorne" as="xs:boolean"/>
      <xsl:choose>
         <xsl:when test="$vorne">
            <xsl:value-of select="foo:werk-in-index($first, '|pwt(', 1)"/>
            <xsl:text>}</xsl:text>
         </xsl:when>
         <xsl:otherwise>
            <xsl:value-of select="foo:werk-in-index($first, '|pwt)', 1)"/>
            <xsl:text>}</xsl:text>
         </xsl:otherwise>
      </xsl:choose>
      <!--<xsl:choose>
         <xsl:when test="$first = ''">
            <xsl:text>\textcolor{red}{INDEX FEHLER W}</xsl:text>
         </xsl:when>
         <xsl:when test="not(starts-with($first, '#pmb'))">
            <xsl:text>\textcolor{red}{WERKINDEX FEHLER}</xsl:text>
         </xsl:when>
         <xsl:otherwise>
            <xsl:variable name="entry" select="key('work-lookup', $first, $works)" as="node()?"/>
            <xsl:variable name="author"Überse
               select="$entry/author[@role = 'author' or @role = 'abbreviated-name' or not(@role)]"/>
            <xsl:choose>
               <xsl:when test="not($entry) or $entry = ''">
                  <xsl:text>\pwindex{XXXX Abgedrucktes Werk, Nummer nicht vorhanden|pwt}</xsl:text>
                  <xsl:value-of select="$first"/>
               </xsl:when>
               <xsl:otherwise>
                  <xsl:choose>
                     <!-\- Hier nun gleich der Fall von einem Autor, mehreren Autoren abgefangen -\->
                     <xsl:when test="not($author)">
                        <xsl:value-of select="foo:werk-in-index($first, '|pwt', 0)"/>
                        <xsl:choose>
                           <xsl:when test="$vorne">
                              <xsl:text>(</xsl:text>
                           </xsl:when>
                           <xsl:otherwise>
                              <xsl:text>)</xsl:text>
                           </xsl:otherwise>
                        </xsl:choose>
                        <xsl:text>}</xsl:text>
                     </xsl:when>
                     <xsl:otherwise>
                        <xsl:for-each
                           select="$entry/author[@role = 'author' or @role = 'abbreviated-name' or not(@role)]">
                           <xsl:value-of select="foo:werk-in-index($first, '|pwt', position())"/>
                           <xsl:choose>
                              <xsl:when test="$vorne">
                                 <xsl:text>(</xsl:text>
                              </xsl:when>
                              <xsl:otherwise>
                                 <xsl:text>)</xsl:text>
                              </xsl:otherwise>
                           </xsl:choose>
                           <xsl:text>}</xsl:text>
                        </xsl:for-each>
                     </xsl:otherwise>
                  </xsl:choose>
               </xsl:otherwise>
            </xsl:choose>
         </xsl:otherwise>
      </xsl:choose>-->
      <!--<xsl:if test="$rest != ''">
            <xsl:value-of
               select="foo:abgedruckte-workNameRoutine(substring($rest, 1, 7), substring-after($rest, ' '), $vorne)"
            />
         </xsl:if>-->
   </xsl:function>
   <xsl:function name="foo:werkInEndnote">
      <xsl:param name="first" as="xs:string"/>
      <xsl:param name="verweis" as="xs:boolean"/>
      <xsl:variable name="entry" select="key('work-lookup', $first, $works)"/>
      <xsl:variable name="author-entry" select="$entry/author"/>
      <xsl:if test="$verweis">
         <xsl:text>$\rightarrow$</xsl:text>
      </xsl:if>
      <xsl:if
         test="$entry/author[@role = 'author' or @role = 'abbreviated-name' or not(@role)]/surname/text() != ''">
         <xsl:for-each
            select="$entry/author[@role = 'author' or @role = 'abbreviated-name' or not(@role)]">
            <xsl:choose>
               <xsl:when test="persName/forename = '' and persName/surname = ''">
                  <xsl:text>\textcolor{red}{KEIN NAME}</xsl:text>
               </xsl:when>
               <xsl:when test="forename = ''">
                  <xsl:apply-templates select="surname"/>
               </xsl:when>
               <xsl:otherwise>
                  <xsl:apply-templates select="concat(forename, ' ', surname)"/>
               </xsl:otherwise>
            </xsl:choose>
            <xsl:choose>
               <xsl:when test="position() = last()">
                  <xsl:text>:</xsl:text>
               </xsl:when>
               <xsl:otherwise>
                  <xsl:text>, </xsl:text>
               </xsl:otherwise>
            </xsl:choose>
            <xsl:text> </xsl:text>
         </xsl:for-each>
      </xsl:if>
      <xsl:choose>
         <xsl:when test="contains($entry/title[1], ':]') and starts-with($entry/title[1], '[')">
            <xsl:value-of select="substring-before($entry/title, ':] ')"/>
            <xsl:text>]: \emph{</xsl:text>
            <xsl:value-of select="substring-after($entry/title[1], ':] ')"/>
            <xsl:text>}</xsl:text>
         </xsl:when>
         <xsl:otherwise>
            <xsl:text>\emph{</xsl:text>
            <xsl:value-of select="$entry/title[1]"/>
            <xsl:text>}</xsl:text>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:if test="$entry/Bibliografie != ''">
         <xsl:text>, </xsl:text>
         <xsl:value-of select="foo:date-translate($entry/Bibliografie)"/>
      </xsl:if>
   </xsl:function>
   <!-- ORGANISATIONEN -->
   <!-- Da mehrere Org-keys angegeben sein können, kommt diese Routine zum Einsatz: -->
   <xsl:function name="foo:orgNameRoutine">
      <xsl:param name="first" as="xs:string"/>
      <xsl:param name="rest" as="xs:string"/>
      <xsl:param name="endung" as="xs:string"/>
      <xsl:if test="$first != ''">
         <xsl:value-of select="foo:org-in-index($first, $endung)"/>
         <xsl:if test="$rest != ''">
            <xsl:value-of
               select="foo:orgNameRoutine(tokenize($rest, ' ')[1], substring-after($rest, ' '), $endung)"
            />
         </xsl:if>
      </xsl:if>
   </xsl:function>
   <xsl:function name="foo:orgInEndnote">
      <xsl:param name="first" as="xs:string"/>
      <xsl:param name="verweis" as="xs:boolean"/>
      <xsl:variable name="entry" select="key('org-lookup', $first, $orgs)"/>
      <xsl:if test="$verweis">
         <xsl:text>$\rightarrow$</xsl:text>
      </xsl:if>
      <xsl:choose>
         <xsl:when test="$first = ''">
            <xsl:text>\textcolor{red}{ORGANISATION OFFEN}</xsl:text>
         </xsl:when>
         <xsl:otherwise>
            <xsl:if test="$entry[1]/tei:orgName[1] != ''">
               <xsl:value-of
                  select="foo:sonderzeichen-ersetzen(normalize-space($entry[1]//tei:orgName))"/>
            </xsl:if>
            <xsl:if test="$entry[1]/Ort[1] != ''">
               <xsl:text>, </xsl:text>
               <xsl:value-of select="foo:sonderzeichen-ersetzen(normalize-space($entry[1]/Ort))"/>
            </xsl:if>
            <xsl:if test="$entry[1]/Ort[1] != ''">
               <xsl:text>, \emph{</xsl:text>
               <xsl:value-of select="foo:sonderzeichen-ersetzen(normalize-space($entry[1]/Typ))"/>
               <xsl:text>}</xsl:text>
            </xsl:if>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:text>.</xsl:text>
   </xsl:function>
   <xsl:function name="foo:orgNameEndnoteR">
      <xsl:param name="first" as="xs:string"/>
      <xsl:param name="rest" as="xs:string"/>
      <xsl:param name="verweis" as="xs:boolean"/>
      <xsl:value-of select="foo:orgInEndnote($first, $verweis)"/>
      <xsl:if test="$rest != ''">
         <xsl:text>{\newline}</xsl:text>
         <xsl:value-of
            select="foo:orgNameEndnoteR(substring($rest, 1, 7), substring-after($rest, ' '), $verweis)"
         />
      </xsl:if>
   </xsl:function>
   <!-- ORTE: -->
   <!-- Da mehrere place-keys angegeben sein können, kommt diese Routine zum Einsatz: -->
   <xsl:function name="foo:placeNameRoutine">
      <xsl:param name="first" as="xs:string"/>
      <xsl:param name="rest" as="xs:string"/>
      <xsl:param name="endung" as="xs:string"/>
      <xsl:param name="endung-setzen" as="xs:boolean"/>
      <xsl:choose>
         <xsl:when test="not(starts-with($first, '#pmb')) or $first = '#pmb' or $first = ''">
            <xsl:text>\textcolor{red}{ORT FEHLER}</xsl:text>
         </xsl:when>
         <xsl:otherwise>
            <xsl:value-of select="foo:place-in-index($first, $endung, $endung-setzen)"/>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:if test="$rest != ''">
         <xsl:value-of
            select="foo:placeNameRoutine(tokenize($rest, ' ')[1], substring-after($rest, ' '), $endung, $endung-setzen)"
         />
      </xsl:if>
   </xsl:function>
   <xsl:function name="foo:placeInEndnote">
      <xsl:param name="first" as="xs:string"/>
      <xsl:param name="verweis" as="xs:boolean"/>
      <xsl:variable name="place" select="key('place-lookup', $first, $places)"/>
      <xsl:variable name="ort" select="$place/tei:placeName"/>
      <xsl:if test="$verweis">
         <xsl:text>$\rightarrow$</xsl:text>
      </xsl:if>
      <xsl:choose>
         <xsl:when test="$first = ''">
            <xsl:text>\textcolor{red}{ORT OFFEN}</xsl:text>
         </xsl:when>
         <xsl:otherwise>
            <xsl:value-of
               select="normalize-space(foo:sonderzeichen-ersetzen($place/tei:placeName[1]))"/>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:text>.</xsl:text>
   </xsl:function>
   <xsl:function name="foo:placeNameEndnoteR">
      <xsl:param name="first" as="xs:string"/>
      <xsl:param name="rest" as="xs:string"/>
      <xsl:param name="verweis" as="xs:boolean"/>
      <xsl:value-of select="foo:placeInEndnote($first, $verweis)"/>
      <xsl:if test="$rest != ''">
         <xsl:text>{\newline}</xsl:text>
         <xsl:value-of
            select="foo:placeNameEndnoteR(substring($rest, 1, 7), substring-after($rest, ' '), $verweis)"
         />
      </xsl:if>
   </xsl:function>
   <xsl:function name="foo:normalize-und-umlaute">
      <xsl:param name="wert" as="xs:string"/>
      <xsl:value-of select="normalize-space(foo:umlaute-entfernen($wert))"/>
   </xsl:function>
   
   <xsl:function name="foo:ort-für-index">
      <xsl:param name="first" as="xs:string"/>
      <xsl:variable name="ort" select="key('place-lookup', $first, $places)/placeName[1]"/>
      <xsl:choose>
         <xsl:when test="string-length($ort) = 0">
            <xsl:text>XXXX Ortsangabe fehlt</xsl:text>
            <xsl:value-of select="$first"/>
         </xsl:when>
         <xsl:otherwise>
            <xsl:value-of
               select="normalize-space(foo:umlaute-entfernen(foo:sonderzeichen-ersetzen($ort)))"/>
            <xsl:text>@</xsl:text>
            <xsl:text>\textbf{</xsl:text>
            <xsl:value-of select="normalize-space(foo:sonderzeichen-ersetzen($ort))"/>
            <xsl:text>}</xsl:text>
            <!--<xsl:if test="key('place-lookup', $first, $places)/tei:desc[1]/tei:gloss[1]">
               <xsl:text>, \emph{</xsl:text>
               <xsl:value-of select="key('place-lookup', $first, $places)/tei:desc[1]/tei:gloss[1]"/>
               <xsl:text>}</xsl:text>
            </xsl:if>-->
         </xsl:otherwise>
      </xsl:choose>
   </xsl:function>
   <xsl:function name="foo:wienerBezirke">
      <xsl:param name="bezirksname" as="xs:string"/>
      <xsl:choose>
         <xsl:when test="$bezirksname = 'pmb51'">
            <xsl:text>zz01</xsl:text>
         </xsl:when>
         <xsl:when test="$bezirksname = 'pmb52'">
            <xsl:text>zz02</xsl:text>
         </xsl:when>
         <xsl:when test="$bezirksname = 'pmb53'">
            <xsl:text>zz03</xsl:text>
         </xsl:when>
         <xsl:when test="$bezirksname = 'pmb54'">
            <xsl:text>zz04</xsl:text>
         </xsl:when>
         <xsl:when test="$bezirksname = 'pmb55'">
            <xsl:text>zz05</xsl:text>
         </xsl:when>
         <xsl:when test="$bezirksname = 'pmb56'">
            <xsl:text>zz06</xsl:text>
         </xsl:when>
         <xsl:when test="$bezirksname = 'pmb57'">
            <xsl:text>zz07</xsl:text>
         </xsl:when>
         <xsl:when test="$bezirksname = 'pmb58'">
            <xsl:text>zz08</xsl:text>
         </xsl:when>
         <xsl:when test="$bezirksname = 'pmb59'">
            <xsl:text>zz09</xsl:text>
         </xsl:when>
         <xsl:when test="$bezirksname = 'pmb60'">
            <xsl:text>zz10</xsl:text>
         </xsl:when>
         <xsl:when test="$bezirksname = 'pmb61'">
            <xsl:text>zz11</xsl:text>
         </xsl:when>
         <xsl:when test="$bezirksname = 'pmb62'">
            <xsl:text>zz12</xsl:text>
         </xsl:when>
         <xsl:when test="$bezirksname = 'pmb63'">
            <xsl:text>zz13</xsl:text>
         </xsl:when>
         <xsl:when test="$bezirksname = 'pmb64'">
            <xsl:text>zz14</xsl:text>
         </xsl:when>
         <xsl:when test="$bezirksname = 'pmb65'">
            <xsl:text>zz15</xsl:text>
         </xsl:when>
         <xsl:when test="$bezirksname = 'pmb66'">
            <xsl:text>zz16</xsl:text>
         </xsl:when>
         <xsl:when test="$bezirksname = 'pmb67'">
            <xsl:text>zz17</xsl:text>
         </xsl:when>
         <xsl:when test="$bezirksname = 'pmb68'">
            <xsl:text>zz18</xsl:text>
         </xsl:when>
         <xsl:when test="$bezirksname = 'pmb69'">
            <xsl:text>zz19</xsl:text>
         </xsl:when>
         <xsl:when test="$bezirksname = 'pmb60'">
            <xsl:text>zz20</xsl:text>
         </xsl:when>
         <xsl:when test="$bezirksname = 'pmb71'">
            <xsl:text>zz21</xsl:text>
         </xsl:when>
         <xsl:when test="$bezirksname = 'pmb72'">
            <xsl:text>zz22</xsl:text>
         </xsl:when>
         <xsl:when test="$bezirksname = 'pmb73'">
            <xsl:text>zz23</xsl:text>
         </xsl:when>
         <xsl:otherwise>
            <xsl:text>keinBezirk</xsl:text>
         </xsl:otherwise>
      </xsl:choose>
   </xsl:function>
   <xsl:function name="foo:place-in-index">
      <xsl:param name="first" as="xs:string"/>
      <xsl:param name="endung" as="xs:string"/>
      <xsl:param name="endung-setzen" as="xs:boolean"/>
      <xsl:variable name="place" select="key('place-lookup', $first, $places)"/>
      <xsl:variable name="ort" select="$place/placeName[1]"/>
      <xsl:variable name="typ" select="$place/desc[@type = 'entity_type']"/>
      <xsl:choose>
         <xsl:when test="not(starts-with($first, '#pmb'))">
            <xsl:text>\textcolor{red}{FEHLER4}</xsl:text>
         </xsl:when>
         <xsl:when test="$first = 'pmb50' or $first = 'pmb168' or $first = '#pmb50' or $first = '#pmb168'"/>
         <!-- Wien und Berlin raus -->
         <xsl:when test="not($place/location[@type = 'located_in_place'])">
            <xsl:text>\oindex{</xsl:text>
            <xsl:value-of select="foo:ort-für-index($first)"/>
            <xsl:if test="$endung-setzen">
               <xsl:value-of select="$endung"/>
            </xsl:if>
         </xsl:when>
         <xsl:otherwise>
            <xsl:for-each select="$place/location[@type = 'located_in_place']">
               <xsl:variable name="entityTypeID" as="text()" select="desc[@type='entity_type_id']/text()"/>
               <xsl:choose>
                  <xsl:when test="not(foo:wienerBezirke(placeName/@ref) = 'keinBezirk')">
                     <xsl:text>\oindex{</xsl:text>
                     <xsl:value-of select="foo:index-sortiert('Wien', 'bf')"/>
                     <xsl:text>!</xsl:text>
                     <xsl:value-of select="foo:wienerBezirke(placeName/@ref)"/>
                     <xsl:value-of select="foo:index-sortiert(placeName, 'bf')"/>
                     <xsl:text>!</xsl:text>
                     <xsl:value-of select="foo:ort-für-index($first)"/>
                     <xsl:if test="$endung-setzen">
                        <xsl:value-of select="$endung"/>
                     </xsl:if>
                  </xsl:when>
                  <xsl:when
                     test="not(foo:wienerBezirke(replace($first, '#pmb', 'pmb')) = 'keinBezirk')">
                     <xsl:text>\oindex{</xsl:text>
                     <xsl:value-of select="foo:index-sortiert('Wien', 'bf')"/>
                     <xsl:text>!</xsl:text>
                     <xsl:value-of select="foo:wienerBezirke(replace($first, '#pmb', 'pmb'))"/>
                     <xsl:value-of select="foo:ort-für-index($first)"/>
                     <xsl:if test="$endung-setzen">
                        <xsl:value-of select="$endung"/>
                     </xsl:if>
                  </xsl:when>
                  <xsl:when test="placeName/@ref = 'pmb50'">
                     <xsl:text>\oindex{</xsl:text>
                     <xsl:value-of select="foo:index-sortiert('Wien', 'bf')"/>
                     <xsl:text>!</xsl:text>
                     <xsl:value-of select="foo:ort-für-index($first)"/>
                     <xsl:if test="$endung-setzen">
                        <xsl:value-of select="$endung"/>
                     </xsl:if>
                  </xsl:when>
                  <xsl:when test="$entityTypeID = '14' or
                     $entityTypeID = '1103' or
                     $entityTypeID = '1123' or
                     $entityTypeID = '1412' or
                     $entityTypeID = '1418' or
                     $entityTypeID = '1419' or
                     $entityTypeID = '1519' or
                     $entityTypeID = '1576' or
                     $entityTypeID = '1729' or
                     $entityTypeID = '25' or
                     $entityTypeID = '28'">
                     <xsl:text>\oindex{</xsl:text>
                     <xsl:value-of select="foo:index-sortiert(placeName, 'bf')"/>
                     <xsl:text>!</xsl:text>
                     <xsl:value-of select="foo:ort-für-index($first)"/>
                     <xsl:if test="$endung-setzen">
                        <xsl:value-of select="$endung"/>
                     </xsl:if>
                  </xsl:when>
               </xsl:choose>
            </xsl:for-each>
         </xsl:otherwise>
      </xsl:choose>
   </xsl:function>
   <xsl:template match="facsimile"/>
   <!-- Horizontale Linie -->
   <xsl:template match="milestone[@rend = 'line']">
      <xsl:text>\noindent\rule{\textwidth}{0.5pt}</xsl:text>
   </xsl:template>
   <!-- Bilder einbetten -->
   <xsl:template match="figure">
      <xsl:variable name="numbers" as="xs:integer*">
         <xsl:analyze-string select="graphic/@width" regex="([0-9]+)cm">
            <xsl:matching-substring>
               <xsl:sequence select="xs:integer(regex-group(1))"/>
            </xsl:matching-substring>
         </xsl:analyze-string>
      </xsl:variable>
      <xsl:variable name="caption" as="node()?" select="child::caption"/>
      <!-- Drei Varianten:
         - Bild ohne Bildtext zentriert
         - Bild mit Bildtext, halbe Textbreite, Bildtext daneben
         - Bild mit Bildtext, Bildtext drunter
        Wenn
         
         Wenn das Bild max. bis zur halben Textbreite geht, wird die Bildunterschrift daneben gesetzt = Variante 1 -->
      <xsl:choose>
         <xsl:when test="not($caption)">
            <xsl:choose>
               <!-- Bilder in Herausgebertexten sind nicht auf Platz fixiert -->
               <xsl:when test="ancestor::TEI/starts-with(@id, 'E_')">
                  <xsl:text>\noindent</xsl:text>
                  <xsl:text>\begin{figure}[tbp]</xsl:text>
                  <xsl:text>\centering</xsl:text>
                  <xsl:apply-templates/>
                  <xsl:text>\end{figure}</xsl:text>
               </xsl:when>
               <xsl:otherwise>
                  <xsl:text>\begin{figure}[H]\centering</xsl:text>
                  <xsl:apply-templates/>
                  <xsl:text>\end{figure}</xsl:text>
               </xsl:otherwise>
            </xsl:choose>
         </xsl:when>
         <xsl:when test="$numbers &lt; 6">
            <!-- Bild auf halber Textbreite -->
            <xsl:choose>
               <!-- Herausgebertext:  -->
               <xsl:when test="ancestor::TEI/starts-with(@id, 'E_')">
                  <xsl:text>\begin{figure}[tbp]</xsl:text>
                  <xsl:text>\noindent</xsl:text>
                  <xsl:text>\begin{minipage}[t]{</xsl:text>
                  <xsl:value-of select="$numbers"/>
                  <xsl:text>cm}</xsl:text>
                  <xsl:text>\noindent</xsl:text>
                  <xsl:apply-templates select="graphic"/>
                  <xsl:text>\end{minipage}</xsl:text>
                  <xsl:text>\noindent</xsl:text>
                  <xsl:text>\begin{minipage}[t]{\dimexpr\halbtextwidth-</xsl:text>
                  <xsl:value-of select="graphic/@width"/>
                  <xsl:text>\relax}</xsl:text>
                  <xsl:apply-templates select="$caption" mode="halbetextbreite"/>
                  <xsl:text>\end{minipage}</xsl:text>
                  <xsl:text>\end{figure}</xsl:text>
               </xsl:when>
               <xsl:otherwise>
                  <xsl:text>\noindent\begin{minipage}[t]{</xsl:text>
                  <xsl:value-of select="$numbers"/>
                  <xsl:text>cm}</xsl:text>
                  <xsl:apply-templates/>
                  <xsl:text>\end{minipage}</xsl:text>
                  <xsl:text>\noindent\begin{minipage}[t]{\dimexpr\halbtextwidth-</xsl:text>
                  <xsl:value-of select="graphic/@width"/>
                  <xsl:text>\relax}</xsl:text>
                  <xsl:apply-templates select="$caption" mode="halbetextbreite"/>
                  <xsl:text>\end{minipage}</xsl:text>
               </xsl:otherwise>
            </xsl:choose>
         </xsl:when>
         <xsl:otherwise>
            <xsl:choose>
               <!-- Bilder in Herausgebertexten sind nicht auf Platz fixiert -->
               <xsl:when test="ancestor::TEI/starts-with(@id, 'E_')">
                  <xsl:text>\noindent</xsl:text>
                  <xsl:text>\begin{figure}[tbp]</xsl:text>
                  <xsl:text>\centering</xsl:text>
                  <xsl:apply-templates/>
                  <xsl:text>\end{figure}</xsl:text>
               </xsl:when>
               <xsl:otherwise>
                  <xsl:text>\begin{figure}[H]\centering</xsl:text>
                  <xsl:apply-templates/>
                  <xsl:text>\end{figure}</xsl:text>
               </xsl:otherwise>
            </xsl:choose>
         </xsl:otherwise>
      </xsl:choose>
   </xsl:template>
   <xsl:template match="caption" mode="halbetextbreite">
      <!-- Falls es eine Bildunterschrift gibt -->
      <xsl:text>\hspace{0.5cm}\begin{minipage}[b]{0.85\textwidth}\noindent</xsl:text>
      <xsl:text>\begin{RaggedRight}\small\emph{</xsl:text>
      <xsl:apply-templates/>
      <xsl:text>}\end{RaggedRight}\end{minipage}
      </xsl:text>
   </xsl:template>
   <xsl:template match="figDesc"/>
   <xsl:template match="caption">
      <!-- Falls es eine Bildunterschrift gibt -->
      <xsl:text>\hspace{0.5cm}\noindent</xsl:text>
      <xsl:text>\begin{center}\small\emph{</xsl:text>
      <xsl:apply-templates/>
      <xsl:text>}\end{center}\vspace{\baselineskip}
      </xsl:text>
   </xsl:template>
   <xsl:template match="graphic">
      <xsl:if test="parent::figure/figDesc">
         <xsl:text>\BeginAccSupp{ActualText=image </xsl:text>
         <xsl:value-of select="parent::figure/figDesc/text()"/>
         <xsl:text>,space}\EndAccSupp{}</xsl:text>
      </xsl:if>
      <xsl:text>\includegraphics</xsl:text>
      <xsl:choose>
         <xsl:when test="@width">
            <xsl:text>[width=</xsl:text>
            <xsl:value-of select="@width"/>
            <xsl:text>]</xsl:text>
         </xsl:when>
         <xsl:when test="@height">
            <xsl:text>[height=</xsl:text>
            <xsl:value-of select="@height"/>
            <xsl:text>]</xsl:text>
         </xsl:when>
         <xsl:otherwise>
            <xsl:text>[max height=\linewidth,max width=\linewidth]
</xsl:text>
         </xsl:otherwise>
      </xsl:choose>
      <xsl:text>{</xsl:text>
      <xsl:value-of select="replace(@url, '../resources/img', 'images')"/>
      <xsl:text>}</xsl:text>
   </xsl:template>
   <xsl:template match="list">
      <xsl:text>\begin{itemize}[noitemsep, leftmargin=*]</xsl:text>
      <xsl:apply-templates/>
      <xsl:text>\end{itemize}</xsl:text>
   </xsl:template>
   <xsl:template match="item">
      <xsl:text>\item </xsl:text>
      <xsl:apply-templates/>
      <xsl:text>
      </xsl:text>
   </xsl:template>
   <xsl:template match="list[@type = 'gloss']">
      <xsl:text>\setlist[description]{font=\normalsize\upshape\mdseries,style=nextline}\begin{description}</xsl:text>
      <xsl:apply-templates/>
      <xsl:text>\end{description}</xsl:text>
   </xsl:template>
   <xsl:template match="list[@type = 'gloss']/label">
      <xsl:text>\item[</xsl:text>
      <xsl:apply-templates/>
      <xsl:text>]</xsl:text>
   </xsl:template>
   <xsl:template match="list[@type = 'gloss']/item">
      <xsl:text>{</xsl:text>
      <xsl:apply-templates/>
      <xsl:text>}</xsl:text>
   </xsl:template>
   <xsl:template match="list[@type = 'simple-gloss']">
      <xsl:text>\begin{description}[font=\normalsize\upshape\mdseries, itemsep=0em, labelwidth=5em, itemsep=0em,leftmargin=5.6em]</xsl:text>
      <xsl:apply-templates/>
      <xsl:text>\end{description}</xsl:text>
   </xsl:template>
   <xsl:template match="list[@type = 'simple-gloss']/label">
      <xsl:text>\item[</xsl:text>
      <xsl:apply-templates/>
      <xsl:text>]</xsl:text>
   </xsl:template>
   <xsl:template match="list[@type = 'simple-gloss']/item">
      <xsl:text>{</xsl:text>
      <xsl:apply-templates/>
      <xsl:text>}</xsl:text>
   </xsl:template>
   <xsl:template match="ref[@type = 'pointer']">
      <!-- Pointer funktionieren so, dass sie, wenn sie auf v enden, auf einen Bereich zeigen, sonst
      wird einfach zweimal der selbe Punkt gesetzt-->
      <xsl:choose>
         <xsl:when test="@subtype = 'see'">
            <xsl:text>siehe </xsl:text>
         </xsl:when>
         <xsl:when test="@subtype = 'cf'">
            <xsl:text>vgl. </xsl:text>
         </xsl:when>
         <xsl:when test="@subtype = 'See'">
            <xsl:text>Siehe </xsl:text>
         </xsl:when>
         <xsl:when test="@subtype = 'Cf'">
            <xsl:text>Vgl. </xsl:text>
         </xsl:when>
      </xsl:choose>
      <xsl:text>$\triangleright$</xsl:text>
      <xsl:variable name="start-label" select="substring-after(@target, '#')"/>
      <xsl:choose>
         <xsl:when test="$start-label = ''">
            <xsl:text>\textcolor{red}{XXXX Labelref}</xsl:text>
         </xsl:when>
         <xsl:when test="ends-with(@target, 'v')">
            <xsl:variable name="end-label"
               select="concat(substring-after(substring-before(@target, 'v'), '#'), 'h')"/>
            <xsl:text>\myrangeref{</xsl:text>
            <xsl:value-of select="$start-label"/>
            <xsl:text>}{</xsl:text>
            <xsl:value-of select="$end-label"/>
            <xsl:text>}</xsl:text>
         </xsl:when>
         <xsl:otherwise>
            <xsl:text>\myrangeref{</xsl:text>
            <xsl:value-of select="$start-label"/>
            <xsl:text>v}{</xsl:text>
            <xsl:value-of select="$start-label"/>
            <xsl:text>h}</xsl:text>
         </xsl:otherwise>
      </xsl:choose>
   </xsl:template>
   <xsl:template match="ref[@type = 'footnotemarkpointer']">
      <!-- für Verweise auf Fußnotennummern. Innerhalb der Fußnote einen anchor setzen -->
      <xsl:text>\ref{</xsl:text>
      <xsl:value-of select="substring-after(@target, '#')"/>
      <xsl:text>}</xsl:text>
   </xsl:template>
   <xsl:template match="ref[@type = 'schnitzler-tagebuch']">
      <xsl:if test="not(@subtype = 'date-only')">
         <xsl:choose>
            <xsl:when test="@subtype = 'see'">
               <xsl:text>siehe </xsl:text>
            </xsl:when>
            <xsl:when test="@subtype = 'cf'">
               <xsl:text>vgl. </xsl:text>
            </xsl:when>
            <xsl:when test="@subtype = 'See'">
               <xsl:text>Siehe </xsl:text>
            </xsl:when>
            <xsl:when test="@subtype = 'Cf'">
               <xsl:text>Vgl. </xsl:text>
            </xsl:when>
         </xsl:choose>
         <xsl:text>A.{\,}S.: \emph{Tagebuch}, </xsl:text>
      </xsl:if>
      <xsl:value-of select="
            format-date(@target,
            '[D1].\,[M1].\,[Y0001]')"/>
   </xsl:template>
   <xsl:template match="ref[@type = 'url']">
      <xsl:text>\url{</xsl:text>
      <xsl:value-of select="(@target)"/>
      <xsl:text>}</xsl:text>
   </xsl:template>
   <xsl:template match="ref[@type = 'toLetter']">
      <xsl:variable name="target-path" as="xs:string">
         <xsl:choose>
            <xsl:when test="ends-with(@target, '.xml')">
               <xsl:value-of select="concat('../data/', @target)"/>
            </xsl:when>
            <xsl:otherwise>
               <xsl:value-of select="concat('../data/', @target, '.xml')"/>
            </xsl:otherwise>
         </xsl:choose>
      </xsl:variable>
      <xsl:choose>
         <xsl:when test="@subtype = 'date-only'">
            <xsl:value-of
               select="document(resolve-uri($target-path, document-uri(/)))//tei:correspDesc/tei:correspAction[@type = 'sent']/tei:date/text()"
            />
         </xsl:when>
         <xsl:otherwise>
            <xsl:choose>
               <xsl:when test="@subtype = 'see'">
                  <xsl:text>siehe </xsl:text>
               </xsl:when>
               <xsl:when test="@subtype = 'cf'">
                  <xsl:text>vgl. </xsl:text>
               </xsl:when>
               <xsl:when test="@subtype = 'See'">
                  <xsl:text>Siehe </xsl:text>
               </xsl:when>
               <xsl:when test="@subtype = 'Cf'">
                  <xsl:text>Vgl. </xsl:text>
               </xsl:when>
            </xsl:choose>
            <xsl:value-of
               select="document(resolve-uri($target-path, document-uri(/)))//tei:titleStmt/tei:title[@level = 'a']"
            />
         </xsl:otherwise>
      </xsl:choose>
   </xsl:template>
   <xsl:template match="ref[@type = 'question' and starts-with(ancestor::TEI/@id, 'I')]">
      <xsl:variable name="fragenummer" select="substring-after(@target, '#')"/>
      <xsl:variable name="frage" select="key('question-lookup', $fragenummer, $interviewfragen)"
         as="node()?"/>
      <xsl:choose>
         <xsl:when test="not($frage/. = '')">
            <xsl:text>\sindex[question]{</xsl:text>
            <xsl:value-of
               select="concat(normalize-space(foo:umlaute-entfernen($frage/@ana)), '@', normalize-space($frage/@ana), '!', normalize-space(foo:umlaute-entfernen($frage)), '@', normalize-space($frage))"/>
            <xsl:text>}</xsl:text>
            <!--<xsl:text>\textcolor{red}{\textsuperscript{</xsl:text>
            <xsl:value-of select="$fragenummer"/>
            <xsl:text>}}</xsl:text>-->
         </xsl:when>
         <xsl:otherwise>
            <xsl:text>\textcolor{red}{FRAGE XXXX</xsl:text>
            <xsl:value-of select="$fragenummer"/>
            <xsl:text>}</xsl:text>
         </xsl:otherwise>
      </xsl:choose>
   </xsl:template>
   <!-- Das hier reicht die LateX-Befehler direkt durch, die mit <?latex ....> markiert sind -->
   <xsl:template match="processing-instruction()[name() = 'latex']">
      <xsl:value-of select="concat('{', normalize-space(.), '}')"/>
   </xsl:template>
   <xsl:template match="*:latex">
      <xsl:choose>
         <xsl:when test="@alt = '\small'">
            <xsl:text>\small </xsl:text>
         </xsl:when>
         <xsl:when test="@alt = '\normalsize'">
            <xsl:text>\normalsize </xsl:text>
         </xsl:when>
         <xsl:otherwise>
            
                  <xsl:text>{</xsl:text>
                  <xsl:value-of select="@alt"/>
                  <xsl:text>}</xsl:text>
            
         </xsl:otherwise>
      </xsl:choose>
      
   </xsl:template>
</xsl:stylesheet>
