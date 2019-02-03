--TEST--
Dew\Mail\Smtp::ehlo Test
--SKIPIF--
if (!extension_loaded("dew")) dir("Skip. This test is for Dew.");
--FILE--
<?php
$s = new Dew\Mail\Smtp("sender@example.com", "Sender");
$r = new \ReflectionClass($s);

$m = $r->getMethod("ehlo");
$m->setAccessible(true);
var_dump($m->invoke($s));

$p = $r->getProperty("svr_info");
$p->setAccessible(true);
$srv_info = $p->getValue($s);
var_dump(count($srv_info)>0);

--EXPECTF--
bool(true)
bool(true)

