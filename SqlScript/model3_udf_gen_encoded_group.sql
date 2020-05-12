DELIMITER $$
DROP FUNCTION IF EXISTS model3_udf_gen_encoded_group$$
CREATE FUNCTION model3_udf_gen_encoded_group(inputId VARCHAR(20),timeMin INT(10)) RETURNS INT(6)
BEGIN
	DECLARE sameEncodedGroup INT(4);
	DECLARE maxGroup INT DEFAULT 20;
	DECLARE curAuthcode VARCHAR(50);
	DECLARE prv_act_dt TIMESTAMP;
	DECLARE prv_group INT;
	DECLARE prv_max_group INT;
	DECLARE time_diff INT;
	DECLARE cur_ip_addr VARCHAR(50);
	
	CREATE TEMPORARY TABLE IF NOT EXISTS temptb_model3_encoded_group(
											 CURRUNT_CID INT,
											 id INT,
											 ACT_DT TIMESTAMP,
											 IP_ADDR VARCHAR(255),
											 GROUP_SIMILAR_GROUP_60MIN INT,
											 PRIMARY KEY (CURRUNT_CID,id),
											 INDEX (ACT_DT)
										  );
	/*===========================================================================*/
	
	SET curAuthcode = (SELECT eg.AUTH_CODE_CDE FROM model_building.model3_encoded_group AS eg WHERE eg.id = inputId);
	
	INSERT INTO temptb_model3_encoded_group(CURRUNT_CID,id,ACT_DT,IP_ADDR,GROUP_SIMILAR_GROUP_60MIN)
	SELECT inputId,eg.id,eg.ACT_DT,eg.IP_ADDR,eg.GROUP_SIMILAR_GROUP_60MIN
	FROM model_building.model3_encoded_group AS eg 
	WHERE eg.id = inputId 
    AND eg.AUTH_CODE_CDE = curAuthcode;
	
	INSERT INTO temptb_model3_encoded_group(CURRUNT_CID,id,ACT_DT,IP_ADDR,GROUP_SIMILAR_GROUP_60MIN)
	SELECT inputId,eg.id,eg.ACT_DT,eg.IP_ADDR,eg.GROUP_SIMILAR_GROUP_60MIN
	FROM model_building.model3_encoded_group AS eg 
	WHERE eg.id < inputId 
    AND eg.AUTH_CODE_CDE = curAuthcode
	AND eg.GROUP_SIMILAR_GROUP_60MIN IS NOT NULL
	ORDER BY eg.ACT_DT ASC;
	/*====RETURN===================================================================*/
	IF (
		SELECT COUNT(*) 
		FROM temptb_model3_encoded_group AS tmeg 
		WHERE tmeg.CURRUNT_CID = inputId
		) <= 1
	THEN DELETE FROM temptb_model3_encoded_group
		 WHERE CURRUNT_CID = inputId;
	     RETURN 0;
	END IF;
	/*===========================================================================*/
	
	SET cur_ip_addr = (SELECT tmeg.IP_ADDR 
						FROM temptb_model3_encoded_group AS tmeg 
						WHERE tmeg.id = inputId
						AND tmeg.CURRUNT_CID = inputId
					   );
	SET prv_act_dt = (SELECT tmeg.ACT_DT
					   FROM temptb_model3_encoded_group AS tmeg
					   WHERE tmeg.id < inputId 
					   AND tmeg.CURRUNT_CID = inputId
					   ORDER BY tmeg.ACT_DT DESC
					   LIMIT 1
					   );
	SET prv_group = (SELECT tmeg.GROUP_SIMILAR_GROUP_60MIN
				     FROM temptb_model3_encoded_group AS tmeg
				     WHERE tmeg.id < inputId 
				     AND tmeg.CURRUNT_CID = inputId
					 ORDER BY tmeg.ACT_DT DESC
					 LIMIT 1
					);
	SET prv_max_group = (SELECT MAX(tmeg.GROUP_SIMILAR_GROUP_60MIN)
						  FROM temptb_model3_encoded_group AS tmeg
						  WHERE tmeg.id < inputId 
						  AND tmeg.CURRUNT_CID = inputId
						);

	SET time_diff = (SELECT TIMESTAMPDIFF(MINUTE , prv_act_dt , tmeg.ACT_DT) 
				      FROM temptb_model3_encoded_group AS tmeg 
				      WHERE tmeg.id = inputId
					  AND tmeg.CURRUNT_CID = inputId
					 );
	
	SET sameEncodedGroup = (SELECT tmeg.GROUP_SIMILAR_GROUP_60MIN
							FROM temptb_model3_encoded_group AS tmeg
							WHERE tmeg.IP_ADDR = cur_ip_addr
							AND tmeg.CURRUNT_CID = inputId
							ORDER BY tmeg.ACT_DT ASC
							LIMIT 1
						   );
						   
	DELETE FROM temptb_model3_encoded_group
	WHERE CURRUNT_CID = inputId;
	
/*====RETURN===================================================================*/	
	IF time_diff > timeMin 
	THEN #IF sameEncodedGroup IS NOT NULL
	     IF sameEncodedGroup != -1
	     THEN RETURN sameEncodedGroup;
		 ELSEIF prv_max_group = maxGroup
		 THEN RETURN maxGroup;
		 ELSE RETURN (prv_max_group + 1);
		 END IF;
	ELSEIF time_diff <= timeMin 
	THEN #IF sameEncodedGroup IS NOT NULL
	     IF sameEncodedGroup != -1
		 THEN RETURN (SELECT LEAST(sameEncodedGroup,prv_group,prv_max_group));
		 ELSE RETURN (SELECT LEAST(prv_group,prv_max_group));
		 END IF;
	ELSE RETURN -1;
	END IF;
/*===========================================================================*/

	
END;$$
DELIMITER ;