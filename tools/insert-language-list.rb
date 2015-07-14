#!/usr/bin/env ruby
require 'csv'

preamble = <<__EOPreamble__
\\begin{tabular}{lllll}
\\hline
__EOPreamble__
postamble = <<__EOPostamble__
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

nrow = (languages.count.to_f / 5).ceil
puts nrow
0.upto(nrow - 1) do |row|
  a = 0.upto(4).map do |col|
    languages[row + col * nrow]
  end
  puts a.inspect
  puts a.join(' & ')
end
languages.each do |language|
  # puts language
end
