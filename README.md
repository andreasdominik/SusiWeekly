# SusiWeekly - Snips/Rhasspy Skill

Simple skill to proram a weekly schedule for a Snips-like home assistant
(i.e. Rhasspy).     
The skill is written in Julia with the HermesMQTT.jl framework.

### Julia

This skill is (like the entire HermesMQTT.jl framework) written in the
modern programming language Julia (because Julia is faster
then Python and coding is much much easier and much more straight forward).
However "Pythonians" often need some time to get familiar with Julia.

If you are ready for the step forward, start here: https://julialang.org/


## Installation

The skill can be installed from within the Julia REPL with the following
commands, if the HermesMQTT.jl framework is already installed 
and configured:

```julia
using HermesMQTT

install("SusiWeekly")
```

If the Rhasspy server is running (recommended) the installer will
install the skill on the local machine and upload intents and slots
to the Rhasspy server (locally or remote in a server-satellite setup).


## Usage

Basic idea is to program a weekly schedule for a home assistant by defining a weekly *profile* and *actions* for each profile.

Each action is defined by 3 or 4 paramaters in the config.ini file:

+ **command**: the command to be executed as plain text. Each command
            the NLU (natural language understanding) engine is able to
            recognise is valid (such as *"turn on the light in the living room"*).
+ **days**: comma-separated list of days of the week (e.g. `mo, tu, we`).
            The command is executed on these days only.
+ **times**: comma-separated list of times (e.g. `8, 12:10, 18:00`).
            The command is executed at these times on the days defined in `days`.
+ **fuzzy**: the optional fuzzy-line defines the allowed fuzzyness of the 
            time specification in minutes (i.e. if `fuzzy=10` the command
            is executed between 10 minutes earlier or later than the specified 
            time).


## Example

Definiton of a new profile is easy but  requires settings in the configurations 
of the skill *and* the Rhasspy server:

### Wake me up with some music

Assuming that a skill or app is installed that can play music by voice command
(i.e. *"Rhasspy, play the Moolight Sonata in the bedroom"*), a 
profile can be defined that plays wakeup music in the morning:

### 1) profile and action

define the profile `wake_up_music` and the action `play_music` 
  in the config.ini file:

```ini
wake_up_music = play_music

play_music:command = play the Moolight Sonata in the bedroom
play_music:days = mo, tu, we, th, fr
play_music:times = 7:00
play_music:fuzzy = 15
```
This will schedule the music to be played every morning at 7:00 o'clock
plus-minus 15 minutes.

### 2) give the profile a name

In order to make rhasspy know how to call the profile, a
entry must be added to the language section of the ini file
(here  english, but other or several languages can be added; 
if not given, Rhasspy will try to read the name of the profile itself):

```ini
[en]
:wake_up_music = wake up with moonlight sonata
```

### add the slot value `wake_up_music` to the NLU

In order to make the NLU (natural language understanding) engine able 
to understand the new slot value `wake_up_music`, it must be added to the
alternatives of the slot `weekly_profile`. 

This can be done by editing the file `<lang>/slots/weekly_profile` in the
profiles directory of the Rhasspy server 
(e.g. `~home/.config/rhasspy/profiles/en/slots/weekly_profile`) or
by editing the file `profiles/<lang>/slots/weekly_profile` in the
directory of this skill and uploading the file to the Rhasspy server
from the Julia REPL via:

```julia
using HermesMQTT
update_intents("SusiWeekly")
``` 
The file may look like:

```ini
summer:summer
winter:winter
default:default
irrigation:irrigation
(wake up with (music | Beethoven | moonligh sonata)):wake_up_music
```

### program wakeup music

The schedule can now be programmed by voice command:
*Rhasspy, start the programming from tomorrow until the end of the year 
with the profile wake up with Beethoven*.






