--------------------------------------------------------------
-- RealEurekas - Gathering Storm changes
-- Author: Infixo
-- 2019-02-20: Created
-- 2019-03-18: New boosts for GS
--------------------------------------------------------------

UPDATE Boosts SET Boost = 90 WHERE CivicType = 'CIVIC_NEAR_FUTURE_GOVERNANCE'; -- Boost=90??? Bug?


--------------------------------------------------------------
-- TABLE REurBoostDefs
--------------------------------------------------------------
INSERT INTO REurBoostDefs (BoostTypeID,BClass,TDesc,U1Type,BType,IType,BTType,RType,NItems,NItems2,FType,DType,RRes,BCType,GovTier,Hlpr)
VALUES  -- below part is generated from Excel - should not be changed manually - change 'hash' into NULL!
(105,'ARTIFACT_EXTRACTED','ARTIFACT_EXTRACTED_RF',NULL,NULL,NULL,NULL,NULL,0,0,NULL,NULL,0,NULL,NULL,NULL),
(152,'CONSTRUCT_BUILDING','CONSTRUCT_BUILDING_FLOOD_BARRIER',NULL,'FLOOD_BARRIER',NULL,NULL,NULL,0,0,NULL,NULL,0,NULL,NULL,NULL),
(225,'HAVE_GOVERNMENT_TIER','HAVE_GOV_TIER1',NULL,NULL,NULL,NULL,NULL,0,0,NULL,NULL,0,NULL,'Tier1',NULL),
(226,'HAVE_GOVERNMENT_TIER','HAVE_GOV_TIER2',NULL,NULL,NULL,NULL,NULL,0,0,NULL,NULL,0,NULL,'Tier2',NULL),
(227,'HAVE_GOVERNMENT_TIER','HAVE_GOV_TIER3',NULL,NULL,NULL,NULL,NULL,0,0,NULL,NULL,0,NULL,'Tier3',NULL),
(228,'HAVE_GOVERNMENT_TIER','HAVE_GOV_TIER4',NULL,NULL,NULL,NULL,NULL,0,0,NULL,NULL,0,NULL,'Tier4',NULL),
(263,'HAVE_X_IMPROVEMENTS','HAVE_X_IMPR_GEOPLANT_1_LS',NULL,NULL,'GEOTHERMAL_PLANT',NULL,NULL,1,0,NULL,NULL,0,NULL,NULL,NULL),
(264,'HAVE_X_IMPROVEMENTS','HAVE_X_IMPR_GEOPLANT_1_CO',NULL,NULL,'GEOTHERMAL_PLANT',NULL,NULL,1,0,NULL,NULL,0,NULL,NULL,NULL),
(288,'HAVE_X_IMPROVEMENTS','HAVE_X_IMPR_SKI_RESORT_2',NULL,NULL,'SKI_RESORT',NULL,NULL,2,0,NULL,NULL,1,NULL,NULL,NULL),
(289,'HAVE_X_IMPROVEMENTS','HAVE_X_IMPR_SKI_RESORT_3',NULL,NULL,'SKI_RESORT',NULL,NULL,3,0,NULL,NULL,1,NULL,NULL,NULL),
(290,'HAVE_X_IMPROVEMENTS','HAVE_X_IMPR_SOLAR_FARM_2',NULL,NULL,'SOLAR_FARM',NULL,NULL,2,0,NULL,NULL,1,NULL,NULL,NULL),
(291,'HAVE_X_IMPROVEMENTS','HAVE_X_IMPR_WIND_FARM_2',NULL,NULL,'WIND_FARM',NULL,NULL,2,0,NULL,NULL,1,NULL,NULL,NULL),
(306,'HAVE_X_BUILDINGS','HAVEXB_COAL_POWER_PLANT_2',NULL,'COAL_POWER_PLANT',NULL,NULL,NULL,2,0,NULL,NULL,0,NULL,NULL,NULL),
(311,'HAVE_X_BUILDINGS','HAVEXB_OIL_PP_1',NULL,'FOSSIL_FUEL_POWER_PLANT',NULL,NULL,NULL,1,0,NULL,NULL,0,NULL,NULL,NULL),
(312,'HAVE_X_BUILDINGS','HAVEXB_OIL_PP_2',NULL,'FOSSIL_FUEL_POWER_PLANT',NULL,NULL,NULL,2,0,NULL,NULL,0,NULL,NULL,NULL),
(313,'HAVE_X_BUILDINGS','HAVEXB_HYDROELECTRIC_DAM_1',NULL,'HYDROELECTRIC_DAM',NULL,NULL,NULL,1,0,NULL,NULL,0,NULL,NULL,NULL),
(314,'HAVE_X_BUILDINGS','HAVEXB_HYDROELECTRIC_DAM_2',NULL,'HYDROELECTRIC_DAM',NULL,NULL,NULL,2,0,NULL,NULL,0,NULL,NULL,NULL),
(325,'HAVE_X_BUILDINGS','HAVEXB_POWER_PLANT_1',NULL,'POWER_PLANT',NULL,NULL,NULL,1,0,NULL,NULL,0,NULL,NULL,NULL),
(327,'HAVE_X_BUILDINGS','HAVEXB_POWER_PLANT_3',NULL,'POWER_PLANT',NULL,NULL,NULL,3,0,NULL,NULL,0,NULL,NULL,NULL),
(350,'HAVE_X_BUILDINGS','HAVEXB_WATER_MILL_2',NULL,'WATER_MILL',NULL,NULL,NULL,2,0,NULL,NULL,0,NULL,NULL,NULL),
(351,'HAVE_X_BUILDINGS','HAVEXB_WATER_MILL_3',NULL,'WATER_MILL',NULL,NULL,NULL,3,0,NULL,NULL,0,NULL,NULL,NULL),
(359,'HAVE_X_DISTRICTS','HAVEXD_CANAL_1',NULL,NULL,NULL,NULL,NULL,1,0,NULL,'CANAL',0,NULL,NULL,NULL),
(366,'HAVE_X_DISTRICTS','HAVEXD_DAM_1',NULL,NULL,NULL,NULL,NULL,1,0,NULL,'DAM',0,NULL,NULL,NULL),
(367,'HAVE_X_DISTRICTS','HAVEXD_DAM_2',NULL,NULL,NULL,NULL,NULL,2,0,NULL,'DAM',0,NULL,NULL,NULL),
(518,'OWN_X_UNITS_OF_TYPE','OWNXU_COURSER_2','COURSER',NULL,NULL,NULL,NULL,2,0,NULL,NULL,0,NULL,NULL,NULL),
(521,'OWN_X_UNITS_OF_TYPE','OWNXU_CUIRASSIER_2','CUIRASSIER',NULL,NULL,NULL,NULL,2,0,NULL,NULL,0,NULL,NULL,NULL),
(522,'OWN_X_UNITS_OF_TYPE','OWNXU_CUIRASSIER_3','CUIRASSIER',NULL,NULL,NULL,NULL,3,0,NULL,NULL,0,NULL,NULL,NULL),
(527,'OWN_X_UNITS_OF_TYPE','OWNXU_GDR_1','GIANT_DEATH_ROBOT',NULL,NULL,NULL,NULL,1,0,NULL,NULL,0,NULL,NULL,NULL),
(539,'OWN_X_UNITS_OF_TYPE','OWNXU_SKIRMISHER_1','SKIRMISHER',NULL,NULL,NULL,NULL,1,0,NULL,NULL,0,NULL,NULL,NULL),
(540,'OWN_X_UNITS_OF_TYPE','OWNXU_SKIRMISHER_2','SKIRMISHER',NULL,NULL,NULL,NULL,2,0,NULL,NULL,0,NULL,NULL,NULL),
(547,'TURN_NUMBER','PILLAGE_WITH_COURSER','COURSER',NULL,NULL,NULL,NULL,14500,0,NULL,NULL,0,NULL,NULL,NULL),
(588,'TURN_NUMBER','SETTLE_CAPITAL_RIVER',NULL,NULL,NULL,NULL,NULL,13800,0,NULL,NULL,0,NULL,NULL,NULL),
(625,'TURN_NUMBER','UNIT_LEVEL_ROCK_BAND_3','ROCK_BAND',NULL,NULL,NULL,NULL,14600,3,NULL,NULL,0,NULL,NULL,NULL),
(626,'TURN_NUMBER','UNIT_LEVEL_ROCK_BAND_4','ROCK_BAND',NULL,NULL,NULL,NULL,14600,4,NULL,NULL,0,NULL,NULL,NULL),
(629,'TRAIN_UNIT','TRAIN_UNIT_ROCK_BAND','ROCK_BAND',NULL,NULL,NULL,NULL,0,0,NULL,NULL,0,NULL,NULL,NULL),
(635,'TURN_NUMBER','TRAIN_UNIT_CUIRASSIER','CUIRASSIER',NULL,NULL,NULL,NULL,10000,0,NULL,NULL,0,NULL,NULL,NULL);


