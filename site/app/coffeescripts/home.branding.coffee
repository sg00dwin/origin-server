### Home page scripts ###
$ = jQuery
_this = this

# success callback for latest tweet
latestSuccess = (data, textStatus, jqXHR) ->
  rts = $ '#buzz-twitter-2' #remove after page is simplified
  for tweet in data.slice(0,4)
    rts.append $ (_this.renderTweet tweet, false)
  #if data.length > 0
  #  tweet = data[0]
    # ($ '#buzz-twitter').replaceWith $ (_this.renderTweet tweet, false)

# error callback for latest tweet
latestError = (jqXHR, textStatus, errorThrown) ->
  ($ '#buzz-twitter').hide()

#success callback for retweets
retweetSuccess = (data, textStatus, jqXHR) ->
  rts = $ '#buzz-twitter'
  for rt in data
    rts.append $ _this.renderTweet rt.retweeted_status

retweetError = (jqHXR, textStatus, errorThrown) ->
  ($ '#buzz-twitter').hide()

# when document is ready
$ ->

  # Get latest tweet
  _this.latestTweet latestSuccess, latestError
  # Get retweets
  _this.latestRetweets retweetSuccess, retweetError
