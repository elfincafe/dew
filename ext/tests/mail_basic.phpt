--TEST--
Dew\Mail Basic Test
--SKIPIF--
if (!extension_loaded("dew")) dir("Skip. This test is for Dew.");
--FILE--
<?php
try {
	new Dew\Mail("error#example.com", "Sender");
} catch (\Dew\Mail\Exception $e) {
	var_dump($e->getMessage());
} catch (\Throwable $e) {
	var_dump("Error");
} finally {
	$d = new Dew\Mail("test@example.com", "Sender");
	$p = (new \ReflectionClass($d))->getProperty("from");
	$p->setAccessible(true);
	var_dump($p->getValue($d));
}

--EXPECT--
string(31) ""error#example.com" is invalid."
array(2) {
  ["addr"]=>
  string(16) "test@example.com"
  ["name"]=>
  string(6) "Sender"
}