--------------------------------------------------------------
-- TABLE REurMapping
--------------------------------------------------------------
INSERT INTO REurMapping (BoostID,BoostSeq,BoostTypeID)
VALUES  -- below part is generated from Excel - should not be changed manually
(7,6,225),
(18,7,518),
(65,6,539),
(72,4,226),
(22,4,540),
(80,7,547),
(28,5,366),
(88,4,635),
(86,5,367),
(33,3,521),
(33,4,522),
(94,5,227),
(89,3,359),
(98,2,312),
(98,3,312),
(100,5,311),
(108,4,264),
(107,3,263),
(111,5,327),
(48,4,625),
(48,5,626),
(113,0,290),
(113,1,290),
(113,2,291),
(113,3,152),
(113,4,313),
(113,5,314),
(114,0,446),
(114,1,446),
(114,2,325),
(115,0,629),
(115,1,629),
(115,2,288),
(115,3,289),
(116,0,583),
(116,1,583),
(116,2,527),
(117,0,228),
(117,1,228),
(117,2,578),
(118,0,236),
(118,1,236),
(118,2,350),
(118,3,351),
(118,4,588),
(119,0,306),
(119,1,306),
(119,2,105),
(119,3,633),
(120,0,102),
(121,0,102),
(122,0,102),
(123,0,102),
(124,0,102),
(125,0,102),
(126,0,102);
