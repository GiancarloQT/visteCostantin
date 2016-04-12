SELECT     
	'' AS statoPag, ordcm.CSG_DOC, ordcm.CKY_SAZ_DOC, ordcm.NGB_SR_DOC, ordcm.NGL_DOC, ordcm.CKY_CNT_CLFR, ordcd.DTT_SCAD, ordcm.NKY_PAG, 
    'vendite' AS origine, dbo.v_rate.PRG_RATA, 'xxx' AS cds_pag, dbo.v_rate.IKY_TIPO_RATA, dbo.v_rate.NGB_SCAD, 
	
	CASE COALESCE (dbo.v_rate.NPC_PAG, 0) WHEN 0 THEN 
		ordcd.NMP_VALMOV_UM1 / dbo.v_rate.num_rate 
	ELSE 
		ordcd.NMP_VALMOV_UM1 * dbo.v_rate.NPC_PAG / 100 
	END AS importo_rata, 
	
	DATEADD(day, dbo.v_rate.NGB_SCAD, ordcd.DTT_SCAD) AS scadenza_rata, 'ordini' AS Tipologia, COALESCE (vidr.V1CC_COMMESSA, '') AS Commessa, 
	
	CASE WHEN charindex('.', vidr.V1CC_COMMESSA) > 0 THEN 
		LTrim(RTrim(LEFT(vidr.V1CC_COMMESSA, charindex('.', vidr.V1CC_COMMESSA) - 1))) 
	ELSE 
		LTrim(RTrim(COALESCE (vidr.V1BB_RIFERIMENTO, ''))) 
	END AS commPadre, dbo.INN_RUDT.CDS_CNT_RAGSOC,
	
	CASE WHEN Coalesce(
	(SELECT ratePag.IKY_TIPO_RATA FROM 
		INN_TPAGAM_ANAPAG anaPag 
		LEFT JOIN INN_TPAGAM_RATE_PAG ratePag ON (ratePag.NKY_PAG = anaPag.NKY_PAG) 
	WHERE
	  (anaPag.NKY_PAG = ordcm.NKY_PAG)  and (ratePag.IKY_TIPO_RATA = 'M') and (ratePag.PRG_RATA = 1)), '') = 'M' THEN
	    Coalesce(rudtBanPref.CDS_CNT_RAGSOC, '')
	  else
	    ''
	  end as BANCA					  
FROM         
	dbo.INN_ORDC_M AS ordcm 
    INNER JOIN dbo.INN_ORDC_D AS ordcd ON ordcm.CSG_DOC = ordcd.CSG_DOC AND ordcm.CKY_SAZ_DOC = ordcd.CKY_SAZ_DOC 
		AND ordcm.NGB_SR_DOC = ordcd.NGB_SR_DOC AND ordcm.NGL_DOC = ordcd.NGL_DOC
    LEFT JOIN dbo.INN_RUDT ON ordcm.CKY_CNT_CLFR = dbo.INN_RUDT.CKY_CNT 
	LEFT JOIN INN_PICO PICO on (PICO.CKY_CNT = INN_RUDT.CKY_CNT)
	LEFT JOIN INN_RUDT rudtBanPref ON (rudtBanPref.CKY_CNT = pico.CKY_CNT_BAN_PREF)
	LEFT JOIN dbo.INN_ORDC_D_VIDR AS vidr ON vidr.ID = ordcd.ID 
	LEFT JOIN dbo.v_rate ON ordcm.NKY_PAG = dbo.v_rate.NKY_PAG
