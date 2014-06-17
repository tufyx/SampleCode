var tempUID;
// flag indicating if the route is created or edited; default is create
var isEdited = false;
// stores the point objects
var points;
// stores the marker objects
var mapMarkers;
var directionService;
// stores the final sequence of points after all the updates
var sequence;
var pinnedLocation;

function customInit() {
	userID = getCookie('userID');
	points = new Array();
	mapMarkers = new Array();
	getAllThemes();
	isEdited = parseWindowURL(window.location.href);
	configureMapListeners();
	configureUIListeners();
	
	// initialize the DirectionRequest
	directionsService = new google.maps.DirectionsService();
	 // Create a renderer for directions and bind it to the map.
	var rendererOptions = {
		    map: map
		  };
	directionsDisplay = new google.maps.DirectionsRenderer(rendererOptions);
}

function configureMapListeners() {
	google.maps.event.addListener(map, 'click', mapClickListener);
}

function togglePanel(event_) {
	var height = 320;
	var panelPosition = "+=" + height.toString() + "px";
	var mapHeight = "-=" + height.toString() + "px";
	var buttonLabel = 'Hide';
	if($('#buttonShowPanel').text() == 'Hide') {
		panelPosition = "-=" + height.toString() + "px";
		mapHeight = "+=" + height.toString() + "px";
		buttonLabel  = "Show";
	}
	$('#map-canvas').animate({"height": mapHeight},300,"swing");
	$('#routePanel').animate({"bottom": panelPosition},300,"swing",function() {
		$("#buttonShowPanel").text(buttonLabel);	
	});
}

function showPOIsPanel(event_) {
	var widthValue = (window.innerWidth - $('#poiList').width()) * 0.5; 
	$('#poiList').animate({right:widthValue},300,'swing',function() {
		// add click event listeners for the list items when the panel is displayed
		$('button.list-down').click(movePOIDown);
		$('button.list-up').click(movePOIUp);
		$('button.list-remove').click(removePOI);
	});
}

function configureUIListeners() {
	$('#buttonShowPanel').click(togglePanel);
	$('#buttonShowPOIs').click(showPOIsPanel);
	$('#buttonDonePOI').click(updatePOI);
	$('#buttonDonePOIList').click(closePOIList);
	$('#buttonDoneRoute').click(saveRoute);
	
	// restrict the inputs for duration and distance to accept numbers only
	$('#routeDuration').keydown(checkInputNumeric);
	$('#routeDistance').keydown(checkInputNumeric);
	
	$('#buttonSearch').click(searchLocation);
	$('#routeSearch').keydown(searchKeyDownHandler);
	
	$('#buttonAddMyLocation').click(addMyLocation);
	$('#buttonAddPinnedLocation').click(addPinnedLocation);
}

function getPointForUID(uid_) {
	for(var i = 0; i < points.length; i++) {
		if(points[i].uid == uid_) {
			var obj = new Object();
			obj.pointIndex = i;
			obj.point = points[i];
			return obj;
		}
	}
}

function getMarkerForUID(uid_) {
	for(var i = 0; i < mapMarkers.length; i++) {
		if(mapMarkers[i].pointData.uid == uid_) {
			return mapMarkers[i];
		}
	}
}

function updatePOI(event_) {
	var objPOI = getPointForUID(parseInt($('#poiUID').val()));
	objPOI.point.title = $('#poiTitle').val();
	objPOI.point.description = $('#poiDescription').val();
	objPOI.point.waypoint = $('#cbWaypoint').is(':checked');
	points[objPOI.pointIndex] = objPOI.point;
	
	// update the POI list entry
	var label = '#title_' + objPOI.point.uid.toString();
	$(label).text(objPOI.point.title);
	
	if(validatePOI(objPOI.point)) {
		$('#poiDetails').animate({top:-350});
		if(isEdited) {
			objPOI.point.route_id = detailedRouteID;
			updatePoint(objPOI.point);
			tempUID = objPOI.point.uid;
		}
	} else {
		// show error
		console.log('point invalid, fields missing');
	}
}

