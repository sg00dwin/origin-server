# encoding: UTF-8

module ApplicationHelper
  include Console::CommunityHelper
  include Console::ConsoleHelper
  include Console::DateHelper
  include Console::HelpHelper
  include Console::Html5BoilerplateHelper
  include Console::LayoutHelper
  include Console::ModelHelper
  include Console::SecuredHelper

  include ActionView::Helpers::NumberHelper
  include CaptchaHelper

  def logout_path(*args)
    controller.logout_path(*args)
  end

  def product_title
    "OpenShift Online by Red Hat"
  end

  def product_branding
    [
      content_tag(:span, nil, :class => 'brand-image'),
      content_tag(:span, "<strong>Open</strong>Shift".html_safe, :class => 'brand-text headline'),
    ].join.html_safe
  end

  def user_currency_symbol
    case controller.user_currency_cd
    when "eur"
      "€"
    when "cad"
      "C$"
    else
      "$"
    end
  end
  
  def number_to_user_currency(number)
    return nil if number.nil?

    case controller.user_currency_cd
    when 'eur'
      unit = "€"
      format = "%u %n"
    when 'cad'
      unit = "C$"
      format = "%u%n"
    else
      unit = "$"
      format = "%u%n"
    end

    options = {}
    options[:unit] = unit
    options[:format] = format
    number_to_currency(number, options)
  end    
end
