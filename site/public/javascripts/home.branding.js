
/* Home page scripts
*/

(function() {
  var $, latestError, latestSuccess, retweetError, retweetSuccess, _this;

  $ = jQuery;

  _this = this;

  latestSuccess = function(data, textStatus, jqXHR) {
    var tweet;
    if (data.length > 0) return tweet = data[0];
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
