<?xml version="1.0" encoding="utf-8" ?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0" xmlns:java="http://xml.apache.org/xalan/java" exclude-result-prefixes="java">

  <xsl:output method="xml" encoding="utf-8" />

  <!-- zkratka skladu na kterém je zboží určené pro eshop -->
  <xsl:variable name="sklad" select="'SKLAD'" />

  <xsl:template match="SHOP">
    <winstrom version="1.0">
      <xsl:apply-templates select="SHOPITEM"/>
      <xsl:apply-templates select="SHOPITEM/SET_ITEMS"/>
    </winstrom>
  </xsl:template>

  <xsl:template name="STEJNE">
    <!-- vytvoření produktu - není rozdíl mezi produktem s variantami a bez variant -->
    <xsl:param name="itemType"/>
    <!-- identifikátory -->
    <id>code:<xsl:value-of select="CODE"/></id>
    <kod><xsl:value-of select="CODE"/></kod>
    <xsl:if test="EAN and EAN != ''">
      <!--id>ean:<xsl:value-of select="EAN"/></id-->
      <eanKod><xsl:value-of select="EAN"/></eanKod>
    </xsl:if>

    <!-- důležitá pole -->
    <xsl:choose>
      <xsl:when test="PRICE_VAT">
        <cenaZakl><xsl:value-of select="PRICE_VAT"/></cenaZakl>
        <typCenyDphK>typCeny.sDph</typCenyDphK>
      </xsl:when>
      <xsl:when test="PRICE">
        <cenaZakl><xsl:value-of select="PRICE"/></cenaZakl>
        <typCenyDphK>typCeny.bezDph</typCenyDphK>
      </xsl:when>
    </xsl:choose>
    <xsl:choose>
      <xsl:when test="VAT = 0">
        <typSzbDphK>typSzbDph.dphOsv</typSzbDphK>
      </xsl:when>
      <xsl:when test="VAT = 10">
        <typSzbDphK>typSzbDph.dphSniz2</typSzbDphK>
      </xsl:when>
      <xsl:when test="VAT = 15">
        <typSzbDphK>typSzbDph.dphSniz</typSzbDphK>
      </xsl:when>
      <xsl:otherwise>
        <typSzbDphK>typSzbDph.dphZakl</typSzbDphK>
      </xsl:otherwise>
    </xsl:choose>

    <xsl:if test="$itemType = 'product' or $itemType = 'set'">
      <!-- skladové karty -->
      <skladove>true</skladove>
      <sklad-karty>
        <skladova-karta>
          <sklad>code:<xsl:value-of select="$sklad"/></sklad>
          <ucetObdobi>code:<xsl:value-of select="java:flexibee.Tool.substring(java:flexibee.Tool.currentDate(), 0, 4)"/></ucetObdobi>
        </skladova-karta>
      </sklad-karty>
    </xsl:if>

    <poznam><xsl:value-of select="$itemType"/></poznam>
  </xsl:template>

  <xsl:template name="ITEM">
    <!-- jednoduchý produkt -->
    <cenik>
      <id>ext:shoptet-product:<xsl:value-of select="@id"/></id>
      <xsl:call-template name="STEJNE">
        <xsl:with-param name="itemType" select="ITEM_TYPE" />
      </xsl:call-template>
      <nazev><xsl:value-of select="NAME"/></nazev>
    </cenik>
  </xsl:template>

  <xsl:template match="VARIANTS/VARIANT">
    <!-- produkt s variantami -->
    <cenik>
      <id>ext:shoptet-product:<xsl:value-of select="../../@id"/>-<xsl:value-of select="@id"/></id>
      <id>ext:shoptet-product-variant:<xsl:value-of select="@id"/></id>
      <xsl:call-template name="STEJNE">
        <xsl:with-param name="itemType" select="../../ITEM_TYPE" />
      </xsl:call-template>
      <xsl:if test="../../ITEM_TYPE = 'set'">
        <setWithVariants/>
      </xsl:if>
      <nazev><xsl:value-of select="../../NAME"/> - <xsl:value-of select="CODE"/></nazev>
    </cenik>
  </xsl:template>

  <xsl:template match="SHOPITEM">
    <!-- rozhodování zda se jedná o produkt s variantami nebo bez variant -->
    <xsl:if test="VARIANTS">
      <xsl:apply-templates select="VARIANTS/VARIANT"/>
    </xsl:if>
    <xsl:if test="not(VARIANTS)">
      <xsl:call-template name="ITEM"/>
    </xsl:if>
  </xsl:template>

  <xsl:template match="SHOPITEM/SET_ITEMS">
    <!-- zpracování rozpadů sad -->
    <cenik>
      <id>code:<xsl:value-of select="../CODE"/></id>
      <xsl:if test="../ITEM_TYPE = 'set'">
        <sady-a-komplety removeAll="true">
          <xsl:apply-templates select="SET_ITEM"/>
        </sady-a-komplety>
      </xsl:if>
    </cenik>
  </xsl:template>

  <xsl:template match="SET_ITEM">
    <!-- jednotlivý rozpad sady -->
    <sady-a-komplety>
      <id>ext:SHOPTET-SET:<xsl:value-of select="../../CODE"/>-<xsl:value-of select="CODE"/>-<xsl:value-of select="AMOUNT"/></id>
      <!--cenikSada>code:<xsl:value-of select="../../CODE"/></cenikSada-->
      <cenik>code:<xsl:value-of select="CODE"/></cenik>
      <mnozMj><xsl:value-of select="AMOUNT"/></mnozMj>
    </sady-a-komplety>
  </xsl:template>

</xsl:stylesheet>
