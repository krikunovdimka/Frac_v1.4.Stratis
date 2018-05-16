// ******************************************************************************************
// * This project is licensed under the GNU Affero GPL v3. Copyright © 2014 A3Wasteland.com *
// ******************************************************************************************
//	@file Name: mission_TownInvasion.sqf
//	@file Author: [404] Deadbeat, [404] Costlyy, JoSchaap, AgentRev, Zenophon
//  @file Information: JoSchaap's Lite version of 'Infantry Occupy House' Original was made by: Zenophon

if (!isServer) exitwith {};

#include "sideMissionDefines.sqf"

private ["_nbUnits", "_box1", "_box2", "_townName", "_missionPos", "_buildingRadius", "_putOnRoof", "_fillEvenly", "_tent1", "_chair1", "_chair2", "_cFire1"];

_setupVars =
{
	_missionType = "RED DAWN";
	_nbUnits = if (missionDifficultyHard) then { AI_GROUP_LARGE } else { AI_GROUP_MEDIUM };
	_locArray = ((call cityList) call BIS_fnc_selectRandom);
	_missionPos = markerPos (_locArray select 0);
	_missionPos set [2,200];
	_buildingRadius = _locArray select 1;
	_townName = _locArray select 2;
	_nbUnits = _nbUnits + round(random (_nbUnits*0.5));
	_buildingRadius = if (_buildingRadius > 201) then {(_buildingRadius*0.5)} else {_buildingRadius};

};

_setupObjects =
{
	_fillEvenly = true;
	_putOnRoof = true;
	_aiGroup = createGroup CIVILIAN;
	[_aiGroup, _missionPos, _nbUnits] call createAirTroops;
	{
 		_x move _missionPos;
		_x moveTo _missionPos;
	} forEach units _aiGroup;
	[_aiGroup, _missionPos, _buildingRadius, _fillEvenly, _putOnRoof] call moveIntoBuildings;

	_missionHintText = format ["Hostiles parachuted over <br/><t size='1.25' color='%1'>%2</t><br/><br/>There seem to be <t color='%1'>%3 enemies</t> dropping in! Get rid of them all, and take their supplies!<br/>WOLVERINES!", sideMissionColor, _townName, _nbUnits];
};

_waitUntilMarkerPos = nil;
_waitUntilExec = nil;
_waitUntilCondition = nil;
_failedExec = nil;


/*/ ------------------------------------------------------------------------------------------- /*/
/*/ scripted by soulkobk 5:00 PM 16/05/2018 for Arma 3 - A3Wasteland -------------------------- /*/
/*/ ------------------------------------------------------------------------------------------- /*/
_missionCratesSpawn = true; // upon mission success, spawn crates?
_missionCrateNumber = 2; // the total number of crates to spawn.
_missionCrateSmoke = true; // spawn crate smoke (red) to show location of dropped crates?
_missionCrateSmokeDuration = 120; // how long will the smoke last for once the crate reaches the ground?
_missionCrateChemlight = true; // spawn crate chemlight (red) to show location of dropped crates?
_missionCrateChemlightDuration = 120; // how long will the chemlight last for once the crate reaches the ground?

_missionMoneySpawn = false; // upon mission success, spawn money?
_missionMoneyTotal = 100000; // the total amount of money to spawn.
_missionMoneyBundles = 10; // edit this! how many bundles of money to spawn? (_missionMoneyTotal / _missionMoneyBundles).
_missionMoneySmoke = true; // spawn money smoke (red) to show location of dropped money?
_missionMoneySmokeDuration = 120; // how long will the smoke last for once the money reaches the ground?
_missionMoneyChemlight = true; // spawn money chemlight (red) to show location of dropped money?
_missionMoneyChemlightDuration = 120; // how long will the chemlight last for once the money reaches the ground?

_missionSuccessMessage = "WOLVERINES!!!!!!";

