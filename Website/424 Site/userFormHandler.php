<?php
    
        
$firstName = htmlspecialchars($_POST['userFirstName']);
$lastName = htmlspecialchars($_POST['userLastName']);
$uName = htmlspecialchars($_POST['userName']);
$userBirthDate = htmlspecialchars($_POST['userDOB']);
$emailAddress = htmlspecialchars($_POST['userEmailAddress']);
$pWord = htmlspecialchars($_POST['userPassword']);
$secretQuestion1 = (int)htmlspecialchars($_POST['secQues1']);
$secretQuestion1Answer = htmlspecialchars($_POST['secQues1Answer']);
$secretQuestion2 = (int)htmlspecialchars($_POST['secQues2']);
$secretQuestion2Answer = htmlspecialchars($_POST['secQues2Answer']);


print "First Name: $firstName";
print "\nLast Name: $lastName";
print "\nUser Name: $uName";
print "\nEmail Address: $emailAddress";
print "\nPassWord: $pWord";
print "Secret Question 1: $secretQuestion1";
print "Secret Question Answer 1: $secretQuestion1Answer";
print "Secret Question 2: $secretQuestion2";
print "Secret Question Answer 1: $secretQuestion2Answer";

//Check into Secret Question Values Data Entry maybe try changing input type

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

$insertQuery  = "INSERT INTO `userdatabase`.`users` (`user_name`, `first_name`, `last_name`, `Date_of_Birth`, `user_email`, `password`, `sq_1_ID`, `sq_1_Answer`, `sq_2_ID`, `sq_2_answer`) 
VALUES ('$uName', '$firstName', '$lastName', '$userBirthDate', '$emailAddress', '$pWord', '$secretQuestion1', '$secretQuestion1Answer', '$secretQuestion2', '$secretQuestion2Answer')";

if ($conn->query($insertQuery) === TRUE) {
    echo "New record created successfully";
} else {
    echo "Error: " . $insertQuery . "<br>" . $conn->error;
}

$conn->close();
/*Another day look up String Ouput Info*/

?>


