$ = jQuery
_this = this
_this.subscribers or= {}

class osDialog
  constructor: (@options, @element) -> 
    # cache element jq object
    @$element = $ @element
    # cache window and document jq elements
    @$window = $ window
    @$document = $ document 
    # merge options with defaults
    defaults = modal: false, top: false
    @options = $.extend {}, defaults, @options
    @name = 'OpenShiftDialog'
    @_init()
  
  # Required creation function
  # runs the first time this plugin is called
  _create: ->
  
  # Required init function
  # runs when instance is first created
  # and whenever it is reinitialized
  _init: ->

    @$overlay = $ '#overlay'
    
    # create modal overlay if needed
    if @$overlay.length == 0
      ($ 'body').append """
        <div id="overlay"></div>
      """
      @$overlay = $ '#overlay'

    # create close link
    @$closeLink = $ """
      <a href="#" class="os-close-link">Close</a>
    """
    @$element.prepend @$closeLink
    
    # create container
    @$container = $ """
      <div class="os-dialog-container"></div>
    """
    @$element.append @$container

    # make sure dialog element has needed classes
    unless @$element.hasClass 'os-widget'
      @$element.addClass 'os-widget'
    unless @$element.hasClass 'os-dialog'
      @$element.addClass 'os-dialog'
    
    # get top property as offset
    # t = @$element.css 'top'
    # @topOffset = parseInt t.split('px')[0]
    # @maxHeight = @$element.css 'max-height'

    # bind close link
    @$closeLink.click @hide
  
  # Required
  # get or set options after initialization
  option: (key, value) ->
    
    # signature $('#foo').bar({key: value})
    if $.isPlainObject key
      @options = $.extend true, @options, key
  
    # signature $('#foo').option('key')
    else if key and value? 
      @options[key] = value

    # signature $('#foo').bar('option', 'baz', 'bat')
    else
      return @options[key]

    return this

  # calculate top for dialog
  _positionDialog: ->
    if @options.top
      @$element.css 'top', @options.top

  show: =>
    @_positionDialog()
    # show overlay if modal
    if @options.modal
      @$overlay.show()
    @$element.show()

  hide: (event) =>
    if event?
      event.preventDefault()
    @$overlay.hide()
    @$element.hide()
    ($ '.message.error', @$element).remove()
  
  setText: (text) =>
    @$container.text text
    this

  setHtml: (html) =>
    @$container.html html
    this

  insert: (contents) =>
    @$container.children().detach()
    @$container.append contents
    this

# Connect widgets to jquery via bridge
# http://erichynds.com/jquery/using-jquery-ui-widget-factory-bridge/
$.widget.bridge 'osDialog', osDialog

class osPopup
  constructor: (@options, @element) -> 
    # cache jq object
    @$element = $ @element
    # merge options with defaults
    defaults = modal: false, top: false, keepindom: false
    @options = $.extend {}, defaults, @options
    @name = 'OpenShiftPopup'
    @_init()
  
  # Required creation function
  # runs the first time this plugin is called
  _create: ->

  # Required init function
  # runs when first instance is
  # created or reinitialized
  _init: ->

    # set classes if needed
    unless @$element.hasClass 'os-widget'
      @$element.addClass 'os-widget'
    unless @$element.hasClass 'os-popup'
      @$element.addClass 'os-popup'

    # get component elements 
    @trigger = $ '.popup-trigger', @$element
    @trigger.addClass 'js'

    @content = $ '.popup-content', @$element
    @content.addClass 'js'
    
    
    if not @options.dialog
      # create new dialog
      @options.dialog = $ '<div class="popup-dialog"></div>'
      ($ 'body').append @options.dialog
      @options.dialog.osDialog(modal: @options.modal)

    if @options.keepindom
      @_saveSetup()
    
    # event binding
    @trigger.click @pop

  # Required
  # get or set options after initialization
  option: (key, value) ->
    
    # signature $('#foo').bar({key: value})
    if $.isPlainObject key
      @options = $.extend true, @options, key
  
    # signature $('#foo').option('key')
    else if key and value? 
      @options[key] = value

    # signature $('#foo').bar('option', 'baz', 'bat')
    else
      return @options[key]

    if @options.keepindom
      @_saveSetup()
    return this

  _saveSetup: ->
    # set up placeholder for contents when hidden
    unless @placeholder
      @placeholder = $ '<div class="popup-placeholder" style="display:none"></div>'
      ($ 'body').append @placeholder
    # add to dialog close button behavior
    @options.dialog.data('osDialog').$closeLink.click @unpop

  pop: (event) =>
    if event?
      event.preventDefault()
    dTop = if @options.top then @options.top else @trigger.offset().top
    opts =
      top:
        dTop
      modal:
        @options.modal

    dialog = @options.dialog.osDialog('option', opts).osDialog('insert', @content)

    # reposition dialog if it flows out of view
    dHeight = dialog.outerHeight()
    dBottom = dTop + dHeight

    docViewTop = $(window).scrollTop()
    docViewBottom = docViewTop + $(window).height()

    # raise popup so bottom is resting on document viewport bottom if needed
    if dBottom > docViewBottom
      dTop = docViewBottom - dHeight

    # recorrect if the top is above the document viewport
    if dTop < docViewTop
      dTop = docViewTop

    # reflow if pos needs changing
    if opts.top != dTop
      opts.top = dTop
      dialog = dialog.osDialog('option', opts)

    dialog.osDialog 'show'

  unpop: (event) =>
    if event?
      event.preventDefault()
    @options.dialog.osDialog 'hide'
    # save contents to placeholder
    @placeholder.append @content

# Connect widgets to jquery via bridge
# http://erichynds.com/jquery/using-jquery-ui-widget-factory-bridge/
$.widget.bridge 'osPopup', osPopup

# Data widget listens for an event and publishes
# data associated with the event
class osData
  constructor: (@options, @element) ->
    # cache jq object
    @$element = $ @element
    defaults = event: false, onEvent: false
    @options = $.extend defaults, @options
    @name = 'OpenShiftData'
    @_init()

  _create: ->

  _init: ->
    if @options.event
      @subscribe()

  option: (key, value) ->
    if $.isPlainObject key
      @options = $.extend true, @options, key
    else if key and value?
      @options[key] = value
    else
      return @options[key]

    #resubscribe if options have changed
    @subscribe()
    return this
  
  subscribe: =>
    if @options.event
      # add to subscribers list
      _this.subscribers[@options.event] or= []
      _this.subscribers[@options.event].push @$element

      # bind event to element
      @$element.bind @options.event, @eventResponse

  eventResponse: (event) =>
    if event?
      event.preventDefault()
    #update element with new data
    # if event.osEventData
      # unless $.isPlainObject event.osEventData
        # @$element.html event.osEventData
    #run callback with element context if given
    if @options.onEvent
      @options.onEvent.call(@element, event)

# Connect widgets to jquery via bridge
# http://erichynds.com/jquery/using-jquery-ui-widget-factory-bridge/
$.widget.bridge 'osData', osData

# Publishes events and related data based on ajax responses
osDataEmitter = (event, xhr, status) ->
  json = $.parseJSON xhr.responseText
  if json.event
    e = jQuery.Event json.event, { osEventData: json.data, osEventStatus: json.status }
    subs = _this.subscribers[json.event]
    if subs
      for elem in subs
        elem.trigger e

# bind data emitter
$('body').bind 'ajax:complete', osDataEmitter
