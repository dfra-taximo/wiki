
DROP TRIGGER IF EXISTS invoice_purchase_detail_update_report ON public.invoice_purchase_detail;

DROP FUNCTION IF EXISTS reports.invoice_purchase_detail_update_report_function();

-- Función que será ejecutada por el trigger
CREATE OR REPLACE FUNCTION reports.invoice_purchase_detail_update_report_function()
  RETURNS trigger AS
$BODY$
DECLARE


--Variables

	-- invoice_purchase
	entry_date_v TIMESTAMP WITHOUT TIME ZONE := null;
	provider_id_v BIGINT := null;
	date_v DATE := null;
	date_expiration_v DATE := null;
	number_v VARCHAR := null;
	invoice_purchase_type_id_v INTEGER := null;

	-- person
	name_v VARCHAR := null;
	document_type_id_v INTEGER := null;
	lastname_v VARCHAR := null;

	--	invoice_purchase_type
	type_document_v VARCHAR := null;

	-- concept
	concepto_v VARCHAR := null;

	-- family
	fmid_v  INTEGER := null;
	fmlabel_v  VARCHAR := null;

	-- system
	sysid INTEGER := null;
	syslabel VARCHAR := null;

	-- subsystem
	subid_v INTEGER := null;
	sublabel_v VARCHAR := null;

	-- transaction_type
	tipoop VARCHAR := null;
	movement_type_id_v INTEGER := null;

	-- cost_center
	contract_v INTEGER := null;
	cost_center_admin_id_v INTEGER := null;

	-- cost_center_admin
	subcost_center_admin_id_v INTEGER := null;
	territory_type_id_v INTEGER := null;
	territory_id_v INTEGER := null;

	-- ubcost_center_admin
	sca_label_v VARCHAR := NULL;

	-- territory_type
	tty_label_v VARCHAR := NULL;

	-- city
	cy_name VARCHAR := NULL;
	ciudad VARCHAR := NULL;

	-- contract
	taxi_id_v INTEGER := null;

	-- taxi
	plate_v VARCHAR := null;
	fleet_id_v INTEGER := null; 

	-- fleet
	city_id_fleet_v INTEGER := null;

	--	city ccostc
	ccostc_name_v VARCHAR := null;

	-- movement_type
	move_id_v INTEGER := null;
	move_label_v VARCHAR := null;
	move_name_v VARCHAR := null;

	-- provider_status
	provider_status_date_v DATE := null;
	max_date_provider DATE := null;


--	COUNTS
	count_invoice_purchase_v INTEGEr := 0;
	count_reporte_periodo_v INTEGER := 0;
	count_person_v INTEGER := 0;
	count_invoice_purchase_type_v INTEGER := 0;
	count_concept_v INTEGER := 0;
	count_family_v INTEGER := 0;
	count_system_v INTEGER := 0;
	count_subsystem_v INTEGER := 0;
	count_transaction_type_v INTEGER := 0;
	count_cost_center_v INTEGER := 0;
	count_cost_center_admin_v INTEGER := 0;
	count_subcost_center_admin_v INTEGER := 0;
	count_city_v INTEGER := 0;
	count_type_cost_center_v INTEGER := 0;
	count_contract_v INTEGER := 0;
	count_taxi_v INTEGER := 0;
	count_territory_type_v INTEGER := 0;
	count_fleet_v INTEGER := 0;
	count_movement_type_v INTEGER := 0;
	count_provider_status_v INTEGER := 0;