function finishUpdatePOI(newUID_) {
	var p = getPointForUID(tempUID);
	p.point.uid = newUID_;
	points[p.pointIndex] = p.point;
	$('#hidden_'+tempUID).val(newUID_);
}

function validatePOI(point_) {
	if(point_.title.length == 0) {
		return false;
	} else if (point_.description.length == 0) {
		return false;
	}
	return true;
}

function closePOIList(event_) {
	// obtain the sequence of points from the newly ordered list
	$('#poiList').animate({right:-1400},500,'swing',function() {
		// remove the click event listeners from the list items when the panel is hidden
		$('button.list-down').off('click');
		$('button.list-up').off('click');
	});
}

function saveRoute(event_) {
	// put the ordered points in the sequence array
	sequence = new Array();
	$('.point-uid').each(function() {
		for (var index in points) {
			var point = points[index];
			if(point.uid == this.value) {
				sequence.push(point);
				break;
			}
		}
	});
	
	// build the route variable
	var route = new Object();
	route.title = $('#routeTitle').val();
	route.description = $('#routeDescription').val();
	var themes = new Array();
	themes.push({title: $('#routeTheme option:selected').text(), uid: $('#routeTheme option:selected').val()});
	route.themes = themes;
	route.circuit = $('#cbCircuit').is(':checked') ? 1 : 0;
	route.distance = isNaN(parseFloat($('#routeDistance').val())) ? 0 : parseFloat($('#routeDistance').val());
	route.duration = isNaN(parseInt($('#routeDuration').val())) ? 0 : parseInt($('#routeDuration').val());
	route.author_id = Math.round(1 + Math.random() * 9);
	route.points = points;
	if(validateRoute(route)) {
		if(isEdited) {
			// edit route
			route.route_uid = detailedRouteID;
			editRoute(route);
		} else {
			// save route
			addNewRoute(route);	
		}
		
	}
}

function finishAddNewRoute() {
	if(createRoute(sequence)) {
		togglePanel(new MouseEvent());
		window.location.replace("userprofile.php");
	}
}

function createRoute(points_) {
	var start;
	var end;
	var waypoints = new Array();
	var intermediary = new Array();
	switch(points_.length) {
		case 0:
		case 1:
			alert('NOT ENOUGH POINTS');
			return false;
		case 2:
			start = new google.maps.LatLng(points_[0].latitude,points_[0].longitude);
			end = new google.maps.LatLng(points_[points_.length - 1].latitude,points_[points_.length - 1].longitude);
			break;
		default:
			start = new google.maps.LatLng(points_[0].latitude,points_[0].longitude);
			intermediary = points_.slice(1,points_.length - 1);
			end = new google.maps.LatLng(points_[points_.length - 1].latitude,points_[points_.length - 1].longitude);
			break;
	}
	for (var k in intermediary) {
		var pt = new Object();
		pt.location = new google.maps.LatLng(intermediary[k].latitude,intermediary[k].longitude);
		waypoints.push(pt);
	}
	var request = {
		origin:start,
		destination:end,
		waypoints:waypoints,
		travelMode: google.maps.TravelMode.WALKING
	};
	directionsService.route(request, function(result, status) {
		if (status == google.maps.DirectionsStatus.OK) {
			directionsDisplay.setDirections(result);
		} else {
			console.log('DIRECTIONS FAILED');
		}
	});
	return true;
}

function validateRoute(route_) {
	if(route_.title.length == 0) {
		alert('Title is missing');
		return false;
	} else if(route_.description.length == 0) {
		alert('Description is missing');
		return false;
	} else if(route_.duration == 0) {
		alert('Duration is missing');
		return false;
	} else if(route_.distance == 0) {
		alert('Distance is missing');
		return false;
	} else if (!validatePoints(route_.points)) {
		alert('It appears some of the points you added don`t have any details');
		return false;
	}
	
	return true;
}

