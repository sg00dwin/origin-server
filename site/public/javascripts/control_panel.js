/* DO NOT MODIFY. This file was compiled Thu, 12 Jan 2012 00:01:30 GMT from
 * /home/aboone/Source/li/site/app/coffeescripts/control_panel.coffee
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
    ($('.ssh-widget')).osData({
      event: 'ssh_form_return',
      onEvent: function(event) {
        var err_msg;
        ($('.error', cpDialog)).remove();
        if (event.osEventStatus === 'success') {
          ($('.current', this)).text(shorten(event.osEventData.ssh, 20));
          ($('.popup', this)).osPopup('unpop');
          $('#ssh_form_express_domain_ssh').val(event.osEventData.ssh);
          return $('#express_domain_ssh').val(event.osEventData.ssh);
        } else {
          err_msg = event.osEventData;
          err_msg = err_msg.replace(/([^\s]{30})[^\s]+/g, '$1...');
          err_msg = err_msg.replace(/>/g, '&gt;').replace(/</g, '&lt;');
          return ($('.os-dialog-container', cpDialog)).prepend("<div class=\"error message\">\n  " + err_msg + "\n</div>");
        }
      }
    });
    ($('#apps')).osData({
      event: 'app_form_return',
      onEvent: function(event) {
        ($('.error', this)).remove();
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
          return ($('#new_express_app', this)).before("<div class=\"error message\">\n  " + event.osEventData + "\n</div>");
        }
      }
    });
    ($('body')).delegate('form', 'ajax:beforeSend', function(event) {
      return ($(this)).spin();
    });
    ($('body')).delegate('form', 'ajax:complete', function(event) {
      return ($(this)).spin(false);
    });
    if ($('#ssh_form_express_domain_ssh').val().match(/nossh$/)) {
      return $('#ssh_form_express_domain_ssh').val('');
    }
  });
}).call(this);
