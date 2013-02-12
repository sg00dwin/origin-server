
describe 'FAQ Controller', ->

  describe '#filter', ->
    it 'defaults to the top ten if search term is blank', ->
      # Given
      scope = { topten: ['foo', 'bar'], searchTerm: '' }
      FaqController(scope)

      # When
      scope.filter()

      # Then
      expect(scope.questions).toBe(scope.topten)
