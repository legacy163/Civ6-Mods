print("Loading RealStrategy.lua from Real Strategy version "..GlobalParameters.RST_VERSION_MAJOR.."."..GlobalParameters.RST_VERSION_MINOR);
-- ===========================================================================
-- Real Strategy
-- 2018-12-14: Created by Infixo
-- ===========================================================================

-- InGame functions exposed here
if not ExposedMembers.RST then ExposedMembers.RST = {} end;
local RST = ExposedMembers.RST;

-- Rise & Fall check
--local bIsRiseFall:boolean = Modding.IsModActive("1B28771A-C749-434B-9053-D1380C553DE9"); -- Rise & Fall
--print("Rise & Fall", (bIsRiseFall and "YES" or "no"));

-- configuration options
--local bOptionHarvests:boolean = ( GlobalParameters.BTT_OPTION_HARVESTS == 1 );
--local bOptionModifiers:boolean = ( GlobalParameters.BCP_OPTION_MODIFIERS == 1 );
--local bOptionInternal:boolean = ( GlobalParameters.BCP_OPTION_INTERNAL == 1 );

local LL = Locale.Lookup;


-- ===========================================================================
-- DATA
-- ===========================================================================

local Strategies:table = {
	NONE     = 0,
	CONQUEST = 1,
	SCIENCE  = 2,  
	CULTURE  = 3, 
	RELIGION = 4,
	DIPLO    = 5, -- reserved for Gathering Storm
	DEFENCE  = 6, -- supporting
	NAVAL    = 7, -- supporting
	TRADE    = 8, -- supporting
};
--dshowtable(Strategies);

local tData:table = {}; -- a table of data sets, one for each player
local tPriorities:table = {}; -- a table of Priorities tables (flavors); constructed from DB


-- ===========================================================================
-- DEBUG ROUTINES
-- ===========================================================================

-- debug output routine
function dprint(sStr,p1,p2,p3,p4,p5,p6)
	--if true then return; end
	local sOutStr = sStr;
	if p1 ~= nil then sOutStr = sOutStr.." [1] "..tostring(p1); end
	if p2 ~= nil then sOutStr = sOutStr.." [2] "..tostring(p2); end
	if p3 ~= nil then sOutStr = sOutStr.." [3] "..tostring(p3); end
	if p4 ~= nil then sOutStr = sOutStr.." [4] "..tostring(p4); end
	if p5 ~= nil then sOutStr = sOutStr.." [5] "..tostring(p5); end
	if p6 ~= nil then sOutStr = sOutStr.." [6] "..tostring(p6); end
	print(Game.GetCurrentGameTurn(), sOutStr);
end

-- debug routine - prints a table (no recursion)
function dshowtable(tTable:table)
	if tTable == nil then print("dshowtable: table is nil"); return; end
	for k,v in pairs(tTable) do
		print(k, type(v), tostring(v));
	end
end

-- debug routine - prints a table, and tables inside recursively (up to 5 levels)
function dshowrectable(tTable:table, iLevel:number)
	local level:number = 0;
	if iLevel ~= nil then level = iLevel; end
	for k,v in pairs(tTable) do
		print(string.rep("---:",level), k, type(v), tostring(v));
		if type(v) == "table" and level < 5 then dshowrectable(v, level+1); end
	end
end

-- debug routine - prints priorities table in a compacted form (1 line, formatted)
local tShowStrat:table = {};
table.insert(tShowStrat, "CONQUEST");
table.insert(tShowStrat, "SCIENCE");
table.insert(tShowStrat, "CULTURE");
table.insert(tShowStrat, "RELIGION");
function dshowpriorities(pTable:table)
	local tOut:table = {}; table.insert(tOut, "  priorities :");
	--for strat,value in pairs(pTable) do table.insert(tOut, string.format("%s %4.1f :", strat, value)); end
	for _,strat in ipairs(tShowStrat) do table.insert(tOut, string.format("%s %4.1f :", strat, pTable[strat])); end
	print(Game.GetCurrentGameTurn(), table.concat(tOut, " "));
end


-- ===========================================================================
-- HELPFUL ENUMS
-- ===========================================================================

-- from MapEnums.lua
DirectionTypes = {
	DIRECTION_NORTHEAST = 0,
	DIRECTION_EAST 		= 1,
	DIRECTION_SOUTHEAST = 2,
	DIRECTION_SOUTHWEST = 3,
	DIRECTION_WEST		= 4,
	DIRECTION_NORTHWEST = 5,
	NUM_DIRECTION_TYPES = 6,
};

-- from MapEnums.lua
function GetGameInfoIndex(table_name, type_name) 
	local index = -1;
	local table = GameInfo[table_name];
	if(table) then
		local t = table[type_name];
		if(t) then
			index = t.Index;
		end
	end
	return index;
end

-- from MapEnums.lua, These come from the database.  Get the runtime index values.
g_TERRAIN_NONE				= -1;
g_TERRAIN_GRASS				= GetGameInfoIndex("Terrains", "TERRAIN_GRASS");
g_TERRAIN_GRASS_HILLS		= GetGameInfoIndex("Terrains", "TERRAIN_GRASS_HILLS");
g_TERRAIN_GRASS_MOUNTAIN	= GetGameInfoIndex("Terrains", "TERRAIN_GRASS_MOUNTAIN");
g_TERRAIN_PLAINS			= GetGameInfoIndex("Terrains", "TERRAIN_PLAINS");
g_TERRAIN_PLAINS_HILLS		= GetGameInfoIndex("Terrains", "TERRAIN_PLAINS_HILLS");
g_TERRAIN_PLAINS_MOUNTAIN	= GetGameInfoIndex("Terrains", "TERRAIN_PLAINS_MOUNTAIN");
g_TERRAIN_DESERT			= GetGameInfoIndex("Terrains", "TERRAIN_DESERT");
g_TERRAIN_DESERT_HILLS		= GetGameInfoIndex("Terrains", "TERRAIN_DESERT_HILLS");
g_TERRAIN_DESERT_MOUNTAIN	= GetGameInfoIndex("Terrains", "TERRAIN_DESERT_MOUNTAIN");
g_TERRAIN_TUNDRA			= GetGameInfoIndex("Terrains", "TERRAIN_TUNDRA");
g_TERRAIN_TUNDRA_HILLS		= GetGameInfoIndex("Terrains", "TERRAIN_TUNDRA_HILLS");
g_TERRAIN_TUNDRA_MOUNTAIN	= GetGameInfoIndex("Terrains", "TERRAIN_TUNDRA_MOUNTAIN");
g_TERRAIN_SNOW				= GetGameInfoIndex("Terrains", "TERRAIN_SNOW");
g_TERRAIN_SNOW_HILLS		= GetGameInfoIndex("Terrains", "TERRAIN_SNOW_HILLS");
g_TERRAIN_SNOW_MOUNTAIN		= GetGameInfoIndex("Terrains", "TERRAIN_SNOW_MOUNTAIN");
g_TERRAIN_COAST				= GetGameInfoIndex("Terrains", "TERRAIN_COAST");
g_TERRAIN_OCEAN				= GetGameInfoIndex("Terrains", "TERRAIN_OCEAN");
g_FEATURE_NONE				= -1;
g_FEATURE_FLOODPLAINS		= GetGameInfoIndex("Features", "FEATURE_FLOODPLAINS");
g_FEATURE_ICE				= GetGameInfoIndex("Features", "FEATURE_ICE");
g_FEATURE_JUNGLE			= GetGameInfoIndex("Features", "FEATURE_JUNGLE");
g_FEATURE_FOREST			= GetGameInfoIndex("Features", "FEATURE_FOREST");
g_FEATURE_OASIS				= GetGameInfoIndex("Features", "FEATURE_OASIS");
g_FEATURE_MARSH				= GetGameInfoIndex("Features", "FEATURE_MARSH");

-- new ones
--IMPROVEMENT_BARBARIAN_CAMP
--IMPROVEMENT_GOODY_HUT

-- ===========================================================================
-- TABLE FUNCTIONS AND HELPERS (INC. TABLE OF PLOT INDICES)
-- ===========================================================================

-- check if 'value' exists in table 'pTable'; should work for any type of 'value' and table indices
function IsInTable(pTable:table, value)
	for _, data in pairs(pTable) do
		if data == value then return true; end
	end
	return false;
end

-- returns 'key' at which a given 'value' is stored in table 'pTable'; nil if not found; should work for any type of 'value' and table indices
function GetTableKey(pTable:table, value)
	for key,data in pairs(pTable) do
		if data == value then return key; end
	end
	return nil;
end

-- ===========================================================================
-- PLOT FUNCTIONS AND HELPERS
-- ===========================================================================

-- table with new coors corresponding to given Direction
local tAdjCoors:table = {
	[DirectionTypes.DIRECTION_NORTHEAST] = { dx= 1, dy= 1 },  -- shifting +X, in some conditons dx=0 (rows with even Y-coor)
	[DirectionTypes.DIRECTION_EAST] 	 = { dx= 1, dy= 0 },
	[DirectionTypes.DIRECTION_SOUTHEAST] = { dx= 1, dy=-1 },  -- shifting +X, in some conditons dx=0
	[DirectionTypes.DIRECTION_SOUTHWEST] = { dx=-1, dy=-1 },  -- shifting -X, in some conditons dx=0 (rows with odd Y-coor)
	[DirectionTypes.DIRECTION_WEST]      = { dx=-1, dy= 0 },
	[DirectionTypes.DIRECTION_NORTHWEST] = { dx=-1, dy= 1 },  -- shifting -X, in some conditons dx=0
};

