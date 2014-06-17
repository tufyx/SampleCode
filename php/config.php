<?php
	date_default_timezone_set('UTC');
	// db related
	define('DB_HOST','dev.tufyx.com');
	define('DB_USERNAME','root');
	define('DB_PASSWORD','Test1234');
	define('DB_NAME','localeyes_live');
	
// 	define('DB_HOST','snowiechile.netfirmsmysql.com');
// 	define('DB_USERNAME','le');
// 	define('DB_PASSWORD','local');
// 	define('DB_NAME','localeyes_live');
	
	// debug variable; set to true outputs debug messages
	define("DEBUG", FALSE);
	
	function myPrintR($resource_) {
		echo "<pre>";
		print_r($resource_);
		echo "</pre>";
	}
	
	function generateRandomString($length = 10) {
		$characters = '0123456789abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ';
		$randomString = '';
		for ($i = 0; $i < $length; $i++) {
			$randomString .= $characters[rand(0, strlen($characters) - 1)];
		}
		return $randomString;
	}
	
	function generateRandomMessage($wordCount = 20) {
		$lorem = "Sed ut perspiciatis unde omnis iste natus error sit voluptatem accusantium doloremque laudantium totam rem aperiam eaque ipsa quae ab illo inventore veritatis et quasi architecto beatae vitae dicta sunt explicabo Nemo enim ipsam voluptatem quia voluptas sit aspernatur aut odit aut fugit sed quia consequuntur magni dolores eos qui ratione voluptatem sequi nesciunt Neque porro quisquam est qui dolorem ipsum quia dolor sit amet consectetur adipisci velit sed quia non numquam eius modi tempora incidunt ut labore et dolore magnam aliquam quaerat voluptatem Ut enim ad minima veniam quis nostrum exercitationem ullam corporis suscipit laboriosam nisi ut aliquid ex ea commodi consequatur? Quis autem vel eum iure reprehenderit qui in ea voluptate velit esse quam nihil molestiae consequatur vel illum qui dolorem eum fugiat quo voluptas nulla pariatur?";
		$wordPool = explode(" ",$lorem);
		$message = '';
		for($i = 0; $i < $wordCount; $i++) {
			$message .= $wordPool[rand(1,count($wordPool))]." ";
		}
		return ucfirst(trim($message));
	}
?>