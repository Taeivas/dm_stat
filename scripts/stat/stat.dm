stat
	New()
		src += args
	var
		const
			STAT_DEFAULT = 1
			STAT_MIN = 2
			STAT_MAX = 4
			STAT_FLOOR = 8
			STAT_ABS = 16
			STAT_CEIL = 32
			STAT_ROUND = 64
			STAT_FORMULA = 128
		tmp
			pause_stat = FALSE
		name
		desc
		value = 0
		base = 0
		mode = STAT_DEFAULT
		round_digit = 1
		stat
			multiplier
			base_min
			base_max
			value_min
			value_max
		contents[] = new
		locs[] = new
	proc
		Formula(n)
			return n
		Update()
			if(pause_stat)
				return FALSE
			else
				. = value
				base = LimitBase(base)
				value = base
				var/L[] = new
				for(var/stat/s in contents)
					if(mode & STAT_DEFAULT)
						value += mode & STAT_ABS ? abs(s.value) : s.value
					else if(mode & (STAT_MIN | STAT_MAX))
						L += mode & STAT_ABS ? abs(s.value) : s.value

				if(mode & STAT_MIN)
					value = min(L)
				else if(mode & STAT_MAX)
					value = max(L)

				if(multiplier)
					if(isnum(multiplier))
						value *= multiplier
					else if(istype(multiplier, /stat))
						value *= multiplier.value

				if(mode & STAT_FORMULA)
					value = Formula(value)

				if(mode & STAT_FLOOR)
					value = round(value)
				else if(mode & STAT_CEIL)
					value = -round(-value)
				else if(mode & STAT_ROUND)
					value = round(value, round_digit)

				value = LimitValue(value)

				if(. != value)
					if(locs && locs.len)
						for(var/stat/s in locs)
							s.Update()
						for(var/atom/a in locs)
							a.OnUpdateStat(src, ., value)
					return TRUE
				else
					return FALSE
		Set(value)
			if(isnum(value))
				src &= value
				Update()
		LimitBase(base)
			if(base_min != null)
				if(isnum(base_min))
					base = max(base_min, base)
				else if(istype(base_min, /stat))
					base = max(base_min.value, base)
			if(base_max != null)
				if(isnum(base_max))
					base = min(base_max, base)
				else if(istype(base_max, /stat))
					base = min(base_max.value, base)
			return base
		LimitValue(value)
			if(value_min != null)
				if(isnum(value_min))
					value = max(value_min, value)
				else if(istype(value_min, /stat))
					value = max(value_min.value, value)
			if(value_max != null)
				if(isnum(value_max))
					value = min(value_max, value)
				else if(istype(value_max, /stat))
					value = min(value_max.value, value)
			return value
		operator""()
			. = "[name]: [value]"
			if(desc != null)
				. += "\n\t[desc]"
		operator+=(stat/s)
			if(isnum(s))
				base += s
				base = LimitBase(base)
				Update()
			else if(istype(s, /stat))
				base += s.value
				base = LimitBase(base)
				Update()
			else if(istype(s, /atom))
				locs += s
			else if(istext(s))
				if(name == initial(name))
					name = s
				else if(desc == initial(desc))
					desc = s
			else if(islist(s))
				pause_stat = TRUE
				for(var/a in s)
					if(istype(a, /stat))
						src &= a
					else
						src += a
				pause_stat = FALSE
				Update()
		operator-=(stat/s)
			if(isnum(s))
				base -= s
				base = LimitBase(base)
				Update()
			else if(istype(s, /stat))
				base -= s.value
				base = LimitBase(base)
				Update()
			else if(istype(s, /atom))
				locs -= s
			else if(istext(s))
				if(name != initial(name))
					name = initial(name)
				else if(desc != initial(desc))
					desc = initial(desc)
			else if(islist(s))
				pause_stat = TRUE
				for(var/a in s)
					src -= a
				pause_stat = FALSE
				Update()
		operator*=(stat/s)
			if(isnum(s))
				base *= s
				base = LimitBase(base)
				Update()
			else if(istype(s, /stat))
				base *= s.value
				base = LimitBase(base)
				Update()
			else if(islist(s))
				pause_stat = TRUE
				for(var/a in s)
					src *= a
				pause_stat = FALSE
				Update()
		operator/=(stat/s)
			if(isnum(s))
				base /= s
				base = LimitBase(base)
				Update()
			else if(istype(s, /stat))
				base /= s.value
				base = LimitBase(base)
				Update()
			else if(islist(s))
				pause_stat = TRUE
				for(var/a in s)
					src /= a
				pause_stat = FALSE
				Update()
		operator&=(stat/s)
			if(isnum(s))
				base = LimitBase(s)
				Update()
			else if(istype(s, /stat))
				contents += s
				s.locs += src
				Update()
			else if(istype(s, /atom))
				locs += s
			else if(islist(s))
				pause_stat = TRUE
				for(var/a in s)
					src &= a
				pause_stat = FALSE
				Update()
		operator|=(stat/s)
			if(istype(s, /stat))
				contents -= s
				s.locs -= src
				Update()
			else if(istype(s, /atom))
				locs -= s
			else if(islist(s))
				pause_stat = TRUE
				for(var/a in s)
					src |= a
				pause_stat = FALSE
				Update()
		operator+(stat/s)
			if(istype(s, /stat))
				return value + s.value
			else if(isnum(s))
				return value + s
		operator-(stat/s)
			if(istype(s, /stat))
				return value - s.value
			else if(isnum(s))
				return value - s
		operator*(stat/s)
			if(istype(s, /stat))
				return value * s.value
			else if(isnum(s))
				return value * s
		operator/(stat/s)
			if(istype(s, /stat))
				return value / s.value
			else if(isnum(s))
				return value / s
		operator**(stat/s)
			if(istype(s, /stat))
				return value ** s.value
			else if(isnum(s))
				return value ** s