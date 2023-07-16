# BYOND Dream Maker `/stat` Library

The `/stat` library offers a powerful and versatile solution for handling character statistics in your games or simulations. It simplifies the creation and manipulation of statistics like strength, speed, health, and more. It provides robust arithmetic operations, flexible binding/unbinding of statistics, customizable modes for different stats, easy reading of values, and extensibility through operator overloading. Whether you're creating an RPG, strategy game, or a complex simulation, the `/stat `library is the tool you need to manage your character stats effectively and efficiently.

- [BYOND Dream Maker `/stat` Library](#byond-dream-maker-stat-library)
- [Installation](#installation)
    - [Prerequisites:](#prerequisites)
    - [Steps:](#steps)
      - [1. Navigate to your project folder](#1-navigate-to-your-project-folder)
      - [2. Create the `submodules` folder](#2-create-the-submodules-folder)
      - [3. Add the `/stat` library as a submodule](#3-add-the-stat-library-as-a-submodule)
      - [4. Initialize and fetch the submodule](#4-initialize-and-fetch-the-submodule)
- [Usage](#usage)
    - [Statistic Definitions](#statistic-definitions)
    - [Statistic Relationships: Binding and Unbinding](#statistic-relationships-binding-and-unbinding)
    - [Modes of Operation](#modes-of-operation)
    - [Vital Statistics](#vital-statistics)
    - [Reading Statistics](#reading-statistics)
    - [Arithmetic Operations with Statistics](#arithmetic-operations-with-statistics)
  - [Operators](#operators)
    - [`operator""()`](#operator)
    - [`operator+=(stat/s)`](#operatorstats)
    - [`operator-=(stat/s)`](#operator-stats)
    - [`operator*=(stat/s)`, `operator/=(stat/s)`](#operatorstats-operatorstats)
    - [`operator&=(stat/s)`](#operatorstats-1)
    - [`operator|=(stat/s)`](#operatorstats-2)
    - [`operator%=(stat/s)`](#operatorstats-3)
    - [`operator+(stat/s)`, `operator-(stat/s)`, `operator*(stat/s)`, `operator/(stat/s)`, `operator**(stat/s)`](#operatorstats-operator-stats-operatorstats-operatorstats-operatorstats)
  - [Event Handling](#event-handling)
    - [Subscribing to Events](#subscribing-to-events)
    - [Unsubscribing from Events](#unsubscribing-from-events)
    - [Example Usage](#example-usage)
  - [Applying Limits to Statistics](#applying-limits-to-statistics)
    - [Setting Static Limits](#setting-static-limits)
    - [Setting Dynamic Limits](#setting-dynamic-limits)
  - [Tick and Vital Stat Recovery](#tick-and-vital-stat-recovery)


# Installation

This guide provides a step-by-step process to install the `/stat` library as a submodule into your project folder. The submodule will be installed into a folder named "submodules".

### Prerequisites:
- You have Git installed on your system.
- You're familiar with using command line.

### Steps:
#### 1. Navigate to your project folder
Open a terminal (or command prompt) and navigate to your project folder using the `cd` (change directory) command. Replace `<your_project_folder>` with your actual project folder path.
```cmd
cd <your_project_folder>
```
#### 2. Create the `submodules` folder
In your project directory, create a new directory called `submodules` using the `mkdir` command.
```cmd
mkdir submodules
```
#### 3. Add the `/stat` library as a submodule
Navigate into the `submodules` directory and execute the `git submodule add` command with the URL of the `/stat` library. This will create a submodule for the `/stat` library within the `submodules` directory.
```cmd
cd submodules
git submodule add https://github.com/Taeivas/dm_stat
```
#### 4. Initialize and fetch the submodule
If your project was already a git repository before you added the submodule, you'll need to initialize and fetch the submodule with the following commands:
```cmd
git submodule update --init --recursive
```
This command will initialize the local configuration file, fetch all the data from the `/stat` library that you require, and checkout the appropriate commit listed in your superproject.

Now, the `/stat` library is successfully installed as a submodule in your project under the "submodules" folder. You can use it as part of your codebase.

Remember to regularly update the submodule to pull in the latest changes from the `/stat` library using the `git submodule update --remote` command.

# Usage

The statistical system in question is underpinned by two fundamental components: `/stat` and `/stat/vital`. These components serve as the bedrock for establishing various statistical metrics such as strength, stamina, durability, and more.

`/stat` is a component designed to denote basic statistical values. It encompasses a value variable, representing the immediate value of the statistic. It also features a base variable, denoting the foundational value of the statistic prior to the addition of any supplementary elements or calculations.

Conversely, `/stat/vital` is a more dynamic statistical component, extending the functionalities of the standard `/stat`. While it maintains all the functionalities of `/stat`, `/stat/vital `introduces an additional current variable. The current variable signifies the live, or real-time, status of the statistic, providing a snapshot of its current state as opposed to its upper limit or maximum value.

In essence, `/stat` provides a base statistical value, while `/stat/vital` adds another layer of complexity by tracking the statistic's real-time status, allowing for a more nuanced understanding of the statistical metrics at play.

### Statistic Definitions

It is possible to initialize the statistical values in several ways, but we'll go through the fundamental ways. Let us create some statistical values for a character.
```js
// We can by creating a basic statistical template by defining some stats with values for a character.
var
    stat
        size = new ("Size", 5) // The size of the character, value `5`.
        strength = new ("Strength", 3) // The strength of the character, value `3`.
        stamina = new ("Stamina", 2) // The stamina of the character, value `2`.
        finesse = new ("Finesse", 1) // The finesse of the character, value `1`.
```

Now that we have defined the basic statistics for the characters we notice that some are missing, such as speed or defense, let us go ahead and create some of those as well.
```js
// We'll define speed and defense as empty statistics.
var
    stat
        speed = new ("Speed") // The speed of the character, without value - defaults to `0`.
        defense = new ("Defense") // The defense of the character, without value - defaults to `0`.
```

### Statistic Relationships: Binding and Unbinding

After defining your statistics, you can create relationships between them. This process, also known as binding, links different stats together, enabling more complex calculations.
```js
// By using the `&=` operator, you can bind multiple statistics (such as size, strength, and finesse) to another statistic (like speed).
// The result will be a speed value that is the sum of all the bound statistics.
speed &= list(size, strength, finesse)
```

You can also define these relationships individually, not in a list. However, each time a binding operation occurs, the statistic value updates, potentially causing inefficiencies. To bypass this, use the `/stat/var/pause_update` variable and set it to `TRUE`. After binding all desired statistics, re-enable updates and call the `Update()` function.
```js
// Updates everytime a relationship is bound
speed &= size
speed &= strength
speed &= finesse

// Updates only once after all bindings are made
speed.pause_update = TRUE // Pausing updates
speed &= size
speed &= strength
speed &= finesse
speed.pause_update = FALSE // Re-enabling updates
speed.Update() // Manual update
```

There might be occasions where you want to dissolve these relationships. To unbind statistics, use the `|=` operator. This operation mirrors the process of building relationships.
```js
// For instance, you can remove strength from the relationship with speed.
speed |= strength
```

### Modes of Operation

At times, you might want to manipulate your statistics in more specific ways. For instance, consider a `defense` variable that needs to represent the weakest attribute of a character. In such cases, we can employ modes to customize statistic behavior.
```js
// To create a defense statistic that reflects the lowest of certain other stats, use the `STAT_MIN` mode.
// Once the mode is set, bind the desired stats (e.g., stamina, finesse) to 'defense'.
defense.mode = defense.STAT_MIN // Now, 'defense' will always reflect the lowest value among its bound stats.
defense &= list(stamina, finesse)
```

### Vital Statistics

For some attributes, like `health`, which requires tracking of both the current status and maximum value, we can employ `/stat/vital` instead of the basic `/stat`.
```js
// We will initialize the health statistic as a vital and bind it to be the sum of size and stamina.
var
    stat/vital
        health = new
health &= list(size, stamina)
```

### Reading Statistics

Once your statistics are defined and bound as desired, you can easily access their values for game logic, display purposes, or debugging.
```js
// The 'value' variable provides the computed value of any given statistic.
src << health.value

// For '/stat/vital' types, use the 'current' variable to get the current status of that statistic.
src << health.current
```

### Arithmetic Operations with Statistics

This library is designed to facilitate arithmetic operations with statistics, much like you'd handle regular numeric values. To prevent potential issues, it's recommended that the statistic value is placed on the left side of the operation, or directly refer to the `value` variable of the statistic.

In the following example, we perform a subtraction operation between two statistics, `attack` and `defense`. The result of this operation can then be used in further game mechanics, such as calculating `damage`.
```js
var
    stat
        attack = new ("Attack", 10)
        defense = new ("Defense", 5)
    damage = attack - defense // Returns the value `5`
```


## Operators

This library supports the overloading of various operators to streamline the use of statistical values in your code. Here are the definitions and uses for these overloaded operators:

### `operator""()`
This operator returns a string representation of the statistic. It outputs the name of the statistic followed by its value.
```js
src << stat // Outputs "[name]: [value]"
```
### `operator+=(stat/s)`
This operator adds a value `s` to the statistic `base` value. It can accept a numeric value, another statistic, a list of statistics, or a text string.
```js
stat += 5 // Add number to base
stat += other_stat // Add value of other_stat to base
stat += list(stat1, stat2) // Add values of stat1 and stat2 to base
stat += "New Name" // Change name or desc of the stat
```
### `operator-=(stat/s)`
This operator behaves similarly to `operator+=(stat/s)`, but subtracts `s` from `base`.
```js
stat -= 5 // Subtract number from base
stat -= other_stat // Subtract value of other_stat from base
stat -= list(stat1, stat2) // Subtract values of stat1 and stat2 from base
stat -= "New Name" // Reset name or desc of the stat to its initial value
```
### `operator*=(stat/s)`, `operator/=(stat/s)`
These operators behave like the addition and subtraction operators, but instead perform multiplication and division, respectively.
```js
stat *= 2 // Multiply base by number
stat /= other_stat // Divide base by value of other_stat
stat *= list(stat1, stat2) // Multiply base by values of stat1 and stat2
```
### `operator&=(stat/s)`
This operator binds `s` to the statistic. If `s` is a number, it sets base to `s`. If `s` is a statistic, it adds `s` to the contents of the statistic. If `s` is a list, it binds each statistic in `s` to the statistic.
```js
stat &= 5 // Bind number to base
stat &= other_stat // Bind other_stat to stat
stat &= list(stat1, stat2) // Bind stat1 and stat2 to stat
```
### `operator|=(stat/s)`
This operator unbinds `s` from the statistic. If `s` is a statistic, it removes `s` from contents of the statistic. If `s` is a list, it unbinds each statistic in `s` from the statistic.
```js
stat |= other_stat // Unbind other_stat from stat
stat |= list(stat1, stat2) // Unbind stat1 and stat2 from stat
```
### `operator%=(stat/s)`
This operator changes the `multiplier` of the statistic to `s`. It can accept another statistic or a number.
```js
stat %= other_stat // Set multiplier of stat to the value of other_stat
stat %= 2 // Set multiplier of stat to 2
```
### `operator+(stat/s)`, `operator-(stat/s)`, `operator*(stat/s)`, `operator/(stat/s)`, `operator**(stat/s)`
These operators perform the corresponding arithmetic operation between the value of the statistic and `s`. If `s` is a statistic, the operation is performed with the value of `s`. If `s` is a number, the operation is performed with `s`.
```js
var/result = stat + 5 // Add number to value of stat
result = stat - other_stat // Subtract value of other_stat from value of stat
result = stat / 2 // Divide value of stat by number
result = stat ** other_stat // Raise value of stat to the power of the value of other_stat
```

## Event Handling

Event handling is a critical aspect of the `/stat` library. It integrates seamlessly with your current or future ecosystem by providing hooks to specific state changes or updates in your statistics. Here are some of the events you can subscribe to:

- `update`: Triggered every time the statistic undergoes an update.
- `change`: Activated when the `value` of the statistic changes.
- `change:current`: Fired when the `current` value of a statistic changes.

### Subscribing to Events
You can subscribe to these events using the `/stat/proc/On()` function. This function allows you to specify the event, the datum (object), the callback function, and any additional arguments you might need.
```js
/*
event: The event to subscribe to as a string.
datum: The object in context, any `/datum` instance.
callback: The path or name of the function to execute upon triggering the event.
callback_args: A list of additional arguments you want to pass to the callback function.
strict: Boolean flag (default is FALSE). When set to TRUE, it provides the callback function with additional arguments such as the origin `/stat` and the previous `value`.
*/
stat.On(event, datum, callback, callback_args, strict)
```

### Unsubscribing from Events
The process to unsubscribe from an event is similar to subscription. It searches for the event and callbacks that match the parameters you defined and removes them accordingly.
```js
stat.Off(event, datum, callback, callback_args, strict)
```

### Example Usage
Below is an example of defining a callback function, subscribing to a statistic, and modifying the statistic to trigger the event.
```js
// Define callback functions:
// static = FALSE
proc/change_static_false(event, stat/s, old_value, a, b, c)
    src << json_encode(args) // Returns: ["change", "Stat: 11", 10, 1, 2, 3]
// static = TRUE
proc/change_static_true(a, b, c)
    src << json_encode(args) // Returns: [3, 2, 1]

// Define and subscribe to a statistic.
var/stat/stat = new ("Stat", 10)
stat.On("change", null, /proc/change_static_false, list(1, 2, 3))
stat.On("change", null, /proc/change_static_true, list(3, 2, 1), static = TRUE)

// Increment the statistic to trigger the event.
stat += 1
```
This example demonstrates how you can leverage events to keep track of changes in your statistics and execute specific actions in response.

## Applying Limits to Statistics

In many scenarios, it's essential to impose limitations on statistics, whether due to natural constraints or designed restrictions. The `/stat/limit` feature provides the capability to set limits on `base`, `value`, and `current` variables through `base_limit`, `value_limit`, and `current_limit` respectively. This section explains how to implement these limitations.

### Setting Static Limits
In this scenario, we're establishing fixed bounds for our statistic. The statistic, named 'Strength', is created with an initial value of 4. We then set the lower and upper bounds for the base value to 1 and 5, respectively. This means the base value can't go lower than 1 or higher than 5. We also set the overall value limit within the range of 0 to 10, allowing for additional boosts or modifications to alter the statistic within this specified range.
```js
// Create a statistic named 'Strength' with a value of 4 and set base and value limitations.
var/stat/strength = new ("Strength", 4)
strength.base_limit = new (1, 5) // The base value will always be between 1 and 5.
strength.value_limit = new (0, 10) // With boosts or other modifications, the value can range from 0 to 10.
```

### Setting Dynamic Limits
Dynamic limits allow for more flexibility, with the ability to use another statistic as either the lower or upper limit. The setup largely resembles the static definition, but we'll use a different statistic as the upper limit in this example. Here, 'Upper Limit' is defined as a statistic with a value of 5, which is then used as the upper limit for the 'Strength' statistic's base value.
```js
// Define 'Upper Limit' as a statistic and use it as the upper limit for 'Strength'.
var
    stat
        upper_limit = new ("Upper Limit", 5) // Define the 'Upper Limit' statistic.
        strength = new ("Strength", 4) // Define the 'Strength' statistic.
strength.base_limit = new (1, upper_limit) // Set the 'Upper Limit' statistic as the upper base limit for 'Strength'.
strength.value_limit = new (0, 10) // The value of 'Strength' can range from 0 to 10.
```

## Tick and Vital Stat Recovery

To facilitate the automatic recovery of the current value in a `/stat/vital` object, the `/stat/vital/proc/Recovery()` function must be tied into a global updater. This updater function, `stat_vital_recovery_tick()`, should be placed within a running environment where it can consistently trigger at a specified rate.

A suitable place to implement this updater is within the `world/Tick()` procedure, which runs every game tick. This ensures that the `stat_vital_recovery_tick()` function executes routinely, allowing the current value of all vital stats to recover over time.

Here's how you can integrate it:
```js
// A good option to place the updater is to make it run every tick in the `world/Tick()` proc.
world
    Tick()
        . = ..() // Run all other defined procs, it returns the value of the parent proc.
        stat_vital_recovery_tick()
```
This configuration promotes regular updates of current values in `/stat/vital` objects, facilitating their recovery per each game tick.