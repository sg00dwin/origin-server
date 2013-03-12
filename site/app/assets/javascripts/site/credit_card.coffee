$ = jQuery

$ ->
  # Save inputs
  cc_input  = $('input[name="cc_no"]')
  cvv_input = $('input[name="cvv"]')

  cc_input.payment('formatCardNumber')
  cvv_input.payment('formatCardCVC')

  cc_input.on 'payment.cardType', (cardType) ->
    type = arguments[1]
    $('.cc-card').removeClass('selected')
    $(".cc-card.#{type}").addClass('selected')
