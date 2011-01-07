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

print_r("\n/usr/sbin/mc-rpc --np -I 'ip-10-101-6-42' libra cartridge_do cartridge=$cartridge action=$action args=$args");
$results = my_exec("/usr/sbin/mc-rpc -v --np -I 'ip-10-101-6-42' libra cartridge_do cartridge=$cartridge action=$action args=$args", $out);
if($results['return'] != 0) {
    header('HTTP/1.1 500 Internal Server Error', 500);
}
if(!strpos($results[stdout],'exitcode=>0')){
    $results['return'] = 1;
}
print_r("\nstdout: " . $results['stdout']);
print_r("\nstderr: " . $results['stderr']);
print_r("\nreturn: " . $results['return']);
?>
