<?php
require __DIR__ . '/vendor/autoload.php';

use Ratchet\MessageComponentInterface;
use Ratchet\ConnectionInterface;
use Ratchet\Server\IoServer;
use Ratchet\Http\HttpServer;
use Ratchet\WebSocket\WsServer;

class WebSocketServer implements MessageComponentInterface
{
    protected $clients;
    private $host = "localhost";
    private $db_name = "testdb";
    private $username = "root";
    private $password = "";
    private $connection;

    public function __construct()
    {
        $this->clients = new \SplObjectStorage;
        $this->connectDatabase();
        echo "Serveur WebSocket démarré sur ws://localhost:8080\n";
    }

    private function connectDatabase()
    {
        try {
            $this->connection = new PDO(
                "mysql:host={$this->host};dbname={$this->db_name}",
                $this->username,
                $this->password,
                [PDO::ATTR_ERRMODE => PDO::ERRMODE_EXCEPTION]
            );
        } catch (PDOException $exception) {
            echo json_encode(['erreur' => $exception->getMessage()]);
        }
    }

    public function createUser($name)
    {
        if (!$this->connection) {
            $this->connectDatabase();
        }

        $stmt = $this->connection->prepare("INSERT INTO users (name) VALUES (:name)");
        $stmt->bindValue(':name', $name, PDO::PARAM_STR);
        return $stmt->execute();
    }

    public function getUser()
    {
        if (!$this->connection) {
            $this->connectDatabase();
        }

        $stmt = $this->connection->prepare("SELECT * FROM users");
        $stmt->execute();
        return $stmt->fetchAll(PDO::FETCH_ASSOC);
    }

    public function onOpen(ConnectionInterface $conn)
    {
        $this->clients->attach($conn);
        echo "Nouvelle connexion : {$conn->resourceId}\n";
        $conn->send(json_encode(["message" => "Bienvenue client #{$conn->resourceId}"]));
    }

    public function onMessage(ConnectionInterface $from, $msg)
    {
        // Décodage JSON du message reçu
        $data = json_decode($msg, true);
        if (!$data) {
            $from->send(json_encode(["error" => "Format JSON invalide."]));
            return;
        }

        $action = $data['action'] ?? '';
        $value  = $data['data'] ?? [];

        echo "Message reçu de {$from->resourceId} : " . $msg . "\n";

        switch ($action) {
            case 'add_users':
                if (!empty($value['name'])) {
                    $this->createUser($value['name']);
                }
                break;

            case 'get_users':
                $users = $this->getUser();
                $from->send(json_encode(["users" => $users]));
                return; // On envoie juste la liste à celui qui demande
        }

        // Diffusion à tous les clients
        foreach ($this->clients as $client) {
            $client->send(json_encode([
                "from"    => $from->resourceId,
                "message" => $data
            ]));
        }
    }

    public function onClose(ConnectionInterface $conn)
    {
        $this->clients->detach($conn);
        echo "Client {$conn->resourceId} déconnecté\n";
    }

    public function onError(ConnectionInterface $conn, \Exception $e)
    {
        echo "Erreur : {$e->getMessage()}\n";
        $conn->close();
    }
}

$server = IoServer::factory(
    new HttpServer(
        new WsServer(
            new WebSocketServer()
        )
    ),
    8080
);

$server->run();
