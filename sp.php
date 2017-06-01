<?php
/**
 * Created by PhpStorm.
 * User: Sistemas
 * Date: 26/5/2017
 * Time: 16:20
 */

//conectarse y probar el SP con los parametros requieridos, retornar mensaje de exito|error
$serverName = "PC_DELL";
$connectionInfo = array( "Database"=>"prueba", "UID"=>"roman", "PWD"=>"123456");
$conn = sqlsrv_connect($serverName, $connectionInfo);

if( $conn ) {
    echo "Conexión establecida.<br />";
}else{
    //echo "Conexión no se pudo establecer.<br />";
    die( print_r( sqlsrv_errors(), true));
}

//parametros
$idAgencia = 1846;
$idProducto = 559;
$importeComisionActual = 50;
$cantidad = 1;
$idAsesorAgencia = 741741;
$nombreAsesorAgencia = 'Lauren M';
$importeComisionNuevo = 40;

$comisionNumero=1;
//llamar al procedimiento
/*
 *      @IdAgencia = 1846,
		@IdProducto = 559,
		@ImporteComisionActual = 50,
		@Cantidad = 5,
		@IdAsesorAgencia = 999,
		@NombreAsesorAgencia = 'Armando Broncas',
		@ImporteComisionNuevo = 80
 * */
/*
//obtener comisiones(todas: nombre,comision)
$procedimientoCuatro="{CALL spObtenerComisiones(?,?)}";
$parametros=array(
    array($idProducto,SQLSRV_PARAM_IN),
    array($idAgencia,SQLSRV_PARAM_IN)
);
$res=sqlsrv_query($conn,$procedimientoCuatro,$parametros);
if($res){
    print_r(sqlsrv_fetch_object($res));
    print_r(sqlsrv_errors());
}
else{
    print_r(sqlsrv_errors());
}
*/
/*
///Comisiones normales(monto,cantidad)
$procedimientoCuatro="{CALL spImporteComision(?,?)}";
$parametros=array(
    array($idAgencia,SQLSRV_PARAM_IN),
    array($idProducto,SQLSRV_PARAM_IN)
);
$res=sqlsrv_query($conn,$procedimientoCuatro,$parametros);
if($res){
    print_r(sqlsrv_fetch_object($res));
    print_r(sqlsrv_errors());
}
else{
    print_r(sqlsrv_errors());
}
*/
/*
///Comisiones normales(monto,cantidad)
$procedimientoCuatro="{CALL spImporteComisionEspecial(?,?,?)}";
$parametros=array(
    array($idAgencia,SQLSRV_PARAM_IN),
    array($idProducto,SQLSRV_PARAM_IN),
    array($comisionNumero,SQLSRV_PARAM_IN)
);
$res=sqlsrv_query($conn,$procedimientoCuatro,$parametros);
if($res){
    print_r(sqlsrv_fetch_object($res));
    print_r(sqlsrv_errors());
}
else{
    print_r(sqlsrv_errors());
}
*/
/*
///Comisiones normales(monto,cantidad)
$procedimientoCuatro="{CALL spAsignarComision(?,?,?,?,?,?,?)}";
$parametros=array(
    array($idAgencia,SQLSRV_PARAM_IN),
    array($idProducto,SQLSRV_PARAM_IN),
    array($importeComisionActual,SQLSRV_PARAM_IN),
    array($cantidad,SQLSRV_PARAM_IN),
    array($idAsesorAgencia,SQLSRV_PARAM_IN),
    array($nombreAsesorAgencia,SQLSRV_PARAM_IN),
    array($importeComisionNuevo,SQLSRV_PARAM_IN)
);
$res=sqlsrv_query($conn,$procedimientoCuatro,$parametros);
if($res){
    print_r(sqlsrv_fetch_object($res));
    print_r(sqlsrv_errors());
}
else{
    print_r(sqlsrv_errors());
}
*/
/*
//Asignar comision especial
$importeComisionEspecial=30;
$procedimientoCuatro="{CALL spAsignarComisionEspecial(?,?,?,?,?,?,?)}";
$parametros=array(
    array($idAgencia,SQLSRV_PARAM_IN),
    array($idProducto,SQLSRV_PARAM_IN),
    array($cantidad,SQLSRV_PARAM_IN),
    array($idAsesorAgencia,SQLSRV_PARAM_IN),
    array($nombreAsesorAgencia,SQLSRV_PARAM_IN),
    array($importeComisionEspecial,SQLSRV_PARAM_IN),
    array($comisionNumero,SQLSRV_PARAM_IN)
);
$res=sqlsrv_query($conn,$procedimientoCuatro,$parametros);
if($res){
    print_r(sqlsrv_fetch_object($res));
    print_r(sqlsrv_errors());
}
else{
    print_r(sqlsrv_errors());
}
*/
/*
//cargar asesores con la opcion NINGUNO
$procedimiento="{CALL spCargarAsesoresOpcional(?)}";
$parametros=array(
    array($idAgencia,SQLSRV_PARAM_IN)
);
$res=sqlsrv_query($conn,$procedimiento,$parametros);
if($res){
    while($row=sqlsrv_fetch_object($res)){
        var_dump($row);
    }
    //print_r(sqlsrv_fetch_object($res));
    print_r(sqlsrv_errors());
}
else{
    print_r(sqlsrv_errors());
}
*/
$procedimiento="{CALL spCargarAgencias}";
//$parametros=array(
//    array($idAgencia,SQLSRV_PARAM_IN)
//);
$res=sqlsrv_query($conn,$procedimiento);
if($res){
    while($row=sqlsrv_fetch_object($res)){
        var_dump($row);
    }
    //print_r(sqlsrv_fetch_object($res));
    print_r(sqlsrv_errors());
}
else{
    print_r(sqlsrv_errors());
}


