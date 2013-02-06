
class @FaqController

  constructor: ($scope, faq) ->
    $scope.questions = faq.topTen

    $scope.filter = ->
      if $scope.searchTerm.length > 0
        search = $scope.searchTerm.toLowerCase()

        # Note:  A good optimization would be to stop looking 
        # once we reach the limit instead of searching all of the 
        # questions then truncating with the markup filter
        $scope.questions = (q for q in faq.faq when q.node.name.toLowerCase().indexOf(search) > -1)
      else
        $scope.questions = faq.topTen