function validatePoints(points_) {
	for(var i = 0; i < points_.length; i++) {
		var point = points_[i];
		if(!validatePOI(point)) {
			return false;
		}
	}
	return true;
}

function checkInputNumeric(event_) {
	// Allow: backspace, delete, tab, escape, enter and .
    if ( $.inArray(event.keyCode,[46,8,9,27,13,190]) !== -1 ||
         // Allow: Ctrl+A
        (event.keyCode == 65 && event.ctrlKey === true) || 
         // Allow: home, end, left, right
        (event.keyCode >= 35 && event.keyCode <= 39)) {
             // let it happen, don't do anything
             return;
    }
    else {
        // Ensure that it is a number and stop the keypress
        if (event.shiftKey || (event.keyCode < 48 || event.keyCode > 57) && (event.keyCode < 96 || event.keyCode > 105 )) {
            event.preventDefault(); 
        }   
    }
}

function movePOIDown(event_) {
	var elementToMove = $('#' + event_.currentTarget.id.toString()).parent();
	var uidCurrent = elementToMove.find('.point-uid').val();
	var nextElement = elementToMove.next();
	var uidNext = nextElement.find('.point-uid').val();
	nextElement.after(elementToMove);
	if(uidNext) {
		// retrieve the markers to be updated
		var marker = getMarkerForUID(uidCurrent);
		marker.pointData.position += 1;
		var color = ''; 
		if(marker.pointData.position == 1) {
			color = '00FF00';
		} else {
			color = 'FF0000';
		}
		marker.icon = "http://www.googlemapsmarkers.com/v1/"+marker.pointData.position+"/"+color+"/";
		marker.setMap(map);
		
		marker = getMarkerForUID(uidNext);
		marker.pointData.position -= 1;
		if(marker.pointData.position == 1) {
			color = '00FF00';
		} else {
			color = 'FF0000';
		}
		marker.icon = "http://www.googlemapsmarkers.com/v1/"+marker.pointData.position+"/"+color+"/";
		marker.setMap(map);
	}
}

function movePOIUp(event_) {
	var elementToMove = $('#' + event_.currentTarget.id.toString()).parent();
	var uidCurrent = elementToMove.find('.point-uid').val();
	var previousElement = elementToMove.prev();
	var uidPrevious = previousElement.find('.point-uid').val();
	previousElement.before(elementToMove);
	if(uidPrevious) {
		// retrieve the markers to be updated
		var marker = getMarkerForUID(uidCurrent);
		marker.pointData.position -= 1;
		var color = ''; 
		if(marker.pointData.position == 1) {
			color = '00FF00';
		} else {
			color = 'FF0000';
		}
		marker.icon = "http://www.googlemapsmarkers.com/v1/"+marker.pointData.position+"/"+color+"/";
		marker.setMap(map);
		
		marker = getMarkerForUID(uidPrevious);
		marker.pointData.position += 1;
		if(marker.pointData.position == 1) {
			color = '00FF00';
		} else {
			color = 'FF0000';
		}
		marker.icon = "http://www.googlemapsmarkers.com/v1/"+marker.pointData.position+"/"+color+"/";
		marker.setMap(map);
	}
}

function removePOI(event_) {
	var element = $('#' + event_.currentTarget.id.toString()).parent();
	var uid = element.find('.point-uid').val();
	// remove it from the list
	element.remove();
	// remove it from the points array
	for(var index in points) {
		if(points[index].uid == uid) {
			if(isEdited) {
				points[index].deleted = true;
			} else {
				points.splice(index,1);	
			}
			break;
		}
	}
	// retrieve the marker to be removed
	var marker = getMarkerForUID(uid);
	// remove it from the map
	marker.setMap(null);
	marker = null;
	// remove it from the mapMarkers array
	if(points.length == 0) {
		$('#labelNoPOIs').show();
	}
}

