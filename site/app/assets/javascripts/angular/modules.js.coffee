
angular.module('openshift', []).config(['$provide', ($provide) ->

  $provide.factory('faq', ['$http', ($http) ->
    new FaqService($http)
  ])

])
