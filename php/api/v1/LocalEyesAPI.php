<?php
include('../../config.php');
include('../../Models/DBConnection.php');
include('../../Models/Routes.php');
include('../../Models/Themes.php');
include('../../Models/Users.php');
include('../../Models/Points.php');

require_once 'API.class.php';
class LocalEyesAPI extends API
{
	public $Routes;
	protected $Themes;
	protected $Users;
	protected $Points;
	protected $DBConnection;

	public function __construct($request, $origin) {
		parent::__construct($request);

		// Abstracted out for example
// 		$APIKey = new Models\APIKey();
		$DBConnection = new Models\DBConnection();
		$Users = new Models\Users($DBConnection);
		$Routes = new Models\Routes($DBConnection);
		$Themes = new Models\Themes($DBConnection);
		$Points = new Models\Points($DBConnection);

// 		if (!array_key_exists('apiKey', $this->request)) {
// 			throw new Exception('No API Key provided');
// 		} else if (!$APIKey->verifyKey($this->request['apiKey'], $origin)) {
// 			throw new Exception('Invalid API Key');
// 		} else if (array_key_exists('token', $this->request) && 
// 					!$User->get('token', $this->request['token'])) {
// 			throw new Exception('Invalid User Token');
// 		}

		$this->Routes = $Routes;
		$this->Themes = $Themes;
		$this->Users = $Users;
		$this->Points = $Points;
	}
	
	public function processLocalEyesAPI() {
		switch(strtolower($this->endpoint)) {
			case 'routes':
				$c = $this->Routes;
				break;
			case 'users':
				$c = $this->Users;
				break;
			case 'themes':
				$c = $this->Themes;
				break;
			case 'points':
				$c = $this->Points;
				break;
		}
		return $this->processAPI($c);
	}
}


// Requests from the same server don't have a HTTP_ORIGIN header
if (!array_key_exists('HTTP_ORIGIN', $_SERVER)) {
	$_SERVER['HTTP_ORIGIN'] = $_SERVER['SERVER_NAME'];
}

try {
	$API = new LocalEyesAPI($_REQUEST['request'], $_SERVER['HTTP_ORIGIN']);
	echo $API->processLocalEyesAPI();
} catch (Exception $e) {
	echo json_encode(Array('error' => $e->getMessage()));
}
?>