--TEST--
Dew\Mail::bcc() Test
--SKIPIF--
if (!extension_loaded("dew")) dir("Skip. This test is for Dew.");
--FILE--
<?php
$d = new Dew\Mail("sender@example.com", "Sender");

try {
	$d->bcc("error#example.com");
} catch (\Dew\Mail\Exception $e) {
	var_dump($e->getMessage());
} catch (\Throwable $e) {
	var_dump("Error");
} finally {
	$d->bcc("recipient+bcc1@example.com", "RecipientBcc1");
	$d->bcc("recipient+bcc2@example.com", "受信者Ｂｃｃ2");
	$p = (new \ReflectionClass($d))->getProperty("bcc");
	$p->setAccessible(true);
	var_dump($p->getValue($d));
}

--EXPECT--
string(31) ""error#example.com" is invalid."
array(2) {
  ["recipient+bcc1@example.com"]=>
  array(2) {
    ["addr"]=>
    string(26) "recipient+bcc1@example.com"
    ["name"]=>
    string(0) ""
  }
  ["recipient+bcc2@example.com"]=>
  array(2) {
    ["addr"]=>
    string(26) "recipient+bcc2@example.com"
    ["name"]=>
    string(0) ""
  }
}