UNION
SELECT     
	'' AS statoPag, ordfm.CSG_DOC, ordfm.CKY_SAZ_DOC, ordfm.NGB_SR_DOC, ordfm.NGL_DOC, ordfm.CKY_CNT_CLFR, ordfd.DTT_SCAD, ordfm.NKY_PAG, 
    'acquisti' AS origine, dbo.v_rate.PRG_RATA, 'xxx' AS cds_pag, dbo.v_rate.IKY_TIPO_RATA, 
	dbo.v_rate.NGB_SCAD, - (ordfd.NMP_VALMOV_UM1 / dbo.v_rate.num_rate) AS importo_rata, 
	DATEADD(day, dbo.v_rate.NGB_SCAD, ordfd.DTT_SCAD) AS scadenza_rata, 'ordini' AS Tipologia, COALESCE (vidr.V1CC_COMMESSA, '') AS Commessa, 
	CASE WHEN charindex('.', vidr.V1CC_COMMESSA) > 0 THEN 
		LTrim(RTrim(LEFT(vidr.V1CC_COMMESSA, charindex('.', vidr.V1CC_COMMESSA) - 1))) 
    ELSE 
		LTrim(RTrim(COALESCE (vidr.V1CC_COMMESSA, ''))) 
	END AS commPadre, dbo.INN_RUDT.CDS_CNT_RAGSOC,
					  
	CASE WHEN Coalesce(
	(SELECT ratePag.IKY_TIPO_RATA FROM 
		INN_TPAGAM_ANAPAG anaPag 
		LEFT JOIN INN_TPAGAM_RATE_PAG ratePag ON (ratePag.NKY_PAG = anaPag.NKY_PAG) 
	WHERE
	  (anaPag.NKY_PAG = ordfm.NKY_PAG)  and (ratePag.IKY_TIPO_RATA = 'R') and (ratePag.PRG_RATA = 1)), '') = 'R' THEN
	    Coalesce(rudtBanPref.CDS_CNT_RAGSOC, '')
	  else
	    ''
	  end as BANCA
FROM         
	dbo.INN_ORDF_M AS ordfm 
    INNER JOIN dbo.INN_ORDF_D AS ordfd ON ordfm.CSG_DOC = ordfd.CSG_DOC AND ordfm.CKY_SAZ_DOC = ordfd.CKY_SAZ_DOC  
		AND ordfm.NGB_SR_DOC = ordfd.NGB_SR_DOC AND ordfm.NGL_DOC = ordfd.NGL_DOC 
    LEFT JOIN dbo.INN_RUDT ON ordfm.CKY_CNT_CLFR = dbo.INN_RUDT.CKY_CNT 
	LEFT JOIN INN_PICO PICO on (PICO.CKY_CNT = INN_RUDT.CKY_CNT)
	LEFT JOIN INN_RUDT rudtBanPref ON (rudtBanPref.CKY_CNT = pico.CKY_CNT_BAN_PREF)
	LEFT JOIN dbo.INN_ORDF_D_VIDR AS vidr ON vidr.ID = ordfd.ID 
	LEFT JOIN dbo.v_rate ON ordfm.NKY_PAG = dbo.v_rate.NKY_PAG
UNION
SELECT     
	'' AS statoPag, mmam.CSG_DOC, mmam.CKY_SAZ_DOC, mmam.NGB_SR_DOC, mmam.NGL_DOC, mmam.CKY_CNT_CLFR, mmam.DTT_DOC, mmam.NKY_PAG, 
    'vendite' AS origine, dbo.v_rate.PRG_RATA, 'xxx' AS cds_pag, dbo.v_rate.IKY_TIPO_RATA, dbo.v_rate.NGB_SCAD, 
    mmad.NMP_VALMOV_UM1 / dbo.v_rate.num_rate AS importo_rata, 
	DATEADD(day, dbo.v_rate.NGB_SCAD, mmam.DTT_DOC) AS scadenza_rata, 'mov' AS Tipologia, 
    COALESCE (vidr.V1CC_COMMESSA, '') AS Commessa, 
	CASE WHEN charindex('.', vidr.V1CC_COMMESSA) > 0 THEN 
		LTrim(RTrim(LEFT(vidr.V1CC_COMMESSA, charindex('.', vidr.V1CC_COMMESSA) - 1))) 
	ELSE 
		LTrim(RTrim(COALESCE (vidr.V1CC_COMMESSA, ''))) 
	END AS commPadre, dbo.INN_RUDT.CDS_CNT_RAGSOC,
					  
	CASE WHEN Coalesce(
	(SELECT ratePag.IKY_TIPO_RATA FROM 
		INN_TPAGAM_ANAPAG anaPag 
		LEFT JOIN INN_TPAGAM_RATE_PAG ratePag ON (ratePag.NKY_PAG = anaPag.NKY_PAG) 
	WHERE
	  (anaPag.NKY_PAG = mmam.NKY_PAG)  and (ratePag.IKY_TIPO_RATA = 'M') and (ratePag.PRG_RATA = 1)), '') = 'M' THEN
	    Coalesce(rudtBanPref.CDS_CNT_RAGSOC, '')
	  else
	    ''
	  end as BANCA					  
	  
