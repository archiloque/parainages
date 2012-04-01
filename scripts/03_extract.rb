# encoding: UTF-8

require 'json'
require 'csv'

list = JSON.parse(IO.read('liste.json'))
CSV.open("rc.csv", "wb", {:col_sep => ';'}) do |csv|
    csv << ['candidat', 'prénom', 'nom', 'long', 'lat']
    list.each do |i|
        csv << [
            i['candidat'],
            i['prénom'],
            i['nom'],
            (i['geolocalisation'] && i['geolocalisation']['location']) ? i['geolocalisation']['location']['lng'] : nil,
            (i['geolocalisation'] && i['geolocalisation']['location']) ? i['geolocalisation']['location']['lat'] : nil
        ]

    end
end

list = list.select { |person| person['geolocalisation'] && person['geolocalisation']['location'] }

result = []
candicates_list = ['Nathalie Arthaud', 'Nicolas Dupont-Aignan', 'François Bayrou', 'Jacques Cheminade', 'François Hollande', 'Eva Joly', 'Nicolas Sarkozy', 'Jean-Luc Mélenchon', 'Philippe Poutou']

def result_from_data person
    {
        :name => "#{person['prénom']} #{person['nom']}, #{person['fonction'].capitalize}, #{person['localité']}",
        :position => person['geolocalisation']['location']
    }
end

candicates_list.each do |candidate_name|
    result << {
        :candidate => candidate_name,
        :people =>
            list.
                select { |person| person['candidat'] == candidate_name }.
                collect { |person| result_from_data(person) }
    }

end
File.open('../data.js', 'w') { |f| f.write("var data=#{result.to_json}") }