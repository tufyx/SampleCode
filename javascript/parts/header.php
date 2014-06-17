<body>
	<div class="mobileMenu">
		<nav>
			<a href="routes_find.php"><i class="fa fa-search"></i> Search</a>
			<a href="creation.php"><i class="fa fa-plus-square-o"></i> Create route</a>
			<a href="userprofile.php"><i class="fa fa-user"></i> My Info</a>
			<a href="<?php echo getServername();?>index.php" onclick="logoutUser(event);">Logout</a>
			<!--<h3>test links:</h3>
			<a href="creation.php">creation</a>
			<a href="routes_find.php">route: find (step 1)</a>
			<a href="routes_browse.php">route: browse (step 2)</a>
			<a href="routes_details.php">route: details (step 3)</a>
			<a href="routes_do.php">route: do (step 4)</a>-->
		</nav>
	</div>
	<div class="nav-button toggleMenu">
		<i class="fa fa-bars fa-3x"></i>
	</div>
	<div class="mobileContent" id="mobileContent">