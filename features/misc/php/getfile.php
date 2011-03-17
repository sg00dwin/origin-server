<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Frameset//EN" "http://www.w3.org/TR/html4/frameset.dtd">
<?php
# define any functions needed later
date_default_timezone_set("UTC");

function formatdate() {
  return date("Ymd-H:i:sT");
}

#
# get parameters from $_GET or defaults
#
$defaults = 
  array('filename' => '/etc/motd'
	);

# Actual options provided
$opts = array();

# assign the default or provided value from $_GET for each variable
foreach (array_keys($defaults) as $key) {
  if (array_key_exists($key, $_GET)) {
    $opts[$key] = $_GET[$key];
  } else {
    $opts[$key] = $defaults[$key];
  }
}


?>
<html>
  <head>
    <title>Get File <?php echo $opts['filename'] ?></title>
  </head>
  <body>
    <h1 style="text-align: center;"> Get File <?php echo $opts['filename'] ?></h1>
    <p>

      <?php
	print formatdate() . " Begin script<br/>\n" ;
	$filetype = @filetype($opts['filename']);
	print "file type: $filetype<br/>\n";
	print "<hr/>\n<pre>\n";
	# fill in here.
	switch ($filetype) {
	case 'file':
	  if (filesize($opts['filename']) == 0) {
	    print "EMPTY FILE: $opts[filename]\n";
	  } else {
	    $contents = @file_get_contents($opts['filename']);
	    if ($contents != FALSE) {
	      print $contents;
	    } else {
	      print "ERROR: unable to open $opts[filename]\n";
	    }
	  }
	  break;

	case 'dir':
	  $dh = opendir($opts['filename']);
	  $filestat = array();
	  while (($filename = readdir($dh)) != FALSE) {
	    $file = @stat("$opts[filename]/$filename");
	    $filestat[$filename] = $file;
	  }

	  $filenames = array_keys($filestat);
	  sort($filenames);
	   
	  foreach ($filenames as $filename) {
	    $fs = $filestat[$filename];

	    if ($fs != FALSE and count($fs) > 0) {
	      printf("%5d %5d %8d %17s", $fs[4], $fs[5], $fs[7], @date('Ymd-H:i:s', $fs[8]));
	    }
	    print " $filename\n";
	  }
	  break;

	default:
	    print "unknown file type: $filetype";
	}
	print "</pre>\n<hr/>\n";
	print formatdate() . " End script\n" ;
      ?>
    </p>
  </body>
</html>