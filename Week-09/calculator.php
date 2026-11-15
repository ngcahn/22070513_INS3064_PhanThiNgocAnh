
<?php
// Student: Phan Thi Ngoc Anh
// Student ID: 22070513
// Course: INS3064
// Homework 9: Error Handling and Debugging
// Date: 15/11/2026

session_start();

error_reporting(E_ALL);
ini_set('display_errors', 0);

// Initialize session history
if (!isset($_SESSION['history'])) {
    $_SESSION['history'] = [];
}

// Custom Exception 1
class DivisionByZeroException extends Exception {
    public function __construct($message) {
        parent::__construct($message);
    }
}

// Custom Exception 2
class InvalidOperatorException extends Exception {
    public function __construct($message) {
        parent::__construct($message);
    }
}

// Custom Exception 3
class InvalidInputException extends Exception {
    public function __construct($message) {
        parent::__construct($message);
    }
}

// Log every caught error
function logCalculatorError($exception, $expression) {
    $date = date('Y-m-d H:i:s');
    $type = get_class($exception);
    $message = $exception->getMessage();
    $ip = $_SERVER['REMOTE_ADDR'] ?? 'Unknown';

    $log = "[$date] $type: $message | Input: \"$expression\" | IP: $ip" . PHP_EOL;

    file_put_contents(
        __DIR__ . '/calculator_errors.log',
        $log,
        FILE_APPEND | LOCK_EX
    );
}

// Variables
$message = '';
$messageType = '';
$firstNumber = '';
$secondNumber = '';
$operator = '';
$result = null;
$expression = '';

// Handle form submission
if ($_SERVER['REQUEST_METHOD'] === 'POST') {

    // Clear calculation history
    if (isset($_POST['clear_history'])) {
        $_SESSION['history'] = [];
        $message = 'Calculation history cleared successfully!';
        $messageType = 'success';
    }

    // Calculate
    elseif (isset($_POST['calculate'])) {

        $firstNumber = trim($_POST['first_number'] ?? '');
        $secondNumber = trim($_POST['second_number'] ?? '');
        $operator = $_POST['operator'] ?? '';

        $expression = "$firstNumber $operator $secondNumber";

        try {
            // Validate numeric input
            if (
                $firstNumber === '' ||
                $secondNumber === '' ||
                !is_numeric($firstNumber) ||
                !is_numeric($secondNumber)
            ) {
                throw new InvalidInputException(
                    'Please enter valid numeric values for both numbers.'
                );
            }

            $a = (float)$firstNumber;
            $b = (float)$secondNumber;

            // Check supported operators
            $validOperators = ['+', '-', '*', '/', '%', '**'];

            if (!in_array($operator, $validOperators, true)) {
                throw new InvalidOperatorException(
                    'Invalid operator. Please select a supported operator.'
                );
            }

            // Perform calculation
            switch ($operator) {

                case '+':
                    $result = $a + $b;
                    break;

                case '-':
                    $result = $a - $b;
                    break;

                case '*':
                    $result = $a * $b;
                    break;

                case '/':
                    if ($b == 0) {
                        throw new DivisionByZeroException(
                            'Cannot divide by zero. Please enter a non-zero second number.'
                        );
                    }
                    $result = $a / $b;
                    break;

                case '%':
                    if ($b == 0) {
                        throw new DivisionByZeroException(
                            'Cannot calculate modulo by zero.'
                        );
                    }
                    $result = fmod($a, $b);
                    break;

                case '**':
                    $result = $a ** $b;
                    break;
            }

            // Check overflow
            if (is_infinite($result) || is_nan($result)) {
                throw new OverflowException(
                    'The result exceeds the supported numeric limits.'
                );
            }

            // Format result
            if ($operator === '/') {
                $formattedResult = number_format($result, 4, '.', '');
            } elseif (floor($result) == $result) {
                $formattedResult = (string)(int)$result;
            } else {
                $formattedResult = (string)$result;
            }

            // Build expression
            $fullExpression = "$firstNumber $operator $secondNumber = $formattedResult";

            // Save successful calculation
            $_SESSION['history'][] = [
                'expression' => $fullExpression,
                'result' => $formattedResult,
                'timestamp' => date('Y-m-d H:i:s')
            ];

            $message = 'Calculation completed successfully!';
            $messageType = 'success';

        } catch (InvalidInputException $e) {

            logCalculatorError($e, $expression);
            $message = $e->getMessage();
            $messageType = 'error';

        } catch (InvalidOperatorException $e) {

            logCalculatorError($e, $expression);
            $message = $e->getMessage();
            $messageType = 'error';

        } catch (DivisionByZeroException $e) {

            logCalculatorError($e, $expression);
            $message = $e->getMessage();
            $messageType = 'error';

        } catch (OverflowException $e) {

            logCalculatorError($e, $expression);
            $message = $e->getMessage();
            $messageType = 'error';

        } catch (Throwable $e) {

            logCalculatorError($e, $expression);
            $message = 'An unexpected error occurred. Please try again.';
            $messageType = 'error';
        }
    }
}

// Display history from newest to oldest
$history = array_reverse($_SESSION['history']);

function safeOutput($value) {
    return htmlspecialchars((string)$value, ENT_QUOTES, 'UTF-8');
}
?>

