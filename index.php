<?php
/**
 * Created by PhpStorm.
 * User: Sistemas
 * Date: 22/5/2017
 * Time: 09:34
 */

//PDO
/*
try{
    $db=new PDO("sqlsrv:Server=PC_DELL;Database=prueba", "roman", "123456");
    $db->setAttribute(PDO::ATTR_ERRMODE,PDO::ERRMODE_EXCEPTION);
}catch(Exception $e)
{
    die( print_r( $e->getMessage() ) );
}

$parametros=array('2017-05-20');
$selectSql="SELECT * FROM usuario WHERE fecha=?";
try{
    $getDatos=$db->prepare($selectSql);
    $getDatos->execute($parametros);
    $datos=$getDatos->fetchAll(PDO::FETCH_ASSOC);
    var_dump($datos);
}catch(Exception $e){
    var_dump($e->getMessage());
}

try{
    //$storePro='spPrueba';
    $fecha='2017-05-20';
    $storePro="spPruebaDos '$fecha'";
    $res=$db->query($storePro);
    $rows=$res->fetchAll(PDO::FETCH_ASSOC);
    var_dump($rows);
}catch(Exception $e){
    var_dump($e->getMessage());
}
*/


//SQLSRV

$serverName = "PC_DELL";
$connectionInfo = array( "Database"=>"prueba", "UID"=>"roman", "PWD"=>"123456");
$conn = sqlsrv_connect($serverName, $connectionInfo);

if( $conn ) {
    echo "Conexión establecida.<br />";
}else{
    //echo "Conexión no se pudo establecer.<br />";
    die( print_r( sqlsrv_errors(), true));
}

/*
$procedimiento="EXEC spPrueba";
$sentencia=sqlsrv_prepare($conn,$procedimiento);
if(sqlsrv_execute($sentencia)){
    while($row = sqlsrv_fetch_object($sentencia))
    {
        var_dump($row);
    }
}
*/

/*
$procedimientoDos="{CALL spPruebaDos(?)}";
$parametros=array(array('2017-05-20',SQLSRV_PARAM_IN));
$res=sqlsrv_query($conn,$procedimientoDos,$parametros,array("Scrollable"=>SQLSRV_CURSOR_CLIENT_BUFFERED));
if($res){
    var_dump(sqlsrv_num_rows($res));
    while($row = sqlsrv_fetch_object($res))
    {
        //echo $row->fecha->format('Y-m-d'),'<br>';
        echo $row->nombre,'<br>';
    }
}
*/

$nombre='Elsa Pato';
$correo='elsapato@hotmail.com';
$id=0;
$procedimientoTres="{CALL spTres(?,?,?)}";
$parametros=array(
    array($nombre,SQLSRV_PARAM_IN),
    array($correo,SQLSRV_PARAM_IN),
    array($id,SQLSRV_PARAM_OUT),
);
$res=sqlsrv_query($conn,$procedimientoTres,$parametros);
//var_dump($res);
if($res){
    var_dump(sqlsrv_get_field($res,0));
    var_dump(sqlsrv_fetch_object($res));
    print_r(sqlsrv_errors());
}
else{
    print_r(sqlsrv_errors());
}



//ODBC
/*
$conn = odbc_connect(
    "Driver={SQL Server Native Client 11.0};Server=PC_DELL;Database=prueba;",
    "roman",
    "123456",
    SQL_CUR_USE_ODBC )
or die ( "Could Not Connect to ODBC Database!" );

try{

    $fecha='2017-05-20';
    $sentencia=odbc_prepare($conn,'spPruebaDos ?');
    if($sentencia){
        $res=odbc_execute($sentencia,array('2017-05-20'));
        //var_dump($res);
    }
    else{
        echo "error";
        die();
    }
    //var_dump($res);

    //$res = odbc_exec($conn, "spPruebaDos '$fecha'");

    //ODBC_result(current_query, 33)
    while($row=odbc_fetch_object($sentencia))
    {
        var_dump($row);
    }


} catch (Exception $e) {
    echo 'Excepción capturada: ',  $e->getMessage(), "\n";
}
*/
?>