<?php

list($blank, $uuid, $blank) = split("/", $_SERVER["PATH_INFO"]);
#echo "/usr/bin/sudo /usr/bin/rhc-restorer -u $uuid";
shell_exec("/usr/bin/sudo /usr/bin/runcon -l s0-s0:c0.c1023 /usr/bin/rhc-restorer -u $uuid");

#echo shell_exec("/usr/bin/sudo /usr/bin/id");
sleep(2);
header("Location: /");

?>
