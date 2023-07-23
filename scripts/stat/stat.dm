/*
 * Represents a statistic with various operations and modes for updating its value.
 *
 * This class provides functionality for managing statistics and performing calculations on them.
 * It includes operations for addition, subtraction, multiplication, division, and exponentiation.
 * The `Update()` method recalculates the current value of the statistic based on its properties and mode.
 * The class also supports event handling for update and change events.
 *
 * Properties:
 * - `name`: The name of the statistic.
 * - `desc`: The description of the statistic.
 * - `mode`: The current mode of the statistic, indicating how calculations are performed.
 * - `mode_round_digit`: The number of digits to round the value to when using the `STAT_ROUND` mode.
 * - `mode_proc`: The procedure to call for custom processing of the value.
 * - `tmp/pause_update`: A temporary flag to pause the update process.
 * - `base`: The base value of the statistic.
 * - `value`: The current calculated value of the statistic.
 * - `stat/multiplier`: The multiplier statistic that affects the value of this statistic.
 * - `stat/limit/base_limit`: The base limit for the statistic's value.
 * - `stat/limit/value_limit`: The limit for the statistic's value.
 * - `contents[]`: An array of statistics that contribute to the value calculation of this statistic.
 * - `locs[]`: An array of statistics that depend on this statistic and need to be updated when it changes.
 * - `events[]`: An array for storing event callbacks for update and change events.
 *
 * Modes:
 * - `STAT_DEFAULT`: Default mode, sums the values of contributing statistics.
 * - `STAT_MIN`: Calculates the minimum value among contributing statistics.
 * - `STAT_MAX`: Calculates the maximum value among contributing statistics.
 * - `STAT_ABS`: Applies the absolute value to the calculated value.
 * - `STAT_FLOOR`: Rounds down the calculated value to the nearest integer.
 * - `STAT_CEIL`: Rounds up the calculated value to the nearest integer.
 * - `STAT_ROUND`: Rounds the calculated value to the specified number of decimal places.
 * - `STAT_PROC`: Applies a custom processing procedure to the calculated value.
 *
 * Methods:
 * - `Update()`: Recalculates the value of the statistic based on its properties and mode.
 * - `On(event, datum, callback, callback_args, strict)`: Attaches an event handler to the specified event.
 * - `Off(event, datum, callback, callback_args)`: Detaches an event handler from the specified event.
 * - `operator""()`: Returns a string representation of the statistic in the format "[name]: [value]".
 * - `operator+=(stat/s)`: Adds a value or statistic to the base value of this statistic.
 * - `operator-=(stat/s)`: Subtracts a value or statistic from the base value of this statistic.
 * - `operator*=(stat/s)`: Multiplies the base value of this statistic by a value or statistic.
 * - `operator/=(stat/s)`: Divides the base value of this statistic by a value or statistic.
 * - `operator&=(stat/s)`: Sets the base value of this statistic to a value or adds a statistic to the contributing statistics.
 * - `operator%=(stat/s)`: Sets the multiplier statistic for this statistic.
 * - `operator|=(stat/s)`: Removes a statistic from the contributing statistics.
 * - `operator+(stat/s)`: Adds a value or statistic to the current value of this statistic.
 * - `operator-(stat/s)`: Subtracts a value or statistic from the current value of this statistic.
 * - `operator*(stat/s)`: Multiplies the current value of this statistic by a value or statistic.
 * - `operator/(stat/s)`: Divides the current value of this statistic by a value or statistic.
 * - `operator**(stat/s)`: Raises the current value of this statistic to the power of a value or statistic.
 */
