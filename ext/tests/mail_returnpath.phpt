--TEST--
Dew\Mail::returnPath() Test
--SKIPIF--
if (!extension_loaded("dew")) dir("Skip. This test is for Dew.");
--FILE--
<?php
$d = new \Dew\Mail("test@example.com");
try {
	$d->returnPath("error#example.com");
} catch (\Dew\Mail\Exception $e) {
	var_dump($e->getMessage());
} catch (\Throwable $e) {
	var_dump("Error");
} finally {
	$d->returnPath("returnpath@example.com");
	$p = (new \ReflectionClass($d))->getProperty("headers");
	$p->setAccessible(true);
	var_dump($p->getValue($d)["Return-Path"]);
}

--EXPECT--
string(31) ""error#example.com" is invalid."
string(24) "<returnpath@example.com>"
