#!/usr/bin/env ruby
class Dialogs < OpenShift::SeleniumTestCase

  def setup
    super
    @home.open
  end

  def test_dialogs
    # Toggle the dialogs by sending cmd to the old one
    #  If only one dialog is sent, assume we just want to check it and close it
    def toggle_dialogs(new,old=nil,cmd=nil)
      old.click(cmd) if cmd
      (assert !old.is_open?) if old
      assert new.is_open?
      new.click(:close)
      assert !new.is_open?
    end

    # Open the signin dialog
    open_dialog(:signin)
    toggle_dialogs(@signin)

    # Test signin -> reset
    open_dialog(:signin)
    toggle_dialogs(@reset,@signin,:reset)

    # Test reset -> signin
    open_dialog(:reset)
    toggle_dialogs(@signin,@reset,:signin)

    # Test signin -> signup
    open_dialog(:signin)
    toggle_dialogs(@signup,@signin,:signup)

    # Test signup -> signin
    open_dialog(:signup)
    toggle_dialogs(@signin,@signup,:signin)
  end
end
