/*

SQL ORIGINAL


SELECT 
    ipd.id,
    ipd.auditor_id,
    ipd.entry_date as ipddate,
    ipd.id as ipdid,
    ip.entry_date,
    tt.label AS tipoop,
    cn.label AS concepto,
    ip.provider_id, 
    pr.name,
    pr.document_type_id,
    pr.lastname,
    prl.name||' '||prl.lastname as commercial_name,
    ipt.label AS type_document,
    ip.date AS fechadoc,
    ip.date_expiration AS fecha_exp,
    ip.number AS number_doc,
    cp.label AS caja,
    COALESCE (cy.name,ccostc.name) AS ciudad,
    cp.label as ciudad_caja,
    cc.contract_id AS contract,
    COALESCE((cy.name||'  '||tty.label||'  '||sca.label),t.plate) AS ccenter,
    fm.id AS fmid,
    fm.label AS fmlabel,
    sys.id AS sysid,
    sys.label AS syslabel, 
    sub.id AS subid,
    sub.label AS sublabel,
    ipd.detail,
    prl.name AS name_legalizer,
    prl.lastname AS lastname_legalizer,
    ipd.quantity,
    ipd.exempt_tax_cost,
    ipd.cost, 
    ipd.cost_to_pay,
    ipd.costiva, 
    ipd.costreteica,
    ipd.costretefuente,
    ipd.costimpoconsumo, 
    ipd.costigv,
    ipd.cloudfleet_move_id,
    mt.id AS move_id,
    mt.label AS move_label,
    mt.name AS move_name
FROM 
    invoice_purchase_detail AS ipd
    LEFT JOIN invoice_purchase AS ip on ipd.invoice_purchase_id=ip.id
    LEFT JOIN person as pr on pr.id=ip.provider_id
    LEFT JOIN invoice_purchase_type as ipt on ipt.id=ip.invoice_purchase_type_id
    LEFT JOIN concept AS cn ON ipd.concept_id=cn.id 
    LEFT JOIN family AS fm ON ipd.family_id=fm.id 
    LEFT JOIN system AS sys ON ipd.system_id=sys.id
    LEFT JOIN subsystem AS sub ON ipd.sbsystem_id=sub.id 
    LEFT JOIN transaction_type AS tt ON ipd.transaction_type_id=tt.id 
    LEFT JOIN cost_center AS cc ON ipd.cost_center_id=cc.id
    LEFT JOIN cost_center_admin cca ON cc.cost_center_admin_id=cca.id
    LEFT JOIN subcost_center_admin sca ON cca.subcost_center_admin_id=sca.id 
    LEFT JOIN territory_type as tty ON cca.territory_type_id=tty.id 
    LEFT JOIN city cy ON cca.territory_id=cy.id
    LEFT JOIN contract c ON cc.contract_id=c.id
    LEFT JOIN taxi t ON c.taxi_id=t.id
    LEFT JOIN fleet f ON t.fleet_id=f.id
    LEFT JOIN city ccostc ON f.city_id=ccostc.id 
    LEFT JOIN movement_type AS mt ON mt.id=tt.movement_type_id
    LEFT JOIN cash_point AS cp ON cp.id=ip.cash_point_id
    LEFT JOIN person AS prl ON prl.id=ip.provider_id
    LEFT JOIN accounting_period ap ON ip.accounting_period_id=ap.id
    
    LEFT JOIN provider_status AS prs ON prs.provider_id=ip.provider_id
WHERE 
    ap.year=:year
    and ap.month=:month
    and ap.cash_point_id=:cash_point_id
    and ip.annulled=false
    and ipd.active is true
    and prs.date=(
            SELECT 
                    MAX(date)
            FROM
                    provider_status
            WHERE
                    provider_id=ip.provider_id);


-- La Consulta quedara de la siguiente forma 
SELECT 
    id, auditor_id, ipddate, ipdid, entry_date, tipoop, concepto, provider_id, name, document_type_id, lastname, commercial_name, type_document, fechadoc, fecha_exp, number_doc, caja, ciudad, ciudad_caja, contract, ccenter, fmid, fmlabel, sysid, syslabel, subid, sublabel, detail, name_legalizer, lastname_legalizer, quantity, exempt_tax_cost, cost, cost_to_pay, costiva, costreteica, costretefuente, costimpoconsumo, costigv, cloudfleet_move_id, move_id, move_label, move_name
FROM reports.reporte_periodo 
WHERE 
    year_input = :year 
    AND month_input = :month 
    AND cash_point_id_input = :cash_point_id 
    AND annulled is false
    AND active is true;

-- Es necesario despues de ingresar el trigger realizar un update sin realizar modificaciones para
llenar la tabla la tabla

UPDATE invoice_purchase_detail SET id = id WHERE id = id;

*/


DROP TRIGGER IF EXISTS invoice_purchase_detail_update_report ON public.invoice_purchase_detail;

DROP FUNCTION IF EXISTS reports.invoice_purchase_detail_update_report_function();

-- Función que será ejecutada por el trigger
CREATE OR REPLACE FUNCTION reports.invoice_purchase_detail_update_report_function()
  RETURNS trigger AS
