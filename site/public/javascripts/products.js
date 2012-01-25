/* DO NOT MODIFY. This file was compiled Wed, 25 Jan 2012 15:49:29 GMT from
 * /home/clayton/code/li/site/app/coffeescripts/products.coffee
 */

(function() {
  /* Scripts for the product pages */
  var $, retweetError, retweetSuccess, _this;
  $ = jQuery;
  _this = this;
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
    ($('#retweets')).hide();
    return log("Error getting retweets: ");
  };
  $(function() {
    var overview;
    if (($('#retweets')).length > 0) {
      latestRetweets(retweetSuccess);
    }
    overview = $('#product_overview');
    if (overview.hasClass('prev_login')) {
      if (!(($('.message', overview)).length > 0)) {
        overview.addClass('no_error');
      }
      return overview.bind('ajax:complete', function(xhr, status) {
        if (status.status !== 200) {
          return overview.removeClass('no_error');
        }
      });
    }
  });
}).call(this);
