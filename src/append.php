<?php
/* Copyright (C) 2024 Mark D. Blackwell.
    All rights reserved.
    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
*/

/* See:
https://stackoverflow.com/questions/24972424/php-create-or-write-append-in-text-file

Accept AJAX requests to append song likes to a file.
*/

function clean_input($string)
{
    $double_quote = '"';
    $white_space = "/\s+/";
    $neat = implode(' ', preg_split($white_space, trim($string)));
    return addcslashes($neat, $double_quote);
};


// Constants:
$double_quote = "\"";
$ip_address = $_SERVER['REMOTE_ADDR'];
$like_filename = "like.txt";
$my_query_keys = array(
    'song_artist',
    'song_title',
    );
$n_dash = " - "; // Using hyphen, because it's ASCII.
$response_ok_json = "";

// d is zero-padded day of the month,
// H is zero-padded hour of 24,
// m is zero-padded month,
// M is zero-padded minute,
// S is zero-padded second, and
// Y is year with century.
$timestamp = date("Y-m-d H:M:S");

// Depends upon the above:

$prefix = $timestamp . " " . $ip_address;

foreach ($my_query_keys as $key)
    isset($_POST[$key]) or die();

$song_artist = clean_input($_POST['song_artist']);
$song_title  = clean_input($_POST['song_title' ]);

$string_to_write =
    $prefix . $n_dash . $double_quote .
    $song_artist .
    $double_quote . $n_dash . $double_quote .
    $song_title .
    $double_quote . "\n";

// See http://php.net/manual/en/function.fopen.php
// fopen with "a" means:
//   "Open for writing only; place the file pointer at the end of the file.
//   If the file does not exist, attempt to create it."

$myfile = fopen($like_filename, "a") or die();

fwrite($myfile, $string_to_write);

fclose($myfile);

echo $response_ok_json;
exit();
?>
