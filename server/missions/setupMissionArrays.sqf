// ******************************************************************************************
// * This project is licensed under the GNU Affero GPL v3. Copyright © 2014 A3Wasteland.com *
// ******************************************************************************************
//	@file Name: setupMissionArrays.sqf
//	@file Author: AgentRev

if (!isServer) exitWith {};

MainMissions =
[
	// Mission filename, weight
	["mission_ArmedDiversquad", 1],
	//["mission_Coastal_Convoy", .75],
	["mission_Convoy", 1],
	["mission_HostileHeliFormation", 0.5],
	["mission_APC", 1],
	["mission_MBT", 1],
	//["mission_LightArmVeh", 1],
	["mission_ArmedHeli", 1],
	//["mission_CivHeli", 1],
	["mission_Hackers",0.5],
	["mission_HostileJetFormation", .5],
	["mission_AbandonedJet", .5],
	["mission_ArmedPatrol", 1],
	//["mission_AbandonedVehicle", 0.75]
	["mission_ArmedPatrol", .75]
//["mission_AbandonedVehicle", 0.75]
];

SideMissions =
[
	["mission_HostileHelicopter", 0.5],
	["mission_MiniConvoy", 1],
	["mission_SunkenSupplies", .5],
	["mission_TownInvasion", 1],
	["mission_Outpost", 1],
	["mission_Truck", 1],
	["mission_redDawn", 1],
	//["mission_AirWreck", 2],
	["mission_geoCache", 0.5],
	["mission_HostileJet", 0.5],
	//["mission_WepCache", 2],
	["mission_Sniper", 1],
	["mission_Roadblock", 1]

];

MoneyMissions =
[
	["mission_MoneyShipment", 2],
	["mission_miniMoneyShipment", 2],
	["mission_SunkenTreasure", 1],
	["mission_SkySmuggler", 0.25]
];

MissionSpawnMarkers = (allMapMarkers select {["Mission_", _x] call fn_startsWith}) apply {[_x, false]};
ForestMissionMarkers = (allMapMarkers select {["ForestMission_", _x] call fn_startsWith}) apply {[_x, false]};
SunkenMissionMarkers = (allMapMarkers select {["SunkenMission_", _x] call fn_startsWith}) apply {[_x, false]};
RoadblockMissionMarkers = (allMapMarkers select {["RoadblockMission_", _x] call fn_startsWith}) apply {[_x, false]};



LandConvoyPaths = (call compile preprocessFileLineNumbers "mapConfig\convoys\landConvoysList.sqf") apply {[_x, false]};
CoastalConvoyPaths = (call compile preprocessFileLineNumbers "mapConfig\convoys\coastalConvoysList.sqf") apply {[_x, false]};

MainMissions = [MainMissions, [["A3W_heliPatrolMissions", ["mission_Coastal_Convoy", "mission_HostileHeliFormation", "mission_HostileJetFormation"]], ["A3W_underWaterMissions", ["mission_ArmedDiversquad"]]]] call removeDisabledMissions;
SideMissions = [SideMissions, [["A3W_heliPatrolMissions", ["mission_HostileHelicopter"]], ["A3W_underWaterMissions", ["mission_SunkenSupplies"]]]] call removeDisabledMissions;
MoneyMissions = [MoneyMissions, [["A3W_underWaterMissions", ["mission_SunkenTreasure"]]]] call removeDisabledMissions;

{ _x set [2, false] } forEach MainMissions;
{ _x set [2, false] } forEach SideMissions;
{ _x set [2, false] } forEach MoneyMissions;
