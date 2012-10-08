/* DO NOT MODIFY. This file was compiled Wed, 22 Aug 2012 22:11:05 GMT from
 * /builddir/build/BUILD/rhc-site-0.97.12/app/coffeescripts/widgets.coffee
 */

(function() {
  var $, osData, osDataEmitter, osDialog, osPopup, _this;
  var __bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; };
  $ = jQuery;
  _this = this;
  _this.subscribers || (_this.subscribers = {});
  osDialog = (function() {
    function osDialog(options, element) {
      var defaults;
      this.options = options;
      this.element = element;
      this.insert = __bind(this.insert, this);
      this.setHtml = __bind(this.setHtml, this);
      this.setText = __bind(this.setText, this);
      this.hide = __bind(this.hide, this);
      this.show = __bind(this.show, this);
      this.$element = $(this.element);
      this.$window = $(window);
      this.$document = $(document);
      defaults = {
        modal: false,
        top: false
      };
      this.options = $.extend({}, defaults, this.options);
      this.name = 'OpenShiftDialog';
      this._init();
    }
    osDialog.prototype._create = function() {};
    osDialog.prototype._init = function() {
      this.$overlay = $('#overlay');
      if (this.$overlay.length === 0) {
        ($('body')).append("<div id=\"overlay\"></div>");
        this.$overlay = $('#overlay');
      }
      this.$closeLink = $("<a href=\"#\" class=\"os-close-link\">Close</a>");
      this.$element.prepend(this.$closeLink);
      this.$container = $("<div class=\"os-dialog-container\"></div>");
      this.$element.append(this.$container);
      if (!this.$element.hasClass('os-widget')) {
        this.$element.addClass('os-widget');
      }
      if (!this.$element.hasClass('os-dialog')) {
        this.$element.addClass('os-dialog');
      }
      return this.$closeLink.click(this.hide);
    };
    osDialog.prototype.option = function(key, value) {
      if ($.isPlainObject(key)) {
        this.options = $.extend(true, this.options, key);
      } else if (key && (value != null)) {
        this.options[key] = value;
      } else {
        return this.options[key];
      }
      return this;
    };
    osDialog.prototype._positionDialog = function() {
      if (this.options.top) {
        return this.$element.css('top', this.options.top);
      }
    };
    osDialog.prototype.show = function() {
      this._positionDialog();
      if (this.options.modal) {
        this.$overlay.show();
      }
      return this.$element.show();
    };
    osDialog.prototype.hide = function(event) {
      if (event != null) {
        event.preventDefault();
      }
      this.$overlay.hide();
      this.$element.hide();
      return ($('.message.error', this.$element)).remove();
    };
    osDialog.prototype.setText = function(text) {
      this.$container.text(text);
      return this;
    };
    osDialog.prototype.setHtml = function(html) {
      this.$container.html(html);
      return this;
    };
    osDialog.prototype.insert = function(contents) {
      this.$container.children().detach();
      this.$container.append(contents);
      return this;
    };
    return osDialog;
  })();
  $.widget.bridge('osDialog', osDialog);
  osPopup = (function() {
    function osPopup(options, element) {
      var defaults;
      this.options = options;
      this.element = element;
      this.unpop = __bind(this.unpop, this);
      this.pop = __bind(this.pop, this);
      this.$element = $(this.element);
      defaults = {
        modal: false,
        top: false,
        keepindom: false
      };
      this.options = $.extend({}, defaults, this.options);
      this.name = 'OpenShiftPopup';
      this._init();
    }
    osPopup.prototype._create = function() {};
    osPopup.prototype._init = function() {
      if (!this.$element.hasClass('os-widget')) {
        this.$element.addClass('os-widget');
      }
      if (!this.$element.hasClass('os-popup')) {
        this.$element.addClass('os-popup');
      }
      this.trigger = $('.popup-trigger', this.$element);
      this.trigger.addClass('js');
      this.content = $('.popup-content', this.$element);
      this.content.addClass('js');
      if (!this.options.dialog) {
        this.options.dialog = $('<div class="popup-dialog"></div>');
        ($('body')).append(this.options.dialog);
        this.options.dialog.osDialog({
          modal: this.options.modal
        });
      }
      if (this.options.keepindom) {
        this._saveSetup();
      }
      return this.trigger.click(this.pop);
    };
    osPopup.prototype.option = function(key, value) {
      if ($.isPlainObject(key)) {
        this.options = $.extend(true, this.options, key);
      } else if (key && (value != null)) {
        this.options[key] = value;
      } else {
        return this.options[key];
      }
      if (this.options.keepindom) {
        this._saveSetup();
      }
      return this;
    };
    osPopup.prototype._saveSetup = function() {
      if (!this.placeholder) {
        this.placeholder = $('<div class="popup-placeholder" style="display:none"></div>');
        ($('body')).append(this.placeholder);
      }
      return this.options.dialog.data('osDialog').$closeLink.click(this.unpop);
    };
    osPopup.prototype.pop = function(event) {
      var dBottom, dHeight, dTop, dialog, docViewBottom, docViewTop, opts;
      if (event != null) {
        event.preventDefault();
      }
      dTop = this.options.top ? this.options.top : this.trigger.offset().top;
      opts = {
        top: dTop,
        modal: this.options.modal
      };
      dialog = this.options.dialog.osDialog('option', opts).osDialog('insert', this.content);
      dHeight = dialog.outerHeight();
      dBottom = dTop + dHeight;
      docViewTop = $(window).scrollTop();
      docViewBottom = docViewTop + $(window).height();
      if (dBottom > docViewBottom) {
        dTop = docViewBottom - dHeight;
      }
      if (dTop < docViewTop) {
        dTop = docViewTop;
      }
      if (opts.top !== dTop) {
        opts.top = dTop;
        dialog = dialog.osDialog('option', opts);
      }
      return dialog.osDialog('show');
    };
    osPopup.prototype.unpop = function(event) {
      if (event != null) {
        event.preventDefault();
      }
      this.options.dialog.osDialog('hide');
      return this.placeholder.append(this.content);
    };
    return osPopup;
  })();
  $.widget.bridge('osPopup', osPopup);
  osData = (function() {
    function osData(options, element) {
      var defaults;
      this.options = options;
      this.element = element;
      this.eventResponse = __bind(this.eventResponse, this);
      this.subscribe = __bind(this.subscribe, this);
      this.$element = $(this.element);
      defaults = {
        event: false,
        onEvent: false
      };
      this.options = $.extend(defaults, this.options);
      this.name = 'OpenShiftData';
      this._init();
    }
    osData.prototype._create = function() {};
    osData.prototype._init = function() {
      if (this.options.event) {
        return this.subscribe();
      }
    };
    osData.prototype.option = function(key, value) {
      if ($.isPlainObject(key)) {
        this.options = $.extend(true, this.options, key);
      } else if (key && (value != null)) {
        this.options[key] = value;
      } else {
        return this.options[key];
      }
      this.subscribe();
      return this;
    };
    osData.prototype.subscribe = function() {
      var _base, _name;
      if (this.options.event) {
        (_base = _this.subscribers)[_name = this.options.event] || (_base[_name] = []);
        _this.subscribers[this.options.event].push(this.$element);
        return this.$element.bind(this.options.event, this.eventResponse);
      }
    };
    osData.prototype.eventResponse = function(event) {
      if (event != null) {
        event.preventDefault();
      }
      if (this.options.onEvent) {
        return this.options.onEvent.call(this.element, event);
      }
    };
    return osData;
  })();
  $.widget.bridge('osData', osData);
  osDataEmitter = function(event, xhr, status) {
    var e, elem, json, subs, _i, _len, _results;
    json = $.parseJSON(xhr.responseText);
    if (json.event) {
      e = jQuery.Event(json.event, {
        osEventData: json.data,
        osEventStatus: json.status
      });
      subs = _this.subscribers[json.event];
      if (subs) {
        _results = [];
        for (_i = 0, _len = subs.length; _i < _len; _i++) {
          elem = subs[_i];
          _results.push(elem.trigger(e));
        }
        return _results;
      }
    }
  };
  $('body').bind('ajax:complete', osDataEmitter);
}).call(this);
