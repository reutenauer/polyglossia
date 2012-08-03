kpse.set_program_name('lualatex', 'lualatex')

dofile('/Users/arthur/TeX/ConTeXt/tree/tex/context/base/l-table.lua')

function find_hyph(name)
  language_dat_file = kpse.find_file('language.dat.lua')
  if language_dat_file then
    language_dat = dofile(language_dat_file)
    for k in pairs(language_dat) do
      print(k)
    end

    local hyph = language_dat[name]
    if hyph then
      print(table.serialize(hyph))
    end
  end
end

find_hyph('german')
