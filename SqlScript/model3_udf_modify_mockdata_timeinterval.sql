DELIMITER $$
DROP FUNCTION IF EXISTS model3_udf_modify_mockdata_timeinterval$$
CREATE FUNCTION model3_udf_modify_mockdata_timeinterval(consumerInqRecId VARCHAR(20),authCode VARCHAR(20)) RETURNS VARCHAR(50)
BEGIN
	/*
	此func.可把假資料的時間修改成與前後資料的時間區間大於60min的狀態
	*/
	DECLARE curr_act_date VARCHAR(50);
	DECLARE prv_act_dt VARCHAR(50);
	DECLARE next_act_dt VARCHAR(50);
	DECLARE prv_t_inv INT;
	DECLARE next_t_inv INT;
	DECLARE k INT;
	/*===========================================================================*/
	SET k = 0;
	WHILE TRUE
	DO 	SET curr_act_date = (SELECT (r.ACT_DT + INTERVAL k MINUTE)
							 FROM model_building.real_data_rec AS r
							 WHERE r.CONSUMER_INQ_REC_ID = consumerInqRecId
							);
		SET prv_act_dt = (SELECT r.ACT_DT
						   FROM model_building.real_data_rec AS r
						   WHERE r.ACT_DT <= curr_act_date
						   AND r.AUTH_CODE_CDE = authCode
						   AND r.CONSUMER_INQ_REC_ID != consumerInqRecId
						   AND r.SYS_DETEM_VAL != ''
						   ORDER BY r.ACT_DT DESC
						   LIMIT 1
						   );
		SET next_act_dt = (SELECT r.ACT_DT
						   FROM model_building.real_data_rec AS r
						   WHERE r.ACT_DT >= curr_act_date
						   AND r.AUTH_CODE_CDE = authCode
						   AND r.CONSUMER_INQ_REC_ID != consumerInqRecId
						   AND r.SYS_DETEM_VAL != ''
						   ORDER BY r.ACT_DT ASC
						   LIMIT 1
							);
		SET prv_t_inv = (SELECT TIMESTAMPDIFF(MINUTE,prv_act_dt,curr_act_date));
		SET next_t_inv = (SELECT TIMESTAMPDIFF(MINUTE,curr_act_date,next_act_dt));
		
		IF (prv_t_inv > 60 AND next_t_inv > 60)
		THEN RETURN curr_act_date;
		ELSEIF prv_t_inv IS NULL
		THEN RETURN (SELECT curr_act_date - INTERVAL k MINUTE);
		ELSEIF next_t_inv IS NULL
		THEN RETURN (SELECT curr_act_date + INTERVAL k MINUTE);
		ELSE SET k = k + 60;
		END IF;
	END WHILE;
	RETURN "ERROR";
END;$$
DELIMITER ;