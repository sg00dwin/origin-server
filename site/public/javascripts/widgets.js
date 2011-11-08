/* DO NOT MODIFY. This file was compiled Tue, 25 Oct 2011 20:22:36 GMT from
 * /home/emily/Devel/libra/li/site/app/coffeescripts/widgets.coffee
 */

(function() {
  var $, _this;
  $ = jQuery;
  _this = this;
  _this.OpenShiftWidgets || (_this.OpenShiftWidgets = {});
  _this.OpenShiftWidgets.Dialog = (function() {
    var contents_selector, dialog, dialog_contents, dialog_html, dialog_selector, overlay, overlay_html, overlay_selector;
    dialog_selector = '.dialog.widget';
    contents_selector = '.dialog-contents';
    dialog_html = "<div class=\"widget dialog\">\n  <a href=\"#\" class=\"close_btn\" title=\"Close dialog\">Close</a>\n  <div class=\"dialog-contents\"></div>\n</div>";
    dialog = $(dialog_selector);
    dialog_contents = $(contents_selector);
    overlay_selector = '.overlay';
    overlay_html = "<div class=\"overlay\"></div>";
    overlay = $(overlay_selector);
    return {
      get: function() {
        if (dialog.length === 0) {
          ($('body')).append(dialog_html);
          dialog = $(dialog_selector);
          dialog_contents = $(contents_selector);
        }
        return dialog;
      },
      setText: function(text) {
        return dialog_contents.text(text);
      },
      setHtml: function(html) {
        return dialog_contents.html(html);
      },
      open: function() {
        return get().show();
      },
      openModal: function() {
        if (overlay.length === 0) {
          ($('body')).append(overlay_html);
          overlay = $(overlay_selector);
        }
        overlay.show();
        return get().show();
      }
    };
  })();
  _this.OpenShiftWidgets.InlineDocs = (function() {
    function _Class(elem) {
      var docs, link;
      this.elem = elem;
      docs = this.elem.children('#docs');
      if (docs.length > 0) {
        this.docs = docs.html();
      }
      link = this.elem.children;
    }
    _Class.prototype.showDocs = function() {};
    return _Class;
  })();
}).call(this);
