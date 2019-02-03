--TEST--
Dew\Mail\Smtp::rcpt Test
--SKIPIF--
if (!extension_loaded("dew")) dir("Skip. This test is for Dew.");
--FILE--
<?php
$s = new Dew\Mail\Smtp("sender@example.com", "Sender");
$r = new \ReflectionClass($s);

$m = $r->getMethod("mail");
$m->setAccessible(true);
$m->invoke($s, "sender@example.com");

$m = $r->getMethod("rcpt");
$m->setAccessible(true);
var_dump($m->invoke($s, "rcpt@example.com"));

--EXPECTF--
bool(true)

