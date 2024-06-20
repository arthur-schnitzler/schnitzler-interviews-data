<?xml version="1.0" encoding="utf-8"?>
<!-- Dieses XSL, angewandt auf eine TEI-Datei setzt einen Kommentar, wenn einer Person oder ein Werk nicht explizit genannt ist -->

<!-- Fehler: die <rs type="implied" werden nicht mehr gesetzt, sondern nur die Kommentare -->
<!-- Fehler: Im Fall von mehreren Werken Schnitzlers klappt es nicht -->
<!-- Fehler: die XML:ids sollten ohne Rauten sein -->

<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:fn="http://www.w3.org/2005/xpath-functions"
    xmlns:foo="whatever" xmlns:tei="http://www.tei-c.org/ns/1.0" version="3.0">
    <xsl:output method="xml"/>
    <xsl:mode on-no-match="shallow-copy"/>
    <xsl:template match="tei:rs[@subtype = 'implied' and (@type = 'person' or @type = 'work')]">
        <xsl:variable name="reff" select="tokenize(@ref, ' #')[1]"/>
        <xsl:variable name="typ" select="@type"/>
        <xsl:choose>
            <xsl:when test="@ref = $reff">
                <xsl:choose>
                    <!-- es ist von Schnitzler, seiner Frau Olga, seinen Kindern oder dem Vater die Rede, dann muss kein Kommentar gesetzt werden -->
                    <xsl:when
                        test="$reff = '#2121' or $reff = '#2173' or $reff = '#2238' or $reff = '#12695' or $reff = '#12692'">
                        <xsl:copy-of select="."/>
                    </xsl:when>
                    <!-- es gibt eine namentliche Nennung: -->
                    <xsl:when
                        test="ancestor::tei:body//tei:rs[not(@subtype = 'implied')]/@ref = $reff">
                        <xsl:copy-of select="."/>
                    </xsl:when>
                    <!-- es ist nicht das erste Vorkommen dieser @ref-nummer -->
                    <xsl:when
                        test="not((//ancestor::tei:body//tei:rs[@subtype = 'implied' and @ref = $reff])[1] is .)">
                        <xsl:copy-of select="."/>
                    </xsl:when>
                    <!-- Erwähnung im biografischen Teil -->
                    <xsl:when test="ancestor::tei:div[@type = 'biographical']">
                        <xsl:copy-of select="."/>
                    </xsl:when>
                    <!-- Erwähnung im Kommentar Teil -->
                    <xsl:when test="ancestor::tei:note">
                        <xsl:copy-of select="."/>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:variable name="nummer" select="substring-after($reff, '#')"/>
                        <xsl:variable name="tei-ende" select="'/?format=tei'" as="xs:string"/>
                        <xsl:variable name="eintrag"
                            select="fn:escape-html-uri(concat('https://pmb.acdh.oeaw.ac.at/entity/', $nummer, $tei-ende))"
                            as="xs:string"/>
                        <xsl:element name="anchor" namespace="http://www.tei-c.org/ns/1.0">
                            <xsl:attribute name="type">
                                <xsl:text>commentary</xsl:text>
                            </xsl:attribute>
                            <xsl:attribute name="xml:id">
                                <xsl:value-of select="concat('K_implied_', @ref)"/>
                            </xsl:attribute>
                        </xsl:element>
                        <xsl:apply-templates/>
                        <xsl:element name="note" namespace="http://www.tei-c.org/ns/1.0">
                            <xsl:attribute name="type">
                                <xsl:text>commentary</xsl:text>
                            </xsl:attribute>
                            <xsl:attribute name="xml:id">
                                <xsl:value-of select="concat('K_implied_', @ref, 'h')"/>
                            </xsl:attribute>
                            <xsl:choose>
                                <xsl:when test="doc-available($eintrag)">
                                    <xsl:choose>
                                        <xsl:when test="@type = 'person'">
                                            <xsl:variable name="entry"
                                                select="document($eintrag)/descendant::tei:body[1]/tei:listPerson[1]/tei:person/tei:persName"/>
                                            <xsl:choose>
                                                <xsl:when
                                                  test="$entry/tei:surname and $entry/tei:forename">
                                                  <xsl:element name="rs"
                                                  namespace="http://www.tei-c.org/ns/1.0">
                                                  <xsl:attribute name="type">
                                                  <xsl:text>person</xsl:text>
                                                  </xsl:attribute>
                                                  <xsl:attribute name="ref">
                                                  <xsl:value-of select="$nummer"/>
                                                  </xsl:attribute>
                                                  <xsl:value-of
                                                  select="concat(normalize-space($entry/tei:forename), ' ', normalize-space($entry/tei:surname))"
                                                  />
                                                  </xsl:element>
                                                </xsl:when>
                                                <xsl:when test="$entry/tei:surname">
                                                  <xsl:choose>
                                                  <xsl:when
                                                  test="starts-with(normalize-space($entry/tei:surname), '??')">
                                                  <xsl:text>nicht identifiziert</xsl:text>
                                                  </xsl:when>
                                                  <xsl:otherwise>
                                                  <xsl:element name="rs"
                                                  namespace="http://www.tei-c.org/ns/1.0">
                                                  <xsl:attribute name="type">
                                                  <xsl:text>person</xsl:text>
                                                  </xsl:attribute>
                                                  <xsl:attribute name="ref">
                                                  <xsl:value-of select="$nummer"/>
                                                  </xsl:attribute>
                                                  <xsl:value-of
                                                  select="normalize-space($entry/tei:surname)"/>
                                                  </xsl:element>
                                                  </xsl:otherwise>
                                                  </xsl:choose>
                                                </xsl:when>
                                                <xsl:when test="$entry/tei:forename">
                                                  <xsl:element name="rs"
                                                  namespace="http://www.tei-c.org/ns/1.0">
                                                  <xsl:attribute name="type">
                                                  <xsl:text>person</xsl:text>
                                                  </xsl:attribute>
                                                  <xsl:attribute name="ref">
                                                  <xsl:value-of select="$nummer"/>
                                                  </xsl:attribute>
                                                  <xsl:value-of
                                                  select="normalize-space($entry/tei:forename)"/>
                                                  </xsl:element>
                                                </xsl:when>
                                            </xsl:choose>
                                        </xsl:when>
                                        <xsl:when test="@type = 'work'">
                                            <xsl:variable name="work-entry"
                                                select="document($eintrag)/descendant::tei:body[1]/tei:list[1]/tei:item"/>
                                            <xsl:element name="rs"
                                                namespace="http://www.tei-c.org/ns/1.0">
                                                <xsl:attribute name="type">
                                                  <xsl:text>work</xsl:text>
                                                </xsl:attribute>
                                                <xsl:attribute name="ref">
                                                  <xsl:value-of select="$nummer"/>
                                                </xsl:attribute>
                                                <xsl:value-of
                                                  select="fn:normalize-space($work-entry)"/>
                                            </xsl:element>
                                            <xsl:choose>
                                                <!-- Werk mit mehreren Verfassern: -->
                                                <xsl:when
                                                  test="$work-entry/tei:note[@type = 'persons']/tei:ptr[@type = 'steht-in-beziehung-zu-person-geschaffen-von'][2]">
                                                  <xsl:text> von </xsl:text>
                                                  <xsl:for-each
                                                  select="$work-entry/tei:note[@type = 'persons']/tei:ptr[@type = 'steht-in-beziehung-zu-person-geschaffen-von']/@target">
                                                  <xsl:variable name="autor-ptr"
                                                  select="fn:escape-html-uri(concat(., '/?format=tei'))"
                                                  as="xs:string"/>
                                                  <xsl:variable name="entry"
                                                  select="document($autor-ptr)/descendant::tei:body[1]/tei:listPerson[1]/tei:person/tei:persName"/>
                                                  <xsl:choose>
                                                  <xsl:when
                                                  test="$entry/tei:surname and $entry/tei:forename">
                                                  <xsl:element name="rs"
                                                  namespace="http://www.tei-c.org/ns/1.0">
                                                  <xsl:attribute name="type">
                                                  <xsl:text>person</xsl:text>
                                                  </xsl:attribute>
                                                  <xsl:attribute name="ref">
                                                  <xsl:value-of select="$nummer"/>
                                                  </xsl:attribute>
                                                  <xsl:value-of
                                                  select="concat(normalize-space($entry/tei:forename), ' ', normalize-space($entry/tei:surname))"
                                                  />
                                                  </xsl:element>
                                                  </xsl:when>
                                                  <xsl:when test="$entry/tei:surname">
                                                  <xsl:choose>
                                                  <xsl:when
                                                  test="starts-with(normalize-space($entry/tei:surname), '??')">
                                                  <xsl:text>nicht identifiziert</xsl:text>
                                                  </xsl:when>
                                                  <xsl:otherwise>
                                                  <xsl:element name="rs"
                                                  namespace="http://www.tei-c.org/ns/1.0">
                                                  <xsl:attribute name="type">
                                                  <xsl:text>person</xsl:text>
                                                  </xsl:attribute>
                                                  <xsl:attribute name="ref">
                                                  <xsl:value-of select="$nummer"/>
                                                  </xsl:attribute>
                                                  <xsl:value-of
                                                  select="normalize-space($entry/tei:surname)"/>
                                                  </xsl:element>
                                                  </xsl:otherwise>
                                                  </xsl:choose>
                                                  </xsl:when>
                                                  <xsl:when test="$entry/tei:forename">
                                                  <xsl:element name="rs"
                                                  namespace="http://www.tei-c.org/ns/1.0">
                                                  <xsl:attribute name="type">
                                                  <xsl:text>person</xsl:text>
                                                  </xsl:attribute>
                                                  <xsl:attribute name="ref">
                                                  <xsl:value-of select="$nummer"/>
                                                  </xsl:attribute>
                                                  <xsl:value-of
                                                  select="normalize-space($entry/tei:forename)"/>
                                                  </xsl:element>
                                                  </xsl:when>
                                                  </xsl:choose>
                                                  <xsl:choose>
                                                  <xsl:when test="position() = last()"/>
                                                  <xsl:when test="position() = (last() - 1)">
                                                  <xsl:text> und </xsl:text>
                                                  </xsl:when>
                                                  <xsl:otherwise>
                                                  <xsl:text>, </xsl:text>
                                                  </xsl:otherwise>
                                                  </xsl:choose>
                                                  </xsl:for-each>
                                                </xsl:when>
                                                <!-- Texte von Schnitzler ohne Verfasserangabe wiedergeben-->
                                                <xsl:when
                                                  test="$work-entry/tei:note[@type = 'persons']/tei:ptr[@type = 'steht-in-beziehung-zu-person-geschaffen-von']/@target = 'https://pmb.acdh.oeaw.ac.at/entity/2121'"/>
                                                <!-- Texte ohne Verfasserangabe -->
                                                <xsl:when
                                                  test="not($work-entry/tei:note[@type = 'persons'])"/>
                                                <xsl:when
                                                  test="$work-entry/tei:note[@type = 'persons']/tei:ptr[@type = 'steht-in-beziehung-zu-person-geschaffen-von']">
                                                  <xsl:text> von </xsl:text>
                                                  <xsl:variable name="autor-ptr"
                                                  select="fn:escape-html-uri(concat($work-entry/tei:note[@type = 'persons']/tei:ptr[@type = 'steht-in-beziehung-zu-person-geschaffen-von']/@target, '/?format=tei'))"
                                                  as="xs:string"/>
                                                  <xsl:variable name="entry"
                                                  select="document($autor-ptr)/descendant::tei:body[1]/tei:listPerson[1]/tei:person/tei:persName"/>
                                                  <xsl:choose>
                                                  <xsl:when
                                                  test="$entry/tei:surname and $entry/tei:forename">
                                                  <xsl:element name="rs"
                                                  namespace="http://www.tei-c.org/ns/1.0">
                                                  <xsl:attribute name="type">
                                                  <xsl:text>person</xsl:text>
                                                  </xsl:attribute>
                                                  <xsl:attribute name="ref">
                                                  <xsl:value-of select="$nummer"/>
                                                  </xsl:attribute>
                                                  <xsl:value-of
                                                  select="concat(normalize-space($entry/tei:forename), ' ', normalize-space($entry/tei:surname))"
                                                  />
                                                  </xsl:element>
                                                  </xsl:when>
                                                  <xsl:when test="$entry/tei:surname">
                                                  <xsl:choose>
                                                  <xsl:when
                                                  test="starts-with(normalize-space($entry/tei:surname), '??')">
                                                  <xsl:text>nicht identifiziert</xsl:text>
                                                  </xsl:when>
                                                  <xsl:otherwise>
                                                  <xsl:element name="rs"
                                                  namespace="http://www.tei-c.org/ns/1.0">
                                                  <xsl:attribute name="type">
                                                  <xsl:text>person</xsl:text>
                                                  </xsl:attribute>
                                                  <xsl:attribute name="ref">
                                                  <xsl:value-of select="$nummer"/>
                                                  </xsl:attribute>
                                                  <xsl:value-of
                                                  select="normalize-space($entry/tei:surname)"/>
                                                  </xsl:element>
                                                  </xsl:otherwise>
                                                  </xsl:choose>
                                                  </xsl:when>
                                                  <xsl:when test="$entry/tei:forename">
                                                  <xsl:element name="rs"
                                                  namespace="http://www.tei-c.org/ns/1.0">
                                                  <xsl:attribute name="type">
                                                  <xsl:text>person</xsl:text>
                                                  </xsl:attribute>
                                                  <xsl:attribute name="ref">
                                                  <xsl:value-of select="$nummer"/>
                                                  </xsl:attribute>
                                                  <xsl:value-of
                                                  select="normalize-space($entry/tei:forename)"/>
                                                  </xsl:element>
                                                  </xsl:when>
                                                  </xsl:choose>
                                                </xsl:when>
                                                <xsl:otherwise>
                                                  <xsl:text>XXXX Werkangabe überprüfen</xsl:text>
                                                </xsl:otherwise>
                                            </xsl:choose>
                                        </xsl:when>
                                    </xsl:choose>
                                </xsl:when>
                                <xsl:otherwise>
                                    <xsl:text>XXXXX fehlt in PMB</xsl:text>
                                    <xsl:copy-of select="."/>
                                </xsl:otherwise>
                            </xsl:choose>
                        </xsl:element>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:when>
            <xsl:otherwise>
                <xsl:element name="anchor" namespace="http://www.tei-c.org/ns/1.0">
                    <xsl:attribute name="type">
                        <xsl:text>commentary</xsl:text>
                    </xsl:attribute>
                    <xsl:attribute name="xml:id">
                        <xsl:value-of select="concat('K_implied_', $reff)"/>
                    </xsl:attribute>
                </xsl:element>
                <xsl:apply-templates/>
                <xsl:element name="note" namespace="http://www.tei-c.org/ns/1.0">
                    <xsl:attribute name="type">
                        <xsl:text>commentary</xsl:text>
                    </xsl:attribute>
                    <xsl:attribute name="xml:id">
                        <xsl:value-of select="concat('K_implied_', $reff, 'h')"/>
                    </xsl:attribute>
                    <xsl:for-each select="tokenize(@ref, ' ')">
                            <xsl:variable name="nummer"
                                select="normalize-space(substring-after(., '#'))"/>
                            <xsl:variable name="tei-ende" select="'/?format=tei'" as="xs:string"/>
                            <xsl:variable name="eintrag"
                                select="fn:escape-html-uri(concat('https://pmb.acdh.oeaw.ac.at/entity/', $nummer, $tei-ende))"
                                as="xs:string"/>
                            <xsl:choose>
                                <xsl:when test="$typ = 'person'">
                                    <xsl:variable name="entry"
                                        select="document($eintrag)/descendant::tei:body[1]/tei:listPerson[1]/tei:person/tei:persName"/>
                                    <xsl:choose>
                                        <xsl:when test="$entry/tei:surname and $entry/tei:forename">
                                            <xsl:element name="rs"
                                                namespace="http://www.tei-c.org/ns/1.0">
                                                <xsl:attribute name="type">
                                                  <xsl:text>person</xsl:text>
                                                </xsl:attribute>
                                                <xsl:attribute name="ref">
                                                  <xsl:value-of select="$nummer"/>
                                                </xsl:attribute>
                                                <xsl:value-of
                                                  select="concat(normalize-space($entry/tei:forename), ' ', normalize-space($entry/tei:surname))"
                                                />
                                            </xsl:element>
                                        </xsl:when>
                                        <xsl:when test="$entry/tei:surname">
                                            <xsl:choose>
                                                <xsl:when
                                                  test="starts-with(normalize-space($entry/tei:surname), '??')">
                                                  <xsl:text>nicht identifiziert</xsl:text>
                                                </xsl:when>
                                                <xsl:otherwise>
                                                  <xsl:element name="rs"
                                                  namespace="http://www.tei-c.org/ns/1.0">
                                                  <xsl:attribute name="type">
                                                  <xsl:text>person</xsl:text>
                                                  </xsl:attribute>
                                                  <xsl:attribute name="ref">
                                                  <xsl:value-of select="$nummer"/>
                                                  </xsl:attribute>
                                                  <xsl:value-of
                                                  select="normalize-space($entry/tei:surname)"/>
                                                  </xsl:element>
                                                </xsl:otherwise>
                                            </xsl:choose>
                                        </xsl:when>
                                        <xsl:when test="$entry/tei:forename">
                                            <xsl:element name="rs"
                                                namespace="http://www.tei-c.org/ns/1.0">
                                                <xsl:attribute name="type">
                                                  <xsl:text>person</xsl:text>
                                                </xsl:attribute>
                                                <xsl:attribute name="ref">
                                                  <xsl:value-of select="$nummer"/>
                                                </xsl:attribute>
                                                <xsl:value-of
                                                  select="normalize-space($entry/tei:forename)"/>
                                            </xsl:element>
                                        </xsl:when>
                                    </xsl:choose>
                                </xsl:when>
                                <xsl:otherwise>
                                    <xsl:text>XXXXX nicht vorhergesehen</xsl:text>
                                    <xsl:copy-of select="."/>
                                </xsl:otherwise>
                            </xsl:choose>
                        
                        <xsl:if test="not(position() = last())">
                            <xsl:text>, </xsl:text>
                        </xsl:if>
                    </xsl:for-each>
                </xsl:element>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
</xsl:stylesheet>
