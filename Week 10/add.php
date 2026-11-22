<?php
require_once 'config.php';

$name = '';
$email = '';
$phone = '';
$groupName = 'General';
$notes = '';
$errors = [];
$groups = ['Family', 'Friends', 'Work', 'Other', 'General'];

if ($_SERVER['REQUEST_METHOD'] === 'POST') {
    $name = trim($_POST['name'] ?? '');
    $email = trim($_POST['email'] ?? '');
    $phone = trim($_POST['phone'] ?? '');
    $groupName = $_POST['group_name'] ?? 'General';
    $notes = trim($_POST['notes'] ?? '');

    if ($name === '') {
        $errors[] = 'Name cannot be empty.';
    }
    if (!filter_var($email, FILTER_VALIDATE_EMAIL)) {
        $errors[] = 'Please enter a valid email address.';
    }
    if (!in_array($groupName, $groups, true)) {
        $groupName = 'General';
        $errors[] = 'Please select a valid group.';
    }

    if (!$errors) {
        $check = $pdo->prepare('SELECT id FROM contacts WHERE email = :email');
        $check->execute(['email' => $email]);
        if ($check->fetch()) {
            $errors[] = 'This email address already exists.';
        }
    }

    if (!$errors) {
        try {
            $stmt = $pdo->prepare(
                'INSERT INTO contacts (name, email, phone, group_name, notes)
                 VALUES (:name, :email, :phone, :group_name, :notes)'
            );
            $stmt->execute([
                'name' => $name,
                'email' => $email,
                'phone' => $phone,
                'group_name' => $groupName,
                'notes' => $notes
            ]);
            set_flash('Contact added successfully!');
            redirect('index.php');
        } catch (PDOException $e) {
            $errors[] = 'Could not save the contact. Please check the information.';
        }
    }
}
?>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Add Contact | Contact Manager</title>
    <link rel="stylesheet" href="style.css">
</head>
<body>
<div class="container narrow">
    <header class="page-header">
        <div><p class="eyebrow">CONTACTS</p><h1>Add Contact</h1><p class="subtitle">Enter the new contact details.</p></div>
        <a class="button secondary" href="index.php">Back to List</a>
    </header>

    <?php if ($errors): ?>
        <div class="alert error"><ul>
            <?php foreach ($errors as $error): ?><li><?= e($error) ?></li><?php endforeach; ?>
        </ul></div>
    <?php endif; ?>

    <form class="form-card" method="POST" action="add.php">
        <label>Name <span>*</span><input type="text" name="name" maxlength="100" required value="<?= e($name) ?>"></label>
        <label>Email <span>*</span><input type="email" name="email" maxlength="150" required value="<?= e($email) ?>"></label>
        <label>Phone<input type="text" name="phone" maxlength="20" value="<?= e($phone) ?>"></label>
        <label>Group
            <select name="group_name">
                <?php foreach ($groups as $group): ?>
                    <option value="<?= e($group) ?>" <?= $groupName === $group ? 'selected' : '' ?>><?= e($group) ?></option>
                <?php endforeach; ?>
            </select>
        </label>
        <label>Notes<textarea name="notes" rows="4"><?= e($notes) ?></textarea></label>
        <div class="form-actions">
            <button class="button primary" type="submit">Save Contact</button>
            <a class="button secondary" href="index.php">Cancel</a>
        </div>
    </form>
</div>
</body>
</html>
