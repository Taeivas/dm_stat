/*
 * Represents an event.
 *
 * @param {/datum} datum - The datum associated with the event.
 * @param {function} callback - The callback function to be executed.
 * @param {/list[]} callback_args - The arguments to be passed to the callback function.
 * @param {boolean} strict - Determines whether strict mode is enabled.
*/
stat
	event
		parent_type = /datum
		New(datum = src.datum, callback = src.callback, callback_args = src.callback_args, strict = src.strict)
			src.strict = strict
			src.datum = datum
			src.callback = callback
			src.callback_args = callback_args
		var
			strict = FALSE
			datum
			callback
			callback_args
		proc
			Call()
				if(strict)
					call(datum, callback)(arglist(callback_args))
				else
					if(!callback_args)
						call(datum, callback)(arglist(args))
					else
						call(datum, callback)(arglist(args + callback_args))