function mapClickListener(event_) {
	addLocationToMap(event_.latLng);
}

function addLocationToMap(latLng_,info_) {
	var position = info_ ? info_.position : points.length + 1;
	var color = "FF0000";
	if(points.length == 0) {
		color = "00FF00";
	}
	var pointMarker = new google.maps.Marker({
	      position: latLng_,
	      map: map,
	      icon: 'http://www.googlemapsmarkers.com/v1/'+position.toString()+'/'+color+'/',
	 });
	 
	pointMarker.pointData = createPOI(latLng_,info_);
	mapMarkers.push(pointMarker);
	google.maps.event.addListener(pointMarker,'click',displayPOIInfo);
}

function createPOI(location_,info_) {
	var position = points.length + 1;
	var point = new Object();
	point.position = position;
	if(info_) {
		point.title = info_.title;
		point.description = info_.description;
		point.waypoint = info_.waypoint == "1" ? true : false;
		point.existing = info_.existing;
		point.uid = info_.uid;
	} else {
		point.title = "Untitled POI " + position.toString();
		point.description = "";
		point.waypoint = false;
		point.existing = false;
		point.uid = new Date().getTime();
	}
//	point.location = location_;
	point.latitude = location_.lat();
	point.longitude = location_.lng();
	// create the li entry item in the unordered list
	var poiListItem = '<div class="list-group-item"><input id="hidden_'+point.uid+'" type="hidden" class="point-uid" value="' + point.uid + '"><label id="title_' + point.uid + '" class="poi-title">' + point.title + '</label><button id="btnDown' + point.uid + '" class="btn btn-default list-down">Down</button><button id="btnUp' + point.uid + '" class="btn btn-default list-up">Up</button><button id="btnRemove' + point.uid + '" class="btn btn btn-danger list-remove">Remove</button></div>';
	// add the entry to the list
	$('#poiListContainer').append(poiListItem);
	points.push(point);
	if(points.length > 0) {
		$('#labelNoPOIs').hide();
	}
	return point;
}

function displayPOIInfo(event) {
	var point = this.pointData;
	// populate the POI UID hidden field
	$('#poiUID').val(point.uid);
	// populate the POI title
	$('#poiTitle').val(point.title);
	// populate the POI description
	$('#poiDescription').val(point.description);
	// populate the POI waypoint checkbox
	$('#cbWaypoint').prop('checked', point.waypoint);
	var heightValue = (window.innerHeight - $('#poiDetails').height()) * 0.5; 
	$('#poiDetails').animate({top:heightValue});
}

function searchKeyDownHandler(event) {
	// if enter is pressed
	if(event.keyCode == 13) {
		searchLocation();
	}
}

function searchLocation(event) {
	var geocoder = new google.maps.Geocoder();
	var address = $('#routeSearch').val();
	geocoder.geocode( { 'address': address}, function(results, status) {
		if(pinnedLocation) {
			pinnedLocation.setMap(null);
		}
		if (status == google.maps.GeocoderStatus.OK) {
			map.setCenter(results[0].geometry.location);
			pinnedLocation = new google.maps.Marker({
				map: map,
				position: results[0].geometry.location,
				icon: 'http://www.googlemapsmarkers.com/v1/S/0000FF/'
			});	
		} else {
			alert('Geocode was not successful for the following reason: ' + status);
		}
	});
}

function addMyLocation(event) {
//	addLocationToMap();
}

function addPinnedLocation(event) {
	addLocationToMap(pinnedLocation.position);
	pinnedLocation.setMap(null);
	pinnedLocation = null;
}

function parseWindowURL(url_) {
	url_ = url_.substr(0,url_.indexOf('?'));
	var pieces = url_.split('/');
	pieces = pieces.reverse();
	if(pieces[0] == 'edit.php') {
		retrieveRouteNavigation(detailedRouteID);
		return true;
	}
	return false;
}
