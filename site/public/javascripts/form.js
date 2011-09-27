/* DO NOT MODIFY. This file was compiled Mon, 26 Sep 2011 22:30:13 GMT from
 * /home/fotios/li/site/app/coffeescripts/form.coffee
 */

(function() {
  var $;
  $ = jQuery;
  $(function() {
    var change, close_btn, close_dialog, dialogs, login_complete, open_dialog, registration_complete, reset, reset_password_complete, signin, signup;
    $.validator.addMethod("aws_account", (function(value) {
      return /^[\d]{4}-[\d]{4}-[\d]{4}$/.test(value);
    }), "Account numbers should be a 12-digit number separated by dashes. Ex: 1234-5678-9000");
    $.validator.addMethod("alpha_numeric", (function(value) {
      return /^[A-Za-z0-9]*$/.test(value);
    }), "Only letters and numbers are allowed");
    $("#new_access_express_request").validate({
      rules: {
        "access_express_request[terms_accepted]": {
          required: true
        }
      }
    });
    $("#new_access_flex_request").validate({
      rules: {
        "access_flex_request[terms_accepted]": {
          required: true
        }
      }
    });
    $("#new_express_domain").validate({
      rules: {
        "express_domain[namespace]": {
          required: true,
          alpha_numeric: true,
          maxlength: 16
        },
        "express_domain[ssh]": {
          required: true,
          accept: ".pub"
        },
        "express_domain[password]": {
          required: true,
          minlength: 6
        }
      }
    });
    dialogs = $('.dialog');
    open_dialog = function(dialog) {
      dialogs.hide();
      dialog.show();
      return ($(window, 'html', 'body')).scrollTop(0);
    };
    close_dialog = function(dialog) {
      return dialog.hide();
    };
    close_btn = $('.close_button');
    signup = $('#signup');
    signin = $('#signin');
    reset = $('#reset_password');
    change = $('#change_password');
    ($('a.sign_up')).click(function(event) {
      event.preventDefault();
      return open_dialog(signup);
    });
    ($('a.sign_in')).click(function(event) {
      var userbox;
      event.preventDefault();
      userbox = $('#user_box #login-form');
      if (userbox.length > 0) {
        dialogs.hide();
        return userbox.find('#login_input').focus();
      } else {
        return open_dialog(signin);
      }
    });
    ($('a.password_reset')).click(function(event) {
      event.preventDefault();
      return open_dialog(reset);
    });
    ($('a.change_password')).click(function(event) {
      event.preventDefault();
      return open_dialog(change);
    });
    close_btn.click(function(event) {
      return close_dialog(($(this)).parent());
    });
    login_complete = function(xhr, status) {
      var $err_div, json;
      json = $.parseJSON(status.responseText);
      console.log(json);
      $(this).parent().find('div.message.error').remove();
      $err_div = $('<div>').addClass('message error').hide().insertBefore(this);
      switch (status.status) {
        case 200:
          window.location.replace(json.redirectUrl);
          break;
        case 401:
          $err_div.text(json.error).show();
          break;
        default:
          $err_div.html(json.error || "Some unknown error occured,<br/> please try again.").show();
          return console.log('Some unknown AJAX error with the login', status.status);
      }
    };
    registration_complete = function(xhr, status) {
      var $err_div, form, json, messages;
      form = $(this);
      json = $.parseJSON(status.responseText);
      console.log("Reg complete, got JSON", json);
      $(this).parent().find('div.message.error').remove();
      $err_div = $('<div>').addClass('message error').hide().insertBefore(this);
      messages = $.map(json, function(k, v) {
        return k;
      });
      if (json['redirectUrl'] === void 0 || json['redirectUrl'] === null) {
        $.each(messages, function(i, val) {
          return $err_div.addClass('error').append($('<div>').html(val));
        });
        $err_div.show();
        if (typeof Recaptcha !== 'undefined') {
          return Recaptcha.reload();
        }
      } else {
        return window.location.replace(json['redirectUrl']);
      }
    };
    reset_password_complete = function(xhr, status) {
      var $div, form, json;
      form = $(this);
      json = $.parseJSON(status.responseText);
      console.log("Reset password complete, got JSON", json);
      $(this).parent().find('div.message').remove();
      return $div = $('<div>').addClass("message " + json.status).text(json.message).insertBefore(this);
    };
    $.each([signin, $('#login-form')], function(index, element) {
      return element.find('form').bind('ajax:complete', login_complete).validate({
        rules: {
          "login": {
            required: true,
            email: true
          },
          "password": {
            required: true
          }
        }
      });
    });
    $.each([signup, $('#new-user')], function(index, element) {
      return element.find('form').bind('ajax:complete', registration_complete).validate({
        rules: {
          "web_user[email_address]": {
            required: true,
            email: true
          },
          "web_user[password]": {
            required: true,
            minlength: 6
          },
          "web_user[password_confirmation]": {
            required: true,
            equalTo: "#web_user_password"
          }
        }
      });
    });
    change.find('form').bind('ajax:complete', reset_password_complete).validate({
      rules: {
        "old_password": {
          required: true
        },
        "password": {
          required: true,
          minlength: 6
        },
        "password_confirmation": {
          required: true,
          minlength: 6
        }
      }
    });
    return reset.find('form').bind('ajax:complete', reset_password_complete).validate({
      rules: {
        "email": {
          required: true,
          email: true
        }
      }
    });
  });
}).call(this);
