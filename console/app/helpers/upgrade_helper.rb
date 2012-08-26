module UpgradeHelper
  def upgrade_in_rails_31
    controller.send(:upgrade_in_rails_31)
  end
end
