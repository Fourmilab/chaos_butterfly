
            Sensitive Dependence on Initial Conditions Experiment

                                            Instructions

One of the key characteristics of a system exhibiting deterministic chaos
is sensitive dependence on initial conditions: a tiny change in the starting
state of the system will diverge into completely different results.  This
experiment demonstrates the phenomenon, first by starting two
butterflies flying with initial positions that differ only by 100 parts per
billion (about as small a difference as can be represented by Second
Life's floating point arithmetic) and observing their trajectories diverge
as the chaotic Lorenz system amplifies this initially tiny difference.

Then, the experiment is re-run with precisely identical initial conditions,
demonstrating that the deterministic system evolves exactly the same
if the initial conditions are identical.

Here is how to run the experiment.

    Rez "Sensitive Dependence Experiment" from inventory.
        This creates two butterflies in exactly the same position, one
        listening on /4001 that starts flying at 20% of the way between
        the critical points and a second listening on /4002 that starts
        at 20.000002%, a difference of 100 parts per billion in initial
        conditions.
    /4002 channel 4001
        This sets the second butterfly to also listen to channel 4001,
        so both will respond to commands on that channel.
    /4001 run on
        Both butterflies start flying, apparently in lockstep.  But the
        tiny difference in their initial positions is being amplified by
        the chaotic Lorenz system as they fly, and around 100 seconds
        into the run you'll see their paths begin to visibly diverge.
        Shortly thereafter, they'll be following completely different
        trajectories, often orbiting different critical points.
    /4001 run off
    /4001 boot
        Stop the run and reboot the two butterflies.  They will resume
        listening on channels 4001 and 4002.
    /4002 set start 20
        Change the starting position of butterfly 2 to 20%, precisely
        the same as butterfly 1.
    /4002 channel 4001
        Reset butterfly 2 to listen to the same channel as butterfly 1.
    /4001 run on
        Start the butterflies flying again.  This time, having
        eliminated the 100 parts per billion difference in initial
        conditions, they will track perfectly, as the evolution of the
        Lorenz system is deterministic.  After a while, you may notice
        that one butterfly is getting a little ahead of the other along
        their trajectory.  This is due to the Second Life simulator not
        updating these two independent objects at precisely the same
        rate.  But you will notice they are following exactly the same
        trajectory because their starting points were identical.  I
        have let this run overnight, and the two butterflies never
        diverged onto radically different trajectories.
    /4001 run off
    /4001 boot
        This concludes the experiment.  You may now, if you wish,
        continue the experiment at the step above where we set the
        starting position of /4002 and try different starting positions
        or changes in other parameters such as beta, rho, or sigma.
        Bear in mind that floating point computation in Second Life is
        single-precision only, which has around 7.2 significant digits,
        so changes smaller than the 100 parts per billion used in the
        example may not make any difference.
