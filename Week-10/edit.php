<?php
require_once 'config.php';

$id = filter_input(INPUT_GET, 'id', FILTER_VALIDATE_INT);
if (!$id || $id < 1) {
    set_flash('Invalid contact ID.', 'error');
    redirect('index.php');
}

$find = $pdo->prepare('SELECT * FROM contacts WHERE id = :id');
$find->execute(['id' => $id]);
$contact = $find->fetch();

if (!$contact) {
    set_flash('Contact not found.', 'error');
    redirect('index.php');
}

$name = $contact['name'];
$email = $contact['email'];
$phone = $contact['phone'];
$groupName = $contact['group_name'];
$notes = $contact['notes'];
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
        $check = $pdo->prepare('SELECT id FROM contacts WHERE email = :email AND id <> :id');
        $check->execute(['email' => $email, 'id' => $id]);
        if ($check->fetch()) {
            $errors[] = 'This email address is already used by another contact.';
        }
    }

    if (!$errors) {
        try {
            $stmt = $pdo->prepare(
                'UPDATE contacts
                 SET name = :name, email = :email, phone = :phone,
                     group_name = :group_name, notes = :notes
                 WHERE id = :id'
            );
            $stmt->execute([
                'name' => $name,
                'email' => $email,
                'phone' => $phone,
                'group_name' => $groupName,
                'notes' => $notes,
                'id' => $id
            ]);
            set_flash('Contact updated successfully!');
            redirect('index.php');
        } catch (PDOException $e) {
            $errors[] = 'Could not update the contact. Please check the information.';
        }
    }
}
?>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Edit Contact | Contact Manager</title>
    <link rel="stylesheet" href="style.css">
</head>
<body>
<div class="container narrow">
    <header class="page-header">
        <div><p class="eyebrow">CONTACTS</p><h1>Edit Contact</h1><p class="subtitle">Update the contact information.</p></div>
        <a class="button secondary" href="index.php">Back to List</a>
    </header>

    <?php if ($errors): ?>
        <div class="alert error"><ul>
            <?php foreach ($errors as $error): ?><li><?= e($error) ?></li><?php endforeach; ?>
        </ul></div>
    <?php endif; ?>

    <form class="form-card" method="POST" action="edit.php?id=<?= (int)$id ?>">
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
            <button class="button primary" type="submit">Update Contact</button>
            <a class="button secondary" href="index.php">Cancel</a>
        </div>
    </form>
</div>
</body>
</html>
