<?php
    
$uEmail = htmlspecialchars($_POST['email']);
$pWord = htmlspecialchars($_POST['password']);

$servername = "localhost";
$dbUserName = "root";
$dbPWord = "";
$dbName = "userdatabase";

$conn = new mysqli($servername, $dbUserName, $dbPWord, $dbName);

if($conn->connect_error)
{
    die("Connection Failed: ".$conn->connect_error);
}

echo "\nConnected Successfully";

// I need a query that will search the data base and return true if the user name and password match ill take another look at it in a sec

$selectQuery = "SELECT * FROM users WHERE (user_email LIKE $uEmail AND password LIKE $password)";
$altQuery = "SELECT CASE WHEN EXISTS (
    SELECT *
    FROM [users}
    (WHERE user_email = $uEmail AND password = $password))";

if ($conn->query($altQuery) == 1) {
    echo "\nLogin Successful";
} else {
    echo "\nLogin Failure";
}

$conn->close();
?>