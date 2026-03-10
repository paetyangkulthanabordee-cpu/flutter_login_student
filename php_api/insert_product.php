<?php
include 'condb.php';

header('Content-Type: application/json');

$fname = $_POST['fname'];
$lname = $_POST['lname'];
$phone = $_POST['phone'];
$username = $_POST['username'];
$password = $_POST['password'];

////////////////////////////////////////////////////////////
// ✅ รับรูปภาพ
////////////////////////////////////////////////////////////

$imageName = "";

if (isset($_FILES['image'])) {

    $targetDir = "images/";   // ✅ โฟลเดอร์เก็บรูป
    $imageName = time() . "_" . basename($_FILES["image"]["fname"]);
    $targetFile = $targetDir . $imageName;

    if (!move_uploaded_file($_FILES["image"]["tmp_name"], $targetFile)) {
        echo json_encode([
            "success" => false,
            "error" => "Upload image failed"
        ]);
        exit;
    }
}

////////////////////////////////////////////////////////////
// ✅ Insert DB
////////////////////////////////////////////////////////////

try {

    $stmt = $conn->prepare("
        INSERT INTO employees (fname, lname, phone, username, password, image)
        VALUES (:fname, :lname, :phone, :username, :password, :image)
    ");

    $stmt->bindParam(":fname", $fname);
    $stmt->bindParam(":lname", $lname);
    $stmt->bindParam(":phone", $phone);
    $stmt->bindParam(":username", $username);
    $stmt->bindParam(":password", $password);
    $stmt->bindParam(":image", $imageName);

    if ($stmt->execute()) {
        echo json_encode(["success" => true]);
    } else {
        echo json_encode(["success" => false]);
    }

} catch (PDOException $e) {
    echo json_encode([
        "success" => false,
        "error" => $e->getMessage()
    ]);
}
