--------------------------------------------------------------
-- Real Building Upgrades
-- Author: Infixo
-- 2018-03-04: Created
-- 2018-12-15: New file format (each building is changed separately)
-- 2019-04-07: Added historic moment illustrations
--------------------------------------------------------------


--------------------------------------------------------------
-- 2019-04-06 Historic moment illustrations are the same as for base buildings
-- This must be executed at the end, so all upgrades will register their traits in Buildings.
--------------------------------------------------------------

INSERT INTO MomentIllustrations (MomentIllustrationType, MomentDataType, GameDataType, Texture)
SELECT 'MOMENT_ILLUSTRATION_UNIQUE_BUILDING', 'MOMENT_DATA_BUILDING', GameDataType||'_UPGRADE', Texture
FROM RBUConfig, MomentIllustrations
WHERE IsUnq = 1 AND 'BUILDING_'||BType = GameDataType
ORDER BY GameDataType;


--------------------------------------------------------------
-- 2018-12-15 Neighborhood
--------------------------------------------------------------

-- 2018-03-05 Mutually exclusive buildings (so they won't appear in production list)
INSERT INTO MutuallyExclusiveBuildings (Building, MutuallyExclusiveBuilding) VALUES
('BUILDING_FOOD_MARKET_UPGRADE', 'BUILDING_SHOPPING_MALL'),
('BUILDING_FOOD_MARKET_UPGRADE', 'BUILDING_SHOPPING_MALL_UPGRADE'),
('BUILDING_SHOPPING_MALL_UPGRADE', 'BUILDING_FOOD_MARKET'),
('BUILDING_SHOPPING_MALL_UPGRADE', 'BUILDING_FOOD_MARKET_UPGRADE');

--------------------------------------------------------------
-- FOOD_MARKET

-- Add +2 Food from Pastures and Plantations
INSERT INTO BuildingModifiers (BuildingType, ModifierId) VALUES
('BUILDING_FOOD_MARKET_UPGRADE', 'FOOD_MARKET_UPGRADE_ADD_PASTURE_FOOD'),
--('BUILDING_FOOD_MARKET_UPGRADE', 'FOOD_MARKET_UPGRADE_ADD_CAMP_FOOD'),
('BUILDING_FOOD_MARKET_UPGRADE', 'FOOD_MARKET_UPGRADE_ADD_PLANTATION_FOOD');

INSERT INTO Modifiers (ModifierId, ModifierType, RunOnce, Permanent, OwnerRequirementSetId, SubjectRequirementSetId) VALUES
('FOOD_MARKET_UPGRADE_ADD_PASTURE_FOOD',    'MODIFIER_CITY_PLOT_YIELDS_ADJUST_PLOT_YIELD', 0, 0, NULL, 'PLOT_HAS_PASTURE_REQUIREMENTS'),
--('FOOD_MARKET_UPGRADE_ADD_CAMP_FOOD',       'MODIFIER_CITY_PLOT_YIELDS_ADJUST_PLOT_YIELD', 0, 0, NULL, 'PLOT_HAS_CAMP_REQUIREMENTS'),
('FOOD_MARKET_UPGRADE_ADD_PLANTATION_FOOD', 'MODIFIER_CITY_PLOT_YIELDS_ADJUST_PLOT_YIELD', 0, 0, NULL, 'PLOT_HAS_PLANTATION_REQUIREMENTS');

INSERT INTO ModifierArguments (ModifierId, Name, Value) VALUES
('FOOD_MARKET_UPGRADE_ADD_PASTURE_FOOD', 'Amount', '2'),
('FOOD_MARKET_UPGRADE_ADD_PASTURE_FOOD', 'YieldType', 'YIELD_FOOD'),
--('FOOD_MARKET_UPGRADE_ADD_CAMP_FOOD', 'Amount', '2'),
--('FOOD_MARKET_UPGRADE_ADD_CAMP_FOOD', 'YieldType', 'YIELD_FOOD'),
('FOOD_MARKET_UPGRADE_ADD_PLANTATION_FOOD', 'Amount', '2'),
('FOOD_MARKET_UPGRADE_ADD_PLANTATION_FOOD', 'YieldType', 'YIELD_FOOD');

INSERT INTO RequirementSets (RequirementSetId, RequirementSetType)
SELECT 'PLOT_HAS_PLANTATION_REQUIREMENTS', 'REQUIREMENTSET_TEST_ALL' -- added in XP2
WHERE NOT EXISTS (SELECT 1 FROM RequirementSets WHERE RequirementSetId = 'PLOT_HAS_PLANTATION_REQUIREMENTS');
	
INSERT OR REPLACE INTO RequirementSetRequirements (RequirementSetId, RequirementId) VALUES
('PLOT_HAS_PLANTATION_REQUIREMENTS', 'REQUIRES_PLOT_HAS_PLANTATION'); -- already exists

--------------------------------------------------------------
-- SHOPPING_MALL

-- +2 Tourism, +2 Gold from Lux resources
INSERT INTO BuildingModifiers (BuildingType, ModifierId) VALUES
('BUILDING_SHOPPING_MALL_UPGRADE', 'SHOPPING_MALL_UPGRADE_TOURISM'),
('BUILDING_SHOPPING_MALL_UPGRADE', 'SHOPPING_MALL_UPGRADE_ADD_LUXURY_GOLD');

INSERT INTO Modifiers (ModifierId, ModifierType, RunOnce, Permanent, OwnerRequirementSetId, SubjectRequirementSetId) VALUES
('SHOPPING_MALL_UPGRADE_TOURISM',         'MODIFIER_PLAYER_DISTRICT_ADJUST_TOURISM_CHANGE', 0, 0, NULL, NULL),
('SHOPPING_MALL_UPGRADE_ADD_LUXURY_GOLD', 'MODIFIER_CITY_PLOT_YIELDS_ADJUST_PLOT_YIELD',    0, 0, NULL, 'PLOT_HAS_LUXURY_RESOURCE');

INSERT INTO ModifierArguments (ModifierId, Name, Value) VALUES
('SHOPPING_MALL_UPGRADE_TOURISM', 'Amount', '2'),
('SHOPPING_MALL_UPGRADE_ADD_LUXURY_GOLD', 'Amount', '2'),
('SHOPPING_MALL_UPGRADE_ADD_LUXURY_GOLD', 'YieldType', 'YIELD_GOLD');

INSERT OR REPLACE INTO RequirementSets (RequirementSetId, RequirementSetType) VALUES
('PLOT_HAS_LUXURY_RESOURCE', 'REQUIREMENTSET_TEST_ALL');

INSERT OR REPLACE INTO RequirementSetRequirements (RequirementSetId, RequirementId) VALUES
('PLOT_HAS_LUXURY_RESOURCE', 'REQUIRES_PLOT_HAS_LUXURY'); -- already exists


--------------------------------------------------------------
-- 2018-12-15 Water Park
--------------------------------------------------------------

--------------------------------------------------------------
-- FERRIS_WHEEL

-- +1 Tourism, +1 Appeal
INSERT INTO BuildingModifiers (BuildingType, ModifierId) VALUES
('BUILDING_FERRIS_WHEEL_UPGRADE', 'FERRIS_WHEEL_UPGRADE_TOURISM'),
('BUILDING_FERRIS_WHEEL_UPGRADE', 'FERRIS_WHEEL_UPGRADE_APPEAL');

INSERT INTO Modifiers (ModifierId, ModifierType, RunOnce, Permanent, OwnerRequirementSetId, SubjectRequirementSetId) VALUES
('FERRIS_WHEEL_UPGRADE_TOURISM', 'MODIFIER_PLAYER_DISTRICT_ADJUST_TOURISM_CHANGE', 0, 0, NULL, NULL),
('FERRIS_WHEEL_UPGRADE_APPEAL',  'MODIFIER_SINGLE_CITY_ADJUST_CITY_APPEAL',        1, 1, NULL, NULL);

INSERT INTO ModifierArguments (ModifierId, Name, Value) VALUES
('FERRIS_WHEEL_UPGRADE_TOURISM', 'Amount', '1'),
('FERRIS_WHEEL_UPGRADE_APPEAL',  'Amount', '1');

--------------------------------------------------------------
-- AQUARIUM

-- +1 Amenity, Range=9
UPDATE Buildings
SET Entertainment = 1, RegionalRange = 9
WHERE BuildingType = 'BUILDING_AQUARIUM_UPGRADE';

-- +1 GSP
INSERT INTO Building_GreatPersonPoints (BuildingType, GreatPersonClassType, PointsPerTurn) VALUES
('BUILDING_AQUARIUM_UPGRADE', 'GREAT_PERSON_CLASS_SCIENTIST', 1);

--------------------------------------------------------------
-- AQUATICS_CENTER

-- +1 Amenity, Range=9
UPDATE Buildings
SET Entertainment = 1, RegionalRange = 9
WHERE BuildingType = 'BUILDING_AQUATICS_CENTER_UPGRADE';

-- +10% to all Tourism
INSERT INTO BuildingModifiers (BuildingType, ModifierId) VALUES
('BUILDING_AQUATICS_CENTER_UPGRADE', 'AQUATICS_CENTER_UPGRADE_BOOST_ALL_TOURISM');

INSERT INTO Modifiers (ModifierId, ModifierType, RunOnce, Permanent, OwnerRequirementSetId, SubjectRequirementSetId) VALUES
('AQUATICS_CENTER_UPGRADE_BOOST_ALL_TOURISM', 'MODIFIER_PLAYER_ADJUST_TOURISM', 0, 0, NULL, NULL);

INSERT INTO ModifierArguments (ModifierId, Name, Value) VALUES
('AQUATICS_CENTER_UPGRADE_BOOST_ALL_TOURISM', 'Amount', '10');


--------------------------------------------------------------
-- 2018-03-27 Changes to upgrades of Vanilla buildings made possible in R&F
--------------------------------------------------------------

INSERT OR REPLACE INTO Types (Type, Kind) VALUES  -- hash value generated automatically
('MODIFIER_SINGLE_CITY_ADJUST_CITY_YIELD_PER_POPULATION', 'KIND_MODIFIER');

INSERT OR REPLACE INTO DynamicModifiers (ModifierType, CollectionType, EffectType) VALUES
('MODIFIER_SINGLE_CITY_ADJUST_CITY_YIELD_PER_POPULATION', 'COLLECTION_OWNER', 'EFFECT_ADJUST_CITY_YIELD_PER_POPULATION');


--------------------------------------------------------------
-- 2018-03-26 Theater Square
--------------------------------------------------------------

-- important change here! you get back these per pop yields from upgrades!
UPDATE GlobalParameters SET Value = '20' WHERE Name = 'CULTURE_PERCENTAGE_YIELD_PER_POP'; -- default is 30

-------------------------------------------------------------
-- AMPHITHEATER

-- +0.2 Culture per population
INSERT INTO BuildingModifiers (BuildingType, ModifierId) VALUES
('BUILDING_AMPHITHEATER_UPGRADE', 'AMPHITHEATER_UPGRADE_ADJUST_CULTURE_PER_POP');

INSERT INTO Modifiers (ModifierId, ModifierType, RunOnce, Permanent, OwnerRequirementSetId, SubjectRequirementSetId) VALUES
('AMPHITHEATER_UPGRADE_ADJUST_CULTURE_PER_POP', 'MODIFIER_SINGLE_CITY_ADJUST_CITY_YIELD_PER_POPULATION', 0, 0, NULL, NULL);

INSERT INTO ModifierArguments (ModifierId, Name, Value) VALUES
('AMPHITHEATER_UPGRADE_ADJUST_CULTURE_PER_POP', 'YieldType', 'YIELD_CULTURE'),
('AMPHITHEATER_UPGRADE_ADJUST_CULTURE_PER_POP', 'Amount',    '0.2');


--------------------------------------------------------------
-- 2018-03-26 Campus
--------------------------------------------------------------

-- important change here! you get back these per pop yields from upgrades!
UPDATE GlobalParameters SET Value = '30' WHERE Name = 'SCIENCE_PERCENTAGE_YIELD_PER_POP'; -- default 50

--------------------------------------------------------------
-- LIBRARY
-- +0.2 Science per population

INSERT INTO BuildingModifiers (BuildingType, ModifierId) VALUES
('BUILDING_LIBRARY_UPGRADE', 'LIBRARY_UPGRADE_ADJUST_SCIENCE_PER_POP');

INSERT INTO Modifiers (ModifierId, ModifierType, RunOnce, Permanent, OwnerRequirementSetId, SubjectRequirementSetId) VALUES
('LIBRARY_UPGRADE_ADJUST_SCIENCE_PER_POP', 'MODIFIER_SINGLE_CITY_ADJUST_CITY_YIELD_PER_POPULATION', 0, 0, NULL, NULL);

INSERT INTO ModifierArguments (ModifierId, Name, Value) VALUES
('LIBRARY_UPGRADE_ADJUST_SCIENCE_PER_POP', 'YieldType', 'YIELD_SCIENCE'),
('LIBRARY_UPGRADE_ADJUST_SCIENCE_PER_POP', 'Amount',    '0.2');

--------------------------------------------------------------
-- UNIVERSITY
-- +0.2 Science per population

INSERT INTO BuildingModifiers (BuildingType, ModifierId) VALUES
('BUILDING_UNIVERSITY_UPGRADE', 'UNIVERSITY_UPGRADE_ADJUST_SCIENCE_PER_POP');

INSERT INTO Modifiers (ModifierId, ModifierType, RunOnce, Permanent, OwnerRequirementSetId, SubjectRequirementSetId) VALUES
('UNIVERSITY_UPGRADE_ADJUST_SCIENCE_PER_POP', 'MODIFIER_SINGLE_CITY_ADJUST_CITY_YIELD_PER_POPULATION', 0, 0, NULL, NULL);

INSERT INTO ModifierArguments (ModifierId, Name, Value) VALUES
('UNIVERSITY_UPGRADE_ADJUST_SCIENCE_PER_POP', 'YieldType', 'YIELD_SCIENCE'),
('UNIVERSITY_UPGRADE_ADJUST_SCIENCE_PER_POP', 'Amount',    '0.2');

--------------------------------------------------------------
-- MADRASA
-- +0.3 Science per population

INSERT INTO BuildingModifiers (BuildingType, ModifierId) VALUES
('BUILDING_MADRASA_UPGRADE', 'MADRASA_UPGRADE_ADJUST_SCIENCE_PER_POP');

INSERT INTO Modifiers (ModifierId, ModifierType, RunOnce, Permanent, OwnerRequirementSetId, SubjectRequirementSetId) VALUES
('MADRASA_UPGRADE_ADJUST_SCIENCE_PER_POP', 'MODIFIER_SINGLE_CITY_ADJUST_CITY_YIELD_PER_POPULATION', 0, 0, NULL, NULL);

INSERT INTO ModifierArguments (ModifierId, Name, Value) VALUES
('MADRASA_UPGRADE_ADJUST_SCIENCE_PER_POP', 'YieldType', 'YIELD_SCIENCE'),
('MADRASA_UPGRADE_ADJUST_SCIENCE_PER_POP', 'Amount',    '0.3');


-------------------------------------------------------------
-- PALACE
-- +1 Loyalty

INSERT INTO BuildingModifiers (BuildingType, ModifierId) VALUES
('BUILDING_PALACE_UPGRADE', 'PALACE_UPGRADE_LOYALTY');

INSERT INTO Modifiers (ModifierId, ModifierType, RunOnce, Permanent, OwnerRequirementSetId, SubjectRequirementSetId) VALUES
('PALACE_UPGRADE_LOYALTY', 'MODIFIER_SINGLE_CITY_ADJUST_IDENTITY_PER_TURN', 0, 0, NULL, NULL);

INSERT INTO ModifierArguments (ModifierId, Name, Value) VALUES
('PALACE_UPGRADE_LOYALTY', 'Amount', '1');


--------------------------------------------------------------
-- 2018-12-15 LIGHTHOUSE
-- Add +1 Food from IMPROVEMENT_FISHERY

INSERT INTO BuildingModifiers (BuildingType, ModifierId) VALUES
('BUILDING_LIGHTHOUSE_UPGRADE', 'LIGHTHOUSE_UPGRADE_ADD_FISHERY_FOOD');

INSERT INTO Modifiers (ModifierId, ModifierType, RunOnce, Permanent, OwnerRequirementSetId, SubjectRequirementSetId) VALUES
('LIGHTHOUSE_UPGRADE_ADD_FISHERY_FOOD', 'MODIFIER_CITY_PLOT_YIELDS_ADJUST_PLOT_YIELD', 0, 0, NULL, 'PLOT_HAS_FISHERY_REQUIREMENTS');

INSERT INTO ModifierArguments (ModifierId, Name, Value) VALUES
('LIGHTHOUSE_UPGRADE_ADD_FISHERY_FOOD', 'YieldType', 'YIELD_FOOD'),
('LIGHTHOUSE_UPGRADE_ADD_FISHERY_FOOD', 'Amount',    '1');

INSERT OR REPLACE INTO RequirementSets (RequirementSetId, RequirementSetType) VALUES
('PLOT_HAS_FISHERY_REQUIREMENTS', 'REQUIREMENTSET_TEST_ALL');
	
INSERT OR REPLACE INTO RequirementSetRequirements (RequirementSetId, RequirementId) VALUES
('PLOT_HAS_FISHERY_REQUIREMENTS', 'REQUIRES_PLOT_HAS_FISHERY');

INSERT OR REPLACE INTO Requirements (RequirementId, RequirementType) VALUES
('REQUIRES_PLOT_HAS_FISHERY', 'REQUIREMENT_PLOT_IMPROVEMENT_TYPE_MATCHES');
	
INSERT OR REPLACE INTO RequirementArguments (RequirementId, Name, Value) VALUES
('REQUIRES_PLOT_HAS_FISHERY', 'ImprovementType', 'IMPROVEMENT_FISHERY');


--------------------------------------------------------------
-- 2018-12-15 SEAPORT
-- Add +1 Gold from IMPROVEMENT_FISHERY

INSERT INTO BuildingModifiers (BuildingType, ModifierId) VALUES
('BUILDING_SEAPORT_UPGRADE', 'SEAPORT_UPGRADE_ADD_FISHERY_GOLD');

INSERT INTO Modifiers (ModifierId, ModifierType, RunOnce, Permanent, OwnerRequirementSetId, SubjectRequirementSetId) VALUES
('SEAPORT_UPGRADE_ADD_FISHERY_GOLD',       'MODIFIER_CITY_PLOT_YIELDS_ADJUST_PLOT_YIELD', 0, 0, NULL, 'PLOT_HAS_FISHERY_REQUIREMENTS');

INSERT INTO ModifierArguments (ModifierId, Name, Value) VALUES
('SEAPORT_UPGRADE_ADD_FISHERY_GOLD', 'YieldType', 'YIELD_GOLD'),
('SEAPORT_UPGRADE_ADD_FISHERY_GOLD', 'Amount',    '1');
