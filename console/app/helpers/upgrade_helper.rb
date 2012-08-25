module UpgradeHelper
  def upgrade_in_rails_31
    raise "Code needs upgrade for rails 3.1+" if Rails.version[0..3] != '3.0.'
  end
end
