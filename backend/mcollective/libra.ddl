metadata    :name        => "Libra Management",
            :description => "Agent to manage Libra services",
            :author      => "Mike McGrath",
            :license     => "GPLv2",
            :version     => "0.1",
            :url         => "https://engineering.redhat.com/trac/Libra",
            :timeout     => 60

action "create_customer", :description => "Creates a new customer" do
    display :always

    input :customer,
        :prompt         => "Customer username",
        :description    => "Customers desired username",
        :type           => :string,
        :validation     => '^[a-zA-Z0-9]+$',
        :optional       => false,
        :maxlength      => 32

    input :email,
        :prompt         => "Email",
        :description    => "Customers email address",
        :type           => :string,
        :validation     => '^[a-zA-Z][\w\.-]*[a-zA-Z0-9]@[a-zA-Z0-9][\w\.-]*[a-zA-Z0-9]\.[a-zA-Z][a-zA-Z\.]*[a-zA-Z]$',
        :optional       => false,
        :maxlength      => 254
       
    input :ssh_key,
        :prompt         => "Email",
        :description    => "Customers email address",
        :type           => :string,
        :validation     => '^.+$',
        :optional       => false,
        :maxlength      => 1000

    output  :time,
            :description => "The time as a message",
            :display_as => "Time"

    output  :output,
            :description => "Output from creation script",
            :display_as => "Output"

    output :exitcode,
           :description => "Exit code",
           :display_as => "Exit Code"
end

action "create_http", :description => "create an apache lamp stack" do
    display :always

    input :customer,
        :prompt         => "Customer username",
        :description    => "Username of customer creating http instance",
        :type           => :string,
        :validation     => '^[a-zA-Z0-9]+$',
        :optional       => false,
        :maxlength      => 32

    input :application,
        :prompt         => "Application Name",
        :description    => "Name of http instance",
        :type           => :string,
        :validation     => '^[a-zA-Z0-9]+$',
        :optional       => false,
        :maxlength      => 32

    output  :time,
            :description => "The time as a message",
            :display_as => "Time"

    output  :output,
            :description => "Output from creation script",
            :display_as => "Output"

    output :exitcode,
           :description => "Exit code",
           :display_as => "Exit Code"
end

action "destroy_http", :description => "destroy an apache lamp stack" do
    display :always

    input :customer,
        :prompt         => "Customer username",
        :description    => "Username of customer creating http instance",
        :type           => :string,
        :validation     => '^[a-zA-Z0-9]+$',
        :optional       => false,
        :maxlength      => 32

    input :application,
        :prompt         => "Application Name",
        :description    => "Name of http instance",
        :type           => :string,
        :validation     => '^[a-zA-Z0-9]+$',
        :optional       => false,
        :maxlength      => 32

    output  :time,
            :description => "The time as a message",
            :display_as => "Time"

    output  :output,
            :description => "Output from creation script",
            :display_as => "Output"

    output :exitcode,
           :description => "Exit code",
           :display_as => "Exit Code"
end



action "echo", :description => "echo's a string back" do
    display :always

    input :msg,
        :prompt         => "prompt when asking for information",
        :description    => "description of input",
        :type           => :string,
        :validation     => '^.+$',
        :optional       => false,
        :maxlength      => 90

    output  :msg,
            :description => "displayed message",
            :display_as => "Message"

    output  :time,
            :description => "the time as a message",
            :display_as => "Time"
end
