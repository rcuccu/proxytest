<?xml version="1.0" encoding="utf-8"?>
<xsl:stylesheet 
    version="1.0" 
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform" 
    xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#" 
    xmlns:ws="http://dclite4g.xmlns.com/ws.rdf#"
    xmlns:dclite4g="http://xmlns.com/2008/dclite4g#"
    xmlns:dct="http://purl.org/dc/terms/" 
    xmlns:ical="http://www.w3.org/2002/12/cal/ical#"
    xml:lang="en" 
    xmlns:atom="http://www.w3.org/2005/Atom" 
    xmlns:time="http://a9.com/-/opensearch/extensions/time/1.0/" 
    xmlns:os="http://a9.com/-/spec/opensearch/1.1/" 
    xmlns:dc="http://purl.org/dc/elements/1.1/" 
    xmlns:georss="http://www.georss.org/georss" 
    xmlns:gml="http://www.opengis.net/gml" 
    xmlns:geo="http://a9.com/-/opensearch/extensions/geo/1.0/" 
    xmlns:eo="http://a9.com/-/opensearch/extensions/eo/1.0/" 
    xmlns:eop="http://www.genesi-dr.eu/spec/opensearch/extensions/eop/1.0/"
    xmlns:metalink="urn:ietf:params:xml:ns:metalink" 
    xmlns:xlink="http://www.w3.org/1999/xlink" 
    xmlns:media="http://search.yahoo.com/mrss/" 
    xmlns:resto="resto">

<xsl:output media-type="application/rdf+xml" encoding="utf-8" method="xml" indent="no"/>

<xsl:template match="/">
   <xsl:apply-templates select="atom:feed"/> 
</xsl:template>

<xsl:template match="atom:link">
     <atom:link>
        <xsl:if test="@rel"><xsl:attribute name="atom:rel"><xsl:value-of select="@rel"/></xsl:attribute></xsl:if>
        <xsl:if test="@type"><xsl:attribute name="atom:type">application/rdf+xml</xsl:attribute></xsl:if>
        <xsl:if test="@href"><xsl:attribute name="atom:href"><xsl:value-of select="@href"/></xsl:attribute></xsl:if>
        <xsl:if test="@title"><xsl:attribute name="atom:title"><xsl:value-of select="@title"/></xsl:attribute></xsl:if>
        <xsl:if test="@hreflang"><xsl:attribute name="atom:hreflang"><xsl:value-of select="@hreflang"/></xsl:attribute></xsl:if>
        <xsl:if test="@length"><xsl:attribute name="atom:length"><xsl:value-of select="@length"/></xsl:attribute></xsl:if>
     </atom:link>
</xsl:template>

<xsl:template name="split">
        <xsl:param name="str" />
        <xsl:choose>
            <xsl:when test="contains($str,' ')">
                <xsl:variable name="first">
                    <xsl:value-of select="substring-before($str,' ')" />
                </xsl:variable>
                <xsl:variable name="second">
                    <xsl:value-of select="substring-before(substring-after(concat($str,' '),' '),' ')" />
                </xsl:variable>
                    <xsl:value-of select="concat($second,' ',$first)" />

                <xsl:if test="substring-after(substring-after($str,' '),' ')">
                 <xsl:text>, </xsl:text>
                    <xsl:call-template name="split">
                        <xsl:with-param name="str">
                            <xsl:value-of select="substring-after(substring-after($str,' '),' ')"/>
                        </xsl:with-param>
                    </xsl:call-template>
                </xsl:if>
            </xsl:when>
        </xsl:choose>
</xsl:template>


<xsl:template match="atom:entry">
   <dclite4g:DataSet><xsl:attribute name="rdf:about"><xsl:value-of select="atom:link[@rel='enclosure']/@href"/></xsl:attribute>
      <dc:identifier><xsl:value-of select="atom:title"/></dc:identifier>
      <dclite4g:onlineResource> 
        <ws:CACHE>
          <xsl:attribute name="rdf:about"><xsl:value-of select="atom:link[@rel='enclosure']/@href"/></xsl:attribute>
          <xsl:attribute name="ws:preference">20</xsl:attribute>
        </ws:CACHE>
      </dclite4g:onlineResource>
      <dct:spatial>MULTIPOLYGON(((<xsl:call-template name="split"><xsl:with-param name="str" select="georss:polygon" /></xsl:call-template>)))</dct:spatial> 
      <ical:dtstart><xsl:value-of select="gml:validTime/gml:TimePeriod/gml:beginPosition"/></ical:dtstart>
      <ical:dtend><xsl:value-of select="gml:validTime/gml:TimePeriod/gml:endPosition"/></ical:dtend>

      <eop:size>0</eop:size>
      <dct:modified>2018-10-26T00:00:00.001Z</dct:modified>
      <dct:created>2018-10-26T00:00:00.001Z</dct:created>

   </dclite4g:DataSet>
</xsl:template>


<xsl:template match="atom:feed">
<rdf:RDF>
   <rdf:Description><xsl:attribute name="rdf:about"><xsl:value-of select="atom:link[@rel='self']/@href"/></xsl:attribute>

    <xsl:choose>
      <xsl:when test="os:Query">
       
       <os:totalResults><xsl:value-of select="os:totalResults"/></os:totalResults>  
       <os:startIndex><xsl:value-of select="os:startIndex"/></os:startIndex>
       <os:itemsPerPage><xsl:value-of select="os:itemsPerPage"/></os:itemsPerPage> 

       <xsl:apply-templates select="atom:link"/>   
       <os:Query os:role="request"/>

      </xsl:when>
      <xsl:otherwise>

       <os:totalResults><xsl:value-of select="os:totalResults"/></os:totalResults>

      </xsl:otherwise>
    </xsl:choose>

   </rdf:Description>

   <dclite4g:Series><xsl:attribute name="rdf:about"><xsl:value-of select="atom:link[@rel='self']/@href"/></xsl:attribute>
     <title>resto-proxy</title>
     <dc:identifier><xsl:value-of select="atom:id"/></dc:identifier>
 

   </dclite4g:Series>

   <xsl:apply-templates select="atom:entry"/>

</rdf:RDF>
</xsl:template>
</xsl:stylesheet>
