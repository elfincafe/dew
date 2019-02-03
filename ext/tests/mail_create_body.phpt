--TEST--
Dew\Mail:createbody() Test
--SKIPIF--
if (!extension_loaded("dew")) dir("Skip. This test is for Dew.");
--FILE--
<?php
$d = new Dew\Mail("test@example.com", "テスト送信者");

$d->test1 = "Test1";
$d->body("TestBody");
$m = (new \ReflectionClass($d))->getMethod("createBody");
$m->setAccessible(true);
var_dump($m->invoke($d));

$d->body("{{test1}}
{{ test2}}
{{test3 }}
");
$d->test2 = "Test2";
$d->test3 = "Test3";

$m = (new \ReflectionClass($d))->getMethod("createBody");
$m->setAccessible(true);
var_dump($m->invoke($d));

--EXPECT--
string(8) "TestBody"
string(18) "Test1
Test2
Test3
"
