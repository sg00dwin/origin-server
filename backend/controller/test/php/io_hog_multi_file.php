<?php

function io_infinite_loop() {
    // Adding a couple loops to not hit recursive stack limit any time soon
    for ($i = 0; $i <= PHP_INT_MAX; $i++) {
        for ($j = 0; $j <= PHP_INT_MAX; $j++) {
            $filename = "./io_infinite_loop_file_".$i."_".$j.".txt";
            $fp = fopen($filename, "w+");
            fwrite($fp, "just taking up some space");
            fclose($fp);
        }
    }
    io_infinite_loop();
}
io_infinite_loop();

?>

