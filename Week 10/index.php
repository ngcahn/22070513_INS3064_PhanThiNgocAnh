<?php
require_once 'config.php';

$search = trim($_GET['search'] ?? '');
$allowedSorts = ['name', 'email', 'phone', 'group_name', 'created_at'];
$sort = $_GET['sort'] ?? 'created_at';
$order = strtolower($_GET['order'] ?? 'desc');

if (!in_array($sort, $allowedSorts, true)) {
    $sort = 'created_at';
}
if (!in_array($order, ['asc', 'desc'], true)) {
    $order = 'desc';
}

if ($search !== '') {
    $stmt = $pdo->prepare(
        'SELECT * FROM contacts
         WHERE name LIKE :search_name OR email LIKE :search_email
         ORDER BY ' . $sort . ' ' . $order
    );

    $keyword = '%' . $search . '%';

    $stmt->execute([
        'search_name' => $keyword,
        'search_email' => $keyword
    ]);
} else {
    // $sort and $order are selected from fixed allow-lists above.
    $stmt = $pdo->prepare('SELECT * FROM contacts ORDER BY ' . $sort . ' ' . $order);
    $stmt->execute();
}
$contacts = $stmt->fetchAll();

if ($search !== '') {
    $countStmt = $pdo->prepare(
        'SELECT COUNT(*) FROM contacts
         WHERE name LIKE :search_name OR email LIKE :search_email'
    );

    $keyword = '%' . $search . '%';

    $countStmt->execute([
        'search_name' => $keyword,
        'search_email' => $keyword
    ]);
} else {
    $countStmt = $pdo->prepare('SELECT COUNT(*) FROM contacts');
    $countStmt->execute();
}

$total = (int)$countStmt->fetchColumn();

function sort_link($label, $column, $currentSort, $currentOrder, $search) {
    $nextOrder = ($currentSort === $column && $currentOrder === 'asc') ? 'desc' : 'asc';
    $url = '?sort=' . urlencode($column) . '&order=' . $nextOrder . '&search=' . urlencode($search);
    return '<a href="' . e($url) . '">' . e($label) . '</a>';
}
?>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Contact Manager</title>
    <link rel="stylesheet" href="style.css">
</head>
<body>
<div class="container">
    <header class="page-header">
        <div>
            <p class="eyebrow">INS3064 · Homework 10</p>
            <h1>Contact Manager</h1>
            <p class="subtitle">Manage your contacts in one simple place.</p>
        </div>
        <a class="button primary" href="add.php">+ Add New Contact</a>
    </header>

    <?php display_flash(); ?>

    <section class="toolbar">
        <div class="total-card">
            <span class="total-number"><?= $total ?></span>
            <span class="total-label">Contacts found</span>
        </div>
        <form class="search-form" method="GET" action="index.php">
            <input type="text" name="search" placeholder="Search by name or email..."
                   value="<?= e($search) ?>">
            <button class="button primary" type="submit">Search</button>
            <?php if ($search !== ''): ?>
                <a class="button secondary" href="index.php">Clear</a>
            <?php endif; ?>
        </form>
    </section>

    <div class="table-wrap">
        <table>
            <thead>
            <tr>
                <th><?= sort_link('Name', 'name', $sort, $order, $search) ?></th>
                <th><?= sort_link('Email', 'email', $sort, $order, $search) ?></th>
                <th><?= sort_link('Phone', 'phone', $sort, $order, $search) ?></th>
                <th><?= sort_link('Group', 'group_name', $sort, $order, $search) ?></th>
                <th><?= sort_link('Created At', 'created_at', $sort, $order, $search) ?></th>
                <th>Actions</th>
            </tr>
            </thead>
            <tbody>
            <?php if ($contacts): ?>
                <?php foreach ($contacts as $contact): ?>
                    <tr>
                        <td class="name-cell"><?= e($contact['name']) ?></td>
                        <td><?= e($contact['email']) ?></td>
                        <td><?= e($contact['phone']) ?></td>
                        <td><span class="group-tag"><?= e($contact['group_name']) ?></span></td>
                        <td><?= e($contact['created_at']) ?></td>
                        <td class="actions">
                            <a href="edit.php?id=<?= (int)$contact['id'] ?>">Edit</a>
                            <a class="delete-link" href="delete.php?id=<?= (int)$contact['id'] ?>">Delete</a>
                        </td>
                    </tr>
                <?php endforeach; ?>
            <?php else: ?>
                <tr><td colspan="6" class="empty-state">No contacts found.</td></tr>
            <?php endif; ?>
            </tbody>
        </table>
    </div>
    <footer class="footer">INS3064 · PHP with MySQL · PDO</footer>
</div>
</body>
</html>
