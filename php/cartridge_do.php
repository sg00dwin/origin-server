<?php

$cartridge = escapeshellarg(filter_var($_POST['cartridge'], FILTER_SANITIZE_SPECIAL_CHARS, FILTER_FLAG_STRIP_LOW));
$action = escapeshellarg(filter_var($_POST['action'], FILTER_SANITIZE_EMAIL, FILTER_FLAG_STRIP_LOW));
$args = escapeshellarg(filter_var($_POST['args'], FILTER_SANITIZE_STRING));

function my_exec($cmd, $input='')
         {$proc=proc_open($cmd, array(0=>array('pipe', 'r'), 1=>array('pipe', 'w'), 2=>array('pipe', 'w')), $pipes);
          fwrite($pipes[0], $input);fclose($pipes[0]);
          $stdout=stream_get_contents($pipes[1]);fclose($pipes[1]);
          $stderr=stream_get_contents($pipes[2]);fclose($pipes[2]);
          $rtn=proc_close($proc);
          return array('stdout'=>$stdout,
                       'stderr'=>$stderr,
                       'return'=>$rtn
                      );
         }

$results = my_exec("/usr/sbin/mc-rpc --np -I 'ip-10-101-6-42' libra create_customer cartridge='$cartridge' action='$action' args='$args'", $out);
print_r("\nstdout: " . $results['stdout']);
print_r("\nstderr: " . $results['stderr']);
print_r("\nreturn: " . $results['return']);
?>
