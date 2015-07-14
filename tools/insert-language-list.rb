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

  nrow = (languages.count.to_f / 5).ceil
  preamble + 0.upto(nrow - 1).inject([]) do |table, row|
    table << 0.upto(4).map do |col|
      language = languages[row + col * nrow]
      language + ' ' * (14 - language.length)
    end.join(' & ') + '\\\\'
  end.join("\n") + postamble
end

puts make_table
