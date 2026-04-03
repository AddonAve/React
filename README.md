**React** is a Windower addon that reacts to different situations.

## Release Notes

**Version 1.8.0 - Addon Ave modification**
1. Only reacts to targets that are claimed by party or self
2. Added //react [on|off]

**Version 1.6.0.0**
- Added in $ACTORID variable to use in a reaction which is useful for sending helper lua's commands about the actor that performed the action
 
**Version 1.4.0.4**
1. Added in a default "complete" command of "gs c update" 
2. Expanded to react in the instances of Healing or Enhancing Magic
	- In order for this type of processing to occur, you must build a reaction with the Actor of yourself
	- Example: //react add "player" "Protect V" ready "input /equip ring1 'sheltered ring'"

## Features

React can react to the following events
- [actor] begins casting [action]
- [actor] readies [action]
- [actor] finishes casting [action]
- [actor] finishes ready [move]

- Monster 1 hours have no "readying" so you can only react to a "complete".
 
To create an action:
- //react add "actor" "action" ready "reaction" (during ready phase)
- //react add "actor" "action" complete "reaction" (after ready phase)
 
To list actions for an Actor
- //react list "actor"
 
To remove an action
- //react remove "actor" "action"
 
Reactions are job specific and are saved in a file within the React directory called react_[JOB].lua
 
Custom Commands:
- The special reaction verb "turnaround" will simply face same direction as the [actor] in the ready phase
- The special reaction verb "facemob" will simply face the same direction as the [actor] in the complete phase.
- The "runaway" and "runto" parameters would be the yalms to run away from or run close to
	- Default is to run within 2 yalms of target (runto) and 30 yalms away if you don't specify
	- **This will force compliance even if you change your mind. To cancel a "runaway" or "runto" command, use //react stoprun**
 
## Examples

Warder of Courage uses an SP roughly 60 seconds after previous move wears off - so can create a timer based on that.
//react add "Warder of Courage" "Benediction" Complete "timers create \"Next Ready Move:\" 60 down"
//react add "Tyrannotaur" "Mortal Ray" ready "turnaround"
//react add "Tyrannotaur" "Mortal Ray" complete "facemob"
 
Add in MEVA Gear for evading status debuffs:
//react add "Quetzalcoatl" "Cyclone Wing" ready "gs equip sets.meva"
 
Use an item:
//react add "Warder of Courage" "Soul Voice" complete "input /item \"Charm Buffer\" [me]"
 
Healing or Enhancing Magic:
//react add yourplayername "Cure V" ready "gs equip sets.CurePotencyRecieved"
//react add yourplayername "Protect V" ready "gs equip sets.Protect"
//react add yourplayername "Refresh II" ready "gs equip sets.RefreshPotencyRecieved"
//react add yourplayername "Phalanx II" ready "gs equip sets.PhalanxRecieved"
//react add yourplayername "Cursna" ready "gs equip sets.CursnaPotencyRecieved"
 
Pet Reactions:
//react add Onychophora "Psyche Suction" ready "input /pet Heel [me]" 
 
Run a Script:
//react add MobName "action" ready "exec foo.txt"
 
Runaway from a bad WS:
//react add "Glassy Craver" "View Sync" ready "runaway 25"
//react add "Glassy Craver" "View Sync" complete "runto 21"

## Commands

Do not type | when using commands:

List commands: //react help

- //react [on|off] - Enable/Disable
- //react add - Adds a reaction to an ability
- //react list - Lists abilities per target
- //react remove - Removes action/reaction from a target
- //react debugmode - Print to console all moves capable of reacting
- //react chatlog - Show/hide chat log messages
