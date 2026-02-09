_addon.name = 'React'
_addon.author = 'Sammeh, modified by Addon Ave'
_addon.version = '1.7.0'
_addon.commands = {'react'}

require('actions')
require('chat')
require('logger')
require('pack')
require('sets')
require('strings')
require('tables')
files = require('files')
res = require('resources')

--------------------------------------------------------------------------------
-- Settings
--------------------------------------------------------------------------------

autorun = 0				-- Runtime movement state (DO NOT EDIT)
chatcolor = 2			-- Change default React color
react_enabled = 1		-- 1=On, 0=Off

if windower.ffxi.get_player() then 
self = windower.ffxi.get_player()

custom_reactions_file = files.new('react_'..self.main_job..'.lua')

if custom_reactions_file:exists() then
windower.add_to_chat(2,'React: Loading File: react_'..self.main_job..'.lua')
else
windower.add_to_chat(2,'React: New job detected, Creating file: react_'..self.main_job..'.lua')
custom_reactions = {}
custom_reactions_file:write('return ' .. T(custom_reactions):tovstring())
end
custom_reactions = require('react_'..self.main_job)
end

function addaction(args)
local monster = args[1]
local monster_action = args[2]
local monster_reactiontype = args[3]
if monster_reactiontype:lower() ~= "ready" and monster_reactiontype:lower() ~= "complete" then
windower.add_to_chat(2,"Error: You didn't specify the Action Type as 'Ready' or 'Complete'")
return
end
local monster_reaction = args[4]
if custom_reactions[monster] then
if custom_reactions[monster][monster_action] then
current_ready_reaction = custom_reactions[monster][monster_action].ready_reaction or nil
current_complete_reaction = custom_reactions[monster][monster_action].complete_reaction or nil
if monster_reactiontype:lower() == "ready" then
custom_reactions[monster][monster_action] = {ready_reaction=monster_reaction, complete_reaction=current_complete_reaction}
elseif monster_reactiontype:lower() == "complete" then
custom_reactions[monster][monster_action] = {complete_reaction=monster_reaction, ready_reaction=current_ready_reaction}
end
else 
custom_reactions[monster][monster_action] = {}
if monster_reactiontype:lower() == "ready" then
custom_reactions[monster][monster_action] = {ready_reaction=monster_reaction, complete_reaction=""}
elseif monster_reactiontype:lower() == "complete" then
custom_reactions[monster][monster_action] = {complete_reaction=monster_reaction, ready_reaction=""}
end
end
else 
custom_reactions[monster] = {}
if custom_reactions[monster][monster_action] then
current_ready_reaction = custom_reactions[monster][monster_action].ready_reaction or nil
current_complete_reaction = custom_reactions[monster][monster_action].reaction or nil
if monster_reactiontype:lower() == "ready" then
custom_reactions[monster][monster_action] = {ready_reaction=monster_reaction, complete_reaction=current_complete_reaction}
elseif monster_reactiontype:lower() == "complete" then
custom_reactions[monster][monster_action] = {complete_reaction=monster_reaction, ready_reaction=current_ready_reaction}
end
else 
custom_reactions[monster][monster_action] = {}
if monster_reactiontype:lower() == "ready" then
custom_reactions[monster][monster_action] = {ready_reaction=monster_reaction, complete_reaction=""}
elseif monster_reactiontype:lower() == "complete" then
custom_reactions[monster][monster_action] = {complete_reaction=monster_reaction, ready_reaction=""}
end
end
end
custom_reactions_file:write('return ' .. T(custom_reactions):tovstring())
end

function listaction(args)
local monster = args[1]
if custom_reactions[monster] then
for index,value in pairs(custom_reactions[monster]) do
windower.add_to_chat(2,'Action:'..index..' Readies Reaction:'..value.ready_reaction..' Complete Reaction:'..value.complete_reaction)
end
else
windower.add_to_chat(2,"No Monster found to list actions for:"..monster)
end
end

function removeaction(args)
local monster = args[1]
local monster_action = args[2]
if custom_reactions[monster][monster_action] then
windower.add_to_chat(chatcolor,"Removed Reactions for:"..monster_action)
custom_reactions[monster][monster_action] = nil
else
windower.add_to_chat(chatcolor,"Could not find Action to Remove:"..monster_action)
end
custom_reactions_file:write('return ' .. T(custom_reactions):tovstring())
end