-- Returns coordinates (x,y) of a plot adjacent to the one tested in a specific direction
function GetAdjacentPlotXY(iX:number, iY:number, eDir:number)
	-- double-checking
	if tAdjCoors[eDir] == nil then
		print("ERROR: GetAdjacentXY() invalid direction - ", tostring(eDir));
		return iX, iY;
	end
	-- shifting X, in some conditons dx=-1 or dx=+1
	local idx = tAdjCoors[eDir].dx;
	if (eDir == DirectionTypes.DIRECTION_NORTHEAST or eDir ==  DirectionTypes.DIRECTION_SOUTHEAST) and (iY % 2 == 0) then idx = 0; end
	if (eDir == DirectionTypes.DIRECTION_NORTHWEST or eDir ==  DirectionTypes.DIRECTION_SOUTHWEST) and (iY % 2 == 1) then idx = 0; end
	-- get new coors
	local iAdjX = iX + idx;
	local iAdjY = iY + tAdjCoors[eDir].dy;
	-- wrap coordinates
	if iAdjX >= iMapWidth 	then iAdjX = 0; end
	if iAdjX < 0 			then iAdjX = iMapWidth-1; end
	if iAdjY >= iMapHeight 	then iAdjY = 0; end
	if iAdjY < 0 			then iAdjY = iMapHeight-1; end
	return iAdjX, iAdjY;
end

-- Returns Index of a plot adjacent to the one tested in a specific direction
function GetAdjacentPlotIndex(iIndex:number, eDir:number)
	local iAdjX, iAdjY = GetAdjacentPlotXY(iIndex % iMapWidth, math.floor(iIndex/iMapWidth), eDir);
	return iMapWidth * iAdjY + iAdjX;
end





-- ===========================================================================
-- BOOST DATA AND HELPERS
-- ===========================================================================

local sBoostClassCustom:string = "BOOST_TRIGGER_TURN_NUMBER";  -- the only one that doesn't crash the game

local tBoostClasses:table = {};  -- indexed using code (cc, ccc or 99999); holds some specific type data and a table of active Boosts

-- traverse through Boosts, find custom ones and initialize tBoostTypes table accordingly
function InitializeBoosts()
	dprint("FUN InitializeBoosts()");
	
	for boost in GameInfo.Boosts() do
		-- detect custom boost
		if boost.BoostClass == sBoostClassCustom and boost.NumItems > 9999 and boost.NumItems < 100000 then  -- range is all 5-digits numbers
			-- process custom boost
			dprint("Found custom boost id", boost.NumItems);
			-- find the class for code in boost.NumItems
			local sBoostClass:string = "";
			for class in GameInfo.REurBoostCodes() do
				if class.BoostCode == boost.NumItems then sBoostClass = class.BoostClass; break; end
			end
			if sBoostClass == "" then
				print("ERROR: cannot find class for boost code", boost.NumItems); return;
			end
			dprint("  ...its class is", sBoostClass);
			-- get the class object; register if nil
			local pBoostClass = tBoostClasses[sBoostClass];
			if pBoostClass == nil then
				-- first time encountered this class
				dprint("  ...registering", boost.NumItems, sBoostClass);
				pBoostClass = {};
				pBoostClass.BoostClass = sBoostClass;
				pBoostClass.BoostCode = boost.NumItems;
				pBoostClass.Boosts = {};
				tBoostClasses[sBoostClass] = pBoostClass;
			end
			-- register this specific boost
			dprint("  ...adding boost (id,numitems2,tech,civic)", boost.BoostID, boost.NumItems2, boost.TechnologyType, boost.CivicType);
			tBoostClasses[sBoostClass].Boosts[boost.BoostID] = boost;
		end  -- custom boost
	end  -- main loop
end

