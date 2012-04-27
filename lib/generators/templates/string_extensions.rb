class String

  def capitalize_words
   return self.gsub(/\w+/u) { |word| word.capitalize } #gsub(/^[a-z]|\s+[a-z]/) { |a| a.upcase }
  end

  # Turns a string like "Devil's Cave.xml" into "Devil\'s\ Cave.xml", i.e. escapes spaces
  # and these: '&
  def escape_filename
    self.split("'").join("\\'").gsub(/(\s)/, '\\\\\1').gsub("&", '\\\\&')
  end

  # AFAIK this truncate method breaks some plugins like Faraday - Bill Alton 2012.03.02
  # def truncate(length, end_string = ' ...')
  #   l = length - end_string.mb_chars.length
  #   chars = self.mb_chars rescue self
  #   (chars.length > length ? chars[0...l] + end_string : self).to_s
  # end

end
