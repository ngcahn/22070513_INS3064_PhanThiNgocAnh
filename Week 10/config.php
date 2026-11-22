<?php
// Database connection and shared helper functions.
session_start();

define('DB_HOST', 'localhost');
define('DB_NAME', 'contact_manager');
define('DB_USER', 'root');
define('DB_PASS', '');

try {
    $pdo = new PDO(
        'mysql:host=' . DB_HOST . ';dbname=' . DB_NAME . ';charset=utf8mb4',
        DB_USER,
        DB_PASS
    );
    $pdo->setAttribute(PDO::ATTR_ERRMODE, PDO::ERRMODE_EXCEPTION);
    $pdo->setAttribute(PDO::ATTR_DEFAULT_FETCH_MODE, PDO::FETCH_ASSOC);
    $pdo->setAttribute(PDO::ATTR_EMULATE_PREPARES, false);
} catch (PDOException $e) {
    die('Database connection failed. Please check config.php and MySQL.');
}

function e($value) {
    return htmlspecialchars((string)($value ?? ''), ENT_QUOTES, 'UTF-8');
}

function set_flash($message, $type = 'success') {
    $_SESSION['message'] = $message;
    $_SESSION['message_type'] = $type;
}

function display_flash() {
    if (!empty($_SESSION['message'])) {
        $type = $_SESSION['message_type'] ?? 'success';
        echo '<div class="alert ' . e($type) . '">' . e($_SESSION['message']) . '</div>';
        unset($_SESSION['message'], $_SESSION['message_type']);
    }
}

function redirect($location) {
    header('Location: ' . $location);
    exit;
}
