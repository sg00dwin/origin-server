require 'trello'

class TrelloHelper
  # Trello Config
  attr_accessor :consumer_key, :consumer_secret, :oauth_token, :oauth_token_secret, 
                :broker_id, :origin_broker_id, :documentation_id,  :enterprise_id, 
                :runtime_id, :origin_runtime_id, :ui_id, :origin_ui_id, :organization_id
                
  attr_accessor :boards

  def initialize(opts)
    opts.each do |k,v|
      send("#{k}=",v)
    end

    Trello.configure do |config|
      config.consumer_key = @consumer_key
      config.consumer_secret = @consumer_secret
      config.oauth_token = @oauth_token
      config.oauth_token_secret = @oauth_token_secret
    end
  end
  
  def board_ids
    return [broker_id, origin_broker_id, documentation_id,  enterprise_id, runtime_id, origin_runtime_id, ui_id, origin_ui_id]
  end
  
  def team_boards(team_name)
    case team_name
    when 'broker'
      return [boards[broker_id], boards[origin_broker_id]]
    when 'runtime'
      return [boards[runtime_id], boards[origin_runtime_id]]
    when 'ui'
      return [boards[ui_id], boards[origin_ui_id]]
    when 'enterprise'
      return [boards[enterprise_id]]
    when 'documentation'
      return [boards[documentation_id]]
    end
  end

  def boards
    return @boards if @boards
    @boards = {}
    org.boards.target.each do |board|
      if board_ids.include?(board.id)
        @boards[board.id] = board
      end
    end
    @boards
  end

  def org
    @org ||= Trello::Organization.find(organization_id)
  end

  def org_boards
    org.boards.target
  end

  def board(board_id)
    boards[board_id]
  end
  
  def member(member_name)
    Trello::Member.find(member_name)
  end

end
