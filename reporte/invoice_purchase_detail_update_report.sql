
CREATE SCHEMA IF NOT EXISTS reports;

CREATE TABLE IF NOT EXISTS reports.reporte_periodo AS SELECT 
        ipd.id,
        ipd.auditor_id,
        ipd.entry_date as ipddate,
        ipd.id as ipdid,
        ip.entry_date,
        tt.label AS tipoop,
        cn.label AS concepto,
        ip.provider_id, pr.name,
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
        mt.name AS move_name,

        ipd.invoice_purchase_id,
        ip.invoice_purchase_type_id,
        ipd.concept_id,
        ipd.family_id,
        ipd.system_id,
        ipd.sbsystem_id,
        ipd.transaction_type_id,
        ipd.cost_center_id,
        cc.cost_center_admin_id,
        cca.subcost_center_admin_id,
        cca.territory_type_id,
        cca.territory_id,
        cc.type_cost_center_id,
        c.taxi_id,
        t.fleet_id,
        f.city_id,
        tt.movement_type_id,
        tt.transaction_class_id,
        ip.cash_point_id,
        ip.accounting_period_id,

        null::INTEGER as year_input,
        null::INTEGER as month_input,
        null::INTEGER as cash_point_id_input
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
        LEFT JOIN type_cost_center tcc ON cc.type_cost_center_id=tcc.id 
        LEFT JOIN contract c ON cc.contract_id=c.id
        LEFT JOIN taxi t ON c.taxi_id=t.id
        LEFT JOIN fleet f ON t.fleet_id=f.id
        LEFT JOIN city ccostc ON f.city_id=ccostc.id 
        LEFT JOIN movement_type AS mt ON mt.id=tt.movement_type_id
        LEFT JOIN transaction_class AS tc ON tc.id=tt.transaction_class_id
        LEFT JOIN provider_status AS prs ON prs.provider_id=ip.provider_id
        LEFT JOIN cash_point AS cp ON cp.id=ip.cash_point_id
        LEFT JOIN person AS prl ON prl.id=ip.provider_id
        LEFT JOIN accounting_period ap ON ip.accounting_period_id=ap.id
    WHERE 
        ipd.id = -1;