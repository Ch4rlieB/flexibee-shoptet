<?xml version="1.0" encoding="utf-8" ?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
     xmlns:java="http://xml.apache.org/xalan/java" exclude-result-prefixes="java">
  <xsl:output method="xml" indent="yes" encoding="utf-8" />

  <xsl:template match="winstrom">
    <SHOP>
      <xsl:apply-templates select="cenik"/>
    </SHOP>
  </xsl:template>

  <xsl:template match="cenik">
    <SHOPITEM>
      <CODE><xsl:value-of select="kod"/></CODE>
      <NAME><xsl:value-of select="nazev"/></NAME>
      <PRICE><xsl:value-of select="java:flexibee.Tool.round(cenaZaklBezDph, 2)"/></PRICE>
      <PRICE_VAT><xsl:value-of select="java:flexibee.Tool.round(cenaZaklVcDph, 2)"/></PRICE_VAT>
      <PURCHASE_PRICE><xsl:value-of select="java:flexibee.Tool.round(nakupCena, 2)"/></PURCHASE_PRICE>
      <STANDARD_PRICE><xsl:value-of select="java:flexibee.Tool.round(cenaBezna, 2)"/></STANDARD_PRICE>
      <CURRENCY>CZK</CURRENCY>

      <xsl:if test="skladove = 'true'">
        <STOCK>
          <!--MAXIMAL_AMOUNT></MAXIMAL_AMOUNT-->
          <MINIMAL_AMOUNT>1</MINIMAL_AMOUNT>
          <AMOUNT><xsl:value-of select="sumDostupMj"/></AMOUNT>
        </STOCK>
      </xsl:if>

      <xsl:choose>
        <xsl:when test="kratkyPopis != ''"><SHORT_DESCRIPTION><xsl:value-of select="kratkyPopis"/></SHORT_DESCRIPTION></xsl:when>
        <xsl:when test="popis != ''"><SHORT_DESCRIPTION><xsl:value-of select="popis"/></SHORT_DESCRIPTION></xsl:when>
        <xsl:otherwise></xsl:otherwise>
      </xsl:choose>

      <xsl:if test="popis != ''">
        <DESCRIPTION><xsl:value-of select="popis"/></DESCRIPTION>
      </xsl:if>

      <xsl:if test="mj1 != ''">
        <UNIT><xsl:value-of select="java:flexibee.Tool.substring(mj1, 5)"/></UNIT>
      </xsl:if>

      <ITEM_TYPE>
        <xsl:choose>
          <xsl:when test="typZasobyK = 'typZasoby.sluzba'">service</xsl:when>
          <xsl:otherwise>product</xsl:otherwise>
        </xsl:choose>
      </ITEM_TYPE>

      <xsl:if test="vyrobce != ''">
        <MANUFACTURER><xsl:value-of select="java:flexibee.Tool.substring(vyrobce, 5)"/></MANUFACTURER>
      </xsl:if>

      <AVAILABILITY>
        <xsl:choose>
          <xsl:when test="sumStavMj > 0.0">Skladem</xsl:when>
          <xsl:otherwise>Není skladem</xsl:otherwise>
        </xsl:choose>
      </AVAILABILITY>

      <!-- odkomentováním následujících řádků a jejich správným vyplněním je možné vyplnit i další vlastnosti -->
      <!--VISIBILITY></VISIBILITY-->
      <!--WARRANTY></WARRANTY-->
      <!--WEIGHT></WEIGHT-->
      <!--CATEGORY></CATEGORY-->
      <!--FLAGS></FLAGS-->
      <!--FREE_SHIPPING></FREE_SHIPPING-->
      <!--IMAGES></IMAGES-->
      <!--INFORMATION_PARAMETERS></INFORMATION_PARAMETERS-->
      <!--PARAMETERS></PARAMETERS-->
      <!--TEXT_PROPERTIES></TEXT_PROPERTIES-->
      <!--ALTERNATIVE_PRODUCTS>
        <CODE></CODE>
      </ALTERNATIVE_PRODUCTS-->
      <!--RELATED_PRODUCTS>
        <CODE></CODE>
      </RELATED_PRODUCTS-->

    </SHOPITEM>
  </xsl:template>

</xsl:stylesheet>
