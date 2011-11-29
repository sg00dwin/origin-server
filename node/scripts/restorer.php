<?php

list($blank, $uuid, $blank) = split("/", $_SERVER["PATH_INFO"]);
shell_exec("/usr/bin/oddjob_request -s com.redhat.oddjob_openshift -o /com/redhat/oddjob/openshift -i com.redhat.oddjob_restorer restore $uuid");

sleep(2);
header("Location: /");

?>
