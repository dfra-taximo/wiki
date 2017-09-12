
DROP TRIGGER IF EXISTS invoice_purchase_report ON public.invoice_purchase;

DROP FUNCTION IF EXISTS reports.invoice_purchase_update_report_function();

-- Función que será ejecutada por el trigger
CREATE OR REPLACE FUNCTION reports.invoice_purchase_update_report_function()
  RETURNS trigger AS
$BODY$
DECLARE
--Variables
--	COUNTS
	count_reporte_periodo INTEGER := 0;

BEGIN

	IF TG_OP = 'DELETE' THEN
		-- RAISE NOTICE 'DELETE';
	ELSE

	RAISE NOTICE '' , NEW.id ;
		/*
		SELECT count(1) INTO count_reporte_periodo FROM reports.reporte_periodo WHERE  id = NEW.id;
		IF count_reporte_periodo = 0 THEN
			INSERT INTO reports.reporte_periodo 
				(id, auditor_id, ipddate, ipdid, detail, quantity, exempt_tax_cost, cost, cost_to_pay, costiva, costreteica, costretefuente, costimpoconsumo, costigv, cloudfleet_move_id) 
			VALUES 
				(NEW.id, NEW.auditor_id, NEW.entry_date, NEW.id, NEW.detail, NEW.quantity, NEW.exempt_tax_cost, NEW.cost, NEW.cost_to_pay, NEW.costiva, NEW.costreteica, NEW.costretefuente, NEW.costimpoconsumo, NEW.costigv, NEW.cloudfleet_move_id);
		ELSE
			UPDATE reports.reporte_periodo SET
				auditor_id = NEW.auditor_id, ipddate = NEW.entry_date, ipdid = NEW.id, detail = NEW.detail, quantity = NEW.quantity, exempt_tax_cost = NEW.exempt_tax_cost, cost = NEW.cost, cost_to_pay = NEW.cost_to_pay, costiva = NEW.costiva, costreteica = NEW.costreteica, costretefuente = NEW.costretefuente, costimpoconsumo = NEW.costimpoconsumo, costigv = NEW.costigv, cloudfleet_move_id = NEW.cloudfleet_move_id
			WHERE id = NEW.id;
		END IF;
		*/
	END IF;
    RETURN NEW;
END;
$BODY$
  LANGUAGE plpgsql VOLATILE
  COST 100;

-- Definición del Trigger
CREATE TRIGGER invoice_purchase_report
  AFTER INSERT OR UPDATE OR DELETE
  ON public.invoice_purchase
  FOR EACH ROW
  EXECUTE PROCEDURE reports.invoice_purchase_update_report_function();

/*
UPDATE invoice_purchase SET id = id WHERE id = 5002;
UPDATE invoice_purchase SET id = id WHERE id = 5004;
UPDATE invoice_purchase SET id = id WHERE id = id;


SELECt * FROM reports.reporte_periodo;
*/