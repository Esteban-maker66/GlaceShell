import QtQuick

Item {
    id: weatherService
    width: weatherRow.implicitWidth
    height: weatherRow.implicitHeight

    property string cityName: ""
    property string tempText: ""
    property string weatherIcon: ""
    property bool weatherReady: tempText.length > 0 && weatherIcon.length > 0

    FontLoader {
        id: estedad
        // Estedad-VF defaults to Thin/Regular; use the static bold face here.
        source: Qt.resolvedUrl("../../fonts/KonkhmerSleokchher-Regular.ttf")
    }

    Row {
        id: weatherRow
        spacing: 4
        anchors.verticalCenter: parent.verticalCenter
        opacity: weatherService.weatherReady ? 1 : 0

        Behavior on opacity {
            NumberAnimation {
                duration: 600
                easing.type: Easing.OutCubic
            }
        }

        Text {
            text: weatherService.tempText
            color: "#efefef"
            font.pixelSize: 25
            font.family: estedad.name
            renderType: Text.NativeRendering
            style: Text.Raised
            styleColor: "#1d1d1d2d"
        }

        WeatherIcon {
            width: 22
            height: 22
            condition: weatherService.weatherIcon.length > 0 ? weatherService.weatherIcon : "cloud"
            anchors.verticalCenter: parent.verticalCenter
        }
    }

    function fetchWeather() {
        // 1. Geolocate by IP
        var xhr = new XMLHttpRequest();
        xhr.open("GET", "http://ip-api.com/json?fields=status,city,lat,lon", true);
        xhr.onreadystatechange = function() {
            if (xhr.readyState === XMLHttpRequest.DONE && xhr.status === 200) {
                var res = JSON.parse(xhr.responseText);
                if (res.status === "success") {
                    weatherService.cityName = res.city;
                    getMeteo(res.lat, res.lon);
                }
            }
        };
        xhr.send();
    }

    function getMeteo(lat, lon) {
        // 2. Fetch weather
        var url = "https://api.open-meteo.com/v1/forecast?latitude=" + lat + 
                  "&longitude=" + lon + 
                  "&current=temperature_2m,weather_code&timezone=auto";
        
        var xhr = new XMLHttpRequest();
        xhr.open("GET", url, true);
        xhr.onreadystatechange = function() {
            if (xhr.readyState === XMLHttpRequest.DONE && xhr.status === 200) {
                var data = JSON.parse(xhr.responseText);
                var current = data.current;
                
                weatherService.tempText = Math.round(current.temperature_2m) + "°C";
                weatherService.weatherIcon = parseWeatherCode(current.weather_code);
            }
        };
        xhr.send();
    }

    function parseWeatherCode(code) {
        // Mapping copied from getWeatherCondition
        switch(code) {
            case 0: case 1: return "sun";
            case 2: return "partly-cloudy";
            case 3: return "cloud";
            case 45: case 48: return "fog";
            case 51: case 53: case 55: case 61: case 63: case 65: return "rain";
            case 71: case 73: case 75: return "snow";
            case 95: case 96: case 99: return "storm";
            default: return "cloud";
        }
    }

    Component.onCompleted: fetchWeather()
}