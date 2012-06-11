require 'digest/md5'

require 'redcarpet'

module Admin::Atreides::GithubHelper

  GH_OPTIONS = {
     :filter_html => true,
     :autolink => true,
     :no_intra_emphasis => true,
     :fenced_code_blocks => true,
     :hard_wrap => true
     }

  def gfm(text)
    # Extract pre blocks
    extractions = {}
    text.gsub!(%r{<pre>.*?</pre>}m) do |match|
      md5 = Digest::MD5.hexdigest(match)
      extractions[md5] = match
      "{gfm-extraction-#{md5}}"
    end

    # prevent foo_bar_baz from ending up with an italic word in the middle
    text.gsub!(/(^(?! {4}|\t)\w+_\w+_\w[\w_]*)/) do |x|
      x.gsub('_', '\_') if x.split('').sort.to_s[0..1] == '__'
    end

    # in very clear cases, let newlines become <br /> tags
    text.gsub!(/(\A|^$\n)(^\w[^\n]*\n)(^\w[^\n]*$)+/m) do |x|
      x.gsub(/^(.+)$/, "\\1  ")
    end

    # Insert pre block extractions
    text.gsub!(/\{gfm-extraction-([0-9a-f]{32})\}/) do
      extractions[$1]
    end

    markdown = Redcarpet::Markdown.new(Redcarpet::Render::HTML.new(GH_OPTIONS), GH_OPTIONS)
    markdown.render(text)
  end

end
