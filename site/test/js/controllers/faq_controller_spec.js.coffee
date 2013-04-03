#= require application

describe 'FAQ Controller', ->

  describe '#filter', ->
    it 'should default to the top ten if search term is blank', ->
      # Given
      scope = { topten: ['foo', 'bar'], searchTerm: '' }
      FaqController(scope)

      # When
      scope.filter()

      # Then
      expect(scope.questions).to.equal(scope.topten)

    it 'should find a single name match', ->
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
      expect(scope.questions).to.eql([faq.faq[0]])

    it 'should find case insensitive name matches', ->
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
      expect(scope.questions).to.eql([faq.faq[3], faq.faq[2]])

    it 'should find a body match', ->

      # Given
      scope = { topten: [], searchTerm: 'body' }
      faq = {
        faq: [
          {name :'one', body: 'This should not match'},
          {name :'two', body: 'This body should match'}
        ]
      }

      FaqController(scope, faq)

      # When
      scope.filter()

      # Then
      expect(scope.questions).to.eql([faq.faq[1]])

    it 'should weight name matches higher', ->

      # Given
      scope = { topten: [], searchTerm: 'two' }
      faq = {
        faq: [
          {name :'one', body: 'This has a two'},
          {name :'two', body: 'This body does not match'}
        ]
      }

      FaqController(scope, faq)

      # When
      scope.filter()

      # Then
      expect(scope.questions).to.eql([faq.faq[1], faq.faq[0]])

    it 'should weight name and body matches highest', ->

      # Given
      scope = { topten: [], searchTerm: 'xxxx' }
      faq = {
        faq: [
          {name :'one', body: 'This only xxxx matches the body'},
          {name :'This has (xxxx) both', body: 'This also has both name and body xxxx'},
          {name :'name', body: 'This body does not match at all'},
          {name :'xxxx name', body: 'This only matches the name'}
        ]
      }

      FaqController(scope, faq)

      # When
      scope.filter()

      # Then
      expect(scope.questions).to.eql([faq.faq[1], faq.faq[3], faq.faq[0]])

