--TEST--
Dew\Mail\Smtp::parseOptions Test
--SKIPIF--
if (!extension_loaded("dew")) dir("Skip. This test is for Dew.");
--FILE--
<?php
$s = new Dew\Mail\Smtp("sender@example.com", "Sender");
$r = new \ReflectionClass($s);
$p = $r->getProperty("scheme");
$p->setAccessible(true);

$m = $r->getMethod("parseOptions");
$m->setAccessible(true);
$m->invoke($s, [
	"host" => "smtp://127.0.0.1:25",
]);
var_dump($p->getValue($s));
$m->invoke($s, [
	"host" => "smtps://127.0.0.1:25",
]);
var_dump($p->getValue($s));
$m->invoke($s, [
	"host" => "tls://127.0.0.1:25",
]);
var_dump($p->getValue($s));


--EXPECTF--
string(4) "smtp"
string(4) "smtp"
string(4) "smtp"

