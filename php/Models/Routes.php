<?php
namespace Models;

class Routes {
	
	private $_dbConnection;
	private $_themes;
	private $_points;
	
	function __construct($dbConnection_) {
		$this->_dbConnection = $dbConnection_;
		$this->_themes = new Themes($dbConnection_);
		$this->_points = new Points($dbConnection_);
	}
	
	/** 
	* Creates a route and inserts it into the DB
	* @param $route_ object containing the following properties:
	* title: String, description: String, circuit: Boolean, duration: uint (in minutes), distance: uint, author_id: uint, 
	* themes: array of objects (theme_id, theme_title)
	* points: array of points (title, description, waypoint, latitude , longitude, position, route_id)
	* @return uint - the id of the created route
	* API ACCESS METHOD: POST
	*/ 
	public function create($route_) {
		if(gettype($route_['themes']) == 'string') {
			parse_str($route_['themes'],$themes);
			$route_['themes'] = $themes;
		}
		if(gettype($route_['points']) == 'string') {
			parse_str($route_['points'],$points);
			$route_['points'] = $points;
		}
		// build the query
		$query = "INSERT INTO routes
				  (title,
				   description,
				   circuit,
				   duration,
				   distance,
				   author_id,
				   created_at)
				  VALUES ('".$route_['title']."',
				  		  '".$route_['description']."',
		  		  		  ".($route_['circuit'] ? 'TRUE' : 'FALSE').",
		  		  		  ".intval($route_['duration']).",
		  		  		  ".intval($route_['distance']).",
		  		  		  ".intval($route_['author_id']).",
  		  				  NOW()
						 )";
		// send the command to the DB
		$result = $this->_dbConnection->query($query);
		// retrieve the id of the inserted route; this is used later for inserting route points and themes
		$routeID = mysql_insert_id();
		// insert themes
		foreach ($route_['themes'] as $key=>$theme) {
			// if the theme id is not set, add the new theme in the themes table
			if(!isset($theme['uid'])) {
				$theme['uid'] = $this->_themes->create($theme);
			}
			// and create the associations between the themes and the current route
			$this->addRouteTheme($routeID,$theme['uid']);
		}
		// insert points
		foreach ($route_['points'] as $key=>$point) {
			$point['route_id'] = $routeID;
			// insert the point into the points table
			$this->_points->create($point);
		}
		return $routeID;
	}
	
	/**
	 * Attaches a theme identified by $themeUID_ to the route identified by $routeUID_
	 * @param uint $routeID_ - the uid of the route for which the theme is added
	 * @param uint $themeUID_ - the uid of the theme attached to the route
	 * @return void
	 * API ACCESS METHOD: none
	 */
	private function addRouteTheme($routeID_, $themeUID_) {
		$query = "INSERT INTO themes_routes
								(route_id,
								 theme_id)
								VALUES
								(".intval($routeID_).",
								 ".intval($themeUID_).")";
		$this->_dbConnection->query($query);
	}
	
	/**
	 * Retrieves the themes associated with a route
	 * @param uint $routeID_
	 * @return array - an array of objects representing the themes associated to a route; a theme object contains the following properties: theme_id, theme_title
	 * API ACCESS METHOD: GET
	 */
	private function getThemes($routeID_) {
		$query = "SELECT t.uid AS theme_uid, t.title as title
				  FROM themes t, themes_routes tr
				  WHERE
					t.uid = tr.theme_id AND
					tr.route_id = ".intval($routeID_);
	
		$themes = array();
		$result = $this->_dbConnection->query($query);
		while($r = mysql_fetch_assoc($result)) {
			$themes[] = $r;
		}
		return $themes;
	}
	
	/**
	 * Retrieves all points for the route navigation mode.
	 * @param uint $routeID_
	 */
	private function getPoints($routeID_) {
		$query  = "SELECT uid FROM points WHERE route_id = ".intval($routeID_)." ORDER BY position ASC";
		$result = $this->_dbConnection->query($query);
		if(mysql_num_rows($result) == 0) {
			return 0;
		}
		$points = array();
		while($row = mysql_fetch_row($result)) {
			$point = $this->_points->get($row[0]);
			$point['existing'] = true;
			$points[] = $point;
		}
	
		return $points;
	
	}
	
