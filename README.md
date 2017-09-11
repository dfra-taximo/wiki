# Bases para Postgresql:
 
## Procedimientos Almacenados: 
 
 * Estructura Base

```
#!POSTGRESQL

/*
METADATA:
	* VARCHAR
	* INT
	* DATE
	* TIMESTAMP
	* TEXT
	* RECORD

1: Las Variables que son utlizadas para obtener la data de entrada terminan en '_vi', ejemplo: nombre_vi.
2: Las variables que son utlizadas para captura la data dentro del procedimiento almacenado terminan en '_v', ejemplo: nombre_apellido_v.
3: La unica excepcion es la variable que retorna el procedimiento almacenado que por lo general se llamara 'resultado'.
*/

CREATE OR REPLACE FUNCTION schema.table(
	variable_vi METADATA
)
RETURNS METADATA AS
$BODY$
--Declarando las variables  
DECLARE  

--	Variables

	variable_v METDATA := null;

BEGIN

    RETURN resultado;

EXCEPTION

    WHEN OTHERS THEN
        
    RETURN resultado;

END;$BODY$
LANGUAGE plpgsql VOLATILE
COST 100;

```

  * Estructura con excepcion y auditoria, de forma que retorne un mensaje de error personalizado:


```
#!postgresql

/*
METADATA:
	* VARCHAR
	* INT
	* DATE
	* TIMESTAMP
	* TEXT
	* RECORD

1: Las Variables que son utlizadas para obtener la data de entrada terminan en '_vi', ejemplo: nombre_vi.
2: Las variables que son utlizadas para captura la data dentro del procedimiento almacenado terminan en '_v', ejemplo: nombre_apellido_v.
3: La unica excepcion es la variable que retorna el procedimiento almacenado que por lo general se llamara 'resultado'.
*/

CREATE OR REPLACE FUNCTION schema.table(
usuario_ini_id_vi BIGINT,
data_vi TEXT
)
RETURNS RECORD AS
$BODY$
--Declarando las variables
DECLARE

--  Variables de Resultado
    resultado record;

--  Variables de exception
--      Seccion que permite localizar hasta que punto corrio el codigo hasta que se genero el error.
    seccion_v SMALLINT := 0;
    mensaje_v VARCHAR := 'Aun no ha generado el mensaje para esta respuesta.'; --SQLERRM

--  Variables de auditoria
    fecha_hora_v DATE := NOW();
    ipaddress_v VARCHAR := ''; -- Si es necesario capturar la ip del servidor donde se aloja la base de datos se usa: 'inet_client_addr();'
    tipo_transaccion_v VARCHAR := 'ESCRITURA'; --Si es ESCRITURA, ELIMINACION, EDICION o LECTURA
    modulo_v VARCHAR := 'modulo.controlador.accion'; --Modulo.Controlador.Accion
    transaccion_v VARCHAR := null;
    resultado_transaccion_v VARCHAR := null;
    mensaje_auditoria_v VARCHAR := null;
    username_v VARCHAR := '';

BEGIN

    /**
      En lo posible evitar los if anidados, en vez de anidar if para continuar el flujo se agrega un IF que lo detenga
      en caso de no cumplir la condicion, el exception se encargara de todo.
       el if tendra esta forma:
      IF ("condicion para detener el flujo") THEN
        mensaje := 'No cumple con la condicion.';
        resultado_transaccion_v := 'alert';
        RAISE EXCEPTION 'mensaje del error';
      END IF;
    **/

    seccion_v := 1;

    resultado_transaccion_v := 'success';

    SELECT
        mensaje_v,
        seccion_v,
        resultado_transaccion_v
        --Campos
    INTO
        resultado;

--  AUDITORIA
    INSERT INTO
        auditoria.traza(
            fecha_hora,
            ip_maquina,
            tipo_transaccion,
            modulo,
            resultado_transaccion,
            descripcion,
            user_id,
            username,
            data
        ) VALUES (
            fecha_hora_v,
            ipaddress_v,
            tipo_transaccion_v,
            modulo_v,
            resultado_transaccion_v,
            mensaje_auditoria_v,
            usuario_ini_id_vi,
            username_v,
            data_vi
        );
    RETURN resultado;

EXCEPTION

    WHEN OTHERS THEN
    transaccion_v := SQLSTATE;
    IF resultado_transaccion_v is null OR length(resultado_transaccion_v) = 0 THEN
      resultado_transaccion_v := 'error';
    END IF;
    mensaje_auditoria_v := 'ACTIBACION DE POSTULACION PARA ENTREVISTA: '||SQLERRM||' (ERROR NRO: '||SQLSTATE||') (Seccion: '||seccion_v||') (Resultado: '||transaccion_v||')';
    mensaje_v := SQLERRM;

--  AUDITORIA
    INSERT INTO
      auditoria.traza(
          fecha_hora,
          ip_maquina,
          tipo_transaccion,
          modulo,
          resultado_transaccion,
          descripcion,
          user_id,
          username,
          data
      ) VALUES (
          fecha_hora_v,
          ipaddress_v,
          tipo_transaccion_v,
          modulo_v,
          resultado_transaccion_v,
          mensaje_auditoria_v,
          usuario_ini_id_vi,
          username_v,
          data_vi
      );

    SELECT
        mensaje_v,
        seccion_v
        --Campos
    INTO
        resultado;

    RETURN resultado;

END;$BODY$
LANGUAGE plpgsql VOLATILE
COST 100;

``` 
  * Bucles.


