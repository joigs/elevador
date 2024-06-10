# app/helpers/custom_form_builder.rb
class CustomFormBuilder < ActionView::Helpers::FormBuilder
  def field_with_errors(method, options = {})
    if object.errors[method].present?
      # Add the 'error' class along with any existing classes
      options[:class] = "#{options[:class]} error".strip
    end
    options
  end

  def text_field(method, options = {})
    super(method, field_with_errors(method, options))
  end

  def email_field(method, options = {})
    super(method, field_with_errors(method, options))
  end

  def password_field(method, options = {})
    super(method, field_with_errors(method, options))
  end

  def number_field(method, options = {})
    super(method, field_with_errors(method, options))
  end

  def full_error_messages_for(method, options = {})
    if object.errors[method].present?
      icons_html = @template.content_tag(:span, "", class: "error-icon") do
        # Assuming you have a helper method to fetch an SVG icon for 'error-icon'
        @template.svg_icon("exclamation-circle")
      end
      error_message = object.errors.full_messages_for(method).join(', ')
      @template.content_tag(:div, class: "error-message") do
        icons_html + @template.content_tag(:span, error_message)
      end
    end
  end

end
