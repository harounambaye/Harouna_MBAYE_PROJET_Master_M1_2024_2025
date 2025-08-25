<?php
class Put {
    protected $pdo;
    public function __construct(\PDO $pdo){ $this->pdo = $pdo; }

    public function updateTodo($d){
        // done doit être 0/1
        $done = ($d->done ? 1 : 0);
        $stmt = $this->pdo->prepare("UPDATE todo_tables SET date = ?, todo = ?, done = ? WHERE todo_id = ?");
        $stmt->execute([$d->date, $d->todo, $done, $d->todo_id]);
        $count = $stmt->rowCount();
        if ($count > 0) {
            return array("data" => "Mise a jour reussie $count todo(s)");
        } else {
            // pas d’erreur SQL mais rien modifié (même contenu ou id inexistant)
            return array("data" => "Aucune modification (valeurs identiques ou id introuvable)");
        }
    }
}
?>
