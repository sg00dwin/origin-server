// file: Form validation initialization script

$(function() {
  
  //Add custom validation method for ec2 acct number
  jQuery.validator.addMethod(
    "aws_account",
    function (value) {
      return (/^[\d]{4}-[\d]{4}-[\d]{4}$/).test(value);  
    },
    "Account numbers should be a 12-digit number separated by dashes. Ex: 1234-5678-9000"
  );
  
  //Add custom validation method for alpha_numeric
  jQuery.validator.addMethod(
    "alpha_numeric",
    function (value) {
      return (/^[A-Za-z0-9]*$/).test(value);
    },
    "Only letters and numbers are allowed"
  );
  
  //Login form
  $('#login-form form').validate({
    rules: {
      login: {
        required: true
      },
      password: {
        required: true
      }
    }
  });
  
  //Register form
  $('#new_web_user').validate({
    rules: {
      'web_user[email_address]': {
        required: true,
        email: true
      },
      'web_user[password]': {
        required: true,
        minlength: 6
      },
      'web_user[password_confirmation]': {
        required: true,
        equalTo: '#web_user_password'
      }
    }
  });
  
  //Express Request access form
  $('#new_access_express_request').validate({
    rules : {
      'access_express_request[terms_accepted]' : 'required'
    }
  });
  
  //Flex request access  
  $('#new_access_flex_request').validate({
    rules : {
      'access_flex_request[ec2_account_number]' : {
        'required' : true,
        'aws_account' : true
      },
      'access_flex_request[terms_accepted]' : 'required'
    }
  });
  
  //Domain form
  $('#new_express_domain').validate({
    rules: {
      'express_domain[namespace]' : {
        'required' : true,
        'alpha_numeric' : true,
        'maxlength' : 16
      },
      'express_domain[ssh]' : {
        'required' : true,
        'accept': '.pub'
      },
      'express_domain[password]' : {
        'required' : true,
        'minlength' : 6
      }
    }
  });
  
  //Focus first non-hidden form field on page
  $('input').not('[type=hidden]').first().focus();
      
});
