Drupal.CTools.Modal.show = function() {
  var resize = function(e) {
    // For reasons I do not understand, when creating the modal the context must be
    // Drupal.CTools.Modal.modal but otherwise the context must be more than that.
    var context = e ? document : Drupal.CTools.Modal.modal;
    $('table.ctools-modal-content', context).css({
      'width': $(window).width() * .7 + 'px',
      'height': $(window).height() * .6 + 'px'
    });
    $('table.ctools-modal-content .modal-content', context).css({
      'width': ($(window).width() * .7 - 53) + 'px',
      'height': ($(window).height() * .6 - 65) + 'px'
    });
  }

  if (!Drupal.CTools.Modal.modal) {
    Drupal.CTools.Modal.modal = $(Drupal.theme('CToolsModalDialog'));
    $(window).bind('resize', resize);
  }

  resize();
  $('span.modal-title', Drupal.CTools.Modal.modal).html(Drupal.t('Loading...'));
  var opts = {
    // @todo this should be elsewhere.
    opacity: Drupal.settings.CToolsModal.backDropOpacity,
    background: Drupal.settings.CToolsModal.backDropColor
  };

  Drupal.CTools.Modal.modalContent(Drupal.CTools.Modal.modal, opts);
  $('#modalContent .modal-content').html(Drupal.theme('CToolsModalThrobber'));
};

/**
* Provide the HTML to create the modal dialog.
*/
Drupal.theme.prototype.CToolsModalDialog = function () {
var html = ''

html += '<div id="ctools-modal" class ="popups-box">';
html += '  <table class="ctools-modal-content" cellpadding="0" cellspacing="0">';
html += '    <tr>';
html += '      <td class="popups-tl popups-border"></td>';
html += '      <td class="popups-t popups-border"></td>';
html += '      <td class="popups-tr popups-border"></td>';
html += '    </tr>';
html += '    <tr>';
html += '      <td class="popups-cl popups-border"></td>';
html += '      <td class="popups-c" valign="top">';
html += '        <div class="popups-container">';
html += '          <div class="modal-header popups-title">';
html += '            <span id="modal-title" class="modal-title"></span>';
html += '            <div class="popups-close"><a class="close" href="#">' + Drupal.settings.CToolsModal.closeText + '</a></div>';
html += '            <div class="clear-block"></div>';
html += '          </div>';
html += '          <div id="modal-content" class="modal-content popups-body"></div>';
html += '          <div class="popups-buttons"></div>'; //Maybe someday add the option for some specific buttons.
html += '          <div class="popups-footer"></div>'; //Maybe someday add some footer.
html += '        </div>';
html += '      </td>';
html += '      <td class="popups-cr popups-border"></td>';
html += '    </tr>';
html += '    <tr>';
html += '      <td class="popups-bl popups-border"></td>';
html += '      <td class="popups-b popups-border"></td>';
html += '      <td class="popups-br popups-border"></td>';
html += '    </tr>';
html += '  </table>';
html += '</div>';

return html;

}