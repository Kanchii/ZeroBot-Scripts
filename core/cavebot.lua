-- CaveBot table to manage the cavebot system.
CaveBot = {}

--- Goto to specific label waypoint on cavebot
-- This function is a wrapper around the external function cavebotGoto.
-- Note: this function will not set instantly the waypoint, it will be set on the next tick. If you need to execute this function twice or more, you should use a delay between the calls.
-- On waypoint script, it will kill the script execution after the use of this function.
-- @param label (string) - The waypoint label name
function CaveBot.GoTo(labelName)
    return cavebotGoto(labelName)
end

--- Adds a waypoint to the cavebot system.
-- This function is a wrapper around the external function cavebotAddWaypoint.
-- @param waypointType (number) - The type of waypoint to add. Refer waypointType as Enums.WaypointType
-- @param x (number) - The x coordinate of the waypoint.
-- @param y (number) - The y coordinate of the waypoint.
-- @param z (number) - The z coordinate of the waypoint.
-- @param extraData (string) - The extra data of the waypoint. This parameter is optional and should be used only when waypointType is Label/Goto/Script/Hur Down-Up. For Label/Goto/Script the extraData should be a string, for Hur Down-Up the extraData should be the direction (Enums.Directions).
function CaveBot.addWaypoint(waypointType, x, y, z, extraData)
    if not extraData then
        extraData = waypointType >= Enums.WaypointType.WAYPOINT_TYPE_HUR_UP and waypointType <= Enums.WaypointType.WAYPOINT_TYPE_HUR_DOWN and "0" or ""
    end

    cavebotAddWaypoint(waypointType, x, y, z, extraData)
end

--- Insert a waypoint before specific id on the cavebot system.
-- This function is a wrapper around the external function cavebotInsertWaypoint.
-- @param wpId (number) - The id of the waypoint to insert before.
-- @param waypointType (number) - The type of waypoint to add. Refer waypointType as Enums.WaypointType
-- @param x (number) - The x coordinate of the waypoint.
-- @param y (number) - The y coordinate of the waypoint.
-- @param z (number) - The z coordinate of the waypoint.
function CaveBot.insertWaypoint(wpId, waypointType, x, y, z, extraData)
    cavebotInsertWaypoint(wpId, waypointType, x, y, z, extraData or "")
end

--- Replace a waypoint by specific id on the cavebot system.
-- This function is a wrapper around the external function cavebotReplaceWaypoint.
-- @param wpId (number) - The id of the waypoint to replace.
-- @param waypointType (number) - The type of waypoint to add. Refer waypointType as Enums.WaypointType
-- @param x (number) - The x coordinate of the waypoint.
-- @param y (number) - The y coordinate of the waypoint.
-- @param z (number) - The z coordinate of the waypoint.
function CaveBot.replaceWaypoint(wpId, waypointType, x, y, z, extraData)
    cavebotReplaceWaypoint(wpId, waypointType, x, y, z, extraData or "")
end

--- Delete a waypoint by specific id on the cavebot system.
-- This function is a wrapper around the external function cavebotDeleteWaypoint.
-- @param wpId (number) - The id of the waypoint to delete.
function CaveBot.deleteWaypoint(wpId)
    cavebotDeleteWaypoint(wpId)
end

--- Clear all waypoints on the cavebot system.
-- This function is a wrapper around the external function cavebotClearWaypoints.
function CaveBot.clearWaypoints()
    cavebotClearWaypoints()
end

--- Select a waypoint by specific id on the cavebot system.
-- This function is a wrapper around the external function cavebotSelectWaypoint.
-- Note: this function will not set instantly the waypoint, it will be set on the next tick. If you need to execute this function twice or more, you should use a delay between the calls.
-- On waypoint script, it will kill the script execution after the use of this function.
-- @param wpId (number) - The id of the waypoint to select.
function CaveBot.selectWaypoint(wpId)
    cavebotSelectWaypoint(wpId)
end

--- Get selected waypoint id.
-- This function is a wrapper around the external function cavebotGetSelectedWaypointId.
-- @return (number) - Returns the waypoint id if there's one selected, otherwise returns -1.
function CaveBot.getSelectedWaypointId()
    return cavebotGetSelectedWaypointId()
end

--- Get waypoint type by specific id.
--- This function is a wrapper around the external function cavebotGetWaypointTypeById.
--- @param id (number) - The id of the waypoint to get the type.
--- @return (number) - Returns the waypoint type if the id is valid, otherwise returns -1.
function CaveBot.getWaypointTypeById(id)
    return cavebotGetWaypointTypeById(id)
