<?php include('../config/config.php');?>
<?php include('../parts/head.php'); ?>
<?php include('../parts/header.php'); ?>
<!-- Add the code/template for the route creation here, write the script in create.js -->
<script type="text/javascript" src="<?php echo getServerName();?>assets/js/create.js"></script>
<script type="text/javascript" src="<?php echo getServerName();?>assets/js/APIRequests.js"></script>
<link rel="stylesheet" href="<?php echo getServerName();?>assets/css/create.css">
<div class="btn-group">
  	<button id="buttonAddMyLocation" type="button" class="btn btn-primary">Add My Location</button>
  	<button id="buttonAddPinnedLocation" type="button" class="btn btn-primary">Add Pinned Location</button>
  	<button type="button" class="btn btn-primary">Start</button>
  	<button id="buttonShowPOIs" type="button" class="btn btn-success">Show POIs</button>
</div>
<!-- THE MAP -->
<div id="map-canvas" class="creation-map"></div>
<!-- THE BOTTOM BAR CONTAINING SEARCH, ROUTE TITLE, CIRCUIT CHECKBOX - FLOWS IN FROM BOTTOM-->
<div id="routePanel">
	<div class="row">
	  <div class="col-md-11" style="padding-top: 9px">
	  		<input id="routeSearch" type="text" class="form-control" placeholder="Enter a location to search..."/>
	  </div>
	  <div class="col-md-1">
	  		<button id="buttonSearch" type="button" class="btn btn-default btn-small">Search</button>
	  </div>
	</div>
	<div class="row">
		<div class="col-md-5"></div>
		<div class="col-md-7">
			<button id="buttonShowPanel" type="button" class="btn btn-default">Show</button>
		</div>
	</div>
	<div class="row">
		<div class="col-md-3"></div>
		<div class="row col-md-6">
			<div class="col-md-2">
				<label>Title</label>
			</div>
			<div class="col-md-10">
				<input id="routeTitle" type="text" class="form-control" placeholder="Untitled route"/>
			</div>
		</div>
	  	<div class="col-md-3"></div>
	</div>
	<div class="row">
		<div class="col-md-3"></div>
		<div class="row col-md-6">
			<div class="col-md-2">
				<label>Description</label>
			</div>
			<div class="col-md-10">
				<textarea id="routeDescription" class="form-control" placeholder="Default text"></textarea>
			</div>
		</div>
	  	<div class="col-md-3"></div>
	</div>
	<div class="row">
		<div class="col-md-3"></div>
		<div class="row col-md-6">
			<div class="col-md-2">
				<label>Duration (min)</label>
			</div>
			<div class="col-md-4">
				<input id="routeDuration" type="text" class="form-control" placeholder="45"/>
			</div>
			<div class="col-md-2">
				<label>Distance (km)</label>
			</div>
			<div class="col-md-4">
				<input id="routeDistance" type="text" class="form-control" placeholder="2.5"/>
			</div>
		</div>
	  	<div class="col-md-3"></div>
	</div>
	<div class="row">
		<div class="col-md-3"></div>
		<div class="row col-md-6">
			<div class="col-md-2">
				<label>Theme</label>
			</div>
			<div class="col-md-4">
				<div class="btn-group">
			  	  <select id="routeTheme" class="form-control"></select>
			  	</div>
			</div>
			<div class="col-md-2">
				<label for="cbCircuit">Circuit</label>
			</div>
			<div class="col-md-4">
				<input id="cbCircuit" type="checkbox"/>
			</div>
		</div>
	  	<div class="col-md-3"></div>
	</div>
	<div class="row">
		<div class="col-md-5"></div>
		<div class="row col-md-2">
			<div class="col-md-2">
				<button id="buttonDoneRoute" type="button" class="btn btn-default">Done</button>
			</div>
		</div>
	  	<div class="col-md-5"></div>
	</div>
</div>
<!-- PANEL FOR ADD/EDIT POI DETAILS - FLOWS IN FROM TOP -->
<div id="poiDetails" class="panel panel-default poi-details">
	<div class="panel-heading">Add/Edit POI</div>
	<div class="form-group row">
		<div class="col-md-1">
	  		<label for="poiTitle">Title</label>
	  	</div>
	  	<div class="col-md-11">
			<input type="text" name="poi_title" id="poiTitle" value="" placeholder="POI Title" class="form-control"/>
			<input type="hidden" id="poiUID"/>
		</div>
	</div>
	<div class="form-group row">
		<div class="col-md-1">
			<label for="poiDescription">Description</label>
		</div>
		<div class="col-md-11">
			<textarea name="poi_description" id="poiDescription" class="form-control"></textarea>		
		</div>
	</div>
	<div class="form-group row">
		<div class="col-md-1">
			<label for="poiMedia">Add Media</label>
		</div>
		<div class="col-md-11">
			<input type="file" name="poi_media" id="poiMedia" placeholder="Upload a file..." class="form-control"/>		
		</div>
	</div>
	<div class="form-group row">
		<div class="col-md-1">
			<label for="cbWaypoint">Use point as waypoint</label>
		</div>
		<div class="col-md-11">
			<input type="checkbox" name="poi_waypoint" id="cbWaypoint" class="form-control"/>		
		</div>
	</div>
	<div class="form-group">
		<div class="col-md-1"></div>
		<div class="col-md-11">
			<button id="buttonDonePOI" class="btn btn-default">Done</button>		
		</div>
	</div>
</div>
<!-- LIST OF SORTABLE POIS - FLOWS IN FROM RIGHT -->
<div id="poiList" class="panel list-group">
	<div class="panel-heading">
		<h3>POIs list</h3>
	</div>
	<label id="labelNoPOIs">You have no POIs added to the map.</label>
	<div id="poiListContainer"></div>
	<button id="buttonDonePOIList" class="btn btn-default">Done</button>
</div>
<?php include('../parts/footer.php'); ?>