$BODY$
DECLARE


--Variables

	--Variables Generales
	commercial_name_v VARCHAR := null;
	ciudad_v VARCHAR := null;
	ccenter_v VARCHAR := null;


	-- invoice_purchase
	ip_id_v BIGINT := null;
	entry_date_v TIMESTAMP WITHOUT TIME ZONE := null;
	provider_id_v BIGINT := null;
	fechadoc_v DATE := null;
	fecha_exp_v DATE := null;
	number_doc_v VARCHAR := null;
	invoice_purchase_type_id_v INTEGER := null;
	cash_point_id_v INTEGER := null;
	accounting_period_id_v INTEGER := null;
	annulled_v BOOLEAN := null;

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
	sysid_v INTEGER := null;
	syslabel_v VARCHAR := null;

	-- subsystem
	subid_v INTEGER := null;
	sublabel_v VARCHAR := null;

	-- transaction_type
	tipoop_v VARCHAR := null;
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
	cy_name_v VARCHAR := NULL;

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
	max_date_v DATE := null;

	-- cash_point
	caja_v VARCHAR := null;
	ciudad_caja_v VARCHAR := null;

	-- person ext
	name_legalizer_v VARCHAR := NULL;
	lastname_legalizer_v VARCHAR := NULL;

	--
	cash_point_id_input_v INTEGER := NULL;
	year_input_v INTEGER := null;
	month_input_v INTEGER := null;

	active_v BOOLEAN := NEW.active;


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
	count_cash_point_v INTEGER := 0;
	count_person_ext_v INTEGER := 0;
	count_accounting_period_v INTEGER := 0;

