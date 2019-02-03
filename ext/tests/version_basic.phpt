--TEST--
Dew\Version Basic Test
--SKIPIF--
if (!extension_loaded("dew")) dir("Skip. This test is for Dew.");
--FILE--
<?php
ob_start();
phpinfo(INFO_MODULES);
$content = ob_get_contents();
ob_end_clean();

$major = $minor = $revision = 0; $extra = "";
$lines = explode("\n", $content);
$pattern = "Version\\s?=>\\s?(\d+)\.(\d+)\.(\d+)(\w+)?";
$flg = false;
foreach ($lines as $line) {
	if (!$flg && $line!="Dew => enabled") { continue; }
	$flg = true;
	if (preg_match("#{$pattern}#", $line, $m)) {
		$major = (int)$m[1];
		$minor = (int)$m[2];
		$revision = (int)$m[3];
		$extra = isset($m[4]) ? $m[4] : "";
	}
	if ($line=="") { break; }
}

$v = new \Dew\Version();
printf("Major Property => %s\n", $v->major===$major ? "OK" : "NG"); 
printf("Major Constant => %s\n", \Dew\Version::MAJOR===$major ? "OK" : "NG"); 
printf("Minor Property => %s\n", $v->minor===$minor ? "OK" : "NG"); 
printf("Minor Constant => %s\n", \Dew\Version::MINOR===$minor ? "OK" : "NG"); 
printf("Revision Property => %s\n", $v->revision===$revision ? "OK" : "NG"); 
printf("Revision Constant => %s\n", \Dew\Version::REVISION===$revision ? "OK" : "NG"); 
printf("Extra Property => %s\n", $v->extra===$extra ? "OK" : "NG"); 
printf("Extra Constant => %s\n", \Dew\Version::EXTRA===$extra ? "OK" : "NG"); 
$id = $major*10000 + $minor*100 + $revision;
printf("ID => %s\n", $v->id===$id ? "OK" : "NG"); 
$text = sprintf("%d.%d.%d%s", $major, $minor, $revision, $extra);
printf("Text => %s\n", $v->text===$text ? "OK" : "NG");


--EXPECT--
Major Property => OK
Major Constant => OK
Minor Property => OK
Minor Constant => OK
Revision Property => OK
Revision Constant => OK
Extra Property => OK
Extra Constant => OK
ID => OK
Text => OK
