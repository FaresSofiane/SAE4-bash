#!/bin/bash
cat << EOF > "SAE4-main/README.md"
# MYBASE

Dépot Git du projet de SAE effectué a l'Université Picardie Jules Vernes de Amiens dans le cadre de la deuxieme année de licence informatique.
EOF

cat << EOF > "SAE4-main/connex.inc.php"
<?php
function connex($base,$param)
{
    include_once($param.".inc.php");


    $idcom=@mysqli_connect(MYHOST,MYUSER,MYPASS,$base);
    if(!$idcom)
    {
        echo "<script type=text/javascript>";
        echo "alert('Connexion Impossible à la base $base')</script>";
    }
    return $idcom;
}
?>
EOF

cat << EOF > "SAE4-main/dashboard.php"
<?php

session_start();

if (!isset($_SESSION["nom_utilisateur"])) {
    header("Location: index.php");
    exit();
}

?>



<html>
<head>

    <title>Parc d'attraction</title>
    <link rel="stylesheet" type="text/css" href="assets/css/styles.css">
    <link rel="stylesheet" type="text/css" href="assets/font/Source_Sans_Pro/font.css">
            <meta charset="UTF-8">
    <script src="https://ajax.googleapis.com/ajax/libs/jquery/3.3.1/jquery.min.js"></script>
    <script>const navLinks = document.querySelectorAll('nav ul li a');

        navLinks.forEach(link => {
            link.addEventListener('click', function() {
                navLinks.forEach(link => link.classList.remove('active'));
                this.classList.add('active');
            });
        });
    </script>
    <meta charset="UTF-8">
</head>
<body>
<div class="header">
    <h1>Starlight Park</h1>
    <nav>
        <ul>
            <?php if ($_SESSION["role"]=="directeur" || $_SESSION['role'] =="cm" || $_SESSION['role'] == "responsable"){echo '<li><a href="admin">Admin</a></li>';}?>

            <li><a href="index.php">Accueil</a></li>
            <li><a href="#">Vente</a></li>
            <li><a href="manege">Manege</a></li>
            <li class="dropdown">
                <a href="#"><?php echo $_SESSION["nom_utilisateur"]?></a>
                <div class="dropdown-content">
                    <a href="compte">Mon compte</a>
                    <a href="deconnection.php" class="deconnexion-btn">Déconnexion</a>

                </div>
            </li>
        </ul>
    </nav>
</div>

</body>

</html>
EOF

cat << EOF > "SAE4-main/deconnection.php"
<?php
session_start();
session_destroy();
header('Location: index.php');
exit;
?>
EOF

cat << EOF > "SAE4-main/index.php"
<?php
session_start();

if (isset($_SESSION["nom_utilisateur"])) {
    header("Location: dashboard.php");
    exit();
} else {
    echo '<html>
        <head>
            <title>Parc d\'attraction</title>
            <link rel="stylesheet" type="text/css" href="assets/css/styles.css">
            <link rel="stylesheet" type="text/css" href="assets/font/Source_Sans_Pro/font.css">
            <meta charset="UTF-8">
            
        </head>
        <body>
            <div id="login">
                <form action="login.php" method="post" name="login_form" class="login-form">
                    <a class="input-text">Numéro de sécurité sociale</a>
                    <input type="text" name="ssn" required/>
                    <br>
                    <a class="input-text">Mot de passe</a>
                    <input type="password" name="password" id="password" required/>
                    <br>
                    <input type="submit" name="submit" value="Connexion" class="login-button" />
                </form>
            </div>
        </body>
    </html>';
}
?>
EOF

cat << EOF > "SAE4-main/login.php"
<?php

Include("connex.inc.php");
Include("myparam.inc.php");

$idcom = connex(MYBASE, "myparam");
session_start();

function chercherRole($numero_ss) {

    Include("myparam.inc.php") ;;
    $conn=connex(MYBASE, "myparam") ;

    $sql = "SELECT * FROM directeur WHERE Numero_SS = '$numero_ss'";
    $result = $conn->query($sql);
    if ($result->num_rows > 0) {
        return "directeur";
    }

    $sql = "SELECT * FROM cm WHERE Numero_SS = '$numero_ss'";
    $result = $conn->query($sql);
    if ($result->num_rows > 0) {
        return "cm";
    }

    $sql = "SELECT * FROM technicien WHERE Numero_SS = '$numero_ss'";
    $result = $conn->query($sql);
    if ($result->num_rows > 0) {
        return "technicien";
    }

    $sql = "SELECT * FROM responsable WHERE Numero_SS = '$numero_ss'";
    $result = $conn->query($sql);
    if ($result->num_rows > 0) {
        return "responsable";
    }

    $sql = "SELECT * FROM employe WHERE Numero_SS = '$numero_ss'";
    $result = $conn->query($sql);
    if ($result->num_rows > 0) {
        return "employe";
    }

}


if (isset($_POST['submit'])) {

    $ssn = $_POST['ssn'];
    $password = $_POST['password'];
    $hashed_password = hash('sha256', $password);

    $stmt = mysqli_prepare($idcom, "SELECT * FROM personnel WHERE Numero_SS = ? AND Mot_de_passe = ?");
    mysqli_stmt_bind_param($stmt, "ss", $ssn, $hashed_password);
    mysqli_stmt_execute($stmt);
    $result = mysqli_stmt_get_result($stmt);

    if (mysqli_num_rows($result) > 0) {

        $_SESSION['id'] = session_id();
        $_SESSION['ssn'] = $ssn;

        echo 'Vous êtes connecté.';
        $row = mysqli_fetch_assoc($result);
        $_SESSION['nom_utilisateur'] = $row["Nom"];
        $_SESSION['nom'] = $row["Nom"];
        $_SESSION['prenom'] = $row["Prenom"];
        $_SESSION['numero_ss'] = $row["Numero_SS"];
        $_SESSION['role'] = chercherRole($row["Numero_SS"]);

        if ($_SESSION['role'] == "cm") {
            $stmt = mysqli_prepare($idcom, "SELECT id_cm FROM cm WHERE Numero_SS = ?");
            mysqli_stmt_bind_param($stmt, "s", $row["Numero_SS"]);
            mysqli_stmt_execute($stmt);
            $result = mysqli_stmt_get_result($stmt);
            $row = mysqli_fetch_assoc($result);
            $_SESSION['id_cm'] = $row["id_cm"];
        }

        if ($_SESSION['role'] == "responsable") {
            $stmt = mysqli_prepare($idcom, "SELECT * FROM responsable WHERE Numero_SS = ?");
            mysqli_stmt_bind_param($stmt, "s", $row["Numero_SS"]);
            mysqli_stmt_execute($stmt);
            $result = mysqli_stmt_get_result($stmt);
            $row = mysqli_fetch_assoc($result);
            $_SESSION['id_boutique'] = $row["id_boutique"];
            $_SESSION['id_responsable'] = $row["Id_responsable"];
            echo $_SESSION['id_boutique'];
            echo $_SESSION['id_responsable'];
        }
        header('Location: dashboard.php');
    } else {
        echo 'Le numéro de sécurité sociale ou le mot de passe est incorrect.';
    }
}
mysqli_close($idcom);
?>
EOF

cat << EOF > "SAE4-main/myparam.inc.php"


<?php
define("MYHOST", "localhost") ;
define("MYUSER", "root") ;
define("MYPASS", "") ;
define("MYBASE","sae4");
?>
EOF

cat << EOF > "SAE4-main/param.wamp.inc.php"
<?php
define("MYHOST","localhost");
define("MYUSER","root");
define("MYPASS","");
define("MYBASE","test");
?>
EOF

