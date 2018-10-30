<?php

function getVar($var) {
        return htmlspecialchars($_GET[$var]);
}

function simplexml_load_file_from_url($url, $timeout = 120){
  $opts = array('http' => array('timeout' => (int)$timeout));
  $context  = stream_context_create($opts);
  $data = file_get_contents($url, false, $context);
  if(!$data){
    trigger_error('Cannot load data from url: ' . $url, E_USER_NOTICE);
    return false;
  }
#  return simplexml_load_string($data);
   return $data;
}

$path = parse_url($_SERVER['REQUEST_URI'], PHP_URL_PATH);
$pathComponents = explode("/", trim($path, "/"));
$collection = $pathComponents[1];

if ($collection == "SENTINEL-2") {

  $query = 'https://finder.eocloud.eu/resto/api/collections/Sentinel2/search.atom?maxRecords=50&processingLevel=LEVELL1C&count=*&startDate='.getVar('start').'&completionDate='.getVar('stop').'&box='.getVar('bbox');

}elseif ($collection == "LANDSAT-8") {

  $query = 'https://finder.eocloud.eu/resto/api/collections/Landsat8/search.atom?maxRecords=50&count=*&startDate='.getVar('start').'&completionDate='.getVar('stop').'&box='.getVar('bbox');

}else{
 
  header("HTTP/1.0 404 Not Found");
  die("Template not found");

}

$page = getVar('page');
if (!empty($page)) {
  $query = $query . '&page=' . $page ;
}

$xml = simplexml_load_file_from_url($query, 300);

$xmlstr = simplexml_load_string($xml);

foreach($xmlstr->link as $link){
    switch ($link['rel']) {
       case "self":
          $request = "http://$_SERVER[HTTP_HOST]$_SERVER[REQUEST_URI]";
          $link->attributes()->href = $request;
          break;
       case "search":
          $request = "http://$_SERVER[HTTP_HOST]$path/description";
          $link->attributes()->href = $request;
          break;
       case "next":
       case "last":
       case "previous":
       case "first":
#          $hrefurl = urldecode($xmlstr->link['href']);
          $hrefurl = urldecode($link['href']);
          $hrefurlquery = parse_url($hrefurl, PHP_URL_QUERY);
          parse_str($hrefurlquery, $params);
          $newpage = $params['page'];

          $myquery = $_GET;
          // replace parameter(s)
          $myquery['page'] = $newpage;
          // rebuild url
          $query_result = http_build_query($myquery);

          $query_result = urldecode($query_result);

          $request = "http://$_SERVER[HTTP_HOST]$path?$query_result";
          $request = str_replace('&?','&',$request);
          $request = str_replace('?&','?',$request);

          $link->attributes()->href = $request;


          break;
    }

} 

$index = $xmlstr->children('os', TRUE)->startIndex;
$newindex = $index[0] - 1;
$xmlstr->startIndex = $newindex;

$xml = $xmlstr->asXML();


$xmldom = DomDocument::loadXML($xml);


$xsl_file='query2rdf.xsl';

if (!file_exists($xsl_file)) {
   //Produce a template error (internal error)
   header("HTTP/1.0 404 Not Found");
   die("Template not found");
}



  //Let's perform the traslation
  $xsl = new XSLTProcessor();
  $xsl_doc = new DOMDocument();
  $xsl_doc->load($xsl_file);
  $xsl->importStylesheet($xsl_doc);

  //Output to the browser
  echo $xsl->transformToXML($xmldom);


#echo $xml

?>

