module RakeMethods

  def parse_datetime(str)
    timestamp = (Time.zone.parse(str) rescue nil)
    if timestamp.nil?
      ['%m/%d/%Y %H:%M:%S',
       '%m/%d/%Y %H:%M',
       '%m/%d/%y %H:%M:%S',
       '%m/%d/%y %H:%M',
      ].each do |fmt|
        timestamp = (DateTime.strptime(str, fmt) rescue nil)
        if timestamp.present?
          # convert to local time (doesn't work right around DST transition)
          timestamp = timestamp.in_time_zone(Time.zone)
          timestamp -= timestamp.utc_offset
          break
        end
      end
    end
    timestamp
  end

  def read_file_to_string(f, src_encoding, options={})
    f.binmode
    str = f.read
    return str if str.nil? or str.length == 0
    encode_options = {}
    if options[:replace]
      encode_options[:invalid] = encode_options[:undef] = :replace
    end
    # convert from src_encoding to utf-8
    str.encode!('utf-8', src_encoding, encode_options)
    # convert to "universal" end-of-line format "\n"
    # first convert one or more \r followed by \n to \n
    str.gsub!(/\r+\n/, "\n")
    # now convert \r to \n
    str.gsub!(/\r/, "\n")
    # now ensure last line ends with \n
    str += "\n" unless str[-1] == "\n"
    return str
  end

  def row_value(row, header, indexes, line = nil, errors = nil)
    index = header_index(header, indexes)
    value = index.present? ? row[index] : nil
    if value.blank? && line.present?
      error = "line #{line}: missing #{header} value"
      if errors.nil?
        STDERR.puts error
      else
        errors << error
      end
    end
    value
  end

  def header_index(header, indexes)
    indexes[header.downcase]
  end

  def header_row(row, header_index)
    # track index for each header in case order of columns varies
    row.each_with_index do |val, index|
      # track only the first column with each header name
      header_index[val.squish.downcase] ||= index unless val.blank?
    end
  end

  def verify_headers(header_list, header_index, errors = nil)
    header_errors = []
    header_list.each do |header|
      header_errors << "missing #{header} column header" if header_index[header.downcase].nil?
    end
    if errors.nil?
      abort header_errors.join("\n") if header_errors.size > 0
    else
      errors += header_errors
    end
  end

  def csv_column_separator(str)
    # look at the first (header) line and count "," and "\t" chars
    # and use the one which has the most
    line = str.partition("\n").first
    if line.count("\t") > line.count(",")
      "\t"
    else
      ","
    end
  end

end