	/**
	 * Retrieves minimal details about a route: title, description, distance, duration, themes
	 * @param uint $routeID_
	 * @return Object route - an object containing the properties of the route
	 * API ACCESS METHOD: GET
	 */
	public function getBrowse($routeID_) {
		$query  = "SELECT * FROM routes WHERE uid = ".intval($routeID_)." LIMIT 1";
		$result = $this->_dbConnection->query($query);
		$route  = mysql_fetch_assoc($result);
		if($route) {
			$route['themes'] = $this->getThemes($routeID_);
		} else {
			return false;
		}
		
		return $route;
	}
	
	/**
	 * Computes the average rating of a route
	 * @param uint $routeID_
	 * @return uint - the rounded average rating of the route
	 * API ACCESS METHOD: GET
	 */
	public function getRating($routeID_) {
		$query = "SELECT AVG(rating) as rating FROM route_comments WHERE route_id = ".intval($routeID_);
		$result = $this->_dbConnection->query($query);
		$rating = mysql_fetch_assoc($result); 
		return round($rating['rating']);
	}
	
	/**
	 * Retrieves route details for the route viewing mode (prior to route navigation mode)
	 * @param uint $routeID_
	 * @return object - an object containing the route details, average rating and comments associated to it
	 * API ACCESS METHOD: GET
	 */
	public function getDetails($routeID_) {
		$route = $this->getBrowse($routeID_);
		if($route) {
			$route['rating'] = $this->getRating($routeID_);
			$route['comments'] = $this->getComments($routeID_);
		} else {
			return false;
		}
		return $route;
	}
	
	/**
	 * Retrieves route details for the navigation mode. In adition to getDetails, it also retrieves the route`s points
	 * @param uint $routeID_ - the id of the route for which the navigation details are retrieved
	 * API ACCESS METHOD: GET
	 */
	public function getNavigation($routeID_) {
		$route = $this->getDetails($routeID_);
		if($route) {
			$route['points'] = $this->getPoints($routeID_);
			return $route;
		} else {
			return false;
		}
	}
	
	/**
	 * Deletes the themes associated to a route
	 * @param uint $routeID_ - the id of the route for which the associated themes are removed
	 * @return boolean - true if the deletion is succesful; if the operation fails, the script stops execution
	 * API ACCESS METHOD: none
	 */
	private function deleteRouteThemes($routeID_) {
		$query = "DELETE FROM themes_routes WHERE route_id = ".intval($routeID_);
		$this->_dbConnection->query($query);
		return true;
	}
	
	/**
	 * Deletes the points associated to a route
	 * @param uint $routeID_ - the id of the route for which the associated points are removed
	 * @return boolean - true if the deletion is succesful; if the operation fails, the script stops execution
	 * API ACCESS METHOD: none
	 */
	private function deleteRoutePoints($routeID_) {
		$query = "SELECT uid FROM points WHERE route_id = ".intval($routeID_);
		$result = $this->_dbConnection->query($query);
		while ($point = mysql_fetch_assoc($result)) {
			$this->_points->delete($point['uid']);
		}
	}
	
	/**
	 * Deletes all the comments associated to a route
	 * @param object $route_ - an object containing a propery route_uid
	 * @return boolean - true if the deletion is succesful; if the operation fails, the script stops execution
	 * API ACCESS METHOD: none
	 */
	private function deleteRouteComments($routeID_) {
		$query = "DELETE FROM route_comments WHERE route_id = ".intval($routeID_);
		$this->_dbConnection->query($query);
		return true;
	}
	
	/**
	 * Deletes a route and its associated dependencies: comments, themes (from the routes_themes table), points, points` media
	 * @param uint $route - an object containing a property route_id - the uid of the deleted route
	 * @return true - on success; if a problem occurs during the deletion of the dependencies or the route itself the script stops execution
	 * API ACCESS METHOD: POST - for now; will be changed to DELETE
	 */
	public function delete($route_) {
		$routeID = $route_['route_uid'];
		// delete the route comments
		$this->deleteRouteComments($routeID);
		// delete the route themes
		$this->deleteRouteThemes($routeID);
		// delete the route points
		$this->deleteRoutePoints($routeID);
		// delete the route itself
		$query = "DELETE FROM routes WHERE uid = ".intval($routeID)." LIMIT 1";
		$this->_dbConnection->query($query);
		return true;
	}
	