windower.register_event('action', function(act)
-- Global master toggle
if react_enabled == 0 then return end
local actor = windower.ffxi.get_mob_by_id(act.actor_id)		
local self = windower.ffxi.get_player()
local target_count = act.target_count 
local category = act.category  
local param = act.param
local recast = act.recast  
local targets = act.targets
local primarytarget = windower.ffxi.get_mob_by_id(targets[1].id)
local valid_target = act.valid_target

-- Only reacts to targets that are claimed by self or party
if actor and actor.is_npc and actor.name ~= self.name then
local player = windower.ffxi.get_player()
local party_ids = {}
for _, member in pairs(windower.ffxi.get_party()) do
if type(member) == "table" and member.mob and member.mob.id then
party_ids[member.mob.id] = true
end
end

if actor.claim_id == player.id or party_ids[actor.claim_id] then
if debugmode == 1 then
if category == 7 and res.monster_abilities[targets[1].actions[1].param] then
print('Ready Move:', actor.name, res.monster_abilities[targets[1].actions[1].param].en)
elseif category == 8 and res.spells[targets[1].actions[1].param] then
print('Begins Casting', actor.name, res.spells[targets[1].actions[1].param].en, res.skills[res.spells[targets[1].actions[1].param].skill].en)
elseif category == 11 and res.monster_abilities[param] then
print('Completed Ready Move:', actor.name, res.monster_abilities[param].en)
elseif category == 4 and res.spells[param] then
print('Completed Casting', actor.name, res.spells[param].en)
end
end

if category == 7 and targets[1].actions[1].param ~= 0 then
local ability = res.monster_abilities[targets[1].actions[1].param]
if ability then
reaction(actor, category, ability, primarytarget)
end
elseif category == 11 then
local ability = res.monster_abilities[param]
if ability then
reaction(actor, category, ability, primarytarget)
end
elseif category == 8 and targets[1].actions[1].param ~= 0 then
local ability = res.spells[targets[1].actions[1].param]
if ability then
reaction(actor, category, ability, primarytarget)
end
elseif category == 4 then
local ability = res.spells[param]
if ability then
reaction(actor, category, ability, primarytarget)
end
end
end
end
end)

windower.register_event('prerender', function()
-- If disabled, ensure we are not running
if react_enabled == 0 then
    if autorun == 1 then
        windower.ffxi.run(false)
        autorun = 0
    end
    return
end
if autorun == 1 and autorun_target and autorun_distance and autorun_tofrom then 
local t = windower.ffxi.get_mob_by_index(autorun_target.index)
if t.valid_target and (t.status == 1 or t.status == 0) then 
if autorun_tofrom == 2 then -- run away from
if t.distance:sqrt() > autorun_distance then	
windower.ffxi.run(false)
autorun = 0
else
local self_vector = windower.ffxi.get_mob_by_index(windower.ffxi.get_player().index or 0)
local angle = (math.atan2((t.y - self_vector.y), (t.x - self_vector.x))*180/math.pi)*-1
windower.ffxi.run((angle+180):radian())
end
elseif autorun_tofrom == 1 then -- run towards
if t.distance:sqrt() < autorun_distance then	
windower.ffxi.run(false)
autorun = 0
else 
local self_vector = windower.ffxi.get_mob_by_index(windower.ffxi.get_player().index or 0)
local angle = (math.atan2((t.y - self_vector.y), (t.x - self_vector.x))*180/math.pi)*-1
windower.ffxi.run((angle):radian())
end
end
else
windower.add_to_chat(chatcolor,"React: Target no longer valid. Stop running.")
windower.ffxi.run(false)
autorun = 0
end 
end
end)

