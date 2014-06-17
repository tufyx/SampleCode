<?php include('../config/config.php');?>
<?php include('../parts/head.php'); ?>
<?php include('../parts/header.php'); ?>
<!-- Add the code/template for the route creation here, write the script in create.js -->
<script type="text/javascript" src="<?php echo getServerName();?>assets/js/userprofile.js"></script>
<script type="text/javascript" src="<?php echo getServerName();?>assets/js/APIRequests.js"></script>
<div id="user_statistics">
	<div class="row">
	  <div class="col-md-1">
	  		<label>Username</label>
	  </div>
	  <div class="col-md-11">
	  		<label id="labelUsername">N/A</label>
	  </div>
	</div>
	<div class="row">
	  <div class="col-md-1">
	  		<label>Email</label>
	  </div>
	  <div class="col-md-11">
	  		<label id="labelEmail">N/A</label>
	  </div>
	</div>
	<div class="row">
	  <div class="col-md-12">
	  		<label>Stats</label>
	  </div>
	</div>
	<hr/>
	<div class="row">
	  <div class="col-md-2">
	  		<label>Routes Created:</label>
	  		<label id="labelRoutesCount" class='someclass'>N/A</label>
	  </div>
	  <div class="col-md-2">
	  		<label>Routes Completed:</label>
	  		<label class='someclass'>N/A</label>
	  </div>
	  <div class="col-md-2">
	  		<label>Routes Comments:</label>
	  		<label id="labelRCCount" class='someclass'>N/A</label>
	  </div>
	  <div class="col-md-2">
	  		<label>Point Comments:</label>
	  		<label id="labelPCCount" class='someclass'></label>
	  </div>
	  <div class="col-md-4">
	  		<label>Last created route:</label>
	  		<a id="labelLastCreated" class='someclass'>N/A</a>
	  </div>
	</div>
</div>

<div id="routesList"></div>
<?php include('../parts/footer.php'); ?>