-- helper - get currently active player ID (yeah, it's not there...)
function GetActivePlayer()
	for _,player in ipairs(Game.GetPlayers()) do
		if player:IsTurnActive() then return player:GetID(); end
	end
	print("ERROR: no player is active");
	return -1;
end

-- helper - can this player receive a boost? must be Alive and Major
function IsPlayerBoostable(ePlayerID:number)
	local pPlayer = Players[ePlayerID];
	if pPlayer == nil then return false; end
	return pPlayer:IsAlive() and pPlayer:IsMajor();
end

-- helper - check if we need to proces a specific boost (an object from Boosts table)
function HasBoostBeenTriggered(ePlayerID:number, pBoost:table)
	dprint("FUN HasBoostBeenTriggered() (player,id,tech,civic)",ePlayerID,pBoost.BoostID,pBoost.TechnologyType,pBoost.CivicType);
	if pBoost.TechnologyType ~= nil then 
		--dprint("  ...checking (tech)", pBoost.TechnologyReference.Index);
		return Players[ePlayerID]:GetTechs():HasBoostBeenTriggered( pBoost.TechnologyReference.Index );
	end
	if pBoost.CivicType ~= nil then
		--dprint("  ...checking (civic)", pBoost.CivicReference.Index);
		return Players[ePlayerID]:GetCulture():HasBoostBeenTriggered( pBoost.CivicReference.Index );
	end
	print("ERROR: no tech nor civic attached to boost, no further processing required", pBoost.BoostID);
	return true;  -- so we we won't run any further processing
end

-- main function to actually trigger a boost
function TriggerBoost(ePlayerID:number, pBoost:table)
	dprint("FUN TriggerBoost(player,id,tech,civic)",ePlayerID,pBoost.BoostID,pBoost.TechnologyType,pBoost.CivicType);
	if pBoost.TechnologyType ~= nil then 
		dprint("  ...triggering (tech)", pBoost.TechnologyReference.Index);
		Players[ePlayerID]:GetTechs():TriggerBoost( pBoost.TechnologyReference.Index );
	end
	if pBoost.CivicType ~= nil then
		dprint("  ...triggering (civic)", pBoost.CivicReference.Index);
		Players[ePlayerID]:GetCulture():TriggerBoost( pBoost.CivicReference.Index );
	end
	dprint("  ...checking results:", HasBoostBeenTriggered(ePlayerID, pBoost));
end


-- ===========================================================================
-- BOOST CLASS FUNCTIONS
-- ===========================================================================


-- helper - returns a table of Plot objects that are owned by a given city
local iCitySettleRange:number = tonumber(GameInfo.GlobalParameters["CITY_MAX_BUY_PLOT_RANGE"].Value);
function GetCityPlots(tPlots:table, ePlayerID:number, iCityID:number)
	local pCity = Players[ePlayerID]:GetCities():FindID(iCityID);
	if pCity == nil then return; end
	local iX:number, iY:number = pCity:GetX(), pCity:GetY();
	for dx = -iCitySettleRange, iCitySettleRange, 1 do
		for dy = -iCitySettleRange, iCitySettleRange, 1 do
			local pPlot = Map.GetPlotXY(iX, iY, dx, dy);
			--dprint("  ...plot (id) owned by (owner)", pPlot:GetIndex(), pPlot:GetOwner());
			local pPlotCity = Cities.GetPlotPurchaseCity(pPlot);
			if pPlotCity ~= nil and pPlotCity:GetOwner() == ePlayerID and pPlotCity:GetID() == iCityID then
				table.insert(tPlots, pPlot);
			end
		end
	end
	dprint("FUNEND GetCityPlots() found plots", table.count(tPlots));
end

function CountCityTilesTerrain(tPlots:table, sTerrainType:string)
	dprint("FUN CountCityTilesTerrain()",sTerrainType);
	local iNum = 0;
	for _,plot in pairs(tPlots) do
		local pTerrain = GameInfo.Terrains[plot:GetTerrainType()];
		--dprint("  ...plot (id) is (terrain)", plot:GetIndex(), plot:GetTerrainType());
		if pTerrain ~= nil and string.find(pTerrain.TerrainType, sTerrainType) ~= nil then iNum = iNum + 1; end
	end
	dprint("  ...found", iNum, sTerrainType);
	return iNum;
end

function CountCityTilesFeature(tPlots:table, sFeatureType:string)
	dprint("FUN CountCityTilesFeature()",sFeatureType);
	local iNum = 0;
	for _,plot in pairs(tPlots) do
		local pFeature = GameInfo.Features[plot:GetFeatureType()];
		--dprint("  ...plot (id) is (feature)", plot:GetIndex(), plot:GetFeatureType());
		if pFeature ~= nil and pFeature.FeatureType == sFeatureType then iNum = iNum + 1; end
	end
	dprint("  ...found", iNum, sFeatureType);
	return iNum;
end


-- special additional resource visibility check is required
local tResourceVisible:table = {};
function UpdateResourceVisibility(ePlayerID:number)
	for res in GameInfo.Resources() do
		tResourceVisible[res.Index] = true;  -- most of them are visible from start
		if res.PrereqTechReference ~= nil then 
			tResourceVisible[res.Index] = Players[ePlayerID]:GetTechs():HasTech( res.PrereqTechReference.Index );
		end
		if res.PrereqCivicReference ~= nil then 
			tResourceVisible[res.Index] = Players[ePlayerID]:GetCulture():HasCivic( res.PrereqCivicReference.Index );
		end
	end
	--dprint("Resources NOT visible");
	--for res in GameInfo.Resources() do
		--if not tResourceVisible[res.Index] then dprint("  ... (type)", res.ResourceType); end
	--end
end


function CountCityTilesImprovableRes(tPlots:table, sImprovementType:string)
	dprint("FUN CountCityTilesImprovableRes()",sImprovementType);
	-- first prepare a table of valid resources (just Indices)
	local tResourceValid:table = {};
	for _,vres in pairs(GameInfo.Improvements[sImprovementType].ValidResources) do
		if tResourceVisible[vres.ResourceReference.Index] then
			tResourceValid[vres.ResourceReference.Index] = true;
		end
	end
	--dprint("Valid resources for improvement are", sImprovementType);
	--for id,_ in pairs(tResourceValid) do dprint("  ... (id,type)", id, GameInfo.Resources[id].ResourceType); end
	-- now check plots
	local iNum = 0;
	for _,plot in pairs(tPlots) do
		local pResource = GameInfo.Resources[plot:GetResourceType()];
		--dprint("  ...plot (id) is (res)", plot:GetIndex(), plot:GetResourceType());
		if pResource ~= nil and tResourceValid[pResource.Index] then iNum = iNum + 1; end
	end
	dprint("  ...found", iNum, sImprovementType);
	return iNum;
end

-- added 2018-02-13
function CountCityTilesHills(tPlots:table)
	dprint("FUN CountCityTilesHills()");
	local iNum = 0;
	for _,plot in pairs(tPlots) do
		if plot:IsHills() then iNum = iNum + 1; end
	end
	dprint("  ...found", iNum);
	return iNum;
end

-- added 2018-02-13
function CountCityTilesLake(tPlots:table)
	dprint("FUN CountCityTilesLake()");
	local iNum = 0;
	for _,plot in pairs(tPlots) do
		if plot:IsLake() then iNum = iNum + 1; end
	end
	dprint("  ...found", iNum);
	return iNum;
end

function ProcessBoostsSettledCities(sClassFix:string, ePlayerID:number, iCityID:number)
	dprint("FUN ProcessBoostsSettledCities() (fix,player,city)",sClassFix,ePlayerID,iCityID);

	-- we always have to count all plots from all cities (no matter if 1 or 2 or more)
	local tPlots = {};
	for _,city in Players[ePlayerID]:GetCities():Members() do
		dprint("Getting plots for city (id,name)", city:GetID(), city:GetName());
		GetCityPlots(tPlots, ePlayerID, city:GetID());
	end

	local tBoostClass:table = nil;
	
	-- BOOST: SETTLE_CITY1_DESERT_X, SETTLE_CITY1_SNOW_X, SETTLE_CITY1_TUNDRA_X
	local function ProcessBoostSettledCitiesTerrain(sBoostClass:string, sTerrainType:string)
		tBoostClass = tBoostClasses[sBoostClass];
		if tBoostClass == nil then return end;
		dprint("  ...processing (class,terrain)", sBoostClass, sTerrainType);
		local iNumItems:number = CountCityTilesTerrain(tPlots, sTerrainType);
		for id,boost in pairs(tBoostClass.Boosts) do
			dprint("     ...for boost (id,items2,num)", id, boost.NumItems2, iNumItems);
			if not HasBoostBeenTriggered(ePlayerID, boost) and iNumItems >= boost.NumItems2 then TriggerBoost(ePlayerID, boost); end
		end
	end
	ProcessBoostSettledCitiesTerrain("SETTLE_CITY"..sClassFix.."_DESERT_X", "TERRAIN_DESERT");
	ProcessBoostSettledCitiesTerrain("SETTLE_CITY"..sClassFix.."_SNOW_X", "TERRAIN_SNOW");
	ProcessBoostSettledCitiesTerrain("SETTLE_CITY"..sClassFix.."_TUNDRA_X", "TERRAIN_TUNDRA");
	
	-- BOOST: SETTLE_CITY1_FEATURE_X
	tBoostClass = tBoostClasses["SETTLE_CITY"..sClassFix.."_FEATURE_X"];
	if tBoostClass ~= nil then
		for id,boost in pairs(tBoostClass.Boosts) do
			dprint("  ...processing (class,feature)", "SETTLE_CITY"..sClassFix.."_FEATURE_X", boost.FeatureType);
			local iNumItems:number = CountCityTilesFeature(tPlots, boost.FeatureType);
			dprint("     ...for boost (id,items2,num)", id, boost.NumItems2, iNumItems);
			if not HasBoostBeenTriggered(ePlayerID, boost) and iNumItems >= boost.NumItems2 then TriggerBoost(ePlayerID, boost); end
		end
	end
	
	-- BOOST: SETTLE_CITY1_IMPR_X
	tBoostClass = tBoostClasses["SETTLE_CITY"..sClassFix.."_IMPR_X"];
	if tBoostClass ~= nil then 
		-- special addition - additional resource visibility check is required
		UpdateResourceVisibility(ePlayerID);
		for id,boost in pairs(tBoostClass.Boosts) do
			dprint("  ...processing (class,improv)", "SETTLE_CITY"..sClassFix.."_IMPR_X", boost.ImprovementType);
			local iNumItems:number = CountCityTilesImprovableRes(tPlots, boost.ImprovementType);
			dprint("     ...for boost (id,items2,num)", id, boost.NumItems2, iNumItems);
			if not HasBoostBeenTriggered(ePlayerID, boost) and iNumItems >= boost.NumItems2 then TriggerBoost(ePlayerID, boost); end
		end
	end
	
	-- BOOST: SETTLE_CITY1_HILLS_X, added 2018-02-13
	tBoostClass = tBoostClasses["SETTLE_CITY"..sClassFix.."_HILLS_X"];
	if tBoostClass ~= nil then 
		for id,boost in pairs(tBoostClass.Boosts) do
			dprint("  ...processing (class)", "SETTLE_CITY"..sClassFix.."_HILLS_X");
			local iNumItems:number = CountCityTilesHills(tPlots);
			dprint("     ...for boost (id,items2,num)", id, boost.NumItems2, iNumItems);
			if not HasBoostBeenTriggered(ePlayerID, boost) and iNumItems >= boost.NumItems2 then TriggerBoost(ePlayerID, boost); end
		end
	end

	-- BOOST: SETTLE_CITY1_LAKE_X, added 2018-02-13
	tBoostClass = tBoostClasses["SETTLE_CITY"..sClassFix.."_LAKE_X"];
	if tBoostClass ~= nil then 
		for id,boost in pairs(tBoostClass.Boosts) do
			dprint("  ...processing (class)", "SETTLE_CITY"..sClassFix.."_LAKE_X");
			local iNumItems:number = CountCityTilesLake(tPlots);
			dprint("     ...for boost (id,items2,num)", id, boost.NumItems2, iNumItems);
			if not HasBoostBeenTriggered(ePlayerID, boost) and iNumItems >= boost.NumItems2 then TriggerBoost(ePlayerID, boost); end
		end
	end
	
end

-- BOOST: SETTLE_CAPITAL_COAST, SETTLE_CAPITAL_LAKE, SETTLE_CAPITAL_RIVER, SETTLE_CAPITAL_MOUNTAIN, SETTLE_CAPITAL_HILLS
function ProcessBoostsCapitalLocation(ePlayerID:number, iCityID:number, iX:number, iY:number)
	dprint("FUN ProcessBoostsCapitalLocation() (player,city,x,y)",ePlayerID,iCityID,iX,iY);
	
	local pPlot = Map.GetPlot(iX, iY);
	
	-- BOOST: SETTLE_CAPITAL_COAST
	tBoostClass = tBoostClasses["SETTLE_CAPITAL_COAST"];
	if tBoostClass ~= nil then 
		for id,boost in pairs(tBoostClass.Boosts) do
			dprint("  ...processing boost (class,id,coast)", "SETTLE_CAPITAL_COAST", id, pPlot:IsCoastalLand());
			if not HasBoostBeenTriggered(ePlayerID, boost) and pPlot:IsCoastalLand() then TriggerBoost(ePlayerID, boost); end
		end
	end
	-- BOOST: SETTLE_CAPITAL_RIVER
	tBoostClass = tBoostClasses["SETTLE_CAPITAL_RIVER"];
	if tBoostClass ~= nil then 
		for id,boost in pairs(tBoostClass.Boosts) do
			dprint("  ...processing boost (class,id,coast)", "SETTLE_CAPITAL_RIVER", id, pPlot:IsRiver());
			if not HasBoostBeenTriggered(ePlayerID, boost) and pPlot:IsRiver() then TriggerBoost(ePlayerID, boost); end
		end
	end
	-- BOOST: SETTLE_CAPITAL_LAKE
	local bIsLake:boolean = false;
	for direction = 0, DirectionTypes.NUM_DIRECTION_TYPES - 1, 1 do
		if Map.GetAdjacentPlot(iX, iY, direction):IsLake() then bIsLake = true; break; end
	end
	tBoostClass = tBoostClasses["SETTLE_CAPITAL_LAKE"];
	if tBoostClass ~= nil then 
		for id,boost in pairs(tBoostClass.Boosts) do
			dprint("  ...processing boost (class,id,lake)", "SETTLE_CAPITAL_LAKE", id, bIsLake);
			if not HasBoostBeenTriggered(ePlayerID, boost) and bIsLake then TriggerBoost(ePlayerID, boost); end
		end
	end
	-- BOOST: SETTLE_CAPITAL_MOUNTAIN
	local bIsMountain:boolean = false;
	for direction = 0, DirectionTypes.NUM_DIRECTION_TYPES - 1, 1 do
		if Map.GetAdjacentPlot(iX, iY, direction):IsMountain() then bIsMountain = true; break; end
	end
	tBoostClass = tBoostClasses["SETTLE_CAPITAL_MOUNTAIN"];
	if tBoostClass ~= nil then 
		for id,boost in pairs(tBoostClass.Boosts) do
			dprint("  ...processing boost (class,id,mountain)", "SETTLE_CAPITAL_MOUNTAIN", id, bIsMountain);
			if not HasBoostBeenTriggered(ePlayerID, boost) and bIsMountain then TriggerBoost(ePlayerID, boost); end
		end
	end
	-- BOOST: SETTLE_CAPITAL_HILLS
	tBoostClass = tBoostClasses["SETTLE_CAPITAL_HILLS"];
	if tBoostClass ~= nil then
		for id,boost in pairs(tBoostClass.Boosts) do
			dprint("  ...processing boost (class,id,hills)", "SETTLE_CAPITAL_HILLS", id);
			if not HasBoostBeenTriggered(ePlayerID, boost) and pPlot:IsHills() then TriggerBoost(ePlayerID, boost); end
		end
	end
end


------------------------------------------------------------------------------
-- Helpers for checking City States
------------------------------------------------------------------------------

-- IsMinor() is not available in Gameplay context!
-- see also CivilizationLevels table
function PlayerIsMinor(ePlayerID:number)
	if PlayerConfigurations[ePlayerID] == nil then return false; end
	return PlayerConfigurations[ePlayerID]:GetCivilizationLevelTypeName() == "CIVILIZATION_LEVEL_CITY_STATE";
end

-- get City State category (cultural, industrial, etc.)
-- this is tricky - this info is in TypeProperties table attached to CIVILIZATION_ type
function GetCityStateCategory(ePlayerID:number)
	if PlayerConfigurations[ePlayerID] == nil then print("ERROR: GetCityStateCategory cannot get configuration for", ePlayerID); return "(error)"; end
	local sCivilizationType:string = PlayerConfigurations[ePlayerID]:GetCivilizationTypeName();
	for row in GameInfo.TypeProperties() do
		if row.Type == sCivilizationType and row.Name == "CityStateCategory" then return row.Value; end
	end
	print("ERROR: GetCityStateCategory cannot find category for", sCivilizationType);
	return "(error)";
end

-- check how many City States the player has met
function GetNumCityStatesPlayerHasMet(ePlayerID:number)
	if Players[ePlayerID] == nil then return 0; end
	local pPlayerDiplomacy = Players[ePlayerID]:GetDiplomacy();
	if pPlayerDiplomacy == nil then return 0; end
	local iNumHasMet:number = 0;
	for _,playerID in ipairs(PlayerManager.GetWasEverAliveIDs()) do
		if PlayerIsMinor(playerID) and pPlayerDiplomacy:HasMet(playerID) then iNumHasMet = iNumHasMet + 1; end
	end
	return iNumHasMet;
end

-- check how many City States the player is a Suzerain of
function GetNumCityStatesPlayerIsSuzerain(ePlayerID:number)
	if Players[ePlayerID] == nil then return 0; end
	local iNumSuzerain:number = 0;
	for _,pMinor in ipairs(PlayerManager.GetAliveMinors()) do
		if pMinor:GetInfluence():GetSuzerain() == ePlayerID then iNumSuzerain = iNumSuzerain + 1; end
	end
	return iNumSuzerain;
end


function ProcessBoostMeetCityState(ePlayerID:number, eMetPlayerID:number)
	dprint("FUN ProcessBoostMeetCityState", ePlayerID, eMetPlayerID);
	-- BOOST: MEET_CITY_STATE
	tBoostClass = tBoostClasses["MEET_CITY_STATE"];
	if tBoostClass ~= nil then 
		for id,boost in pairs(tBoostClass.Boosts) do
			dprint("  ...processing boost (class,id,helper,cs-cat)", "MEET_CITY_STATE", id, boost.Helper, GetCityStateCategory(eMetPlayerID));
			if not HasBoostBeenTriggered(ePlayerID, boost) and GetCityStateCategory(eMetPlayerID) == boost.Helper then TriggerBoost(ePlayerID, boost); end
		end
	end
end

function ProcessBoostMeetXCityStates(ePlayerID:number, eMetPlayerID:number)
	dprint("FUN ProcessBoostMeetXCityStates", ePlayerID, eMetPlayerID);
	-- BOOST: MEET_X_CITY_STATES
	tBoostClass = tBoostClasses["MEET_X_CITY_STATES"];
	if tBoostClass ~= nil then 
		for id,boost in pairs(tBoostClass.Boosts) do
			dprint("  ...processing boost (class,id,num2,cs-num)", "MEET_X_CITY_STATES", id, boost.NumItems2, GetNumCityStatesPlayerHasMet(ePlayerID));
			if not HasBoostBeenTriggered(ePlayerID, boost) and GetNumCityStatesPlayerHasMet(ePlayerID) >= boost.NumItems2 then TriggerBoost(ePlayerID, boost); end
		end
	end
end

function ProcessBoostSuzerainCityState(ePlayerID:number, eMinorID:number)
	dprint("FUN ProcessBoostSuzerainCityState", ePlayerID, eMinorID);
	-- BOOST: SUZERAIN_CITY_STATE
	tBoostClass = tBoostClasses["SUZERAIN_CITY_STATE"];
	if tBoostClass ~= nil then 
		for id,boost in pairs(tBoostClass.Boosts) do
			dprint("  ...processing boost (class,id,helper,cs-cat)", "SUZERAIN_CITY_STATE", id, boost.Helper, GetCityStateCategory(eMinorID));
			if not HasBoostBeenTriggered(ePlayerID, boost) and 
				GetCityStateCategory(eMinorID) == boost.Helper and Players[eMinorID]:GetInfluence():GetSuzerain() == ePlayerID then TriggerBoost(ePlayerID, boost); end
		end
	end
end

function ProcessBoostSuzerainXCityStates(ePlayerID:number, eMetPlayerID:number)
	dprint("FUN ProcessBoostSuzerainXCityStates", ePlayerID, eMetPlayerID);
	-- BOOST: SUZERAIN_X_CITY_STATES
	tBoostClass = tBoostClasses["SUZERAIN_X_CITY_STATES"];
	if tBoostClass ~= nil then 
		for id,boost in pairs(tBoostClass.Boosts) do
			dprint("  ...processing boost (class,id,num2,cs-num)", "SUZERAIN_X_CITY_STATES", id, boost.NumItems2, GetNumCityStatesPlayerIsSuzerain(ePlayerID));
			if not HasBoostBeenTriggered(ePlayerID, boost) and GetNumCityStatesPlayerIsSuzerain(ePlayerID) >= boost.NumItems2 then TriggerBoost(ePlayerID, boost); end
		end
	end
end


function ProcessBoostTrainUnit(ePlayerID:number, eUnitType:number)
	dprint("FUN ProcessBoostTrainUnit", ePlayerID, eUnitType);
	-- BOOST: TRAIN_UNIT
	tBoostClass = tBoostClasses["TRAIN_UNIT"];
	if tBoostClass ~= nil then 
		for id,boost in pairs(tBoostClass.Boosts) do
			dprint("  ...processing boost (class,id,unittype,trained)", "TRAIN_UNIT", id, boost.Unit1Type, GameInfo.Units[eUnitType].UnitType);
			if not HasBoostBeenTriggered(ePlayerID, boost) and GameInfo.Units[eUnitType].UnitType == boost.Unit1Type then TriggerBoost(ePlayerID, boost); end
		end
	end
end


function ProcessBoostGreatPerson(ePlayerID:number, eGreatPersonClass:number)
	dprint("FUN ProcessBoostGreatPerson", ePlayerID, eGreatPersonClass);
	-- BOOST: GREAT_PERSON
	tBoostClass = tBoostClasses["GREAT_PERSON"];
	if tBoostClass ~= nil then 
		for id,boost in pairs(tBoostClass.Boosts) do
			local sGPClass:string = "GREAT_PERSON_CLASS_"..boost.Helper;
			dprint("  ...processing boost (class,id,unittype,trained)", "GREAT_PERSON", id, sGPClass, GameInfo.GreatPersonClasses[eGreatPersonClass].GreatPersonClassType);
			if not HasBoostBeenTriggered(ePlayerID, boost) and GameInfo.GreatPersonClasses[eGreatPersonClass].GreatPersonClassType == sGPClass then TriggerBoost(ePlayerID, boost); end
		end
	end
end


function ProcessBoostHaveGovernment(ePlayerID:number, eGovernmentIndex:number)
	dprint("FUN ProcessBoostHaveGovernment", ePlayerID, eGovernmentIndex);
	-- BOOST: HAVE_GOVERNMENT
	tBoostClass = tBoostClasses["HAVE_GOVERNMENT"];
	if tBoostClass ~= nil then
		for id,boost in pairs(tBoostClass.Boosts) do
			local sHelperType:string = "GOVERNMENT_"..boost.Helper;
			dprint("  ...processing boost (class,id,helper,established)", "HAVE_GOVERNMENT", id, sHelperType, GameInfo.Governments[eGovernmentIndex].GovernmentType);
			if not HasBoostBeenTriggered(ePlayerID, boost) and GameInfo.Governments[eGovernmentIndex].GovernmentType == sHelperType then TriggerBoost(ePlayerID, boost); end
		end
	end
end


function ProcessBoostsProjectCompleted(ePlayerID:number, eProjectIndex:number)
	dprint("FUN ProcessBoostsProjectCompleted", ePlayerID, eProjectIndex);
	
	local projectInfo:table = GameInfo.Projects[eProjectIndex];
	if projectInfo == nil then return; end -- assert

	-- BOOST: PROJECT_COMPLETE
	tBoostClass = tBoostClasses["PROJECT_COMPLETE"];
	if tBoostClass ~= nil then
		for id,boost in pairs(tBoostClass.Boosts) do
			local sHelperType:string = "PROJECT_"..boost.Helper;
			dprint("  ...processing boost (class,id,helper,project)", "PROJECT_COMPLETE", id, sHelperType, projectInfo.ProjectType);
			if not HasBoostBeenTriggered(ePlayerID, boost) and projectInfo.ProjectType == sHelperType then TriggerBoost(ePlayerID, boost); end
		end
	end
	
	-- BOOST: PROJECT_ENHANCE
	tBoostClass = tBoostClasses["PROJECT_ENHANCE"];
	if tBoostClass ~= nil then
		for id,boost in pairs(tBoostClass.Boosts) do
			local sHelperType:string = boost.DistrictType;
			dprint("  ...processing boost (class,id,helper,district)", "PROJECT_ENHANCE", id, sHelperType, projectInfo.PrereqDistrict);
			if not HasBoostBeenTriggered(ePlayerID, boost) and projectInfo.PrereqDistrict == sHelperType then TriggerBoost(ePlayerID, boost); end
		end
	end
	
	-- BOOST: PROJECT_HAVE_X
	tBoostClass = tBoostClasses["PROJECT_HAVE_X"];
	if tBoostClass ~= nil and ( projectInfo.ProjectType == "PROJECT_BUILD_NUCLEAR_DEVICE" or projectInfo.ProjectType == "PROJECT_BUILD_THERMONUCLEAR_DEVICE" ) then
		for id,boost in pairs(tBoostClass.Boosts) do
			local iNumWMDs:number = 0;
			-- this is the first case where UI is actually NOT UPDATED with game core changes - GetWMDWeaponCount does not count the one that has just been built!
			if boost.Helper == "BUILD_NUCLEAR_DEVICE"       then iNumWMDs = 1 + ExposedMembers.REU.GetWMDWeaponCount(ePlayerID, "WMD_NUCLEAR_DEVICE");       end
			if boost.Helper == "BUILD_THERMONUCLEAR_DEVICE" then iNumWMDs = 1 + ExposedMembers.REU.GetWMDWeaponCount(ePlayerID, "WMD_THERMONUCLEAR_DEVICE"); end
			dprint("  ...processing boost (class,id,helper,helpnum,num)", "PROJECT_HAVE_X", id, boost.Helper, boost.NumItems2, iNumWMDs);
			if not HasBoostBeenTriggered(ePlayerID, boost) and iNumWMDs >= boost.NumItems2 then TriggerBoost(ePlayerID, boost); end
		end
	end
	
end


function ProcessBoostReligionFollowers(ePlayerID:number)
	dprint("FUN ProcessBoostReligionFollowers", ePlayerID);

	-- BOOST: RELIGION_X_FOLLOWERS
	tBoostClass = tBoostClasses["RELIGION_X_FOLLOWERS"];
	if tBoostClass == nil then return; end -- no boost like this at all
	
	--local iNumFollowers:number = Players[ePlayerID]:GetStats():GetNumFollowers(); -- weird, but this function is not reliable...
	
	-- check if player has religion
	if Players[ePlayerID] == nil then return; end
	local eReligionID:number = Players[ePlayerID]:GetReligion():GetReligionTypeCreated();
	if GameInfo.Religions[eReligionID] == nil or GameInfo.Religions[eReligionID].Pantheon then return; end
	dprint("...player has religion (id,rel)", eReligionID, GameInfo.Religions[eReligionID].ReligionType);
	
	-- iterate through all cities
	local iNumFollowers:number = 0;
	for _,player in ipairs(PlayerManager.GetAlive()) do
		for _,city in player:GetCities():Members() do
			--local iCityFollowers:number = city:GetReligion():GetNumFollowers(eReligionID);
			--if iCityFollowers > 0 then dprint("...adding followers from city (name,num)", city:GetName(), iCityFollowers); end
			iNumFollowers = iNumFollowers + city:GetReligion():GetNumFollowers(eReligionID);
		end
	end
	
	-- BOOST: RELIGION_X_FOLLOWERS
	for id,boost in pairs(tBoostClass.Boosts) do
		dprint("  ...processing boost (class,id,helper,followers)", "RELIGION_X_FOLLOWERS", id, boost.NumItems2, iNumFollowers);
		if not HasBoostBeenTriggered(ePlayerID, boost) and iNumFollowers >= boost.NumItems2 then TriggerBoost(ePlayerID, boost); end
	end
	
end


function ProcessBoostHaveGreatWorks(ePlayerID:number, iCityX:number, iCityY:number, iGreatWorkIndex:number)
	dprint("FUN ProcessBoostHaveGreatWorks", ePlayerID, iCityX, iCityY, iGreatWorkIndex)
	
	-- BOOST: HAVE_X_GREAT_WORKS
	tBoostClass = tBoostClasses["HAVE_X_GREAT_WORKS"];
	if tBoostClass == nil then return; end -- no boost like this at all
	
	-- first, find out what kind of GW has just been created
	local sGreatWorkCreated:string = ExposedMembers.REU.GetGreatWorkObjectType(iCityX, iCityY, iGreatWorkIndex);
	if sGreatWorkCreated == nil then return; end -- assert
	local iNumGWs:number = ExposedMembers.REU.GetGreatWorkCount(ePlayerID, sGreatWorkCreated); -- count once the type's just created
	
	-- BOOST: HAVE_X_GREAT_WORKS
	for id,boost in pairs(tBoostClass.Boosts) do
		local sHelperType:string = "GREATWORKOBJECT_"..boost.Helper;
		if sGreatWorkCreated == sHelperType then
			dprint("  ...processing boost (class,id,helper,helpnum,created)", "HAVE_X_GREAT_WORKS", id, sHelperType, boost.NumItems2, iNumGWs);
			if not HasBoostBeenTriggered(ePlayerID, boost) and iNumGWs >= boost.NumItems2 then TriggerBoost(ePlayerID, boost); end
		end
	end
	
end


-- ===========================================================================
-- HELPERS
-- ===========================================================================

-- get a new table with all 0
function PriorityTableNew()
	local tNew:table = {};
	for strat,_ in pairs(Strategies) do tNew[ strat ] = 0; end
	return tNew;
end

-- set all values to 0
function PriorityTableClear(pTable:table)
	for strat,_ in pairs(Strategies) do pTable[ strat ] = 0; end
end

-- add two tables
function PriorityTableAdd(pTable:table, pTableToAdd:table)
	for strat,_ in pairs(Strategies) do pTable[ strat ] = pTable[ strat ] + pTableToAdd[ strat ]; end
end

-- multiply two tables
function PriorityTableMultiplyByTable(pTable:table, pTableToMult:table)
	for strat,_ in pairs(Strategies) do pTable[ strat ] = pTable[ strat ] * pTableToMult[ strat ]; end
end

-- multiply by a given number
function PriorityTableMultiply(pTable:table, fModifier:number)
	for strat,_ in pairs(Strategies) do pTable[ strat ] = pTable[ strat ] * fModifier; end
end


-- ===========================================================================
-- CORE FUNCTIONS
-- ===========================================================================


------------------------------------------------------------------------------
-- Read flavors and parameters, initialize players
function InitializeData()
	print("FUN InitializeData");
	-- read parameters
	-- read flavors
	-- initialize players
	for _,playerID in ipairs(PlayerManager.GetAliveMajorIDs()) do
		local data:table = {
			PlayerID = playerID,
			LeaderType = PlayerConfigurations[playerID]:GetLeaderTypeName(),
			LeaderName = Locale.Lookup(PlayerConfigurations[playerID]:GetLeaderName()),
			Dirty = true,
			ActiveStrategy = "NONE",
			NumTurnsActive = 0,
			Data = {}, -- this will be refreshed whenever Dirty is true
			Stored = {}, -- this will be stored between turns (persistent) and eventually perhaps in the save file
		};
		tData[playerID] = data;
		print("...registering player", data.PlayerID, data.LeaderType, data.LeaderName); -- debug
	end
	-- initalize flavors
	for flavor in GameInfo.RSTFlavors() do
		local data:table = tPriorities[flavor.ObjectType];
		if data == nil then
			data = {
				ObjectType = flavor.ObjectType,
				Type = flavor.Type,
				Subtype = flavor.Subtype,
				Priorities = PriorityTableNew(),
			};
			tPriorities[flavor.ObjectType] = data;
		end
		data.Priorities[flavor.Strategy] = flavor.Value;
	end
	--[[
	print("Table of priorities:"); -- debug
	for objType,data in pairs(tPriorities) do
		dprint("object,type,subtype", data.ObjectType, data.Type, data.Subtype);
		dshowpriorities(data.Priorities);
	end
	--]]
end

--[[
Data
- Each civ needs its own set of data - should be stored in the table []????
- Not needed, assuming that all is refreshed!
- However, it is possible that some data could be stored between turns, e.g. current strategy
- Weights should be parameters

Main function:
- uses bDirty to mark dirty data
- gather current data about ourselves
- store each element in a table of priorities, with the name and weight?
- recalculate (easy)
- log results (details)
- guess what others are doing
- AI logic?

Event functions
- There will be many or few, but they will be called for many strategies, so multiple times
- Recalculate only once and later just return quickly results
- Need bDirty to mark the need to recalculate



--]]

------------------------------------------------------------------------------
-- This function gathers data specific for victories, like Military Strength, Science Positions, Tourism, etc.
function RefreshSpecificData(ePlayerID:number)
	print("FUN RefreshSpecificData", ePlayerID);
	--[[
	-- TESTING DISPLAY VARIOUS DATA AND COMPARE WITH OTHERS
	local pPlayer:table = Players[ePlayerID];
	if not (pPlayer ~= nil and pPlayer:IsAlive() and pPlayer:IsMajor()) then return; end
	local iTurn:number = Game.GetCurrentGameTurn();
	local sBegin:string = string.format("RST %3d %2d", iTurn, ePlayerID);
	-- get us first
	local sEra:string       = sBegin..string.format(" era  , %4d,", pPlayer:GetEra());
	local sScore:string     = sBegin..string.format(" score, %4d,", pPlayer:GetScore());
	local sTechNum:string   = sBegin..string.format(" techs, %4d,", RST.GetPlayerNumTechsResearched(ePlayerID));
	local sTechYield:string = sBegin..string.format(" scien, %4.1f,", pPlayer:GetTechs():GetScienceYield());
	local sMilStr:string    = sBegin..string.format(" milit, %4d,", RST.GetPlayerMilitaryStrength(ePlayerID));
	local sMilStrNoT:string = sBegin..string.format(" milwt, %4d,", RST.GetPlayerMilitaryStrengthWithoutTreasury(ePlayerID));
	-- now add all others for comparison
	for _,player in pairs(PlayerManager.GetAlive()) do
		sEra       = sEra..string.format(" %4d,", player:GetEra());
		sScore     = sScore..string.format(" %4d,", player:GetScore());
		sTechNum   = sTechNum..string.format(" %4d,", RST.GetPlayerNumTechsResearched(player:GetID()));
		sTechYield = sTechYield..string.format(" %4.1f,", player:GetTechs():GetScienceYield());
		sMilStr    = sMilStr..string.format(" %4d,", RST.GetPlayerMilitaryStrength(player:GetID()));
		sMilStrNoT = sMilStrNoT..string.format(" %4d,", RST.GetPlayerMilitaryStrengthWithoutTreasury(player:GetID()));
	end
	print(sEra);
	print(sScore);
	print(sTechNum);
	print(sTechYield);
	print(sMilStr);
	print(sMilStrNoT);
	--]]
end


------------------------------------------------------------------------------
-- Gather generic data like Leader, Policies, Beliefs, etc
function GetGenericPriorities(data:table)
	print("FUN ProcessGenericData for", data.LeaderName);
	
	local pPlayer:table = Players[data.PlayerID];
	local tGenericPriorities:table = PriorityTableNew();
	
	-- POLICIES
	-- Add priority value based on flavors of policies we've acquired.
	print("...generic: policies");
	local tPolicies:table = RST.PlayerGetSlottedPolicies(data.PlayerID);
	local tPolicyPriorities:table = PriorityTableNew();
	for _,policy in ipairs(tPolicies) do
		if tPriorities[policy] then PriorityTableAdd(tPolicyPriorities, tPriorities[policy].Priorities);
		else                        print("WARNING: policy", policy, "not defined in Priorities"); end
	end
	PriorityTableMultiply(tPolicyPriorities, GlobalParameters.RST_WEIGHT_POLICY);
	dshowpriorities(tPolicyPriorities); -- debug
	
	-- GOVERNMENT
	print("...generic: government");
	local sGovType:string = GameInfo.Governments[ RST.PlayerGetCurrentGovernment(data.PlayerID) ].GovernmentType;
	local tGovPriorities:table = PriorityTableNew();
	if tPriorities[sGovType] then PriorityTableAdd(tGovPriorities, tPriorities[sGovType].Priorities);
	else                          print("WARNING: government", sGovType, "not defined in Priorities"); end
	PriorityTableMultiply(tGovPriorities, GlobalParameters.RST_WEIGHT_GOVERNMENT);
	dshowpriorities(tGovPriorities); -- debug
	
	
	-- WONDERS
	-- probably the fastest way is to iterate through Flavors?
	print("...generic: wonders");
	local tWonderPriorities:table = PriorityTableNew();
	for object,data in pairs(tPriorities) do
		if data.Type == "Wonder" then
			-- now iterate through cities
			-- Player	GetCities	Members
			-- City	GetBuildings	HasBuilding
		end
	end
	PriorityTableMultiply(tWonderPriorities, GlobalParameters.RST_WEIGHT_WONDER);
	dshowpriorities(tWonderPriorities); -- debug
	
	-- CITY STATES
	--print("...generic: city states");
	
	-- BELIEFS
	--print("...generic: beliefs");
	
	print("...generic priorities total");
	PriorityTableAdd(tGenericPriorities, tPolicyPriorities);
	PriorityTableAdd(tGenericPriorities, tGovPriorities);
	PriorityTableAdd(tGenericPriorities, tWonderPriorities);
	dshowpriorities(tGenericPriorities);
	return tGenericPriorities;
end


------------------------------------------------------------------------------
-- TODO: Add map analysis in the future
function ProcessGeographicData(ePlayerID:number)
	print("FUN ProcessGeographicData", ePlayerID);
end

------------------------------------------------------------------------------
-- Gather all data needed to guess what others are doing
function RefreshGuessData(ePlayerID:number)
	print("FUN RefreshGuessData", ePlayerID);
end


------------------------------------------------------------------------------
-- Gather all data needed to guess what others are doing
function GuessOtherPlayersActiveStrategy(data:table)
end


------------------------------------------------------------------------------
-- TODO
function GetGuessOtherPlayerActiveGrandStrategy(data:table, eOtherID:number)
	print("FUN GetGuessOtherPlayerActiveGrandStrategy", data.PlayerID, eOtherID);
	local iRand:number = math.random(0,4);
	for strat,value in pairs(Strategies) do
		if iRand == value then
			print("...guessing", strat);
			return strat;
		end
	end
	return "NONE";
end

------------------------------------------------------------------------------
-- TODO
function OtherPlayerDoingBetterThanUs(data:table, eOtherID:number, sStrategy:string)
	print("FUN OtherPlayerDoingBetterThanUs", data.PlayerID, eOtherID, sStrategy);
	local bBetter:boolean = math.random(0,1) == 1;
	print("...", bBetter and "YES" or "no");
	return bBetter
end

------------------------------------------------------------------------------
-- Specific: CONQUEST
function GetPriorityConquest(data:table)
	print("FUN GetPriorityConquest");
	-- check if this victory type is enabled
	if not RST.GameIsVictoryEnabled("VICTORY_CONQUEST") then return -1000; end
	
	local iPriority:number = 0;
	local pPlayer:table = Players[data.PlayerID];
	
	-- first check is for Hostility, Deceptiveness, etc. - those are not supported in Civ6
	-- iPriority += ((GetPlayer()->GetDiplomacyAI()->GetBoldness() + iGeneralApproachModifier + GetPlayer()->GetDiplomacyAI()->GetMeanness()) * (10 - iEra)); // make a little less likely as time goes on
	-- try to use generic Flavor?
	if tPriorities[data.LeaderType] then
		iPriority = tPriorities[data.LeaderType].Priorities.CONQUEST;
		iPriority = iPriority * 2 * (1.0 - pPlayer:GetEra()/#GameInfo.Eras); -- PARAMETER???
		dprint("...era adjusted extra conquest priority", iPriority);
	end

	-- early game, if we haven't met any Major Civs yet, then we probably shouldn't be planning on conquering the world
	local iElapsedTurns:number = Game.GetCurrentGameTurn() - GameConfiguration.GetStartTurn(); -- TODO: GameSpeed scaling!
	if iElapsedTurns >= GlobalParameters.RST_CONQUEST_NOBODY_MET_NUM_TURNS then -- def. 20, AI_GS_CONQUEST_NOBODY_MET_FIRST_TURN
		local bHasMetMajor:boolean = false;
		for _,otherID in ipairs(PlayerManager.GetAliveMajorIDs()) do
			-- did we meet him?
			if otherID ~= data.PlayerID and pPlayer:GetDiplomacy():HasMet(otherID) then bHasMetMajor = true; end
		end
		if not bHasMetMajor then 
			iPriority = iPriority + GlobalParameters.RST_CONQUEST_NOBODY_MET_PRIORITY; -- def. -50, AI_GRAND_STRATEGY_CONQUEST_NOBODY_MET_WEIGHT
			print("...turn", Game.GetCurrentGameTurn(), "no majors met, priority", GlobalParameters.RST_CONQUEST_NOBODY_MET_PRIORITY);
		end
	end

	
	return iPriority;
end

function GetPriorityScience(data:table)
	print("FUN GetPriorityScience");
	-- check if this victory type is enabled
	if not RST.GameIsVictoryEnabled("VICTORY_TECHNOLOGY") then return -1000; end
	return 0;
end

function GetPriorityCulture(data:table)
	print("FUN GetPriorityCulture");
	-- check if this victory type is enabled
	if not RST.GameIsVictoryEnabled("VICTORY_CULTURE") then return -1000; end
	return 0;
end

function GetPriorityReligion(data:table)
	print("FUN GetPriorityReligion");
	-- check if this victory type is enabled
	if not RST.GameIsVictoryEnabled("VICTORY_RELIGIOUS") then return -1000; end
	return 0;
end

function GetPriorityDiplo(data:table)
	print("FUN GetPriorityDiplo");
	return 0;
end

function GetPriorityDefence(data:table)
	print("FUN GetPriorityDefence");
	return 0;
end


------------------------------------------------------------------------------
-- Get the base Priority for a Grand Strategy; these are elements common to ALL Grand Strategies
-- Base Priority looks at Personality Flavors (0 - 10) and multiplies * the Flavors attached to a Grand Strategy (0-10),
-- so expect a number between 0 and 100 back from this
function EstablishStrategyBasePriority(data:table)
	print("FUN EstablishStrategyBasePriority, player", data.PlayerID, data.LeaderName);
	data.Priorities = PriorityTableNew();
	if tPriorities["BasePriority"] == nil then
		print("WARNING: BasePriority table not defined."); return;
	end
	if tPriorities[data.LeaderType] == nil then
		print("WARNING: Priorities table for leader", data.LeaderType, "not defined."); return;
	end
	-- multiply Leader flavors by Strategy flavors
	PriorityTableAdd(data.Priorities, tPriorities[data.LeaderType].Priorities);
	PriorityTableMultiplyByTable(data.Priorities, tPriorities["BasePriority"].Priorities);
	print("...base priorities for leader", data.LeaderType);
	dshowpriorities(data.Priorities);
end


------------------------------------------------------------------------------
-- Main function, do all pre-checks so others won't have to
function RefreshAndProcessData(ePlayerID:number)
	print("FUN RefreshAndProcessData", ePlayerID);
	local pPlayer:table = Players[ePlayerID];
	if not (pPlayer ~= nil and pPlayer:IsAlive() and pPlayer:IsMajor()) then return; end
	local data:table = tData[ePlayerID];
	-- check if data needs to be refreshed
	if not data.Dirty then return; end
	
	-- Only run this on turns we need it
	if data.ActiveStrategy ~= "NONE" and data.NumTurnsActive > 0 then
		data.NumTurnsActive = data.NumTurnsActive + 1;
		print("...current strategy", data.ActiveStrategy, "active for", data.NumTurnsActive, "turns");
		if data.NumTurnsActive > GlobalParameters.RST_STRATEGY_NUM_TURNS_MUST_BE_ACTIVE then -- AI_GRAND_STRATEGY_NUM_TURNS_STRATEGY_MUST_BE_ACTIVE -- note to self: it must scaled by GameSpeed
			data.NumTurnsActive = 0;
			print("......RESET");
		end
		return;
	end
	
	RefreshSpecificData(ePlayerID);
	
	GuessOtherPlayersActiveStrategy(data);
	
	-- reset priorities
	--data.Priorities = PriorityTableNew();
	
	-- Base Priority looks at Personality Flavors (0 - 10) and multiplies * the Flavors attached to a Grand Strategy (0-10),
	-- so expect a number between 0 and 100 back from this
	EstablishStrategyBasePriority(data);
	
	-- Loop through all GrandStrategies to set their Priorities
	-- specific conditions - TODO: can this be expandable? like Lua function as a parameter
	--                       TODO: if objects were used, then data would be self aand functions would look like self:GetPriorityConquest()
	local tSpecificPriorities:table = PriorityTableNew();
	tSpecificPriorities.CONQUEST = GetPriorityConquest(data);
	tSpecificPriorities.SCIENCE  = GetPriorityScience(data);
	tSpecificPriorities.CULTURE  = GetPriorityCulture(data);
	tSpecificPriorities.RELIGION = GetPriorityReligion(data);
	tSpecificPriorities.DIPLO    = GetPriorityDiplo(data);
	tSpecificPriorities.DEFENCE  = GetPriorityDefence(data);
	--tSpecificPriorities.NAVAL  = GetPriorityNaval(data);
	--tSpecificPriorities.TRADE  = GetPriorityTrade(data);
	print("...specific priorities");
	dshowpriorities(tSpecificPriorities);
	--print("...applying specific priorities");
	--dshowpriorities(data.Priorities);

	--local tGenericPriorities:table = GetGenericPriorities(data);
	PriorityTableAdd(tSpecificPriorities, GetGenericPriorities(data));
	
	-- reduce the potency of these until the mid game.
	-- Civ5 just uses MaxTurn, but for Cv6 it won't work - TODO: use Num of techs / civics just as for District costs
	-- int MaxTurn = GC.getGame().getEstimateEndTurn();
	local iMaxTurn:number = RST.GameGetMaxGameTurns();
	local iCurrentTurn:number = Game.GetCurrentGameTurn();
	dprint("...(iMaxT,iCurT,perc)", iMaxTurn, iCurrentTurn, iCurrentTurn * 2 / iMaxTurn);
	PriorityTableMultiply(tSpecificPriorities, iCurrentTurn * 2 / iMaxTurn); -- effectively, it gives 100% at half the game and scales linearly
	print("...specific priorities after turn scaling");
	dshowpriorities(tSpecificPriorities);
	
	print("...applying specific priorities");
	PriorityTableAdd(data.Priorities, tSpecificPriorities);
	dshowpriorities(data.Priorities);
	
	-- random element
	for strat,value in pairs(data.Priorities) do
		data.Priorities[strat] = value + math.random(0,GlobalParameters.RST_STRATEGY_RANDOM_PRIORITY); -- AI_GS_RAND_ROLL
	end
	print("...applying a bit of randomization");
	dshowpriorities(data.Priorities);
	
	-- Give a boost to the current strategy so that small fluctuation doesn't cause a big change
	if data.ActiveStrategy ~= "NONE" then
		print("...boosting current strategy", data.ActiveStrategy);
		data.Priorities[data.ActiveStrategy] = data.Priorities[data.ActiveStrategy] + GlobalParameters.RST_STRATEGY_CURRENT_PRIORITY; -- AI_GRAND_STRATEGY_CURRENT_STRATEGY_WEIGHT
	end
			
	-- Tally up how many players we think are pursuing each Grand Strategy
	local tAdoptedNum:table = PriorityTableNew();
	local pPlayerDiplomacy:table = Players[data.PlayerID]:GetDiplomacy();
	local iNumPlayersAliveAndMet:number = 0;
	for _,otherID in ipairs(PlayerManager.GetAliveMajorIDs()) do
		-- did we meet him?
		if otherID ~= data.PlayerID and pPlayerDiplomacy:HasMet(otherID) then
			iNumPlayersAliveAndMet = iNumPlayersAliveAndMet + 1;
			local sOtherStrategy:string = GetGuessOtherPlayerActiveGrandStrategy(data, otherID); -- WARNING! can they pursue 2 strategies? if so, make changes here!
			if sOtherStrategy ~= "NONE" and sOtherStrategy == data.ActiveStrategy then
				if OtherPlayerDoingBetterThanUs(data, otherID, sOtherStrategy) then
					print("...player", otherID, "is doing better than us with", sOtherStrategy);
					tAdoptedNum[sOtherStrategy] = tAdoptedNum[sOtherStrategy] + 1;
				end
			end
		end
	end
	print("...players met and alive", iNumPlayersAliveAndMet);
	print("...number of players better than us in specific strategies");
	dshowpriorities(tAdoptedNum);
	
	
	-- Now modify our preferences based on how many people are going for stuff
	-- For each player following the strategy and being better than us, reduce our priority by 33%
	local tNerfFactor:table = PriorityTableNew();
	PriorityTableAdd(tNerfFactor, data.Priorities); -- copy
	PriorityTableMultiply(tNerfFactor, GlobalParameters.RST_STRATEGY_BETTER_THAN_US_NERF/100.0);
	for strat,value in pairs(data.Priorities) do
		tNerfFactor[strat] = tNerfFactor[strat] * tAdoptedNum[strat] * (-1);
	end
	print("...nerf factors");
	dshowpriorities(tNerfFactor);
	print("...final priorities are");
	PriorityTableAdd(data.Priorities, tNerfFactor);
	dshowpriorities(data.Priorities);
	
	-- Now see which Grand Strategy should be active, based on who has the highest Priority right now
	local iBestPriority:number = GlobalParameters.RST_STRATEGY_MINIMUM_PRIORITY; -- minimum score to activate a strategy
	for strat,value in pairs(data.Priorities) do
		if value > iBestPriority then
			iBestPriority = value;
			data.ActiveStrategy = strat;
			data.NumTurnsActive = 1;
		end
	end
	print("...selected", data.ActiveStrategy, "priority", iBestPriority, "turns", data.NumTurnsActive);
	
	-- finish
	if data.ActiveStrategy ~= "NONE" then
		data.NumTurnsActive = data.NumTurnsActive + 1
	end
	data.Dirty = false; -- data is refreshed
	dshowrectable(tData[ePlayerID]); -- show all info
end


-- ===========================================================================
-- GAME EVENTS
-- ===========================================================================


-- ===========================================================================
-- only 4 params, checked
function OnCityAddedToMap(ePlayerID:number, iCityID:number, iX:number, iY:number)
	dprint("FUN OnCityAddedToMap() (player,city,x,y,a,b)",ePlayerID,iCityID,iX,iY);
	if not IsPlayerBoostable(ePlayerID) then return; end
	dprint("Player is boostable (id)", ePlayerID);
	-- BOOST CLASS DISPATCHER
	if Players[ePlayerID]:GetCities():GetCount() == 1 then
		ProcessBoostsCapitalLocation(ePlayerID, iCityID, iX, iY);
		ProcessBoostsSettledCities("1", ePlayerID, iCityID);
	end
	if Players[ePlayerID]:GetCities():GetCount() == 2 then
		ProcessBoostsSettledCities("2", ePlayerID, iCityID);
	end
end

-- ===========================================================================
-- Units: called only when actual training, e.g. NOT called for gold purchased units.
--        TypeModifier in CPC event is for Normal=0/Corps=1/Army=2
function OnCityProductionCompleted(ePlayerID:number, iCityID:number, eOrderType:number, eObjectType:number, bCanceled:boolean, typeModifier:number)
	dprint("FUN OnCityProductionCompleted(ePlayerID,iCity,eOrderType,eObjectType,bCanceled,typeModifier)",ePlayerID,iCityID,eOrderType,eObjectType,bCanceled,typeModifier);
	if not IsPlayerBoostable(ePlayerID) then return; end
	-- BOOST CLASS DISPATCHER
	if eOrderType == 0 then  -- OrderTypes.ORDER_TRAIN
		dprint("..trained", GameInfo.Units[eObjectType].UnitType);
		ProcessBoostTrainUnit(ePlayerID, eObjectType); -- TRAIN_UNIT
	elseif eOrderType == 1 then  -- OrderTypes.ORDER_CONSTRUCT
		-- boosts for Buildings
		--GameInfo.Buildings[eObjectType].BuildingType
	elseif eOrderType == 2 then  -- OrderTypes.ORDER_ZONE
		-- boosts for Districts
		--GameInfo.Districts[eObjectType].DistrictType
	elseif eOrderType == 3 then  -- PROJECTS!
		-- boosts for Projects
		--GameInfo.Projects[eObjectType].ProjectType
	else  -- unknown order type
		print("ERROR: unknown order type", eOrderType);
	end
end


-- ===========================================================================
-- CityProjectCompleted = { "player", "iCityID", "Project", "Building", "iX", "iY", "bCanceled" },
function OnCityProjectCompleted(ePlayerID:number, iCityID:number, eProjectIndex:number, eBuildingIndex:number, iLocX:number, iLocY:number, bCanceled:boolean)
	dprint("FUN OnCityProjectCompleted(ePlayerID,iCityID,eProjectIndex,eBuildingIndex,iLocX,iLocY,bCanceled)",ePlayerID, iCityID, eProjectIndex, eBuildingIndex, iLocX, iLocY, bCanceled);
	if not IsPlayerBoostable(ePlayerID) or bCanceled then return; end
	-- BOOST CLASS DISPATCHER
	ProcessBoostsProjectCompleted(ePlayerID, eProjectIndex);
end


-- ===========================================================================
-- CityReligionFollowersChanged = { "player", "iCityID", "eRevealedState", "x" }, -- last param is 'city'; careful, this event fires insanely often!
function OnCityReligionFollowersChanged(ePlayerID:number, iCityID:number, eVisibility:number, city)
	dprint("OnCityReligionFollowersChanged(ePlayerID,iCityID,eVisibility,city)", ePlayerID, iCityID, eVisibility, city);
	if not IsPlayerBoostable(ePlayerID) then return; end
	-- BOOST CLASS DISPATCHER
	ProcessBoostReligionFollowers(ePlayerID);
end


-- ===========================================================================
function OnGreatWorkCreated(ePlayerID:number, iCreatorID:number, iCityX:number, iCityY:number, eBuildingID:number, iGreatWorkIndex:number)
	dprint("FUN OnGreatWorkCreated(ePlayerID,iCreatorID,iCityX,iCityY,eBuildingID,iGreatWorkIndex)", ePlayerID, iCreatorID, iCityX, iCityY, eBuildingID, iGreatWorkIndex);
	if not IsPlayerBoostable(ePlayerID) then return; end
	-- BOOST CLASS DISPATCHER
	ProcessBoostHaveGreatWorks(ePlayerID, iCityX, iCityY, iGreatWorkIndex);
end


-- ===========================================================================
-- Player:GetCulture:GetCurrentGovernment -- only UI context
function OnGovernmentChanged(ePlayerID:number, eGovernmentIndex:number)
	dprint("FUN OnGovernmentChanged(ePlayerID,eGovernmentIndex)", ePlayerID, eGovernmentIndex);
	if not IsPlayerBoostable(ePlayerID) then return; end
	-- BOOST CLASS DISPATCHER
	ProcessBoostHaveGovernment(ePlayerID, eGovernmentIndex); -- HAVE_GOVERNMENT
end


-- ===========================================================================
-- UnitGreatPersonCreated =	{ "player", "iUnitID", "GreatPersonClass", "GreatPersonIndividual" },
function OnUnitGreatPersonCreated(ePlayerID:number, iUnitID:number, eGreatPersonClass:number, eGreatPersonIndividual:number)
	dprint("FUN OnUnitGreatPersonCreated(ePlayerID,iUnitID,eGreatPersonClass,eGreatPersonIndividual)",ePlayerID,iUnitID,eGreatPersonClass,eGreatPersonIndividual);
	if not IsPlayerBoostable(ePlayerID) then return; end
	-- BOOST CLASS DISPATCHER
	ProcessBoostGreatPerson(ePlayerID, eGreatPersonClass);
end


-- ===========================================================================
function OnDistrictAddedToMap( playerID: number, districtID : number, cityID :number, districtX : number, districtY : number, districtType:number, percentComplete:number )
-- percentComplete was ERA_ANCIENT=-1851407529
-- 1400916610=ERA_CLASSICAL (I was in Medieval)
-- 848543945=ERA_RENAISSANCE (I was in Industrial)
-- 1948543980=ERA_ATOMIC (I was in Information)
	dprint("FUN OnDistrictAddedToMap() (did,cid,x,y,type,perc)",districtID,cityID,districtX,districtY,districtType,percentComplete);
end

-- ===========================================================================
function OnImprovementAddedToMap(locX, locY, eImprType, eOwner, resource, isPillaged, isWorked)
	dprint("FUN OnImprovementAddedToMap() (x,y,type,owner,resource)",locX,locY,eImprType,eOwner,resource);
end

-- ===========================================================================
-- This event is called for any unit, no matter how created. So, purchasing with gold and faith, earning GPs, etc.
-- Also: this event is called BEFORE CityProductionCompleted!
function OnUnitAddedToMap( playerID: number, unitID : number, unitX : number, unitY : number )
	dprint("FUN OnUnitAddedToMap() (player,unit,x,y)",playerID,unitID,unitX,unitY);
end


-- ===========================================================================
-- it's call for each plot that unit is traversing
function OnUnitMoved(ePlayerID:number, iUnitID:number, x, y, locallyVisible, stateChange)
	dprint("FUN OnUnitMoved (player,unit,x,y,visible,state)",ePlayerID, iUnitID,x,y,locallyVisible,stateChange);
end


-- ===========================================================================
-- only 4 params, checked
function OnUnitMoveComplete(playerID, unitID, x, y)
	dprint("FUN OnUnitMoveComplete() (player,unit,x,y,visible,state)",playerID,unitID,x,y);
end

-- ===========================================================================
-- DiplomacyMeet is always called, then either MajorMinor or Majors.
-- DiplomacyMeet = 			{ "player", "player" },
-- DiplomacyMeetMajorMinor = 	{ "player", "player" },
-- DiplomacyMeetMajors =		{ "player", "player" },
function OnDiplomacyMeet(ePlayerID:number, eMetPlayerID:number)
	dprint("FUN OnDiplomacyMeet", ePlayerID, eMetPlayerID);
	if not IsPlayerBoostable(ePlayerID) then return; end
	-- BOOST CLASS DISPATCHER
	if PlayerIsMinor(eMetPlayerID) then
		ProcessBoostMeetCityState(ePlayerID, eMetPlayerID); -- MEET_CITY_STATE
		ProcessBoostMeetXCityStates(ePlayerID, eMetPlayerID); -- MEET_X_CITY_STATES
	end
	-- add more conditions here
end

-- ===========================================================================
-- Generic event called for all civs
function OnInfluenceChanged(ePlayerID:number)
end

-- ===========================================================================
-- Called for a City-State when a token is received
function OnInfluenceGiven(eMinorID:number, iUnknown:number)
	local ePlayerID:number = GetActivePlayer();
	dprint("FUN OnInfluenceGiven(player,minor)",ePlayerID,eMinorID);
	if not IsPlayerBoostable(ePlayerID) then return; end
	-- BOOST CLASS DISPATCHER
	ProcessBoostSuzerainCityState(ePlayerID, eMinorID);
	ProcessBoostSuzerainXCityStates(ePlayerID, eMinorID);
end

-- ===========================================================================
-- DiplomacyRelationshipTypes.ALLIED, .FRIENDSHIP, .DENOUNCED
-- Note: this has nothing to do with City-States
function OnDiplomacyRelationshipChanged(ePlayerID:number, eToPlayerID:number, eDiploRelType:number, iXX:number)
end

-- ===========================================================================
function OnLoadScreenClose()
	dprint("FUN OnLoadScreenClose");
end




------------------------------------------------------------------------------
-- PlayerTurnActivated = { "player", "bIsFirstTime" },
-- TESTING MODE - it should be deactivated later, there is no need to call this here 
function OnPlayerTurnActivated( ePlayerID:number, bIsFirstTime:boolean)
	print("FUN OnPlayerTurnActivated", ePlayerID, bIsFirstTime);
	RefreshAndProcessData(ePlayerID);
end

------------------------------------------------------------------------------
-- PlayerTurnDeactivated = { "player" },
function OnPlayerTurnDeactivated(ePlayerID:number)
	print("FUN OnPlayerTurnDeactivated", ePlayerID);
	local pPlayer:table = Players[ePlayerID];
	if not (pPlayer ~= nil and pPlayer:IsAlive() and pPlayer:IsMajor()) then return; end
	tData[ePlayerID].Dirty = true; -- default mode - later can be changed for specific events (e.g. Policy changed, gov changed, etc.)
end


-- ===========================================================================
-- Called separately for each player, including Minors, Free Cities and Barbarians
-- For player X it is called BEFORE PlayerTurnActivated(X)
-- For a Human, it is called AFTER LocalPlayerTurnBegin, but before PlayerTurnActivated(0)
function CheckTurnNumber(iPlayerID:number, iThreshold:number)
	--print("FUN CheckTurnNumber()", iPlayerID, iThreshold);
	--print("Turn number is", Game.GetCurrentGameTurn());
	--RefreshAndProcessData(ePlayerID);
	return Game.GetCurrentGameTurn() >= iThreshold;
end
GameEvents.CheckTurnNumber.Add(CheckTurnNumber);


-- ===========================================================================
function Initialize()
	print("FUN Initialize()");
	
	InitializeData();

	--Events.LoadScreenClose.Add ( OnLoadScreenClose );   -- fires when Game is ready to begin i.e. big circle buttons appears; if loaded - fires AFTER LoadComplete
	Events.PlayerTurnActivated.Add( OnPlayerTurnActivated );  -- main event for any player start (AIs, including minors), goes for playerID = 0,1,2,...
	-- these events fire AFTER custom PlayerTurnActivated()
	--Events.CityProductionCompleted.Add( OnCityProductionCompleted );
	--Events.CityProjectCompleted.Add( OnCityProjectCompleted );
	--Events.UnitGreatPersonCreated.Add( OnUnitGreatPersonCreated );
	--Events.TechBoostTriggered.Add( OnTechBoostTriggered );
	--Events.CivicBoostTriggered.Add( OnCivicBoostTriggered );
	--Events.ResearchCompleted.Add( OnResearchComplete );
	--Events.CivicCompleted.Add( OnCivicComplete );
	--Events.CityAddedToMap.Add( OnCityAddedToMap );
	--Events.DistrictAddedToMap.Add( OnDistrictAddedToMap );
	--Events.ImprovementAddedToMap.Add( OnImprovementAddedToMap );
	--Events.UnitAddedToMap.Add( OnUnitAddedToMap );
	--Events.UnitMoved.Add( OnUnitMoved );
	--Events.UnitMoveComplete.Add( OnUnitMoveComplete );
	--Events.DiplomacyMeet.Add( OnDiplomacyMeet );
	--Events.DiplomacyRelationshipChanged.Add( OnDiplomacyMeet );
	--Events.InfluenceChanged.Add( OnDiplomacyMeet );
	--Events.InfluenceGiven.Add( OnInfluenceGiven );
	--Events.CityReligionFollowersChanged.Add( OnCityReligionFollowersChanged ); -- this event fires every turn, for each city, very often!
	--Events.GreatWorkCreated.Add( OnGreatWorkCreated );
	--Events.GovernmentChanged.Add( OnGovernmentChanged );
	
	--InitializeBoosts();
	--dprint("List of BoostClasses:");
	--dshowtable(tBoostClasses, 0);
	-- more pre-events to check
	--Events.LoadComplete.Add( OnLoadComplete );  -- fires after loading a game, when it's ready to start (i.e. circle button)
	--Events.LoadScreenClose.Add ( OnLoadScreenClose );   -- fires then Game is ready to begin i.e. big circle buttons appears; if loaded - fires AFTER LoadComplete
	--Events.SaveComplete.Add( OnSaveComplete );  -- fires after save is completed, and Main Game Menu is displayed
	--Events.AppInitComplete.Add( OnAppInitComplete );
	--Events.GameViewStateDone.Add( OnGameViewStateDone );
	--Events.RequestSave.Add( OnRequestSave );  -- didn't fire
	--Events.RequestLoad.Add( OnRequestLoad );  -- didn't fire
	
	-- initialize events - starting events
	--Events.LocalPlayerChanged.Add( OnLocalPlayerChanged );  -- fires in-between TurnEnd and TurnBegin
	--Events.PreTurnBegin.Add( OnPreTurnBegin );  -- fires ONCE at start of turn, before actual Turn start
	--Events.TurnBegin.Add( OnTurnBegin );  -- fires ONCE at the start of Turn
	--Events.PhaseBegin.Add( OnPhaseBegin );  -- engine?
	--Events.LocalPlayerTurnBegin.Add( OnLocalPlayerTurnBegin );  -- event for LOCAL player only (i.e. HUMANS), fires BEFORE PlayerTurnActivated
	--Events.PlayerTurnActivated.Add( OnPlayerTurnActivated );  -- main event for any player start (AIs, including minors), goes for playerID = 0,1,2,...
	-- these events fire AFTER custom PlayerTurnActivated()
	--Events.CityProductionCompleted.Add(	OnCityProductionCompleted );
	--Events.CityProjectCompleted.Add( OnCityProjectComplete );	
	--Events.TechBoostTriggered.Add( OnTechBoostTriggered );
	--Events.CivicBoostTriggered.Add( OnCivicBoostTriggered );
	--Events.ResearchCompleted.Add( OnResearchComplete );
	--Events.CivicCompleted.Add( OnCivicComplete );
	
	-- HERE YOU PLAY GAME AS HUMAN
	-- initialize events - finishing events
	--Events.LocalPlayerTurnEnd.Add( OnLocalPlayerTurnEnd );  -- fires only for HUMANS
	Events.PlayerTurnDeactivated.Add( OnPlayerTurnDeactivated );  -- main event for any player end (including minors)
	--Events.PhaseEnd.Add( OnPhaseEnd );  -- engine?
	--Events.TurnEnd.Add( OnTurnEnd );  -- fires ONCE at end of turn
	--Events.EndTurnDirty.Add( OnEndTurnDirty );  -- engine event, triggers very often

end	
Initialize();

print("OK loaded RealStrategy.lua from Real Strategy");