                Fourmilab Chaos Butterfly User Guide

Fourmilab Chaos Butterfly demonstrates the phenomenon of chaos in 
classical mechanics by implementing a Lorenz system, the mathematical 
system originally developed by Edward Lorenz in 1963 to model 
convection in the Earth's atmosphere.  As Lorenz studied the behaviour 
of the model, simulated on a rudimentary computer system, he discovered 
that even the slightest change in the starting point would result in an 
entirely different evolution of the system with time.  This was the 
first discovery of the mathematical phenomenon of chaos and what has 
come to be called the "butterfly effect": where the beating of the 
wings of a single butterfly in a jungle halfway around the world may 
result in the formation of a hurricane on the other.

Fourmilab Chaos Butterfly lets you create one or more butterflies which
fly through the air in Second Life along the trajectories of the Lorenz
model, demonstrating its chaotic behaviour.  You can sit on a butterfly
and experience the wild ride for itself, and chat commands let you set
any of the parameters of the model and observe how that alters its
behaviour.  You can also wear the butterfly as an avatar accessory,
which lets you fly with it in areas where you do not have permission to
create objects.

The model is fully scriptable with commands supplied in notecards in 
its inventory and scripts may define pop-up menus through which an 
avatar may interact with the model.  A collection of butterfly textures
are included so you can distinguish multiple butterflies from one another
or just choose one you find pleasing.  A Deployer is included, which
makes it easy to hatch as many butterflies as you wish, each of which
will wheel and gyre through the sky of your simulation.

A demonstration of the model and features may be viewed on YouTube at:
    https://www.youtube.com/watch?v=TBA

REZZING CHAOS BUTTERFLY IN-WORLD

To use Fourmilab Double Pendulum, simply rez the object in-world on 
land where you are allowed to create objects (land you own or have 
permission to use, or in a public sandbox that supports scripted 
objects).  The land impact is 1.  You can create as many butterflies as 
you wish, limited only by your parcel's prim capacity.  If you create 
multiple objects in proximity to one another, you may want to assign 
them different chat channels (see the Channel command below) so you can 
control each independently.  You can demonstrate and control many of 
the features of Chaos Butterfly from a system of menus which can be 
launched by the chat command:
    /1993 script run Commander
A demonstration of the model and commands can be run with:
    /1993 script run Demonstration

SITTING ON THE BUTTERFLY

You can sit on the butterfly and gyre and gimble in the wabe as it 
flies by right clicking anywhere on the model except the wooden base 
and selecting “Sit Here” or by simply touching it.  Only one avatar may 
sit on a butterfly at a time, but if you've created multiple 
butterflies, one avatar may sit on each.

WEARING THE BUTTERFLY

If you want to fly with the butterfly in an area where you are not 
allowed to create (“rez”) objects, you can wear it as an avatar 
accessory by selecting it in your inventory and using “Add to outfit” 
or “Attach to spine”.  The butterfly will appear on your back like a 
set of angel wings and you may then have your avatar start to fly, 
activate the butterfly, and fly along with it.  When worn as an avatar 
accessory, the butterfly has no land impact.

CHAT COMMANDS

