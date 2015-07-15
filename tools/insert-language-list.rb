#!/usr/bin/env ruby
require 'csv'

def make_table
  preamble = <<-__EOPreamble__
\\begin{tabular}{lllll}
\\hline
  __EOPreamble__
  postamble = <<-__EOPostamble__
\\hline
\\end{tabular}
  __EOPostamble__

  f = File.open(File.expand_path('../../doc/languages.csv', __FILE__))
# CSV.open(File.read(File.expand_path('../../doc/languages.csv', __FILE__))) do |csv|
  languages = []
  CSV.open(f) do |csv|
    csv.each do |row|
      if row.last == "true"
        languages << "\\TX{#{row.first}}"
      else
        languages << row.first
      end
    end
  end
  f.close

  remainder = languages.count % 5
  nrow = (languages.count.to_f / 5).ceil
  table = { }
  n = 0
  puts "nrow = #{nrow}, remainder = #{remainder}"
  (0..4).each do |col|
    0.upto(nrow - 1) do |row|
      puts "#{row} #{col}"
      next if row == nrow - 1 && col >= remainder
      language = languages[n] || ""
      n += 1
      table[[row, col]] = language + ' ' * (14 - language.length)
    end
  end

  formatted_table = ''
  0.upto(nrow - 1) do |row|
    formatted_table += (0..4).map do |col|
      table[[row, col]]
    end.compact.join(' & ') + "\\\\\n"
  end

  preamble + formatted_table + postamble
end

puts make_table
