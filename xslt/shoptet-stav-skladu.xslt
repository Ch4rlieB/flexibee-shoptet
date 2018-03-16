<?xml version="1.0" encoding="utf-8" ?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:java="http://xml.apache.org/xalan/java" exclude-result-prefixes="java">
  <xsl:output method="xml" indent="yes" encoding="utf-8" />

  <xsl:template match="winstrom">
    <SHOP>
      <xsl:apply-templates select="skladova-karta"/>
    </SHOP>
  </xsl:template>

  <xsl:template match="skladova-karta">
    <!-- zpracování konkrétní skladové karty -->
    <SHOPITEM>
      <CODE><xsl:value-of select="java:flexibee.Tool.substring(cenik, 5)"/></CODE>
      <STOCK>
        <AMOUNT><xsl:value-of select="stavMjSPozadavky - rezervMJ"/></AMOUNT>
      </STOCK>
      <PURCHASE_PRICE><xsl:value-of select="java:flexibee.Tool.round(prumCenaTuz, '2')"/></PURCHASE_PRICE>
    </SHOPITEM>
  </xsl:template>

</xsl:stylesheet>
