#!/usr/bin/env php
<?php

// de http://php.net/manual/en/function.strtr.php#98669
function cleanForShortURL($toClean)
{

    $normalizeChars = array(
        'Š'=>'S', 'š'=>'s', 'Ð'=>'Dj','Ž'=>'Z', 'ž'=>'z', 'À'=>'A', 'Á'=>'A', 'Â'=>'A', 'Ã'=>'A', 'Ä'=>'A',
        'Å'=>'A', 'Æ'=>'A', 'Ç'=>'C', 'È'=>'E', 'É'=>'E', 'Ê'=>'E', 'Ë'=>'E', 'Ì'=>'I', 'Í'=>'I', 'Î'=>'I',
        'Ï'=>'I', 'Ñ'=>'N', 'Ò'=>'O', 'Ó'=>'O', 'Ô'=>'O', 'Õ'=>'O', 'Ö'=>'O', 'Ø'=>'O', 'Ù'=>'U', 'Ú'=>'U',
        'Û'=>'U', 'Ü'=>'U', 'Ý'=>'Y', 'Þ'=>'B', 'ß'=>'Ss','à'=>'a', 'á'=>'a', 'â'=>'a', 'ã'=>'a', 'ä'=>'a',
        'å'=>'a', 'æ'=>'a', 'ç'=>'c', 'è'=>'e', 'é'=>'e', 'ê'=>'e', 'ë'=>'e', 'ì'=>'i', 'í'=>'i', 'î'=>'i',
        'ï'=>'i', 'ð'=>'o', 'ñ'=>'n', 'ò'=>'o', 'ó'=>'o', 'ô'=>'o', 'õ'=>'o', 'ö'=>'o', 'ø'=>'o', 'ù'=>'u',
        'ú'=>'u', 'û'=>'u', 'ý'=>'y', 'ý'=>'y', 'þ'=>'b', 'ÿ'=>'y', 'ƒ'=>'f'
    );

    $toClean     =     str_replace('&', '-and-', $toClean);
    //$toClean     =     trim(preg_replace('/[^\w\d_ -]/si', '', $toClean)); //remove all illegal chars
    $toClean     =     str_replace(' ', '-', $toClean);
    $toClean     =     str_replace('--', '-', $toClean);

    return strtr($toClean, $normalizeChars);
}


function cat2file($category)
{
    $ex = explode(" ", $category);
    $file = strtolower(cleanForShortURL($ex[0]));

    return $file;
}

$manifestfile = ".repo/manifest.xml";
if (isset($argv[1]))
    $manifestfile = $argv[1];

$xml = simplexml_load_file($manifestfile);
$json = json_encode($xml);
$xmlarray = json_decode($json,TRUE);
$projects = $xmlarray['project'];

//print_r($projects);

$lastcat = "";
$list = "";
$localpath = "partituras/";

// inicializar categorias del libro
// para mantenerlas ordenadas tal y como aparecen en el manifiesto
$bookcontent = array();
foreach ($projects as $index => $project)
{
    if (array_key_exists('category', $project['@attributes']))
    {
        $currcat = $project['@attributes']['category'];

        if (!array_key_exists($currcat, $bookcontent))
            $bookcontent[$currcat] = array();
    }
}

foreach ($projects as $index => $project)
{
    if (array_key_exists('category', $project['@attributes']))
        $currcat = $project['@attributes']['category'];
    else
        continue;
    $currtitle = @$project['@attributes']['title'];
    $currpath = $project['@attributes']['path'];
    $currpath = str_replace($localpath, "", $currpath); //quitar pathlocal
    if (array_key_exists('score', $project['@attributes']))
        $currscore = $project['@attributes']['score'];
    else $currscore = $currpath;

    $bookcontent[$currcat][] = $currpath ."/". $currscore . ".ly";
    //echo "$currcat: $currtitle" . "\n";
    //print_r($project);
}

$newlist = array();
foreach ($bookcontent as $category => $files)
{
    $filcat = cat2file($category);
    $newlist[] = "r:utilerias/paginas/separador-$filcat.pdf:$category";

    foreach ($files as $file)
    {
        $newlist[] = $file;
    }
}

foreach ($newlist as $file)
{
    if (substr($file, 0, 2) == "r:")
        echo PHP_EOL;
    echo "    $file " . PHP_EOL;
}

?>
