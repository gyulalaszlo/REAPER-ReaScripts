--[[
 * ReaScript Name: Render selected tracks individually through master
 * Description: A way to render tracks to master chain.
 * Instructions: Select tracks. Set render settings to source = master tracks. Add incrementation ($tracks wildcard will not work). Run.
 * Author: X-Raym
 * Author URI: http://extremraym.com
 * Repository: GitHub > X-Raym > EEL Scripts for Cockos REAPER
 * Repository URI: https://github.com/X-Raym/REAPER-Scripts
 * File URI:
 * Licence: GPL v3
 * Forum Thread: Render Stems (selected tracks) through master FX?
 * Forum Thread URI: http://forum.cockos.com/showthread.php?p=1652366
 * REAPER: 5.0
 * Extensions: None
 * Version: 1.0
--]]

--[[
 * Changelog:
 * v1.0 (2016-03-16)
	+ Initial Release
--]]


-- USER CONFIG AREA -----------------------------------------------------------

render = true -- true/false: display debug messages in the console

console = true -- display console messages

------------------------------------------------------- END OF USER CONFIG AREA

function main()

	Msg("Set your render settings to source = Master Track, and add the $track wildcard to the output file name.")
	Msg("Auto-render can be deactivated by editing the script.\n")
	Msg("------")
	Msg("Tracks added to render queue:")

	-- LOOP TRHOUGH SELECTED TRACKS
	total = 0
	for i, track in ipairs(init_sel_tracks) do

		reaper.SetOnlyTrackSelected(track)
		reaper.Main_OnCommand(40340, 0) -- Unsolo all tracks
		reaper.Main_OnCommand(40728, 0) -- Solo track
		reaper.Main_OnCommand(41823, 0) -- Add to render queue

		local retval, track_name = reaper.GetSetMediaTrackInfo_String(track, "P_NAME", "new track name", false)

		Msg(track_name)

		total = total + 1

	end

	Msg("\nTotal tracks = " .. total)

	reaper.Main_OnCommand(40340, 0) -- Unsolo all tracks

end


-- UTILITIES -------------------------------------------------------------

-- Display a message in the console for debugging
function Msg(value)
	if console then
		reaper.ShowConsoleMsg(tostring(value) .. "\n")
	end
end


-- UNSELECT ALL TRACKS
function UnselectAllTracks()
	first_track = reaper.GetTrack(0, 0)
	reaper.SetOnlyTrackSelected(first_track)
	reaper.SetTrackSelected(first_track, false)
end

-- SAVE INITIAL TRACKS SELECTION
function SaveSelectedTracks(table)
	for i = 0, reaper.CountSelectedTracks(0)-1 do
		table[i+1] = reaper.GetSelectedTrack(0, i)
	end
end

-- RESTORE INITIAL TRACKS SELECTION
function RestoreSelectedTracks(table)
	UnselectAllTracks()
	for _, track in ipairs(table) do
		reaper.SetTrackSelected(track, true)
	end
end

--------------------------------------------------------- END OF UTILITIES

-- INIT

sel_tracks_count = reaper.CountSelectedTracks(0)

if sel_tracks_count > 0 then

	reaper.Undo_BeginBlock() -- Begining of the undo block. Leave it at the top of your main function.

	reaper.PreventUIRefresh(1)

	init_sel_tracks = {}
	SaveSelectedTracks(init_sel_tracks)

	main() -- Execute your main function

	if render then
		reaper.Main_OnCommand(41207, 0)
	end

	RestoreSelectedTracks(init_sel_tracks)

	reaper.UpdateArrange() -- Update the arrangement (often needed)

	reaper.PreventUIRefresh(-1)

	reaper.Undo_EndBlock("Render selected tracks individually through master", -1) -- End of the undo block. Leave it at the bottom of your main function.

end