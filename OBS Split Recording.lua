-- Global variables
obs = obslua
Enabled = true
Duration = 60
Max_dur = 240
Min_dur = 0.5

-- A function named script_description returns the description shown to
-- the user
function script_description()
	return "<b>OBS Recording Spliter</b><p>Recording Duration value can be between " .. Min_dur .. " - " .. Max_dur .. "</p>"
end

-- A function named script_properties defines the properties that the user
-- can change for the entire script module itself
function script_properties()
  props = obs.obs_properties_create()
  obs.obs_properties_add_bool(props, "enabled", "Enabled")
  obs.obs_properties_add_float(props, "duration", "Recording Duration (Minutes)", Min_dur, Max_dur, 1)
  return props
end

-- A function named script_defaults will be called to set the default settings
function script_defaults(settings)
	obs.obs_data_set_default_bool(settings, "enabled", true)
	obs.obs_data_set_default_double(settings, "duration", 60)
end

-- A function named script_update will be called when settings are changed
function script_update(settings)
	Enabled = obs.obs_data_get_bool(settings, "enabled")
	Duration = obs.obs_data_get_double(settings, "duration")
	
	if not Enabled then
		obs.timer_remove(timer_split_recording)
		obs.timer_remove(timer_restart_recording)
	end
	
	-- Duration can't be zero
	if (Duration == 0) then
		Duration = 60
	end
end

function on_event(event)
	if Enabled then
		if event == obs.OBS_FRONTEND_EVENT_RECORDING_STARTED then
			print("Timer started")
			obs.timer_remove(timer_split_recording)
			obs.timer_remove(timer_restart_recording)
			obs.timer_add(timer_split_recording, Duration * 60000)
		elseif event == obs.OBS_FRONTEND_EVENT_RECORDING_STOPPED then
			print("Timer ended")
			obs.timer_remove(timer_split_recording)
		end
	end
end

function timer_split_recording()
	obs.obs_frontend_recording_stop()
	print("Split")
	obs.timer_add(timer_restart_recording, 1)
end

function timer_restart_recording()
	obs.obs_frontend_recording_start()
end

function script_load(settings)
  obs.obs_frontend_add_event_callback(on_event)
end