end

--- Get waypoint data by specific id.
--- This function is a wrapper around the external function cavebotGetWaypointDataById.
--- @param id (number) - The id of the waypoint to get the data.
--- @return (table) - Returns the waypoint data if the id is valid, otherwise nil. Data format: {x = number, y = number, z = number, type = number, data = string}
function CaveBot.getWaypointDataById(id)
    return cavebotGetWaypointDataById(id)
end

--- Set the lure ignore list for the cavebot system.
--- This function is a wrapper around the external function cavebotSetLureIgnoreList.
--- @param list (table) - The list of creatures to ignore.
function CaveBot.setLureIgnoreList(list)
    cavebotSetLureIgnoreList(list)
end

--- Set the safety lure settings for the cavebot system.
--- All parameters below is based on Safety Lure Settings section from CaveBot settings window.
--- This function is a wrapper around the external function cavebotSetSafetyLureSettings.
--- @param nearCreatureDistance (number) - The distance to consider a creature near the player.
--- @param nearCreatureCount (number) - The count of creatures to consider near the player.
--- @param avoidStuckTrapCount (number) - The count of creatures to consider a stuck trap.
function CaveBot.setSafetyLureSettings(nearCreatureDistance, nearCreatureCount, avoidStuckTrapCount)
    cavebotSetSafetyLureSettings(nearCreatureDistance, nearCreatureCount, avoidStuckTrapCount)
end

--- Set the lure settings for the cavebot system.
--- All parameters below is based on Lure Settings section from CaveBot settings window.
--- This function is a wrapper around the external function cavebotSetLureSettings.
--- @param creaturesToRun (number) - The count of creatures to run.
--- @param dynamicLure (boolean) - The flag to enable/disable the dynamic lure.
--- @param skipUnreachableCreatures (boolean) - The flag to skip unreachable creatures.
function CaveBot.setLureSettings(creaturesToRun, dynamicLure, skipUnreachableCreatures)
    cavebotSetLureSettings(creaturesToRun, dynamicLure, skipUnreachableCreatures)
end

--- Set the end lure settings for the cavebot system.
--- All parameters below is based on End Lure Settings section from CaveBot settings window.
--- This function is a wrapper around the external function cavebotSetEndLureSettings.
--- @param creaturesToStop (number) - The count of creatures to stop.
--- @param creaturesToLeave (number) - The count of creatures to leave.
--- @param tryWalkToCenter (boolean) - The flag to try walk to center.
--- @param creaturesToLeaveByHp (boolean) - The flag to leave creatures by hp.
--- @param creaturesToLeaveByHpValue (number) - The value of hp to leave creatures.
--- @param creaturesToLeaveByHpCount (number) - The count of creatures to leave by hp.
--- @param dontLeaveIfHp (boolean) - The flag to dont leave if hp.
--- @param dontLeaveIfHpValue (number) - The value of hp to dont leave.
--- @param dontLeaveIfHpCount (number) - The count of creatures to dont leave.
function CaveBot.setEndLureSettings(creaturesToStop, creaturesToLeave, tryWalkToCenter, creaturesToLeaveByHp, creaturesToLeaveByHpValue, creaturesToLeaveByHpCount, dontLeaveIfHp, dontLeaveIfHpValue, dontLeaveIfHpCount)
    cavebotSetEndLureSettings(creaturesToStop, creaturesToLeave, tryWalkToCenter, creaturesToLeaveByHp, creaturesToLeaveByHpValue, creaturesToLeaveByHpCount, dontLeaveIfHp, dontLeaveIfHpValue, dontLeaveIfHpCount)
end

--- Set the auto recorder settings for the cavebot system.
--- All parameters below is based on Auto Recorder Settings section from CaveBot settings window.
--- This function is a wrapper around the external function cavebotSetAutoRecorderSettings.
--- @param nodeDistance (number) - The distance to add a new node/stand between the last node and the player.
--- @param type (number) - The type of auto recorder. 0 = Stand / 1 = Node.
function CaveBot.setAutoRecorderSettings(nodeDistance, type)
    cavebotSetAutoRecorderSettings(nodeDistance, type)
end

--- Set the node settings for the cavebot system.
--- All parameters below is based on Node Settings section from CaveBot settings window.
--- This function is a wrapper around the external function cavebotSetNodeSettings.
--- @param nodeDistance (number) - The distance to consider a node.
function CaveBot.setNodeSettings(nodeDistance)
    cavebotSetNodeSettings(nodeDistance)
end