Fourmilab Chaos Butterfly accepts commands submitted on local chat 
channel 1963 (the year Edward Lorenz published the paper “Deterministic 
nonperiodic flow” in the Journal of the Atmospheric Sciences) and 
responds in local chat. Commands are as follows.  (Most chat commands 
and parameters, except those specifying names from the inventory, may 
be abbreviated to as few as two characters and are insensitive to upper 
and lower case.)

    Access public/group/owner
        Specifies who can send commands to the object.  You can
        restrict it to the owner only, members of the owner's group, or
        open to the general public.  Default access is by owner.

    Boot
        Reset the script.  All settings will be restored to their
        defaults.  If you have changed the chat command channel, this
        will restore it to the default of 1963.

    Channel n
        Set the channel on which the object listens for commands in
        local chat to channel n.  If you subsequently reset the script
        with the “Boot” command or manually, the chat channel will
        revert to the default of 1963.  If you want to permanently
        change the channel, add a Channel command to the Configuration
        script, described below.

    Clear
        Send vertical white space to local chat to separate output when
        debugging.

    Echo text
        Echo the text in local chat.  This allows scripts to send
        messages to those running them to let them know what they're
        doing.

    Help
        Send this notecard to the requester.

    Menu
        These commands allow displaying a custom menu dialogue with
        buttons which, when clicked, cause commands to be executed
        as if entered from chat or a notecard script.

        Menu begin name "Menu text"
            Begins the definition of a menu with the given name.  When
            the menu is displayed, the quoted Menu text will appear at
            the top of the dialogue box.

        Menu button "Label" "Command 1" "Command 2" ...
            Defines a button with the specified label which, when
            clicked, causes the listed commands to be run as if entered
            from chat or submitted by a script.  If the label or
            commands contain spaces, they should be quoted.  Two
            consecutive quote marks may be used to include a quote in
            the label or command.  Due to limitations in Second Life's
            dialogue system, a maximum of 12 buttons may be defined in
            a menu and button labels can contain no more than 24
            characters.  A button with the label "*Timeout*" will not
            be displayed in the menu but its commands will be run if
            the menu times out after one minute without user response.
            The commands defined for a button may include those
            described below as being used only with scripts, such as
            “Script pause” and “Script loop”.

        Menu delete name
            Deletes a previously defined menu with the specified name.

        Menu end
            Completes the definition of a menu started with “Menu
            begin” and subsequent “Menu button” commands.  You may
            define as many menus as you wish, limited only by available
            memory for the script.

        Menu kill
            Terminates listening for clicks in the currently displayed
            menu.  Second Life provides no way to remove a displayed
            menu from the screen, so it continues to be shown until the
            user closes its window.

        Menu list [ name ]
            If no name is specified, lists the names of defined menus.
            If a name is given, lists the buttons of that menu and
            the commands they run when clicked.

        Menu reset
            Resets the menu system, terminating any active menu and
            deleting all previously-defined menus.

        Menu show name [ continue ]
            Display the named menu and begin listening for clicks on
            the buttons it contains.  Normally, displaying a menu from
            a script causes script execution to pause until the user
            clicks a button in the menu or it times out.  If “continue”
            is specified, script execution will continue while the menu
            is displayed.  The “Menu show” command may be used within
            menu button command lists, allowing complex chaining of
            menus and construction of hierarchical menu systems.

    Reset
        Resets the model to the initial conditions when the scipt is
        started.

    Run on/off/time/asynchronous
        Starts or stops the flight of the butterfly in which its 
        location and orientation are updated every time tick (see “Set 
        tick” below).  If a number is specified instead of “on” or 
        “off”, the flight will run for that number of seconds and stop 
        automatically. Execution of commands from a script is suspended 
        while a flight is in progress, so you can use timed Run 
        commands in a script to demonstrate different parameters.  If 
        “asynchronous” is specified (as always, you can abbreviate this 
        to as few as two characters), the flight will be started for an 
        indefinite period but a script that submits the command will 
        not be paused.  This allows building menu systems that permit a 
        user to change parameters while a flight is in progress and see 
        the effects immediately.  When a flight ends, the butterfly
        returns to the location whence it started.

    Script
        These commands control the running of scripts stored in
        notecards in the inventory of the object.  Commands in scripts
        are identical to those entered in local chat (but, of course,
        are not preceded by a slash and channel number).  Blank lines
        and those beginning with a “#” character are treated as
        comments and ignored.

        Script list
            Print a list of scripts in the inventory.  Only notecards
            whose names begin with “Script: ” are listed and may be
            run.

        Script resume
            Resumes a paused script, whether due to an unexpired timed
            pause or a pause until touched or resumed.

        Script run [ Script Name ]
            Run the specified Script Name.  The name must be specified
            exactly as in the inventory, without the leading “Script: ”.
            Scripts may be nested, so the “Script run” command may
            appear within a script.  Entering “Script run” with no
            script name terminates any running script(s).

        Script set name "Value"
            Defines a macro with the given name and value which may be
            used in script and menu commands by specifying the name
            within curly brackets.  Names are case-insensitive, but
            values are case-sensitive and may contain spaces.  For
            example, in a menu you might define a button:
                menu button "Rotate" "rotate {plane} {sign}{ang}" "menu show Rot"
            where the macros can be changed by other buttons in the
            menu, for example:
                menu button "XY" "script set plane xy" "menu show Rot"

        Script set name
            Deletes a macro with the specified name.  Macros remain
            defined until the script processor is reset or they are
            explicitly deleted, so scripts and menus should clean up
            macros they define to avoid memory exhaustion errors.

        Script set *
            Deletes all defined macros.

        Script set
            Lists all defined macros and their values.

            The following commands may be used only within scripts or
            commands defined for Menu buttons.

            Script loop [ n ]
                Begin a loop within the script which will be executed n
                times, or forever if n is omitted.  Loops may be
                nested, and scripts may run other scripts within loops.
                An infinite loop can be terminated by “Script run” with
                no script name or by the “Boot” command.

            Script end
                Marks the end of a “Script loop”.  If the number of
                iterations has been reached, proceeds to the next
                command.  Otherwise, repeats, starting at the top of
                the loop.

            Script pause [ n/touch/region ]
                Pauses execution of the script for n seconds.  If the
                argument is omitted, the script is paused for one
                second.  If “touch” is specified, the script will be
                paused until the object is touched or a “Script resume”
                command is entered from chat.  Specifying “region”
                resumes the script when the object enters a new region,
                which can only occur if you happen to be wearing it as
                an attachment, which is a pretty odd thing to do.

            Script wait n[unit] [ offset[unit] ]
                Pause the script until the start of the next n units of
                time, where unit may be “s”=seconds, “m”=minutes,
                “h“=hours, or ”d”=days, plus the offset time, similarly
                specified.  This can be used in loops to periodically
                run shows at specified intervals.  For example, the
                following script runs a five minute show once an hour
                at 15 minutes after the hour.
                    Script loop
                        Script wait 1h 15m
                        Script run MyHourlyShow
                    Script end

    Set
        Set a variety of parameters.

        Set beta n
        
        Set critical [ perm ]
        
        set DeltaT n

        Set echo on/off
            Controls whether commands entered from local chat or a
            script are echoed to local chat as they are executed.

        Set offset <x, y, z>
            with a default of 0.1.  The rods are assumed to be massless.

        Set path on/off/lines [ permanent/clear ]/width n/colour <r, g, b>
            Controls two methods of plotting the path traced out by the
            butterfly as it flies.  “Set path on” activates the
            dropping of particles by the flying butterfly, leaving a
            trace that persists for around 30 seconds before
            evaporating.  This uses the Second Life “particle system”
            mechanism, which doesn't look all that great but it's
            lightweight and doesn't slow down the simulation.  If you
            specify “Set path lines”, temporary thin cylinder prims
            will be left behind by the butterfly, tracing the
            path.  This draws a very clear path but, as it involves
            creating numerous new objects, can slow the simulation.
            The path objects are automatically cleaned up by the Second
            Life garbage collector after about a minute (the time can
            vary depending on activity and object content of the land
            where the model is installed).  You can explicitly delete
            the paths with “Set path off” or “Set path lines clear”.
            Particle system paths cannot be cleared, but will evaporate
            naturally after you turn off their generation.  If you
            enable path generation with “Set path lines permanent”, the
            objects making up the path will be permanent, not temporary
            prims.  These count against the prim capacity of the land
            at the rate of one land impact per line segment, so this
            adds up quickly.  If you have land with limited capacity,
            you may want to experiment with this mode in a public
            sandbox.  “Set path lines clear” may be used to delete
            permanent path objects.  You can set the size of the path
            drawn with “Set path width” (maximum value for lines is
            0.025 metres), and its colour with “Set path colour”, specifying
            a <r, g, b> triple for a uniform colour or “polychrome” for a
            trail whose colour depends upon its distance from the nearest
            critical point of the Lorenz system (this is the default).
            
        Set rho n

        Set scale n
        
        Set sigma n
        
        Set start min% max%
        
        Set texture [ name ]

        Set tick n
            Sets the time in seconds between animation steps when the
            Run command is active.  For smooth animation, try a setting
            of 0.1 (a tenth of a second) or a little smaller.

        Set trace on/off
            Enable or disable output, sent to the owner on local chat,
            describing operations as they occur.  This is generally
            only of interest to developers.

    Status
        Show status of the object, including settings and memory usage.

