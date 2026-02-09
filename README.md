React is a Windower addon that reacts to different situations.

Prior to version 1.4, React only worked with the actor as an NPC (trust or enemy mob). With version 1.4, react has been expanded to react based on Player characters only in the instances of Healing or Enhancing Magic. In order for this type of processing to occur, you must build a reaction with the Actor of yourself. Example: //react add "YOURNAMEHERE" "Protect V" ready "input /equip ring1 'sheltered ring'"
 
At version 1.4.0.4
- Added in a default "complete" command of "gs c update" 

React 1.6.0.0
- Added in $ACTORID variable to use in a reaction. Useful for sending helper lua's commands about the actor that performed the action. Replaces $ACTORID with the ID of the actor.

React 1.7.0  **Addon Ave modification**
- Only reacts to targets that are claimed by self or party
- Added //react on|off

## Features

React can react to the following events
 * [Actor] begins casting [action]
 * [Actor] readies [action]
 * [Actor] finishes casting [action]
 * [Actor] finishes ready [move]

**Note: 1 hours have no 'readying' - so you can only react to a 'Complete'**
 
To create an action:
* //react add "Actor" "Action" Ready "Reaction" -- during readies phase
* //react add "Actor" "Action" Complete "Reaction" -- After Ready phase
 
To list actions for an Actor
* //react list "Actor"
 
To remove an action
* //react remove "Actor" "Action"
 
Reactions are job specific and are saved in a file within the React directory called react_[JOB].lua
 
Custom Commands:
 * The special reaction verb "turnaround" will simply face same direction as the [actor]. Useful for Gaze attacks in 'ready' phase.
 * The special reaction verb "facemob" will simply face the same direction as the [actor]. Used in 'complete' phase.
 * 1.5.0 React added in "runaway" and "runto" verbs.  Parameters would be the yalms to run away from or run close to. Default is to run within 2 yalms of target (runto) and 30 yalms away if you don't specify.
 **Please note this will force compliance even if you change your mind. To cancel a runaway or runto command, issue //react stoprun Highly recommend if you use this - bind a quick key to cancel running.**
 
Examples:
Warder of Courage uses an SP roughly 60 seconds after previous move wears off - so can create a timer based on that.
//react add "Warder of Courage" "Benediction" Complete "timers create \"Next Ready Move:\" 60 down"
//react add "Tyrannotaur" "Mortal Ray" ready "turnaround"
//react add "Tyrannotaur" "Mortal Ray" complete "facemob"
 
Add in MEVA Gear for evading status debuffs:
//react add Quetzalcoatl "Cyclone Wing" ready "gs equip sets.meva"
 
Use an item:
//react add "Warder of Courage" "Soul Voice" complete "input /item \"Charm Buffer\" [me]"
 
Healing or Enhancing Magic:(Remember add your own Character's name when Healing or Enhancing magic is cast on you).
//react add Sammeh "Cure V" ready "gs equip sets.CurePotencyRecieved"
//react add Sammeh "Protect V" ready "gs equip sets.Protect"
//react add Sammeh "Refresh II" ready "gs equip sets.RefreshPotencyRecieved"
//react add Sammeh "Phalanx II" ready "gs equip sets.PhalanxRecieved"
//react add Sammeh "Cursna" ready "gs equip sets.CursnaPotencyRecieved"
 
Pet Reactions:
//react add Onychophora "Psyche Suction" ready "input /pet Heel [me]" 
 
Run a Script:
//react add MobName "Action" ready "exec foo.txt"
 
Runaway from a bad WS:
//react add "Glassy Craver" "View Sync" ready "runaway 25"
//react add "Glassy Craver" "View Sync" complete "runto 21"

## Commands

Do not type | when using commands:

List commands: //react help

- //react on|off - Enable/Disable
- //react add - Adds a reaction to an ability
- //react list - Lists abilities per target
- //react remove - Removes action/reaction from a target
- //react debugmode - Print to console all moves capable of reacting
- //react chatlog - Show/hide chat log messages
