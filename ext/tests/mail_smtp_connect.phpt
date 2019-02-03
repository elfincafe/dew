--TEST--
Dew\Mail\Smtp::connect Test
--SKIPIF--
if (!extension_loaded("dew")) dir("Skip. This test is for Dew.");
--FILE--
<?php
$s = new Dew\Mail\Smtp("sender@example.com", "Sender");
$r = new \ReflectionClass($s);

$m = $r->getMethod("connect");
$m->setAccessible(true);
$m->invoke($s);

$p = $r->getProperty("sock");
$p->setAccessible(true);
var_dump($p->getValue($s));

$p = $r->getProperty("svr_name");
$p->setAccessible(true);
var_dump($p->getValue($s)!=="");

--EXPECTF--
resource(5) of type (stream)
bool(true)
