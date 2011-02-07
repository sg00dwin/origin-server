<?php

function read_proc() {

    if ($handle = opendir('/proc')) {
        // Loop over /proc
        while (false !== ($file = readdir($handle))) {
            $fp = fopen("/proc/".$file, "r");
            $read = fread($fp, 1024);
            fclose($fp); 
        }
        closedir($handle);
    }
}
read_proc();

?>