stat
	New()
		if(base_limit)
			base = base_limit.Clamp(base)
		pause_update = TRUE
		if(multiplier != null)
			if(istype(multiplier, /stat))
				if(!multiplier.locs)
					multiplier.locs = new
				multiplier.locs |= src
		src += args
		pause_update = FALSE
		Update()
	var
		name
		desc

		const
			STAT_DEFAULT = 1
			STAT_MIN = 2
			STAT_MAX = 4
			STAT_ABS = 8
			STAT_FLOOR = 16
			STAT_CEIL = 32
			STAT_ROUND = 64
			STAT_PROC = 128

		mode = STAT_DEFAULT
		mode_round_digit
		mode_proc

		tmp/pause_update = FALSE
		base = 0
		value = 0
		stat
			multiplier
			limit
				base_limit
				value_limit

		contents[]
		locs[]
		events[]
	proc
		Update()
			if(pause_update)
				return FALSE
			. = value
			value = base
			if(contents)
				var/L[] = new
				for(var/stat/s in contents)
					if(mode & STAT_DEFAULT)
						value += s.value
					else if(mode & (STAT_MIN|STAT_MAX))
						L += s.value
				if(mode & STAT_MIN)
					value = min(L)
				else if(mode & STAT_MAX)
					value = max(L)

			if(multiplier)
				if(isnum(multiplier))
					value *= multiplier
				else if(istype(multiplier, /stat))
					value *= multiplier.value

			if(mode & STAT_PROC)
				value = call(mode_proc)(value)

			if(mode & STAT_FLOOR)
				#if DM_VERSION < 515
				value = round(value)
				#else
				value = floor(value)
				#endif
			else if(mode & STAT_CEIL)
				#if DM_VERSION < 515
				value = -round(-value)
				#else
				value = ceil(value)
				#endif
			else if(mode & STAT_ROUND)
				value = round(value, mode_round_digit)

			if(mode & STAT_ABS)
				value = abs(value)

			if(value_limit)
				value = value_limit.Clamp(value)

			if(events && events["update"])
				for(var/stat/event/e in events["update"])
					e.Call("update", src)

			if(. != value)
				if(events && events["change"])
					for(var/stat/event/e in events["change"])
						e.Call("change", src, .)

				if(locs)
					for(var/stat/s in locs)
						s.Update()
				return TRUE
			else
				return FALSE
		On(event, datum, callback, callback_args, strict = FALSE)
			if(!events)
				events = new
			if(!events[event])
				events[event] = new
			events[event] += new /stat/event(datum, callback, callback_args, strict)
		Off(event, datum, callback, callback_args)
			if(events)
				if(events[event])
					for(var/stat/event/e in events[event])
						if(e.datum == datum && e.callback == callback && e.callback_args == callback_args)
							events[event] -= e
					if(!events[event].len)
						events -= event
		#if DM_VERSION < 515
		Stringify()
			return "[name]: [value]"
		#else
		operator""()
			return "[name]: [value]"
		#endif
		operator+=(stat/s)
			if(isnum(s))
				base += s
				if(base_limit)
					base = base_limit.Clamp(base)
				Update()
			else if(istype(s, /stat))
				base += s.value
				if(base_limit)
					base = base_limit.Clamp(base)
				Update()
			else if(istype(s, /list))
				pause_update = TRUE
				for(var/a in s)
					src += a
				pause_update = FALSE
				Update()
			else if(istext(s))
				if(name == initial(name))
					name = s
				else if(desc == initial(desc))
					desc = s
		operator-=(stat/s)
			if(isnum(s))
				base -= s
				if(base_limit)
					base = base_limit.Clamp(base)
				Update()
			else if(istype(s, /stat))
				base -= s.value
				if(base_limit)
					base = base_limit.Clamp(base)
				Update()
			else if(istype(s, /list))
				pause_update = TRUE
				for(var/a in s)
					src -= a
				pause_update = FALSE
				Update()
			else if(istext(s))
				if(name != initial(name))
					name = initial(name)
				else if(desc != initial(desc))
					desc = initial(desc)
		operator*=(stat/s)
			if(isnum(s))
				base *= s
				if(base_limit)
					base = base_limit.Clamp(base)
				Update()
			else if(istype(s, /stat))
				base *= s.value
				if(base_limit)
					base = base_limit.Clamp(base)
				Update()
			else if(istype(s, /list))
				pause_update = TRUE
				for(var/a in s)
					src *= a
				pause_update = FALSE
				Update()
		operator/=(stat/s)
			if(isnum(s))
				base /= s
				if(base_limit)
					base = base_limit.Clamp(base)
				Update()
			else if(istype(s, /stat))
				base /= s.value
				if(base_limit)
					base = base_limit.Clamp(base)
				Update()
			else if(istype(s, /list))
				pause_update = TRUE
				for(var/a in s)
					src /= a
				pause_update = FALSE
				Update()
		operator&=(stat/s)
			if(isnum(s))
				base = s
				if(base_limit)
					base = base_limit.Clamp(base)
				Update()
			else if(istype(s, /stat))
				if(!contents)
					contents = new
				contents += s
				if(!s.locs)
					s.locs = new
				s.locs += src
				Update()
			else if(istype(s, /list))
				pause_update = TRUE
				for(var/a in s)
					src &= a
				pause_update = FALSE
				Update()
		operator|=(stat/s)
			if(istype(s, /stat))
				contents -= s
				if(!contents.len)
					contents = null
				s.locs -= src
				if(!s.locs.len)
					s.locs = null
				Update()
			else if(istype(s, /list))
				pause_update = TRUE
				for(var/a in s)
					src |= a
				pause_update = FALSE
				Update()
		operator%=(stat/s)
			if(istype(multiplier, /stat))
				multiplier.locs -= src
				if(!multiplier.locs.len)
					multiplier.locs = null
			multiplier = s
			if(istype(multiplier, /stat))
				if(!multiplier.locs)
					multiplier.locs = new
				multiplier.locs += src
			Update()
		operator+(stat/s)
			return istype(s, /stat) ? value + s.value : value + s
		operator-(stat/s)
			return istype(s, /stat) ? value - s.value : value - s
		operator*(stat/s)
			return istype(s, /stat) ? value * s.value : value * s
		operator/(stat/s)
			return istype(s, /stat) ? value / s.value : value / s
		operator**(stat/s)
			return istype(s, /stat) ? value ** s.value : value ** s