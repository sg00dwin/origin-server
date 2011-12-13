/* DO NOT MODIFY. This file was compiled Tue, 13 Dec 2011 19:01:18 GMT from
 * /home/fotios/openshift/li/site/app/coffeescripts/form.coffee
 */

(function() {
  var $;
  $ = jQuery;
  $(function() {
    var change, close_btn, close_dialog, dialogs, form_complete, form_type, login_complete, open_dialog, registration_complete, reset, reset_password_complete, rulesets, signin, signup, start_spinner, stop_spinner;
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
          required: true
        },
        "express_domain[password]": {
          required: true,
          minlength: 6
        }
      }
    });
    $("#new_express_app").validate({
      rules: {
        "express_app[app_name]": {
          required: true,
          alpha_numeric: true,
          maxlength: 16
        },
        "express_app[cartridge]": {
          required: true
        }
      }
    });
    dialogs = $('.dialog');
    open_dialog = function(dialog) {
      $.each($('div.dialog:visible'), function(index, dialog) {
        return close_dialog($(dialog));
      });
      dialogs.hide();
      dialog.show();
      dialog.find("input:visible:first").focus();
      return ($(window, 'html', 'body')).scrollTop(0);
    };
    close_dialog = function(dialog) {
      dialog.find(':hidden').show();
      dialog.find('div.message').remove();
      dialog.find('input:visible:not(.button)').val('');
      dialog.find('label.error').remove();
      dialog.find('input').removeClass('error');
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
      var login, userbox;
      event.preventDefault();
      login = $('div.content #login-form');
      userbox = $('#user_box #login-form');
      if (login.length > 0 || userbox.length > 0) {
        dialogs.hide();
        return $('#login_input').focus();
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
    login_complete = function($form, $msg, $json, status) {
      switch (status) {
        case 200:
          window.location.replace($json.redirectUrl);
          break;
        case 401:
          $msg.addClass('error').text($json.error).show();
          break;
        default:
          return $msg.addClass('error').html($json.error || "Some unknown error occured,<br/> please try again.").show();
      }
    };
    registration_complete = function($form, $msg, $json, status) {
      var messages;
      messages = $.map($json, function(k, v) {
        return k;
      });
      if ($json['redirectUrl'] === void 0 || $json['redirectUrl'] === null) {
        $.each(messages, function(i, val) {
          return $msg.addClass('error').append($('<div>').html(val));
        });
        $msg.show();
        if (typeof Recaptcha !== 'undefined') {
          return Recaptcha.reload();
        }
      } else {
        return window.location.replace($json['redirectUrl']);
      }
    };
    reset_password_complete = function($form, $msg, $json, hide) {
      $msg.addClass($json.status).text($json.message).show();
      if (hide) {
        return $form.parent().find('form,div#extra_options').hide();
      }
    };
    start_spinner = function(e) {
      var $form;
      $form = $(e.target);
      $form.find('input[type=submit]').attr('disabled', 'disabled');
      return $form.spin();
    };
    stop_spinner = function($form) {
      $form.find('input[type=submit]').removeAttr('disabled');
      return $form.spin(false);
    };
    form_complete = function(xhr, status) {
      var $form, $json, $msg, $parent, type;
      $form = $(this);
      stop_spinner($form);
      $json = $.parseJSON(status.responseText);
      $parent = $form.parent();
      $parent.find('div.message').remove();
      $msg = $('<div>').addClass('message').hide().insertBefore($form);
      type = $parent.attr('id');
      switch (type) {
        case 'new-user':
          registration_complete($form, $msg, $json, status.status);
          break;
        case 'login-form':
          login_complete($form, $msg, $json, status.status);
          break;
        case 'password-reset-form':
          reset_password_complete($form, $msg, $json, true);
          break;
        case 'change-password-form':
          reset_password_complete($form, $msg, $json, false);
          break;
      }
      return $msg.truncate();
    };
    rulesets = {
      reset: {
        rules: {
          "email": {
            required: true,
            email: true
          }
        }
      },
      change: {
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
            equalTo: '#password'
          }
        }
      },
      signup: {
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
      },
      signin: {
        rules: {
          "login": {
            required: true
          },
          "password": {
            required: true
          }
        }
      }
    };
    form_type = {
      signin: [signin, $('#login-form')],
      signup: [signup, $('#new-user')],
      change: [change],
      reset: [reset]
    };
    return $.each(form_type, function(name, forms) {
      return $.each(forms, function(index, form) {
        return form.find('form').bind('ajax:complete', form_complete).bind('ajax:beforeSend', start_spinner).validate(rulesets[name]);
      });
    });
  });
}).call(this);
