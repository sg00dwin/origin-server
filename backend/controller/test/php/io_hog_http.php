<?php

function io_infinite_loop() {
    // Adding a couple loops to not hit recursive stack limit any time soon
    //TODO point this to a resource that won't get you in trouble for DoS
    $url = "http://localhost";
    for ($i = 0; $i <= PHP_INT_MAX; $i++) {
        for ($j = 0; $j <= PHP_INT_MAX; $j++) {
            $fp = fopen($url, "r");
            $read = fread($fp, 1024);
            fclose($fp);  
        }
    }
    io_infinite_loop();
}
io_infinite_loop();

?>

