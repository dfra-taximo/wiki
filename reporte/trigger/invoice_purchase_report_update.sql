
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

/*

UPDATE invoice_purchase SET id = id WHERE id = id;

*/