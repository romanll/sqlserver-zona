<?php

/**
 * Created by PhpStorm.
 * User: Sistemas
 * Date: 31/5/2017
 * Time: 17:50
 */
class Conexion
{
    public $conn;
    private $serverName = "PC_DELL";
    private $database='prueba';
    private $usuario='roman';
    private $pass='123456';

    function __construct()
    {

        $connectionInfo = array( );
        $this->conn = sqlsrv_connect($this->serverName, array(
            "Database"=>$this->database, "UID"=>$this->usuario, "PWD"=>$this->pass
        ));
    }

    public function query($sentencia,$parametros=false){
        if($parametros){
            return sqlsrv_query($this->conn,$sentencia,$parametros);
        }
        return sqlsrv_query($this->conn,$sentencia);
    }

    public function rows($resp){
        $datos=false;
        while($row=sqlsrv_fetch_array($resp,SQLSRV_FETCH_ASSOC)){
            $datos[]=array_map(function($row){return utf8_encode($row);},$row);
        }
        return $datos;
    }

    public function cerrar(){
        sqlsrv_close($this->conn);
    }
}