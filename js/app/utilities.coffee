define ->
  # add custom function my_getBounds to get the bounds of a polygon
  google.maps.Polygon::my_getBounds = ->
    bounds = new google.maps.LatLngBounds()
    @getPath().forEach (element, index) ->
      bounds.extend element
    bounds
  
  # encode latLng paths from a google maps polygon to the format ["path1", "path2"]
  getEncodedPaths = (poly) ->
    paths = []
    poly.latLngs.forEach (element) ->
      paths.push google.maps.geometry.encoding.encodePath(element.b).replace(/\\/g, "\\\\")
    paths
    
  # decode paths from format ["path1", "path2"] to array of arrays of latlngs
  getDecodedPaths = (paths) ->
    array = []
    for i of paths
      array.push google.maps.geometry.encoding.decodePath(paths[i])
    array
    
  # create google map polygon from geojson coords
  geojsonToPoly = (geometry, options) ->
    paths = []
    coords = geometry.coordinates
    if geometry.type is "Polygon"
      i = 0
      while i < coords.length
        path = []
        k = 0
        while k < coords[i].length
          path.push new google.maps.LatLng(coords[i][k][1], coords[i][k][0])
          k++
        paths.push path
        i++
    else if geometry.type is "MultiPolygon"
      i = 0
      while i < coords.length
        j = 0
        while j < coords[i].length
          path = []
          k = 0
          while k < coords[i][j].length
            path.push new google.maps.LatLng(coords[i][j][k][1], coords[i][j][k][0])
            k++
          paths.push path
          j++
        i++
    options.paths = paths
    new google.maps.Polygon(options)
    
  # add listener to dragend event of country poly
  addListener = (country) ->
    google.maps.event.addListener country.poly, "dragend", ->
      currentLocation = country.poly.my_getBounds().getCenter()
      goalLocation = new google.maps.LatLng(country.endCoords[0], country.endCoords[1])
      distance = google.maps.geometry.spherical.computeDistanceBetween(currentLocation, goalLocation)
      if distance < 100000
        options = endOptions
        options.paths = getDecodedPaths(country.endPath)
        country.poly.setOptions options
        country.active = false
        updateCounter()
  
  # update counter
  updateCounter = ->
    console.log countries
    i = 0
    for country of countries
      i++  if countries[country].active
    $("#count").html i + " countries remaining"
    return