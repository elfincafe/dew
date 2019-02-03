--TEST--
Dew\Mail::__set() & __get() Test
--SKIPIF--
if (!extension_loaded("dew")) dir("Skip. This test is for Dew.");
--FILE--
<?php
$d = new \Dew\Mail("test@example.com");
$d->test1 = "Test1";
$d->test2 = "Test2\r\nTest2";
var_dump($d->test1);
var_dump($d->test2);
$p = (new \ReflectionClass($d))->getProperty("vars");
$p->setAccessible(true);
var_dump($p->getValue($d));

--EXPECT--
string(5) "Test1"
string(10) "Test2Test2"
array(2) {
  ["test1"]=>
  string(5) "Test1"
  ["test2"]=>
  string(10) "Test2Test2"
}
