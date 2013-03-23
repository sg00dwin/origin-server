module PaymentMethodsHelper
  def accepted_credit_cards
    @@accepted_credit_cards ||= (
      credit_cards = YAML.load_file(File.join(Rails.root, 'config', 'credit_cards.yml'))
      if Rails.configuration.respond_to?(:accepted_cards)
        credit_cards.slice!(*Rails.configuration.accepted_cards)
      end
      credit_cards
    )
  end

  def extended_cc_validation
    !(Rails.configuration.respond_to?(:disable_cc_validation) && Rails.configuration.disable_cc_validation)
  end
end
