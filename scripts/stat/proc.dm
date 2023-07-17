/*
 * Executes the recovery process for each vital statistic in the `stat_vital_recovery` array.
 *
 * The `stat_vital_recovery` array is a variable that stores instances of `/stat/vital` objects.
 * Each object represents a vital statistic that requires recovery. This code block checks if the
 * `stat_vital_recovery` array has any elements, and if so, iterates through each element using
 * a for-loop. Within the loop, the `Recovery()` method is called on each vital statistic object
 * to initiate the recovery process.
*/
var/stat_vital_recovery[] = new
proc/stat_vital_recovery_tick()
	#if DM_VERSION < 515
	if(global.stat_vital_recovery.len)
		for(var/stat/vital/v in global.stat_vital_recovery)
			v.Recovery()
	#endif
	#if DM_VERSION >= 515
	if(::stat_vital_recovery.len)
		for(var/stat/vital/v in ::stat_vital_recovery)
			v.Recovery()
	#endif