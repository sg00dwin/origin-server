
class @FaqController

  constructor: ($scope, faq) ->
    $scope.filter = ->
      if $scope.searchTerm.length > 0
        search = $scope.searchTerm.toLowerCase()

        # There is probably a way to do this cleanly with a
        # comprehension but it was getting very messy
        questions = []
        angular.forEach(faq.faq, (q) ->
          score = 0
          if q.name.toLowerCase().indexOf(search) > -1
            score += 2

          if q.body && q.body.toLowerCase().indexOf(search) > -1
            score += 1

          questions.push([score, q]) if score > 0
        )

        # Sort descending and pull out the score
        $scope.questions = (item[1] for item in questions.sort().reverse())
      else
        $scope.questions = $scope.topten

@FaqController.$inject = ['$scope', 'faq']
