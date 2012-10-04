/* DO NOT MODIFY. This file was compiled Wed, 22 Aug 2012 22:11:04 GMT from
 * /builddir/build/BUILD/rhc-site-0.97.12/app/coffeescripts/home.coffee
 */

(function() {
  /* Home page scripts */
  var $, latestError, latestSuccess, retweetError, retweetSuccess, _this;
  $ = jQuery;
  _this = this;
  latestSuccess = function(data, textStatus, jqXHR) {
    var tweet;
    if (data.length > 0) {
      tweet = data[0];
      return ($('#latest p.tweet')).replaceWith($(_this.renderTweet(tweet, false)));
    }
  };
  latestError = function(jqXHR, textStatus, errorThrown) {
    return ($('#latest')).hide();
  };
  retweetSuccess = function(data, textStatus, jqXHR) {
    var item, list, rt, rts, _i, _len, _results;
    rts = $('#retweets');
    rts.empty();
    list = $('<ul></ul>');
    rts.append(list);
    _results = [];
    for (_i = 0, _len = data.length; _i < _len; _i++) {
      rt = data[_i];
      item = $('<li></li>');
      item.append($(_this.renderTweet(rt.retweeted_status)));
      _results.push(list.append(item));
    }
    return _results;
  };
  retweetError = function(jqHXR, textStatus, errorThrown) {
    return ($('#retweets')).hide();
  };
  $(function() {
    _this.latestTweet(latestSuccess, latestError);
    return _this.latestRetweets(retweetSuccess, retweetError);
  });
}).call(this);