DEMONSTRATION AND EXAMPLE SCRIPT NOTECARDS

    The following script notecards are included in the inventory of the
    Chaos Butterflyobject and may be run with the chat command “Script
    run” followed by the name of the script, which may not be
    abbreviated and must be given with capital and lower case letters
    as shown. All of these notecards are full permission so you can use
    them as models for your own development.

    Commander
        Script which defines and displays a series of linked menus that
        provide access to many of the Double Pendulum commands and
        options without requiring use of chat commands.  Illustrates
        how to build an interactive menu system.

    Configuration
        Default configuration script, which simply displays a message
        letting the user know about the Demonstration.

    Demonstration
        This is the standard demonstration script for the object.

CONFIGURATION NOTECARD

When Double Pendulum is initially rezzed or reset with the Boot
command, if there is a notecard in its inventory named “Script:
Configuration”, the commands it contains will be executed as if entered
via local chat (do not specify the chat channel on the script lines).
This allows you to automatically preset preferences as you like.

USING THE BUTTERFLY DEPLOYER

https://en.wikipedia.org/wiki/Commercial_butterfly_breeding
1977
To have fun with SAM evasion, a random SAM Site Deployer is included
This is a cylinder you can place anywhere which listens on channel 75
(from S-75, the Soviet designation for the SAM which NATO calls the
SA-2 Guideline, known for, among other things, shooting down the U-2 in
1960).

