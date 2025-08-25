<?php
    class Post{
        protected $pdo;

        public function __construct(\PDO $pdo){
            $this->pdo = $pdo;
        }

        public function insertTodo($d){
            $stmt = $this->pdo->prepare(
            "INSERT INTO todo_tables (account_id, date, todo, done) VALUES (?, ?, ?, ?)"
            );
            $ok = $stmt->execute([
                $d->account_id,
                $d->date,
                $d->todo,
                $d->done ? 1 : 0,
            ]);
            if($ok){
                $id = $this->pdo->lastInsertId();
                return array("data" => array("todo_id" => intval($id)));
            } else {
                return array("error" => "Impossible d'inserer cette tache");
            }
        }

        public function login($d){
            $stmt = $this->pdo->prepare(
            "SELECT account_id, email FROM accounts_table WHERE email=? AND password=? LIMIT 1"
            );
            $stmt->execute([$d->email, $d->password]);
            $res = $stmt->fetch(PDO::FETCH_ASSOC);
            if ($res) {
                return array("data" => $res);
            } else {
                return array("error"=>"Email ou mot de passe incorrect");
            }
        }

        public function register($d){
            $stmt = $this->pdo->prepare("SELECT 1 FROM accounts_table WHERE email=? LIMIT 1");
            $stmt->execute([$d->email]);
            if ($stmt->fetch()) {
                return array("error"=>"Ce compte existe deja");
            } else {
                $stmt2 = $this->pdo->prepare("INSERT INTO accounts_table (email, password) VALUES (?, ?)");
                $ok = $stmt2->execute([$d->email, $d->password]);
                if ($ok) return array("data"=>"Inscription Reussie");
                return array("error"=>"Echec inscription");
            }
        }

    }

?>