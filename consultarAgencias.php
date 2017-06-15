<?php
/**
 * Created by PhpStorm.
 * User: Sistemas
 * Date: 2/6/2017
 * Time: 18:35
 */


include_once 'db/Conexion.php';

$db=new Conexion();

$sentencia="{CALL spCargarAgencias}";
$resp=$db->query($sentencia);

if($resp){
    $datos=$db->rows($resp);
    echo json_encode(array('datos'=>$datos,'status'=>true));
}
$db->cerrar();