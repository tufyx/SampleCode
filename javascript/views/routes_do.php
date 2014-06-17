<?php include('../config/config.php');?>
<?php include('../parts/head.php'); ?>
<?php include('../parts/header.php'); ?>

<script type="text/javascript" src="<?php echo getServerName();?>assets/js/APIRequests.js"></script>
<script type="text/javascript" src="<?php echo getServerName();?>assets/js/do.js"></script>
<script type="text/javascript" src="<?php echo getServerName();?>assets/js/say-cheese.js"></script>
<link type="text/css" href="<?php echo getServerName();?>assets/css/pikachoose/localeyes.css" rel="stylesheet" />
<script type="text/javascript" src="<?php echo getServerName();?>assets/js/pikachoose/jquery.jcarousel.min.js"></script>
<script type="text/javascript" src="<?php echo getServerName();?>assets/js/pikachoose/jquery.pikachoose.js"></script>
<h1 id="title"></h1>
<div class="container">
  <div id="map-canvas"></div>
  <div id="details">
    <div class="row">
      <div class="col-xs-3" id="photo"></div>
      <div class="col-xs-9" id="description"></div>
    </div>
    <div id="comments">
    </div>
  <div id="photoCamera"></div>
  <button type="button" class="btn btn-primary" id="next">Next -></button>
</div>
<?php include('../parts/footer.php'); ?>