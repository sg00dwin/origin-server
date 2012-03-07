### Scripts for twitter integration ###

$ = jQuery

# Get latest tweets
@latestTweet = (successCallback, errorCallback) ->
  $.ajax
    url: "/app/twitter_latest_tweet"
    dataType: 'json'
    timeout: 10000
    async: true
    success: successCallback
    error: errorCallback
    
@latestRetweets = (successCallback, errorCallback) ->
  $.ajax
    url: "/app/twitter_latest_retweets"
    dataType: 'json'
    timeout: 10000
    async: true
    success: successCallback
    error: errorCallback

@renderTweet = (tweet, include_image=true) ->
  #Add entities to text
  entities = {} # keep track of entities
  indices = [] # keep track of indices for ordering
  
  # replace urls
  for link in tweet.entities.urls
    # add replacement string to link
    
    link.replacement = """
      <a href="#{link.expanded_url ? link.url}" title="#{link.display_url ? link.url}" target="_blank">#{link.display_url ? link.url}</a>
      """
    # add link to entity object so that we can keep track of where it goes
    entities[link.indices[0]] = link
    # add beginning index to indices array for ordering later
    indices.push link.indices[0]
  
  # replace user mentions
  for user in tweet.entities.user_mentions
    # add replacement string to user
    user.replacement = """
    <a href="http://twitter.com/#!/#{user.screen_name}" title="#{user.name}" target="_blank">
        @#{user.screen_name}
      </a>
    """
    # add user to entity object so that we can keep track of where it goes
    entities[user.indices[0]] = user
    # add beginning index to indices array for ordering later
    indices.push user.indices[0]
    
  # replace hashtags
  for tag in tweet.entities.hashtags
    # add replacement string to tag
    tag.replacement = """
      <a href="http://twitter.com/#!/search?q=%23#{tag.text}" target="_blank">##{tag.text}</a>
    """
    # add tag to entity object so that we can keep track of where it goes
    entities[tag.indices[0]] = tag
    # add beginning index to indices array for ordering later
    indices.push tag.indices[0]
  
  # sort indices so we can replace in order
  indices.sort (a, b) ->
    a - b
  
  # do replacing
  index_adjustment = 0
  tweetText = tweet.text
  for i in indices
    entity = entities[i]
    begin = entity.indices[0] + index_adjustment
    end = entity.indices[1] + index_adjustment
    tweetText = tweetText.substringReplace begin, end, entity.replacement
    # adjust by difference between what was replaced and what's replacing it
    index_adjustment += entity.replacement.length + entity.indices[0] - entity.indices[1]

  
  # Render tweet
  if include_image
    avatar = """
      <img src='#{tweet.user.profile_image_url_https}'>
    """
  else
    avatar = ''
    
  """
    <div class="tweet">
      #{avatar}
      <p>
        #{tweetText}
      </p>
      <small>#{tweet.user.name}</small>
    </div>
  """

String::substringReplace = (begin, end, replace) ->
  if 0 < begin < end < this.length
    (this.slice 0, begin) + replace + (this.slice end)
  else if 0 < begin < end
    (this.slice 0, begin) + replace
  else if begin < end < this.length
    replace + (this.slice end)
  else if begin < end
    replace
  else
    this
