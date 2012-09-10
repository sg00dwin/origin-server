class Sprint
  def queries
    {
      :needs_tasks => {
        :function => lambda{|x| x.tasks.nil? }
      },
      :blocked => {
        :function => lambda{|x| x.blocked == "true" }
      },
      :needs_qe => {
        :function => lambda{|x|
          # Make sure the project is not design or docs
          !(x.design? || x.documentation?) &&
            # Check the tags for no-qe
          !(x.check_tags('no-qe') || x.check_tags('os-no-qe'))
        }
      },
      :qe_ready => {
        :parent => :needs_qe,
        :function => lambda{|x| x.check_notes(/(\[libra-qe\]|tcms|QE)/) }
      },
      :approved => {
        :parent => :not_rejected,
        :function => lambda{|x| x.check_tags('TC-approved') }
      },
      :rejected => {
        :parent => :qe_ready,
        :function => lambda{|x| x.check_tags('TC-rejected') }
      },
      :accepted   => {
        :function => lambda{|x| x.schedule_state == "Accepted" }
      },
      :completed   => {
        :parent   => :not_accepted,
        :function => lambda{|x| x.schedule_state == "Completed" }
      },
      :not_dcut_complete => {
        :parent   => :not_completed,
        :function => lambda{|x| x.check_tags('os-DevCut')}
      }
    }
  end
end
