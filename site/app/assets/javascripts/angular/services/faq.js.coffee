
class @FaqService

  constructor: ($http) ->
    @topTen = []
    @faq = []

    #base = 'https://ec2-54-235-228-79.compute-1.amazonaws.com/community/api/v1'
    base = '/community/api/v1'

    $http.get("#{base}/faq/topten.json").success (resp) =>
      @topTen = resp.data

    $http.get("#{base}/faq.json").success (resp) =>
      @faq = resp.data

