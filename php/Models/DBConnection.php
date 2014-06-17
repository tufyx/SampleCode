<?php
namespace Models;
class DBConnection {
	
	function __construct() {
		$dbconnect = mysql_connect(DB_HOST, DB_USERNAME, DB_PASSWORD);
		mysql_select_db(DB_NAME) or die(mysql_error());
	}
	
	public function query($query_) {
		$result = mysql_query($query_) or die("Error >> ".mysql_error()."<br/>Query >> $query_");
		return $result;
	}
}
?>
