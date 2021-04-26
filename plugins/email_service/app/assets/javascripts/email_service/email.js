// const toFakeAddresses = " rjones@sbcglobal.net, doormat@comcast.net, less mfburgo@me.com, alfred@outlook.com, mfleming@comcast.net, verymuch hermanab@comcast.net, dpitts@sbcglobal.net, care,fairbank@aol.com, moxfulder@live.com, tarreau@comcast.net, simone@sbcglobal.net, I,bahwi@outlook.com, jonas@optonline.net, so much malvar@verizon.net, zeller@yahoo.ca, policies@att.net, froodian@hotmail.com, alias@me.com, fmerges@att.net, tmccarth@yahoo.com"
// const ccFakeAddresses = " curly@comcast.net, plover@me.com, jmcnamara@icloud.com, dgriffith@comcast.net, invalid,elmer@optonline.net, lamky@yahoo.ca, barlow@sbcglobal.net, random,timlinux@optonline.net, anicolao@me.com, jaesenj@yahoo.ca, some,cgcra@yahoo.com, guialbu@msn.com, benits@verizon.net, entries,bwcarty@icloud.com, pavel@msn.com, pplinux@mac.com, verizon,rmcfarla@mac.com, bjornk@verizon.net, globalcampbell@verizon.net, notaprguy@verizon.net"
// const bccFakeAddresses = " greear@icloud.com, major,ranasta@gmail.com, forsberg@sbcglobal.net, pdbaby@verizon.net, afifi@aol.com, ninenine@verizon.net, potato mbswan@live.com, galbra@mac.com, vsprintf@hotmail.com, ducasse@att.net, tomato sopwith@yahoo.ca, wildfire@yahoo.ca, donev@mac.com, pdbaby@msn.com, gfody@hotmail.com, minor,frederic@hotmail.com, ardagna@optonline.net, citizenl@yahoo.com, makarow@gmail.com, xnormal@live.com"

const re = /[\s, ]+/; // comma and space regex.
//email regex
// var regex = /^[\W]*([\w+\-.%]+@[\w\-.]+\.[A-Za-z]+[\W]*,{1}[\W]*)*([\w+\-.%]+@[\w\-.]+\.[A-Za-z]+)[\W]*$/; //multiple occurance need fix
const regex = /^(([^<>()[\]\\.,;:\s@\"]+(\.[^<>()[\]\\.,;:\s@\"]+)*)|(\".+\"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$/;


$(document).ready(function() {
  // alert("Document is ready !!");
  $('#email_to_addr').val() = "HELLO"
  // Test fake email data population to the input fields
  // populateClearFakeEmails('#toBtnPopulate', '#toeMail', toFakeAddresses);
  // populateClearFakeEmails('#ccBtnPopulate', '#cceMail', ccFakeAddresses);
  // populateClearFakeEmails('#bccBtnPopulate', '#bcceMail', bccFakeAddresses);

  //Validate eMail Addresses from to, cc and bcc field and ensure count does not exceed 50.
  emailValidate("#email_to_addr", "#toEmailHelpBlock", "#toErrBlock");
  emailValidate("#email_cc_addr", "#ccEmailHelpBlock", "#ccErrBlock");
  emailValidate("#email_bcc_addr", "#bccEmailHelpBlock", "#bccErrBlock");

  
  // document.getElementsByClassName("email-addr")[0];
  // $(".email-addr").forEach( (item, index ) => {
  //   emailValidate(".email-addr", "#toEmailHelpBlock", "#toErrBlock");
  // }


});

function populateClearFakeEmails(btnElement, inputElement, strAddr) {
  $(btnElement).click(function() { 
    tmp = $(inputElement).val();
    if (!tmp || tmp.length === 0  ) {
      $(inputElement).val(strAddr);
    }
    else {
      $(inputElement).val("");
    }
  });
}

function emailValidate(inputElement, helperBlock, errorBlock) {
  var valideMailArr = [];
  $(inputElement).on('blur change' , function (){
    const inputText = $(inputElement).val();
    if ( !inputText || inputText.length === 0 ) {
      $(errorBlock).html("At least one email address is required : "+ valideMailArr.length);
    }
    else {
      var result = processBulkEmail(inputText);
      var invalidEntries = result.invalidEntries;
      valideMailArr = result.valideMailArr;
      if (invalidEntries || invalidEntries.length > 0) {
        $(errorBlock).html("Invalid entries: " + invalidEntries + " and will be omitted");
      }
      // console.log( "Valid Count: " + valideMailArr.length + " Invalid Count : "+ invalidEntries.length);
      if ( valideMailArr.length <= 50 ) {
        $(helperBlock).html("<b>"+ valideMailArr.length  + " </b>valid email recipients of " + (valideMailArr.length + invalidEntries.length) + " entries.");
      }
      if ( valideMailArr.length > 50 ) {
        $(errorBlock).html("Error: Number of recipients ( "+ valideMailArr.length +" ) are exceeding the maximum limit of 50");
      }
    }
    // if ( totalRecipients.length > 50 ){
    //   $('ErrBlock').html("Total count : " + totalRecipients.length  + " is exceeding the allowed limit of 50 addresses altogether");
    // }

  });
  return valideMailArr.length;
}
function processBulkEmail(inputText) {
  var invalidEntries = [];
  var valideMailArr = [];
  emailList = inputText.split(re); 
  console.log("Unprocessed - Count is : " + emailList.length);
  emailList.forEach( ( element, index ) => {
    var emElement = element.trimEnd().trimStart();
    if ( validateEmail( emElement ) ) {
      valideMailArr.push( emElement );
    }
    else {
      invalidEntries.push(element);
    }
  });
  return { valideMailArr, invalidEntries };
}

const validateEmail= (email) => {
    return regex.test(String(email).toLowerCase());
}
