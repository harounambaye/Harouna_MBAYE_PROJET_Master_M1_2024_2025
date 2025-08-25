<?php
class Get{
    protected $pdo;
    public function __construct(\PDO $pdo){ $this->pdo = $pdo; }

    public function getAllTodos($d){
        $stmt = $this->pdo->prepare("SELECT * FROM todo_tables WHERE account_id = ?");
        $stmt->execute([$d->account_id]);
        $rows = $stmt->fetchAll(PDO::FETCH_ASSOC);
        if ($rows && count($rows) > 0) {
            return array("data" => $rows);
        } else {
            return array("data" => []); // vide = pas d'erreur
        }
    }
}
?>
