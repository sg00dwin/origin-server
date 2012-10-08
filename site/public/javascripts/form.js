/* DO NOT MODIFY. This file was compiled Wed, 22 Aug 2012 22:11:04 GMT from
 * /builddir/build/BUILD/rhc-site-0.97.12/app/coffeescripts/form.coffee
 */

(function() {
  var $, find_control_group_parent;
  $ = jQuery;
  find_control_group_parent = function(child) {
    var parent;
    parent = $(child).parentsUntil(".control-group").parent().closest(".control-group");
    return parent;
  };
  $(function() {
    var loading_match;
    $.validator.addMethod("alpha_numeric", (function(value) {
      return /^[A-Za-z0-9]*$/.test(value);
    }), "Only letters and numbers are allowed");
    $.validator.setDefaults({
      errorClass: 'help-inline',
      errorElement: 'p',
      highlight: function(element, errorClass, validClass) {
        return $(find_control_group_parent(element)).addClass('error').addClass('error-client').removeClass(validClass);
      },
      unhighlight: function(element, errorClass, validClass) {
        var $el;
        $el = $(find_control_group_parent(element));
        $el.removeClass('error-client');
        if (typeof ($el.attr('data-server-error')) === 'undefined') {
          return $el.removeClass('error');
        }
      }
    });
    $('form#new_user_form').validate({
      rules: {
        "web_user[email_address]": {
          required: true,
          email: true
        },
        "web_user[old_password]": {
          required: true
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
    $('form#login_form').validate({
      rules: {
        "web_user[rhlogin]": {
          required: true
        },
        "web_user[password]": {
          required: true
        }
      }
    });
    $('form#payment_method').validate({
      rules: {
        "cc_no": {
          required: true
        },
        "cvv": {
          required: true
        }
      }
    });
    $("[data-unhide]").click(function(event) {
      var src, tgt;
      src = $(this);
      tgt = $(src.attr('data-unhide'));
      if (tgt) {
        if (event != null) {
          event.preventDefault();
        }
        src.closest('[data-hide-parent]').addClass('hidden');
        return $('input', tgt.removeClass('hidden')).focus();
      }
    });
    loading_match = '*[data-loading=true]';
    return ($('form ' + loading_match)).each(function() {
      var finished;
      if (window.loader_image) {
        this.src = window.loader_image;
      }
      finished = function() {
        ($(loading_match)).hide();
        return ($('input[type=submit][disabled]')).removeAttr('disabled');
      };
      ($(window)).bind('pagehide', finished);
      return ($(this)).closest('form').bind('submit', function() {
        this.finished = finished;
        if (($('.control-group.error-client')).length === 0) {
          ($(loading_match, this)).show();
          ($('input[type=submit]', this)).attr('disabled', 'disabled');
          return true;
        }
      });
    });
  });
}).call(this);
