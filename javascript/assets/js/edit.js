function displayRouteNavigation(route_) {
	configureEditUIListeners();
	
	// fill in route details: title, description, duration, distance, circuit, theme
	fillRouteDetails(route_);
	// draw the points on the map & populate the POI info
	drawPoints(route_.points);
	// connect the points on the map
	createRoute(points);
}

function fillRouteDetails(route_) {
	$('#routeTitle').val(route_.title);
	$('#routeDescription').val(route_.description);
	$('#routeDuration').val(route_.duration);
	$('#routeDistance').val(route_.distance);
	$('#cbCircuit').prop('checked', route_.circuit == "1" ? true : false);
	
	$('#routeTheme').val(route_.themes[0].theme_uid);
}

function drawPoints(points_) {
	for(var i = 0; i < points_.length; i++) {
		var point = points_[i];
		var latLng = new google.maps.LatLng(point.latitude,point.longitude);
		addLocationToMap(latLng,point);
	}
	if(points_.length > 0) {
		map.panTo(mapMarkers[0].getPosition());
	}
}

function configureEditUIListeners() {
	$('#buttonDonePOIList').off('click'); // deregister the listener inherited from create.js
	$('#buttonDonePOIList').click(editPOIList);
}

function editPOIList() {
	// put the ordered points in the sequence array
	sequence = new Array();
	$('.point-uid').each(function() {
		for (var index in points) {
			var point = points[index];
			if(point.uid == this.value) {
				console.log(point.uid + " @ position " + point.position);
				sequence.push(point);
				break;
			}
		}
	});
	var obj = new Object();
	obj.route_id = detailedRouteID;
	obj.points = points;
	updateRoutePoints(obj);
}

function finishEditRoute() {
	alert("ROUTE HAS BEEN SUCCESSFULLY EDITED");
	if(createRoute(sequence)) {
		togglePanel(new MouseEvent());
	}
}

function finishUpdatePoints() {
	closePOIList();
	createRoute(sequence);
}