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
candicates_list = ['Nathalie Arthaud', 'Marine Le Pen', 'Nicolas Dupont-Aignan', 'François Bayrou', 'Jacques Cheminade', 'François Hollande', 'Eva Joly', 'Nicolas Sarkozy', 'Jean-Luc Mélenchon', 'Philippe Poutou']

AFFILIATIONS = {
    'DVG' => ', divers gauche',
    'AUT' => ', autre',
    'DVD' => ', divers droite',
    'N/A' => '',
    'SOC' => ', Parti Socialiste',
    'EXD' => ', extrême-droite',
    'COM' => ', communiste',
    'UDFD' => ', MoDem',
    'UMP' => ', UMP',
    'EXG' => ', extrême-gauche',
    'RDG' => ', Parti radical de gauche',
    'ECO' => ', écologiste',
    'REG' => ', régionaliste',
    'FN' => ', FN',
    'UDF' => ', UDF',
    'RPR' => ', RPR',
    'MNR' => ', Mouvement National Républicain',
    'NI' => ', non inscrit',
    'MODM' => ', MoDem',
    'M-NC' => ', Nouvean Centre',
    'UCR' => ', centre droit',
    'VEC' => ', vert',
    'DL' => ', Démocratie Libérale',
    'NC' => ', Nouveau Centre',
    'SRC' => ', gauche',
    'SOC-EELV' => ', gauche',
    'PRS' => '',
    'RDSE' => ', Parti radical de gauche',
    'PRG' => ', Parti radical de gauche',
    'GDR' => ', gauche',
    'CRC' => ', communiste'
}

def result_from_data person
    if person['affiliation']
        affiliation = AFFILIATIONS[person['affiliation']]
        unless affiliation
            raise "Affiliation inconnue #{person['affiliation']}"
        end
    else
        affiliation = ''
    end
    {
        :name => "#{person['prénom']} #{person['nom']}, #{person['fonction'].capitalize}, #{person['localité']}#{affiliation}",
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