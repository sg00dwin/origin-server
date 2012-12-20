module RecaptchaHelper
  #FIXME move into bootstrap form builder as an input type
  def input_recaptcha(options={})
    html = ""
    html << <<-EOS
    <div id="recaptcha_widget" style="display:none" class="control-group #{options[:errors].present? && 'error'}">
      <label class="control-label recaptcha_only_if_image" for="recaptcha_response_field">Are you a spam bot?</label>
      <label class="control-label recaptcha_only_if_audio" for="recaptcha_response_field">Are you a spam bot?</label>
      <div class="controls">
        <div>
          <input type="text" class="max" placeholder="Type the words that appear below" id="recaptcha_response_field" name="recaptcha_response_field" />
          <div class="help-inline recaptcha_only_if_incorrect_so" style="#{options[:errors].present? ? '' : 'display:none;'}">Incorrect, please try again</div>
          <div style="margin-top: 10px;" id="recaptcha_image"></div>

          <div class='btn-toolbar btn-group'>
            <a class='btn btn-mini' href="javascript:Recaptcha.reload()">Get another</a>
            <a class='btn btn-mini recaptcha_only_if_image' href="javascript:Recaptcha.switch_type('audio')">Get an audio CAPTCHA</a>
            <a class='btn btn-mini recaptcha_only_if_audio' href="javascript:Recaptcha.switch_type('image')">Get an image CAPTCHA</a>
            <a class='btn btn-mini' href="javascript:Recaptcha.showhelp()">Help</a>
          </div>
          <div style="color: #555; font-size: 10px;margin-top:-10px">reCAPTCHA provided by Google - help fight spam and fix books!</div>
        </div>
      </div>
    </div>
    EOS
    options[:ssl] = true unless options[:ssl] === false
    options[:display] ||= {}
    options[:display][:theme] = :custom
    options[:display][:custom_theme_widget] = 'recaptcha_widget'
    html << recaptcha_tags(options)
    return (html.respond_to?(:html_safe) && html.html_safe) || html
  end
end
