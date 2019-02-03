--TEST--
Dew\Mail::replyTo() Test
--SKIPIF--
if (!extension_loaded("dew")) dir("Skip. This test is for Dew.");
--FILE--
<?php
$d = new \Dew\Mail("test@example.com");
$r = new \ReflectionClass($d);
try {
	$d->replyTo("error#example.com");
} catch (\Dew\Mail\Exception $e) {
	var_dump($e->getMessage());
} catch (\Throwable $e) {
	var_dump("Error");
} finally {
	$d->replyTo("replyto@example.com");
	$p = $r->getProperty("headers");
	$p->setAccessible(true);
	var_dump($p->getValue($d)["Reply-To"]);
}

--EXPECT--
string(31) ""error#example.com" is invalid."
string(21) "<replyto@example.com>"
