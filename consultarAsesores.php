<?php
/**
 * Created by PhpStorm.
 * User: Sistemas
 * Date: 1/6/2017
 * Time: 10:19
 */


include_once 'db/Conexion.php';

$db=new Conexion();

if(!empty($_POST['agencia'])){
    //bien
    $idAgencia=filter_var($_POST['agencia'],FILTER_SANITIZE_NUMBER_INT);
}
$sentencia="{CALL spCargarAsesores(?)}";
$parametros=array(
    array($idAgencia,SQLSRV_PARAM_IN)
);
$resp=$db->query($sentencia,$parametros);

if($resp){
    $datos=$db->rows($resp);
    echo json_encode(array('datos'=>$datos,'status'=>true));
}
$db->cerrar();