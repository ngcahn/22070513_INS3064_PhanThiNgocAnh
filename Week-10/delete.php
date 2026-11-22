<?php
require_once 'config.php';

$id = filter_input(INPUT_GET, 'id', FILTER_VALIDATE_INT);
if (!$id || $id < 1) {
    set_flash('Invalid contact ID.', 'error');
    redirect('index.php');
}

$stmt = $pdo->prepare('SELECT * FROM contacts WHERE id = :id');
$stmt->execute(['id' => $id]);
$contact = $stmt->fetch();

if (!$contact) {
    set_flash('Contact not found.', 'error');
    redirect('index.php');
}

if ($_SERVER['REQUEST_METHOD'] === 'POST') {
    $delete = $pdo->prepare('DELETE FROM contacts WHERE id = :id');
    $delete->execute(['id' => $id]);
    set_flash('Contact deleted successfully!');
    redirect('index.php');
}
?>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Delete Contact | Contact Manager</title>
    <link rel="stylesheet" href="style.css">
</head>
<body>
<div class="container narrow">
    <header class="page-header">
        <div><p class="eyebrow">CONTACTS</p><h1>Delete Contact</h1><p class="subtitle">Please confirm this action.</p></div>
        <a class="button secondary" href="index.php">Back to List</a>
    </header>

    <section class="confirm-card">
        <h2>Are you sure you want to delete this contact?</h2>
        <p><strong>Name:</strong> <?= e($contact['name']) ?></p>
        <p><strong>Email:</strong> <?= e($contact['email']) ?></p>
        <p><strong>Phone:</strong> <?= e($contact['phone']) ?></p>
        <form method="POST" action="delete.php?id=<?= (int)$id ?>" class="form-actions">
            <button class="button danger" type="submit">Yes, Delete Contact</button>
            <a class="button secondary" href="index.php">Cancel</a>
        </form>
    </section>
</div>
</body>
</html>
