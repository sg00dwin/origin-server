<?php

function io_infinite_loop() {
    // Adding a couple loops to not hit recursive stack limit any time soon
    $filename = "./io_infinite_loop_file.txt";
    for ($i = 0; $i <= PHP_INT_MAX; $i++) {
        for ($j = 0; $j <= PHP_INT_MAX; $j++) {
            $fp = fopen($filename, "w+");
            fwrite($fp, "just taking up some space");
            fclose($fp);
            $fp = fopen($filename, "r");
            $read = fread($fp, 1024);
            fclose($fp);  
        }
    }
    io_infinite_loop();
}
io_infinite_loop();

?>

