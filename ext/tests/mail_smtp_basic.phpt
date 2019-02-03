--TEST--
Dew\Mail\Smtp Basic Test
--SKIPIF--
if (!extension_loaded("dew")) dir("Skip. This test is for Dew.");
--FILE--
<?php
$s = new Dew\Mail\Smtp("sender@example.com", "Sender");
$r = new \ReflectionClass($s);

$keys = ["from", "scheme", "host", "port", "timeout"];
foreach ($keys as $k) {
  $p = $r->getProperty($k);
  $p->setAccessible(true);
  var_dump($p->getValue($s));
}
--EXPECTF--
array(2) {
  ["addr"]=>
  string(18) "sender@example.com"
  ["name"]=>
  string(6) "Sender"
}
string(4) "smtp"
string(9) "127.0.0.1"
int(25)
int(30)
