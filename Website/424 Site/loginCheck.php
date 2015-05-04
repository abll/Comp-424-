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

// I need a query that will search the data base and return true if the user name and password match ill take another look at it in a sec

$selectQuery = "SELECT * FROM users WHERE user_email LIKE '$uEmail' AND password LIKE '$pWord'";

$result = $conn->query($selectQuery);

if ($result->num_rows == 1) 
{
    echo "Login Successful <br>";
    while($row = $result->fetch_assoc()) 
    {
        echo "First Name: " . $row["first_name"]. "<br>". "Last Name: " . $row["last_name"]. "<br>". "Last Login: ".
        "<br>". "Number Of Logins: ". "<br>";
    }
} 
else {
    echo "Login Failure Please Check Email and Password";
}

$conn->close();
?>