BEGIN


	-- Obtenemos los datos de invoice_purchase
	SELECT count(1) INTO count_invoice_purchase_v FROM invoice_purchase WHERE id = NEW.invoice_purchase_id AND NEW.invoice_purchase_id is not null;
	IF count_invoice_purchase_v != 0 THEN
		SELECT entry_date, provider_id, date, date_expiration, number, invoice_purchase_type_id INTO entry_date_v, provider_id_v, date_v, date_expiration_v, number_v, invoice_purchase_type_id_v FROM invoice_purchase WHERE id = NEW.invoice_purchase_id;
	END IF;

	-- Obtenemos los datos de person
	SELECT count(1) INTO count_person_v FROM person WHERE id = provider_id_v AND provider_id_v is not null;
	IF count_person_v != 0 THEN 
		SELECT name, document_type_id, lastname INTO name_v, document_type_id_v, lastname_v FROM person WHERE id = provider_id_v;
	END IF;

	-- Obtenemos los datos de  invoice_purchase_type
	SELECT count(1) INTO count_invoice_purchase_type_v FROM invoice_purchase_type WHERE id = invoice_purchase_type_id_v AND invoice_purchase_type_id_v is not null;
	IF count_invoice_purchase_type_v != 0 THEN
		SELECT label INTO type_document_v FROM invoice_purchase_type WHERE id = invoice_purchase_type_id_v;
	END IF;

	--	Obtenemos los datos de concept
	SELECT count(1) INTO count_concept_v FROM concept WHERE id = NEW.concept_id AND NEW.concept_id is not null;
	IF count_concept_v != 0 THEN
		SELECT label INTO concepto_v FROM concept WHERE id = NEW.concept_id AND NEW.concept_id is not null;
	END IF;

	--	Obtenemos los datos de family
	SELECT count(1) INTO count_family_v FROM family WHERE id = NEW.family_id AND NEW.family_id is not null;
	IF count_family_v != 0 THEN
		SELECT id, label INTO fmid_v, fmlabel_v FROM family WHERE id = NEW.family_id AND NEW.family_id is not null;
	END IF;

	--	Obtenemos los datos de system
	SELECT count(1) INTO count_system_v FROM system WHERE id = NEW.system_id AND NEW.system_id is not null;
	IF count_system_v != 0 THEN
		SELECT id, label INTO sysid, syslabel FROM system WHERE id = NEW.system_id AND NEW.system_id is not null;
	END IF;

	--	Obtenemos los datos de subsystem
	SELECT count(1) INTO count_subsystem_v FROM subsystem WHERE id = NEW.sbsystem_id AND NEW.sbsystem_id is not null;
	IF count_subsystem_v != 0 THEN
		SELECT id, label INTO sysid, syslabel FROM subsystem WHERE id = NEW.sbsystem_id AND NEW.sbsystem_id is not null;
	END IF;

	--	Obtenemos los datos de transaction_type
	SELECT count(1) INTO count_transaction_type_v FROM transaction_type WHERE id = NEW.transaction_type_id AND NEW.transaction_type_id is not null;
	IF count_transaction_type_v != 0 THEN
		SELECT label, movement_type_id INTO tipoop, movement_type_id_v FROM transaction_type WHERE id = NEW.transaction_type_id AND NEW.transaction_type_id is not null;
	END IF;

	--	Obtenemos los datos de cost_center
	SELECT count(1) INTO count_cost_center_v FROM cost_center WHERE id = NEW.cost_center_id AND NEW.cost_center_id is not null;
	IF count_cost_center_v != 0 THEN
		SELECT contract_id, cost_center_admin_id INTO contract_v, cost_center_admin_id_v FROM cost_center WHERE id = NEW.cost_center_id AND NEW.cost_center_id is not null;
	END IF;

	--	Obtenemos los datos de cost_center_admin
	SELECT count(1) INTO count_cost_center_admin_v FROM cost_center_admin WHERE id = cost_center_admin_id_v AND cost_center_admin_id_v is not null;
	IF count_cost_center_admin_v != 0 THEN
		SELECT subcost_center_admin_id ,territory_type_id ,territory_id INTO subcost_center_admin_id_v ,territory_type_id_v ,territory_id_v FROM cost_center_admin WHERE id = cost_center_admin_id_v AND cost_center_admin_id_v is not null;
	END IF;

	--	Obtenemos los datos de subcost_center_admin
	SELECT count(1) INTO count_subcost_center_admin_v FROM subcost_center_admin WHERE id = subcost_center_admin_id_v AND subcost_center_admin_id_v is not null;
	IF count_subcost_center_admin_v != 0 THEN
		SELECT label INTO sca_label_v FROM subcost_center_admin WHERE id = subcost_center_admin_id_v AND subcost_center_admin_id_v is not null;
	END IF;

	--	Obtenemos los datos de territory_type
	SELECT count(1) INTO count_territory_type_v FROM territory_type WHERE id = territory_type_id_v AND territory_type_id_v is not null;
	IF count_territory_type_v != 0 THEN
		SELECT id, label INTO sysid, syslabel FROM territory_type WHERE id = territory_type_id_v AND territory_type_id_v is not null;
	END IF;

	--	Obtenemos los datos de city
	SELECT count(1) INTO count_city_v FROM city WHERE id = territory_id_v AND territory_id_v is not null;
	IF count_city_v != 0 THEN
		SELECT name INTO cy_name FROM city WHERE id = territory_id_v AND territory_id_v is not null;
	END IF;

	--	Obtenemos los datos de contract
	SELECT count(1) INTO count_contract_v FROM contract WHERE id = contract_v AND contract_v is not null;
	IF count_contract_v != 0 THEN
		SELECT taxi_id INTO taxi_id_v FROM contract WHERE id = contract_v AND contract_v is not null;
	END IF;

	--	Obtenemos los datos de taxi
	SELECT count(1) INTO count_taxi_v FROM taxi WHERE id = taxi_id_v AND taxi_id_v is not null;
	IF count_taxi_v != 0 THEN
		SELECT plate, fleet_id INTO plate_v, fleet_id_v FROM taxi WHERE id = taxi_id_v AND taxi_id_v is not null;
	END IF;

	--	Obtenemos los datos de fleet
	SELECT count(1) INTO count_fleet_v FROM fleet WHERE id = fleet_id_v AND fleet_id_v is not null;
	IF count_fleet_v != 0 THEN
		SELECT city_id INTO city_id_fleet_v FROM fleet WHERE id = fleet_id_v AND fleet_id_v is not null;
	END IF;

	count_city_v := 0;
	--	Obtenemos los datos de city ccostc
	SELECT count(1) INTO count_city_v FROM city WHERE id = city_id_fleet_v AND city_id_fleet_v is not null;
	IF count_city_v != 0 THEN
		SELECT name INTO ccostc_name_v FROM city WHERE id = city_id_fleet_v AND city_id_fleet_v is not null;
	END IF;

	--	Obtenemos los datos de movement_type
	SELECT count(1) INTO count_movement_type_v FROM movement_type WHERE id = movement_type_id_v AND movement_type_id_v is not null;
	IF count_movement_type_v != 0 THEN
		SELECT id, label, name INTO move_id_v, move_label_v, move_name_v FROM movement_type WHERE id = movement_type_id_v AND movement_type_id_v is not null;
	END IF;

	--	Obtenemos los datos de provider_status
	SELECT count(1) INTO count_provider_status_v FROM provider_status WHERE id = provider_id_v AND provider_id_v is not null;
	IF count_provider_status_v != 0 THEN
		SELECT date INTO provider_status_date_v FROM provider_status WHERE id = provider_id_v AND provider_id_v is not null;
	END IF;

	SELECT max(date) INTO max_date_provider FROM provider_status WHERE provider_id = provider_id_v;

	

	-- RAISE NOTICE 'concepto_v: %' , concepto_v;
	-- SELECT count(1) INTO count_reporte_periodo_v FROM reports.reporte_periodo WHERE  id = NEW.id;
	-- IF count_reporte_periodo_v = 0 THEN
	-- 	INSERT INTO reports.reporte_periodo 
	-- 		(id, auditor_id, ipddate, ipdid, detail, quantity, exempt_tax_cost, cost, cost_to_pay, costiva, costreteica, costretefuente, costimpoconsumo, costigv, cloudfleet_move_id, invoice_purchase_id, concept_id, family_id, system_id, sbsystem_id, transaction_type_id, cost_center_id) 
	-- 	VALUES 
	-- 		(NEW.id, NEW.auditor_id, NEW.entry_date, NEW.id, NEW.detail, NEW.quantity, NEW.exempt_tax_cost, NEW.cost, NEW.cost_to_pay, NEW.costiva, NEW.costreteica, NEW.costretefuente, NEW.costimpoconsumo, NEW.costigv, NEW.cloudfleet_move_id, NEW.invoice_purchase_id, NEW.concept_id, NEW.family_id, NEW.system_id, NEW.sbsystem_id, NEW.transaction_type_id, NEW.cost_center_id);
	-- ELSE
	-- 	UPDATE reports.reporte_periodo SET
	-- 		auditor_id = NEW.auditor_id, ipddate = NEW.entry_date, ipdid = NEW.id, detail = NEW.detail, quantity = NEW.quantity, exempt_tax_cost = NEW.exempt_tax_cost, cost = NEW.cost, cost_to_pay = NEW.cost_to_pay, costiva = NEW.costiva, costreteica = NEW.costreteica, costretefuente = NEW.costretefuente, costimpoconsumo = NEW.costimpoconsumo, costigv = NEW.costigv, cloudfleet_move_id = NEW.cloudfleet_move_id, invoice_purchase_id = NEW.invoice_purchase_id, concept_id = NEW.concept_id, family_id = NEW.family_id, system_id = NEW.system_id, sbsystem_id = NEW.sbsystem_id, transaction_type_id = NEW.transaction_type_id, cost_center_id = NEW.cost_center_id 
	-- 	WHERE id = NEW.id;
	-- END IF;
    RETURN NEW;
END;
$BODY$
  LANGUAGE plpgsql VOLATILE
  COST 100;

-- Definición del Trigger
CREATE TRIGGER invoice_purchase_detail_update_report
  AFTER INSERT OR UPDATE
  ON public.invoice_purchase_detail
  FOR EACH ROW
  EXECUTE PROCEDURE reports.invoice_purchase_detail_update_report_function();

UPDATE invoice_purchase_detail SET id = id WHERE id = 5002;
SELECt * FROM reports.reporte_periodo;
/*
UPDATE invoice_purchase_detail SET id = id WHERE id = 5002;
UPDATE invoice_purchase_detail SET id = id WHERE id = id;


SELECt * FROM reports.reporte_periodo;
*/