	/**
	 * Searches for routes according to the filters specified in the routeDetails_ object
	 * @param object $routeDetails_ - an object containing the filtering options (not all the filters are mandatory); possible filters: duration, distance, theme, keywords
	 * @return array - an array containing the browse representation of the routes which fulfill the search criteria
	 * API ACCESS METHOD: POST - for now; intended to change to GET
	 */
	public function search($routeFilters_) {
		$durationFilter = null;
		$distanceFilter = null;
		$keywordFilter = null;
		if(count($routeFilters_)) {
			foreach($routeFilters_ as $key=>$value) {
				switch ($key) {
					case 'duration':
						$durationFilter = "duration < ".intval($value);
						break;
					case 'distance':
						$distanceFilter = "distance < ".intval($value);
						break;
					case 'theme':
						break;
					case 'keywords':
						$keywordFilterArray = array();
						$words = explode(" ",$value);
						foreach($words as $k_word=>$word) {
							$keywordFilterArray[] = "title LIKE '%".$word."%'";
							$keywordFilterArray[] = "description LIKE '%".$word."%'";
						}
						$keywordFilter = "(".implode(" OR ",$keywordFilterArray).")";
						break;
				}
			}
		}
		$filters = array();
		if($durationFilter) {
			$filters[] = $durationFilter;
		} 
		if($distanceFilter) {
			$filters[] = $distanceFilter;
		}
		if($keywordFilter) {
			$filters[] = $keywordFilter;
		}
		
		$totalFilter = implode(" AND ",$filters);
		if(strlen($totalFilter) > 0) {
			$totalFilter = " WHERE ".$totalFilter;
		}
		$query = "SELECT uid FROM routes".$totalFilter;
		$result = $this->_dbConnection->query($query);
		if($result && mysql_num_rows($result) > 0) {
			$searchResults = array();
			while($route = mysql_fetch_assoc($result)) {
				$searchResults[] = $this->getBrowse($route['uid']);
			}
			return $searchResults;
		} else {
			return false;
		}
	}
	
	/**
	 * Updates the details of a route with the information sent in the $route object parameter; 
	 * @param object $route_; the structure of the $route object is as follows:
	 * title - String, description - String, duration - uint, distance - uint, route_uid - uint, 
	 * themes - array representing the new themes selected for the edited route
	 * points - array representing the new points selected for the edited route
	 * @return int - the id of the edited route
	 * API ACCESS METHOD: POST
	 */
	public function edit($route_) {
		if(gettype($route_['themes']) == 'string') {
			parse_str($route_['themes'],$themes);
			$route_['themes'] = $themes;
		}
		$updates = array();
		foreach ($route_ as $routeDetail=>$detailValue) {
			switch($routeDetail) {
				//for the title and description a string needs to be updated, hence quotes are required
				case 'title':
				case 'description':
					$updateString = $routeDetail." = '".$detailValue."'";
					$updates[] = $updateString;
					break;
				// for duration and distance an int value needs to be updated, hence intvalue is used, and no quotes	
				case 'duration':
				case 'distance':
				case 'circuit':
					$updateString = $routeDetail." = ".intval($detailValue);
					$updates[] = $updateString;
					break;
				case 'route_uid':
					$whereClause = " WHERE uid = ".intval($detailValue);
					break;	
			}
		}
		//update the entry in the routes table
		$query = "UPDATE routes SET ".implode(", ",$updates).$whereClause;
		$this->_dbConnection->query($query);
		// NO NEED TO UPDATE THE POINTS; THEY ARE UPDATED SEPARATELY, FROM A DIFFERENT USER INTERACTION
		//update the themes
		$this->updateRouteThemes($route_['route_uid'],$route_['themes']);
		return intval($route_['route_uid']);
	}
	
