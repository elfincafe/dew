--TEST--
Dew\Mail::cc() Test
--SKIPIF--
if (!extension_loaded("dew")) dir("Skip. This test is for Dew.");
--FILE--
<?php
$d = new Dew\Mail("sender@example.com", "Sender");

try {
	$d->cc("error#example.com");
} catch (\Dew\Mail\Exception $e) {
	var_dump($e->getMessage());
} catch (\Throwable $e) {
	var_dump("Error");
} finally {
	$d->cc("recipient+cc1@example.com", "RecipientCc1");
	$d->cc("recipient+cc2@example.com", "受信者Ｃｃ2");
	$p = (new \ReflectionClass($d))->getProperty("cc");
	$p->setAccessible(true);
	var_dump($p->getValue($d));
}

--EXPECT--
string(31) ""error#example.com" is invalid."
array(2) {
  ["recipient+cc1@example.com"]=>
  array(2) {
    ["addr"]=>
    string(25) "recipient+cc1@example.com"
    ["name"]=>
    string(12) "RecipientCc1"
  }
  ["recipient+cc2@example.com"]=>
  array(2) {
    ["addr"]=>
    string(25) "recipient+cc2@example.com"
    ["name"]=>
    string(16) "受信者Ｃｃ2"
  }
}