/*/ ------------------------------------------------------------------------------------------- /*/
_missionFinishPos = [0,0,0];
_waitUntilExec =
{
	_leader = leader _aiGroup;
	if !(isNull _leader) then
	{
		_missionFinishPos = getPosATL _leader;
	};
};
_successExec =
{
	if !(_missionFinishPos isEqualTo [0,0,0]) then
	{
		if (_missionCratesSpawn) then
		{
			_i = 0;
			while {_i < _missionCrateNumber} do
			{
				[_missionFinishPos,_missionCrateSmoke,_missionCrateSmokeDuration,_missionCrateChemlight,_missionCrateChemlightDuration] spawn
				{
					params ["_missionFinishPos","_missionCrateSmoke","_missionCrateSmokeDuration","_missionCrateChemlight","_missionCrateChemlightDuration"];
					_crateObject = selectRandom ["Box_NATO_Wps_F","Box_East_Wps_F","Box_IND_Wps_F","Box_NATO_WpsSpecial_F","Box_East_WpsSpecial_F","Box_IND_WpsSpecial_F"];
					_crate = createVehicle [_crateObject,_missionFinishPos,[],5,"CAN_COLLIDE"];
					_crate allowDamage false;
					waitUntil {sleep 0.1; !isNull _crate};
					if ((_missionFinishPos select 2) > 5) then
					{
						_crateParachute = createVehicle ["O_Parachute_02_F",(getPosATL _crate),[],0,"CAN_COLLIDE"];
						_crateParachute allowDamage false;
						_crate attachTo [_crateParachute, [0,0,0]];
						_crate call randomCrateLoadOut;
						waitUntil {getPosATL _crate select 2 < 5};
						detach _crate;
						deleteVehicle _crateParachute;
					};
					waitUntil {sleep 0.1; getPos _crate select 2 < 0.1};
					_cratePos = getPosATL _crate;
					_cratePos set [2, (_cratePos select 2) max 0 + 0.01];
					_crate setPosATL _cratePos;
					_crate allowDamage true;
					if (_missionCrateSmoke) then
					{
						[_crate,_cratePos,_missionCrateSmokeDuration] spawn
						{
							params ["_crate","_cratePos","_missionCrateSmokeDuration"];
							_smokeSignalCrate = createVehicle ["SmokeShellRed_infinite",_cratePos,[],0,"CAN_COLLIDE"];
							_smokeSignalCrate attachTo [_crate, [0,0,0.25]];
							_timer = time + _missionCrateSmokeDuration;
							waitUntil {sleep 0.1; time > _timer};
							deleteVehicle _smokeSignalCrate;
						};
					};
					if (_missionCrateChemlight) then
					{
						[_crate,_cratePos,_missionCrateChemlightDuration] spawn
						{
							params ["_crate","_cratePos","_missionCrateChemlightDuration"];
							_lightSignalCrate = createVehicle ["Chemlight_red",_cratePos,[],0,"CAN_COLLIDE"];
							_lightSignalCrate attachTo [_crate, [0,0,0.25]];
							_timer = time + _missionCrateChemlightDuration;
							waitUntil {sleep 0.1; time > _timer};
							deleteVehicle _lightSignalCrate;
						};
					};
				};
				_i = _i + 1;
			};
		};
		if (_missionMoneySpawn) then
		{
			[_missionFinishPos,_missionMoneySmoke,_missionMoneySmokeDuration,_missionMoneyChemlight,_missionMoneyChemlightDuration,_missionMoneyTotal,_missionMoneyBundles] spawn
			{
				params ["_missionFinishPos","_missionMoneySmoke","_missionMoneySmokeDuration","_missionMoneyChemlight","_missionMoneyChemlightDuration","_missionMoneyTotal","_missionMoneyBundles"];
				_sack = createVehicle ["Land_Sack_F",_missionFinishPos,[],5,"CAN_COLLIDE"];
				_sack allowDamage false;
				waitUntil {sleep 0.1; !isNull _sack};
				if ((_missionFinishPos select 2) > 5) then
				{
					_crateParachute = createVehicle ["O_Parachute_02_F",(getPosATL _sack),[],0,"CAN_COLLIDE"];
					_crateParachute allowDamage false;
					_sack attachTo [_crateParachute, [0,0,0]];
					waitUntil {sleep 0.1; getPosATL _sack select 2 < 5};
					detach _sack;
					deleteVehicle _crateParachute;
				};
				_log = createVehicle ["Land_WoodenLog_F",(getPosATL _sack),[],0,"CAN_COLLIDE"];
				_sack attachTo [_log, [0,0,0]];
				waitUntil {sleep 0.1; getPos _sack select 2 < 0.1};
				detach _sack;
				deleteVehicle _log;
				_sackPos = getPosATL _sack;
				_sackPos set [2, (getPosATL _sack select 2) max 0 + 0.01];
				_sack setPosATL _sackPos;
				_i = 0;
				while {_i < _missionMoneyBundles} do
				{
					_cash = createVehicle ["Land_Money_F",_sackPos,[],5,"CAN_COLLIDE"];
					_cash setPos ([_sackPos, [[2 + random 3,0,0], random 360] call BIS_fnc_rotateVector2D] call BIS_fnc_vectorAdd);
					_cash setDir random 360;
					_cash setVariable ["cmoney", (_missionMoneyTotal / _missionMoneyBundles), true];
					_cash setVariable ["owner", "world", true];
					_cash call A3W_fnc_setItemCleanup;
					_i = _i + 1;
				};
				_missionSackDeleteDuration = 0;
				if (_missionMoneySmoke) then
				{
					_missionSackDeleteDuration = _missionSackDeleteDuration + _missionMoneySmokeDuration;
					[_sack,_sackPos,_missionMoneySmokeDuration] spawn
					{
						params ["_sack","_sackPos","_missionMoneySmokeDuration"];
						_smokeSignalMoney = createVehicle ["SmokeShellRed_infinite",_sackPos,[],0,"CAN_COLLIDE"];
						_smokeSignalMoney attachTo [_sack, [0,0,0.25]];
						_timer = time + _missionMoneySmokeDuration;
						waitUntil {sleep 0.1; time > _timer};
						deleteVehicle _smokeSignalMoney;
					};
				};
				if (_missionMoneyChemlight) then
				{
					_missionSackDeleteDuration = _missionSackDeleteDuration + _missionMoneyChemlightDuration;
					[_sack,_sackPos,_missionMoneyChemlightDuration] spawn
					{
						params ["_sack","_sackPos","_missionMoneyChemlightDuration"];
						_lightSignalMoney = createVehicle ["Chemlight_red",_sackPos,[],0,"CAN_COLLIDE"];
						_lightSignalMoney attachTo [_sack, [0,0,0.25]];
						_timer = time + _missionMoneyChemlightDuration;
						waitUntil {sleep 0.1; time > _timer};
						deleteVehicle _lightSignalMoney;
					};
				};
				if (_missionSackDeleteDuration isEqualTo 0) then
				{
					deleteVehicle _sack;
				}
				else
				{
					[_sack,_missionSackDeleteDuration] spawn
					{
						params ["_sack","_missionSackDeleteDuration"];
						_timer = time + _missionSackDeleteDuration;
						waitUntil {sleep 0.1; time > _timer};
						deleteVehicle _sack;
					};
				};
			};
		};
	};
	_successHintMessage = _missionSuccessMessage;
};
_this call sideMissionProcessor;