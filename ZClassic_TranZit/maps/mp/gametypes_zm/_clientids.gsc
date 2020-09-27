#include maps/mp/_utility;
#include common_scripts/utility;
#include maps/mp/gametypes_zm/_hud_util;
#include maps/mp/gametypes_zm/_hud_message;
#include maps/mp/zombies/_zm;
#include maps/mp/zombies/_zm_utility;

init()
{
	// Perk Limit
	//level.perk_purchase_limit = 9;
	
	level thread onplayerconnect();
}

onplayerconnect()
{
	level endon( "end_game" );
    self endon( "disconnect" );
	
	for (;;)
	{
		level waittill( "connected", player );
		player thread onplayerspawned();
		player thread spawnOnRoundOne();
	}
}

onplayerspawned() 
{
	for (;;)
	{
		self waittill( "spawned_player" );
		self thread welcome();
	}
}

spawnOnRoundOne() //force spawn player
{
	wait 3; //waits for blackscreen to load
	if ( self.sessionstate == "spectator" && level.round_number == 1 )
	{
		self [[ level.spawnplayer ]]();
		if ( level.script != "zm_tomb" || level.script != "zm_prison" || !is_classic() )
			thread maps\mp\zombies\_zm::refresh_player_navcard_hud();
	}
}
giveAllPerks()
{
    if (isDefined(level.zombiemode_using_juggernaut_perk) && level.zombiemode_using_juggernaut_perk)
      self doGivePerk("specialty_armorvest");
    if (isDefined(level.zombiemode_using_sleightofhand_perk) && level.zombiemode_using_sleightofhand_perk)
      self doGivePerk("specialty_fastreload");
    if (isDefined(level.zombiemode_using_revive_perk) && level.zombiemode_using_revive_perk)
       self doGivePerk("specialty_quickrevive");
    if (isDefined(level.zombiemode_using_doubletap_perk) && level.zombiemode_using_doubletap_perk) 
       self doGivePerk("specialty_rof");
    if (isDefined(level.zombiemode_using_marathon_perk) && level.zombiemode_using_marathon_perk)
        self doGivePerk("specialty_longersprint");
    if(isDefined(level.zombiemode_using_additionalprimaryweapon_perk) && level.zombiemode_using_additionalprimaryweapon_perk)
        self doGivePerk("specialty_additionalprimaryweapon");
    if (isDefined(level.zombiemode_using_deadshot_perk) && level.zombiemode_using_deadshot_perk)
        self doGivePerk("specialty_deadshot");
    if (isDefined(level.zombiemode_using_tombstone_perk) && level.zombiemode_using_tombstone_perk)
        self doGivePerk("specialty_scavenger");
    if (isDefined(level._custom_perks) && isDefined(level._custom_perks["specialty_flakjacket"]) && (level.script != "zm_buried"))
        self doGivePerk("specialty_flakjacket");
    if (isDefined(level._custom_perks) && isDefined(level._custom_perks["specialty_nomotionsensor"]))
        self doGivePerk("specialty_nomotionsensor");
    if (isDefined(level._custom_perks) && isDefined(level._custom_perks["specialty_grenadepulldeath"]))
        self doGivePerk("specialty_grenadepulldeath");
    if (isDefined(level.zombiemode_using_chugabud_perk) && level.zombiemode_using_chugabud_perk)
        self doGivePerk("specialty_finalstand");
    self iprintln("All Perks ^2Gived");
}
doGivePerk(perk)
{
    self endon("disconnect");
    self endon("death");
    level endon("game_ended");
    self endon("perk_abort_drinking");
    if (!(self hasperk(perk) || (self maps/mp/zombies/_zm_perks::has_perk_paused(perk))))
    {
        gun = self maps/mp/zombies/_zm_perks::perk_give_bottle_begin(perk);
        evt = self waittill_any_return("fake_death", "death", "player_downed", "weapon_change_complete");
        if (evt == "weapon_change_complete")
            self thread maps/mp/zombies/_zm_perks::wait_give_perk(perk, 1);
        self maps/mp/zombies/_zm_perks::perk_give_bottle_end(gun, perk);
        if (self maps/mp/zombies/_zm_laststand::player_is_in_laststand() || isDefined(self.intermission) && self.intermission)
            return;
        self notify("burp");
    }
}
welcome()
{
	setBoxCost();
	setLoadout();
}
setBoxCost()
{
    i = 0;
    price = 750;
    while (i < level.chests.size)
    {
        level.chests[ i ].zombie_cost = price;
        level.chests[ i ].old_cost = price;
        i++;
    }
}
setSpeed()
{
	//if ( self.name == "ThomasDevil" )
	if ( self.name == "ThomasDevil" || "VictorAngel" || "RobertGG" )
	{
		self setmovespeedscale(1.1); // pretty sure 1.25 works
	}
}
setLoadout()
{

	// Speed And Jugg
	setSpeed();
	setJuggernaut();
	
	// Give starting weaponry
    self giveweapon( "knife_zm" );
    self give_start_weapon( 1 );
	
	// Give misc
	self.score = 750;
	
	self iprintln("setLoadout() executed");
	
    if ( level.round_number >= 5 && level.round_number < 10)
    {
        self giveWeapon( "fiveseven_zm" );
        self.score = 5000;
    }
    else if ( level.round_number >= 10 && level.round_number < 15)
    {
        self giveweapon( "tazer_knuckles_zm" );
        self giveWeapon( "ak74u_zm" );
        self.score = 10000;
    }
    else if ( level.round_number >= 15 && level.round_number < 20)
    {
        self giveweapon( "tazer_knuckles_zm" );
        self giveWeapon( "srm1216_upgraded_zm" );
        self maps/mp/zombies/_zm_perks::give_perk( "specialty_armorvest" );
        self.score = 15000;
    }
    else if ( level.round_number >= 20 && level.round_number < 25)
    {
        self giveweapon( "tazer_knuckles_zm" );
        self giveWeapon( "galil_zm" );
        self maps/mp/zombies/_zm_perks::give_perk( "specialty_armorvest" );
        self.score = 20000;
    }
    else if ( level.round_number >= 25)
    {
        self giveweapon( "tazer_knuckles_zm" );
        self giveWeapon( "hamr_upgraded_zm" );
        self maps/mp/zombies/_zm_perks::give_perk( "specialty_armorvest" );
        self.score = 25000;
    }
}
setJuggernaut()
{
	if (isDefined(level.zombiemode_using_juggernaut_perk) && level.zombiemode_using_juggernaut_perk)
		self doGivePerk("specialty_armorvest");
}