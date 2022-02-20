stat_limit
	New(min, max)
		if(isnum(min))
			src.min = min
		if(isnum(max))
			src.max = max
	var
		min = 0
		max = 10
stat
	New()
		for(var/a in args)
			src += a
		Update()
	var
		const
			ROUND_DEFAULT = 0
			ROUND_DOWN = 1
			ROUND_UP = 2
		name
		current = 0
		base =  0
		stat
			multiplier
		contents[] = new
		locs[] = new
		round_mode

		stat_limit
			limit
	proc
		ToString()
			. = "[name]: [current]"
		Update()
			. = current
			current = base
			for(var/stat/s in contents)
				current += s.current
			if(multiplier)
				if(isnum(multiplier))
					current *= multiplier
				else if(istype(multiplier, /stat))
					current *= multiplier.current
			if(round_mode != null)
				switch(round_mode)
					if(ROUND_DEFAULT)
						current = round(current, 1)
					if(ROUND_DOWN)
						current = round(current)
					if(ROUND_UP)
						current = -round(-current)
			if(istype(limit, /stat_limit))
				if(isnum(limit.min))
					current = max(limit.min, current)
				if(isnum(limit.max))
					current = min(limit.max, current)
			if(. != current)
				for(var/atom/a in locs)
					a.OnStatUpdate(src, .)
				for(var/stat/s in locs)
					s.Update()
		operator&=(value)
			base = value
			Update()
		operator+=(stat/s)
			if(isnum(s))
				base += s
				Update()
			else if(istype(s, /stat))
				contents += s
				s.locs += src
				Update()
			else if(istype(s, /atom))
				locs += s
			else if(istype(s, /list))
				for(var/a in s)
					src += a
		operator-=(stat/s)
			if(isnum(s))
				base -= s
				Update()
			else if(istype(s, /stat))
				contents -= s
				s.locs -= src
				Update()
			else if(istype(s, /atom))
				locs -= s
			else if(istype(s, /list))
				for(var/a in s)
					src -= a
		operator+(stat/s)
			. = current
			if(istype(s, /stat))
				. += s.current
			else if(isnum(s))
				. += s
		operator-(stat/s)
			. = current
			if(istype(s, /stat))
				. -= s.current
			else if(isnum(s))
				. -= s
	vital
		var
			current_tmp = 0
			auto_adjust = TRUE
			tmp
				recovery = FALSE
			stat
				recovery_rate = 1
			recovery_delay = 60
		New()
			. = ..()
			UpdateVital(current_tmp)
			spawn Recovery()
		Update()
			. = ..()
			if(. != current && auto_adjust)
				var/prev = current_tmp
				current_tmp += (current - .)
				UpdateVital(prev)
		ToString()
			. = "[name]: [current_tmp]/[current]"
		proc
			UpdateVital(prev_current_tmp)
				for(var/atom/a in locs)
					a.OnVitalUpdate(src, prev_current_tmp)
			operator*=(stat/s)
				var/prev = current_tmp
				if(istype(s, /stat))
					current_tmp += s.current
				else if(isnum(s))
					current_tmp += s
				else if(islist(s))
					for(var/a in s)
						src *= a
				if(prev != current_tmp)
					UpdateVital(prev)
				spawn Recovery()
			operator/=(stat/s)
				var/prev = current_tmp
				if(istype(s, /stat))
					current_tmp -= s.current
				else if(isnum(s))
					current_tmp -= s
				else if(islist(s))
					for(var/a in s)
						src /= a
				if(prev != current_tmp)
					UpdateVital(prev)
				spawn Recovery()
			Recovery()
				if(recovery && recovery_rate)
					return
				recovery = TRUE
				while(1)
					sleep(recovery_delay)
					if(current_tmp < current)
						if(istype(recovery_rate, /stat))
							src *= min(current - current_tmp, recovery_rate.current)
						else if(isnum(recovery_rate))
							src *= min(current - current_tmp, recovery_rate)
					if(current_tmp >= current)
						break
				recovery = FALSE