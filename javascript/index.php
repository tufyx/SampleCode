<?php include('config/config.php');?>
<?php include(ROOT.'parts/head.php'); ?>
<?php include(ROOT.'parts/header.php');?>

<script type="text/javascript" src="<?php echo getServerName();?>assets/js/APIRequests.js"></script>
<script type="text/javascript" src="<?php echo getServerName();?>assets/js/login.js"></script>

<div class="panel panel-primary login-box">
  <div class="panel-heading">
    <h3 class="panel-title">Login</h3>
  </div>
  <div class="panel-body">
  	<div class="row">
  		<div class="col-md-1"><label>Your Username:</label></div>
  		<div class="col-md-11"><input type="text" id="username" class="form-control" placeholder="Your username here..."></div>
  	</div>
  	<div class="row">
  		<div class="col-md-1"><label>Your Password:</label></div>
  		<div class="col-md-11"><input type="password" id="password" class="form-control" placeholder="Password..."></div>
  	</div>
  	<div class="row">
  		<div class="col-md-1"></div>
  		<div class="col-md-1"><button type="button" class="btn btn-primary" id="login">Login</button></div>
  	</div>
	<div class="row">
  		<div class="col-md-1"></div>
  		<div class="col-md-11"><div id="response"></div></div>
  	</div>
  </div>
</div>
<?php include(ROOT.'parts/footer.php'); ?>