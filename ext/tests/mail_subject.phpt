--TEST--
Dew\Mail::subject() Test
--SKIPIF--
if (!extension_loaded("dew")) dir("Skip. This test is for Dew.");
--FILE--
<?php
$d = new \Dew\Mail("test@example.com");
$d->subject("Test\r\nSub\rject\n");
$p = (new \ReflectionClass($d))->getProperty("subject");
$p->setAccessible(true);
var_dump($p->getValue($d));
--EXPECT--
string(11) "TestSubject"
