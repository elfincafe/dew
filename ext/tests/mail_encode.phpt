--TEST--
Dew\Mail::encode Test
--SKIPIF--
if (!extension_loaded("dew")) dir("Skip. This test is for Dew.");
--FILE--
<?php
$d = new \Dew\Mail("test@example.com");
$r = new \ReflectionClass($d);
$m = $r->getMethod("encode");
$m->setAccessible(true);
var_dump($m->invoke($d, "test"));
var_dump($m->invoke($d, "テスト"));
--EXPECT--
string(4) "test"
string(24) "=?UTF-8?B?44OG44K544OI?="
