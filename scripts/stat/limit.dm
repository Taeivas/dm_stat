/*
 * Represents a stat limit.
 *
 * The `New()` method initializes the stat with minimum and maximum values.
 * The `Clamp()` method restricts a given value within the stat's limits.
 *
 * @param {var,/stat} min - The minimum value of the stat.
 * @param {var,/stat} max - The maximum value of the stat.
 *
 * @returns {number} - The clamped value within the stat's limits.
*/
stat
	limit
		parent_type = /datum
		New(min = src.min, max = src.max)
			src.min = min
			src.max = max
		var
			stat
				min
				max
		proc
			#if DM_VERSION < 515
			Stringify()
				return "/stat/limit([min], [max])"
			#else
			operator""()
				return "/stat/limit([min], [max])"
			#endif
			Clamp(value)
				if(min != null && max != null)
					return clamp(value, isnum(min) ? min : min.value, isnum(max) ? max : max.value)
				else if(min != null)
					return max(value, isnum(min) ? min : min.value)
				else if(max != null)
					return min(value, isnum(max) ? max : max.value)