function reaction(actor,category,ability,primarytarget)
if custom_reactions[actor.name] then 
if custom_reactions[actor.name][ability.en] then
if category == 7 or category == 8 then 
if custom_reactions[actor.name][ability.en].ready_reaction then
if custom_reactions[actor.name][ability.en].ready_reaction:lower() == 'turnaround' then 
turnaround(actor)
if chatlog == 1 then 
windower.add_to_chat(chatcolor,"-- React Action: Turning Around")
end
elseif custom_reactions[actor.name][ability.en].ready_reaction:lower() == 'facemob' then 
facemob(actor)
if chatlog == 1 then 
windower.add_to_chat(chatcolor,"-- React Action: Facing Mob")
end
elseif string.find(custom_reactions[actor.name][ability.en].ready_reaction:lower(), 'runaway') then 
local actionstring = custom_reactions[actor.name][ability.en].ready_reaction:lower()
local run_distance = string.match(actionstring,"%d+")
runaway(actor,math.floor(run_distance))
if chatlog == 1 then 
windower.add_to_chat(chatcolor,"-- React Action: Runaway "..run_distance.." yalms.")
end
elseif string.find(custom_reactions[actor.name][ability.en].ready_reaction:lower(), 'runto') then 
local actionstring = custom_reactions[actor.name][ability.en].ready_reaction:lower()
local run_distance = string.match(actionstring,"%d+")
runto(actor,math.floor(run_distance))
if chatlog == 1 then 
windower.add_to_chat(chatcolor,"-- React Action: Runto "..run_distance.." yalms.")
end
else
currentReaction = parseAction(actor,custom_reactions[actor.name][ability.en].ready_reaction)
windower.send_command(currentReaction)
if chatlog == 1 then 
windower.add_to_chat(chatcolor,"-- React Action: "..custom_reactions[actor.name][ability.en].ready_reaction)
end
end
end
else
if custom_reactions[actor.name][ability.en].complete_reaction then
if custom_reactions[actor.name][ability.en].complete_reaction:lower() == 'turnaround' then 
turnaround(actor)
if chatlog == 1 then 
windower.add_to_chat(chatcolor,"-- React Action: Turning Around")
end
elseif custom_reactions[actor.name][ability.en].complete_reaction:lower() == 'facemob' then 
facemob(actor)
if chatlog == 1 then 
windower.add_to_chat(chatcolor,"-- React Action: Facing")
end
elseif string.find(custom_reactions[actor.name][ability.en].complete_reaction:lower(), 'runaway') then 
local actionstring = custom_reactions[actor.name][ability.en].complete_reaction:lower()
local run_distance = string.match(actionstring,"%d+")
runaway(actor,math.floor(run_distance))
if chatlog == 1 then 
windower.add_to_chat(chatcolor,"-- React Action: Runaway "..run_distance.." yalms.")
end
elseif string.find(custom_reactions[actor.name][ability.en].complete_reaction:lower(), 'runto') then 
local actionstring = custom_reactions[actor.name][ability.en].complete_reaction:lower()
local run_distance = string.match(actionstring,"%d+")
runto(actor,math.floor(run_distance))
if chatlog == 1 then 
windower.add_to_chat(chatcolor,"-- React Action: Runto "..run_distance.." yalms.")
end
elseif custom_reactions[actor.name][ability.en].complete_reaction == '' then
windower.send_command("gs c update")
if chatlog == 1 then 
windower.add_to_chat(chatcolor,"-- React Action: Running Default gs c update")
end
else
currentReaction = parseAction(actor, custom_reactions[actor.name][ability.en].complete_reaction)
windower.send_command(currentReaction)
if chatlog == 1 then 
windower.add_to_chat(chatcolor,"-- React Action: "..custom_reactions[actor.name][ability.en].complete_reaction)
end
end
end
end
end
end
-- Looking for if the target is yourself, and the magic skill is enhancing or healing magic
if primarytarget and res.skills[ability.skill] then
if (primarytarget.name == self.name and (res.skills[ability.skill].en == "Enhancing Magic" or res.skills[ability.skill].en == "Healing Magic")) then
if debugmode == 1 then
print('Primary Target Self, Spell:',ability.en,'Type:',res.skills[ability.skill].en)
end
if custom_reactions[self.name] then
if custom_reactions[self.name][ability.en] then
if category == 7 or category == 8 then
if custom_reactions[self.name][ability.en].ready_reaction then
currentReaction = parseAction(actor,custom_reactions[self.name][ability.en].ready_reaction)
windower.send_command(currentReaction)
if chatlog == 1 then 
windower.add_to_chat(chatcolor,"-- React Action: "..custom_reactions[self.name][ability.en].ready_reaction)
end
end
else
if custom_reactions[self.name][ability.en].complete_reaction then
if custom_reactions[self.name][ability.en].complete_reaction == '' then
windower.send_command("gs c update")
if chatlog == 1 then 
windower.add_to_chat(chatcolor,"-- React Action: Running Default gs c update")
end
else
currentReaction = parseAction(actor,custom_reactions[self.name][ability.en].complete_reaction)
windower.send_command(currentReaction)
if chatlog == 1 then 
windower.add_to_chat(chatcolor,"-- React Action: "..custom_reactions[self.name][ability.en].complete_reaction)
end
end
end
end
end
end
end
end
end

windower.register_event('load', function()	
debugmode = 0
chatlog = 1
end)

function turnaround(actor) 
local target = {}
if actor then 
target = actor
else 
target = windower.ffxi.get_mob_by_index(windower.ffxi.get_player().target_index or 0)
end
local self_vector = windower.ffxi.get_mob_by_index(windower.ffxi.get_player().index or 0)
if target then -- Pleaes note if you target yourself you will face due West
local angle = (math.atan2((target.y - self_vector.y), (target.x - self_vector.x))*180/math.pi)*-1
windower.ffxi.turn((angle+180):radian())
else 
windower.add_to_chat(10,"React: You're not targeting anything to turn around from")
end
end

