#if defined _hxstats_included
  #endinput
#endif
#define _hxstats_included

enum // COUNTING_TYPE
{
	HX_COUNTING_ROUND, // Collected points per this round
	HX_COUNTING_START, // Total points at map start (or when player connected)
	HX_COUNTING_ACTUAL // Current actual points == HX_COUNTING_START + HX_COUNTING_ACTUAL
}

enum // AMOUNT_SOURCE_TYPE
{
	HX_POINTS,	// total points
	HX_TIME,	// play time (in minutes)
	HX_BOOMER,
	HX_CHARGER,
	HX_HUNTER,
	HX_INFECTED,
	HX_JOCKEY,
	HX_SMOKER,
	HX_SPITTER,
	HX_TANK,
	HX_WITCH,
	HX_POINTS_MONTH,
	HX_POINTS_WEEK,
	HX_POINTS_LAST_MONTH,
	HX_POINTS_LAST_WEEK,
	HX_PLACE,
	HX_PLACE_WEEK,
	HX_VIP_QUEUE,
	HX_PENALTY,
	HX_PENALTY_DEATH,
	HX_PENALTY_INCAP,
	HX_PENALTY_FF,
	HX_HIDE,
	HX_TANK_SOLO,
	HX_HEADSHOT,
	HX_POINTS_SIZE
}

/**
 * Give points to client.
 *
 * @param iClient		Client index given.
 * @param iAmount		Number of points to add.
 *
 * @error				Wrong number of arguments.
 * @noreturn
 */
native int HX_AddPoints(int iClient, int iAmount);

/**
 * Retrieve a number of client points.
 *
 * @param iClient		Client index given.
 * @param iCounting		COUNTING_TYPE enum.
 * @param iSource		AMOUNT_SOURCE_TYPE enum.
 *
 * @error				Wrong number of arguments or incorrect input values.
 * @return				Number of points.
 */
native int HX_GetPoints(int iClient, int iCounting, int iSource);

/**
 * Say whether client is registered and available for retrieving statistics points.
 *
 * @param iClient		Client index given.
 *
 * @error				Wrong number of arguments or incorrect input values.
 * @return				1 - when client is registered, 0 - if not.
 */
native int HX_IsClientRegistered(int iClient);

/**
 * Called when client is registered and become available for retrieving statistics points.
 *
 * @param iClient		Client index.
 */
forward void HX_OnClientRegistered(int iClient);

public SharedPlugin __pl_hxstats = 
{
	name = "hx_stats",
	file = "l4d2_hx_stats.smx",
	#if defined REQUIRE_PLUGIN
		required = 1
	#else
		required = 0
	#endif
};

public void __pl_hxstats_SetNTVOptional()
{
	MarkNativeAsOptional("HX_AddPoints");
	MarkNativeAsOptional("HX_GetPoints");
	MarkNativeAsOptional("HX_IsClientRegistered");
}
