require 'csv'
require 'json'

# Transforme le csv de regards citoyens en json
# Origine http://regardscitoyens.org/telechargement/presidentielles-2012/

list = []

CSV.foreach("signatures_candidats_2012.csv", {:col_sep => ';', :headers => true}) do |row|
    list << row.to_hash
end

File.open('liste.json', 'w') {|f| f.write(JSON.pretty_generate(list)) }
