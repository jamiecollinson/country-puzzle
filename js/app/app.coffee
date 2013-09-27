define ['cs!app/countries', 'cs!app/config', 'cs!app/utilities'], (countries, config, util) ->
  
  do init = (id = 'map', devMode = false) ->
  
    # number of countries to display
    numberOfCountries = 15
  
    # create google map on #id element
    map = new google.maps.Map(document.getElementById(id),
      zoom: 3
      center: new google.maps.LatLng(7.19, 21.09)
      mapTypeId: google.maps.MapTypeId.ROADMAP
    )
    
    if devMode
      # set number of countries to max
      numberOfCountries = 0
      for country of countries
        numberOfCountries++
    
      # load world data
      $.getJSON "world.geo.json/countries.geo.json", (data) ->
        world = data.features
      
        # add input field and listener to add country from json
        $("div#title").append "<form id=\"dev-country\"><input></form>"
        $("form#dev-country").submit ->
          msg = $(this).children("input").val()
          for countryNumber of world
            if world[countryNumber].id is msg.toUpperCase()
              poly = geojsonToPoly(world[countryNumber].geometry, startOptions)
              poly.setMap map
              console.log msg.toUpperCase(), poly.my_getBounds().getCenter(), getEncodedPaths(poly)
              google.maps.event.addListener poly, "dragend", ->
                console.log poly.my_getBounds().getCenter(), getEncodedPaths(poly)

              break
          $(this).children("input").val ""
          false
  
    # randomly pick which countries to display
    randomCountryList = []
    for country of countries
      randomCountryList.push country
    randomCountryList.sort -> # inefficient method, but only a small list
      0.5 - Math.random()

    i = 0
    while i < numberOfCountries
      countries[randomCountryList[i]].active = true
      i++

    util.updateCounter()
  
    # add countries to map
    for country of countries
      if countries[country].active
        options = startOptions
        options.paths = getDecodedPaths(countries[country].startPath)
        options.map = map
        countries[country].poly = new google.maps.Polygon(options)
        addListener countries[country]