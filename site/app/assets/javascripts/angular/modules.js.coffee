
angular.module('openshift', []).config(['$provide', ($provide) ->

  $provide.factory('faq', ['$http', ($http) ->
    new FaqService($http)
  ])

])


# TEMP!
#.config(['$httpProvider', ($httpProvider) ->
#  delete $httpProvider.defaults.headers.common["X-Requested-With"]
#])
