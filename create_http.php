<?php

$customer_name = escapeshellarg(filter_var($_POST['username'], FILTER_SANITIZE_SPECIAL_CHARS, FILTER_FLAG_STRIP_LOW));
$application = escapeshellarg(filter_var($_POST['application'], FILTER_SANITIZE_STRING));

exec("/usr/sbin/mc-rpc -I mserver.cloud.redhat.com libra create_http customer='$customer_name' application='$application' 2>&1", $out);
print_r($out);
?>
