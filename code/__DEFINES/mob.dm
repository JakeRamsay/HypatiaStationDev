// Vampire power defines
#define VAMP_REJUV 1
#define VAMP_GLARE 2
#define VAMP_HYPNO 3
#define VAMP_SHAPE 4
#define VAMP_VISION 5
#define VAMP_DISEASE 6
#define VAMP_CLOAK 7
#define VAMP_BATS 8
#define VAMP_SCREAM 9
#define VAMP_JAUNT 10
#define VAMP_SLAVE 11
#define VAMP_BLINK 12
#define VAMP_FULL 13
///////////////////ORGAN DEFINES///////////////////

// Organ defines.
#define ORGAN_CUT_AWAY   1
#define ORGAN_GAUZED     2
#define ORGAN_ATTACHABLE 4
#define ORGAN_BLEEDING   8
#define ORGAN_BROKEN     32
#define ORGAN_DESTROYED  64
#define ORGAN_ROBOT      128
#define ORGAN_SPLINTED   256
#define SALVED           512
#define ORGAN_DEAD       1024
#define ORGAN_MUTATED    2048
#define ORGAN_ASSISTED   4096

#define DROPLIMB_EDGE 0
#define DROPLIMB_BLUNT 1
#define DROPLIMB_BURN 2

#define AGE_MIN 17			//youngest a character can be
#define AGE_MAX 85			//oldest a character can be


#define LEFT 1
#define RIGHT 2


//Pulse levels, very simplified
#define PULSE_NONE		0	//so !M.pulse checks would be possible
#define PULSE_SLOW		1	//<60 bpm
#define PULSE_NORM		2	//60-90 bpm
#define PULSE_FAST		3	//90-120 bpm
#define PULSE_2FAST		4	//>120 bpm
#define PULSE_THREADY	5	//occurs during hypovolemic shock
//feel free to add shit to lists below


//proc/get_pulse methods
#define GETPULSE_HAND	0	//less accurate (hand)
#define GETPULSE_TOOL	1	//more accurate (med scanner, sleeper, etc)

//Some on_mob_life() procs check for alien races.
#define IS_DIONA 1
#define IS_VOX 2
#define IS_SKRELL 3
#define IS_SOGHUN 4
#define IS_OBSEDAI 5

#define HUMAN_STRIP_DELAY 40 //takes 40ds = 4s to strip someone.
#define ALIEN_SELECT_AFK_BUFFER 1 // How many minutes that a person can be AFK before not being allowed to be an alien.
#define SHOES_SLOWDOWN -1.0			// How much shoes slow you down by default. Negative values speed you up


////////REAGENT STUFF////////
// How many units of reagent are consumed per tick, by default.
#define  REAGENTS_METABOLISM 0.4

// By defining the effect multiplier this way, it'll exactly adjust
// all effects according to how they originally were with the 0.4 metabolism
#define REAGENTS_EFFECT_MULTIPLIER REAGENTS_METABOLISM / 0.4

// Factor of how fast mob nutrition decreases
#define	HUNGER_FACTOR 0.1