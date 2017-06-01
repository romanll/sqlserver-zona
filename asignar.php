<?php
/**
 * Created by PhpStorm.
 * User: Sistemas
 * Date: 1/6/2017
 * Time: 11:17
 */


include_once 'Conexion.php';

//var_dump($_POST);die();


if(
    !empty($_POST['agencia']) &&
    !empty($_POST['productos']) &&
    !empty($_POST['asesores']) &&
    !empty($_POST['cantidad']) &&
    !empty($_POST['monto']) &&
    !empty($_POST['nombreAsesor'])
){
    //hacer algo
    $agencia=filter_var($_POST['agencia'],FILTER_SANITIZE_NUMBER_INT);
    $producto=filter_var($_POST['productos'],FILTER_SANITIZE_NUMBER_INT);
    $asesor=filter_var($_POST['asesores'],FILTER_SANITIZE_NUMBER_INT);
    $cantidad=filter_var($_POST['cantidad'],FILTER_SANITIZE_NUMBER_INT);
    $monto=filter_var($_POST['monto'],FILTER_SANITIZE_NUMBER_FLOAT,FILTER_FLAG_ALLOW_FRACTION);
    $nombreAsesor=filter_var($_POST['nombreAsesor'],FILTER_SANITIZE_STRING);

    //db

    $db=new Conexion();

    $sentencia="{CALL spAsignarComision(?,?,?,?,?,?)}";
    $parametros=array(
        array($agencia,SQLSRV_PARAM_IN),
        array($producto,SQLSRV_PARAM_IN),
        array($cantidad,SQLSRV_PARAM_IN),
        array($asesor,SQLSRV_PARAM_IN),
        array($nombreAsesor,SQLSRV_PARAM_IN),
        array($monto,SQLSRV_PARAM_IN)
    );
    $resp=$db->query($sentencia,$parametros);
    if($resp){
        $datos=$db->rows($resp);
        $respuesta[]=array('datos'=>$datos[0],'status'=>true);
        //echo json_encode(array('datos'=>$datos,'status'=>true));
    }
    $db->cerrar();


    //existen comisones especiales?
    if(!empty($_POST['asesor'])){
        $asesores=filter_var_array($_POST['asesor'],FILTER_SANITIZE_NUMBER_INT);
        $nombresAsesores=filter_var_array($_POST['asesorNombre'],FILTER_SANITIZE_STRING);
        $cantidadComEsp=filter_var_array($_POST['cantidadExtra'],FILTER_SANITIZE_NUMBER_INT);
        $montoExtra=filter_var_array($_POST['montoExtra'],FILTER_SANITIZE_NUMBER_FLOAT,FILTER_FLAG_ALLOW_FRACTION);
        for($i=0;$i<count($asesores);$i++){
            if($asesores[$i]>0){
                $idAsesorComEspX=$asesores[$i];
                $nombreAsesorComEspX=$nombresAsesores[$i];
                $cantidadComEspX=$cantidadComEsp[$i];
                $montoComEspX=$montoExtra[$i];
                $comEspNumX=$i+1;
                //llamar a la comsion especial $i
                $sentenciaEsp="{CALL spAsignarComisionEspecial(?,?,?,?,?,?,?)}";
                $parametrosEsp=array(
                    array($agencia,SQLSRV_PARAM_IN),
                    array($producto,SQLSRV_PARAM_IN),
                    array($cantidadComEspX,SQLSRV_PARAM_IN),
                    array($idAsesorComEspX,SQLSRV_PARAM_IN),
                    array($nombreAsesorComEspX,SQLSRV_PARAM_IN),
                    array($montoComEspX,SQLSRV_PARAM_IN),
                    array($comEspNumX,SQLSRV_PARAM_IN)
                );
                //var_dump($parametrosEsp);

                $db=new Conexion();
                $respComEsp=$db->query($sentenciaEsp,$parametrosEsp);
                if($respComEsp){
                    $datos=$db->rows($respComEsp);
                    //echo json_encode(array('datos'=>$datos,'status'=>true));
                    $respuesta[]=array('datos'=>$datos[0],'status'=>true);
                }
                $db->cerrar();
            }
        }
    }
    echo json_encode($respuesta);
}
else{
    echo json_encode(array("status"=>false,"text"=>"Error de campos requeridos"));
}


