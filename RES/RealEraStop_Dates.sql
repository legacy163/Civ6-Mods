--------------------------------------------------------------
-- RealEraStop_Dates
-- Author: Infixo
-- Mar 26th, 2017: Created, custom Game Speeds
--------------------------------------------------------------

INSERT INTO Types (Type,Kind)
VALUES
	('GAMESPEED_LASTERACLA', 'KIND_GAMESPEED'),
	('GAMESPEED_LASTERAMED', 'KIND_GAMESPEED'),
	('GAMESPEED_LASTERAREN', 'KIND_GAMESPEED'),
	('GAMESPEED_LASTERAIND', 'KIND_GAMESPEED'),
	('GAMESPEED_LASTERAMOD', 'KIND_GAMESPEED'),
	('GAMESPEED_LASTERAATO', 'KIND_GAMESPEED');

INSERT INTO GameSpeeds (GameSpeedType,Name,Description,CostMultiplier,CivicUnlockMaxCost,CivicUnlockPerTurnDrop,CivicUnlockMinCost)
VALUES
	('GAMESPEED_LASTERACLA', 'LOC_GAMESPEED_LASTERACLA_NAME', 'LOC_GAMESPEED_LASTERACLA_HELP', 100, 100, 10, 20),
	('GAMESPEED_LASTERAMED', 'LOC_GAMESPEED_LASTERAMED_NAME', 'LOC_GAMESPEED_LASTERAMED_HELP', 100, 100, 10, 20),
	('GAMESPEED_LASTERAREN', 'LOC_GAMESPEED_LASTERAREN_NAME', 'LOC_GAMESPEED_LASTERAREN_HELP', 100, 100, 10, 20),
	('GAMESPEED_LASTERAIND', 'LOC_GAMESPEED_LASTERAIND_NAME', 'LOC_GAMESPEED_LASTERAIND_HELP', 100, 100, 10, 20),
	('GAMESPEED_LASTERAMOD', 'LOC_GAMESPEED_LASTERAMOD_NAME', 'LOC_GAMESPEED_LASTERAMOD_HELP', 100, 100, 10, 20),
	('GAMESPEED_LASTERAATO', 'LOC_GAMESPEED_LASTERAATO_NAME', 'LOC_GAMESPEED_LASTERAATO_HELP', 100, 100, 10, 20);

INSERT INTO GameSpeed_Turns (GameSpeedType,MonthIncrement,TurnsPerIncrement)
VALUES
('GAMESPEED_LASTERACLA', 120, 300),
('GAMESPEED_LASTERACLA',  96, 200),
('GAMESPEED_LASTERAMED', 180, 200),
('GAMESPEED_LASTERAMED', 120, 150),
('GAMESPEED_LASTERAMED',  72, 150),
('GAMESPEED_LASTERAREN', 240, 150),
('GAMESPEED_LASTERAREN', 144, 125),
('GAMESPEED_LASTERAREN', 108,  95),
('GAMESPEED_LASTERAREN',  36, 130),
('GAMESPEED_LASTERAIND', 300, 120),
('GAMESPEED_LASTERAIND', 180, 100),
('GAMESPEED_LASTERAIND', 120,  80),
('GAMESPEED_LASTERAIND',  48, 100),
('GAMESPEED_LASTERAIND',  24, 100),
('GAMESPEED_LASTERAMOD', 360, 100),
('GAMESPEED_LASTERAMOD', 240,  80),
('GAMESPEED_LASTERAMOD', 120,  75),
('GAMESPEED_LASTERAMOD',  60,  80),
('GAMESPEED_LASTERAMOD',  24,  75),
('GAMESPEED_LASTERAMOD',   6,  90),
('GAMESPEED_LASTERAATO', 420,  85),
('GAMESPEED_LASTERAATO', 240,  75),
('GAMESPEED_LASTERAATO', 180,  60),
('GAMESPEED_LASTERAATO',  60,  75),
('GAMESPEED_LASTERAATO',  24,  70),
('GAMESPEED_LASTERAATO',  12,  60),
('GAMESPEED_LASTERAATO',   6,  75);