<?php

$estado = (isset($_GET['estado'])) ? $_GET['estado'] : null;
$categoria = (isset($_GET['categoria'])) ? $_GET['categoria'] : null;

//$filtro = (isset($_GET['filtro'])) ? $_GET['filtro'] : null;
//$dist = 3.10686; //1.609344

//$estado=14;//Jalisco
//$categoria=1;//Tiendas
$filtro='notfilterset';
//$categoria=5;

try
{
    //if($estado == null || $categoria == null || $filtro == null || $cercano == null)
    if($estado == null || $categoria == null || $filtro == null)
    {
        $resultados['error'] = 'Verifique que este un estado seleccionado';
    }
    else
    {
        if($filtro == 'notfilterset') $filtro = '';

        //url base
        $url_base="api.promo-zone.com.mx/v1/establecimientos";

        //sin importar si recibi estado o categoria, o ambos(siempre uno de los 2)
        //tratar de obtener los datos de estos
        if(!empty($categoria)){
            $categoriaId=filter_var($categoria,FILTER_SANITIZE_NUMBER_INT);
            $urlCategorias="api.promo-zone.com.mx/v1/categorias/$categoriaId";
            $respCategorias=obtenerDatos($urlCategorias);
            //se supone que recibi un objeto
            if(!is_object($respCategorias)){
                //hubo un error
                $resultados['error']=$respCategorias;
            }
            else{
                if(!isset($respCategorias->code)){
                    $url_base.="?EstablecimientoSearch[categoria_id]={$respCategorias->categoria}";
                }
            }
        }

        if(!empty($estado)){
            $estadoId=filter_var($estado,FILTER_SANITIZE_NUMBER_INT);
            $urlEstado="api.promo-zone.com.mx/v1/estados/$estadoId";
            $respEstado=obtenerDatos($urlEstado);
            //var_dump($respEstado);
            if(!is_object($respEstado)){
                $resultados['error']=$respEstado;
            }
            else{
                //solo si no hay error
                if(!isset($respEstado->code)){
                    //confirmar si tambien se buscara por categoria
                    if(!empty($categoria) && is_object($respCategorias)){
                        //anteponer el '&'
                        $url_base.="&EstablecimientoSearch[estado_id]={$respEstado->seo_permalink}";
                    }else{
                        //de otra forma, este sera el unico parametro
                        $url_base.="?EstablecimientoSearch[estado_id]={$respEstado->seo_permalink}";
                    }
                }
                else{
                    $resultados['error']="No existen resultados para estado ";
                    //error 404
                }
            }
        }

        //y obtener los datos
        $datos=obtenerDatos($url_base);
        //var_dump($datos);
        if(is_array($datos) && count($datos)>0){
            $resultados=ordenardatos($datos);
        }
        else{
            $resultados['error']='No existen datos';
        }

    }
}
catch(Exception $e)
{
    $resultados['error'] = $e->getMessage();
}

$resultadosJson = json_encode($resultados);
echo $_GET['callback'] . '(' . $resultadosJson . ');';

/*
 * obtenerDatos
 * de la URL dada, retorna un array en caso de exito y una cadena en caso de error
 */
function obtenerDatos($enlace){
    $c=curl_init();
    $opciones=array(
        CURLOPT_RETURNTRANSFER=>1,
        CURLOPT_URL=>$enlace
    );
    curl_setopt_array($c,$opciones);
    $respuesta=curl_exec($c);
    if(!$respuesta){
        $res='Error: "' . curl_error($c) . '" - Code: ' . curl_errno($c);
    }
    else{
        $res=json_decode($respuesta);
    }
    curl_close($c);
    return $res;
}

/*
 * Ordenar los datos para mostrarlos como estaba antes
 */
function ordenardatos($datos){
    //recibe un array de arrays
    $respuesta=array();
    foreach($datos as $registro){
        //retornar la URL relativa=> img/establecimientos/salon-de-eventos-trasloma-logotipo.jpg
        $urlLogo=parse_url($registro->img_logotipo);
        //evito el primer '/'
        $urlRelativaLogo=substr($urlLogo['path'],1);

        $urlImagen=parse_url($registro->imagen_principal);
        $urlRelativaImagen=substr($urlImagen['path'],1);

        $temp=array(
            'id_sucursal'=>0,
            'id_promocion'=>$registro->promocion->id,
            'promocion'=>$registro->promocion->promocion,
            'id_establecimiento'=>$registro->promocion->establecimiento_id,
            'establecimiento'=>$registro->establecimiento,
            'descripcion'=>$registro->introduccion,
            'logo'=>$urlRelativaLogo,
            'imagen'=>$urlRelativaImagen
        );
        $respuesta['promocion'][]=$temp;
    }
    $respuesta['size']=count($respuesta['promocion']);
    return $respuesta;
}




?>