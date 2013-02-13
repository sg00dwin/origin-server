
describe 'FAQ Controller', ->

  describe '#filter', ->
    it 'should default to the top ten if search term is blank', ->
      # Given
      scope = { topten: ['foo', 'bar'], searchTerm: '' }
      FaqController(scope)

      # When
      scope.filter()

      # Then
      expect(scope.questions).toBe(scope.topten)

    it 'should find a single match', ->
      # Given
      scope = { topten: [], searchTerm: 'foo' }
      faq = {
        faq: [
          {name :'food'},
          {name :'drink'}
        ]
      }

      FaqController(scope, faq)

      # When
      scope.filter()

      # Then
      expect(scope.questions).toEqual([faq.faq[0]])

    it 'should find case insensitive matches', ->
      # Given
      scope = { topten: [], searchTerm: 'Bar' }
      faq = {
        faq: [
          {name :'food'},
          {name :'drink'},
          {name :'bars'},
          {name :'ABBArenionTour'}
        ]
      }

      FaqController(scope, faq)

      # When
      scope.filter()

      # Then
      expect(scope.questions).toEqual([faq.faq[2], faq.faq[3]])

