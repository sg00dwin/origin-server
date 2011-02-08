<?php

function create_large_file() {
    // Adding a couple loops to not hit recursive stack limit any time soon
    $filename = "./io_large_file.txt";
    for ($i = 0; $i <= PHP_INT_MAX; $i++) {
        for ($j = 0; $j <= PHP_INT_MAX; $j++) {
            $fp = fopen($filename, "a");
            fwrite($fp, "just taking up some space");
            fclose($fp);
        }
    }
    create_large_file();
}
create_large_file();

?>

