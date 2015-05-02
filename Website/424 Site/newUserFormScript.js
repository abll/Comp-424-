// This is the java script to validate the new User Form Html File.
//Created By Abel Lawal
//on 04/21/15

//Code to Validate DOB
function dobvalidate(input) 
{
    if(input.validity.patternMismatch)
    {
        //Sets a Custom Error Message
        input.setCustomValidity('The DOB Must Be In MM\\DD\\YYYY Format');
    }
    else
    {
        input.setCustomValidity('');
    }
}

function refreshCaptcha()
{
    var img = document.images['captchaimg'];
    img.src = img.src.substring(0,img.src.lastIndexOf("?"))+"?rand="+Math.random()*1000;
}

function ajaxInit()
{
     var ajaxReq;
    if(window.XMLHttpRequest)
    {
        //Code for Newer Browsers
        ajaxReq = new XMLHttpRequest();
        document.getElementById("test").innerHTML = "New Browser Success";
    }
    else
    {
        //Code for Older Browsers
        ajaxReq = new ActiveXObject("Microsoft.XMLHTTP");
        document.getElementById("test").innerHTML = "Old Browser Success";
    }
}

//Function to ensure that User Name is Uniuqe
//Needs to be implemented with Ajax
function userValidate(input)
{
    document.getElementById("test").innerHTML = "Entered Function";
    
    //ajaxInit();
   //xmlhttp.open("POST", "http://localhost/424Project/userFormHandler.php", true);
    
    //if (!target) target = document.getElementById('uname');
    document.getElementById("inputTest").innerHTML = input;
    ajaxReq.open("POST", "http://localhost/424Project/validateUser.php?id=" + input, true);
    ajaxReq.send();

    ajaxReq = new XMLHttpRequest();
    ajaxReq.onreadystatechange = function () 
    {
        if (ajaxReq.readyState == 4 && ajaxReq.status == 200) 
        {
            document.getElementById("test").innerHTML = ajaxReq.responseText;
        }
    }
}

//Code to Validate confirm Password
function confirmPassword(input) 
{
    if (document.getElementById('pword').value != document.getElementById('cpword').value)
        input.setCustomValidity('Password and Confirm Password Mismatch');
     else
        input.setCustomValidity('');
}

//Probably will need to use regular expressions to make this work.
function passwordStrength(input) 
{
    var strength = "test";

    var testString = input.value;

    /*Regular Expression to Signify at Least 1 Upper Case Letter, 1 Number, 
    1 Lower Case Letter and Be 4 characters long*/
    var weak = new RegExp("^(?=.*[A-Z])(?=.*[0-9])(?=.*[a-z]).{4,}$")
    /* Regular Expression to Signify At least 1 Upper Case Letter, 1 Special Character, 1 numbers,
    2 lower case letters and be at least 6 characters long */
    var medium = new RegExp("^(?=.*[A-Z])(?=.*[!@#$&*])(?=.*[0-9])(?=.*[a-z].*[a-z]).{6,}$");
    /* Regular Expression to Signify At least 2 Upper Case Letter, 1 Special Character, 2 numbers,
    3 lower case letters and be at least 8 characters long */
    var strong = new RegExp("^(?=.*[A-Z].*[A-Z])(?=.*[!@#$&*])(?=.*[0-9].*[0-9])(?=.*[a-z].*[a-z].*[a-z]).{8,}$");

    var weakBool, medBool, StrBool;

    weakBool = weak.test(testString);
    medBool = medium.test(testString);
    StrBool = strong.test(testString);

    //By Default a pass word is weak
    document.getElementById('pwordStrength').innerHTML = "Weak";
     //Need to change the rest to this format

    if ((weakBool) && !(medBool) && !(StrBool)) 
    {
         document.getElementById('pwordStrength').innerHTML = "Weak";
    }
    else if ((weakBool) && (medBool) && !(StrBool))
    {
         document.getElementById('pwordStrength').innerHTML = "Medium";
    }  
    else if ((weakBool) && (medBool) && (StrBool)) 
    {
         document.getElementById('pwordStrength').innerHTML = "Strong";
    }  

    //document.getElementById('pwordStrength').innerHTML = strength;
}