/* DO NOT MODIFY. This file was compiled Wed, 22 Aug 2012 22:11:07 GMT from
 * /builddir/build/BUILD/rhc-site-0.97.12/app/coffeescripts/twitter.branding.coffee
 */

(function() {
  /* Scripts for twitter integration */
  var $;
  $ = jQuery;
  this.latestTweet = function(successCallback, errorCallback) {
    return $.ajax({
      url: "/app/twitter_latest_tweet",
      dataType: 'json',
      timeout: 10000,
      async: true,
      success: successCallback,
      error: errorCallback
    });
  };
  this.latestRetweets = function(successCallback, errorCallback) {
    return $.ajax({
      url: "/app/twitter_latest_retweets",
      dataType: 'json',
      timeout: 10000,
      async: true,
      success: successCallback,
      error: errorCallback
    });
  };
  this.renderTweet = function(tweet, include_image) {
    var avatar, begin, end, entities, entity, i, index_adjustment, indices, link, tag, tweetText, user, _i, _j, _k, _l, _len, _len2, _len3, _len4, _ref, _ref2, _ref3, _ref4, _ref5, _ref6;
    if (include_image == null) {
      include_image = true;
    }
    entities = {};
    indices = [];
    _ref = tweet.entities.urls;
    for (_i = 0, _len = _ref.length; _i < _len; _i++) {
      link = _ref[_i];
      link.replacement = "<a href=\"" + ((_ref2 = link.expanded_url) != null ? _ref2 : link.url) + "\" title=\"" + ((_ref3 = link.display_url) != null ? _ref3 : link.url) + "\" target=\"_blank\">" + ((_ref4 = link.display_url) != null ? _ref4 : link.url) + "</a>";
      entities[link.indices[0]] = link;
      indices.push(link.indices[0]);
    }
    _ref5 = tweet.entities.user_mentions;
    for (_j = 0, _len2 = _ref5.length; _j < _len2; _j++) {
      user = _ref5[_j];
      user.replacement = "<a href=\"http://twitter.com/#!/" + user.screen_name + "\" title=\"" + user.name + "\" target=\"_blank\">\n    @" + user.screen_name + "\n  </a>";
      entities[user.indices[0]] = user;
      indices.push(user.indices[0]);
    }
    _ref6 = tweet.entities.hashtags;
    for (_k = 0, _len3 = _ref6.length; _k < _len3; _k++) {
      tag = _ref6[_k];
      tag.replacement = "<a href=\"http://twitter.com/#!/search?q=%23" + tag.text + "\" target=\"_blank\">#" + tag.text + "</a>";
      entities[tag.indices[0]] = tag;
      indices.push(tag.indices[0]);
    }
    indices.sort(function(a, b) {
      return a - b;
    });
    index_adjustment = 0;
    tweetText = tweet.text;
    for (_l = 0, _len4 = indices.length; _l < _len4; _l++) {
      i = indices[_l];
      entity = entities[i];
      begin = entity.indices[0] + index_adjustment;
      end = entity.indices[1] + index_adjustment;
      tweetText = tweetText.substringReplace(begin, end, entity.replacement);
      index_adjustment += entity.replacement.length + entity.indices[0] - entity.indices[1];
    }
    if (include_image) {
      avatar = "<img src='" + tweet.user.profile_image_url_https + "'>";
    } else {
      avatar = '';
    }
    return "<div class=\"tweet\">\n  " + avatar + "\n  <p>\n    " + tweetText + "\n  </p>\n  <small>" + tweet.user.name + "</small>\n</div>";
  };
  String.prototype.substringReplace = function(begin, end, replace) {
    if (((0 < begin && begin < end) && end < this.length)) {
      return (this.slice(0, begin)) + replace + (this.slice(end));
    } else if ((0 < begin && begin < end)) {
      return (this.slice(0, begin)) + replace;
    } else if ((begin < end && end < this.length)) {
      return replace + (this.slice(end));
    } else if (begin < end) {
      return replace;
    } else {
      return this;
    }
  };
}).call(this);
