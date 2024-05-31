<?php
// db.php
// Use environment variables or a configuration file for credentials
$host = "127.0.0.1";
$username = "root";
$password = "mosesugwu";
$database = "demo";

$con = mysqli_connect($host, $username, $password, $database);

if (mysqli_connect_errno()) {
    die("Failed to connect to MySQL: " . mysqli_connect_error());
}
?>