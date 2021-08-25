const toFakeAddresses = " rjones@sbcglobal.net, doormat@comcast.net, less mfburgo@me.com, alfred@outlook.com, mfleming@comcast.net, verymuch hermanab@comcast.net, dpitts@sbcglobal.net, care,fairbank@aol.com, moxfulder@live.com, tarreau@comcast.net, simone@sbcglobal.net, I,bahwi@outlook.com, jonas@optonline.net, so much malvar@verizon.net, zeller@yahoo.ca, policies@att.net, froodian@hotmail.com, alias@me.com, fmerges@att.net, tmccarth@yahoo.com";
const ccFakeAddresses = " curly@comcast.net, plover@me.com, jmcnamara@icloud.com, dgriffith@comcast.net, invalid,elmer@optonline.net, lamky@yahoo.ca, barlow@sbcglobal.net, random,timlinux@optonline.net, anicolao@me.com, jaesenj@yahoo.ca, some,cgcra@yahoo.com, guialbu@msn.com, benits@verizon.net, entries,bwcarty@icloud.com, pavel@msn.com, pplinux@mac.com, verizon,rmcfarla@mac.com, bjornk@verizon.net, globalcampbell@verizon.net, notaprguy@verizon.net";
const bccFakeAddresses = " greear@icloud.com, major,ranasta@gmail.com, forsberg@sbcglobal.net, pdbaby@verizon.net, afifi@aol.com, ninenine@verizon.net, potato mbswan@live.com, galbra@mac.com, vsprintf@hotmail.com, ducasse@att.net, tomato sopwith@yahoo.ca, wildfire@yahoo.ca, donev@mac.com, pdbaby@msn.com, gfody@hotmail.com, minor,frederic@hotmail.com, ardagna@optonline.net, citizenl@yahoo.com, makarow@gmail.com, xnormal@live.com";

