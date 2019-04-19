-- ===========================================================================
-- Better Tech Tree
-- Author: Infixo
-- 2018-12-10: Created
-- 2019-04-19: Star icons removal
-- ===========================================================================

-- just to make versioning easier
INSERT INTO GlobalParameters (Name, Value) VALUES ('BTT_VERSION_MAJOR', 1);
INSERT INTO GlobalParameters (Name, Value) VALUES ('BTT_VERSION_MINOR', 5);

-- options
INSERT INTO GlobalParameters (Name, Value) VALUES ('BTT_OPTION_HARVESTS',   1); -- set this to '0' if you want to switch OFF the harvest icons
INSERT INTO GlobalParameters (Name, Value) VALUES ('BTT_OPTION_STAR_ICONS', 0); -- set this to 1 if you want to switch ON the star icons



-- ===========================================================================
-- Remove unnecessary star icons

UPDATE Civics SET Description = NULL WHERE Description IN
('LOC_CIVIC_MILITARY_TRADITION_DESCRIPTION')
AND EXISTS (SELECT 1 FROM GlobalParameters WHERE Name = 'BTT_OPTION_STAR_ICONS' AND Value = 0);

UPDATE Technologies SET Description = NULL WHERE Description IN (
'LOC_TECH_POTTERY_DESCRIPTION',
'LOC_TECH_ANIMAL_HUSBANDRY_DESCRIPTION',
'LOC_TECH_MINING_DESCRIPTION',
'LOC_TECH_SAILING_DESCRIPTION',
'LOC_TECH_IRRIGATION_DESCRIPTION',
'LOC_TECH_MASONRY_DESCRIPTION',
'LOC_TECH_BRONZE_WORKING_DESCRIPTION',
'LOC_TECH_CELESTIAL_NAVIGATION_DESCRIPTION',
'LOC_TECH_SHIPBUILDING_DESCRIPTION',
'LOC_TECH_APPRENTICESHIP_DESCRIPTION',
'LOC_TECH_CARTOGRAPHY_DESCRIPTION'
) AND EXISTS (SELECT 1 FROM GlobalParameters WHERE Name = 'BTT_OPTION_STAR_ICONS' AND Value = 0);
