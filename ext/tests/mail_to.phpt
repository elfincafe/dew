--TEST--
Dew\Mail:to() Test
--SKIPIF--
if (!extension_loaded("dew")) dir("Skip. This test is for Dew.");
--FILE--
<?php
$d = new Dew\Mail("sender@example.com", "Sender");

try {
	$d->to("error#example.com");
} catch (\Dew\Mail\Exception $e) {
	var_dump($e->getMessage());
} catch (\Throwable $e) {
	var_dump("Error");
} finally {
	$d->to("recipient+to1@example.com", "RecipientTo1");
	$d->to("recipient+to2@example.com", "受信者Ｔｏ2");
	$p = (new \ReflectionClass($d))->getProperty("to");
	$p->setAccessible(true);
	var_dump($p->getValue($d));
}

--EXPECT--
string(31) ""error#example.com" is invalid."
array(2) {
  ["recipient+to1@example.com"]=>
  array(2) {
    ["addr"]=>
    string(25) "recipient+to1@example.com"
    ["name"]=>
    string(12) "RecipientTo1"
  }
  ["recipient+to2@example.com"]=>
  array(2) {
    ["addr"]=>
    string(25) "recipient+to2@example.com"
    ["name"]=>
    string(16) "受信者Ｔｏ2"
  }
}
