<?php
@ob_start();
$data = json_decode($_POST['json_data']);
$cartridge = escapeshellarg(filter_var($data->{'cartridge'}, FILTER_SANITIZE_SPECIAL_CHARS, FILTER_FLAG_STRIP_LOW));
$action = escapeshellarg(filter_var($data->{'action'}, FILTER_SANITIZE_STRING, FILTER_FLAG_STRIP_LOW));
$app_label = escapeshellarg(filter_var($data->{'app_label'}, FILTER_SANITIZE_STRING));
$namespace = escapeshellarg(filter_var($data->{'namespace'}, FILTER_SANITIZE_STRING));

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

// print_r("/usr/bin/mc-rhc-cartridge-do --cartridge $cartridge -a $action -n $namespace -l $app_label");
$out = '';
$results = my_exec("/usr/bin/mc-rhc-cartridge-do --cartridge $cartridge -a $action -n $namespace -l $app_label -v", $out);

if ($results['return'] != 0) {
    header('HTTP/1.1 500 Service Error', 500);
    header('Status: 500 Service Error');
}

print json_encode($results);

// print_r("\nstdout: " . $results['stdout']);
// print_r("\nstderr: " . $results['stderr']);
// print_r("\nreturn: " . $results['return']);

ob_end_flush();
?>
