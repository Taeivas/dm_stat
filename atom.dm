atom
	proc
		OnStatUpdate(stat/s, old_current)
			. = ..()
			src << json_encode(list(proc = "OnStatUpdate()", args = args))
		OnVitalUpdate(stat/vital/v, old_current_tmp)
			. = ..()
			src << json_encode(list(proc = "OnVitalUpdate()", args = args))