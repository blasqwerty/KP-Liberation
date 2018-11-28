/*
    KPLIB_fnc_build_preInit

    File: fn_build_preInit.sqf
    Author: KP Liberation Dev Team - https://github.com/KillahPotatoes
    Date: 2018-10-18
    Last Update: 2018-11-29
    License: GNU General Public License v3.0 - https://www.gnu.org/licenses/gpl-3.0.html

    Description:
        The preInit function defines global variables, adds event handlers and set some vital settings which are used in this module.

    Parameter(s):
        NONE

    Returns:
        Module preInit finished [BOOL]
*/

if (isServer) then {diag_log format ["[KP LIBERATION] [%1] [PRE] [BUILD] Module initializing...", diag_tickTime];};

/*
    ----- Module Globals -----
*/

// Build camera
KPLIB_build_camera = objNull;

KPLIB_buildLogic = locationNull;

// Build camera PFH ticker id
KPLIB_build_ticker = -1;

// Save data
KPLIB_build_saveNamespace = locationNull;

if (isServer) then {
    // Register load event handler
    ["KPLIB_doLoad", {[] call KPLIB_fnc_build_loadData}] call CBA_fnc_addEventHandler;

    // Register save event handler
    ["KPLIB_doSave", {[] call KPLIB_fnc_build_saveData}] call CBA_fnc_addEventHandler;

    ["KPLIB_build_item_built", {
        params ["_object", "_fob"];
        if (_fob isEqualTo "") exitWith {};

        // If fob has no save data, initialize it
        if (isNil {KPLIB_build_saveNamespace getVariable _fob}) then {
            KPLIB_build_saveNamespace setVariable [_fob, []];
        };

        (KPLIB_build_saveNamespace getVariable _fob) pushBackUnique _object;

    }] call CBA_fnc_addEventHandler;
};

if (hasInterface) then {
    // Register build item movement handler
    ["KPLIB_build_item_moved", KPLIB_fnc_build_validatePosition] call CBA_fnc_addEventHandler;

    // Register Build module as FOB building provider
    ["KPLIB_fob_build_requested", {
        params ["_object"];

         [getPos _object, nil, [KPLIB_preset_fobBuilding, 0,0,0], {
             params ["_builtObject"];
             // Build FOB when item placed
             private _fobName = [getPos _builtObject] call KPLIB_fnc_core_buildFob;
             // Emit the built event with FOB and object to assign the object to FOB
             ["KPLIB_build_item_built", [_builtObject, _fobName]] call CBA_fnc_globalEvent;
             // Remove object
             deleteVehicle _builtObject;
         }] call KPLIB_fnc_build_start_single;

    }] call CBA_fnc_addEventHandler;

    player addEventHandler ["Killed", KPLIB_fnc_build_stop];
};

if (isServer) then {diag_log format ["[KP LIBERATION] [%1] [PRE] [BUILD] Module initialized", diag_tickTime];};

true
