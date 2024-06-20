<?xml version="1.0" encoding="utf-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:so="stackoverflow example"
    version="2.0">
    <xsl:output indent="no" method="text"/>
    <xsl:strip-space elements="*"/>
    <xsl:param name="list">
        <words>
            <word>
                <such>&#8239;</such>
                <replace>{\,}</replace>
            </word>
            <word>
                <search>.–«</search>
                <replace>{\dotdashausfuehrung} </replace>
            </word>
            <word>
                <search>.–</search>
                <replace>{\dotdash}</replace>
            </word>
            <word>
                <search>,–</search>
                <replace>{\commadash}</replace>
            </word>
            <word>
                <search>;–</search>
                <replace>{\semicolondash}</replace>
            </word>
            <word>
                <search>!–</search>
                <replace>{\excdash}</replace>
            </word>
        </words>
    </xsl:param>
    <xsl:function name="so:escapeRegex">
        <xsl:param name="regex"/>
        <xsl:analyze-string select="$regex" regex="\.|\{{">
            <xsl:matching-substring>
                <xsl:value-of select="concat('\', .)"/>
            </xsl:matching-substring>
            <xsl:non-matching-substring>
                <xsl:value-of select="."/>
            </xsl:non-matching-substring>
        </xsl:analyze-string>
    </xsl:function>
    <xsl:template match="@* | * | comment() | processing-instruction()">
        <xsl:copy>
            <xsl:apply-templates select="@* | node()"/>
        </xsl:copy>
    </xsl:template>
    <xsl:template match="text()">
        <xsl:variable name="search"
            select="so:escapeRegex(concat('(', string-join($list/words/word/search, '|'), ')'))"/>
        <xsl:analyze-string select="." regex="{$search}">
            <xsl:matching-substring>
                <xsl:message>"<xsl:value-of select="."/>" matched <xsl:value-of select="$search"/>
                </xsl:message>
                <xsl:value-of select="$list/words/word[child::search = current()]/replace"/>
            </xsl:matching-substring>
            <xsl:non-matching-substring>
                <xsl:value-of select="."/>
            </xsl:non-matching-substring>
        </xsl:analyze-string>
    </xsl:template>
</xsl:stylesheet>
