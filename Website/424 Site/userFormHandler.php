<?php
//Code For Email Verification: http://youhack.me/2010/04/01/building-a-registration-system-with-email-verification-in-php/   
        
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

//Double Check Things Are Stored Correctly
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

define('EMAIL', 'email@gmail.com');
define('WEBSITE_URL', 'http://localhost');
define("SQL_DUPLICATE_ERROR", 1062);

$headers = "login@email.com"
$headers  .= 'MIME-Version: 1.0' . "\r\n";
$headers .= 'Content-type: text/html; charset=iso-8859-1' . "\r\n";

$conn = new mysqli($servername, $dbUserName, $dbPWord, $dbName);

if($conn->connect_error)
{
    die("Connection Failed: ".$conn->connect_error);
}

echo "Connected Successfully". "<br>";

//Double Check email hasnt been taking (Eventually Implement With Ajax)
$emailQuery = "SELECT * FROM users WHERE user_email LIKE '$emailAddress'";
$emailResult = $conn->query($emailQuery);

//Double Check Username hasnt been taking
$uNameQuery = "SELECT * FROM users WHERE user_name LIKE '$uName'";
$uNameResult = $conn->query($uNameQuery);

if (($emailResult->num_rows == 0) && ($uNameResult->num_rows == 0))
{
    $tempPassword = md5(uniqid(rand(), true));

    $insertQuery  = "INSERT INTO `userdatabase`.`users` (`user_name`, `first_name`, `last_name`, `Date_of_Birth`, `user_email`, `password`, `sq_1_ID`, `sq_1_Answer`, `sq_2_ID`, `sq_2_answer`, `temp_Password`) 
    VALUES ('$uName', '$firstName', '$lastName', '$userBirthDate', '$emailAddress', '$pWord', '$secretQuestion1', '$secretQuestion1Answer', '$secretQuestion2', '$secretQuestion2Answer', '$tempPassword')";

    $result = $conn->query($insertQuery);
    
    if ($conn->query($insertQuery) === TRUE) {
        echo "New record created successfully";
    }
    else if(!($result))
    {
        echo "Error". "<br>"
    } 
    else {
    echo "Error: " . $insertQuery . "<br>" . $conn->error;
    }

    //Implement this with PHP Mailer
    $message = " To activate your account, please click on this link:\n\n";
	$message .= WEBSITE_URL . '/activate.php?email=' . urlencode($emailAddress) . "&key=$tempPassword";
	mail($emailAddress, 'Registration Confirmation', $message, $headers);
}
else
{
    if($emailResult->num_rows > 0)
        echo "ERROR Email Account Has Been Taken Try Forgot PassWord Link! <br>";

    if($uNameResult->num_rows > 0)
        echo "ERROR USER NAME TAKEN! <br>";
}


$conn->close();
/*Another day look up String Ouput Info*/

?>


