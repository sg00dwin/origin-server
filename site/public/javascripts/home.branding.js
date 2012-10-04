/* DO NOT MODIFY. This file was compiled Wed, 22 Aug 2012 22:11:07 GMT from
 * /builddir/build/BUILD/rhc-site-0.97.12/app/coffeescripts/home.branding.coffee
 */

(function() {
  /* Home page scripts */
  var $, latestError, latestSuccess, retweetError, retweetSuccess, _this;
  $ = jQuery;
  _this = this;
  latestSuccess = function(data, textStatus, jqXHR) {
    var rts, tweet, _i, _len, _ref, _results;
    rts = $('#buzz-twitter-2');
    _ref = data.slice(0, 4);
    _results = [];
    for (_i = 0, _len = _ref.length; _i < _len; _i++) {
      tweet = _ref[_i];
      _results.push(rts.append($(_this.renderTweet(tweet, false))));
    }
    return _results;
  };
  latestError = function(jqXHR, textStatus, errorThrown) {
    return ($('#buzz-twitter')).hide();
  };
  retweetSuccess = function(data, textStatus, jqXHR) {
    var rt, rts, _i, _len, _results;
    rts = $('#buzz-twitter');
    _results = [];
    for (_i = 0, _len = data.length; _i < _len; _i++) {
      rt = data[_i];
      _results.push(rts.append($(_this.renderTweet(rt.retweeted_status))));
    }
    return _results;
  };
  retweetError = function(jqHXR, textStatus, errorThrown) {
    return ($('#buzz-twitter')).hide();
  };
  $(function() {
    _this.latestTweet(latestSuccess, latestError);
    return _this.latestRetweets(retweetSuccess, retweetError);
  });
}).call(this);
