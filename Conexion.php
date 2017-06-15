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
    /*
    private $serverName = "PC_DELL";
    private $database='prueba';
    private $usuario='roman';
    private $pass='123456';
    */

    private $serverName = "25.152.72.233\SQLEXPRESS_ETIQU";
    private $database='etiquetas_test';
    private $usuario='romanl';
    private $pass='VUg1vhzrom1';



    function __construct()
    {
        $this->conn = sqlsrv_connect($this->serverName, array(
            "Database"=>$this->database, "UID"=>$this->usuario, "PWD"=>$this->pass
        ));
    }

    /**
     * @param $sentencia: La sentencia a ejecutar
     * @param bool $parametros: arreglo de parametros(por lo regular para SP)
     * @return bool|resource: el resultado de la consulta o FALSE
     */
    public function query($sentencia,$parametros=false){
        if($parametros){
            return sqlsrv_query($this->conn,$sentencia,$parametros);
        }
        return sqlsrv_query($this->conn,$sentencia);
    }

    /**
     * @param $resp: El resultado de alguna consulta del tipo SELECT(Un recurso de sentencia devuelta por sqlsrv_query)
     * @asObject: TRUE:retornar los resultados como objetos en vez de array.FALSE: retorna los resultados como arreglos
     * @return array|bool: El arreglo de los registros
     */
    public function rows($resp,$asObject=FALSE){
        $datos=false;
        while($row=sqlsrv_fetch_array($resp,SQLSRV_FETCH_ASSOC)){
            if($asObject){
                $datos[]=(object)array_map(function($row){return utf8_encode($row);},$row);
            }
            else{
                $datos[]=array_map(function($row){return utf8_encode($row);},$row);
            }
        }
        return $datos;
    }

    /**
     * Cerrar la conexion
     */
    public function cerrar(){
        sqlsrv_close($this->conn);
    }
}