<?php include('../config/config.php');?>
<?php include('../parts/head.php'); ?>
<?php include('../parts/header.php'); ?>
<script type="text/javascript" src="<?php echo getServerName();?>assets/js/browse.js"></script>
<script type="text/javascript" src="<?php echo getServerName();?>assets/js/APIRequests.js"></script>
<h1>Browse</h1>
<div id="map-canvas" class="creation-map hide"></div>
<button class="btn btn-default btn-block" id="search-toggle">Open search</button>
<div id="search">
	<div class="row">
		<div class='col-md-2'>
			<label>Distance from current location</label>
		</div>
		<div class='col-md-10'>
			<select id="filterDistance" class="route-search-select" name="distance" class="form-control">
				<option value="1">1 km</option>
				<option value="2">2 km</option>
				<option value="3">3 km</option>
				<option value="5">5 km</option>
				<option value="10">10 km</option>
			</select>
		</div>
	</div>
	<div class="row">
		<div class='col-md-2'>
			<label>Theme</label>
		</div>
		<div class='col-md-10'>
			<input id="filterTheme" type="text" name="theme" placeholder="Sports" class="form-control"/>
		</div>
	</div>
	<div class="row">
		<div class='col-md-2'>
			<label>Duration</label>
		</div>
		<div class='col-md-10'>
			<select id="filterDuration" class="route-search-select" name="duration" class="form-control">
				<option value="30">30 min</option>
				<option value="45">45 min</option>
				<option value="60">60 min</option>
				<option value="90">90 min</option>
				<option value="120">120+ min</option>
			</select>
		</div>
	</div>
	<div class="row">
		<div class='col-md-2'>
			<label>Keywords</label>
		</div>
		<div class='col-md-10'>
			<input id="filterKeywords" type="text" name="theme" placeholder="Type something to search..." class="form-control"/>
		</div>
	</div>
	<div class="row">
		<div class='col-md-12'>
			<button class="btn btn-default btn-block search-button">Search</button>
		</div>
	</div>
	
</div>
<div id="results"></div>
<?php include('../parts/footer.php'); ?>