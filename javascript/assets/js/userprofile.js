function customInit() {
	userID = getCookie('userID');
	retrieveUserProfile(userID);
	retrieveUserCreatedRoutes(userID);
}

function populateUserProfile(info_) {
	$('#labelUsername').text(info_.username);
	$('#labelEmail').text(info_.email);
	$('#labelRoutesCount').text(info_.total_r);
	$('#labelRCCount').text(info_.total_rc);
	$('#labelPCCount').text(info_.total_pc);
	
	$('#labelLastCreated').text(info_.last_route['title']);
	$('#labelLastCreated').attr('href','routes_details.php?uid=' + info_.last_route['uid']);
}

function displayUserRoutes(routes_) {
	for(var i = 0; i < routes_.length; i++) {
		var route = routes_[i];
		populateRoute(route);
	}
}

function populateRoute(route_) {
	var themes = '';
	if(route_.themes.length > 0) {
		for(var i = 0; i < route_.themes.length; i++) {
			if (i < 5) {
				themes += '<span class="badge">'+route_.themes[i].title+'</span>';	
			} else {
				break;
			}
		}
	}
	var element = '<div class="panel panel-primary route-box"><div class="panel-heading"><h3 class="panel-title"><a href="routes_details.php?uid='+route_.uid+'">' + route_.title + '</a></h3><div class="route-time"><i class="fa fa-clock-o"></i>' + route_.duration + 'min</div></div><div class="panel-body"><div class="route-info"><p><i class="fa fa-map-marker"></i>' + route_.distance + ' km</p>'+themes+'</div><div class="route-description"><p>' + route_.description + '</p></div></div></div>';
	$('#routesList').append(element);
}