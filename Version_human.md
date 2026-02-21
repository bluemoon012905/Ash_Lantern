v.0.0 

Lets start with the most basic version of the game. For this, make a circle on a 2D platform that can walk around

v.0.0.1

lets add a sword. make the sword a separate object than the player circle, however make their movement tied. we will add attacks to the sword later, but the position of the sword matters.

v.0.0.2

added hat, brough sword closer 

v.0.1.0

basic attacks. 

劈 direct chop downward
点 stabs the forward
撩 direct chop upward
挂 pulls sword upwards, sword pointing down basic block
崩 starts with sword directly pointing front, pulls the point back attacking along the way, end in block position 

The sword can only perform these actions if the sword reached their respective starting place, so actions take time to perform. if the player spam many actions at a time, add it to a queue that display them. 

whenever an action finish, play the name of the move on screen like how a comic would do it. do it in chinese character, find a stylized font for now. 

we will assign more stats to these after we get it working. make them for now have a placeholder of 1 damage each. 

the sword return to the basic "held" position after some time of no further actions. 

some example for the sword position, you can pull a 崩 after a 劈 a lot quicker as the ending position of 劈 is the starting position of 崩

Implementation (completed):

- Added a five-move action dictionary to the sword with distinct prep, swing, recovery poses and a placeholder damage value of 1 per move.
- Queued inputs using the new UI panel so players can mash commands and see what is pending.
- Each move now plays a stylized Chinese callout (Noto Sans SC) in a comic splash when it resolves.
- The sword enforces start/end stances, transitions through those poses over time, and drifts back to its basic held position after an idle delay.
