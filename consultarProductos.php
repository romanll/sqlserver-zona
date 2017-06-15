<?php
/**
 * Created by PhpStorm.
 * User: Sistemas
 * Date: 31/5/2017
 * Time: 18:05
 */

include_once 'db/Conexion.php';

$db=new Conexion();

if(!empty($_POST['id'])){
    //bien
    $idAgencia=filter_var($_POST['id'],FILTER_SANITIZE_NUMBER_INT);
}
$sentencia="{CALL spCargarProductos(?)}";
$parametros=array(
    array($idAgencia,SQLSRV_PARAM_IN)
);
$resp=$db->query($sentencia,$parametros);
//var_dump($resp);
if($resp){
    $datos=$db->rows($resp);
    //var_dump($datos);
    echo json_encode(array('datos'=>$datos,'status'=>true));
}
$db->cerrar();