--TEST--
Dew\Mail\Smtp::rset Test
--SKIPIF--
if (!extension_loaded("dew")) dir("Skip. This test is for Dew.");
--FILE--
<?php
$s = new Dew\Mail\Smtp("sender@example.com", "Sender");
$r = new \ReflectionClass($s);

$m = $r->getMethod("rset");
$m->setAccessible(true);
var_dump($m->invoke($s));


--EXPECTF--
bool(true)

