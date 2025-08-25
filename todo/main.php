<?php
require_once("./config/database.php");
require_once("./methods/post.php");
require_once("./methods/get.php");
require_once("./methods/put.php");
require_once("./methods/delete.php");

$db = new Connection();
$pdo = $db->connect();

$post = new Post($pdo);
$get = new Get($pdo);
$put = new Put($pdo);
$delete = new Delete($pdo);

    $req = [];
    if (isset($_REQUEST['request'])){
        $req = explode('/', rtrim($_REQUEST['request'], '/'));
    }else {
        $req = array("errorcatcher");
    }

    switch($_SERVER['REQUEST_METHOD']){
        case 'POST':
            switch ($req[0]){
                case 'register':
                    $d = json_decode(file_get_contents("php://input")); 
					echo json_encode($post->register($d));
                break;

                case 'login':
                    $d = json_decode(file_get_contents("php://input")); 
					echo json_encode($post->login($d));
                break;
                
                case 'inserttodo':
                    $d = json_decode(file_get_contents("php://input")); 
					echo json_encode($post->insertTodo($d));
                break;

                case 'todos':
                    $d = json_decode(file_get_contents("php://input")); 
					echo json_encode($get->getAllTodos($d));
                break;

                case 'updatetodo':
                    $d = json_decode(file_get_contents("php://input")); 
					echo json_encode($put->updateTodo($d));
                break;

                case 'deletetodo':
                    $d = json_decode(file_get_contents("php://input")); 
					echo json_encode($delete->deleteTodo($d));
                break;
       
            default: 
                echo "no endpoint";
            break;
        }
        break;
        
        default: 
            echo "prohibited";
        break;
}
?>