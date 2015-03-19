--[[
 * ReaScript Name: Add point on previous visible armed envelope point position from next point value
 * Description: Take next (from cursor position) point value, and insert a new point with that value under the previous point. Works on selected tracks, with visble and armed envelope.
 * Instructions: Place the cursor anywhere between two points. Execute it.
 * Author: X-Raym
 * Author URl: http://extremraym.com
 * Repository: GitHub > X-Raym > EEL Scripts for Cockos REAPER
 * Repository URl: https://github.com/X-Raym/REAPER-EEL-Scripts
 * File URl: https://github.com/X-Raym/REAPER-EEL-Scripts/scriptName.eel
 * Licence: GPL v3
 * Forum Thread: Script (LUA): Copy points envelopes in time selection and paste them at edit cursor
 * Forum Thread URl: http://forum.cockos.com/showthread.php?p=1497832#post1497832
 * Version: 1.0
 * Version Date: 2015-03-18
 * REAPER: 5.0 pre 18b
 * Extensions: None
 --]]
 
--[[
 * Changelog:
 * v1.0 (2015-03-18)
	+ Initial release
 --]]

--[[ ----- DEBUGGING ====>

local info = debug.getinfo(1,'S');

local full_script_path = info.source

local script_path = full_script_path:sub(2,-5) -- remove "@" and "file extension" from file name

if reaper.GetOS() == "Win64" or reaper.GetOS() == "Win32" then
  package.path = package.path .. ";" .. script_path:match("(.*".."\\"..")") .. "..\\Functions\\?.lua"
else
  package.path = package.path .. ";" .. script_path:match("(.*".."/"..")") .. "../Functions/?.lua"
end

require("X-Raym_Functions - console debug messages")


debug = 1 -- 0 => No console. 1 => Display console messages for debugging.
clean = 1 -- 0 => No console cleaning before every script execution. 1 => Console cleaning before every script execution.

msg_clean()
]]-- <==== DEBUGGING -----

function main() -- local (i, j, item, take, track)

	reaper.Undo_BeginBlock() -- Begining of the undo block. Leave it at the top of your main function.

	-- GET CURSOR POS
	offset = reaper.GetCursorPosition()

	startLoop, endLoop = reaper.GetSet_LoopTimeRange2(0, false, true, 0, 0, false)
	lengthLoop = endLoop - startLoop

		-- LOOP TRHOUGH SELECTED TRACKS
		selected_tracks_count = reaper.CountSelectedTracks(0)
		for i = 0, selected_tracks_count-1  do
			
			-- GET THE TRACK
			track = reaper.GetSelectedTrack(0, i) -- Get selected track i

			-- LOOP THROUGH ENVELOPES
			env_count = reaper.CountTrackEnvelopes(track)
			for j = 0, env_count-1 do

				-- GET THE ENVELOPE
				env = reaper.GetTrackEnvelope(track, j)

				-- IF VISIBLE
				retval, strNeedBig = reaper.GetEnvelopeStateChunk(env, "", true)
				x, y = string.find(strNeedBig, "VIS 1")
				w, z = string.find(strNeedBig, "ARM 1")

				if x ~= nil and w ~= nil then

					-- UNSELECT ALL POINTS
					env_points_count = reaper.CountEnvelopePoints(env)

					for k = 0, env_points_count-1 do 
						reaper.SetEnvelopePoint(env, k, timeInOptional, valueInOptional, shapeInOptional, tensionInOptional, false, true)
					end

					-- IF THERE IS PREVIOUS POINT
					cursor_point = reaper.GetEnvelopePointByTime(env, offset)

					if cursor_point ~= -1 then
	
						--GET POINT VALUE
						retval2, timeOut2, valueOut2, shapeOutOptional2, tensionOutOptional2, selectedOutOptional2 = reaper.GetEnvelopePoint(env, cursor_point)

						-- GET NEXT POINT VALUE
						retval3, timeOut3, valueOut3, shapeOutOptional3, tensionOutOptional3, selectedOutOptional3 = reaper.GetEnvelopePoint(env, cursor_point+1)

						-- IF THERE IS A NEXT POINT
						if retval3 == true then
							--reaper.SetEnvelopePoint(env, cursor_point, timeInOptional, valueOut2, shapeInOptional, tensionInOptional, true, false)
						
							-- SET CURSOR POINT
							reaper.InsertEnvelopePoint(env, timeOut2, valueOut3, 0, 0, false, true)

						end -- ENDIF there is a next point
						
						reaper.Envelope_SortPoints(env)

					end -- ENDIF there is a previous point

				end -- ENFIF visible
				
			end -- ENDLOOP through envelopes

		end -- ENDLOOP through selected tracks

		reaper.Undo_EndBlock("Add point on previous visible armed envelope point position from next point value", 0) -- End of the undo block. Leave it at the bottom of your main function.

end -- end main()

--msg_start() -- Display characters in the console to show you the begining of the script execution.

--[[ reaper.PreventUIRefresh(1) ]]-- Prevent UI refreshing. Uncomment it only if the script works.

main() -- Execute your main function

--[[ reaper.PreventUIRefresh(-1) ]] -- Restore UI Refresh. Uncomment it only if the script works.

reaper.UpdateArrange() -- Update the arrangement (often needed)

--msg_end() -- Display characters in the console to show you the end of the script execution.

-- Update the TCP envelope value at edit cursor position
function HedaRedrawHack()
	reaper.PreventUIRefresh(1)

	track=reaper.GetTrack(0,0)

	trackparam=reaper.GetMediaTrackInfo_Value(track, "I_FOLDERCOMPACT")	
	if trackparam==0 then
		reaper.SetMediaTrackInfo_Value(track, "I_FOLDERCOMPACT", 1)
	else
		reaper.SetMediaTrackInfo_Value(track, "I_FOLDERCOMPACT", 0)
	end
	reaper.SetMediaTrackInfo_Value(track, "I_FOLDERCOMPACT", trackparam)

	reaper.PreventUIRefresh(-1)
	
end

HedaRedrawHack()