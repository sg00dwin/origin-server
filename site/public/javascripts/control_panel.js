/* DO NOT MODIFY. This file was compiled Wed, 22 Aug 2012 22:11:06 GMT from
 * /builddir/build/BUILD/rhc-site-0.97.12/app/coffeescripts/control_panel.coffee
 */

(function() {
  var $, shorten;
  $ = jQuery;
  shorten = function(str, len) {
    if (str.length > len) {
      return str.slice(0, len) + '...';
    } else {
      return str;
    }
  };
  $(function() {
    var cpDialog;
    cpDialog = $("<div id=\"cp-dialog\"></div>");
    ($('body')).append(cpDialog);
    cpDialog.osDialog();
    ($('.edit-widget .popup')).osPopup({
      dialog: cpDialog,
      modal: true,
      keepindom: true
    });
    ($('#apps .popup')).osPopup({
      dialog: cpDialog,
      modal: true,
      keepindom: true
    });
    ($('.inline-docs-widget')).osPopup({
      dialog: cpDialog
    });
    ($('.domain-widget')).osData({
      event: 'domain_form_return',
      onEvent: function(event) {
        ($('.error', cpDialog)).remove();
        if (event.osEventStatus === 'success') {
          ($('.current', this)).text(event.osEventData.namespace);
          ($('.popup', this)).osPopup('unpop');
          ($('#ssh_form_express_domain_namespace')).val(event.osEventData.namespace);
          if (event.osEventData.action === 'create') {
            ($('#express_domain_dom_action')).val('update');
            ($('.ssh-form', '#ssh_container')).show();
            ($('.ssh-placeholder', '#ssh_container')).remove();
            ($('.app-form', '#app_form_container')).show();
            return ($('.app-placeholder', '#app_form_container')).hide();
          } else {
            ($('#app_list_container')).spin();
            return $.get('/app/control_panel/apps', {}, function(resp) {
              ($('#app_list_container')).html(resp);
              return ($('#apps .popup')).osPopup({
                dialog: cpDialog,
                modal: true,
                keepindom: true
              });
            });
          }
        } else {
          return ($('.os-dialog-container', cpDialog)).prepend("<div class=\"error message\">\n  " + event.osEventData + "\n</div>");
        }
      }
    });
    ($('#ssh_container')).osData({
      event: 'ssh_key_form_return',
      onEvent: function(event) {
        var err_msg, ssh;
        ($('.error', cpDialog)).remove();
        if (event.osEventStatus === 'success') {
          ($('.popup', this)).osPopup('unpop');
          ssh = event.osEventData.ssh;
          if (ssh) {
            $('#express_domain_ssh').val(ssh);
          }
          $('#ssh_container').html(event.osEventData.key_html);
          return ($('#ssh_container .popup')).osPopup({
            dialog: cpDialog,
            modal: true,
            keepindom: true
          });
        } else {
          err_msg = event.osEventData;
          err_msg = err_msg.replace(/([^\s]{20})[^\s]+/g, '$1...');
          err_msg = err_msg.replace(/>/g, '&gt;').replace(/</g, '&lt;');
          return ($('.os-dialog-container', cpDialog)).prepend("<div class=\"error message\">\n  " + err_msg + "\n</div>");
        }
      }
    });
    ($('#apps')).osData({
      event: 'app_form_return',
      onEvent: function(event) {
        var el, msg, op;
        ($('.message.error', this)).remove();
        ($('.message.error', cpDialog)).remove();
        if (event.osEventStatus === 'success') {
          ($('#app_list_container')).html(event.osEventData.app_table);
          ($('.popup', this)).osPopup({
            dialog: cpDialog,
            modal: true
          });
          cpDialog.osDialog('hide');
          if (event.osEventData.app_limit_reached) {
            ($('.app-form', this)).hide();
            return ($('.app-placeholder', this)).show().text('You have reached your limit of free apps.');
          } else {
            ($('.app-form', this)).show();
            return ($('.app-placeholder', this)).hide();
          }
        } else {
          msg = event.osEventData.message;
          op = event.osEventData.operation || 'create';
          if ('destroy' === op) {
            el = $('header', cpDialog);
          } else {
            el = $('#new_express_app', this);
          }
          return el.before("<div class=\"error message\">\n  " + msg + "\n</div>");
        }
      }
    });
    ($('body')).delegate('form', 'ajax:beforeSend', function(event) {
      return ($(this)).spin();
    });
    return ($('body')).delegate('form', 'ajax:complete', function(event) {
      return ($(this)).spin(false);
    });
  });
}).call(this);
