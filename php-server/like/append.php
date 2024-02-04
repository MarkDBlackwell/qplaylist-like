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
    $white_space = '/\s+/';
    $neat = implode(' ', preg_split($white_space, trim($string)));
    return addcslashes($neat, $double_quote);
};


// Constants:
$double_quote = '"';
$ip_address = $_SERVER['REMOTE_ADDR'];
$like_filename = 'like.txt';
$my_query_keys = array(
    'song_artist',
    'song_title',
    );
$response_bad_file_json                     = json_encode(array('response' => 'Unable to open comments file!'));
$response_bad_request_parameters_json       = json_encode(array('response' => 'Invalid request parameters!'));
$response_bad_request_parameters_count_json = json_encode(array('response' => 'Invalid request parameters count!'));
$response_ok_json                           = json_encode(array('response' => 'good'));
$separator = ' ';

// Depends upon the above:

count($my_query_keys) === count($_POST) or die($response_bad_request_parameters_count_json);
foreach ($my_query_keys as $key)
    isset($_POST[$key]) or die($response_bad_request_parameters_json);

$song_artist = clean_input($_POST['song_artist']);
$song_title  = clean_input($_POST['song_title' ]);

date_default_timezone_set('UTC');

// c is ISO8601 formatted date and time without fractions of seconds.
$timestamp = date('c');

$string_to_write =
    $timestamp .
        $separator .
    $ip_address .
        $separator . $double_quote .
    $song_artist .
        $double_quote . $separator . $double_quote .
    $song_title .
        $double_quote . "\n";

// See http://php.net/manual/en/function.fopen.php
// fopen with "a" means:
//   "Open for writing only; place the file pointer at the end of the file.
//   If the file does not exist, attempt to create it."

$myfile = fopen($like_filename, 'a') or die($response_bad_file_json);

fwrite($myfile, $string_to_write);

fclose($myfile);

echo $response_ok_json;
exit();
?>
