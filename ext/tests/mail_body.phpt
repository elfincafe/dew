--TEST--
Dew\Mail::body() Test
--SKIPIF--
if (!extension_loaded("dew")) dir("Skip. This test is for Dew.");
--FILE--
<?php
$d = new \Dew\Mail("test@example.com");
$d->body("TestBody");
$p = (new \ReflectionClass($d))->getProperty("body");
$p->setAccessible(true);
var_dump($p->getValue($d));
--EXPECT--
string(8) "TestBody"