const re = /[\s, ]+/; // comma and space regex.
const regex = /^(([^<>()[\]\\.,;:\s@\"]+(\.[^<>()[\]\\.,;:\s@\"]+)*)|(\".+\"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$/;
// let toAddrProcessed, toAddrInput;
// let fixtoElementAdded = false;

let validToAddresses, validCcAddresses, validBccAddresses;
let validToAddressCount, validCcAddressCount, validBccAddressCount;
let totalEmailAddresses = 0;

$(document).ready(function() {
  
  if ($('body').hasClass('modal-open')) {
    console.log('modal-open class is added');
    console.log($('#modal-dialog').find('.modal').is(":visible"));
  }
 
  $('.modal').on('focus', function() {
    console.log("mainModel loaded");
  });

  if ( $('.modal').is(":visible") ) {
    console.log('modal is visble');
  }

  $('body.emails.modal-open').click(function(e) {
    initializeData();
    console.log(`Clicked Item is ${e.target.id}`);

    $("select#email_source").change(function() {
      console.log('email_source changed');
      var source_value = $('select#email_source').val();
      console.log(source_value);
    });
    
    $('textarea#email_to_addr').blur(function() {
      console.log('to_addr blur triggered');
      validateEmails('#email_to_addr','span.toEmailHelpBlock','span.toEmailErrorBlock');
    });

    $('textarea#email_cc_addr').blur(function() {
      console.log('cc blurred');
      validateEmails('#email_cc_addr','span.ccEmailHelpBlock','span.ccEmailErrorBlock');
    });

    $('textarea#email_bcc_addr').blur(function() {
      console.log('bcc blurred');
      validateEmails('#email_cc_addr','span.bccEmailHelpBlock','span.bccEmailErrorBlock');
    });

  });

});


const initializeData = function(){
  
  $("#email_to_addr").val(toFakeAddresses);
  $("#email_cc_addr").val(ccFakeAddresses);
  $("#email_bcc_addr").val(bccFakeAddresses);

  validToAddressCount, validCcAddressCount, validBccAddressCount = 0;
  $('span.toEmailHelpBlock').css("color", "blue");
  $('span.ccEmailHelpBlock').css("color", "blue");
  $('span.bccEmailHelpBlock').css("color", "blue");

  $('span.toEmailErrorBlock').css("color", "red");
  $('span.ccEmailErrorBlock').css("color", "red");
  $('span.bccEmailErrorBlock').css("color", "red");

  $("div.form-group.email_to_addr_fix").hide();
  $("div.form-group.email_cc_addr_fix").hide();
  $("div.form-group.email_bcc_addr_fix").hide();

}

const showFixControl = function(element) {
  $(element).show();
};
function populateClearFakeEmails(btnElement, inputElement, strAddr) {
  $(btnElement).click(function () {
    tmp = $(inputElement).val();
    if (!tmp || tmp.length === 0) {
      $(inputElement).val(strAddr);
    }
    else {
      $(inputElement).val("");
    }
  });
}

const validateEmails = function (inputElement, helperBlock, errorBlock) {
  var valideMailArr = [];
  const inputText = $(inputElement).val();
  if (!inputText || inputText.length === 0) {
    $(errorBlock).html("At least one email address is required : " + valideMailArr.length);
  }
  else {
    var result = processBulkEmail(inputText);
    var invalidEntries = result.invalidEntries;
    valideMailArr = result.valideMailArr;
    if (invalidEntries || invalidEntries.length > 0) {
      $(errorBlock).html("Invalid entries: " + invalidEntries + " and will be omitted");
    }
    if (valideMailArr.length <= 50) {
      $(helperBlock).html("<b>" + valideMailArr.length + " </b>valid email recipients of " + (valideMailArr.length + invalidEntries.length) + " entries.");
    }
    if (valideMailArr.length > 50) {
      $(errorBlock).html("Error: Number of recipients ( " + valideMailArr.length + " ) are exceeding the maximum limit of 50");
    }
  } 

  if (inputElement === "#email_to_addr") {
    validToAddresses = valideMailArr;
    validToAddressCount = valideMailArr.length;
  } else if (inputElement === "#email_cc_addr") {
    validCcAddresses = valideMailArr;
    validCcAddressCount = valideMailArr.length;
  } else if (inputElement === "#email_bcc_addr") {
    validBccAddresses = valideMailArr;
    validBccAddressCount = valideMailArr.length;
  }
  // return valideMailArr.length;
}

const processBulkEmail = function (inputText) {
  var invalidEntries = [];
  var valideMailArr = [];
  var emElement = "";
  emailList = inputText.split(re);
  console.log("Unprocessed - Count is : " + emailList.length);
  emailList.forEach((element, index) => {
    emElement = element.trimEnd().trimStart();
    if (validateEmail(emElement)) {
      valideMailArr.push(emElement);
    }
    else {
      invalidEntries.push(element);
    }
  });
  console.log("Processed - Count is : " + valideMailArr.length);
  console.log("invalidEntries - Count is : " + invalidEntries.length);
  return { valideMailArr, invalidEntries };
}
const validateEmail = (email) => {
  return regex.test(String(email).toLowerCase());
}

const getTotalEmailAddresses = function() {
  totalEmailAddresses = validToAddressCount + validCcAddressCount + validBccAddressCount;
  return totalEmailAddresses;
}
// console.log(window.pluginName);
// $('body.emails').css({backgroundColor: "#bbb"});

// $("#mainModal").on('shown.bs.modal', function () {
//   alert('The mainModal is fully shown.');
// });


// const afterPageLoad = function() {
//   console.log('this happens onLoad - Plain JavaScript');
// }
// window.onload = afterPageLoad; // works


// const email_source = document.querySelector('#email_source');
// const email_to_add = document.querySelector("#email_to_add");
// console.log(email_to_add);
// email_to_add.addEventListener('blur', function() {
//   console.log('email_source change event');
// });

  // Validate eMail Addresses from to, cc and bcc field and ensure count does not exceed 50.
  // emailValidate("#email_to_addr", "#toEmailHelpBlock", "#toErrBlock");
  // emailValidate("#email_cc_addr", "#ccEmailHelpBlock", "#ccErrBlock");
  // emailValidate("#email_bcc_addr", "#bccEmailHelpBlock", "#bccErrBlock");

  //   // document.getElementsByClassName("email-addr")[0];
  //   // $(".email-addr").forEach( (item, index ) => {
  //   //   emailValidate(".email-addr", "#toEmailHelpBlock", "#toErrBlock");
  //   // }


  // $("#email_to_addr").on("blur", function () {
  //   toAddrInput = $("#email_to_addr").val();
  //   let valideMailArr, invalidEntries;
  //   result = processBulkEmail(toAddrInput);
  //   invalidEntries = result.invalidEntries;
  //   valideMailArr = result.valideMailArr;
  //   toAddrProcessed = valideMailArr;
  //   if (invalidEntries) {
  //     $("#email_to_addr").addClass("invalid");
  //     if (!fixtoElementAdded) {
  //       fixtoElementAdded = true;
  //     }
  //   } else {
  //     $("#email_to_addr").addClass("valid");
  //   }
  //   $(".toEmailHelpBlock").html(valideMailArr);
  //   $(".toErrBlock").html(invalidEntries.join(", "));

  // });