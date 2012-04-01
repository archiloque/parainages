# encoding: UTF-8
require 'json'
require 'rest-client'

# Récupère la géolocalisation

list = JSON.parse(IO.read('liste.json'))

def query adresse
    JSON.parse(RestClient.get 'http://maps.googleapis.com/maps/api/geocode/json',
                              {:params =>
                                   {:region => :FR,
                                    :language => :fr,
                                    :sensor => :false,
                                    :address => adresse}})
end

delay = 0.0
list.each do |entry|
    if !entry.has_key?('geolocalisation')

        query_place = "#{entry['localité']}, #{entry['département']}"
        result = query(query_place)
        # depassement du quota: on attend jusqu'à ce que ça passe
        unless result['status'] == 'OVER_QUERY_LIMIT'
            delay *= 0.9
        end
        while result['status'] == 'OVER_QUERY_LIMIT'
            delay += 2.0
            sleep delay
            result = query(query_place)
        end
        STDOUT << '.'
        STDOUT.flush

        status = result['status']

        entry['geolocalisation'] = geolocalisation = {'status' => status}
        if status == 'OK'
            geolocalisation['partial_match'] = result['results'][0]['partial_match']
            geolocalisation['location'] = result['results'][0]['geometry']['location']
            geolocalisation['location_type'] = result['results'][0]['geometry']['location_type']
            entry['address'] = result['results'][0]['formatted_address']
        end
        File.open('liste.json', 'w') { |f| f.write(JSON.pretty_generate(list)) }
        sleep delay
    end
end
