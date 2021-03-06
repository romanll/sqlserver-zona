USE [prueba]
GO
/****** Object:  StoredProcedure [dbo].[spAsignarComision]    Script Date: 6/12/2017 10:51:34 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Roman
-- Create date: 25-05-2017
-- Description:	Ingresar los datos del asesor, validando que la cantidad de elementos asignados
-- sea igual o menor a la cantidad de elementos permitidos
-- =============================================
CREATE PROCEDURE [dbo].[spAsignarComision]
	--todos los parametros son de entrada
	--parametros de las condiciones
	@IdAgencia int,	--identificador de la agencia
	@IdProducto int, --Identificador del producto
	--@ImporteComisionActual float,  --El que esta actualmente en la tabla, para la condicion
	@Cantidad int, --cantidad de elementos
	--parametros de los campos que se actualizaran
	@IdAsesorAgencia int,  --El identificador del Asesor
	@NombreAsesorAgencia varchar(100), --El nombre del asesor, pasara de NULL a este valor
	@ImporteComisionNuevo float  --El importe nuevo ****Debe ser mayor a cero?
AS
BEGIN
	SET NOCOUNT ON;

	--Declarar la tabla temporal para almacenar la cantidad de resultados y el mensaje a retornar
	DECLARE @tablaX TABLE(resultados int,mensaje varchar(100))
	--y la variable para almacenar los resultados del 1er SELECT
	DECLARE @NumeroRegistros int;
	--variable para almacenar el mensaje
	DECLARE @Mensaje varchar(100);
	--la comison  actual en tabla
	DECLARE @ImporteComisionActual float;

	--confirmar que exista el numero de registros(@Cantidad)
	SELECT 
		@NumeroRegistros=COUNT([IdReporteFacturaComision]),@ImporteComisionActual=ImporteComision
	FROM 
		[dbo].[ReporteFacturaComision]
	WHERE 
		IdAgencia=@IdAgencia AND 
		IdProducto=@IdProducto AND
		IdAsesorAgencia IS NULL AND 
		--ImporteComision=@ImporteComisionActual AND
		Fecha IS NULL
	GROUP BY ImporteComision;

	--Se supone que deben existir la misma o mayor cantidad de registros(que cumplen las condiciones=@NumeroRegistros)
	--en tabla que los recibidos por parametro(@Cantidad)
	--y tambien @Cantidad no debe ser cero
	IF(@Cantidad<=@NumeroRegistros)
		BEGIN
			--validar que el monto de la comision nueva no rebase al monto actual
			IF(@ImporteComisionNuevo<=@ImporteComisionActual)
				BEGIN
					--Perfecto,Actualizar
					UPDATE TOP(@Cantidad) prueba.dbo.ReporteFacturaComision
					SET IdAsesorAgencia = @IdAsesorAgencia,
						NombreAsesorAgencia = @NombreAsesorAgencia,
						ImporteComision = @ImporteComisionNuevo,
						Fecha = GETDATE(),
						StatusRegistro = 1
					 WHERE 
						IdAgencia=@IdAgencia AND
						IdProducto=@IdProducto AND
						IdAsesorAgencia IS NULL AND 
						Fecha IS NULL AND 
						ImporteComision=@ImporteComisionActual;
					-- y establecer valores p/almacenar el numero de filas afectadas
					SET @NumeroRegistros=@@ROWCOUNT;
					SET @Mensaje=CONCAT('Comision(normal) asignada correctamente, ',@NumeroRegistros,' registro(s) actualizado(s).');
				END
			ELSE
				BEGIN
					--Error, el monto de la comision nueva es mayor al actual, solo puede ser menor igual
					SET @Mensaje='El monto de comision(normal) es mayor a la permitida. Favor de revisar';

				END
		END
	ELSE
		BEGIN
			--@Cantidad es mayor a la permitida
			SET @Mensaje='La cantidad asignada en la comision normal es mayor a la permitida. Favor de revisar';	
		END
	INSERT INTO @tablaX VALUES(@NumeroRegistros,@Mensaje);
	SELECT resultados,mensaje FROM @tablaX;
END


GO
/****** Object:  StoredProcedure [dbo].[spAsignarComisionEspecial]    Script Date: 6/12/2017 10:51:34 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Roman
-- Create date: 29-05-07
-- Description:	Procedimiento para asignar una comision especial
-- =============================================
CREATE PROCEDURE [dbo].[spAsignarComisionEspecial]
	--parametros de las condiciones
	@IdAgencia int,	--identificador de la agencia
	@IdProducto int, --Identificador del producto
	@Cantidad int, --cantidad de elementos
	--parametros de los campos que se actualizaran
	@IdAsesorAgencia int,  --El identificador del Asesor
	@NombreAsesorAgenciaComEsp varchar(100),
	@ComEsp float, --el valor de la comision especial
	@ComEspNumero int --El numero de la comision especial X(1-5)

AS
BEGIN
	SET NOCOUNT ON;
	
	--Declarar la tabla temporal para almacenar la cantidad de resultados y el mensaje a retornar
	DECLARE @tablaX TABLE(resultados int,mensaje varchar(100))
	--y la variable para almacenar los resultados del 1er SELECT
	DECLARE @NumeroRegistros int;
	--variable para almacenar el mensaje
	DECLARE @Mensaje varchar(100);
	--Comision actual
	DECLARE @ComisionActual float;

	IF @ComEspNumero=1
		--Comision especial 1
		BEGIN
			SELECT @NumeroRegistros=COUNT(*),@ComisionActual=ComEsp1
			FROM ReporteFacturaComision 
			WHERE 
				IdAgencia=@IdAgencia AND
				IdProducto=@Idproducto AND
				FechaComisionEspecial1 IS NULL AND
				NombreAsesorAgenciaComEsp1 IS NOT NULL AND
				ComEsp1>=@ComEsp --el monto de la comision nueva no debe ser mayor al monto de a comision especial 1 actual
			GROUP BY ComEsp1
			
			--la comision actual debe de ser superor a la asignada(nueva)
			IF @ComisionActual>=@ComEsp
				BEGIN
					--actualizar solo si existen elementos suficientes
					IF @Cantidad<= @NumeroRegistros
						BEGIN
							UPDATE TOP(@Cantidad) ReporteFacturaComision
							SET FechaComisionEspecial1=GETDATE(),
								IdAsesorAgenciaComEsp1=@IdAsesorAgencia,
								NombreAsesorAgenciaComEsp1=@NombreAsesorAgenciaComEsp,
								StatusRegistro=1,
								ComEsp1=@ComEsp
							WHERE IdAgencia=@IdAgencia AND
								IdProducto=@Idproducto AND
								FechaComisionEspecial1 IS NULL AND
								NombreAsesorAgenciaComEsp1 IS NOT NULL AND
								ComEsp1>=@ComEsp
							-- y establecer valores p/almacenar el numero de filas afectadas
							SET @NumeroRegistros=@@ROWCOUNT;
							SET @Mensaje=CONCAT('Comision especial ',@ComEspNumero,' asignada correctamente, ',@NumeroRegistros,' registro(s) actualizado(s).');
						END
					ELSE
						BEGIN
							--@Cantidad es mayor a la permitida
							SET @Mensaje=CONCAT('La cantidad asignada en la comision especial ',@ComEspNumero,' es mayor a la permitida. Favor de revisar');	
						END
				END
			ELSE
				BEGIN
					SET @Mensaje=CONCAT('El monto de la comision especial ',@ComEspNumero, ' es mayor a la permitida. Favor de revisar');
				END
		END

	IF @ComEspNumero=2
		--Comision especial 2
		BEGIN
			SELECT @NumeroRegistros=COUNT(*),@ComisionActual=ComEsp2 
			FROM ReporteFacturaComision 
			WHERE 
				IdAgencia=@IdAgencia AND
				IdProducto=@Idproducto AND
				FechaComisionEspecial2 IS NULL AND
				NombreAsesorAgenciaComEsp2 IS NOT NULL AND
				ComEsp2>=@ComEsp --el monto de la comision nueva no debe ser mayor al monto de a comision especial X actual
			GROUP BY ComEsp2

			--el monto de comision es mayor al permitido?
			IF @ComisionActual>=@ComEsp
				BEGIN
					IF @Cantidad<= @NumeroRegistros
						BEGIN
							UPDATE TOP(@Cantidad) ReporteFacturaComision
							SET FechaComisionEspecial2=GETDATE(),
								IdAsesorAgenciaComEsp2=@IdAsesorAgencia,
								NombreAsesorAgenciaComEsp2=@NombreAsesorAgenciaComEsp,
								StatusRegistro=1,
								ComEsp2=@ComEsp
							WHERE IdAgencia=@IdAgencia AND
								IdProducto=@Idproducto AND
								FechaComisionEspecial2 IS NULL AND
								NombreAsesorAgenciaComEsp2 IS NOT NULL AND
								ComEsp2>=@ComEsp
							-- y establecer valores p/almacenar el numero de filas afectadas
							SET @NumeroRegistros=@@ROWCOUNT;
							SET @Mensaje=CONCAT('Comision especial ',@ComEspNumero,' asignada correctamente, ',@NumeroRegistros,' registro(s) actualizado(s).');
						END
					ELSE
						BEGIN
							--@Cantidad es mayor a la permitida
							SET @Mensaje=CONCAT('La cantidad asignada en la comision especial ',@ComEspNumero,' es mayor a la permitida. Favor de revisar');
						END
				END
			ELSE
				BEGIN
					SET @Mensaje=CONCAT('El monto de la comision especial ',@ComEspNumero, ' es mayor a la permitida. Favor de revisar');
				END
		END

	IF @ComEspNumero=3
		BEGIN
			SELECT @NumeroRegistros=COUNT(*),@ComisionActual=ComEsp3 
			FROM ReporteFacturaComision 
			WHERE 
				IdAgencia=@IdAgencia AND
				IdProducto=@Idproducto AND
				FechaComisionEspecial3 IS NULL AND
				NombreAsesorAgenciaComEsp3 IS NOT NULL AND
				ComEsp3>=@ComEsp --el monto de la comision nueva no debe ser mayor al monto de a comision especial X actual
			GROUP BY ComEsp3

			IF @ComisionActual>=@ComEsp
				BEGIN
					IF @Cantidad<= @NumeroRegistros
						BEGIN
							UPDATE TOP(@Cantidad) ReporteFacturaComision
							SET FechaComisionEspecial3=GETDATE(),
								IdAsesorAgenciaComEsp3=@IdAsesorAgencia,
								NombreAsesorAgenciaComEsp3=@NombreAsesorAgenciaComEsp,
								StatusRegistro=1,
								ComEsp3=@ComEsp
							WHERE IdAgencia=@IdAgencia AND
								IdProducto=@Idproducto AND
								FechaComisionEspecial3 IS NULL AND
								NombreAsesorAgenciaComEsp3 IS NOT NULL AND
								ComEsp3>=@ComEsp
							-- y establecer valores p/almacenar el numero de filas afectadas
							SET @NumeroRegistros=@@ROWCOUNT;
							SET @Mensaje=CONCAT('Comision especial ',@ComEspNumero,' asignada correctamente, ',@NumeroRegistros,' registro(s) actualizado(s).');
						END
					ELSE
						BEGIN
							--@Cantidad es mayor a la permitida
							SET @Mensaje=CONCAT('La cantidad asignada en la comision especial ',@ComEspNumero,' es mayor a la permitida. Favor de revisar');
						END
				END
			ELSE
				BEGIN
					SET @Mensaje=CONCAT('El monto de la comision especial ',@ComEspNumero, ' es mayor a la permitida. Favor de revisar');
				END
		END

	IF @ComEspNumero=4
		BEGIN
			SELECT @NumeroRegistros=COUNT(*),@ComisionActual=ComEsp4 
			FROM ReporteFacturaComision 
			WHERE 
				IdAgencia=@IdAgencia AND
				IdProducto=@Idproducto AND
				FechaComisionEspecial4 IS NULL AND
				NombreAsesorAgenciaComEsp4 IS NOT NULL AND
				ComEsp4>=@ComEsp --el monto de la comision nueva no debe ser mayor al monto de a comision especial X actual
			GROUP BY ComEsp4

			IF @ComisionActual>=@ComEsp
				BEGIN
					IF @Cantidad<= @NumeroRegistros
						BEGIN
							UPDATE TOP(@Cantidad) ReporteFacturaComision
							SET FechaComisionEspecial4=GETDATE(),
								IdAsesorAgenciaComEsp4=@IdAsesorAgencia,
								NombreAsesorAgenciaComEsp4=@NombreAsesorAgenciaComEsp,
								StatusRegistro=1,
								ComEsp4=@ComEsp
							WHERE IdAgencia=@IdAgencia AND
								IdProducto=@Idproducto AND
								FechaComisionEspecial4 IS NULL AND
								NombreAsesorAgenciaComEsp4 IS NOT NULL AND
								ComEsp4>=@ComEsp
							-- y establecer valores p/almacenar el numero de filas afectadas
							SET @NumeroRegistros=@@ROWCOUNT;
							SET @Mensaje=CONCAT('Comision especial ',@ComEspNumero,' asignada correctamente, ',@NumeroRegistros,' registro(s) actualizado(s).');
						END
					ELSE
						BEGIN
							--@Cantidad es mayor a la permitida
							SET @Mensaje=CONCAT('La cantidad asignada en la comision especial ',@ComEspNumero,' es mayor a la permitida. Favor de revisar');
						END
				END
			ELSE
				BEGIN
					SET @Mensaje=CONCAT('El monto de la comision especial ',@ComEspNumero, ' es mayor a la permitida. Favor de revisar');
				END
		END

	IF @ComEspNumero=5
		BEGIN
			SELECT @NumeroRegistros=COUNT(*),@ComisionActual=ComEsp5 
			FROM ReporteFacturaComision 
			WHERE 
				IdAgencia=@IdAgencia AND
				IdProducto=@Idproducto AND
				FechaComisionEspecial5 IS NULL AND
				NombreAsesorAgenciaComEsp5 IS NOT NULL AND
				ComEsp5>=@ComEsp --el monto de la comision nueva no debe ser mayor al monto de a comision especial X actual
			GROUP BY ComEsp5

			IF @ComisionActual>=@ComEsp
				BEGIN
					IF @Cantidad<= @NumeroRegistros
						BEGIN
							UPDATE TOP(@Cantidad) ReporteFacturaComision
							SET FechaComisionEspecial5=GETDATE(),
								IdAsesorAgenciaComEsp5=@IdAsesorAgencia,
								NombreAsesorAgenciaComEsp5=@NombreAsesorAgenciaComEsp,
								StatusRegistro=1,
								ComEsp5=@ComEsp
							WHERE IdAgencia=@IdAgencia AND
								IdProducto=@Idproducto AND
								FechaComisionEspecial5 IS NULL AND
								NombreAsesorAgenciaComEsp5 IS NOT NULL AND
								ComEsp5>=@ComEsp
							-- y establecer valores p/almacenar el numero de filas afectadas
							SET @NumeroRegistros=@@ROWCOUNT;
							SET @Mensaje=CONCAT('Comision especial ',@ComEspNumero,' asignada correctamente, ',@NumeroRegistros,' registro(s) actualizado(s).');
						END
					ELSE
						BEGIN
							--@Cantidad es mayor a la permitida
							SET @Mensaje=CONCAT('La cantidad asignada en la comision especial ',@ComEspNumero,' es mayor a la permitida. Favor de revisar');
						END
				END
			ELSE
				BEGIN
					SET @Mensaje=CONCAT('El monto de la comision especial ',@ComEspNumero, ' es mayor a la permitida. Favor de revisar');
				END
		END

	--hacer la insercion y despues mostrar los datos/mensaje
	INSERT INTO @tablaX VALUES(@NumeroRegistros,@Mensaje);
	SELECT resultados,mensaje FROM @tablaX;
END


GO
/****** Object:  StoredProcedure [dbo].[spAsignarComisionEspecialX]    Script Date: 6/12/2017 10:51:34 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Roman
-- Create date: 2-6-17
-- Description:	Asignar una comision especial
-- =============================================
CREATE PROCEDURE [dbo].[spAsignarComisionEspecialX]
	--parametros de las condiciones
	@IdAgencia int,	--identificador de la agencia
	@IdProducto int, --Identificador del producto
	@Cantidad int, --cantidad de elementos
	--parametros de los campos que se actualizaran
	@IdAsesorAgencia int,  --El identificador del Asesor
	@NombreAsesorAgenciaComEsp varchar(100),
	@ComEsp float, --el valor de la comision especial
	@Inicial int = 1 --el valor de la comision por donde empezara
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    DECLARE @tablaX TABLE(resultados int,mensaje varchar(100))
	--y la variable para almacenar los resultados del 1er SELECT
	DECLARE @NumeroRegistros int;
	--variable para almacenar el mensaje
	DECLARE @Mensaje varchar(100);
	--Comision actual
	DECLARE @ComisionActual float
	DECLARE @RegistrosActualizados int=0
	DECLARE @Final int

	IF @Inicial=2
		BEGIN
			SET @Final=1
			GOTO dos
		END
	IF @Inicial=3
		BEGIN
			SET @Final=2
			GOTO tres
		END
	IF @Inicial=4
		BEGIN
			SET @Final=3
			GOTO cuatro
		END
	IF @Inicial=5
		BEGIN
			SET @Final=4
			GOTO cinco
		END

	uno:
		IF @RegistrosActualizados=0
			BEGIN
				SELECT @NumeroRegistros=COUNT(*),@ComisionActual=ComEsp1
				FROM ReporteFacturaComision 
				WHERE 
					IdAgencia=@IdAgencia AND
					IdProducto=@IdProducto AND
					FechaComisionEspecial1 IS NULL AND
					NombreAsesorAgenciaComEsp1 IS NOT NULL AND
					ComEsp1>=@ComEsp
					--el monto de la comision nueva no debe ser mayor al monto de a comision especial 1 actual
				GROUP BY ComEsp1
				IF @ComisionActual>=@ComEsp
					BEGIN
						--actualizar solo si la cantidad asignada es menor a la cantidad disponible
						IF @Cantidad <= @NumeroRegistros
							BEGIN
								UPDATE TOP(@Cantidad) ReporteFacturaComision
								SET FechaComisionEspecial1=GETDATE(),
									IdAsesorAgenciaComEsp1=@IdAsesorAgencia,
									NombreAsesorAgenciaComEsp1=@NombreAsesorAgenciaComEsp,
									StatusRegistro=1,
									ComEsp1=@ComEsp
								WHERE IdAgencia=@IdAgencia AND
									IdProducto=@Idproducto AND
									FechaComisionEspecial1 IS NULL AND
									NombreAsesorAgenciaComEsp1 IS NOT NULL AND
									ComEsp1>=@ComEsp
								-- y establecer valores p/almacenar el numero de filas afectadas
								SET @NumeroRegistros=@@ROWCOUNT;
								SET @Mensaje=CONCAT('Comision especial 1 asignada correctamente, ',@NumeroRegistros,' registro(s) actualizado(s).');
								SET @RegistrosActualizados=@@ROWCOUNT;
							END
						ELSE
							BEGIN
								--@Cantidad es mayor a la permitida
								SET @Mensaje='La cantidad asignada en la comision especial 1 es mayor a la permitida. Favor de revisar';	
							END
					END
				ELSE
					BEGIN
						SET @Mensaje='El monto de la comision especial 1 es mayor a la permitida. Favor de revisar';
					END
		END
		IF @Final=1
			GOTO fin
	dos:
		IF @RegistrosActualizados=0
			BEGIN
				SELECT @NumeroRegistros=COUNT(*),@ComisionActual=ComEsp2
				FROM ReporteFacturaComision 
				WHERE 
					IdAgencia=@IdAgencia AND
					IdProducto=@IdProducto AND
					FechaComisionEspecial2 IS NULL AND
					NombreAsesorAgenciaComEsp2 IS NOT NULL AND
					ComEsp2>=@ComEsp
					 --el monto de la comision nueva no debe ser mayor al monto de a comision especial 2 actual
				GROUP BY ComEsp2
				IF @ComisionActual>=@ComEsp
					BEGIN
						--actualizar solo si la cantidad asignada es menor a la cantidad disponible
						IF @Cantidad<= @NumeroRegistros
							BEGIN
								UPDATE TOP(@Cantidad) ReporteFacturaComision
								SET FechaComisionEspecial2=GETDATE(),
									IdAsesorAgenciaComEsp2=@IdAsesorAgencia,
									NombreAsesorAgenciaComEsp2=@NombreAsesorAgenciaComEsp,
									StatusRegistro=1,
									ComEsp2=@ComEsp
								WHERE IdAgencia=@IdAgencia AND
									IdProducto=@Idproducto AND
									FechaComisionEspecial2 IS NULL AND
									NombreAsesorAgenciaComEsp2 IS NOT NULL AND
									ComEsp2>=@ComEsp
								-- y establecer valores p/almacenar el numero de filas afectadas
								SET @NumeroRegistros=@@ROWCOUNT;
								SET @Mensaje=CONCAT('Comision especial 2 asignada correctamente, ',@NumeroRegistros,' registro(s) actualizado(s).');
								SET @RegistrosActualizados=@@ROWCOUNT;
							END
						ELSE
							BEGIN
								--@Cantidad es mayor a la permitida
								SET @Mensaje='La cantidad asignada en la comision especial 2 es mayor a la permitida. Favor de revisar';	
							END
					END
				ELSE
					BEGIN
						SET @Mensaje='El monto de la comision especial 2 es mayor a la permitida. Favor de revisar';
					END
		END
		IF @Final=2
			GOTO fin
	tres:
		IF @RegistrosActualizados=0
			BEGIN
				SELECT @NumeroRegistros=COUNT(*),@ComisionActual=ComEsp3
				FROM ReporteFacturaComision 
				WHERE 
					IdAgencia=@IdAgencia AND
					IdProducto=@IdProducto AND
					FechaComisionEspecial3 IS NULL AND
					NombreAsesorAgenciaComEsp3 IS NOT NULL AND
					ComEsp3>=@ComEsp
					 --el monto de la comision nueva no debe ser mayor al monto de a comision especial 3 actual
				GROUP BY ComEsp3
				IF @ComisionActual>=@ComEsp
					BEGIN
						--actualizar solo si la cantidad asignada es menor a la cantidad disponible
						IF @Cantidad<= @NumeroRegistros
							BEGIN
								UPDATE TOP(@Cantidad) ReporteFacturaComision
								SET FechaComisionEspecial3=GETDATE(),
									IdAsesorAgenciaComEsp3=@IdAsesorAgencia,
									NombreAsesorAgenciaComEsp3=@NombreAsesorAgenciaComEsp,
									StatusRegistro=1,
									ComEsp3=@ComEsp
								WHERE IdAgencia=@IdAgencia AND
									IdProducto=@Idproducto AND
									FechaComisionEspecial3 IS NULL AND
									NombreAsesorAgenciaComEsp3 IS NOT NULL AND
									ComEsp3>=@ComEsp
								-- y establecer valores p/almacenar el numero de filas afectadas
								SET @NumeroRegistros=@@ROWCOUNT;
								SET @Mensaje=CONCAT('Comision especial 3 asignada correctamente, ',@NumeroRegistros,' registro(s) actualizado(s).');
								SET @RegistrosActualizados=@@ROWCOUNT;
							END
						ELSE
							BEGIN
								--@Cantidad es mayor a la permitida
								SET @Mensaje='La cantidad asignada en la comision especial 3 es mayor a la permitida. Favor de revisar';	
							END
					END
				ELSE
					BEGIN
						SET @Mensaje='El monto de la comision especial 3 es mayor a la permitida. Favor de revisar';
					END
		END
		IF @Final=3
			GOTO fin
	cuatro:
		IF @RegistrosActualizados=0
			BEGIN
				SELECT @NumeroRegistros=COUNT(*),@ComisionActual=ComEsp4
				FROM ReporteFacturaComision 
				WHERE 
					IdAgencia=@IdAgencia AND
					IdProducto=@IdProducto AND
					FechaComisionEspecial4 IS NULL AND
					NombreAsesorAgenciaComEsp4 IS NOT NULL AND
					ComEsp4>=@ComEsp
					 --el monto de la comision nueva no debe ser mayor al monto de a comision especial 4 actual
				GROUP BY ComEsp4
				IF @ComisionActual>=@ComEsp
					BEGIN
						--actualizar solo si la cantidad asignada es menor a la cantidad disponible
						IF @Cantidad<= @NumeroRegistros
							BEGIN
								UPDATE TOP(@Cantidad) ReporteFacturaComision
								SET FechaComisionEspecial4=GETDATE(),
									IdAsesorAgenciaComEsp4=@IdAsesorAgencia,
									NombreAsesorAgenciaComEsp4=@NombreAsesorAgenciaComEsp,
									StatusRegistro=1,
									ComEsp4=@ComEsp
								WHERE IdAgencia=@IdAgencia AND
									IdProducto=@Idproducto AND
									FechaComisionEspecial4 IS NULL AND
									NombreAsesorAgenciaComEsp4 IS NOT NULL AND
									ComEsp4>=@ComEsp
								-- y establecer valores p/almacenar el numero de filas afectadas
								SET @NumeroRegistros=@@ROWCOUNT;
								SET @Mensaje=CONCAT('Comision especial 4 asignada correctamente, ',@NumeroRegistros,' registro(s) actualizado(s).');
								SET @RegistrosActualizados=@@ROWCOUNT;
							END
						ELSE
							BEGIN
								--@Cantidad es mayor a la permitida
								SET @Mensaje='La cantidad asignada en la comision especial 4 es mayor a la permitida. Favor de revisar';	
							END
					END
				ELSE
					BEGIN
						SET @Mensaje='El monto de la comision especial 4 es mayor a la permitida. Favor de revisar';
					END
		END
		IF @Final=4
			GOTO fin
	cinco:
		IF @RegistrosActualizados=0
			BEGIN
				SELECT @NumeroRegistros=COUNT(*),@ComisionActual=ComEsp5
				FROM ReporteFacturaComision 
				WHERE 
					IdAgencia=@IdAgencia AND
					IdProducto=@IdProducto AND
					FechaComisionEspecial5 IS NULL AND
					NombreAsesorAgenciaComEsp5 IS NOT NULL AND
					ComEsp5>=@ComEsp
				GROUP BY ComEsp5
				IF @ComisionActual>=@ComEsp
					BEGIN
						--actualizar solo si la cantidad asignada es menor a la cantidad disponible
						IF @Cantidad<= @NumeroRegistros
							BEGIN
								UPDATE TOP(@Cantidad) ReporteFacturaComision
								SET FechaComisionEspecial5=GETDATE(),
									IdAsesorAgenciaComEsp5=@IdAsesorAgencia,
									NombreAsesorAgenciaComEsp5=@NombreAsesorAgenciaComEsp,
									StatusRegistro=1,
									ComEsp5=@ComEsp
								WHERE IdAgencia=@IdAgencia AND
									IdProducto=@Idproducto AND
									FechaComisionEspecial5 IS NULL AND
									NombreAsesorAgenciaComEsp5 IS NOT NULL AND
									ComEsp5>=@ComEsp
								-- y establecer valores p/almacenar el numero de filas afectadas
								SET @NumeroRegistros=@@ROWCOUNT;
								SET @Mensaje=CONCAT('Comision especial 5 asignada correctamente, ',@NumeroRegistros,' registro(s) actualizado(s).');
								SET @RegistrosActualizados=@@ROWCOUNT;
							END
						ELSE
							BEGIN
								--@Cantidad es mayor a la permitida
								SET @Mensaje='La cantidad asignada en la comision especial 5 es mayor a la permitida. Favor de revisar';	
							END
					END
				ELSE
					BEGIN
						SET @Mensaje='El monto de la comision especial 5 es mayor a la permitida. Favor de revisar';
					END
		END
		IF @Final=5
			GOTO fin
		IF @Final<5 GOTO uno
	fin:
		INSERT INTO @tablaX VALUES(@NumeroRegistros,@Mensaje);
		SELECT resultados,mensaje FROM @tablaX;
	--esto ya no =>

	/*
	--ComEsp1
	
	IF @RegistrosActualizados=0
		BEGIN
			SELECT @NumeroRegistros=COUNT(*),@ComisionActual=ComEsp1
			--SELECT COUNT(*),ComEsp1
			FROM ReporteFacturaComision 
			WHERE 
				IdAgencia=@IdAgencia AND
				IdProducto=@IdProducto AND
				FechaComisionEspecial1 IS NULL AND
				NombreAsesorAgenciaComEsp1 IS NOT NULL AND
				ComEsp1>=@ComEsp
				 --el monto de la comision nueva no debe ser mayor al monto de a comision especial 1 actual
			GROUP BY ComEsp1
			IF @ComisionActual>=@ComEsp
				BEGIN
					--actualizar solo si la cantidad asignada es menor a la cantidad disponible
					IF @Cantidad<= @NumeroRegistros
						BEGIN
							UPDATE TOP(@Cantidad) ReporteFacturaComision
							SET FechaComisionEspecial1=GETDATE(),
								IdAsesorAgenciaComEsp1=@IdAsesorAgencia,
								NombreAsesorAgenciaComEsp1=@NombreAsesorAgenciaComEsp,
								StatusRegistro=1,
								ComEsp1=@ComEsp
							WHERE IdAgencia=@IdAgencia AND
								IdProducto=@Idproducto AND
								FechaComisionEspecial1 IS NULL AND
								NombreAsesorAgenciaComEsp1 IS NOT NULL AND
								ComEsp1>=@ComEsp
							-- y establecer valores p/almacenar el numero de filas afectadas
							SET @NumeroRegistros=@@ROWCOUNT;
							SET @Mensaje=CONCAT('Comision especial 1 asignada correctamente, ',@NumeroRegistros,' registro(s) actualizado(s).');
							SET @RegistrosActualizados=@@ROWCOUNT;
						END
					ELSE
						BEGIN
							--@Cantidad es mayor a la permitida
							SET @Mensaje='La cantidad asignada en la comision especial 1 es mayor a la permitida. Favor de revisar';	
						END
				END
			ELSE
				BEGIN
					SET @Mensaje='El monto de la comision especial 1 es mayor a la permitida. Favor de revisar';
				END
	END
	--ComEsp2
	IF @RegistrosActualizados=0
		BEGIN
			SELECT @NumeroRegistros=COUNT(*),@ComisionActual=ComEsp2
			FROM ReporteFacturaComision 
			WHERE 
				IdAgencia=@IdAgencia AND
				IdProducto=@IdProducto AND
				FechaComisionEspecial2 IS NULL AND
				NombreAsesorAgenciaComEsp2 IS NOT NULL AND
				ComEsp2>=@ComEsp
				 --el monto de la comision nueva no debe ser mayor al monto de a comision especial 2 actual
			GROUP BY ComEsp2
			IF @ComisionActual>=@ComEsp
				BEGIN
					--actualizar solo si la cantidad asignada es menor a la cantidad disponible
					IF @Cantidad<= @NumeroRegistros
						BEGIN
							UPDATE TOP(@Cantidad) ReporteFacturaComision
							SET FechaComisionEspecial2=GETDATE(),
								IdAsesorAgenciaComEsp2=@IdAsesorAgencia,
								NombreAsesorAgenciaComEsp2=@NombreAsesorAgenciaComEsp,
								StatusRegistro=1,
								ComEsp2=@ComEsp
							WHERE IdAgencia=@IdAgencia AND
								IdProducto=@Idproducto AND
								FechaComisionEspecial2 IS NULL AND
								NombreAsesorAgenciaComEsp2 IS NOT NULL AND
								ComEsp2>=@ComEsp
							-- y establecer valores p/almacenar el numero de filas afectadas
							SET @NumeroRegistros=@@ROWCOUNT;
							SET @Mensaje=CONCAT('Comision especial 2 asignada correctamente, ',@NumeroRegistros,' registro(s) actualizado(s).');
							SET @RegistrosActualizados=@@ROWCOUNT;
						END
					ELSE
						BEGIN
							--@Cantidad es mayor a la permitida
							SET @Mensaje='La cantidad asignada en la comision especial 2 es mayor a la permitida. Favor de revisar';	
						END
				END
			ELSE
				BEGIN
					SET @Mensaje='El monto de la comision especial 2 es mayor a la permitida. Favor de revisar';
				END
	END
	--ComEsp3
	IF @RegistrosActualizados=0
		BEGIN
			SELECT @NumeroRegistros=COUNT(*),@ComisionActual=ComEsp3
			FROM ReporteFacturaComision 
			WHERE 
				IdAgencia=@IdAgencia AND
				IdProducto=@IdProducto AND
				FechaComisionEspecial3 IS NULL AND
				NombreAsesorAgenciaComEsp3 IS NOT NULL AND
				ComEsp3>=@ComEsp
				 --el monto de la comision nueva no debe ser mayor al monto de a comision especial 3 actual
			GROUP BY ComEsp3
			IF @ComisionActual>=@ComEsp
				BEGIN
					--actualizar solo si la cantidad asignada es menor a la cantidad disponible
					IF @Cantidad<= @NumeroRegistros
						BEGIN
							UPDATE TOP(@Cantidad) ReporteFacturaComision
							SET FechaComisionEspecial3=GETDATE(),
								IdAsesorAgenciaComEsp3=@IdAsesorAgencia,
								NombreAsesorAgenciaComEsp3=@NombreAsesorAgenciaComEsp,
								StatusRegistro=1,
								ComEsp3=@ComEsp
							WHERE IdAgencia=@IdAgencia AND
								IdProducto=@Idproducto AND
								FechaComisionEspecial3 IS NULL AND
								NombreAsesorAgenciaComEsp3 IS NOT NULL AND
								ComEsp3>=@ComEsp
							-- y establecer valores p/almacenar el numero de filas afectadas
							SET @NumeroRegistros=@@ROWCOUNT;
							SET @Mensaje=CONCAT('Comision especial 3 asignada correctamente, ',@NumeroRegistros,' registro(s) actualizado(s).');
							SET @RegistrosActualizados=@@ROWCOUNT;
						END
					ELSE
						BEGIN
							--@Cantidad es mayor a la permitida
							SET @Mensaje='La cantidad asignada en la comision especial 3 es mayor a la permitida. Favor de revisar';	
						END
				END
			ELSE
				BEGIN
					SET @Mensaje='El monto de la comision especial 3 es mayor a la permitida. Favor de revisar';
				END
	END
	--ComEsp4
	IF @RegistrosActualizados=0
		BEGIN
			SELECT @NumeroRegistros=COUNT(*),@ComisionActual=ComEsp4
			FROM ReporteFacturaComision 
			WHERE 
				IdAgencia=@IdAgencia AND
				IdProducto=@IdProducto AND
				FechaComisionEspecial4 IS NULL AND
				NombreAsesorAgenciaComEsp4 IS NOT NULL AND
				ComEsp4>=@ComEsp
				 --el monto de la comision nueva no debe ser mayor al monto de a comision especial 4 actual
			GROUP BY ComEsp4
			IF @ComisionActual>=@ComEsp
				BEGIN
					--actualizar solo si la cantidad asignada es menor a la cantidad disponible
					IF @Cantidad<= @NumeroRegistros
						BEGIN
							UPDATE TOP(@Cantidad) ReporteFacturaComision
							SET FechaComisionEspecial4=GETDATE(),
								IdAsesorAgenciaComEsp4=@IdAsesorAgencia,
								NombreAsesorAgenciaComEsp4=@NombreAsesorAgenciaComEsp,
								StatusRegistro=1,
								ComEsp4=@ComEsp
							WHERE IdAgencia=@IdAgencia AND
								IdProducto=@Idproducto AND
								FechaComisionEspecial4 IS NULL AND
								NombreAsesorAgenciaComEsp4 IS NOT NULL AND
								ComEsp4>=@ComEsp
							-- y establecer valores p/almacenar el numero de filas afectadas
							SET @NumeroRegistros=@@ROWCOUNT;
							SET @Mensaje=CONCAT('Comision especial 4 asignada correctamente, ',@NumeroRegistros,' registro(s) actualizado(s).');
							SET @RegistrosActualizados=@@ROWCOUNT;
						END
					ELSE
						BEGIN
							--@Cantidad es mayor a la permitida
							SET @Mensaje='La cantidad asignada en la comision especial 4 es mayor a la permitida. Favor de revisar';	
						END
				END
			ELSE
				BEGIN
					SET @Mensaje='El monto de la comision especial 4 es mayor a la permitida. Favor de revisar';
				END
	END
	--ComEsp5
	IF @RegistrosActualizados=0
		BEGIN
			SELECT @NumeroRegistros=COUNT(*),@ComisionActual=ComEsp5
			FROM ReporteFacturaComision 
			WHERE 
				IdAgencia=@IdAgencia AND
				IdProducto=@IdProducto AND
				FechaComisionEspecial5 IS NULL AND
				NombreAsesorAgenciaComEsp5 IS NOT NULL AND
				ComEsp5>=@ComEsp
			GROUP BY ComEsp5
			IF @ComisionActual>=@ComEsp
				BEGIN
					--actualizar solo si la cantidad asignada es menor a la cantidad disponible
					IF @Cantidad<= @NumeroRegistros
						BEGIN
							UPDATE TOP(@Cantidad) ReporteFacturaComision
							SET FechaComisionEspecial5=GETDATE(),
								IdAsesorAgenciaComEsp5=@IdAsesorAgencia,
								NombreAsesorAgenciaComEsp5=@NombreAsesorAgenciaComEsp,
								StatusRegistro=1,
								ComEsp5=@ComEsp
							WHERE IdAgencia=@IdAgencia AND
								IdProducto=@Idproducto AND
								FechaComisionEspecial5 IS NULL AND
								NombreAsesorAgenciaComEsp5 IS NOT NULL AND
								ComEsp5>=@ComEsp
							-- y establecer valores p/almacenar el numero de filas afectadas
							SET @NumeroRegistros=@@ROWCOUNT;
							SET @Mensaje=CONCAT('Comision especial 5 asignada correctamente, ',@NumeroRegistros,' registro(s) actualizado(s).');
							SET @RegistrosActualizados=@@ROWCOUNT;
						END
					ELSE
						BEGIN
							--@Cantidad es mayor a la permitida
							SET @Mensaje='La cantidad asignada en la comision especial 5 es mayor a la permitida. Favor de revisar';	
						END
				END
			ELSE
				BEGIN
					SET @Mensaje='El monto de la comision especial 5 es mayor a la permitida. Favor de revisar';
				END
	END
	--hacer la insercion y despues mostrar los datos/mensaje
	INSERT INTO @tablaX VALUES(@NumeroRegistros,@Mensaje);
	SELECT resultados,mensaje FROM @tablaX;
	*/
