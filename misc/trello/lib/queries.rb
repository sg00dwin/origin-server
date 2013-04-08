class Sprint
  def check_labels(x, target)
    x.labels.map{|x| x.name }.include?(target)
  end
  
  def check_comments(x, target)
    #TODO Trello doesn't have an api for comments yet
    #x.comments.map{|x| x.body }.include?(target)
    true
  end
  
  
  def queries
    {
      :needs_qe => {
        :function => lambda{|x|
          # Make sure the project is not docs
          !(x.name == 'Documentation') &&
            # Check the tags for no-qe
          !check_labels(x, 'no-qe')
        }
      },
      :qe_ready => {
        :parent => :needs_qe,
        :function => lambda{|x| check_comments(x, 'tcms') }
      },
      :approved => {
        :function => lambda{|x| check_labels(x, 'tc-approved') || !check_labels(x, 'no-qe') }
      },
      :accepted   => {
        :function => lambda{|x| trello.boards[x.board_id].name == 'Accepted' }
      },
      :completed   => {
        :parent   => :not_accepted,
        :function => lambda{|x| trello.boards[x.board_id].name == 'Complete' }
      },
      :not_dcut_complete => {
        :parent   => :not_completed,
        :function => lambda{|x| check_labels(x, 'devcut')}
      }
    }
  end
end
