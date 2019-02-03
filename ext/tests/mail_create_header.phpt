--TEST--
Dew\Mail:createHeader() Test
--SKIPIF--
if (!extension_loaded("dew")) dir("Skip. This test is for Dew.");
--FILE--
<?php
$d = new Dew\Mail("test@example.com", "テスト送信者");
$d->subject("テスト件名");
$d->replyTo("replyto@example.com");
$d->returnPath("returnpath@example.com");
$d->to("to@example.com", "受信者Ｔｏ");
$d->cc("cc@example.com", "受信者Ｃｃ");
$d->bcc("bcc@example.com", "受信者Ｂｃｃ");
$m = (new \ReflectionClass($d))->getMethod("createHeader");
$m->setAccessible(true);
var_dump($m->invoke($d));

--EXPECTF--
array(7) {
  ["MIME-Version"]=>
  string(3) "1.0"
  ["Return-Path"]=>
  string(24) "<returnpath@example.com>"
  ["Reply-To"]=>
  string(21) "<replyto@example.com>"
  ["Date"]=>
  string(31) "%s, %d %s %d %d:%d:%d +%d"
  ["From"]=>
  string(55) "=?UTF-8?B?44OG44K544OI6YCB5L+h6ICF?= <test@example.com>"
  ["Cc"]=>
  string(49) "=?UTF-8?B?5Y+X5L+h6ICF77yj772D?= <cc@example.com>"
  ["Bcc"]=>
  string(17) "<bcc@example.com>"
}
