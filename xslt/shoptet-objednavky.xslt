<?xml version="1.0" encoding="utf-8" ?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:java="http://xml.apache.org/xalan/java" exclude-result-prefixes="java">
  <xsl:output method="xml" indent="yes" encoding="utf-8" />

  <!-- zkratka skladu na kterém je zboží určené pro eshop -->
  <xsl:variable name="sklad" select="'SKLAD'" />
  <!-- zkratka typu dokladu vytvářených objednávek -->
  <xsl:variable name="typDokl" select="'OBP'"/>

  <xsl:template match="ORDERS">
    <winstrom version="1.0">
      <xsl:apply-templates select="ORDER"/>
    </winstrom>
  </xsl:template>

  <xsl:template match="ORDER">
    <objednavka-prijata>
      <!-- zpracování jedné objednávky -->
      <id>ext:SHOPTET-ORDER:<xsl:value-of select="ORDER_ID"/></id>
      <id>code:<xsl:value-of select="CODE"/></id>
      <kod><xsl:value-of select="CODE"/></kod>
      <varSym><xsl:value-of select="CODE"/></varSym>
      <typDokl>code:<xsl:value-of select="$typDokl"/></typDokl>
      <datVyst><xsl:value-of select="java:flexibee.Tool.parseDate(DATE, 'y-M-d H:m:s')"/></datVyst>
      <mena>code:<xsl:value-of select="CURRENCY/CODE"/></mena>

      <xsl:choose>
        <xsl:when test="STATUS = 'Stornována'">
          <stavUzivK>stavDoklObch.storno</stavUzivK>
        </xsl:when>
        <xsl:otherwise>
          <!-- ostatní stavy zatím neřešíme -->
        </xsl:otherwise>
      </xsl:choose>

      <!-- forma úhrady -->
      <xsl:for-each select="ORDER_ITEMS/ITEM[TYPE='billing']">
        <formaUhradyCis if-not-found="null">code:<xsl:value-of select="java:flexibee.Tool.substring(java:flexibee.Tool.toUpper(NAME), 0, 20)"/></formaUhradyCis>
      </xsl:for-each>

      <!-- forma dopravy -->
      <xsl:for-each select="ORDER_ITEMS/ITEM[TYPE='shipping']">
        <formaDopravy if-not-found="null">code:<xsl:value-of select="java:flexibee.Tool.substring(java:flexibee.Tool.toUpper(NAME), 0, 20)"/></formaDopravy>
      </xsl:for-each>

      <firma if-not-found="null">ext:SHOPTET-CUSTOMER-EMAIL:<xsl:value-of select="CUSTOMER/EMAIL"/></firma>
      
      <!-- záložka sídlo - fakturační adresa -->
      <xsl:choose>
        <xsl:when test="CUSTOMER/BILLING_ADDRESS/COMPANY = ''">
          <nazFirmy><xsl:value-of select="CUSTOMER/BILLING_ADDRESS/NAME"/></nazFirmy>
        </xsl:when>
        <xsl:otherwise>
          <nazFirmy><xsl:value-of select="CUSTOMER/BILLING_ADDRESS/NAME"/> - <xsl:value-of select="CUSTOMER/BILLING_ADDRESS/COMPANY"/></nazFirmy>
        </xsl:otherwise>
      </xsl:choose>
      <ulice><xsl:value-of select="CUSTOMER/BILLING_ADDRESS/STREET"/> <xsl:value-of select="CUSTOMER/BILLING_ADDRESS/HOUSENUMBER"/></ulice>
      <mesto><xsl:value-of select="CUSTOMER/BILLING_ADDRESS/CITY"/></mesto>
      <psc><xsl:value-of select="CUSTOMER/BILLING_ADDRESS/ZIP" /></psc>
      <xsl:choose>
        <xsl:when test="CUSTOMER/BILLING_ADDRESS/COUNTRY = ''"><stat>code:CZ</stat></xsl:when>
        <xsl:when test="CUSTOMER/BILLING_ADDRESS/COUNTRY = 'Česká republika'"><stat>code:CZ</stat></xsl:when>
        <xsl:when test="CUSTOMER/BILLING_ADDRESS/COUNTRY = 'Slovensko'"><stat>code:SK</stat></xsl:when>
        <!-- sem je potřeba doplňovat další státy -->
        <xsl:otherwise><stat>NEDEFINOVANO - <xsl:value-of select="CUSTOMER/BILLING_ADDRESS/COUNTRY"/></stat></xsl:otherwise>
      </xsl:choose>
      <ic><xsl:value-of select="CUSTOMER/BILLING_ADDRESS/COMPANY_ID"/></ic>
      <dic><xsl:value-of select="CUSTOMER/BILLING_ADDRESS/VAT_ID"/></dic>

      <!-- záložka poštovní adresa - dodací adresa -->
      <postovniShodna>false</postovniShodna>
      <xsl:choose>
        <xsl:when test="CUSTOMER/SHIPPING_ADDRESS/COMPANY = ''">
          <faNazev><xsl:value-of select="CUSTOMER/SHIPPING_ADDRESS/NAME"/></faNazev>
        </xsl:when>
        <xsl:otherwise>
          <faNazev><xsl:value-of select="CUSTOMER/SHIPPING_ADDRESS/NAME"/> - <xsl:value-of select="CUSTOMER/SHIPPING_ADDRESS/COMPANY"/></faNazev>
        </xsl:otherwise>
      </xsl:choose>
      <faUlice><xsl:value-of select="CUSTOMER/SHIPPING_ADDRESS/STREET"/> <xsl:value-of select="CUSTOMER/SHIPPING_ADDRESS/HOUSENUMBER"/></faUlice>
      <faMesto><xsl:value-of select="CUSTOMER/SHIPPING_ADDRESS/CITY"/></faMesto>
      <faPsc><xsl:value-of select="CUSTOMER/SHIPPING_ADDRESS/ZIP"/></faPsc>
      <xsl:choose>
        <xsl:when test="CUSTOMER/SHIPPING_ADDRESS/COUNTRY = ''"><faStat></faStat></xsl:when>
        <xsl:when test="CUSTOMER/SHIPPING_ADDRESS/COUNTRY = 'Česká republika'"><faStat>code:CZ</faStat></xsl:when>
        <xsl:when test="CUSTOMER/SHIPPING_ADDRESS/COUNTRY = 'Slovensko'"><faStat>code:SK</faStat></xsl:when>
        <!-- sem je potřeba doplňovat další státy -->
        <xsl:otherwise><faStat>NEDEFINOVANO - <xsl:value-of select="CUSTOMER/SHIPPING_ADDRESS/COUNTRY"/></faStat></xsl:otherwise>
      </xsl:choose>

      <polozkyDokladu removeAll="true">
        <xsl:apply-templates select ="ORDER_ITEMS/ITEM"/>
      </polozkyDokladu>
    </objednavka-prijata>
  </xsl:template>

  <xsl:template match="ORDER_ITEMS/ITEM">
    <!-- zpracování položky objednávky -->
    <objednavka-prijata-polozka>
      <xsl:choose>
        <xsl:when test="TYPE = 'product' or TYPE = 'set'">
          <!-- u produktů a sad vyplňujeme ceník i sklad -->
          <cenik>code:<xsl:value-of select="CODE"/></cenik>
          <sklad>code:<xsl:value-of select="$sklad"/></sklad>
        </xsl:when>
        <xsl:when test="TYPE = 'service'">
          <!-- u služeb vyplňujeme jen ceník -->
          <cenik>code:<xsl:value-of select="CODE"/></cenik>
        </xsl:when>
        <xsl:otherwise>
          <!-- ostatni typy - billing, shipping - neděláme nic -->
        </xsl:otherwise>
      </xsl:choose>

      <xsl:choose>
        <xsl:when test="VARIANT_NAME = ''">
          <nazev><xsl:value-of select="NAME"/></nazev>
        </xsl:when>
        <xsl:otherwise>
          <nazev><xsl:value-of select="NAME"/> - <xsl:value-of select="VARIANT_NAME"/></nazev>
        </xsl:otherwise>
      </xsl:choose>

      <mnozMj><xsl:value-of select="AMOUNT"/></mnozMj>
      <cenaMj><xsl:value-of select="java:flexibee.Tool.parseMoney(UNIT_PRICE/WITH_VAT)"/></cenaMj>
      <typCenyDphK>typCeny.sDph</typCenyDphK>
      <xsl:choose>
        <xsl:when test="UNIT_PRICE/VAT_RATE = 0"><typSzbDphK>typSzbDph.dphOsv</typSzbDphK></xsl:when>
        <xsl:when test="UNIT_PRICE/VAT_RATE = 10"><typSzbDphK>typSzbDph.dphSniz2</typSzbDphK></xsl:when>
        <xsl:when test="UNIT_PRICE/VAT_RATE = 15"><typSzbDphK>typSzbDph.dphSniz</typSzbDphK></xsl:when>
        <xsl:otherwise><typSzbDphK>typSzbDph.dphZakl</typSzbDphK></xsl:otherwise>
      </xsl:choose>

      <xsl:if test="UNIT != ''">
        <mj>code:<xsl:value-of select="java:flexibee.Tool.toUpper(UNIT)"/></mj>
      </xsl:if>

      <xsl:if test="DISCOUNT != 0">
        <slevaPol><xsl:value-of select="DISCOUNT"/></slevaPol>
      </xsl:if>
    </objednavka-prijata-polozka>
  </xsl:template>
</xsl:stylesheet>

