module ApplicationHelper
  include Console::CommunityHelper
  include Console::ConsoleHelper
  include Console::HelpHelper
  include Console::Html5BoilerplateHelper
  include Console::LayoutHelper
  include Console::ModelHelper
  include Console::SecuredHelper

  def logout_path(*args)
    controller.logout_path(*args)
  end

  def product_title
    "OpenShift by Red Hat"
  end

  def product_branding
    [
      content_tag(:span, nil, :class => 'brand-image'),
      content_tag(:span, "<strong>Open</strong>Shift".html_safe, :class => 'brand-text headline'),
    ].join.html_safe
  end
end
