# List of Events

### LocalPlayerDied
- Fired when the LocalPlayer dies.
- **API set:** client 
- args (in table):
  - `killer_id [number]`: server ped id of the killer
  - `killer_type [string]`: what type of entity killed the player
  - `killer_weapon_hash [number]`: the weapon hash that the killer used to kill the player
  - `killer_in_vehicle [bool]`: whether or not the killer was in a vehicle
  - `killer_vehicle_seat [number]`: the seat number of the killer if they were in a vehicle
  - `killer_vehicle_name [string]`: the name of the vehicle the killer was in if they were in a vehicle
  - `player_pos [vector3]`: the position of the player when they died


### PlayerDied
- Fired when a player dies.
- **API set:** shared
- args (in table):
  - `killer_id [number]`: server ped id of the killer
  - `killer_type [string]`: what type of entity killed the player
  - `killer_weapon_hash [number]`: the weapon hash that the killer used to kill the player
  - `killer_in_vehicle [bool]`: whether or not the killer was in a vehicle
  - `killer_vehicle_seat [number]`: the seat number of the killer if they were in a vehicle
  - `killer_vehicle_name [string]`: the name of the vehicle the killer was in if they were in a vehicle
  - `player_pos [vector3]`: the position of the player when they died
  - `player_id [number]`: the server id of the player who died


### PedSpawned (vanilla)
- Fired when a ped spawns.
- **API set:** client
- args (in table):
  - `ped [Ped]`: Ped instance


### PedSpawned
- Fired when a ped spawns.
- **API set:** server
- args (in table):
  - `ped_net_id [number]`: Ped network id
  - `player [sPlayer]`: the player who sent the event


### PedRespawned
- Fired when a ped respawns.
- **API set:** client
- args (in table):
  - `ped [Ped]`: Ped instance


### PedRespawned
- Fired when a ped respawns.
- **API set:** server
- args (in table):
  - `ped_net_id [number]`: Ped network id
  - `player [sPlayer]`: the player who sent the event


### PedDied
- Fired when a ped dies.
- **API set:** client
- args (in table):
  - `ped [Ped]`: Ped instance


### PedDied
- Fired when a ped dies.
- **API set:** server
- args (in table):
  - `ped_net_id [number]`: Ped network id
  - `player [sPlayer]`: the player who sent the event