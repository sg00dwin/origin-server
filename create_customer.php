<?php

$customer_name = escapeshellarg(filter_var($_POST['username'], FILTER_SANITIZE_SPECIAL_CHARS, FILTER_FLAG_STRIP_LOW));
$email = escapeshellarg(filter_var($_POST['email'], FILTER_SANITIZE_EMAIL, FILTER_FLAG_STRIP_LOW));
$ssh_key = escapeshellarg(filter_var($_POST['ssh_key'], FILTER_SANITIZE_STRING));

exec("/usr/sbin/mc-rpc -I mserver.cloud.redhat.com libra create_customer customer='$customer_name' email='$email' ssh_key='$ssh_key' 2>&1", $out);
print_r($out);
?>
