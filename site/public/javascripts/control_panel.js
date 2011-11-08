(function() {
  var $;
  $ = jQuery;
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
            return ($('.ssh-placeholder', '#ssh_container')).remove();
          }
        } else {
          return ($('.os-dialog-container', cpDialog)).prepend("<div class=\"error message\">\n  " + event.osEventData + "\n</div>");
        }
      }
    });
    ($('.ssh-widget')).osData({
      event: 'ssh_form_return',
      onEvent: function(event) {
        ($('.error', cpDialog)).remove();
        if (event.osEventStatus === 'success') {
          ($('.current', this)).text(event.osEventData.ssh);
          ($('.popup', this)).osPopup('unpop');
          return $('#express_domain_ssh').val(event.osEventData.ssh);
        } else {
          return ($('.os-dialog-container', cpDialog)).prepend("<div class=\"error message\">\n  " + event.osEventData + "\n</div>");
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
            modal: true,
            keepindom: true
          });
          ($('.popup', this)).osPopup('unpop');
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
    ($('body')).delegate('form', 'submit', function(event) {
      return ($(this)).spin();
    });
    return ($('body')).delegate('form', 'ajax:complete', function(event) {
      return ($(this)).spin(false);
    });
  });
}).call(this);
