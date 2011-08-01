$(function() {
  var edit_button, form_container, form_replacement, setup_update_form, toggle_update_form, update_form, update_values;
  form_container = $('#domain_form');
  update_form = $('form.update');
  form_replacement = '';
  edit_button = $('#edit_domain');
  setup_update_form = function() {
    var namespace, ssh;
    namespace = ($('#express_domain_namespace')).val();
    ssh = (($('#express_domain_ssh')).val().slice(0, 20)) + '...';
    form_container.append("<dl id=\"form_replacement\">\n  <dt>Your namespace:</dt>\n  <dd id=\"show_namespace\">" + namespace + "</dd>\n  <dt>Your ssh key:</dt>\n  <dd id=\"show_ssh\">" + ssh + "</dd>\n  <a class=\"button\" id=\"edit_domain\">Edit</a>\n</dl>\n");
    form_replacement = $('#form_replacement');
    if (update_form.hasClass('hidden')) {
      return update_form.hide();
    } else {
      return form_replacement.hide();
    }
  };
  if (update_form.length > 0) {
    setup_update_form();
  }
  update_values = function() {
    var namespace, ssh;
    namespace = ($('#express_domain_namespace')).val();
    ssh = (($('#express_domain_ssh')).val().slice(0, 20)) + '...';
    ($('#show_namespace')).text(namespace);
    return ($('#show_ssh')).text(ssh);
  };
  toggle_update_form = function() {
    if (update_form.hasClass('hidden')) {
      update_form.removeClass('hidden');
      update_form.show();
      return form_replacement.hide();
    } else {
      update_values();
      update_form.addClass('hidden');
      update_form.hide();
      return form_replacement.show();
    }
  };
  update_form.live('switch_create_to_update', setup_update_form);
  update_form.live('successful_submission', toggle_update_form);
  return edit_button.live('click', toggle_update_form);
});