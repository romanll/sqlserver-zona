USE [prueba]
GO

/****** Object:  Trigger [dbo].[RegistrarCambiosAsignaciones]    Script Date: 6/12/2017 10:52:02 AM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO




CREATE TRIGGER [dbo].[RegistrarCambiosAsignaciones]
ON [dbo].[ReporteFacturaComision]
AFTER UPDATE
AS
	BEGIN
		SET NOCOUNT ON

		--variables locales para almancenar los campos nuevos y viejos
		--y tambien la cantidad de registros actualizados
		DECLARE @IdAsesorAnterior int, @AsesorAnterior varchar(100),@ImporteComisionAnterior float
		DECLARE @IdAsesorActual int, @AsesorActual varchar(100), @ImporteComisionActual float
		DECLARE @Factura varchar(50),@IdAgencia int,@IdProducto int,@NumRegistrosActualizados int

		--Solo si se actualiza el IdAsesorAgencia, hacer la insercion del registro de
		--asignacion de comision normal(fue asignacion de comision normal)
		IF UPDATE(IdAsesorAgencia)
			BEGIN
				SELECT 
					@Factura=inserted.Factura,
					@IdAgencia=inserted.IdAgencia,
					@IdProducto=inserted.IdProducto,
					@IdAsesorActual=inserted.IdAsesorAgencia,
					@AsesorActual=inserted.NombreAsesorAgencia, 
					@ImporteComisionActual=inserted.ImporteComision,
					@IdAsesorAnterior=deleted.IdAsesorAgencia,
					@AsesorAnterior=deleted.NombreAsesorAgencia, 
					@ImporteComisionAnterior=deleted.ImporteComision
				FROM inserted
				INNER JOIN deleted ON deleted.IdReporteFacturaComision=inserted.IdReporteFacturaComision;
				SELECT  @NumRegistrosActualizados=COUNT(*) FROM inserted;
				INSERT INTO RegistroAsignaciones(NumFactura,IdAgencia,IdProducto,IdAsesorAnterior,NombreAsesorAnterior,
					IdAsesorActual,NombreAsesorActual,MontoComisionAnterior,MontoComisionActual,Cantidad,Tipo) 
				VALUES(@Factura,@IdAgencia,@IdProducto,@IdAsesorAnterior,@AsesorAnterior,@IdAsesorActual,
					@AsesorActual,@ImporteComisionAnterior,@ImporteComisionActual,@NumRegistrosActualizados,'Normal');
			END

		--Es asignacion de comision especial 1?
		IF UPDATE(FechaComisionEspecial1)
			BEGIN
				SELECT 
					@Factura=inserted.Factura,
					@IdAgencia=inserted.IdAgencia,
					@IdProducto=inserted.IdProducto,
					@IdAsesorActual=inserted.IdAsesorAgenciaComEsp1,
					@AsesorActual=inserted.NombreAsesorAgenciaComEsp1, 
					@ImporteComisionActual=inserted.ComEsp1,
					@IdAsesorAnterior=deleted.IdAsesorAgenciaComEsp1,
					@AsesorAnterior=deleted.NombreAsesorAgenciaComEsp1, 
					@ImporteComisionAnterior=deleted.ComEsp1
				FROM inserted
				INNER JOIN deleted ON deleted.IdReporteFacturaComision=inserted.IdReporteFacturaComision;
				SELECT  @NumRegistrosActualizados=COUNT(*) FROM inserted;
				INSERT INTO RegistroAsignaciones(NumFactura,IdAgencia,IdProducto,IdAsesorAnterior,NombreAsesorAnterior,
					IdAsesorActual,NombreAsesorActual,MontoComisionAnterior,MontoComisionActual,Cantidad,Tipo) 
				VALUES(@Factura,@IdAgencia,@IdProducto,@IdAsesorAnterior,@AsesorAnterior,@IdAsesorActual,
					@AsesorActual,@ImporteComisionAnterior,@ImporteComisionActual,@NumRegistrosActualizados,'ComEsp1');
			END

		--Comision especial 2
		IF UPDATE(FechaComisionEspecial2)
			BEGIN
				SELECT 
					@Factura=inserted.Factura,
					@IdAgencia=inserted.IdAgencia,
					@IdProducto=inserted.IdProducto,
					@IdAsesorActual=inserted.IdAsesorAgenciaComEsp2,
					@AsesorActual=inserted.NombreAsesorAgenciaComEsp2, 
					@ImporteComisionActual=inserted.ComEsp2,
					@IdAsesorAnterior=deleted.IdAsesorAgenciaComEsp2,
					@AsesorAnterior=deleted.NombreAsesorAgenciaComEsp2, 
					@ImporteComisionAnterior=deleted.ComEsp2
				FROM inserted
				INNER JOIN deleted ON deleted.IdReporteFacturaComision=inserted.IdReporteFacturaComision;
				SELECT  @NumRegistrosActualizados=COUNT(*) FROM inserted;
				INSERT INTO RegistroAsignaciones(NumFactura,IdAgencia,IdProducto,IdAsesorAnterior,NombreAsesorAnterior,
					IdAsesorActual,NombreAsesorActual,MontoComisionAnterior,MontoComisionActual,Cantidad,Tipo) 
				VALUES(@Factura,@IdAgencia,@IdProducto,@IdAsesorAnterior,@AsesorAnterior,@IdAsesorActual,
					@AsesorActual,@ImporteComisionAnterior,@ImporteComisionActual,@NumRegistrosActualizados,'ComEsp2');
			END

		--Comision especial 3
		IF UPDATE(FechaComisionEspecial3)
			BEGIN
				SELECT 
					@Factura=inserted.Factura,
					@IdAgencia=inserted.IdAgencia,
					@IdProducto=inserted.IdProducto,
					@IdAsesorActual=inserted.IdAsesorAgenciaComEsp3,
					@AsesorActual=inserted.NombreAsesorAgenciaComEsp3, 
					@ImporteComisionActual=inserted.ComEsp3,
					@IdAsesorAnterior=deleted.IdAsesorAgenciaComEsp3,
					@AsesorAnterior=deleted.NombreAsesorAgenciaComEsp3, 
					@ImporteComisionAnterior=deleted.ComEsp3
				FROM inserted
				INNER JOIN deleted ON deleted.IdReporteFacturaComision=inserted.IdReporteFacturaComision;
				SELECT  @NumRegistrosActualizados=COUNT(*) FROM inserted;
				INSERT INTO RegistroAsignaciones(NumFactura,IdAgencia,IdProducto,IdAsesorAnterior,NombreAsesorAnterior,
					IdAsesorActual,NombreAsesorActual,MontoComisionAnterior,MontoComisionActual,Cantidad,Tipo) 
				VALUES(@Factura,@IdAgencia,@IdProducto,@IdAsesorAnterior,@AsesorAnterior,@IdAsesorActual,
					@AsesorActual,@ImporteComisionAnterior,@ImporteComisionActual,@NumRegistrosActualizados,'ComEsp3');
			END

		--Comision especial 4
		IF UPDATE(FechaComisionEspecial4)
			BEGIN
				SELECT 
					@Factura=inserted.Factura,
					@IdAgencia=inserted.IdAgencia,
					@IdProducto=inserted.IdProducto,
					@IdAsesorActual=inserted.IdAsesorAgenciaComEsp4,
					@AsesorActual=inserted.NombreAsesorAgenciaComEsp4, 
					@ImporteComisionActual=inserted.ComEsp4,
					@IdAsesorAnterior=deleted.IdAsesorAgenciaComEsp4,
					@AsesorAnterior=deleted.NombreAsesorAgenciaComEsp4, 
					@ImporteComisionAnterior=deleted.ComEsp4
				FROM inserted
				INNER JOIN deleted ON deleted.IdReporteFacturaComision=inserted.IdReporteFacturaComision;
				SELECT  @NumRegistrosActualizados=COUNT(*) FROM inserted;
				INSERT INTO RegistroAsignaciones(NumFactura,IdAgencia,IdProducto,IdAsesorAnterior,NombreAsesorAnterior,
					IdAsesorActual,NombreAsesorActual,MontoComisionAnterior,MontoComisionActual,Cantidad,Tipo) 
				VALUES(@Factura,@IdAgencia,@IdProducto,@IdAsesorAnterior,@AsesorAnterior,@IdAsesorActual,
					@AsesorActual,@ImporteComisionAnterior,@ImporteComisionActual,@NumRegistrosActualizados,'ComEsp4');
			END

		--Comision especial 5
		IF UPDATE(FechaComisionEspecial5)
			BEGIN
				SELECT 
					@Factura=inserted.Factura,
					@IdAgencia=inserted.IdAgencia,
					@IdProducto=inserted.IdProducto,
					@IdAsesorActual=inserted.IdAsesorAgenciaComEsp5,
					@AsesorActual=inserted.NombreAsesorAgenciaComEsp5, 
					@ImporteComisionActual=inserted.ComEsp5,
					@IdAsesorAnterior=deleted.IdAsesorAgenciaComEsp5,
					@AsesorAnterior=deleted.NombreAsesorAgenciaComEsp5, 
					@ImporteComisionAnterior=deleted.ComEsp5
				FROM inserted
				INNER JOIN deleted ON deleted.IdReporteFacturaComision=inserted.IdReporteFacturaComision;
				SELECT  @NumRegistrosActualizados=COUNT(*) FROM inserted;
				INSERT INTO RegistroAsignaciones(NumFactura,IdAgencia,IdProducto,IdAsesorAnterior,NombreAsesorAnterior,
					IdAsesorActual,NombreAsesorActual,MontoComisionAnterior,MontoComisionActual,Cantidad,Tipo) 
				VALUES(@Factura,@IdAgencia,@IdProducto,@IdAsesorAnterior,@AsesorAnterior,@IdAsesorActual,
					@AsesorActual,@ImporteComisionAnterior,@ImporteComisionActual,@NumRegistrosActualizados,'ComEsp5');
			END
	END



GO


