// ******************************************************************************************
// * This project is licensed under the GNU Affero GPL v3. Copyright © 2014 A3Wasteland.com *
// ******************************************************************************************
//	@file Name: mission_HostileJetFormation.sqf
//	@file Author: JoSchaap, AgentRev
//	@file Modified: [FRAC] Mokey
//	@file missionSuccessHandler Author: soulkobk

if (!isServer) exitwith {};
#include "mainMissionDefines.sqf"

private ["_hostileJetChoices", "_hostileJetVeh", "_veh1", "_veh2", "_createVehicle", "_vehicles", "_leader", "_speedMode", "_waypoint", "_vehicleName", "_numWaypoints", "_box1", "_box2", "_box3", "_smoke"];

_setupVars =
{
	_missionType = "Hostile Jet Squadron";
};

_setupObjects =
{
	_missionPos = markerPos (((call cityList) call BIS_fnc_selectRandom) select 0);

	_hostileJetChoices =
	[
		[["I_Plane_Fighter_03_dynamicLoadout_F", "buzzardCAS"], ["I_Plane_Fighter_03_dynamicLoadout_F", "buzzardCAS"]],
		[["B_Plane_CAS_01_dynamicLoadout_F", "WipeoutMission"], ["B_Plane_CAS_01_dynamicLoadout_F", "WipeoutMission"]],
		["O_Plane_Fighter_02_F", "O_Plane_Fighter_02_F"],
		["B_Plane_Fighter_01_F", "B_Plane_Fighter_01_F"],
		[["O_Plane_CAS_02_dynamicLoadout_F", "NeoMission"], ["O_Plane_CAS_02_dynamicLoadout_F", "NeoMission"]],
		[["I_Plane_Fighter_04_F", "GryphonG"], ["I_Plane_Fighter_04_F", "GryphonG"]]
	];

	_hostileJetVeh = _hostileJetChoices call BIS_fnc_selectRandom;
	_veh1 = _hostileJetVeh select 0;
	_veh2 = _hostileJetVeh select 1;

	_createVehicle =
	{
		private ["_type", "_position", "_direction", "_variant", "_vehicle", "_soldier"];

		_type = _this select 0;
		_position = _this select 1;
		_direction = _this select 2;
		_variant = _type param [1,"",[""]];

 		if (_type isEqualType []) then
 		{
 			_type = _type select 0;
 		};

		_vehicle = createVehicle [_type, _position, [], 0, "FLY"];
		_vehicle setVariable ["R3F_LOG_disabled", true, true];

 		if (_variant != "") then
 		{
 			_vehicle setVariable ["A3W_vehicleVariant", _variant, true];
 		};

		[_vehicle] call vehicleSetup;
		_speed = 20;
		_vel = velocity _vehicle;
		_vehicle setVelocity [(_vel select 0) + (sin _direction * _speed), (_vel select 1) + (cos _direction * _speed), _vel select 2];
		_soldier = [_aiGroup, _position] call createRandomSoldierC;
		_soldier moveInDriver _vehicle;

		switch (true) do
		{
			case (_type isKindOf "O_T_VTOL_02_infantry_dynamicLoadout_F"):
			{
				// these Aircraft need 1 gunner
				_soldier = [_aiGroup, _position] call createRandomSoldierC;
				_soldier moveInGunner _vehicle;
			};
		};

		[_vehicle, _aiGroup] spawn checkMissionVehicleLock;
		_vehicle
	};

	_aiGroup = createGroup CIVILIAN;

	///////////////////////////////////////////////////////////////////////////////////////////////
	// added by soulkobk 09/03/2018...
	_mapSizeSquare = getNumber (configfile >> "CfgWorlds" >> worldName >> "mapSize");
	_mapSizeEllipse = sqrt ((_mapSizeSquare * _mapSizeSquare) + (_mapSizeSquare * _mapSizeSquare));
	_mapCenterPos = [(_mapSizeSquare / 2),(_mapSizeSquare / 2)];
	_startPosition = [_mapCenterPos,_mapSizeEllipse / 1.5,round(random(360))] call BIS_fnc_relPos;
	_directionToFly = [_startPosition,_mapCenterPos] call BIS_fnc_dirTo;
	_vehicles =
    [
        [_veh1,([_startPosition,100,0] call BIS_fnc_relPos),_directionToFly] call _createVehicle,
        [_veh2,([_startPosition,100,120] call BIS_fnc_relPos),_directionToFly] call _createVehicle

    ];
	// eoa
	///////////////////////////////////////////////////////////////////////////////////////////////

	_leader = effectiveCommander (_vehicles select 0);
	_aiGroup selectLeader _leader;
	_leader setRank "LIEUTENANT";
	_aiGroup setCombatMode "WHITE";
	_aiGroup setBehaviour "AWARE";
	_aiGroup setFormation "VEE";

	_speedMode = if (missionDifficultyHard) then { "NORMAL" } else { "LIMITED" };
	_aiGroup setSpeedMode _speedMode;

	{
		_waypoint = _aiGroup addWaypoint [markerPos (_x select 0), 0];
		_waypoint setWaypointType "MOVE";
		_waypoint setWaypointCompletionRadius 100;
		_waypoint setWaypointCombatMode "YELLOW";
		_waypoint setWaypointBehaviour "SAFE";
		_waypoint setWaypointFormation "VEE";
		_waypoint setWaypointSpeed _speedMode;
	} forEach ((call cityList) call BIS_fnc_arrayShuffle);

	_missionPos = getPosATL leader _aiGroup;
	_missionPicture = getText (configFile >> "CfgVehicles" >> (_veh1 param [0,""]) >> "picture");
 	_vehicleName = getText (configFile >> "CfgVehicles" >> (_veh1 param [0,""]) >> "displayName");
	_missionHintText = format ["A formation of Experimental Jets containing Two <t color='%3'>%1</t> are patrolling the island. Destroy them and recover their cargo!", _vehicleName, mainMissionColor];
	_numWaypoints = count waypoints _aiGroup;
};

_waitUntilMarkerPos = {getPosATL _leader};
_waitUntilExec = nil;
_waitUntilCondition = {currentWaypoint _aiGroup >= _numWaypoints};
_failedExec = nil;

#include "..\missionSuccessHandler.sqf"

_missionCratesSpawn = true;
_missionCrateAmount = 4;
_missionCrateSmoke = true;
_missionCrateSmokeDuration = 120;
_missionCrateChemlight = true;
_missionCrateChemlightDuration = 120;

_missionMoneySpawn = false;
_missionMoneyAmount = 100000;
_missionMoneyBundles = 10;
_missionMoneySmoke = true;
_missionMoneySmokeDuration = 120;
_missionMoneyChemlight = true;
_missionMoneyChemlightDuration = 120;

_missionSuccessMessage = "The sky is clear again, the enemy patrol was taken out! Ammo crates have fallen out their jet.";

_this call mainMissionProcessor;
