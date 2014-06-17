<?php include('../config/config.php');?>
<?php include('../parts/head.php'); ?>
<?php include('../parts/header.php'); ?>
<!-- Add the code for the view where you can see details about one particular route -->
<script type="text/javascript">
	var detailedRouteID = '<?php echo $_GET['uid']; ?>';
</script>
<script type="text/javascript" src="<?php echo getServerName();?>assets/js/route_details.js"></script>
<script type="text/javascript" src="<?php echo getServerName();?>assets/js/APIRequests.js"></script>
<link rel="stylesheet" href="<?php echo getServerName();?>assets/css/route_details.css">
<h1>Details</h1>
<button type="button" class="btn btn-primary" id="buttonEditRoute">Edit</button>
<div class="panel panel-primary route-box">
  <div class="panel-heading">
    <h3 id="routeDetailsTitle" class="panel-title">Running tour</h3>
    <div id="routeDetailsTime" class="route-time"></div>
  </div>
  <div class="panel-body">
  	<div id="routeDetailsThemes" class="route-info">
  		<p id="routeDetailsDistance"></p>
  		<p>Rating <span id="routeDetailsRating" class="badge"></span></p>
  	</div>
	<div class="route-description">
		<img src="../assets/images/aalto.jpg" class="img-responsive img-rounded">
		<p id="routeDetailsDescription">Details of the route.</p>
	</div>
  </div>
  <h3>Route Comments</h3>
  <div id="routeDetailsComments"></div>
</div>
<div class="panel panel-primary route-box">
  <div class="panel-heading">
    <h3 class="panel-title">Add comment</h3>
  </div>
  <div class="panel-body">
  	<div class="row">
  		<div class="col-md-1"><label>Your Comment:</label></div>
  		<div class="col-md-11"><textarea id="commentContent" class="form-control" placeholder="Enter your comment here..."></textarea></div>
  	</div>
  	<div class="row">
  		<div class="col-md-1"><label>Your Rating:</label></div>
  		<div class="col-md-11">
  			<img id="star1" src='../assets/images/icons/star_grey.png' class="star-icon"/>
  			<img id="star2" src='../assets/images/icons/star_grey.png' class="star-icon"/>
  			<img id="star3" src='../assets/images/icons/star_grey.png' class="star-icon"/>
  			<img id="star4" src='../assets/images/icons/star_grey.png' class="star-icon"/>
  			<img id="star5" src='../assets/images/icons/star_grey.png' class="star-icon"/>
  		</div>
  	</div>
  	<div class="row">
  		<div class="col-md-1"></div>
  		<div class="col-md-11"><button type="button" class="btn btn-primary" id="postComment">Post Comment</button></div>
  	</div>
  </div>
</div>
<div class="btn-group btn-group-lg">
<button type="button" class="btn btn-primary" id="back" onclick="history.go(-1)">Back</button>
<button type="button" class="btn btn-success" id="next">Select route</button>
</div>
<?php include('../parts/footer.php'); ?>

