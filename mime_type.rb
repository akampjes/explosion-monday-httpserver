class MimeType
  def self.from_file(file)
    file_name = file.split('/')[-1]
    file_parts = file_name.split('.')

    if file_parts.length > 1
      mime_type(file_parts[-1])
    else
      mime_type(nil)
    end
  end

  def self.mime_type(file_extension)
    case file_extension
    when 'html'
      'text/html'
    when /jpe?g/
      'image/jpeg'
    when 'png'
      'image/png'
    when 'svg'
      'image/svg+xml'
    when 'css'
      'text/css'
    when 'js'
      'application/javascript'
    when 'txt'
      'text/plain'
    else
      'text/plain'
    end
  end
end