	/**
	 * Updates the associations between a route and its themes. The existing themes are deleted and the newly specified ones are added
	 * @param uint $routeID_ - the uid of the route being updated
	 * @param array $themes_ - array of objects representing themes; an element in the array has the following structure: uid - the uid of the selected theme, title - the title of the theme
	 * @return void
	 * API ACCESS METHOD: none
	 */
	private function updateRouteThemes($routeID_, $themes_) {
		// delete all the themes currently associated with the indicated route
		$query = "DELETE FROM themes_routes WHERE route_id = ".intval($routeID_);
		$this->_dbConnection->query($query);
		
		//insert the new association indicated in the $themes_ array
		foreach($themes_ as $key=>$theme) {
			$this->addRouteTheme($routeID_,$theme['uid']);
		}
	}
	
	/**
	 * Updates the list of points attached to a route
	 * @param uint $routeID_ - the id of the route being edited
	 * @param array $points_ - an array containing all the points with their updated positions and marked as removed or not;
	 * an element in the array has the following structure: deleted - boolean flag, position - uint, point_uid - uint
	 * @return array - the updated list of the points
	 * API ACCESS METHOD: POST
	 */
	public function updatePoints($data_) {
		$routeID = $data_['route_id'];
		// select the old points of the route for comparison
		$oldPoints = $this->getPoints($routeID);
		$newPoints = $data_['points'];
		
		$oldIDS = array();
		foreach($oldPoints as $key=>$old) {
			$oldIDS[] = $old['uid'];
		}
		
		$newIDS = array();
		foreach($newPoints as $key=>$new) {
			if(!$new['deleted']) {
				$newIDS[] = $new['uid'];				
			}
		}
		$deleted = array();
		foreach($oldIDS as $key=>$old_id) {
			if(!in_array($old_id,$newIDS)) {
				$p['point_uid'] = $old_id;
				$this->_points->delete($p);
			}
		}
		return true;
	}
	
	/**
	 * Inserts a new comment into the route_comments table
	 * @param object $routeComment_ - an object containing the required information about a comment: content, the author's id, the route to which the comment is attached, the rating of the user
	 * @return uint - the uid of the created route comment
	 * API ACCESS METHOD: POST
	 */
	public function createComment($routeComment_) {
		$query = "INSERT INTO route_comments
				  (content,
				   route_id,
				   author_id,
				   rating)
				  VALUES ('".$routeComment_['content']."',
				  		  ".intval($routeComment_['route_id']).",
				  		  ".intval($routeComment_['author_id']).",
				  		  ".intval($routeComment_['rating']).")";
		$this->_dbConnection->query($query);
		return mysql_insert_id();
	}
	
	/**
	 * Retrieves all the comments associated to a route
	 * @param uint $routeID_ - the id of the route for which the comments are being retrieved
	 * @return array - an array containing all the comments of a route; an element of the array contains the following properties: uid, content, author_id, author_name, rating
	 * API ACCESS METHOD: GET
	 */
	private function getComments($routeID_) {
		$query = "SELECT rc.uid AS uid,
						 rc.content AS content,
						 rc.author_id AS author_id,
						 u.username AS author_name,
						 rc.rating AS rating
				  FROM route_comments rc, users u
				  WHERE
					u.uid = rc.author_id AND
					rc.route_id = ".intval($routeID_);
		$result = $this->_dbConnection->query($query);
	
		$comments = array();
		while($comment = mysql_fetch_assoc($result)) {
			$comments[] = $comment;
		}
		return $comments;
	}
	
	/**
	 * Retrieves all the routes created by a user identified through author_id
	 * @param uint $authorID_ - the uid of the author who created the routes
	 * @return array - an array of routes
	 */
	public function getForUser($authorID_) {
		$query = "SELECT uid FROM routes WHERE author_id = ".intval($authorID_)." ORDER BY created_at DESC";
		$result = $this->_dbConnection->query($query);
		$userRoutes = array();
		while($route = mysql_fetch_assoc($result)) {
			$route = $this->getNavigation($route['uid']);
			$userRoutes[] = $route;
		}
		return $userRoutes;
	}
}
?>