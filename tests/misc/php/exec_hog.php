<?php

function create_shell_script($fname) {
    // Adding a couple loops to not hit recursive stack limit any time soon
    $fp = fopen($fname, "w");
    fwrite($fp, "#!/bin/sh\n");
    fwrite($fp, "who\n");
    fwrite($fp, "sleep 120\n");
    fwrite($fp, "who\n");
    fwrite($fp, "sleep 480\n");
    fwrite($fp, "who\n");
    fwrite($fp, "sleep 1200\n");
    fwrite($fp, "who\n");
    fclose($fp);
}
$filename = "./dome.sh";
create_shell_script($filename);
chmod($filename, 0755);
system("/bin/sh $filename");
exec($filename);
?>

