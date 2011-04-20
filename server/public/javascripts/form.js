// file: Form validation initialization script

$(function() {
  
  //Login form
  $('#login-form form').validate({
    rules: {
      login: {
        required: true,
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
});