```
#!postgresql

FOR i IN 1..10 LOOP
    -- i will take on the values 1,2,3,4,5,6,7,8,9,10 within the loop
END LOOP;

FOR i IN REVERSE 10..1 LOOP
    -- i will take on the values 10,9,8,7,6,5,4,3,2,1 within the loop
END LOOP;

FOR i IN REVERSE 10..1 BY 2 LOOP
    -- i will take on the values 10,8,6,4,2 within the loop
END LOOP;

```



*Al crear una Tabla en la base de datos se utiliza la siguiente estructura de Base
```
#!sql
/*

Remplazar con ctrl + f en un editor de texto

*- schema

*- tabla

*/

CREATE TABLE schema.tabla
(
  id serial NOT NULL,
  /*
  Campos
  */
  usuario_ini_id integer NOT NULL,
  fecha_ini date NOT NULL DEFAULT (now())::timestamp(0) without time zone,
  usuario_act_id integer NOT NULL,
  fecha_act date NOT NULL DEFAULT (now())::timestamp(0) without time zone,
  estatus character varying(1) NOT NULL DEFAULT 'A'::character varying,
  CONSTRAINT tabla_pkey PRIMARY KEY (id),
  CONSTRAINT tabla_usuario_act_id_fk2 FOREIGN KEY (usuario_act_id)
      REFERENCES seguridad.usergroups_user (id) MATCH SIMPLE
      ON UPDATE NO ACTION ON DELETE NO ACTION,
  CONSTRAINT tabla_usuario_ini_id_fk1 FOREIGN KEY (usuario_ini_id)
      REFERENCES seguridad.usergroups_user (id) MATCH SIMPLE
      ON UPDATE NO ACTION ON DELETE NO ACTION,
  CONSTRAINT tabla_id_nombre_codigo_key UNIQUE (id, nombre, abreviatura)
);

ALTER TABLE schema.tabla
  OWNER TO postgres;
GRANT ALL ON TABLE schema.tabla TO postgres WITH GRANT OPTION;
GRANT ALL ON TABLE schema.tabla TO divsistemas WITH GRANT OPTION;


```

## Desconectar Todos los usuarios de una Base de Datos y eliminar la Base de Datos


```
#!postgreSQL

SELECT COUNT(*) AS users_online FROM pg_stat_activity WHERE datname='app_naiguata_new';

SELECT pg_terminate_backend(procpid) FROM pg_stat_activity WHERE datname='app_naiguata_new' AND procpid<>pg_backend_pid();


DROP DATABASE app_naiguata_new;
```

