<?php

$data = json_decode($_POST['json_data']);
$cartridge = escapeshellarg(filter_var($data->{'cartridge'}, FILTER_SANITIZE_SPECIAL_CHARS, FILTER_FLAG_STRIP_LOW));
$action = escapeshellarg(filter_var($data->{'action'}, FILTER_SANITIZE_EMAIL, FILTER_FLAG_STRIP_LOW));
$app_name = escapeshellarg(filter_var($data->{'app_name'}, FILTER_SANITIZE_STRING));
$username = escapeshellarg(filter_var($data->{'username'}, FILTER_SANITIZE_STRING));

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

print_r("/usr/bin/mc-libra --framework $cartridge -a $action -u $username -n $app_name");
$results = my_exec("/usr/bin/mc-libra --framework $cartridge -a $action -u $username -n $app_name", $out);

if($results['return'] != 0) {
    header('HTTP/1.1 500 Internal Server Error', 500);
}
print_r("\nstdout: " . $results['stdout']);
print_r("\nstderr: " . $results['stderr']);
print_r("\nreturn: " . $results['return']);
?>
