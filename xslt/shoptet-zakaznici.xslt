<?xml version="1.0" encoding="utf-8" ?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:java="http://xml.apache.org/xalan/java" exclude-result-prefixes="java">
  <xsl:output method="xml" indent="yes" encoding="utf-8" />

  <xsl:template match="CUSTOMERS">
    <winstrom verison="1.0">
      <xsl:apply-templates select="CUSTOMER"/>
    </winstrom>
  </xsl:template>

  <xsl:template match="CUSTOMER">
    <!-- zpracování konkrétního zákazníka -->
    <adresar>
      <id>ext:SHOPTET-CUSTOMER:<xsl:value-of select="GUID"/></id>
      <xsl:if test="ACCOUNTS/ACCOUNT/EMAIL != ''">
        <id>ext:SHOPTET-CUSTOMER-EMAIL:<xsl:value-of select="ACCOUNTS/ACCOUNT/EMAIL"/></id>
      </xsl:if>
      <xsl:choose>
        <xsl:when test="BILLING_ADDRESS/FULL_NAME != ''">
          <nazev><xsl:value-of select="BILLING_ADDRESS/FULL_NAME"/></nazev>
        </xsl:when>
        <xsl:otherwise>
          <nazev><xsl:value-of select="ACCOUNTS/ACCOUNT/EMAIL"/></nazev>
        </xsl:otherwise>
      </xsl:choose>
      <nazev2><xsl:value-of select="BILLING_ADDRESS/COMPANY"/></nazev2>
      <ulice><xsl:value-of select="BILLING_ADDRESS/STREET"/> <xsl:value-of select="BILLING_ADDRESS/HOUSE_NUMBER"/></ulice>
      <mesto><xsl:value-of select="BILLING_ADDRESS/CITY"/></mesto>
      <psc><xsl:value-of select="BILLING_ADDRESS/ZIP"/></psc>
      <xsl:apply-templates select ="BILLING_ADDRESS"/>
      <ic><xsl:value-of select="BILLING_ADDRESS/COMPANY_ID"/></ic>
      <dic><xsl:value-of select="BILLING_ADDRESS/VAT_ID"/></dic>
      <skupFir if-not-found="create">code:<xsl:value-of select="java:flexibee.Tool.toUpper(CUSTOMER_GROUP)"/></skupFir>
      <skupCen if-not-found="create">code:<xsl:value-of select="java:flexibee.Tool.toUpper(PRICELIST)"/></skupCen>
      <poznam><xsl:value-of select="REMARK"/></poznam>
      <kontakty>
        <xsl:apply-templates select ="ACCOUNTS/ACCOUNT"/>
      </kontakty>
    </adresar>

    <xsl:apply-templates select ="SHIPPING_ADDRESSES/SHIPPING_ADDRESS"/>

  </xsl:template>

  <xsl:template match="BILLING_ADDRESS">
    <xsl:call-template name="STAT"/>
  </xsl:template>

  <xsl:template match="SHIPPING_ADDRESSES/SHIPPING_ADDRESS">
    <misto-urceni>
      <!-- vytvoření dodacích adres -->
      <id>ext:SHOPTET-SHIPPING:<xsl:value-of select="GUID"/></id>
      <firma>ext:SHOPTET-CUSTOMER:<xsl:value-of select="../../GUID"/></firma>
      <xsl:choose>
        <xsl:when test="FULL_NAME != ''">
          <nazev><xsl:value-of select="FULL_NAME"/></nazev>
        </xsl:when>
        <xsl:otherwise>
          <nazev><xsl:value-of select="../../ACCOUNTS/ACCOUNT/EMAIL"/></nazev>
        </xsl:otherwise>
      </xsl:choose>
      <nazev2><xsl:value-of select="COMPANY"/></nazev2>
      <ulice><xsl:value-of select="STREET"/> <xsl:value-of select="HOUSE_NUMBER"/></ulice>
      <mesto><xsl:value-of select="CITY"/></mesto>
      <psc><xsl:value-of select="ZIP"/></psc>
      <xsl:call-template name="STAT"/>
    </misto-urceni>
  </xsl:template>

  <xsl:template match="ACCOUNTS/ACCOUNT">
    <kontakt>
      <!-- vytvoření kontaktů -->
      <id>ext:SHOPTET-ACCOUNT:<xsl:value-of select="GUID"/></id>
      <prijmeni><xsl:value-of select="EMAIL"/></prijmeni>
      <email><xsl:value-of select="EMAIL"/></email>
      <tel><xsl:value-of select="PHONE"/></tel>
    </kontakt>
  </xsl:template>

  <xsl:template name="STAT">
    <!-- správné naplnění pole stát v adrese ve FlexiBee -->
    <xsl:choose>
      <xsl:when test="COUNTRY = ''"><stat></stat></xsl:when>
      <xsl:when test="COUNTRY = 'Česká republika'"><stat>code:CZ</stat></xsl:when>
      <xsl:when test="COUTNRY = 'Slovensko'"><stat>code:SK</stat></xsl:when>
      <!-- zde je potřeba doplnit mapování dalších států -->
      <xsl:otherwise><stat>NEDEFINOVANO - <xsl:value-of select="COUNTRY"/></stat></xsl:otherwise>
    </xsl:choose>
  </xsl:template>

</xsl:stylesheet>
