#!/usr/bin/env ruby
require 'csv'
require 'byebug'

def make_table
  preamble = <<-__EOPreamble__
\\begin{tabular}{lllll}
\\toprule
  __EOPreamble__
  postamble = <<-__EOPostamble__
\\bottomrule
\\end{tabular}
  __EOPostamble__

  f = File.open(File.expand_path('../../doc/languages.csv', __FILE__))
# CSV.open(File.read(File.expand_path('../../doc/languages.csv', __FILE__))) do |csv|
  languages = []
  offset = 0
  CSV.open(f) do |csv|
    csv.each do |row|
      if row.last == "true"
        languages << "\\TX{#{row.first}}"
        offset = 4
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
  (0..4).each do |col|
    0.upto(nrow - 1) do |row|
      next unless row < nrow || col < remainder
      language = languages[n]
      n += 1
      table[[row, col]] = language + ' ' * (14 - offset - language.length > 0 ? language.length : 0)
    end
  end

  preamble +  0.upto(nrow - 1).inject('') do |form, row|
    form + (0..4).map do |col|
      table[[row, col]]
    end.compact.join(' & ') + "\\\\\n"
  end + postamble
end

puts make_table
