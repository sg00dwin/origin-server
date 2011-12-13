### Scripts for the product pages ###

$ = jQuery
_this = this

#success callback for retweets
retweetSuccess = (data, textStatus, jqXHR) ->
  rts = $ '#retweets'
  rts.empty()
  list = $ '<ul></ul>'
  rts.append list
  for rt in data
    item = $ '<li></li>'
    item.append $ _this.renderTweet rt.retweeted_status
    list.append item

retweetError = (jqHXR, textStatus, errorThrown) ->
  ($ '#retweets').hide()
  log "Error getting retweets: #{}"
  
$ ->
  if ($ '#retweets').length > 0
    latestRetweets retweetSuccess,
    
  # correct too long user box as long as there's no error
  overview = $ '#product_overview'
  if overview.hasClass 'prev_login'
    # add no-error on page load as long as there is no error
    unless ($ '.message', overview).length > 0
      overview.addClass 'no_error'
    # check for errors when ajax is finished
    overview.bind 'ajax:complete', (xhr, status)->
      unless status.status == 200
        overview.removeClass 'no_error'
        