function runaway(actor,action_distance) 
if windower.ffxi.get_player().target_locked then 
windower.send_command("input /lockon")
end
local target = {}
if actor then 
target = actor
else 
target = windower.ffxi.get_mob_by_index(windower.ffxi.get_player().target_index or 0)
end
local self_vector = windower.ffxi.get_mob_by_index(windower.ffxi.get_player().index or 0)
if target and target.name ~= self_vector.name then 
local angle = (math.atan2((target.y - self_vector.y), (target.x - self_vector.x))*180/math.pi)*-1
windower.ffxi.run((angle+180):radian())
autorun = 1
autorun_target = target
autorun_distance = action_distance
autorun_tofrom = 2
else 
windower.add_to_chat(10,"React: You're not targeting anything to run away from")
end
end

function facemob(actor)
local target = {}
if actor then
target = actor
else 
target = windower.ffxi.get_mob_by_index(windower.ffxi.get_player().target_index or 0)
end
local self_vector = windower.ffxi.get_mob_by_index(windower.ffxi.get_player().index or 0)
if target then -- Please note if you target yourself you will face Due East
local angle = (math.atan2((target.y - self_vector.y), (target.x - self_vector.x))*180/math.pi)*-1
windower.ffxi.turn((angle):radian())
else
windower.add_to_chat(10,"React: You're not targeting anything to face")
end
end

function runto(actor,action_distance)
local target = {}
if actor then
target = actor
else 
target = windower.ffxi.get_mob_by_index(windower.ffxi.get_player().target_index or 0)
end
local self_vector = windower.ffxi.get_mob_by_index(windower.ffxi.get_player().index or 0)
if target and target.name ~= self_vector.name then -- Please note if you target yourself you will run Due East
local angle = (math.atan2((target.y - self_vector.y), (target.x - self_vector.x))*180/math.pi)*-1
windower.ffxi.run((angle):radian())
autorun = 1
autorun_target = target
autorun_distance = action_distance
autorun_tofrom = 1	
else
windower.add_to_chat(10,"React: You're not targeting anything to run to")
end
end

function parseAction(actor,reaction)
local currentAction = string.gsub(reaction, "%$ACTORID", actor.id)
return currentAction
end

--------------------------------------------------------------------------------
-- Commands
--------------------------------------------------------------------------------

windower.register_event('addon command', function(command, ...)
local args = L{...}
local cmd = (command and command:lower()) or ''
if cmd == 'on' then
react_enabled = 1
windower.add_to_chat(chatcolor, "React: Enabled")
return
end

if cmd == 'off' then
react_enabled = 0
if autorun == 1 then
windower.ffxi.run(false)
autorun = 0
end
windower.add_to_chat(chatcolor, "React: Disabled")
return
end

if command:lower() == 'add' then
addaction(args)
end

if command:lower() == 'list' then
listaction(args)
end

if command:lower() == 'chatlog' then
if chatlog == 0 then
chatlog = 1
windower.add_to_chat(chatcolor,"React: Chat log messages On")
else 
chatlog = 0
windower.add_to_chat(chatcolor,"React: Chat log messages Off")
end
end

if command:lower() == 'remove' then
removeaction(args)
end

if command:lower() == 'turnaround' then
turnaround()
end

if command:lower() == 'facemob' then
facemob()
end

if command:lower() == 'runaway' then 
local rundistance = args[1] or 18
runaway(nil,math.floor(rundistance))		
end

if command:lower() == 'runto'  then 
local rundistance = args[1] or 2
runto(nil,math.floor(rundistance))
end

if command:lower() == 'stoprun' then 
windower.ffxi.run(false)
autorun = 0
end

if command:lower() == 'debugmode' then
if debugmode == 0 then
debugmode = 1
windower.add_to_chat(chatcolor,"React: Debug Mode On")
else 
debugmode = 0
windower.add_to_chat(chatcolor,"React: Debug Mode Off")
end
end

if command:lower() == 'help' then
windower.add_to_chat(208, 'React Commands:')
windower.add_to_chat(208, '//react on|off - Enable/Disable')
windower.add_to_chat(208, '//react add - Adds a reaction to an ability')
windower.add_to_chat(208, '//react list - Lists abilities per target')
windower.add_to_chat(208, '//react remove - Removes action/reaction from a target')
windower.add_to_chat(208, '//react debugmode - Print to console all moves capable of reacting')
windower.add_to_chat(208, '//react chatlog - Show/hide chat log messages')
end
end)

--------------------------------------------------------------------------------
-- Job change/Zone change
--------------------------------------------------------------------------------

windower.register_event('job change', function()
windower.send_command('lua r react')    
end)

windower.register_event('zone change', function(new,old)
end)
