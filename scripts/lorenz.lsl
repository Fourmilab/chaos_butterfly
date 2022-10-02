    /*
                    Fourmilab Lorenz Butterfly

                          by John Walker
    */

    key owner;                          // Owner UUID

    integer commandChannel = 11;/*1963*/        /* Command channel in chat (year Edward
                                           Lorenz published "Deterministic Nonperiodic Flow") */
    integer commandH;                   // Handle for command channel
    integer deployer;                   // Start parameter from deployer
    key whoDat = NULL_KEY;              // Avatar who sent command
    integer restrictAccess = 0;         // Access restriction: 0 none, 1 group, 2 owner
    integer echo = TRUE;                // Echo chat and script commands ?
    integer trace = FALSE;              // Trace operation ?
    integer running = FALSE;            // Are we running?
    float runEndTime;                   // Run end time or -1 if none

    integer attached = FALSE;           // Are we attached to an avatar ?
    key wearer;                         // Key of avatar we're attached to
    vector attachPos;                   // Relative position we're attached
    rotation attachRot =                // Rotation relative to avatar when attached
        < 0, -0.70710678, 0.70710678, 0 >;  /* This is llEuler2Rot(< 0, 0, PI >) *
                                                       llEuler2Rot(< PI_BY_TWO, 0, 0 >),
                                               but we can't use this as a initialiser. */

    float tick = 0.01;                  // Animation step time
    float globalScale = 0.125;          // Lorentz co-ordinates to region scale
    vector regionOffset = < 0, 0, 4 >;  // Offset where we start flying from start position

    integer trails = FALSE;             // Draw trail with lines ?
    integer paths = TRUE;               // Trace path with particle system ?
    integer flPlotPerm = FALSE;         // Use permanent objects for plotted lines ?
    integer linePlotters;               // Number of line plotters in inventory
    integer plotterNo = 0;              // Plotter round-robin selector
    float pathWidth = 0.1;              // Particle path size
    vector pathColour = <1, 0, 0>;      // Colour of path particles and lines
    integer pathPolychrome = TRUE;      // Colour paths based on distance from critical point
    string fuisWid;                     // Encoded constant plot line width

    integer pathChannel = -982449866;   // Channel for communicating with path markers
    string ypres = "W?+:$$";            // It's pronounced "Wipers"
    string kaboom = "n?+:$$";           // Flight termination system access code

    string helpFileName = "Fourmilab Lorenz Butterfly User Guide";

    //  Lorenz attractor parameters

    float lorSigma = 10;                // Prandtl number
    float lorRho = 28;                  // Reynolds number
    float lorBeta = 2.666666;           // 8/3  Layer dimensions
    float lorDt = 0.01;                 // Integration step time

    vector critp1;                      // Critical point 1
    vector critp2;                      // Critical point 2
    vector rcritp1;                     // Critical point 1 in region coords
    vector rcritp2;                     // Critical point 2 in region coords
    float maxExcursion;                 // Maximum excursion from closest critical point

    vector curPoint = < 1, 1, 1 >;      // Current position in Lorenz co-ordinates
    vector regPoint;                    // Current position in region co-ordinates

    vector savePos;                     // Initial region position
    rotation saveRot;                   // Initial rotation

    //  Script processing

    integer scriptActive = FALSE;       // Are we reading from a script ?
    integer scriptSuspend = FALSE;      // Suspend script execution for asynchronous event
    string configScript = "Script: Configuration";

    //  Script Processor messages
    integer LM_SP_INIT = 50;            // Initialise
    integer LM_SP_RESET = 51;           // Reset script
    integer LM_SP_STAT = 52;            // Print status
    integer LM_SP_RUN = 53;             // Add script to queue
    integer LM_SP_GET = 54;             // Request next line from script
    integer LM_SP_INPUT = 55;           // Input line from script
    integer LM_SP_EOF = 56;             // Script input at end of file
    integer LM_SP_READY = 57;           // New script ready
    integer LM_SP_ERROR = 58;           // Requested operation failed
    integer LM_SP_SETTINGS = 59;        // Set operating modes

    //  Command processor messages

    integer LM_CP_COMMAND = 223;        // Process command

    //  Menu Processor messages
