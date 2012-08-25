$(document).ready(function() {
  $('.kb-title a').click(function (e) {
    e.preventDefault();
    var toggleID = $(this).parents('div.kb-title').attr('id');
    toggleID = toggleID.replace('kb-title-', '');
    $('#kb-toggle-'+toggleID).slideToggle(300);
  });
});