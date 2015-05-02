<?php
        
$firstName = htmlspecialchars($_POST['userFirstName']);
$lastName = htmlspecialchars($_POST['userLastName']);
$uName = htmlspecialchars($_POST['userName']);
$emailAddress = htmlspecialchars($_POST['userEmailAddress']);
$pWord = htmlspecialchars($_POST['userPassword']);
$secretQuestion = htmlspecialchars($_POST['secQues1']);
$secretQuestionAnswer = htmlspecialchars($_POST['secQues1Answer']);


print "First Name: $firstName";
print "\nLast Name: $lastName";
print "\nUser Name: $uName";
print "\nEmail Address: $emailAddress";
print "\nPassWord: $pWord";
print "Secret Question 1: $secretQuestion";
print "Secret Question Answer 1: $secretQuestionAnswer";

/*Another day look up String Ouput Info*/

?>


