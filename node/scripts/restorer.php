<?php

list($blank, $uuid, $blank) = split("/", $_SERVER["PATH_INFO"]);
shell_exec("/usr/bin/rhc-restorer-wrapper.sh $uuid");

sleep(2);
header("Location: /");

?>
