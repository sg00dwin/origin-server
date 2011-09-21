### Home page scripts ###
$ = jQuery
_this = this

# success callback for latest tweet
latestSuccess = (data, textStatus, jqXHR) ->
  if data.length > 0
    tweet = data[0]
    ($ '#latest p.tweet').replaceWith $ (_this.renderTweet tweet, false)

# error callback for latest tweet
latestError = (jqXHR, textStatus, errorThrown) ->
  ($ '#latest').hide()
  log "Error getting latest tweet: #{errorThrown}"

#success callback for retweets
retweetSuccess = (data, textStatus, jqXHR) ->
  rts = $ '#retweets'
  rts.empty()
  list = $ '<ul></ul>'
  console.log 'list', list
  rts.append list
  for rt in data
    item = $ '<li></li>'
    console.log 'item', item
    item.append $ _this.renderTweet rt.retweeted_status
    list.append item

retweetError = (jqHXR, textStatus, errorThrown) ->
  ($ '#retweets').hide()
  log "Error getting retweets: #{}"

# when document is ready
$ ->

  # Get latest tweet
  _this.latestTweet latestSuccess, latestError
  # Get retweets
  _this.latestRetweets retweetSuccess, retweetError