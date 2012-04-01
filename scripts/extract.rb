# encoding: UTF-8

# Transforme le csv de regards citoyens en json
# Origine http://regardscitoyens.org/telechargement/presidentielles-2012/

require 'csv'
require 'json'

candicates_list = ['Nathalie Arthaud', 'Marine Le Pen', 'Nicolas Dupont-Aignan', 'François Bayrou', 'Jacques Cheminade', 'François Hollande', 'Eva Joly', 'Nicolas Sarkozy', 'Jean-Luc Mélenchon', 'Philippe Poutou']

result = {}
candicates_list.each do |c|
    result[c] = []
end

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
    'CRC' => ', communiste',
    'MDC' => ', Mouvement des Citoyens'
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
        :lng => person['longitude'],
        :lat => person['latitude']
    }
end

CSV.foreach("signatures_candidats_2012.csv", {:col_sep => ';', :headers => true}) do |row|
    if row['longitude'] && row['latitude']
        result[row['candidat']] << result_from_data(row)
    end
end

File.open('../data.js', 'w') { |f| f.write("var data=#{(candicates_list.map { |c| {:candidate => c, :people => result[c]} }).to_json}") }