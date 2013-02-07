
class @FaqService

  constructor: ($http) ->
    @faq = []

    base = '/community/api/v1'
    $http.get("#{base}/faq.json").success (resp) =>
      @faq = resp.data
