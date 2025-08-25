<?php
class Delete{
    protected $pdo;
    public function __construct(\PDO $pdo){ $this->pdo = $pdo; }

    public function deleteTodo($d){
        $stmt = $this->pdo->prepare("DELETE FROM todo_tables WHERE todo_id = ?");
        $stmt->execute([$d->todo_id]);
        $count = $stmt->rowCount();
        if ($count > 0) {
            return array("data" => "Suppression reussie $count todo(s)");
        } else {
            return array("error" => "Aucune ligne supprimée (todo_id introuvable)");
        }
    }
}
?>