--- Set the debug HUD settings for the cavebot system.
--- All parameters below is based on Debug HUD Settings section from CaveBot settings window.
--- This function is a wrapper around the external function cavebotSetDebugHUDSettings.
--- @param debugHUD (boolean) - The flag to enable/disable the debug HUD.
--- @param showPath (boolean) - The flag to show the path.
--- @param showSkippedLureCreatures (boolean) - The flag to show the skipped lure creatures.
function CaveBot.setDebugHUDSettings(debugHUD, showPath, showSkippedLureCreatures)
    cavebotSetDebugHUDSettings(debugHUD, showPath, showSkippedLureCreatures)
end

--- Add a special area to the cavebot system.
--- This function is a wrapper around the external function cavebotAddSpecialArea.
--- If you wanna disable wp range, set fromWp and toWp to 0.
--- @param x (number) - The x coordinate of the special area.
--- @param y (number) - The y coordinate of the special area.
--- @param z (number) - The z coordinate of the special area.
--- @param type (number) - The type of the special area. Refer the value as Enums.SpecialAreaType.
--- @param width (number) - The width of the special area.
--- @param height (number) - The height of the special area.
--- @param fromWp (number) - The start waypoint id of the special area.
--- @param toWp (number) - The end waypoint id of the special area.
--- @return (boolean) - Return true if parameters are valid, otherwise return false
function CaveBot.addSpecialArea(x, y, z, type, width, height, fromWp, toWp)
    return cavebotAddSpecialArea(x, y, z, type, width, height, fromWp, toWp)
end

--- Delete a special area by specific id on the cavebot system.
--- This function is a wrapper around the external function cavebotDeleteSpecialArea.
--- @param id (number) - The id of the special area to delete.
function CaveBot.deleteSpecialArea(id)
    cavebotDeleteSpecialArea(id)
end

--- Clear all special areas on the cavebot system.
--- This function is a wrapper around the external function cavebotClearSpecialAreas.
function CaveBot.clearSpecialAreas()
    cavebotClearSpecialAreas()
end

--- Set the current walk mode for the cavebot system.
--- This function is a wrapper around the external function cavebotSetWalkMode.
--- @param mode (number) - The walk mode to set. Refer the value as Enums.WalkMode.
function CaveBot.setWalkMode(mode)
    cavebotSetWalkMode(mode)
end

--- Sets the walk delay for the cavebot system. Only for arrow keys!
--- This function is a wrapper around the external function cavebotSetWalkDelay.
--- @param delay (number) - The delay to set in milliseconds.
function CaveBot.setWalkDelay(delay)
    cavebotSetWalkDelay(delay)
end

--- Disable player walkthrough for the cavebot system.
--- This function is a wrapper around the external function cavebotDisablePlayerWalkthrough.
--- @param disabled (boolean) - The flag to enable/disable the player walkthrough.
function CaveBot.disablePlayerWalkthrough(disabled)
    cavebotDisablePlayerWalkthrough(disabled)
end

--- Set the teleport ids for the cavebot system. The ids list can be found on CaveBot settings window at [Core Settings] section.
--- This function is a wrapper around the external function cavebotSetCoreTeleportIds.
--- @param ids (table) - The list of teleport ids.
function CaveBot.setCoreTeleportIds(ids)
    cavebotSetCoreTeleportIds(ids)
end

--- Enable auto recorder.
--- This function is a wrapper around the external function cavebotEnableAutoRecorder.
--- @param enabled (boolean) - The flag to enable/disable the auto recorder.
function CaveBot.enableAutoRecorder(enabled)
    cavebotEnableAutoRecorder(enabled)
end

--- Pause the cavebot system for a specific time in milliseconds.
-- This function is a wrapper around the external function cavebotPause.
-- @param milliseconds (number) - The time to pause the cavebot system in milliseconds. If the specified time is 0, the cavebot will resume.
function CaveBot.pause(milliseconds)
    cavebotPause(milliseconds)
end

--- Save all waypoints to a file.
-- This function is a wrapper around the external function cavebotSaveFile.
-- @param file (string) - The file name to save the waypoints. The path is relative to the Documents/ZeroBot directory.
-- @return (boolean) - Return true if the action succeeded, or false if the file name is invalid. Remember: this function will not return the result of file saving.
function CaveBot.saveFile(fileName)
    return cavebotSave(fileName)
end

--- Load all waypoints from a file.
-- This function is a wrapper around the external function cavebotLoadFile.
-- @param file (string) - The file name to load the waypoints. The path is relative to the Documents/ZeroBot directory.
function CaveBot.loadFile(fileName)
    cavebotLoad(fileName)
end
