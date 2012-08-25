require 'pony'
require 'kramdown'

class Report
  attr_accessor :reports, :summary_email, :nag_owners

  def initialize(opts)
    opts.each do |k,v|
      send("#{k}=",v)
    end

    unless defined?(@nag_owners)
      @nag_owners = true
    end

    # Map passed in names to global report_types
    reports.map! do |name|
      $report_types[name]
    end

    # Set the sprint for each report
    reports.each do |r|
      r.sprint = $sprint
    end

    Pony.options = {
      :from => 'openshift-sprint-report@redhat.com',
      :reply_to => 'fotios@redhat.com',
      :via => :sendmail
    }
  end

  def required_reports
    reports.select{|r| r.required? }
  end

  def offenders
    required_reports.map{|r| r.offenders}.flatten.compact.uniq
  end

  def process(user = nil)
    stats = StatsReport.new

    data = required_reports.map do |r|
      rows = r.rows(user)
      hash = {
        :report => r,
        :data => {
          :title => r.title,
          :headings => r.columns.map{|col| col.header},
          :rows => rows
        }
      }
      stats.data << {:name => hash[:data][:title], :count => rows.count} if rows.count > 0
      hash
    end.compact

    data.delete_if{|d| d[:data][:rows].length == 0}

    unless data.empty?
      stats.data.unshift({
        :name => 'Total Stories',
        :count => $sprint.stories.length
      })

      stats_table = {
        :report => stats,
        :data => {
          :title => stats.title,
          :headings => stats.columns.map{|col| col.header},
          :rows => stats.rows
        }
      }

      data.unshift stats_table unless user
    end

    data
  end

  def to_kramdown(data,user = nil)
    str = []
    str << "## %s" % user ? "Incomplete User Stories for #{user}" : $sprint.title
    data.each do |t|
      r = t[:report]
      d = t[:data]
      str << ''
      str << "### #{r.print_title}"
      str << ''
      str << "|---"
      str << "| %s" % d[:headings].join(" | ")
      str << "| %s :--|" % (":--:|" * (d[:headings].length-1) )

      d[:rows].each do |row|
        str << "| %s" % row.join(' | ')
      end
      str << "{: border='1px solid black'}"
    end
    Kramdown::Document.new(str.join("\n"))
  end

  def to_ascii(data, user = nil)
    str = []
    str << "%s" % user ? "Incomplete User Stories for #{user}" : $sprint.title
    str << ("=" * str.last.length)
    data.each do |t|
      r = t[:report]
      d = t[:data]
      str << r.print_title
      str << ("="*str.last.length)
      d[:rows].each do |row|
        str << row.join(' - ')
      end
      str << ''
    end
    str.join("\n")
  end

  def send_email(args = {})
    default_options = {
      :to => summary_email,
      :nag => nag_owners,
      :send => false
    }

    args = default_options.merge(args)

    data = process
    make_mail(args[:to],$sprint.title(true),data,args[:send])

    if args[:nag]
      offenders.each do |user|
        data = process(user)
        make_mail(user,"Incomplete User Story #{$sprint.title(true)}",data,args[:send])
      end
    end
  end

  def make_mail(to,subject,data,send=true)
    puts "#"*100
    puts "Creating mail to: #{to} (#{subject})"
    if send
      print "\t Sending..."
      Pony.mail(:to => to, :subject => subject, :body => to_ascii(data), :html_body => to_kramdown(data).to_html)
      puts "Done"
    else
      puts to_ascii(data)
    end
  end
end
