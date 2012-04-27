class AtreidesBuilder < Formtastic::SemanticFormBuilder 

  def underline_input(method, options)
    type = :string
    form_helper_method = :text_field

    html_options = options.delete(:input_html) || {}
    html_options = default_string_options(method, type).merge(html_options) if [:numeric, :string, :password, :text].include?(type)

    self.label(method, options_for_label(options)) <<
    "<span>#{options[:prefix]}</span>".html_safe <<
    self.send(form_helper_method, method, html_options)
  end
  
  def files_input(method, options)
    type = :string
    form_helper_method = :file_field

    html_options = options.delete(:input_html) || {}
    html_options = default_string_options(method, type).merge(html_options) if [:numeric, :string, :password, :text].include?(type)

    self.label(method, options_for_label(options)) <<
    self.send(form_helper_method, method, html_options)
  end
  
  def price_input(method, options)
    type = :string
    form_helper_method = :text_field

    html_options = options.delete(:input_html) || {}
    html_options = default_string_options(method, type).merge(html_options) if [:numeric, :string, :password, :text].include?(type)

    self.label(method, options_for_label(options)) <<
    "<span>$</span>".html_safe <<
    self.send(form_helper_method, method, html_options)
  end
  
end

