function getAllThemes() {
	var request = new Object();
	request.method = "GET";
	request.url = serviceEndpoint + "themes/getAll";
	request.successHandler = getAllThemesSuccess;
	request.errorHandler = getAllThemesError;
	sendAJAXRequest(request);
}

//handles the success event of an AJAX request
function getAllThemesSuccess(data_, status_, xhr_) {
	var themes = $("#routeTheme");
	$.each(data_, function() {
		themes.append($("<option />").val(this.uid).text(this.title));
	});
}

// handles the error event of an AJAX request
function getAllThemesError (xhr_, status_, error_){
	console.log("AJAX ERROR");
	console.log("ERROR");
	console.log(error_);
}

function addNewRoute(route_) {
	var request = new Object();
	request.method = "POST";
	request.url = serviceEndpoint + "routes/create";
	request.data = route_;
	request.successHandler = addNewRouteSuccess;
	request.errorHandler = addNewRouteError;
	sendAJAXRequest(request);
}

function addNewRouteSuccess(data_, status_, xhr_) {
	console.log('add new route success');
	console.log(data_);
	if(data_) {
		finishAddNewRoute();
	}
}

function addNewRouteError(xhr_, status_, error_) {
	console.log('add new route error');
	console.log(error_);
}

function editRoute(route_) {
	var request = new Object();
	request.method = "POST";
	request.url = serviceEndpoint + "routes/edit";
	request.data = route_;
	request.successHandler = editRouteSuccess;
	request.errorHandler = editRouteError;
	sendAJAXRequest(request);
}

function editRouteSuccess(data_, status_, xhr_) {
	console.log('edit route success');
	console.log(data_);
	if(data_) {
		finishEditRoute();
	}
}

function editRouteError(xhr_, status_, error_) {
	console.log('edit route error');
	console.log(error_);
}

function updatePoint(poi_) {
	var request = new Object();
	if(poi_.existing) {
		request.url = serviceEndpoint + "points/edit";
	} else {
		request.url = serviceEndpoint + "points/create";
	}
	request.method = "POST";
	request.data = poi_;
	request.successHandler = updatePOISuccess;
	request.errorHandler = updatePOIError;
	console.log(request);
	sendAJAXRequest(request);
}

function updatePOISuccess(data_, status_, xhr_) {
	console.log('update poi success');
	console.log(data_);
	finishUpdatePOI(data_);
}

function updatePOIError(xhr_, status_, error_) {
	console.log('edit route error');
	console.log(error_);
}

function updateRoutePoints(data_) {
	var request = new Object();
	request.url = serviceEndpoint + "routes/updatePoints";
	request.method = "POST";
	request.data = data_;
	request.successHandler = updateRoutePointsSuccess;
	request.errorHandler = updateRoutePointsError;
	console.log(request);
	sendAJAXRequest(request);
}

function updateRoutePointsSuccess(data_, status_, xhr_) {
	console.log('update poi list success');
	console.log(data_);
	finishUpdatePoints();
}

function updateRoutePointsError(xhr_, status_, error_) {
	console.log('update poi list error');
	console.log(error_);
}

function retrieveUserProfile(userID_) {
	var request = new Object();
	request.method = "GET";
	request.url = serviceEndpoint + "users/get/" + userID_;
	request.successHandler = retrieveUserProfileSuccess;
	request.errorHandler = retrieveUserProfileError;
	sendAJAXRequest(request);
}

function retrieveUserProfileSuccess(data_, status_, xhr_) {
	console.log('retrieve user profile success');
	console.log(data_);
	populateUserProfile(data_);
}

function retrieveUserProfileError(xhr_, status_, error_) {
	console.log('retrieve user profile error');
	console.log(error_);
}

function retrieveUserCreatedRoutes(authorID_) {
	var request = new Object();
	request.method = "GET";
	request.url = serviceEndpoint + "routes/getForUser/" + authorID_.toString();
	request.successHandler = retrieveUserCreatedRoutesSuccess;
	request.errorHandler = retrieveUserCreatedRoutesError;
	sendAJAXRequest(request);
}

