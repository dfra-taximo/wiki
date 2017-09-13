/*
id                       | integer                     | not null default nextval('invoice_purchase_id_seq'::regclass)
number                   | character varying           | not null
date                     | date                        | not null
date_expiration          | date                        | not null
entry_date               | timestamp without time zone | not null
annulled                 | boolean                     | 
url_image                | character varying           | 
annuller_id              | bigint                      | 
cash_point_id            | integer                     | not null
invoice_purchase_type_id | integer                     | not null
accounting_period_id     | integer                     | not null
provider_id              | bigint                      | not null
creator_id               | bigint                      | 
payer_id   
*/


DROP TRIGGER IF EXISTS invoice_purchase_report_update ON public.invoice_purchase;

DROP FUNCTION IF EXISTS reports.invoice_purchase_report_update_function();

-- Función que será ejecutada por el trigger
CREATE OR REPLACE FUNCTION reports.invoice_purchase_report_update_function()
  RETURNS trigger AS
$BODY$
DECLARE
--Variables
--	COUNTS
	count_reporte_periodo INTEGER := 0;
BEGIN	

  
  RAISE NOTICE 'NEW.ID %' , NEW.id;


    RETURN NEW;
END;
$BODY$
  LANGUAGE plpgsql VOLATILE
  COST 100;

-- Definición del Trigger
CREATE TRIGGER invoice_purchase_report_update
  AFTER INSERT OR UPDATE
  ON public.invoice_purchase
  FOR EACH ROW
  EXECUTE PROCEDURE reports.invoice_purchase_report_update_function();

UPDATE invoice_purchase SET id = id WHERE id = 1052;
/*

UPDATE invoice_purchase SET id = id WHERE id = id;

*/