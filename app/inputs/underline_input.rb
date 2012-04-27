class UnderlineInput
  include Formtastic::Inputs::Base

  def to_html
    input_wrapping do
      label_html <<
      builder.send(:text_field, method, input_html_options)
    end
  end

  def label_html
    super <<
      "<span>#{options[:prefix]}</span>".html_safe
  end

end