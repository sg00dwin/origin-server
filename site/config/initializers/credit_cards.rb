# Do not try to change the order here, the sprites will not look right
# See config/credit_cards.yml for instructions
Rails.configuration.credit_cards = YAML.load_file(File.join(Rails.root, 'config', 'credit_cards.yml'))

if Rails.configuration.respond_to?(:accepted_cards)
  Rails.configuration.credit_cards.slice!(*Rails.configuration.accepted_cards)
end