END


GO
/****** Object:  StoredProcedure [dbo].[spCargarAgencias]    Script Date: 6/12/2017 10:51:34 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Roman
-- Create date: 31-05-2017
-- Description:	obtener las agencias
-- =============================================
CREATE PROCEDURE [dbo].[spCargarAgencias]
	-- Add the parameters for the stored procedure here
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	SELECT IdAgencia,NumeroAgencia,NombreAgencia FROM Agencia ORDER BY NombreAgencia DESC
END


GO
/****** Object:  StoredProcedure [dbo].[spCargarAsesores]    Script Date: 6/12/2017 10:51:34 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Roman
-- Create date: 31-05-2017
-- Description:	Obtiene el id y nombre de asesores(nombre completo)
-- =============================================
CREATE PROCEDURE [dbo].[spCargarAsesores]
	-- Add the parameters for the stored procedure here
	@IdAgencia int
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    SELECT IdAsesor, NombresAsesor+' '+ISNULL(ApellidoPaternoAsesor,'')+' '+ISNULL(ApellidoMaternoAsesor,'') as Nombre
	FROM Asesor
	WHERE IdAgencia = @IdAgencia
	AND Status = 1 
	ORDER BY Nombre
END


GO
/****** Object:  StoredProcedure [dbo].[spCargarAsesoresOpcional]    Script Date: 6/12/2017 10:51:34 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Roman
-- Create date: 31-05-2017
-- Description:	Obtiene el id y nombre de asesores(nombre completo), incluyendo uno que es NINGUNO
-- =============================================
CREATE PROCEDURE [dbo].[spCargarAsesoresOpcional]
	-- Add the parameters for the stored procedure here
	@IdAgencia int
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	SELECT 0 AS IdAsesor, 'NINGUNO' AS Nombre FROM Asesor 
	UNION 
	SELECT IdAsesor, NombresAsesor+' '+ISNULL(ApellidoPaternoAsesor, '') + ' ' + ISNULL(ApellidoMaternoAsesor, '') AS Nombre 
	FROM Asesor
	WHERE IdAgencia = @IdAgencia
	AND Status = 1 
	ORDER BY Nombre
END


GO
/****** Object:  StoredProcedure [dbo].[spCargarProductos]    Script Date: 6/12/2017 10:51:34 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Roman
-- Create date: 30-05-2017
-- Description:	Obtener los datos del producto de acuerdo al identificador de agencia
-- =============================================
CREATE PROCEDURE [dbo].[spCargarProductos]
	-- Add the parameters for the stored procedure here
	@IdAgencia int
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	SELECT NombreProducto, IdProducto, COUNT(IdReporteFacturaComision) AS conteo 
	FROM ReporteFacturaComision
	WHERE IdAgencia=@IdAgencia AND(
		StatusRegistro IS NULL OR 
		Fecha IS NULL OR 
		FechaComisionEspecial1 IS NULL OR 
		FechaComisionEspecial2 IS NULL OR 
		FechaComisionEspecial3 IS NULL OR 
		FechaComisionEspecial4 IS NULL OR 
		FechaComisionEspecial5 IS NULL
	)
	GROUP BY NombreProducto, IdProducto ORDER BY NombreProducto
END


GO
/****** Object:  StoredProcedure [dbo].[spCuatro]    Script Date: 6/12/2017 10:51:34 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Roman
-- Create date: 24-05-17
-- Description:	Retornar los datos del registro insertado
-- =============================================
CREATE PROCEDURE [dbo].[spCuatro]
	-- Add the parameters for the stored procedure here
	@nombre varchar(50)='Nombre', 
	@correo varchar(50)='correo@dominio.com'
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	DECLARE @tablaX table(id int,cliente varchar(50),correo varchar(50),fecha varchar(50));
	INSERT clientes(cliente,correo,fecha)
		OUTPUT INSERTED.id,INSERTED.cliente,INSERTED.correo,INSERTED.fecha INTO @tablaX
	VALUES (@nombre,@correo,GETDATE())
	SELECT * FROM @tablaX
END


GO
/****** Object:  StoredProcedure [dbo].[spImporteComision]    Script Date: 6/12/2017 10:51:34 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Roman
-- Create date: 30-05-2017
-- Description:	Obtener el importe de la comision normal
-- =============================================
CREATE PROCEDURE [dbo].[spImporteComision]
	-- Add the parameters for the stored procedure here
	@IdAgencia int,@IdProducto int
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	SELECT ImporteComision AS Monto, COUNT(ImporteComision) AS Cantidad
	FROM ReporteFacturaComision
	WHERE NombreAsesorAgencia is NULL AND IdAgencia = @IdAgencia
	AND Fecha is NULL 
	AND IdProducto = @IdProducto
	GROUP BY ImporteComision
END


GO
/****** Object:  StoredProcedure [dbo].[spImporteComisionEspecial]    Script Date: 6/12/2017 10:51:34 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Roman
-- Create date: 30-05-2017
-- Description:	Obtener el importe para una comision especial
-- =============================================
CREATE PROCEDURE [dbo].[spImporteComisionEspecial]
	-- Add the parameters for the stored procedure here
	@IdAgencia int,
	@IdProducto int,
	@ComisionNumero int --para sabes si es la comision especial 1,2,3...
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	IF @ComisionNumero=1
		BEGIN	
			SELECT ComEsp1 AS Monto, Count(ComEsp1) AS Cantidad 
			FROM ReporteFacturaComision
			WHERE NombreAsesorAgenciaComEsp1 is not NULL
			AND IdAgencia = @IdAgencia
			AND FechaComisionEspecial1 is NULL
			AND IdProducto = @IdProducto
			GROUP BY ComEsp1
		END
	IF @ComisionNumero=2
		BEGIN	
			SELECT ComEsp2 AS Monto, Count(ComEsp2) AS Cantidad 
			FROM ReporteFacturaComision
			WHERE NombreAsesorAgenciaComEsp2 is not NULL
			AND IdAgencia = @IdAgencia
			AND FechaComisionEspecial2 is NULL
			AND IdProducto = @IdProducto
			GROUP BY ComEsp2
		END
	IF @ComisionNumero=3
		BEGIN	
			SELECT ComEsp3 AS Monto, Count(ComEsp3) AS Cantidad 
			FROM ReporteFacturaComision
			WHERE NombreAsesorAgenciaComEsp3 is not NULL
			AND IdAgencia = @IdAgencia
			AND FechaComisionEspecial3 is NULL
			AND IdProducto = @IdProducto
			GROUP BY ComEsp3
		END
	IF @ComisionNumero=4
		BEGIN	
			SELECT ComEsp4 AS Monto, Count(ComEsp4) AS Cantidad 
			FROM ReporteFacturaComision
			WHERE NombreAsesorAgenciaComEsp4 is not NULL
			AND IdAgencia = @IdAgencia
			AND FechaComisionEspecial4 is NULL
			AND IdProducto = @IdProducto
			GROUP BY ComEsp4
		END
	IF @ComisionNumero=5
		BEGIN	
			SELECT ComEsp5 AS Monto, Count(ComEsp5) AS Cantidad 
			FROM ReporteFacturaComision
			WHERE NombreAsesorAgenciaComEsp5 is not NULL
			AND IdAgencia = @IdAgencia
			AND FechaComisionEspecial5 is NULL
			AND IdProducto = @IdProducto
			GROUP BY ComEsp5
		END
END


GO
/****** Object:  StoredProcedure [dbo].[spObtenerComisiones]    Script Date: 6/12/2017 10:51:34 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Roman
-- Create date: 30-05-2017
-- Description:	obtener las comisiones
-- =============================================
CREATE PROCEDURE [dbo].[spObtenerComisiones]
	-- Add the parameters for the stored procedure here
	@IdProducto int,
	@IdAgencia int
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	SELECT TOP 1
		(SELECT TOP 1 NombreAsesorAgenciaComEsp1 
		FROM ReporteFacturaComision 
		WHERE NombreAsesorAgenciaComEsp1 is not NULL AND IdAgencia = @IdAgencia AND 
		FechaComisionEspecial1 is NULL AND 
		IdProducto = @IdProducto) AS NombreAsesorAgenciaComEsp1,
		(SELECT COUNT(*) 
		FROM ReporteFacturaComision 
		WHERE NombreAsesorAgenciaComEsp1 is not NULL AND IdAgencia = @IdAgencia AND 
		FechaComisionEspecial1 is NULL AND 
		IdProducto = @IdProducto) As LibresComEsp1,
		(SELECT TOP 1 NombreAsesorAgenciaComEsp2 
		FROM ReporteFacturaComision 
		WHERE NombreAsesorAgenciaComEsp2 is not NULL AND IdAgencia = @IdAgencia AND FechaComisionEspecial2 is NULL AND 
		IdProducto = @IdProducto) AS NombreAsesorAgenciaComEsp2,
		(SELECT COUNT(*) 
		FROM ReporteFacturaComision 
		WHERE IdAgencia = @IdAgencia AND NombreAsesorAgenciaComEsp2 is not NULL AND FechaComisionEspecial2 is NULL AND 
		IdProducto = @IdProducto) As LibresComEsp2,
		(SELECT TOP 1 NombreAsesorAgenciaComEsp3 
		FROM ReporteFacturaComision 
		WHERE NombreAsesorAgenciaComEsp3 is not NULL AND IdAgencia = @IdAgencia AND FechaComisionEspecial3 is NULL AND
		IdProducto = @IdProducto) AS NombreAsesorAgenciaComEsp3,
		(SELECT COUNT(*) 
		FROM ReporteFacturaComision 
		WHERE IdAgencia = @IdAgencia AND NombreAsesorAgenciaComEsp3 is not NULL AND FechaComisionEspecial3 is NULL AND 
		IdProducto = @IdProducto) As LibresComEsp3,
		(SELECT TOP 1 NombreAsesorAgenciaComEsp4 
		FROM ReporteFacturaComision 
		WHERE NombreAsesorAgenciaComEsp4 is not NULL AND IdAgencia = @IdAgencia AND FechaComisionEspecial4 is NULL AND 
		IdProducto = @IdProducto) AS NombreAsesorAgenciaComEsp4, 
		(SELECT COUNT(*) 
		FROM ReporteFacturaComision 
		WHERE IdAgencia = @IdAgencia AND NombreAsesorAgenciaComEsp4 is not NULL AND FechaComisionEspecial4 is NULL AND 
		IdProducto = @IdProducto) As LibresComEsp4,
		(SELECT TOP 1 NombreAsesorAgenciaComEsp5 
		FROM ReporteFacturaComision 
		WHERE NombreAsesorAgenciaComEsp5 is not NULL AND IdAgencia = @IdAgencia AND FechaComisionEspecial5 is NULL AND 
		IdProducto = @IdProducto) AS NombreAsesorAgenciaComEsp5,
		(SELECT COUNT(*) 
		FROM ReporteFacturaComision 
		WHERE IdAgencia = @IdAgencia AND NombreAsesorAgenciaComEsp5 is not NULL AND FechaComisionEspecial5 is NULL AND 
		IdProducto = @IdProducto) As LibresComEsp5,
		(SELECT COUNT(*) 
		FROM ReporteFacturaComision 
		WHERE IdAgencia = @IdAgencia AND Fecha is NULL AND IdProducto = @IdProducto)  As LibresComNorm
	FROM ReporteFacturaComision
	WHERE IdAgencia = @IdAgencia
END


GO
