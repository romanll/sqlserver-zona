<?php
/**
 * Created by PhpStorm.
 * User: Sistemas
 * Date: 1/6/2017
 * Time: 11:17
 */


include_once 'db/Conexion.php';


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

    if($cantidad>0 && $monto>0){
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
        //hubo errores?
        $errores=$db->errors();
        if(!is_null($errores)){
            echo utf8_encode($errores[0]['message']);
        }
        //var_dump(sqlsrv_errors());
        $db->cerrar();
    }
    else{
        $respuesta[]=array('status'=>false,'mensaje'=>'No se permiten valores en cero o vacios en comision normal.');
    }



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
                //$sentenciaEsp="{CALL spAsignarComisionEspecial(?,?,?,?,?,?,?)}";
                $sentenciaEsp="{CALL spAsignarComisionEspecialX(?,?,?,?,?,?,?)}";
                $parametrosEsp=array(
                    array($agencia,SQLSRV_PARAM_IN),
                    array($producto,SQLSRV_PARAM_IN),
                    array($cantidadComEspX,SQLSRV_PARAM_IN),
                    array($idAsesorComEspX,SQLSRV_PARAM_IN),
                    array($nombreAsesorComEspX,SQLSRV_PARAM_IN),
                    array($montoComEspX,SQLSRV_PARAM_IN),
                    array($comEspNumX,SQLSRV_PARAM_IN)
                );

                //solo asignar si la cantidad y el monto es diferente a cero
                if($cantidadComEspX>0 && $montoComEspX>0){
                    $db=new Conexion();
                    $respComEsp=$db->query($sentenciaEsp,$parametrosEsp);
                    if($respComEsp){
                        print_r(sqlsrv_errors());
                        $datos=$db->rows($respComEsp);
                        //echo json_encode(array('datos'=>$datos,'status'=>true));
                        $respuesta[]=array('datos'=>$datos[0],'status'=>true);
                    }
                    else{print_r(sqlsrv_errors());}
                    $db->cerrar();
                }
                else{
                    $respuesta[]=array('status'=>false,'mensaje'=>'No se permiten valores en cero o vacios en comisiones especiales.');
                }

            }
        }
    }
    echo json_encode($respuesta);
}
else{
    echo json_encode(array("status"=>false,"mensaje"=>"Error de campos requeridos"));
}