FROM         
	dbo.INN_MMA_M AS mmam 
    INNER JOIN dbo.INN_MMA_D AS mmad ON mmam.ID = mmad.ID 
    LEFT JOIN dbo.INN_RUDT ON mmam.CKY_CNT_CLFR = dbo.INN_RUDT.CKY_CNT 
	LEFT JOIN INN_PICO PICO on (PICO.CKY_CNT = INN_RUDT.CKY_CNT)
	LEFT JOIN INN_RUDT rudtBanPref ON (rudtBanPref.CKY_CNT = pico.CKY_CNT_BAN_PREF)					  
	LEFT JOIN dbo.INN_MMA_D_VIDR AS vidr ON vidr.ID = mmad.ID 
    LEFT JOIN dbo.v_rate ON mmam.NKY_PAG = dbo.v_rate.NKY_PAG
WHERE     (mmam.CSG_DOC = 'BC') AND (mmam.anno = year(getdate()) OR(mmam.anno = year(getdate() - 1)))
UNION
SELECT     
	'' AS statoPag, mmam.CSG_DOC, mmam.CKY_SAZ_DOC, mmam.NGB_SR_DOC, mmam.NGL_DOC, mmam.CKY_CNT_CLFR, mmam.DTT_DOC, mmam.NKY_PAG, 
    'acquisti' AS origine, dbo.v_rate.PRG_RATA, 'xxx' AS cds_pag, dbo.v_rate.IKY_TIPO_RATA, dbo.v_rate.NGB_SCAD, 
    - (mmad.NMP_VALMOV_UM1 / dbo.v_rate.num_rate) AS importo_rata, 
	DATEADD(day, dbo.v_rate.NGB_SCAD, mmam.DTT_DOC) AS scadenza_rata, 'mov' AS Tipologia, 
    COALESCE (vidr.V1CC_COMMESSA, '') AS Commessa, 
	CASE WHEN charindex('.', vidr.V1CC_COMMESSA) > 0 THEN 
		LTrim(RTrim(LEFT(vidr.V1CC_COMMESSA, charindex('.', vidr.V1CC_COMMESSA) - 1))) 
	ELSE 
		LTrim(RTrim(COALESCE (vidr.V1CC_COMMESSA, ''))) 
	END AS commPadre, dbo.INN_RUDT.CDS_CNT_RAGSOC,

	CASE WHEN Coalesce(
	(SELECT ratePag.IKY_TIPO_RATA FROM 
		INN_TPAGAM_ANAPAG anaPag 
		LEFT JOIN INN_TPAGAM_RATE_PAG ratePag ON (ratePag.NKY_PAG = anaPag.NKY_PAG) 
	WHERE
	  (anaPag.NKY_PAG = mmam.NKY_PAG)  and (ratePag.IKY_TIPO_RATA = 'R') and (ratePag.PRG_RATA = 1)), '') = 'R' THEN
	    Coalesce(rudtBanPref.CDS_CNT_RAGSOC, '')
	  else
	    ''
	  end as BANCA						  
					  
FROM         
	dbo.INN_MMA_M AS mmam 
    INNER JOIN dbo.INN_MMA_D AS mmad ON mmam.ID = mmad.ID 
    LEFT JOIN dbo.INN_RUDT ON mmam.CKY_CNT_CLFR = dbo.INN_RUDT.CKY_CNT 
    LEFT JOIN dbo.INN_MMA_D_VIDR AS vidr ON vidr.ID = mmad.ID 
	LEFT JOIN INN_PICO PICO on (PICO.CKY_CNT = INN_RUDT.CKY_CNT)
	LEFT JOIN INN_RUDT rudtBanPref ON (rudtBanPref.CKY_CNT = pico.CKY_CNT_BAN_PREF)
	LEFT JOIN dbo.v_rate ON mmam.NKY_PAG = dbo.v_rate.NKY_PAG
