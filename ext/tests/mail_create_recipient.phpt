--TEST--
Dew\Mail:createRecipient() Test
--SKIPIF--
if (!extension_loaded("dew")) dir("Skip. This test is for Dew.");
--FILE--
<?php
$d = new Dew\Mail("test@example.com", "テスト送信者");
$o = [
	["addr"=>"test+to1@example.com", "name"=>"Test Recipient"],
	["addr"=>"test+to2@example.com", "name"=>"テスト受信者"],
];
$m = (new \ReflectionClass($d))->getMethod("createRecipient");
$m->setAccessible(true);
var_dump($m->invoke($d, $o));

--EXPECT--
string(98) "Test Recipient <test+to1@example.com>, =?UTF-8?B?44OG44K544OI5Y+X5L+h6ICF?= <test+to2@example.com>"