It accepts commands as follows:
    deploy n_sites radius t_rad t_alt height distribution
        Place sites where values are as follows, with defaults in
        parentheses:
            n_sites         Number of sites to place
            radius          Maximum distance in X and Y of sites, metres (10)
            t_rad           Threat radius of sites (0.1)
            t_alt           Threat altitude of sites (99)
                            Value of 0 means 4096 metres
            height          Displayed height of threat markers (50)
            distribution    Distribution of sites: (Uniform)
                                Uniform
                                Gaussian    Bell curve around centre
                                Igaussian   Inverse bell curve, sparse at centre

    list
        List all deployed butterflies in the region, with their
        locations.

    remove
        Remove all butterflies previously placed, whether by a single 
        or multiple deploy commands.

In addition the Access, Channel, and Clear utility commands are
accepted as for the rocket.

PERMISSIONS AND THE DEVELOPMENT KIT

Fourmilab Chaos Butterfly is delivered with “full permissions”.  Every 
part of the object, including the scripts, may be copied, modified, and 
transferred subject only to the license below.  If you find a bug and 
fix it, or add a feature, please let me know so I can include it for 
others to use.  The distribution includes a “Development Kit” 
directory, which includes all of the components of the model and 
textures.

The Development Kit directory contains a Logs subdirectory which
includes the development narratives for the project.  If you wonder
“Why does it work that way?” the answer may be there.

Source code for this project is maintained on and available from the
GitHub repository:
    https://github.com/Fourmilab/chaos_butterfly

LICENSE

This product (software, documents, and models) is licensed under a
Creative Commons Attribution-ShareAlike 4.0 International License.
    http://creativecommons.org/licenses/by-sa/4.0/
    https://creativecommons.org/licenses/by-sa/4.0/legalcode
You are free to copy and redistribute this material in any medium or
format, and to remix, transform, and build upon the material for any
purpose, including commercially.  You must give credit, provide a link
to the license, and indicate if changes were made.  If you remix,
transform, or build upon this material, you must distribute your
contributions under the same license as the original.

ACKNOWLEDGEMENTS

The nine vector images of butterflies included as textures “butterfly1” 
through “butterfly9” were licensed from Shutterstock for unlimited use 
on the Web. The source image is:
    https://www.shutterstock.com/image-vector/collection-multicolored-butterflies-vector-illustration-1912569607
    
The image of the Morpho menelaus blue butterfly included as texture
“butterfly10” was based upon the Wikimedia image:
    https://en.wikipedia.org/wiki/File:Morpho_menelaus_huebneri_MHNT_Male.jpg
which is licensed under Creative Commons Attribution-Share Alike 4.0 
International license.

The image from which the “falcon” texture for the Millennium Falcon was
produced is a “Nonprofit Fanproject” by Christian (ChrisGFX) Fröhlich:
    https://www.the-millennium-falcon.com/2018/03/12/done/
which is posted on the Web with no specification of license.