function retrieveUserCreatedRoutesSuccess(data_, status_, xhr_) {
	console.log('succesfully retrieved user created routes');
	displayUserRoutes(data_);
}

function retrieveUserCreatedRoutesError(xhr_, status_, error_) {
	console.log('error retrieve user created routes');
	console.log(error_);
}

function retrieveRouteDetails(routeID_) {
	var request = new Object();
	request.method = "GET";
	request.url = serviceEndpoint + "routes/getDetails/" + routeID_.toString();
	request.successHandler = retrieveRouteDetailsSuccess;
	request.errorHandler = retrieveRouteDetailsError;
	sendAJAXRequest(request);
}

function retrieveRouteDetailsSuccess(data_, status_, xhr_) {
	console.log('succesfully retrieved user route details');
	displayRouteDetails(data_);
}

function retrieveRouteDetailsError(xhr_, status_, error_) {
	console.log('error retrieve route details');
	console.log(error_);
}

function retrieveRouteNavigation(routeID_) {
	var request = new Object();
	request.method = "GET";
	request.url = serviceEndpoint + "routes/getNavigation/" + routeID_.toString();
	request.successHandler = retrieveRouteNavigationSuccess;
	request.errorHandler = retrieveRouteNavigationError;
	sendAJAXRequest(request);
}

function retrieveRouteNavigationSuccess(data_, status_, xhr_) {
	console.log('succesfully retrieved route navigation');
	console.log(data_);
	displayRouteNavigation(data_);
}

function retrieveRouteNavigationError(xhr_, status_, error_) {
	console.log('error retrieve route navigation');
	console.log(error_);
}

function postRouteComment(comment_) {
	var request = new Object();
	request.method = "POST";
	request.url = serviceEndpoint + "routes/createComment";
	request.data = comment_;
	request.successHandler = postRouteCommentSuccess;
	request.errorHandler = postRouteCommentError;
	console.log(request);
	sendAJAXRequest(request);
}

function postRouteCommentSuccess(data_, status_, xhr_) {
	console.log('succesfully created comment for route');
	addCommentToUI();
}

function postRouteCommentError(xhr_, status_, error_) {
	console.log('error retrieve route details');
	console.log(error_);
}

function postPointComment(comment_) {
	var request = new Object();
	request.method = "POST";
	request.url = serviceEndpoint + "points/createComment";
	request.data = comment_;
	request.successHandler = postPointCommentSuccess;
	request.errorHandler = postPointCommentError;
	console.log(request);
	sendAJAXRequest(request);
}

function postPointCommentSuccess(data_, status_, xhr_) {
	console.log('succesfully created comment for point');
	addCommentToUI();
}

function postPointCommentError(xhr_, status_, error_) {
	console.log('error create point comments');
	console.log(error_);
}

function uploadPointPhoto(photo_) {
	var request = new Object();
	request.method = "POST";
	request.url = serviceEndpoint + "points/createMediaItemFromPhoto";
	request.data = photo_;
	request.successHandler = uploadPointPhotoSuccess;
	request.errorHandler = uploadPointPhotoError;
	console.log(request);
	sendAJAXRequest(request);
}

function uploadPointPhotoSuccess(data_, status_, xhr_) {
	console.log('succesfully uploaded photo for point');
	addPhotoToUI();
}

function uploadPointPhotoError(xhr_, status_, error_) {
	console.log('error upload point photo');
	console.log(error_);
}

function performSearch(filters_) {
	console.log('search function fired');
	var request = new Object();
	request.method = "POST";
	request.url = serviceEndpoint + "routes/search";
	request.data = filters_;
	request.successHandler = searchSuccess;
	request.errorHandler = searchError;
	sendAJAXRequest(request);
}

function userLogin(loginData_) {
	var request = new Object();
	request.method = "POST";
	request.url = serviceEndpoint + "users/login";
	request.data = loginData_;
	request.successHandler = userLoginSuccess;
	request.errorHandler = userLoginError;
	console.log(loginData_);
	sendAJAXRequest(request);
}

function userLoginSuccess(data_, status_, xhr_) {
	finishUserLogin(data_);
}

function userLoginError(xhr_, status_, error_) {
	console.log('error login user');
	console.log(error_);
}