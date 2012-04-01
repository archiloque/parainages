var map;
var geocoder;
var directionsService;
var directionsDisplay;
var possibleImages = [];
var userPositionMarker = null;

function createCheckbox(index, candidate) {
    $("#candicatesList").append('<label class="checkbox">' +
        '<input checked type="checkbox" id="candidate_' + index + '">' + candidate.candidate + ' ' +
        '<img src="' + index + '.png"' +
        '</label>');
    $("#candidate_" + index).click(function(){
        var checked = $("#candidate_" + index).attr('checked');
        if (checked && (!candidate.displayed)) {
            candidate.displayed = true;
            $.each(candidate.people, function (i, person) {
                person.marker.setMap(map);
            });
        } else if ((!checked) && candidate.displayed) {
            candidate.displayed = false;
            $.each(candidate.people, function (i, person) {
                person.marker.setMap(null);
            });
        }
    })

}

$(document).ready(function () {
    $.each(data, function (index, candidate) {
        createCheckbox(index, candidate);
    });

    var paris = new google.maps.LatLng(48.8579, 2.3518);

    map = new google.maps.Map(document.getElementById("mapCanvas"), {
        zoom: 6,
        mapTypeId: google.maps.MapTypeId.ROADMAP,
        region: "FR",
        language: "fr"
    });

    map.setCenter(paris);

    $.each(data, function (i, candidate) {
        possibleImages.push(new google.maps.MarkerImage( i + '.png',
            new google.maps.Size(20, 34),
            new google.maps.Point(0, 0),
            new google.maps.Point(10, 34)));

        candidate.displayed = true;

        $.each(candidate.people, function (j, person) {
            createMarker(i, person);
        });
    });

    geocoder = new google.maps.Geocoder();
    directionsService = new google.maps.DirectionsService();
    directionsDisplay = new google.maps.DirectionsRenderer();
    directionsDisplay.setMap(map);

    $.each(data, function (i, candidate) {
        $.each(candidate.people, function (i, person) {
            person.marker.setMap(map);
            person.displayed = true;
        });
    });
});

function createMarker(candidateIndex, person) {
    person.marker = new google.maps.Marker({
        position: new google.maps.LatLng(person.lat, person.lng),
        map: null,
        title: person.name,
        icon: possibleImages[candidateIndex]
    });
}

function updatePostalCode() {
    var textValue = $("#postalCode").val();
    geocoder.geocode({ address: textValue, region: "FR",
        language: "fr"}, function(results, status) {
        if (status == google.maps.GeocoderStatus.OK) {
            map.setCenter(results[0].geometry.location);
            if (userPositionMarker) {
                userPositionMarker.setMap(null);
            }
            geocoder.setViewport(results[0].geometry.viewport);
        } else {
            alert("Impossible de trouver ce code postal");
        }
    });
}