require 'trello'

class TrelloHelper
  # Trello Config
  attr_accessor :consumer_key, :consumer_secret, :oauth_token, :oauth_token_secret,
                :broker_id, :origin_broker_id, :documentation_id,  :enterprise_id,
                :runtime_id, :origin_runtime_id, :ui_id, :origin_ui_id, :organization_id,
                :roadmap_board, :roadmap_id

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
    return [broker_id, origin_broker_id, enterprise_id, runtime_id, origin_runtime_id, ui_id, origin_ui_id]
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

  def team_board(board_name)
    case board_name
    when 'origin_broker'
      return boards[origin_broker_id]
    when 'online_broker' 
      return boards[broker_id]
    when 'origin_runtime'
      return boards[origin_runtime_id]
    when 'online_runtime'
      return boards[runtime_id]
    when 'origin_ui'
      return boards[origin_ui_id]
    when 'online_ui'
      return boards[ui_id]
    when 'enterprise', 'enterprise_broker', 'enterprise_runtime', 'enterprise_ui'
      return boards[enterprise_id]
    when 'documentation'
      return boards[documentation_id]
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

  def roadmap_board
    @roadmap_board = Trello::Board.find(roadmap_id) unless @roadmap_board
    @roadmap_board
  end

  def epic_list
    list = nil
    roadmap_board.lists.each do |l|
      if l.name == 'Epic Backlog'
        list = l
      end
    end
    list
  end

  def checklist(card, checklist_name)
    card.checklists.target.each do |checklist|
      if checklist.name == checklist_name
        return checklist
      end
    end
    return nil
  end

  def print_card(card, num=nil)
    print "     "
    print "#{num}) " if num
    puts "#{card.name} (##{card.short_id})"
    members = card.members
    if !members.empty?
      puts "       Assignee(s): #{members.map{|member| member.full_name}.join(',')}"
    end
  end

  def print_list(list)
    cards = list.cards.target
    if !cards.empty?
      puts "\n  List: #{list.name}  (#cards #{cards.length})"
      puts "    Cards:"
      cards.each_with_index do |card, index|
        print_card(card, index+1)
      end
    end
  end

  def card_by_ref(card_ref)
    card = nil
    if card_ref =~ /^(\w+)_(\d+)/i
      board_name = $1
      card_short_id = $2
      board = team_board(board_name)
      card = board.find_card(card_short_id)
    end
    card
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