//  integer LM_MP_INIT = 270;           // Initialise
    integer LM_MP_RESET = 271;          // Reset script
    integer LM_MP_STAT = 272;           // Print status
    integer LM_MP_SETTINGS = 273;       // Set operating modes
    integer LM_MP_RESUME = 274;         // Resume script after menu selection

    //  Plotter messages
    integer LM_PL_DRAW = 471;           // Draw a line

    //  tawk  --  Send a message to the interacting user in chat

    tawk(string msg) {
        if (whoDat == NULL_KEY) {
            //  No known sender.  Say in nearby chat.
            llSay(PUBLIC_CHANNEL, msg);
        } else {
            /*  While debugging, when speaking to the owner, use llOwnerSay()
                rather than llRegionSayTo() to avoid the risk of a runaway
                blithering loop triggering the gag which can only be removed
                by a region restart.  */
            if (owner == whoDat) {
                llOwnerSay(msg);
            } else {
                llRegionSayTo(whoDat, PUBLIC_CHANNEL, msg);
            }
        }
    }

    //  checkAccess  --  Check if user has permission to send commands

    integer checkAccess(key id) {
        return (restrictAccess == 0) ||
               ((restrictAccess == 1) && llSameGroup(id)) ||
               (id == llGetOwner());
    }

    //  sendSettings  --  Send settings to other scripts

    sendSettings() {
        llMessageLinked(LINK_THIS, LM_SP_SETTINGS,
            llList2CSV([ trace, echo ]), whoDat);
        llMessageLinked(LINK_THIS, LM_MP_SETTINGS,
            llList2CSV([ trace, echo ]), whoDat);
    }

    /*  scriptResume  --  Resume script execution when asynchronous
                          command completes.  */

    scriptResume() {
        if (scriptActive) {
            if (scriptSuspend) {
                scriptSuspend = FALSE;
                llMessageLinked(LINK_THIS, LM_SP_GET, "", NULL_KEY);
                if (trace) {
                    tawk("Script resumed.");
                }
            }
        }
    }

    /*  fixArgs  --  Transform command arguments into canonical form.
                     All white space within vector and rotation brackets
                     is elided so they will be parsed as single arguments.  */

    string fixArgs(string cmd) {
        cmd = llStringTrim(cmd, STRING_TRIM);
        integer l = llStringLength(cmd);
        integer inbrack = FALSE;
        integer i;
        string fcmd = "";

        for (i = 0; i < l; i++) {
            string c = llGetSubString(cmd, i, i);
            if (inbrack && (c == ">")) {
                inbrack = FALSE;
            }
            if (c == "<") {
                inbrack = TRUE;
            }
            if (!((c == " ") && inbrack)) {
                fcmd += c;
            }
        }
        return fcmd;
    }

    //  abbrP  --  Test if string matches abbreviation

    integer abbrP(string str, string abbr) {
        return abbr == llGetSubString(str, 0, llStringLength(abbr) - 1);
    }

    //  flIsDigit  --  Is the first character of this string a digit ?

    integer flIsDigit(string s) {
        integer codepos = llOrd(s, 0);
        return (codepos >= 48) && (codepos <= 57);
    }

    //  onOff  --  Parse an on/off parameter

    integer onOff(string param) {
        if (abbrP(param, "on")) {
            return TRUE;
        } else if (abbrP(param, "of")) {
            return FALSE;
        } else {
            tawk("Error: please specify on or off.");
            return -1;
        }
    }

    //  eOnOff  -- Edit an on/off parameter

    string eOnOff(integer p) {
        if (p) {
            return "on";
        }
        return "off";
    }

    /*  hsv_to_rgb  --  Convert HSV colour values stored in a vector
                        (H = x, S = y, V = z) to RGB (R = x, G = y, B = z).
                        The Hue is specified as a number from 0 to 1
                        representing the colour wheel angle from 0 to 360
                        degrees, while saturation and value are given as
                        numbers from 0 to 1.  */

    vector hsv_to_rgb(vector hsv) {
        float h = hsv.x;
        float s = hsv.y;
        float v = hsv.z;

        if (s == 0) {
            return < v, v, v >;             // Grey scale
        }

        if (h >= 1) {
            h = 0;
        }
        h *= 6;
        integer i = (integer) llFloor(h);
        float f = h - i;
        float p = v * (1 - s);
        float q = v * (1 - (s * f));
        float t = v * (1 - (s * (1 - f)));
        if (i == 0) {
            return < v, t, p >;
        } else if (i == 1) {
            return < q, v, p >;
        } else if (i == 2) {
            return <p, v, t >;
        } else if (i == 3) {
            return < p, q, v >;
        } else if (i == 4) {
            return < t, p, v >;
        } else if (i == 5) {
            return < v, p, q >;
        }
llOwnerSay("Blooie!  " + (string) hsv);
        return < 0, 0, 0 >;
    }

    /*  fuis  --  Encode floating point number as base64 string

        The fuis function encodes its floating point argument as a six
        character string encoded as base64.  This version is modified
        from the original in the LSL Library.  By ignoring the
        distinction between +0 and -0, this version runs almost three
        times faster than the original.  While this does not preserve
        floating point numbers bit-for-bit, it doesn't make any
        difference in our calculations.
    */

    string fuis(float a) {
        /*  Test for negative number, ignoring the difference between
            +0 and -0.  While this does not preserve floating point
            numbers bit-for-bit, it doesn't make any difference in
            our calculations and is almost three times faster than
            the original code above.  */
        integer b = 0;
        if (a < 0) {
            b = 0x80000000;
        }

        if (a) {        // Is it greater than or less than zero ?
            //  Denormalized range check and last stride of normalized range
            if ((a = llFabs(a)) < 2.3509887016445750159374730744445e-38) {
                // Math overlaps; saves CPU time
                b = b | (integer) (a / 1.4012984643248170709237295832899e-45);
            //  We never need to transmit infinity, so save the time testing for it.
            // } else if (a > 3.4028234663852885981170418348452e+38) { // Round up to infinity
            //     b = b | 0x7F800000;                  // Positive or negative infinity
            } else if (a > 1.4012984643248170709237295832899e-45) { // It should at this point, except if it's NaN
                integer c = ~-llFloor(llLog(a) * 1.4426950408889634073599246810019);
                //  Extremes will error towards extremes. The following corrects it
                b = b | (0x7FFFFF & (integer) (a * (0x1000000 >> c))) |
                        ((126 + (c = ((integer) a - (3 <= (a *= llPow(2, -c))))) + c) * 0x800000);
                //  The previous requires a lot of unwinding to understand
            } else {
                //  NaN time!  We have no way to tell NaNs apart so pick one arbitrarily
                b = b | 0x7FC00000;
            }
        }
        return llGetSubString(llIntegerToBase64(b), 0, 5);
    }

    /*  fv --  Encode vector as base64 string}

        The fv function encodes the three components of a vector as
        consecutive fuis base64 strings.  */

    string fv(vector v) {
        return fuis(v.x) + fuis(v.y) + fuis(v.z);
    }

    /*  flRotBetween  --  Re-implementation of llRotBetween() which
                          actually works.

                          Written by Moon Metty, optimized by Strife Onizuka.
                          This version keeps the axis in the XY-plane, in the
                          case of anti-parallel vectors (unlike the current
                          LL implementation).  -- Moon Metty  */

    rotation flRotBetween(vector a, vector b) {
        //  Product of lengths of argument vectors
        float aabb = llSqrt((a * a) * (b * b));
        if (aabb != 0) {
            //  Normalised dot product of arguments (cosine of angle between)
            float ab = (a * b) / aabb;
            //  Normalised cross product of arguments
            vector c = < (a.y * b.z - a.z * b.y) / aabb,
                         (a.z * b.x - a.x * b.z) / aabb,
                         (a.x * b.y - a.y * b.x) / aabb >;
            //  Squared of length of the normalised cross product (sine of angle between)
            float cc = c * c;
            //  Test for parallel or anti-parallel arguments
            if (cc != 0) {
                //  Not (anti)parallel
                float s;
                if (ab > -0.707107) {
                    //  Use cosine to compute s element of quartenion
                    s = 1 + ab;
                } else {
                    //  Use sine to compute s element of quarternion
                    s = cc / (1 + llSqrt(1 - cc)); // use the sine to adjust the s-element
                }
                float m = llSqrt(cc + s * s); // the magnitude of the quaternion
                return <c.x / m, c.y / m, c.z / m, s / m>; // return the normalized quaternion
            }
            if (ab > 0) {
                //  Arguments are parallel or anti-parallel
                return ZERO_ROTATION;
            }
            //  Length of first argument projected onto the X-Y plane
            float m = llSqrt(a.x * a.x + a.y * a.y);
            if (m != 0) {
                /*  Arguments are not both parallel to the X-Y plane:
                    rotate around an axis in the X-Y plane.  */
                return <a.y / m, -a.x / m, 0, 0>; // return a rotation with the axis in the X-Y plane
            }
            /*  Otherwise, both arguments are parallel to the Z axis.
                Rotate around the X axis.  */
            return <1, 0, 0, 0>;
        }
        //  Arguments are too small: return zero rotation
        return ZERO_ROTATION;
    }

    //  attachMe  --  Handle attachment to avatar

    attachMe(key who) {
        wearer = whoDat = who;
        attached = TRUE;
        llSetRot(attachRot);
        attachPos = llGetLocalPos();
//tawk("Attached at " + (string) attachPos);
    }

    //  pathSetColour  --  Get colour of path at current point

    vector pathSetColour() {
        if (pathPolychrome) {
            float xy = llSqrt(lorBeta * (lorRho - 1));
            float z = lorRho - 1;
            vector cp1 = < xy, xy, z >;
            vector cp2 = < -xy, -xy, z >;
            float dp1 = llVecDist(curPoint, cp1);
            float dp2 = llVecDist(curPoint, cp2);
            if (dp2 < dp1) {
                dp1 = dp2;
            }
            if (dp1 > maxExcursion) {
                dp1 = maxExcursion;
            }
            return hsv_to_rgb(< dp1 / maxExcursion, 1, 1 >);
            }
        return pathColour;
    }

    //  drawPaths  --  Enable or disable particle system paths

    drawPaths() {
        if (paths && running) {
            llLinkParticleSystem(LINK_THIS,
                [ PSYS_PART_FLAGS, PSYS_PART_EMISSIVE_MASK,
                  PSYS_SRC_PATTERN, PSYS_SRC_PATTERN_DROP,
                  PSYS_PART_START_SCALE, <1, 1, 1> * pathWidth,
                  PSYS_PART_START_COLOR, pathSetColour(),
                  PSYS_PART_START_ALPHA, 1,
                  PSYS_PART_END_ALPHA, 1,
                  PSYS_PART_MAX_AGE, 30.0,
                  PSYS_SRC_BURST_PART_COUNT, 2048,
                  PSYS_SRC_BURST_RATE, 0.0 ]);
        } else {
            llLinkParticleSystem(LINK_THIS, [ ]);
        }
    }

    //  plotLine  --  Plot a line between two points in space

    plotLine(vector from, vector to, vector colour,
             string width, integer perm) {
        llMessageLinked(LINK_THIS, LM_PL_DRAW,
            fv(from) + fv(to) + fv(colour) + width +
                llChar(48 + perm) + (string) (plotterNo + 1),
            whoDat);
        plotterNo = (plotterNo + 1) % linePlotters;
    }

    //  drawGnomon  --  Draw axes gnomon at specified region co-ordinates

    drawGnomon(vector origin, float markSize, float armWid, integer perm) {
        string fwid = fuis(armWid);

        plotLine(origin + <-markSize, 0, 0>,
                 origin + <markSize, 0, 0>, <1, 0, 0>, fwid, perm);
        plotLine(origin + <0, -markSize, 0>,
                 origin + <0, markSize, 0>, <0, 1, 0>, fwid, perm);
        plotLine(origin + <0, 0, -markSize>,
                 origin + <0, 0, markSize>, <0, 0, 1>, fwid, perm);
    }

    //  clearPaths  --  Delete any path tracing objects

    clearPaths() {
        llRegionSay(pathChannel, llList2Json(JSON_ARRAY, [ ypres ]));
    }

    //  ratParam  --  Parse a float or rational parameter, with default

    float ratParam(string s, float defval) {
        float v = defval;
        if (s != "") {
            integer p;
            if ((p = llSubStringIndex(s, "/")) > 0) {
                v = ((float) llGetSubString(s, 0, p - 1)) /
                    ((float) llGetSubString(s, p + 1, -1));
            } else {
                v = (float) s;
            }
        }
        return v;
    }

    //  processCommand  --  Process a command

    list args;              // Argument list
    integer argn;           // Argument list length

    integer processCommand(key id, string message, integer fromScript) {

        if (!checkAccess(id)) {
            llRegionSayTo(id, PUBLIC_CHANNEL,
                "You do not have permission to control this object.");
            return FALSE;
        }

        whoDat = id;            // Direct chat output to sender of command

        /*  If echo is enabled, echo command to sender unless
            prefixed with "@".  The command is prefixed with ">>"
            if entered from chat or "++" if from a script.  */

        integer echoCmd = TRUE;
        if (llGetSubString(llStringTrim(message, STRING_TRIM_HEAD), 0, 0) == "@") {
            echoCmd = FALSE;
            message = llGetSubString(llStringTrim(message, STRING_TRIM_HEAD), 1, -1);
        }
        if (echo && echoCmd) {
            string prefix = ">> /" + (string) commandChannel + " ";
            if (fromScript == TRUE) {
                prefix = "++ ";
            } else if (fromScript == 2) {
                prefix = "== ";
            } else if (fromScript == 3) {
                prefix = "<< ";
            }
            tawk(prefix + message);                 // Echo command to sender
        }

        string lmessage = fixArgs(llToLower(message));
        args = llParseString2List(lmessage, [ " " ], []);    // Command and arguments
        argn = llGetListLength(args);               // Number of arguments
        string command = llList2String(args, 0);    // The command
        string sparam = llList2String(args, 1);     // First argument, for convenience

        //  Access public/group/owner   Restrict chat command access

        if (abbrP(command, "ac")) {
            string who = sparam;

            if (abbrP(who, "p")) {          // Public
                restrictAccess = 0;
            } else if (abbrP(who, "g")) {   // Group
                restrictAccess = 1;
            } else if (abbrP(who, "o")) {   // Owner
                restrictAccess = 2;
            } else {
                tawk("Unknown access restriction \"" + who +
                    "\".  Valid: public, group, owner.\n");
                return FALSE;
            }

        //  Boot                    Reset the script to initial settings

        } else if (abbrP(command, "bo")) {
            llMessageLinked(LINK_THIS, LM_MP_RESET, "", whoDat);
            llMessageLinked(LINK_THIS, LM_SP_RESET, "", whoDat);
            llSleep(0.25);
            llResetScript();

        /*  Channel n               Change command channel.  Note that
                                    the channel change is lost on a
                                    script reset.  */

        } else if (abbrP(command, "ch")) {
            integer newch = (integer) sparam;
            if ((newch < 2)) {
                tawk("Invalid channel " + (string) newch + ".");
                return FALSE;
            } else {
                llListenRemove(commandH);
                commandChannel = newch;
                commandH = llListen(commandChannel, "", NULL_KEY, "");
                tawk("Listening on /" + (string) commandChannel);
            }

        //  Clear                   Clear chat for debugging

        } else if (abbrP(command, "cl")) {
            tawk("\n\n\n\n\n\n\n\n\n\n\n\n\n");

        //  Echo text               Send text to sender

        } else if (abbrP(command, "ec")) {
            integer dindex = llSubStringIndex(lmessage, command);
            integer doff = llSubStringIndex(llGetSubString(lmessage, dindex, -1), " ");
            string emsg = " ";
            if (doff >= 0) {
                emsg = llStringTrim(llGetSubString(message, dindex + doff + 1, -1),
                            STRING_TRIM_TAIL);
            }
            tawk(emsg);

        //  Help                    Give help information

        } else if (abbrP(command, "he")) {
            llGiveInventory(id, helpFileName);      // Give requester the User Guide notecard

        //  Kaboom                  Flight termination system activate

        } else if ((command == kaboom) && (sparam == kaboom)) {
            llDie();

        //  Run on/off/time/async   Start / stop simulation

        } else if (abbrP(command, "ru")) {
            integer sync = TRUE;
            runEndTime = -1;
            if (argn >= 2) {
                if (flIsDigit(sparam) >= 0) {
                    runEndTime = llGetTime() + ((float) sparam);
                    sparam = "on";
                } else if (abbrP(sparam, "as")) {
                    sync = FALSE;
                    sparam = "on";
                }
                running = onOff(sparam);
            } else {
                running = !running;
            }
            if (running) {
                //  Run on
                if (attached) {
                    if (llGetAgentInfo(wearer) & AGENT_FLYING) {
                        list pr = llGetObjectDetails(llGetOwnerKey(llGetKey()),
                            [ OBJECT_POS, OBJECT_ROT ]);
                        savePos = llList2Vector(pr, 0);
                        saveRot = llList2Rot(pr, 1);
                    } else {
                        tawk("Please start flying before Run.");
                        running = FALSE;
                        return FALSE;
                    }
                } else {
                    savePos = llGetPos();
                    saveRot = llGetRot();
                }
                updateScale();
                regPoint = <-1, -1, -1>;
                curPoint = critp1 +
                    (llVecNorm(critp2 - critp1) *
                        (llVecDist(critp1, critp2) / (5 + llFrand(1))));
                llSetTimerEvent(tick);
                scriptSuspend = sync;
            } else {
                //  Run off
                llSetTimerEvent(0);
                running = FALSE;
                drawPaths();
                if (attached) {
                    llMoveToTarget(savePos, 0.05);
                    llSetRot(attachRot);
                    llSleep(0.25);
                    llStopMoveToTarget();
                } else {
                    llSetPos(savePos);
                    llSetRot(saveRot);
                }
                scriptResume();
            }

        //  Set                     Set parameter

        } else if (abbrP(command, "se")) {
            string svalue = llList2String(args, 2);

            //  Set beta n

            if (abbrP(sparam, "be")) {
                lorBeta = ratParam(svalue, 2.666666);
                updateScale();

            //  Set crit [ perm ]

            } else if (abbrP(sparam, "cr")) {
                if (!running) {
                    tawk("Must be running to Set critical.");
                    return FALSE;
                }
                integer perm = abbrP(svalue, "pe");
                float markSize = 0.1;
                /*  Compute critical points in Lorenz co-ordinates and
                    establish scaling to region co-ordinates.  */
                updateScale();
                drawGnomon(rcritp1, markSize, 0.015, perm);
                drawGnomon(rcritp2, markSize, 0.015, perm);

            //  Set deltaT n

            } else if (abbrP(sparam, "de")) {
                lorDt = ratParam(svalue, 0.01);

            //  Set echo on/off

            } else if (abbrP(sparam, "ec")) {
                echo = onOff(svalue);
                sendSettings();

            //  Set offset <x, y, z>

            } else if (abbrP(sparam, "of")) {
                regionOffset = (vector) svalue;

            //  Set path on/off/lines [ permanent/clear ]/width n/colour <r,g,b>

            } else if (abbrP(sparam, "pa")) {
                if (abbrP(svalue, "li")) {
                    //  Set path lines
                    string larg = llList2String(args, 3);
                    if (argn >= 4) {
                        //  Set path lines clear
                        if (abbrP(larg, "cl")) {
                            clearPaths();
                            return TRUE;
                        }
                    }
                    flPlotPerm = abbrP(larg, "pe");
                    trails = TRUE;
                    paths = FALSE;
                    drawPaths();
                } else if (abbrP(svalue, "co")) {
                    //  Set path colour <r, g, b>
                    string colarg = llList2String(args, 3);
                    if (!(pathPolychrome = abbrP(colarg, "po"))) {
                        pathColour = (vector) colarg;
                    }
                } else if (abbrP(svalue, "wi")) {
                    //  Set path width n
                    pathWidth = (float) llList2String(args, 3);
                    fuisWid = fuis(pathWidth);
                    if (running && paths) {
                        drawPaths();
                    }
                } else {
                    //  Set path on/off
                    if (trails && (!flPlotPerm)) {
                        clearPaths();
                    }
                    trails = FALSE;
                    paths = onOff(svalue);
                    drawPaths();
                }

            //  Set rho n

            } else if (abbrP(sparam, "rh")) {
                lorRho = ratParam(svalue, 28);
                updateScale();

            //  Set scale n

            } else if (abbrP(sparam, "sc")) {
                globalScale = ratParam(svalue, 0.125);

            //  Set sigma n

            } else if (abbrP(sparam, "si")) {
                lorSigma = ratParam(svalue, 10);
                updateScale();

            //  Set texture [ name ]

            } else if (abbrP(sparam, "te")) {
                string bottom = "-bottom";
                if (argn < 3) {
                    //  Set texture     (No name, list textures)
                    integer n = llGetInventoryNumber(INVENTORY_TEXTURE);
                    integer i;
                    integer j = 0;
                    for (i = 0; i < n; i++) {
                        string s = llGetInventoryName(INVENTORY_TEXTURE, i);
                        if ((s != "") && (llSubStringIndex(s, bottom) < 0)) {
                            tawk("  " + (string) (++j) + ". " + s);
                        }
                    }
                } else {
                    //  Set texture name
                    if (llGetInventoryType(svalue) == INVENTORY_TEXTURE) {
                        string sbottom = svalue + bottom;
                        if (llGetInventoryType(sbottom) != INVENTORY_TEXTURE) {
                            //  If a matching -bottom texture exists, use it
                            sbottom = svalue;
                        }
                        llSetLinkPrimitiveParamsFast(LINK_THIS,
                            [ PRIM_TEXTURE, 3, svalue, <1, -1, 1>, ZERO_VECTOR, 0,
                              PRIM_TEXTURE, 1, sbottom, <1, -1, 1>, ZERO_VECTOR, 0 ]);
                    } else {
                        tawk("No such texture.");
                        return FALSE;
                    }
                }

            //  Set tick n

            } else if (abbrP(sparam, "ti")) {
                tick = (float) svalue;
                if (running) {
                    llSetTimerEvent(tick);
                }

            //  Set trace on/off

            } else if (abbrP(sparam, "tr")) {
                if (flIsDigit(svalue)) {
                    trace = (integer) svalue;
                } else {
                    trace = onOff(svalue);
                }
                sendSettings();

            } else {
                tawk("Setting unknown.");
                return FALSE;
            }

        //    Commands processed by other scripts
        //  Script                  Script commands
        //  Menu                    Menu commands

        } else if (abbrP(command, "sc") || abbrP(command, "me")) {
            if ((abbrP(command, "me") && abbrP(sparam, "sh")) &&
                ((argn < 4) || (!abbrP(llList2String(args, -1), "co")))) {
                scriptSuspend = TRUE;
            }
            llMessageLinked(LINK_THIS, LM_CP_COMMAND,
                llList2Json(JSON_ARRAY, [ message, lmessage ] + args), whoDat);

        //  Status                  Print status

        } else if (abbrP(command, "st")) {
            integer mFree = llGetFreeMemory();
            integer mUsed = llGetUsedMemory();
            string s;
            s += "Sigma: " + (string) lorSigma + "  Rho: " + (string) lorRho +
                 "  Beta: " + (string) lorBeta + "  deltaT: " + (string) lorDt + "\n";
            s += "Trace: " + eOnOff(trace) + "  Echo: " + eOnOff(echo) + "\n";
            s += "Running: " + eOnOff(running) + "  Tick: " + (string) tick +
                 "  Scale: " + (string) globalScale;
            s += "  Line plotters: " + (string) linePlotters +
                 "  Width: " + (string) pathWidth +  "\n";
            s += "Attached: " + eOnOff(attached);
            if (attached) {
                s += "  To: " + llKey2Name(wearer);
            }
            s += "\n";

            s += "Script memory.  Free: " + (string) mFree +
                    "  Used: " + (string) mUsed + " (" +
                    (string) ((integer) llRound((mUsed * 100.0) / (mUsed + mFree))) + "%)";
            tawk(s);
            //  Request status of Script Processor
            llMessageLinked(LINK_THIS, LM_SP_STAT, "", id);
            //  Request status of Menu Processor
            llMessageLinked(LINK_THIS, LM_MP_STAT, "", id);

        } else {
            tawk("Huh?  \"" + message + "\" undefined.  Chat /" +
                (string) commandChannel + " help for instructions.");
            return FALSE;
        }

        return TRUE;
    }

    //  lorIterate  --  Perform one Lorenz iteration

    lorIterate() {
        curPoint = <
            curPoint.x + (lorDt * (lorSigma * (curPoint.y - curPoint.x))),
            curPoint.y + (lorDt * ((curPoint.x * (lorRho - curPoint.z)) - curPoint.y)),
            curPoint.z + (lorDt * ((curPoint.x * curPoint.y) - (lorBeta * curPoint.z)))
                   >;
    }

    //  findCrit  --  Compute critical points in Lorenz co-ordinates

    findCrit() {
        float xy = llSqrt(lorBeta * (lorRho - 1));
        float z = lorRho - 1;
        critp1 = < xy, xy, z >;
        critp2 = < -xy, -xy, z >;
        if (trace) {
            tawk("Critical points " + (string) critp1 + " " + (string) critp2);
        }
    }

    /*  updateScale  --  Update the extreme excursion from critical
                         points by simulated evolution for a number
                         of iterations.  */

    updateScale() {
        findCrit();             // Update critical points from parameters
        vector cpsave = curPoint;
        curPoint = critp1 +
            (llVecNorm(critp2 - critp1) * (llVecDist(critp1, critp2) / 5));
        integer i;
        maxExcursion = -1;
        integer foundI;
        for (i = 0; i  < 1000; i++) {
            lorIterate();
            float excurp1 = llVecDist(curPoint, critp1);
            float excurp2 = llVecDist(curPoint, critp2);
            if (excurp2 < excurp1) {
                excurp1 = excurp2;
            }
            if (excurp1 > maxExcursion) {
                maxExcursion = excurp1;
                foundI = i;
            }
        }
        if (trace) {
            tawk("Max excursion " + (string) maxExcursion +
                 " found at step " + (string) foundI);
        }
        curPoint = cpsave;
        //  Compute critical point locations in region co-ordinates
        rcritp1 = lorenz2Region(critp1);
        rcritp2 = lorenz2Region(critp2);
//tawk("Region critical points " + (string) rcritp1 + " " + (string) rcritp2);
    }

    //  lorenz2Region  --  Convert Lorenz co-ordinates to region

    vector lorenz2Region(vector lor) {
        rotation unRot = llEuler2Rot(<-90, 0, 0>) * saveRot;
        return savePos + ((lor * globalScale) * unRot) + regionOffset;
    }

    //  initState  --  Initialise script

    initState() {
        whoDat = owner = llGetOwner();
        savePos = llGetPos();
//tawk("Pos " + (string) savePos + "  Rot " + (string) (llRot2Euler(llGetRot()) * RAD_TO_DEG));

        //  Reset the script and menu processors
        llMessageLinked(LINK_THIS, LM_SP_RESET, "", whoDat);
        llMessageLinked(LINK_THIS, LM_MP_RESET, "", whoDat);
        llSleep(0.1);           // Allow script process to finish reset
        sendSettings();

        //  Count how many line plotters we have in the inventory

        fuisWid = fuis(0.025);          // Initialise constant plot line width
        linePlotters = 0;
        while (llGetInventoryType("Line plotter " + (string) (linePlotters + 1)) ==
                    INVENTORY_SCRIPT) {
            linePlotters++;
        }

        //  Set sit position and default camera view

        llSetSitText("Fly");
        vector dSIT_POS = <0, 0.7, -0.5>;
        rotation dSIT_ROTATION = llAxisAngle2Rot(<1, 0, 0>, -PI_BY_TWO) *
            flRotBetween(<-1, 0, 0>, <0, 0, 1>);
        llLinkSitTarget(LINK_THIS, dSIT_POS, dSIT_ROTATION);
        vector dCAM_OFFSET = <0, 1, 2>; // Offset of camera lens from pilot sit position
        vector dCAM_ANG = <0, 0, -8>;   // Camera look-at point relative to pilot CAM_OFFSET
        llSetLinkCamera(LINK_THIS, dCAM_OFFSET, dCAM_ANG);

        if (llGetAttached() != 0) {
commandChannel = 111;       // Use different channel for attachment when testing
            attachMe(llGetOwnerKey(llGetKey()));
            llStopMoveToTarget();
        }

        //  Start listening on the command chat channel
        commandH = llListen(commandChannel, "", NULL_KEY, "");
        tawk("Listening on /" + (string) commandChannel);

        //  If a configuration script exists, run it
        if (llGetInventoryType(configScript) == INVENTORY_NOTECARD) {
            llMessageLinked(LINK_THIS, LM_SP_RUN, configScript, whoDat);
        }
    }

    default {

        on_rez(integer sparam) {
            if (llGetAttached() != 0) {
                llSetRot(attachRot);
            }
            deployer = sparam;
            if (deployer == 0) {
                llResetScript();
            } else {
                /*  We were launched by deployer.  Skip script
                    reset (which would cause us to forget that)
                    and listen on the deployer communication
                    channel instead.  */
                commandChannel += 1000;     // Offset to deployer channel
                initState();
            }
        }

        state_entry() {
            initState();
        }

        /*  The listen event handler processes messages from
            our chat control channel.  */

        listen(integer channel, string name, key id, string message) {
            if (channel == commandChannel) {
                processCommand(id, message, FALSE);
            }
        }

        /*  We use link messages to communicate with the script
            processor and its sidekick, the menu processor.  */

        link_message(integer sender, integer num, string str, key id) {

            //  Script Processor messages

            //  LM_SP_READY (57): Script ready to read

            if (num == LM_SP_READY) {
                scriptActive = TRUE;
                llMessageLinked(LINK_THIS, LM_SP_GET, "", id);  // Get the first line

            //  LM_SP_INPUT (55): Next executable line from script

            } else if (num == LM_SP_INPUT) {
                if (str != "") {                // Process only if not hard EOF
                    scriptSuspend = FALSE;
                    // Some commands set scriptSuspend
                    integer stat = processCommand(id, str, TRUE);
                    if (stat) {
                        if (!scriptSuspend) {
                            llMessageLinked(LINK_THIS, LM_SP_GET, "", id);
                        }
                    } else {
                        //  Error in script command.  Abort script input.
                        scriptActive = scriptSuspend = FALSE;
                        llMessageLinked(LINK_THIS, LM_SP_INIT, "", id);
                        tawk("Script terminated.");
                    }
                }

            //  LM_SP_EOF (56): End of file reading from script

            } else if (num == LM_SP_EOF) {
                scriptActive = FALSE;           // Mark script input complete

            //  LM_SP_ERROR (58): Error processing script request

            } else if (num == LM_SP_ERROR) {
                llRegionSayTo(id, PUBLIC_CHANNEL, "Script error: " + str);
                scriptActive = scriptSuspend = FALSE;
                llMessageLinked(LINK_THIS, LM_SP_INIT, "", id);

            //  LM_MP_RESUME (274): Resume script after menu selection or timeout

            } else if (num == LM_MP_RESUME) {
                scriptResume();
            }
        }

        attach(key who) {
            if (who == NULL_KEY) {
                attached = FALSE;
            } else {
                attachMe(who);
            }
        }

        timer() {
            lorIterate();
            vector lRegPoint = regPoint;
            //  New position in region co-ordinates
            regPoint = lorenz2Region(curPoint);
            //  Find closest critical point
            vector closeCp = rcritp1;
            if (llVecDist(regPoint, rcritp2) < llVecDist(regPoint, rcritp1)) {
                closeCp = rcritp2;
            }
            //  Direction vector of flight
            vector flight = llVecNorm(regPoint - lRegPoint);
            //  Vector from current position to closest critical point
            vector look = llVecNorm(closeCp - regPoint);
            //  Rotation to align local Z with direction of flight
            rotation vdir = flRotBetween(<0, 0, 1>, -flight);
            integer permx = trace >= 4;
            if (trace >= 3) {
                //  Plot model orientation vectors
                plotLine(regPoint, regPoint + (llRot2Fwd(vdir) * 0.3),
                         <1, 0, 0>, fuisWid, permx);    // Model right, Red
                plotLine(regPoint, regPoint + (llRot2Left(vdir) * 0.3),
                         <0, 1, 0>, fuisWid, permx);    // Model up, Green
                plotLine(regPoint, regPoint + (llRot2Up(vdir) * 0.3),
                         <0, 0, 1>, fuisWid, permx);    // Model forward, Blue

                //  Plot vector from object to closest critical point
                plotLine(regPoint, closeCp, <1, 1, 0>,
                         fuisWid, permx);   // Model to nearest crit, Yellow
            }
            //  Projection of look vector into plane of object rotation
            vector up = llRot2Up(vdir);
            vector lproj = look - ((look * up) * up);
            if (trace >= 3) {
                //  Look projection into rotation plane, Magenta
                plotLine(regPoint, regPoint + (lproj * 0.3), <1, 0, 1>,
                    fuisWid, permx);
            }
            //  Rotation to align our local left (actually up in model) with critical point
            vector left = llRot2Left(vdir);
            float zAxRot = llAcos(lproj * left);
            //  Normal of direction of travel and projected direction to critical point
            vector nUpLproj = up % lproj;
            //  Sign indicates which way we need to rotate
            float rotSign = nUpLproj * left;
            if (trace >= 3) {
                tawk("Z rot " + (string) (zAxRot * RAD_TO_DEG) +
                     " rotSign " + (string) rotSign);
            }
            /*  Rotate model around the axis of its travel so its local
                up vector faces toward the closest criticial point.  */
            if (rotSign >= 0) {
                vdir = vdir / llAxisAngle2Rot(up, zAxRot);
            } else {
                vdir = vdir * llAxisAngle2Rot(up, zAxRot);
            }

            if (attached) {
                llMoveToTarget(regPoint, 0.05);
            } else {
                llSetLinkPrimitiveParamsFast(LINK_THIS,
                    [ PRIM_POSITION, regPoint,
                      PRIM_ROTATION, vdir
                    ]);
            }
            if (lRegPoint.x < 0) {
                // Wait for position update before starting particle emitter
                llSleep(0.2);   // Sleep to let viewer catch up with pos change
                drawPaths();
            }
            if (paths && pathPolychrome) {
                /*  Set path colour based on distance from closest
                    critical point.  */
                drawPaths();
            }
            if (trails && (lRegPoint.x >= 0)) {
                plotLine(lRegPoint, regPoint, pathSetColour(),
                         fuisWid, flPlotPerm);
            }
            //  If we've reached the end run time, stop
            if (runEndTime >= 0) {
                if (llGetTime() >= runEndTime) {
                    processCommand(whoDat, "@run off", TRUE);
                }
            }
        }
    }