<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">

    <title>Robust Calculator - INS3064</title>

    <style>
        * {
            box-sizing: border-box;
        }

        body {
            font-family: Arial, sans-serif;
            background: #f3f4f6;
            margin: 0;
            padding: 30px 15px;
            color: #333;
        }

        .container {
            max-width: 750px;
            margin: auto;
        }

        h1 {
            text-align: center;
            color: #1e3a5f;
            margin-bottom: 8px;
        }

        .subtitle {
            text-align: center;
            color: #777;
            margin-bottom: 30px;
        }

        .card {
            background: white;
            padding: 25px;
            border-radius: 10px;
            margin-bottom: 20px;
            box-shadow: 0 2px 10px rgba(0,0,0,0.08);
        }

        label {
            display: block;
            font-weight: bold;
            margin-bottom: 8px;
        }

        input, select {
            width: 100%;
            padding: 12px;
            border: 1px solid #ccc;
            border-radius: 6px;
            margin-bottom: 18px;
            font-size: 16px;
        }

        button {
            padding: 12px 20px;
            border: none;
            border-radius: 6px;
            cursor: pointer;
            font-size: 15px;
            font-weight: bold;
        }

        .calculate-btn {
            background: #2563eb;
            color: white;
            width: 100%;
        }

        .calculate-btn:hover {
            background: #1d4ed8;
        }

        .clear-btn {
            background: #dc2626;
            color: white;
        }

        .message {
            padding: 14px;
            border-radius: 6px;
            margin-bottom: 20px;
            font-weight: bold;
        }

        .success {
            background: #dcfce7;
            color: #166534;
        }

        .error {
            background: #fee2e2;
            color: #991b1b;
        }

        .result-box {
            background: #eff6ff;
            padding: 18px;
            border-radius: 6px;
            margin-top: 20px;
            text-align: center;
        }

        .result-value {
            font-size: 28px;
            font-weight: bold;
            color: #2563eb;
        }

        table {
            width: 100%;
            border-collapse: collapse;
            margin-top: 15px;
        }

        th, td {
            padding: 12px;
            text-align: left;
            border-bottom: 1px solid #ddd;
        }

        th {
            background: #eff6ff;
            color: #1e3a5f;
        }

        .history-header {
            display: flex;
            justify-content: space-between;
            align-items: center;
            gap: 10px;
        }

        .empty {
            text-align: center;
            color: #888;
            padding: 20px;
        }

        footer {
            text-align: center;
            color: #888;
            font-size: 13px;
            margin-top: 25px;
        }

        @media (max-width: 500px) {
            .card {
                padding: 16px;
            }

            table {
                font-size: 12px;
            }

            th, td {
                padding: 8px 4px;
            }
        }
    </style>
</head>

<body>

<div class="container">

    <h1>Robust Calculator</h1>
    <p class="subtitle">
        INS3064 - Error Handling and Debugging
    </p>

    <div class="card">

        <h2>Calculator</h2>

        <?php if ($message !== ''): ?>
            <div class="message <?php echo safeOutput($messageType); ?>">
                <?php echo safeOutput($message); ?>
            </div>
        <?php endif; ?>

        <form method="POST" action="">

            <label>First Number</label>

            <input
                type="text"
                name="first_number"
                placeholder="Enter first number"
                value="<?php echo safeOutput($firstNumber); ?>"
                required
            >

            <label>Operator</label>

            <select name="operator">
                <option value="+" <?php echo $operator === '+' ? 'selected' : ''; ?>>Addition (+)</option>
                <option value="-" <?php echo $operator === '-' ? 'selected' : ''; ?>>Subtraction (-)</option>
                <option value="*" <?php echo $operator === '*' ? 'selected' : ''; ?>>Multiplication (*)</option>
                <option value="/" <?php echo $operator === '/' ? 'selected' : ''; ?>>Division (/)</option>
                <option value="%" <?php echo $operator === '%' ? 'selected' : ''; ?>>Modulo (%)</option>
                <option value="**" <?php echo $operator === '**' ? 'selected' : ''; ?>>Power (**)</option>
            </select>

            <label>Second Number</label>

            <input
                type="text"
                name="second_number"
                placeholder="Enter second number"
                value="<?php echo safeOutput($secondNumber); ?>"
                required
            >

            <button type="submit" name="calculate" class="calculate-btn">
                Calculate
            </button>

        </form>

        <?php if ($messageType === 'success' && $result !== null): ?>

            <div class="result-box">
                <p>Calculation Result</p>
                <div class="result-value">
                    <?php echo safeOutput($formattedResult); ?>
                </div>
                <p>
                    <?php echo safeOutput($firstNumber . ' ' . $operator . ' ' . $secondNumber); ?>
                    =
                    <?php echo safeOutput($formattedResult); ?>
                </p>
            </div>

        <?php endif; ?>

    </div>

    <div class="card">

        <div class="history-header">
            <h2>Calculation History</h2>

            <form method="POST" action="">
                <button
                    type="submit"
                    name="clear_history"
                    class="clear-btn"
                    onclick="return confirm('Are you sure you want to clear history?');"
                >
                    Clear History
                </button>
            </form>
        </div>

        <?php if (count($history) > 0): ?>

            <table>
                <thead>
                    <tr>
                        <th>Expression</th>
                        <th>Result</th>
                        <th>Time</th>
                    </tr>
                </thead>

                <tbody>
                    <?php foreach ($history as $item): ?>
                        <tr>
                            <td><?php echo safeOutput($item['expression']); ?></td>
                            <td><?php echo safeOutput($item['result']); ?></td>
                            <td><?php echo safeOutput($item['timestamp']); ?></td>
                        </tr>
                    <?php endforeach; ?>
                </tbody>
            </table>

        <?php else: ?>

            <p class="empty">No calculation history yet.</p>

        <?php endif; ?>

    </div>

    <footer>
        INS3064 - Homework 9 | Phan Thi Ngoc Anh | 22070513
    </footer>

</div>

</body>
</html>
