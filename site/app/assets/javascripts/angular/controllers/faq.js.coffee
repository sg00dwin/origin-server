
class @FaqController

  constructor: ($scope, faq) ->
    $scope.filter = ->
      if $scope.searchTerm.length > 0
        search = $scope.searchTerm.toLowerCase()
        $scope.questions = (q for q in faq.faq when q.node.name.toLowerCase().indexOf(search) > -1)
      else
        $scope.questions = $scope.topten
