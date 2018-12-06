require 'yaml'
require 'csv'

class CSV2YAML
  SPLIT_COLUMNS = ['options']
  SPLIT_MARKS = /[,、，]/

  def convert_with_argv
    csv_filename = ARGV[0]
    unless csv_filename
      puts
      puts 'Usage: ruby csv2yaml.rb {csvname.csv}'
      puts
      return
    end

    csv_filename_array = csv_filename.split(/\./)
    yml_filename = (csv_filename_array[0..-2] + ['yml']).join('.')
    data = load(filepath: csv_filename)
    YAML.dump(data, File.open(yml_filename, 'w'))
  end

  def load(filepath:)
    raw_csv = CSV.read(filepath)
    header = raw_csv[0].map(&:strip)
    items = csv2hash_array(raw_csv: raw_csv, header: header)
    split_columns(items: items)
  end

  private

  def csv2hash_array(raw_csv:, header:)
    raw_csv[1...raw_csv.length].map do |row|
      hash = Hash[*[header, row.map { |r| r && trim(r) }].transpose.flatten]
      hash
    end
  end

  def split_columns(items:)
    items.map do |item|
      new_item = {}
      item.each do |key, value|
        if value && SPLIT_COLUMNS.include?(key)
          value = trim_and_exclude(value.split(SPLIT_MARKS))
          new_item[key] = value
        else
          new_item[key] = trim(value)
        end
      end
      new_item
    end
  end

  def trim_and_exclude(array)
    array = array.select{ |item| item }.map do |item|
      trim(item)
    end
    array.select { |item| item.length > 0 }
  end

  def trim(str)
    if str =~ /^[\s\r\n・　]*(.+?)[\s\r\n・　]*$/
      Regexp.last_match(1)
    else
      str
    end
  end
end

CSV2YAML.new.convert_with_argv
