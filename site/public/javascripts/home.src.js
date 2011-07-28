// File: Front page javascripts

$(function() {

  $.ajax({
    url: location.protocol + "//api.twitter.com/1/statuses/user_timeline/openshift.json?count=1&include_entities=true",
    dataType: 'jsonp',
    timeout: 10000,
    async: true,
    success: function(data, textStatus, request) {
      tweet = data[0];
      var d = document; 
      var el = d.getElementById('latest_tweet');
      
      while (el.firstChild) {
        el.removeChild(el.firstChild);
      }
      render_tweet(d, el, tweet, 'openshift');
    },
    error: function(request, status, error) {
      var d = document; 
      var p = d.getElementById('latest_tweet');
      p.appendChild(d.createTextNode('Currently unavailable'))
    }
  });

  $.ajax({
    url: location.protocol + "//api.twitter.com/1/statuses/retweeted_by_user.json?screen_name=openshift&count=4&include_entities=true",
    dataType: 'jsonp',
    timeout: 10000,
    async: true,
    success: function(data, textStatus, request) {
      var d = document;
      var el = d.getElementById('retweets');
      
      while (el.firstChild) {
        el.removeChild(el.firstChild);
      }
      ul = d.createElement('ul');
      el.appendChild(ul);
      for (var i = 0; i < data.length; i++) {
        tweet = data[i]
        li = d.createElement('li');
        ul.appendChild(li);
        img = d.createElement('img');
          if (tweet.entities.user_mentions.length > 0) {
            img.setAttribute('src', location.protocol + '//api.twitter.com/1/users/profile_image?screen_name=' + tweet.entities.user_mentions[0].name);
          }
          else {
            img.setAttribute('src', location.protocol == 'http:' ? tweet.user.profile_image_url : tweet.user.profile_image_url_https);
          }
          img.setAttribute('class', 'avatar');
        li.appendChild(img);
        el = d.createElement('p');
          el.setAttribute('class', 'tweet');
        li.appendChild(el);
        render_tweet(d, el, tweet, tweet.user.screen_name);
      }
    },
    error: function(request, status, error) {
      console.log('Error fetching retweets: ' + status);
    }
  });
  
  function render_tweet(d, el, tweet, screen_name) {
    a = d.createElement('a');
      a.setAttribute('class', 'tweeter');
      a.setAttribute('href', location.protocol + '//twitter.com/#!/' + screen_name);
      a.appendChild(d.createTextNode('@' + screen_name))
    el.appendChild(a);
    el.appendChild(d.createTextNode(' '));
    var entities = {};
    var indices = []
    for (var i = 0; i < tweet.entities.urls.length; i++) {
      var url = tweet.entities.urls[i];
      entities[url.indices[0]] = url;
      indices.push(url.indices[0]);
    }
    for (var i = 0; i < tweet.entities.hashtags.length; i++) {
      var hashtag = tweet.entities.hashtags[i];
      entities[hashtag.indices[0]] = hashtag;
      indices.push(hashtag.indices[0]);
    }
    for (var i = 0; i < tweet.entities.user_mentions.length; i++) {
      var user_mention = tweet.entities.user_mentions[i];
      entities[user_mention.indices[0]] = user_mention;
      indices.push(user_mention.indices[0]);
    }
    indices.sort(function sortNumber(a,b) {
      return a - b;
    });
    if (indices.length > 0) {
      var pos = 0;
      for (var i = 0; i < indices.length; i++) {
        var entity = entities[indices[i]];
        if (pos < indices[i]) {
          el.appendChild(d.createTextNode(tweet.text.substring(pos, indices[i])));
        }
        pos = entity.indices[1]
        if (entity.url) {
          a = d.createElement('a');
            a.setAttribute('href', entity.url);
            a.appendChild(d.createTextNode(entity.url))
          el.appendChild(a);
        }
        if (entity.text) {
          a = d.createElement('a');
            a.setAttribute('href', location.protocol + '//twitter.com/#!/search?q=%23' + entity.text);
            a.appendChild(d.createTextNode('#' + entity.text))
          el.appendChild(a);
        }
        else if (entity.name) {
          a = d.createElement('a');
            a.setAttribute('class', 'tweeter');
            a.setAttribute('href', location.protocol + '//twitter.com/#!/' + entity.name);
            a.appendChild(d.createTextNode('@' + entity.name))
          el.appendChild(a);
        }
      }
      if (pos < tweet.text.length - 1) {
        el.appendChild(d.createTextNode(tweet.text.substring(pos, tweet.text.length)));
      }
    }
    else {
      el.appendChild(d.createTextNode(tweet.text))
    }
  }
});
