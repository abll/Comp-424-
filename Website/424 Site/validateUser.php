<?php
    $user = $_REQUEST["id"];

    $message = "";

    if($user !=  "")
        $message = " is the User Of The Hour";

        echo $user + $message;

?>