BEGIN


	-- Obtenemos los datos de invoice_purchase
	SELECT count(1) INTO count_invoice_purchase_v FROM invoice_purchase WHERE id = NEW.invoice_purchase_id AND NEW.invoice_purchase_id is not null;
	IF count_invoice_purchase_v != 0 THEN
		SELECT 
			id, entry_date, provider_id, date, date_expiration, number, invoice_purchase_type_id, cash_point_id, accounting_period_id, annulled 
		INTO 
			ip_id_v, entry_date_v, provider_id_v, fechadoc_v, fecha_exp_v, number_doc_v, invoice_purchase_type_id_v, cash_point_id_v, accounting_period_id_v, annulled_v 
		FROM invoice_purchase WHERE id = NEW.invoice_purchase_id;
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
		SELECT id, label INTO sysid_v, syslabel_v FROM system WHERE id = NEW.system_id AND NEW.system_id is not null;
	END IF;

	--	Obtenemos los datos de subsystem
	SELECT count(1) INTO count_subsystem_v FROM subsystem WHERE id = NEW.sbsystem_id AND NEW.sbsystem_id is not null;
	IF count_subsystem_v != 0 THEN
		SELECT id, label INTO subid_v, sublabel_v FROM subsystem WHERE id = NEW.sbsystem_id AND NEW.sbsystem_id is not null;
	END IF;

	--	Obtenemos los datos de transaction_type
	SELECT count(1) INTO count_transaction_type_v FROM transaction_type WHERE id = NEW.transaction_type_id AND NEW.transaction_type_id is not null;
	IF count_transaction_type_v != 0 THEN
		SELECT label, movement_type_id INTO tipoop_v, movement_type_id_v FROM transaction_type WHERE id = NEW.transaction_type_id AND NEW.transaction_type_id is not null;
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
		SELECT label INTO tty_label_v FROM territory_type WHERE id = territory_type_id_v AND territory_type_id_v is not null;
	END IF;

	--	Obtenemos los datos de city
	SELECT count(1) INTO count_city_v FROM city WHERE id = territory_id_v AND territory_id_v is not null;
	IF count_city_v != 0 THEN
		SELECT name INTO cy_name_v FROM city WHERE id = territory_id_v AND territory_id_v is not null;
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

	--	Obtenemos los datos de cash_point
	SELECT count(1) INTO count_cash_point_v FROM cash_point WHERE id = cash_point_id_v AND cash_point_id_v is not null;
	IF count_cash_point_v != 0 THEN
		SELECT label, label INTO caja_v, ciudad_caja_v FROM cash_point WHERE id = cash_point_id_v AND cash_point_id_v is not null;
	END IF;

	--	Obtenemos los datos de person ext
	SELECT count(1) INTO count_person_v FROM person WHERE id = provider_id_v AND provider_id_v is not null;
	IF count_person_v != 0 THEN
		SELECT name, lastname INTO name_legalizer_v, lastname_legalizer_v FROM person WHERE id = provider_id_v AND provider_id_v is not null;
	END IF;

	--	Obtenemos los datos de accounting_period
	SELECT count(1) INTO count_accounting_period_v FROM accounting_period WHERE id = accounting_period_id_v AND accounting_period_id_v is not null;
	IF count_accounting_period_v != 0 THEN
		SELECT year, month, cash_point_id INTO year_input_v, month_input_v, cash_point_id_input_v FROM accounting_period WHERE id = accounting_period_id_v AND accounting_period_id_v is not null;
	END IF;

	SELECT MAX(date) INTO max_date_v FROM provider_status WHERE provider_id=provider_id_v;

	--	Obtenemos los datos de provider_status
	SELECT count(1) INTO count_provider_status_v FROM provider_status WHERE provider_id = id AND provider_id_v is not null;
	IF count_provider_status_v != 0 THEN
		SELECT  max(date) INTO max_date_v FROM provider_status WHERE id = provider_id_v AND provider_id_v is not null;
	END IF;


	commercial_name_v:= name_legalizer_v||' '||lastname_legalizer_v;

	ciudad_v := COALESCE (cy_name_v,ccostc_name_v);

	ccenter_v := COALESCE((cy_name_v||'  '||tty_label_v||'  '||sca_label_v),plate_v);

	active_v := NEW.active;


	-- RAISE NOTICE 'concepto_v: %' , concepto_v;
	SELECT count(1) INTO count_reporte_periodo_v FROM reports.reporte_periodo WHERE  id = NEW.id;
	IF count_reporte_periodo_v = 0 THEN
		INSERT INTO reports.reporte_periodo 
			(
				id,
				auditor_id,
				ipddate,
				ipdid,
				entry_date,
				tipoop,
				concepto,
				provider_id,
				name,
				document_type_id,
				lastname,
				commercial_name,
				type_document,
				fechadoc,
				fecha_exp,
				number_doc,
				caja,
				ciudad,
				ciudad_caja,
				contract,
				ccenter,
				fmid,
				fmlabel,
				sysid,
				syslabel,
				subid,
				sublabel,
				detail,
				name_legalizer,
				lastname_legalizer,
				quantity,
				exempt_tax_cost,
				cost,
				cost_to_pay,
				costiva,
				costreteica,
				costretefuente,
				costimpoconsumo,
				costigv,
				cloudfleet_move_id,
				move_id,
				move_label,
				move_name,
				year_input,
				month_input,
				cash_point_id_input,
				max_date,
				annulled,
				active
			) 
		VALUES 
			(
				NEW.id,
				NEW.auditor_id,
				NEW.entry_date,
				NEW.id,
				entry_date_v,
				tipoop_v,
				concepto_v,
				provider_id_v,
				name_v,
				document_type_id_v,
				lastname_v,
				commercial_name_v,
				type_document_v,
				fechadoc_v,
				fecha_exp_v,
				number_doc_v,
				caja_v,
				ciudad_v,
				ciudad_caja_v,
				contract_v,
				ccenter_v,
				fmid_v,
				fmlabel_v,
				sysid_v,
				syslabel_v,
				subid_v,
				sublabel_v,
				NEW.detail,
				name_legalizer_v,
				lastname_legalizer_v,
				NEW.quantity,
				NEW.exempt_tax_cost,
				NEW.cost,
				NEW.cost_to_pay,
				NEW.costiva,
				NEW.costreteica,
				NEW.costretefuente,
				NEW.costimpoconsumo,
				NEW.costigv,
				NEW.cloudfleet_move_id,
				move_id_v,
				move_label_v,
				move_name_v,
				year_input_v,
				month_input_v,
				cash_point_id_input_v,
				max_date_v,
				annulled_v,
				active_v
			);
	ELSE
		UPDATE reports.reporte_periodo SET
			auditor_id = NEW.auditor_id,
			ipddate = NEW.entry_date,
			ipdid = NEW.id,
			entry_date = entry_date_v,
			tipoop = tipoop_v,
			concepto = concepto_v,
			provider_id = provider_id_v,
			name = name_v,
			document_type_id = document_type_id_v,
			lastname = lastname_v,
			commercial_name = commercial_name_v,
			type_document = type_document_v,
			fechadoc = fechadoc_v,
			fecha_exp = fecha_exp_v,
			number_doc = number_doc_v,
			caja = caja_v,
			ciudad = ciudad_v,
			ciudad_caja = ciudad_caja_v,
			contract = contract_v,
			ccenter = ccenter_v,
			fmid = fmid_v,
			fmlabel = fmlabel_v,
			sysid = sysid_v,
			syslabel = syslabel_v,
			subid = subid_v,
			sublabel = sublabel_v,
			detail = NEW.detail,
			name_legalizer = name_legalizer_v,
			lastname_legalizer = lastname_legalizer_v,
			quantity = NEW.quantity,
			exempt_tax_cost = NEW.exempt_tax_cost,
			cost = NEW.cost,
			cost_to_pay = NEW.cost_to_pay,
			costiva = NEW.costiva,
			costreteica = NEW.costreteica,
			costretefuente = NEW.costretefuente,
			costimpoconsumo = NEW.costimpoconsumo,
			costigv = NEW.costigv,
			cloudfleet_move_id = NEW.cloudfleet_move_id,
			move_id = move_id_v,
			move_label = move_label_v,
			move_name = move_name_v,
			year_input = year_input_v,
			month_input = month_input_v,
			cash_point_id_input = cash_point_id_input_v,
			max_date = max_date_v,
			annulled = annulled_v,
			active = active_v
		WHERE id = NEW.id;
	END IF;
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

