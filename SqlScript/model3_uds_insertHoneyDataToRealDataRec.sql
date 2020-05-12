DELIMITER $$
DROP PROCEDURE IF EXISTS model3_uds_insertHoneyDataToRealDataRec$$
CREATE PROCEDURE model3_uds_insertHoneyDataToRealDataRec(dayIntv INT(5))
BEGIN
	DROP TEMPORARY TABLE IF EXISTS specified_cir_table;
	CREATE TEMPORARY TABLE specified_cir_table(
								 ID INT,
								 PRIMARY KEY (ID)
							  );
	INSERT INTO specified_cir_table(ID) 
	VALUES('719087');
/*	SELECT c.ID
	FROM model_building.model3_honeymoon_authcode_rec AS m
	JOIN tsecurityrds02.consumer_inq_rec AS c ON c.AUTH_CODE_CDE = m.AUTH_CODE_CDE
	WHERE m.QUERY_NUM_30DAYS <= 8
	AND m.AUTH_CODE_CDE NOT IN (SELECT r.AUTH_CODE_CDE FROM model_building.real_data_rec as r GROUP BY r.AUTH_CODE_CDE)
	GROUP BY c.AUTH_CODE_CDE;
*/
  BEGIN
    DECLARE v_finished INTEGER DEFAULT 0;
	DECLARE v_cir varchar(25) DEFAULT "";
	DECLARE startDate varchar(50) DEFAULT "2016-01-01";
	DECLARE specified_cir_table_cursor CURSOR FOR SELECT ID FROM specified_cir_table;
	DECLARE CONTINUE HANDLER FOR NOT FOUND SET v_finished = 1;
	
	OPEN specified_cir_table_cursor;
insertIntoRealData: WHILE TRUE
					DO FETCH specified_cir_table_cursor INTO v_cir;
					   IF v_finished = 1
					   THEN LEAVE insertIntoRealData;
					   END IF;
					   
					   CALL model_building.model3_uds_insert_real_extended_data(v_cir,startDate,NOW());
					END WHILE insertIntoRealData;
	CLOSE specified_cir_table_cursor;
	
	DELETE FROM model_building.real_data_rec
	WHERE CHECK_STATE = 'D'
	AND (SYS_DETEM ='E' OR SYS_DETEM_VAL ='')
	AND ID IN(SELECT c.ID 
								FROM model_building.model3_honeymoon_authcode_rec AS h
								JOIN tsecurityrds02.consumer_inq_rec AS c ON c.AUTH_CODE_CDE = h.AUTH_CODE_CDE
								WHERE DATEDIFF(c.ACT_DT,h.SEND_DT) > dayIntv);
										
	UPDATE model_building.real_data_rec 
	SET REAL_DETEM = 'T' 
	WHERE CHECK_STATE = 'D';
  END;
  DROP TEMPORARY TABLE IF EXISTS specified_cir_table;
END;$$
DELIMITER ;