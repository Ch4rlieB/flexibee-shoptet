<?xml version="1.0" encoding="utf-8" ?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0"
xmlns:rsp="http://www.stormware.cz/schema/version_2/response.xsd" 
xmlns:rdc="http://www.stormware.cz/schema/version_2/documentresponse.xsd" 
xmlns:typ="http://www.stormware.cz/schema/version_2/type.xsd" 
xmlns:dat="http://www.stormware.cz/schema/version_2/data.xsd"
xmlns:lst="http://www.stormware.cz/schema/version_2/list.xsd" 
xmlns:lStk="http://www.stormware.cz/schema/version_2/list_stock.xsd" 
xmlns:lAdb="http://www.stormware.cz/schema/version_2/list_addBook.xsd" 
xmlns:acu="http://www.stormware.cz/schema/version_2/accountingunit.xsd" 
xmlns:inv="http://www.stormware.cz/schema/version_2/invoice.xsd"
xmlns:vch="http://www.stormware.cz/schema/version_2/voucher.xsd"
xmlns:int="http://www.stormware.cz/schema/version_2/intDoc.xsd"
xmlns:stk="http://www.stormware.cz/schema/version_2/stock.xsd"
xmlns:ord="http://www.stormware.cz/schema/version_2/order.xsd"
xmlns:ofr="http://www.stormware.cz/schema/version_2/offer.xsd"
xmlns:enq="http://www.stormware.cz/schema/version_2/enquiry.xsd"
xmlns:vyd="http://www.stormware.cz/schema/version_2/vydejka.xsd"
xmlns:pri="http://www.stormware.cz/schema/version_2/prijemka.xsd"
xmlns:bal="http://www.stormware.cz/schema/version_2/balance.xsd"
xmlns:pre="http://www.stormware.cz/schema/version_2/prevodka.xsd"
xmlns:vyr="http://www.stormware.cz/schema/version_2/vyroba.xsd"
xmlns:pro="http://www.stormware.cz/schema/version_2/prodejka.xsd"
xmlns:con="http://www.stormware.cz/schema/version_2/contract.xsd"
xmlns:adb="http://www.stormware.cz/schema/version_2/addressbook.xsd"
xmlns:prm="http://www.stormware.cz/schema/version_2/parameter.xsd"
xmlns:lCon="http://www.stormware.cz/schema/version_2/list_contract.xsd"
xmlns:ctg="http://www.stormware.cz/schema/version_2/category.xsd"
xmlns:ipm="http://www.stormware.cz/schema/version_2/intParam.xsd"
xmlns:str="http://www.stormware.cz/schema/version_2/storage.xsd"
xmlns:java="http://xml.apache.org/xalan/java"
exclude-result-prefixes="java">
    
  <xsl:output method="xml" encoding="utf-8" />

  <!-- zkratka skladu na kterém je zboží určené pro eshop -->
  <xsl:variable name="sklad" select="'SKLAD'" />

  <!-- zkratka typu dokladu použitého na naimportované faktuře -->
  <xsl:variable name="typDoklFaktura" select="'FAKTURA'" />

  <!-- zkratka typu dokladu použitého na naimportovaném dobropisu -->
  <xsl:variable name="typDoklDobropis" select="'DOBROPIS'" />

  <!-- pokud není stát vyplněn, tak použijeme tento -->
  <xsl:variable name="defaultStat" select="'code:CZ'" />

  <!-- pokud se mají vytvářet také ceníky tak true(), pokud ne tak false() -->
  <xsl:variable name="vytvaretCeniky" select="true()" />

  <!-- zda se maji ceniky vubec resit -->
  <xsl:variable name="resitCenik" select="true()" />


  <xsl:template match="/">
    <winstrom version="1.0" source="pohoda" atomic="false">
      <xsl:apply-templates/>
    </winstrom>	
  </xsl:template>

  <xsl:template match="dat:dataPackItem">
    <xsl:apply-templates select="inv:invoice"/>
  </xsl:template>
	
  <xsl:template match="lst:listInvoice">
    <xsl:apply-templates select="lst:invoice"/>
  </xsl:template>
  
  <xsl:template match="lst:invoice|inv:invoice">
    <xsl:if test="$vytvaretCeniky = true() and $resitCenik = true()">
      <xsl:call-template name="cenik"/>
    </xsl:if>
    <xsl:call-template name="faktura-vydana"/>
  </xsl:template>

  <xsl:template name="cenik">
    <xsl:for-each select="inv:invoiceDetail/inv:invoiceItem">
      <xsl:if test="inv:stockItem/typ:stockItem/typ:ids and inv:stockItem/typ:stockItem/typ:ids != ''">
        <cenik update="ignore">
          <id>code:<xsl:value-of select="inv:code"/></id>
          <kod><xsl:value-of select="inv:code"/></kod>
          <nazev><xsl:value-of select="inv:text"/></nazev>
          <!-- skladové karty -->
          <skladove>true</skladove>
        </cenik>
        <skladova-karta update="ignore">
          <cenik>code:<xsl:value-of select="inv:code"/></cenik>
          <sklad>code:<xsl:value-of select="$sklad"/></sklad>
          <ucetObdobi>code:<xsl:value-of select="java:flexibee.Tool.substring(../../inv:invoiceHeader/inv:date, 0, 4)"/></ucetObdobi>
        </skladova-karta>
      </xsl:if>
    </xsl:for-each>
  </xsl:template>

  <xsl:template name="faktura-vydana">
    <faktura-vydana>
      <xsl:if test="java:flexibee.Tool.trim(inv:invoiceHeader/inv:number/typ:numberRequested) != ''">
        <id>code:<xsl:value-of select="inv:invoiceHeader/inv:number/typ:numberRequested"/></id>
        <kod><xsl:value-of select="inv:invoiceHeader/inv:number/typ:numberRequested"/></kod>
      </xsl:if>
      <varSym><xsl:value-of select="inv:invoiceHeader/inv:symVar"/></varSym>
      <cisObj><xsl:value-of select="inv:invoiceHeader/inv:numberOrder"/></cisObj>
      <xsl:choose>
        <xsl:when test="inv:invoiceHeader/inv:invoiceType = 'issuedCorrectiveTax'">
          <typDokl>code:<xsl:value-of select="$typDoklDobropis"/></typDokl>
        </xsl:when>
        <xsl:otherwise>
          <typDokl>code:<xsl:value-of select="$typDoklFaktura"/></typDokl>
        </xsl:otherwise>
      </xsl:choose>

      <datVyst><xsl:value-of select="inv:invoiceHeader/inv:date"/></datVyst>
      <xsl:choose>
        <xsl:when test="not(inv:invoiceHeader/inv:dateTax)">
          <duzpPuv><xsl:value-of select="inv:invoiceHeader/inv:date"/></duzpPuv>
          <duzpUcto><xsl:value-of select="inv:invoiceHeader/inv:date"/></duzpUcto>
        </xsl:when>
        <xsl:otherwise>
          <duzpPuv><xsl:value-of select="inv:invoiceHeader/inv:dateTax"/></duzpPuv>
          <duzpUcto><xsl:value-of select="inv:invoiceHeader/inv:dateTax"/></duzpUcto>
        </xsl:otherwise>
      </xsl:choose>
      <datSplat><xsl:value-of select="inv:invoiceHeader/inv:dateDue"/></datSplat>

      <xsl:if test="inv:invoiceSummary/inv:foreignCurrency/typ:currency/typ:ids">
        <mena>code:<xsl:value-of select="inv:invoiceSummary/inv:foreignCurrency/typ:currency/typ:ids"/></mena>
      </xsl:if>

      <formaUhradyCis if-not-found="null">code:<xsl:value-of select="java:flexibee.Tool.toUpper(inv:invoiceHeader/inv:paymentType/typ:paymentType)"/></formaUhradyCis>
      <formaDopravy if-not-found="null">code:<xsl:value-of select="java:flexibee.Tool.toUpper(inv:invoiceHeader/inv:carrier/typ:ids)"/></formaDopravy>

      <!-- odberatel -->
      <xsl:choose>
        <xsl:when test="inv:invoiceHeader/inv:partnerIdentity/typ:address/typ:company != '' and inv:invoiceHeader/inv:partnerIdentity/typ:address/typ:name != ''">
          <nazFirmy><xsl:value-of select="inv:invoiceHeader/inv:partnerIdentity/typ:address/typ:company"/> - <xsl:value-of select="inv:invoiceHeader/inv:partnerIdentity/typ:address/typ:name"/></nazFirmy>
        </xsl:when>
        <xsl:when test="inv:invoiceHeader/inv:partnerIdentity/typ:address/typ:company != ''">
          <nazFirmy><xsl:value-of select="inv:invoiceHeader/inv:partnerIdentity/typ:address/typ:company"/></nazFirmy>
        </xsl:when>
        <xsl:otherwise>
          <nazFirmy><xsl:value-of select="inv:invoiceHeader/inv:partnerIdentity/typ:address/typ:name"/></nazFirmy>
        </xsl:otherwise>
      </xsl:choose>
      <ulice><xsl:value-of select="inv:invoiceHeader/inv:partnerIdentity/typ:address/typ:street"/></ulice>
      <mesto><xsl:value-of select="inv:invoiceHeader/inv:partnerIdentity/typ:address/typ:city"/></mesto>
      <psc><xsl:value-of select="inv:invoiceHeader/inv:partnerIdentity/typ:address/typ:zip"/></psc>
      <xsl:choose>
        <xsl:when test="not(inv:invoiceHeader/inv:partnerIdentity/typ:address/typ:country/typ:ids)"><stat><xsl:value-of select="$defaultStat"/></stat></xsl:when>
        <xsl:when test="inv:invoiceHeader/inv:partnerIdentity/typ:address/typ:country/typ:ids = ''"><stat><xsl:value-of select="$defaultStat"/></stat></xsl:when>
        <xsl:when test="inv:invoiceHeader/inv:partnerIdentity/typ:address/typ:country/typ:ids = 'CZE'"><stat>code:CZ</stat></xsl:when>
        <xsl:when test="inv:invoiceHeader/inv:partnerIdentity/typ:address/typ:country/typ:ids = 'SVK'"><stat>code:SK</stat></xsl:when>
        <xsl:when test="inv:invoiceHeader/inv:partnerIdentity/typ:address/typ:country/typ:ids = 'DEU'"><stat>code:DE</stat></xsl:when>
        <xsl:when test="inv:invoiceHeader/inv:partnerIdentity/typ:address/typ:country/typ:ids = 'FRA'"><stat>code:FR</stat></xsl:when>
        <xsl:when test="inv:invoiceHeader/inv:partnerIdentity/typ:address/typ:country/typ:ids = 'POL'"><stat>code:PL</stat></xsl:when>
        <xsl:when test="inv:invoiceHeader/inv:partnerIdentity/typ:address/typ:country/typ:ids = 'ITA'"><stat>code:IT</stat></xsl:when>
        <xsl:when test="inv:invoiceHeader/inv:partnerIdentity/typ:address/typ:country/typ:ids = 'AUT'"><stat>code:AT</stat></xsl:when>
        <xsl:when test="inv:invoiceHeader/inv:partnerIdentity/typ:address/typ:country/typ:ids = 'GBR'"><stat>code:GB</stat></xsl:when>
        <xsl:when test="inv:invoiceHeader/inv:partnerIdentity/typ:address/typ:country/typ:ids = 'ZAF'"><stat>code:ZA</stat></xsl:when>
        <xsl:otherwise>
          <stat>code:<xsl:value-of select="inv:invoiceHeader/inv:partnerIdentity/typ:address/typ:country/typ:ids"/></stat>
        </xsl:otherwise>
      </xsl:choose>
      <ic><xsl:value-of select="inv:invoiceHeader/inv:partnerIdentity/typ:address/typ:ico"/></ic>
      <dic><xsl:value-of select="inv:invoiceHeader/inv:partnerIdentity/typ:address/typ:dic"/></dic>

      <!-- polozky faktury -->
      <xsl:if test="inv:invoiceDetail">
        <!-- polozkova faktura -->
        <bezPolozek>false</bezPolozek>
        <polozkyDokladu removeAll="true">
          <xsl:apply-templates select="inv:invoiceDetail/inv:invoiceItem">
            <xsl:with-param name="invoiceType"><xsl:value-of select="inv:invoiceHeader/inv:invoiceType"/></xsl:with-param> 
          </xsl:apply-templates>
        </polozkyDokladu>
      </xsl:if>
      <xsl:if test="not(inv:invoiceDetail)">
        <!-- bezpolozkova faktura -->
        <bezPolozek>true</bezPolozek>
        <sumOsv><xsl:value-of select="inv:invoiceSummary/inv:homeCurrency/typ:priceNone"/></sumOsv>
        <sumZklZakl><xsl:value-of select="inv:invoiceSummary/inv:homeCurrency/typ:priceHigh"/></sumZklZakl>
        <sumDphZakl><xsl:value-of select="inv:invoiceSummary/inv:homeCurrency/typ:priceHighVAT"/></sumDphZakl>
        <sumZklSniz><xsl:value-of select="inv:invoiceSummary/inv:homeCurrency/typ:priceLow"/></sumZklSniz>
        <sumDphSniz><xsl:value-of select="inv:invoiceSummary/inv:homeCurrency/typ:priceLowVAT"/></sumDphSniz>
        <sumZklSniz2><xsl:value-of select="inv:invoiceSummary/inv:homeCurrency/typ:price3"/></sumZklSniz2>
        <sumDphSniz2><xsl:value-of select="inv:invoiceSummary/inv:homeCurrency/typ:price3VAT"/></sumDphSniz2>
      </xsl:if>

      <popis><xsl:value-of select="inv:invoiceHeader/inv:text"/></popis>

    </faktura-vydana>
  </xsl:template>

  <xsl:template match="inv:invoiceDetail/inv:invoiceItem">
    <xsl:param name="invoiceType" />
    <faktura-vydana-polozka>
      <nazev><xsl:value-of select="inv:text"/></nazev>
      <xsl:choose>
        <xsl:when test="inv:quantity = 0">
          <typPolozkyK>typPolozky.ucetni</typPolozkyK>
        </xsl:when>
        <xsl:otherwise>
          <xsl:if test="inv:stockItem/typ:stockItem/typ:ids and inv:stockItem/typ:stockItem/typ:ids != '' and $resitCenik = true()">
            <cenik>code:<xsl:value-of select="inv:stockItem/typ:stockItem/typ:ids"/></cenik>
            <sklad>code:<xsl:value-of select="$sklad"/></sklad>
          </xsl:if>
          <kod><xsl:value-of select="inv:code"/></kod>
          <xsl:choose>
            <xsl:when test="$invoiceType = 'issuedCorrectiveTax' and inv:quantity > 0">
              <!-- FlexiBee neumožňuje na dobropisu kladné množství tak otočíme jak množství tak částku - jedná se nejspíš hlavně o dopravu na dobropisu -->
              <mnozMj>-<xsl:value-of select="inv:quantity"/></mnozMj>
              <xsl:choose>
                <xsl:when test="inv:foreignCurrency/typ:unitPrice and inv:foreignCurrency/typ:unitPrice != 0.0">
                  <cenaMj>-<xsl:value-of select="inv:foreignCurrency/typ:unitPrice"/></cenaMj>
                </xsl:when>
                <xsl:otherwise>
                  <cenaMj>-<xsl:value-of select="inv:homeCurrency/typ:unitPrice"/></cenaMj>
                </xsl:otherwise>
              </xsl:choose>
            </xsl:when>
            <xsl:otherwise>
              <!-- Ve všech ostatních případech je vše tak jak je ve vstupním souboru -->
              <mnozMj><xsl:value-of select="inv:quantity"/></mnozMj>
              <xsl:choose>
                <xsl:when test="inv:foreignCurrency/typ:unitPrice and inv:foreignCurrency/typ:unitPrice != 0.0">
                  <cenaMj><xsl:value-of select="inv:foreignCurrency/typ:unitPrice"/></cenaMj>
                </xsl:when>
                <xsl:otherwise>
                  <cenaMj><xsl:value-of select="inv:homeCurrency/typ:unitPrice"/></cenaMj>
                </xsl:otherwise>
              </xsl:choose>
            </xsl:otherwise>
          </xsl:choose>
          <xsl:if test="inv:unit != ''">
            <mj if-not-found="create">code:<xsl:value-of select="java:flexibee.Tool.toUpper(inv:unit)"/></mj>
          </xsl:if>
        </xsl:otherwise>
      </xsl:choose>

      <xsl:choose>
        <xsl:when test="inv:rateVAT = 'high'"><typSzbDphK>typSzbDph.dphZakl</typSzbDphK></xsl:when>
        <xsl:when test="inv:rateVAT = 'third'"><typSzbDphK>typSzbDph.dphSniz2</typSzbDphK></xsl:when>
        <xsl:when test="inv:rateVAT = 'low'"><typSzbDphK>typSzbDph.dphSniz</typSzbDphK></xsl:when>
        <xsl:when test="inv:rateVAT = 'none'"><typSzbDphK>typSzbDph.dphOsv</typSzbDphK></xsl:when>
        <xsl:when test="inv:rateVAT = '' or not(inv:rateVAT)"><typSzbDphK>typSzbDph.dphOsv</typSzbDphK></xsl:when>
        <xsl:otherwise>
          <typSzbDphK>NEDEFINOVANO-<xsl:value-of select="inv:rateVAT"/></typSzbDphK>
        </xsl:otherwise>
      </xsl:choose>
      <xsl:choose>
        <xsl:when test="inv:payVAT = 'true'"><typCenyDphK>typCeny.sDph</typCenyDphK></xsl:when>
        <xsl:when test="inv:payVAT = 'false'"><typCenyDphK>typCeny.bezDph</typCenyDphK></xsl:when>
        <xsl:otherwise>
          <typCenyDphK>NEDEFINOVANO-<xsl:value-of select="inv:payVAT"/></typCenyDphK>
        </xsl:otherwise>
      </xsl:choose>
      <xsl:if test="inv:discountPercentage">
        <slevaPol><xsl:value-of select="inv:discountPercentage"/></slevaPol>
      </xsl:if>
    </faktura-vydana-polozka>
  </xsl:template>

  
</xsl:stylesheet>
