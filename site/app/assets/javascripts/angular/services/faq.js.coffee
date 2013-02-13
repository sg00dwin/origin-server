
class @FaqService

  constructor: ($http) ->
    @faq = []
    $http.get('/account/faqs').success (data) =>
      @faq = data
