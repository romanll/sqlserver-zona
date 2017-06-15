<?php

include_once 'db/Conexion.php';

$db=new Conexion();

$consulta=$db->query("SELECT CONVERT(VARCHAR(23), Fecha , 121) as Fecha FROM RegistroAsignaciones ORDER BY IdRegistro ASC");
if($consulta){
    $datos=$db->rows($consulta);
    var_dump($datos);
}
$db->cerrar();


?>