WHERE     (mmam.CSG_DOC = 'BF') AND (mmam.anno = year(getdate()) OR (mmam.anno = year(getdate() - 1)))
UNION
SELECT     
	COALESCE (LTrim(RTrim(IST_STATO_PAG)), '') AS statoPag, CSG_DOC, '1' AS CKY_SAZ_DOC, NGB_SR_DOC, NGL_DOC, CKY_CNT_CLFR, DTT_DOC AS DTT_SCAD, 
    v_scadenze_1.NKY_PAG, 
		CASE CSG_DOC WHEN 'FR' THEN 
			'acquisti' 
		WHEN 'FE' THEN 
			'vendite' 
		WHEN 'NE' THEN 
			'accrediti' 
		WHEN 'NR' THEN 
			'accrediti' 
		END AS origine, 
    0 AS PRG_RATA, CDS_PAG, IST_SCAD AS IKY_TIPO_RATA, '0' AS NGB_SCAD, 
    CASE CSG_DOC WHEN 'FR' THEN 
		- NMP_SCAD 
	WHEN 'NE' THEN - NMP_SCAD 
		ELSE NMP_SCAD 
	END AS importo_rata, DTT_SCAD AS scadenza_rata, 
    'scad' AS Tipologia, '' AS Commessa, '' AS commPadre, v_scadenze_1.CDS_CNT_RAGSOC,

	CASE WHEN PICO.IST_CNT = 'F' THEN
		CASE WHEN Coalesce(
		(SELECT 
			ratePag.IKY_TIPO_RATA 
		FROM 
			INN_TPAGAM_ANAPAG anaPag 
			LEFT JOIN INN_TPAGAM_RATE_PAG ratePag ON (ratePag.NKY_PAG = anaPag.NKY_PAG) 
		WHERE
		  (anaPag.NKY_PAG = v_scadenze_1.NKY_PAG)  and (ratePag.IKY_TIPO_RATA = 'R') and (ratePag.PRG_RATA = 1)), '') = 'R' THEN
			Coalesce(rudtBanPref.CDS_CNT_RAGSOC, '')
		  else
			''
		  end 
	  else
		CASE WHEN Coalesce(
		(SELECT 
			ratePag.IKY_TIPO_RATA 
		FROM 
			INN_TPAGAM_ANAPAG anaPag 
			LEFT JOIN INN_TPAGAM_RATE_PAG ratePag ON (ratePag.NKY_PAG = anaPag.NKY_PAG) 
		WHERE
		  (anaPag.NKY_PAG = v_scadenze_1.NKY_PAG)  and (ratePag.IKY_TIPO_RATA = 'M') and (ratePag.PRG_RATA = 1)), '') = 'M' THEN
			Coalesce(rudtBanPref.CDS_CNT_RAGSOC, '')
		  else
			''
		  end 
	  end  
	  as BANCA							  
FROM         
	dbo.v_scadenze_1
	LEFT JOIN INN_PICO PICO on (PICO.CKY_CNT = CKY_CNT_CLFR)
	LEFT JOIN INN_RUDT rudtBanPref ON (rudtBanPref.CKY_CNT = pico.CKY_CNT_BAN_PREF)	
WHERE     
	(year(dtt_movc) = year(getdate())) OR (year(dtt_movc) = year(getdate() - 1))
UNION
SELECT     
	COALESCE (LTrim(RTrim(sWflStatoPag)), '') AS statoPag, '' AS CSG_DOC, '0' AS CKY_SAZ_DOC, 0 AS NGB_SR_DOC, 0 AS NGL_DOC, sWflCodCli AS CKY_CNT_CLFR, 
    dWflData AS DTT_SCAD, 0 AS NKY_PAG, 'extracont' AS origine, iWflPRG_RATA AS PRG_RATA, '' AS CDS_PAG, '' AS IKY_TIPO_RATA, '0' AS NGB_SCAD, 
    cWflImporto AS importo_rata, dWflData AS scadenza_rata, 'extra' AS Tipologia, '' AS Commessa, '' AS commPadre, sWflCliente, '' AS BANCA
FROM         
	TWFL_WORKFLOW