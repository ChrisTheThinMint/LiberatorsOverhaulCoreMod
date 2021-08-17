class X2Character_NewAdvent extends X2Character config(GameData_CharacterStats);

static function array<X2DataTemplate> CreateTemplates()
{
	local array<X2DataTemplate> Templates;

	Templates.AddItem(CreateTemplate_AdvTrooperM4());
	Templates.AddItem(CreateTemplate_AdvTrooperM5());
	
	Templates.AddItem(CreateTemplate_AdvAssaultM1());
	Templates.AddItem(CreateTemplate_AdvAssaultM2());
	Templates.AddItem(CreateTemplate_AdvAssaultM3());

	Templates.AddItem(CreateTemplate_AdvSniperM1());
	Templates.AddItem(CreateTemplate_AdvSniperM2());
	Templates.AddItem(CreateTemplate_AdvSniperM3());

	Templates.AddItem(CreateTemplate_AdvMedicM1());
	Templates.AddItem(CreateTemplate_AdvMedicM2());
	Templates.AddItem(CreateTemplate_AdvMedicM3());

	Templates.AddItem(CreateTemplate_AdvSpecialistM1());
	Templates.AddItem(CreateTemplate_AdvSpecialistM2());
	Templates.AddItem(CreateTemplate_AdvSpecialistM3());

	Templates.AddItem(CreateTemplate_AdvHunterM1());
	Templates.AddItem(CreateTemplate_AdvHunterM2());
	Templates.AddItem(CreateTemplate_AdvHunterM3());

	Templates.AddItem(CreateTemplate_AdvEngineerM1());
	Templates.AddItem(CreateTemplate_AdvEngineerM2());
	Templates.AddItem(CreateTemplate_AdvEngineerM3());

	return Templates;
}

static function X2CharacterTemplate CreateTemplate_AdvTrooperM4()
{
	local X2CharacterTemplate CharTemplate;
	local LootReference Loot;

	CharTemplate = CreateStandardAdvent('AdvTrooperM4');
	CharTemplate.strPawnArchetypes.AddItem("GameUnit_AdvTrooper.ARC_GameUnit_AdvTrooperM3_M");
	CharTemplate.strPawnArchetypes.AddItem("GameUnit_AdvTrooper.ARC_GameUnit_AdvTrooperM3_F");

	CharTemplate.CharacterGroupName = 'AdventTrooper';
	CharTemplate.DefaultLoadout='AdvTrooperM4_Loadout';
	CharTemplate.strBehaviorTree = "AdventTrooper::CharacterRoot";

	CharTemplate.RevealMatineePrefix = "CIN_Advent_Trooper_Male";

	CharTemplate.CharacterBaseStats[eStat_HP] = 10;

	return CharTemplate;
}

static function X2CharacterTemplate CreateTemplate_AdvTrooperM5()
{
	local X2CharacterTemplate CharTemplate;
	local LootReference Loot;
	
	CharTemplate = CreateStandardAdvent('AdvTrooperM5');
	CharTemplate.strPawnArchetypes.AddItem("GameUnit_AdvTrooper.ARC_GameUnit_AdvTrooperM3_M");
	CharTemplate.strPawnArchetypes.AddItem("GameUnit_AdvTrooper.ARC_GameUnit_AdvTrooperM3_F");
	
	CharTemplate.CharacterGroupName = 'AdventTrooper';
	CharTemplate.DefaultLoadout='AdvTrooperM5_Loadout';
	CharTemplate.strBehaviorTree = "AdventTrooper::CharacterRoot";

	CharTemplate.RevealMatineePrefix = "CIN_Advent_Trooper_Male";

	CharTemplate.CharacterBaseStats[eStat_HP] = 12;

	return CharTemplate;
}

static function X2CharacterTemplate CreateTemplate_AdvAssaultM1()
{
	local X2CharacterTemplate CharTemplate;
	local LootReference Loot;

	CharTemplate = CreateStandardAdvent('AdvAssaultM1');
	CharTemplate.strPawnArchetypes.AddItem("WoTC_Advent_Assault_Trooper.Archetypes.ARC_Advent_AssTrooper_T1_M");

	CharTemplate.CharacterGroupName = 'AdventAssault';
	CharTemplate.DefaultLoadout='AdvAssaultM1_Loadout';
	CharTemplate.strBehaviorTree = "AdventAssault::CharacterRoot";

	/*Loot.LootTableName='AdvStunLancerM3_BaseLoot';
	CharTemplate.Loot.LootReferences.AddItem(Loot);
	Loot.ForceLevel = 0;
	Loot.LootTableName = 'AdvStunLancerM3_TimedLoot';
	CharTemplate.TimedLoot.LootReferences.AddItem(Loot);
	Loot.LootTableName = 'AdvStunLancerM3_VultureLoot';
	CharTemplate.VultureLoot.LootReferences.AddItem(Loot);*/

	CharTemplate.RevealMatineePrefix = "CIN_Advent_Trooper_Male";

	CharTemplate.CharacterBaseStats[eStat_HP] = 5;
	CharTemplate.CharacterBaseStats[eStat_Offense] = 75;

	return CharTemplate;
}

static function X2CharacterTemplate CreateTemplate_AdvAssaultM2()
{
	local X2CharacterTemplate CharTemplate;
	local LootReference Loot;

	CharTemplate = CreateStandardAdvent('AdvAssaultM2');
	CharTemplate.strPawnArchetypes.AddItem("WoTC_Advent_Assault_Trooper.Archetypes.ARC_Advent_AssTrooper_T2_M");

	CharTemplate.CharacterGroupName = 'AdventAssault';
	CharTemplate.DefaultLoadout='AdvAssaultM2_Loadout';
	CharTemplate.strBehaviorTree = "AdventAssault::CharacterRoot";

	CharTemplate.RevealMatineePrefix = "CIN_Advent_Trooper_Male";

	CharTemplate.CharacterBaseStats[eStat_HP] = 8;
	CharTemplate.CharacterBaseStats[eStat_Offense] = 75;

	return CharTemplate;
}

static function X2CharacterTemplate CreateTemplate_AdvAssaultM3()
{
	local X2CharacterTemplate CharTemplate;
	local LootReference Loot;

	CharTemplate = CreateStandardAdvent('AdvAssaultM3');
	CharTemplate.strPawnArchetypes.AddItem("WoTC_Advent_Assault_Trooper.Archetypes.ARC_Advent_AssTrooper_T3_M");

	CharTemplate.CharacterGroupName = 'AdventAssault';
	CharTemplate.DefaultLoadout='AdvAssaultM3_Loadout';
	CharTemplate.strBehaviorTree = "AdventAssault::CharacterRoot";

	CharTemplate.RevealMatineePrefix = "CIN_Advent_Trooper_Male";

	CharTemplate.CharacterBaseStats[eStat_HP] = 12;
	CharTemplate.CharacterBaseStats[eStat_Offense] = 75;

	return CharTemplate;
}

static function X2CharacterTemplate CreateTemplate_AdvSniperM1()
{
	local X2CharacterTemplate CharTemplate;
	local LootReference Loot;

	CharTemplate = CreateStandardAdvent('AdvSniperM1');
	CharTemplate.strPawnArchetypes.AddItem("BetterTroopers.ARC_GameUnit_AdvTrooperM_R_1");
	//CharTemplate.strPawnArchetypes.AddItem("BetterTroopers.ARC_GameUnit_AdvTrooperF_R_1");

	CharTemplate.CharacterGroupName = 'AdventSniper';
	CharTemplate.DefaultLoadout='AdvSniperM1_Loadout';
	CharTemplate.strBehaviorTree = "AdventSniper::CharacterRoot";

	CharTemplate.RevealMatineePrefix = "CIN_Advent_Trooper_Male";

	CharTemplate.CharacterBaseStats[eStat_HP] = 4;

	CharTemplate.Abilities.AddItem('MarkTarget');

	return CharTemplate;
}

static function X2CharacterTemplate CreateTemplate_AdvSniperM2()
{
	local X2CharacterTemplate CharTemplate;
	local LootReference Loot;

	CharTemplate = CreateStandardAdvent('AdvSniperM2');
	CharTemplate.strPawnArchetypes.AddItem("BetterTroopers.ARC_GameUnit_AdvTrooperM_R_1");
	//CharTemplate.strPawnArchetypes.AddItem("BetterTroopers.ARC_GameUnit_AdvTrooperF_R_2");

	CharTemplate.CharacterGroupName = 'AdventSniper';
	CharTemplate.DefaultLoadout='AdvSniperM2_Loadout';
	CharTemplate.strBehaviorTree = "AdventSniper::CharacterRoot";

	CharTemplate.RevealMatineePrefix = "CIN_Advent_Trooper_Male";

	CharTemplate.CharacterBaseStats[eStat_HP] = 6;
	CharTemplate.CharacterBaseStats[eStat_Offense] = 75;

	CharTemplate.Abilities.AddItem('MarkTarget');

	return CharTemplate;
}

static function X2CharacterTemplate CreateTemplate_AdvSniperM3()
{
	local X2CharacterTemplate CharTemplate;
	local LootReference Loot;

	CharTemplate = CreateStandardAdvent('AdvSniperM3');
	CharTemplate.strPawnArchetypes.AddItem("BetterTroopers.ARC_GameUnit_AdvTrooperM_R_1");
	//CharTemplate.strPawnArchetypes.AddItem("BetterTroopers.ARC_GameUnit_AdvTrooperF_R_3");

	CharTemplate.CharacterGroupName = 'AdventSniper';
	CharTemplate.DefaultLoadout='AdvSniperM3_Loadout';
	CharTemplate.strBehaviorTree = "AdventSniper::CharacterRoot";

	CharTemplate.RevealMatineePrefix = "CIN_Advent_Trooper_Male";

	CharTemplate.CharacterBaseStats[eStat_HP] = 8;
	CharTemplate.CharacterBaseStats[eStat_Offense] = 75;

	CharTemplate.Abilities.AddItem('MarkTarget');

	return CharTemplate;
}

static function X2CharacterTemplate CreateTemplate_AdvMedicM1()
{
	local X2CharacterTemplate CharTemplate;
	local LootReference Loot;

	CharTemplate = CreateStandardAdvent('AdvMedicM1');
	//CharTemplate.strPawnArchetypes.AddItem("BetterTroopers.ARC_GameUnit_AdvTrooperM_G_1");
	CharTemplate.strPawnArchetypes.AddItem("BetterTroopers.ARC_GameUnit_AdvTrooperF_G_3");

	CharTemplate.CharacterGroupName = 'AdventMedic';
	CharTemplate.DefaultLoadout='AdvMedicM1_Loadout';
	CharTemplate.strBehaviorTree = "AdventMedic::CharacterRoot";

	CharTemplate.RevealMatineePrefix = "CIN_Advent_Trooper_Female";

	CharTemplate.CharacterBaseStats[eStat_HP] = 4;
	CharTemplate.CharacterBaseStats[eStat_Offense] = 75;

	return CharTemplate;
}

static function X2CharacterTemplate CreateTemplate_AdvMedicM2()
{
	local X2CharacterTemplate CharTemplate;
	local LootReference Loot;

	CharTemplate = CreateStandardAdvent('AdvMedicM2');
	//CharTemplate.strPawnArchetypes.AddItem("BetterTroopers.ARC_GameUnit_AdvTrooperM_G_2");
	CharTemplate.strPawnArchetypes.AddItem("BetterTroopers.ARC_GameUnit_AdvTrooperF_G_3");

	CharTemplate.CharacterGroupName = 'AdventMedic';
	CharTemplate.DefaultLoadout='AdvMedicM2_Loadout';
	CharTemplate.strBehaviorTree = "AdventMedic::CharacterRoot";

	CharTemplate.RevealMatineePrefix = "CIN_Advent_Trooper_Female";

	CharTemplate.CharacterBaseStats[eStat_HP] = 6;
	CharTemplate.CharacterBaseStats[eStat_Offense] = 75;

	return CharTemplate;
}

static function X2CharacterTemplate CreateTemplate_AdvMedicM3()
{
	local X2CharacterTemplate CharTemplate;
	local LootReference Loot;

	CharTemplate = CreateStandardAdvent('AdvMedicM3');
	//CharTemplate.strPawnArchetypes.AddItem("BetterTroopers.ARC_GameUnit_AdvTrooperM_G_3");
	CharTemplate.strPawnArchetypes.AddItem("BetterTroopers.ARC_GameUnit_AdvTrooperF_G_3");

	CharTemplate.CharacterGroupName = 'AdventMedic';
	CharTemplate.DefaultLoadout='AdvMedicM3_Loadout';
	CharTemplate.strBehaviorTree = "AdventMedic::CharacterRoot";

	CharTemplate.RevealMatineePrefix = "CIN_Advent_Trooper_Female";

	CharTemplate.CharacterBaseStats[eStat_HP] = 8;
	CharTemplate.CharacterBaseStats[eStat_Offense] = 75;

	return CharTemplate;
}

static function X2CharacterTemplate CreateTemplate_AdvSpecialistM1()
{
	local X2CharacterTemplate CharTemplate;
	local LootReference Loot;

	CharTemplate = CreateStandardAdvent('AdvSpecialistM1');

	CharTemplate.CharacterGroupName = 'AdventSpecialist';
	CharTemplate.DefaultLoadout='AdvSpecialistM1_Loadout';
	CharTemplate.strBehaviorTree = "AdventSpecialist::CharacterRoot";

	CharTemplate.RevealMatineePrefix = "CIN_Advent_Trooper";
	CharTemplate.GetRevealMatineePrefixFn = GetAdventMatineePrefix;
	CharTemplate.strPawnArchetypes.AddItem("XAdventTrooper.Archetypes.GameUnit_AdvSoldier_M");
	CharTemplate.strPawnArchetypes.AddItem("XAdventTrooper.Archetypes.GameUnit_AdvSoldier_F");

	CharTemplate.CharacterBaseStats[eStat_HP] = 1;

	return CharTemplate;
}

static function X2CharacterTemplate CreateTemplate_AdvSpecialistM2()
{
	local X2CharacterTemplate CharTemplate;
	local LootReference Loot;

	CharTemplate = CreateStandardAdvent('AdvSpecialistM2');

	CharTemplate.CharacterGroupName = 'AdventSpecialist';
	CharTemplate.DefaultLoadout='AdvSpecialistM2_Loadout';
	CharTemplate.strBehaviorTree = "AdventSpecialist::CharacterRoot";

	CharTemplate.RevealMatineePrefix = "CIN_Advent_Trooper";
	CharTemplate.GetRevealMatineePrefixFn = GetAdventMatineePrefix;
	CharTemplate.strPawnArchetypes.AddItem("XAdventTrooper.Archetypes.GameUnit_AdvSoldier_M");
	CharTemplate.strPawnArchetypes.AddItem("XAdventTrooper.Archetypes.GameUnit_AdvSoldier_F");

	CharTemplate.CharacterBaseStats[eStat_HP] = 1;

	return CharTemplate;
}

static function X2CharacterTemplate CreateTemplate_AdvSpecialistM3()
{
	local X2CharacterTemplate CharTemplate;
	local LootReference Loot;

	CharTemplate = CreateStandardAdvent('AdvSpecialistM3');

	CharTemplate.CharacterGroupName = 'AdventSpecialist';
	CharTemplate.DefaultLoadout='AdvSpecialistM3_Loadout';
	CharTemplate.strBehaviorTree = "AdventSpecialist::CharacterRoot";

	CharTemplate.RevealMatineePrefix = "CIN_Advent_Trooper";
	CharTemplate.GetRevealMatineePrefixFn = GetAdventMatineePrefix;
	CharTemplate.strPawnArchetypes.AddItem("XAdventTrooper.Archetypes.GameUnit_AdvSoldier_M");
	CharTemplate.strPawnArchetypes.AddItem("XAdventTrooper.Archetypes.GameUnit_AdvSoldier_F");

	CharTemplate.CharacterBaseStats[eStat_HP] = 1;

	return CharTemplate;
}

static function X2CharacterTemplate CreateTemplate_AdvHunterM1()
{
	local X2CharacterTemplate CharTemplate;
	local LootReference Loot;

	CharTemplate = CreateStandardAdvent('AdvHunterM1');

	CharTemplate.CharacterGroupName = 'AdventHunter';
	CharTemplate.DefaultLoadout='AdvHunterM1_Loadout';
	CharTemplate.strBehaviorTree = "AdventHunter::CharacterRoot";

	CharTemplate.RevealMatineePrefix = "CIN_Advent_Trooper";
	CharTemplate.GetRevealMatineePrefixFn = GetAdventMatineePrefix;
	CharTemplate.strPawnArchetypes.AddItem("XAdventTrooper.Archetypes.GameUnit_AdvSoldier_M");
	CharTemplate.strPawnArchetypes.AddItem("XAdventTrooper.Archetypes.GameUnit_AdvSoldier_F");

	CharTemplate.CharacterBaseStats[eStat_HP] = 1;

	return CharTemplate;
}

static function X2CharacterTemplate CreateTemplate_AdvHunterM2()
{
	local X2CharacterTemplate CharTemplate;
	local LootReference Loot;

	CharTemplate = CreateStandardAdvent('AdvHunterM2');

	CharTemplate.CharacterGroupName = 'AdventHunter';
	CharTemplate.DefaultLoadout='AdvHunterM2_Loadout';
	CharTemplate.strBehaviorTree = "AdventHunter::CharacterRoot";

	CharTemplate.RevealMatineePrefix = "CIN_Advent_Trooper";
	CharTemplate.GetRevealMatineePrefixFn = GetAdventMatineePrefix;
	CharTemplate.strPawnArchetypes.AddItem("XAdventTrooper.Archetypes.GameUnit_AdvSoldier_M");
	CharTemplate.strPawnArchetypes.AddItem("XAdventTrooper.Archetypes.GameUnit_AdvSoldier_F");

	CharTemplate.CharacterBaseStats[eStat_HP] = 1;

	return CharTemplate;
}

static function X2CharacterTemplate CreateTemplate_AdvHunterM3()
{
	local X2CharacterTemplate CharTemplate;
	local LootReference Loot;

	CharTemplate = CreateStandardAdvent('AdvHunterM3');

	CharTemplate.CharacterGroupName = 'AdventHunter';
	CharTemplate.DefaultLoadout='AdvHunterM3_Loadout';
	CharTemplate.strBehaviorTree = "AdventHunter::CharacterRoot";

	CharTemplate.RevealMatineePrefix = "CIN_Advent_Trooper";
	CharTemplate.GetRevealMatineePrefixFn = GetAdventMatineePrefix;
	CharTemplate.strPawnArchetypes.AddItem("XAdventTrooper.Archetypes.GameUnit_AdvSoldier_M");
	CharTemplate.strPawnArchetypes.AddItem("XAdventTrooper.Archetypes.GameUnit_AdvSoldier_F");

	CharTemplate.CharacterBaseStats[eStat_HP] = 1;

	return CharTemplate;
}

static function X2CharacterTemplate CreateTemplate_AdvEngineerM1()
{
	local X2CharacterTemplate CharTemplate;
	local LootReference Loot;

	CharTemplate = CreateStandardAdvent('AdvEngineerM1');

	CharTemplate.CharacterGroupName = 'AdventEngineer';
	CharTemplate.DefaultLoadout='AdvEngineerM1_Loadout';
	CharTemplate.strBehaviorTree = "AdventEngineer::CharacterRoot";

	CharTemplate.RevealMatineePrefix = "CIN_Advent_Trooper";
	CharTemplate.GetRevealMatineePrefixFn = GetAdventMatineePrefix;
	CharTemplate.strPawnArchetypes.AddItem("XAdventTrooper.Archetypes.GameUnit_AdvSoldier_M");
	CharTemplate.strPawnArchetypes.AddItem("XAdventTrooper.Archetypes.GameUnit_AdvSoldier_F");

	CharTemplate.CharacterBaseStats[eStat_HP] = 1;

	return CharTemplate;
}

static function X2CharacterTemplate CreateTemplate_AdvEngineerM2()
{
	local X2CharacterTemplate CharTemplate;
	local LootReference Loot;

	CharTemplate = CreateStandardAdvent('AdvEngineerM2');

	CharTemplate.CharacterGroupName = 'AdventEngineer';
	CharTemplate.DefaultLoadout='AdvEngineerM2_Loadout';
	CharTemplate.strBehaviorTree = "AdventEngineer::CharacterRoot";

	CharTemplate.RevealMatineePrefix = "CIN_Advent_Trooper";
	CharTemplate.GetRevealMatineePrefixFn = GetAdventMatineePrefix;
	CharTemplate.strPawnArchetypes.AddItem("XAdventTrooper.Archetypes.GameUnit_AdvSoldier_M");
	CharTemplate.strPawnArchetypes.AddItem("XAdventTrooper.Archetypes.GameUnit_AdvSoldier_F");

	CharTemplate.CharacterBaseStats[eStat_HP] = 1;

	return CharTemplate;
}

static function X2CharacterTemplate CreateTemplate_AdvEngineerM3()
{
	local X2CharacterTemplate CharTemplate;
	local LootReference Loot;

	CharTemplate = CreateStandardAdvent('AdvEngineerM3');

	CharTemplate.CharacterGroupName = 'AdventEngineer';
	CharTemplate.DefaultLoadout='AdvEngineerM3_Loadout';
	CharTemplate.strBehaviorTree = "AdventEngineer::CharacterRoot";

	CharTemplate.RevealMatineePrefix = "CIN_Advent_Trooper";
	CharTemplate.GetRevealMatineePrefixFn = GetAdventMatineePrefix;
	CharTemplate.strPawnArchetypes.AddItem("XAdventTrooper.Archetypes.GameUnit_AdvSoldier_M");
	CharTemplate.strPawnArchetypes.AddItem("XAdventTrooper.Archetypes.GameUnit_AdvSoldier_F");

	CharTemplate.CharacterBaseStats[eStat_HP] = 1;

	return CharTemplate;
}

static function X2CharacterTemplate CreateStandardAdvent(name TemplateName)
{
	local X2CharacterTemplate CharTemplate;

	`CREATE_X2CHARACTER_TEMPLATE(CharTemplate, TemplateName);
	CharTemplate.BehaviorClass=class'XGAIBehavior';

	CharTemplate.strMatineePackages.AddItem("CIN_Advent");

	CharTemplate.UnitSize = 1;
	CharTemplate.CharacterBaseStats[eStat_AlertLevel]=2;
	CharTemplate.CharacterBaseStats[eStat_HP]=5;
	CharTemplate.CharacterBaseStats[eStat_Mobility]=12;
	CharTemplate.CharacterBaseStats[eStat_Offense]=75;
	CharTemplate.CharacterBaseStats[eStat_SightRadius]=27;
	CharTemplate.CharacterBaseStats[eStat_DetectionRadius]=12;
	CharTemplate.CharacterBaseStats[eStat_UtilityItems]=1;

	// Traversal Rules
	CharTemplate.bCanUse_eTraversal_Normal = true;
	CharTemplate.bCanUse_eTraversal_ClimbOver = true;
	CharTemplate.bCanUse_eTraversal_ClimbOnto = true;
	CharTemplate.bCanUse_eTraversal_ClimbLadder = true;
	CharTemplate.bCanUse_eTraversal_DropDown = true;
	CharTemplate.bCanUse_eTraversal_Grapple = false;
	CharTemplate.bCanUse_eTraversal_Landing = true;
	CharTemplate.bCanUse_eTraversal_BreakWindow = true;
	CharTemplate.bCanUse_eTraversal_KickDoor = true;
	CharTemplate.bCanUse_eTraversal_JumpUp = false;
	CharTemplate.bCanUse_eTraversal_WallClimb = false;
	CharTemplate.bCanUse_eTraversal_BreakWall = false;
	CharTemplate.bAppearanceDefinesPawn = false;    
	CharTemplate.bSetGenderAlways = true;
	CharTemplate.bCanTakeCover = true;

	CharTemplate.bIsAlien = false;
	CharTemplate.bIsAdvent = true;
	CharTemplate.bIsCivilian = false;
	CharTemplate.bIsPsionic = false;
	CharTemplate.bIsRobotic = false;
	CharTemplate.bIsSoldier = false;

	CharTemplate.bCanBeTerrorist = false;
	CharTemplate.bCanBeCriticallyWounded = false;
	CharTemplate.bIsAfraidOfFire = true;

	CharTemplate.AddTemplateAvailablility(CharTemplate.BITFIELD_GAMEAREA_Multiplayer); // Allow in MP!
	CharTemplate.MPPointValue = CharTemplate.XpKillscore * 10;

	CharTemplate.strHackIconImage = "UILibrary_Common.TargetIcons.Hack_captain_icon";
	CharTemplate.strTargetIconImage = class'UIUtilities_Image'.const.TargetIcon_Advent;

	CharTemplate.Abilities.AddItem('AdventStilettoRounds');
	CharTemplate.Abilities.AddItem('DarkEventAbility_BendingReed');
	CharTemplate.Abilities.AddItem('DarkEventAbility_SealedArmor');
	CharTemplate.Abilities.AddItem('DarkEventAbility_UndyingLoyalty');
	CharTemplate.Abilities.AddItem('DarkEventAbility_Barrier');
	CharTemplate.Abilities.AddItem('DarkEventAbility_Counterattack');

	return CharTemplate;
}

static function string GetAdventMatineePrefix(XComGameState_Unit UnitState)
{
	if(UnitState.kAppearance.iGender == eGender_Male)
	{
		return UnitState.GetMyTemplate().RevealMatineePrefix $ "_Male";
	}
	else
	{
		return UnitState.GetMyTemplate().RevealMatineePrefix $ "_Female";
	}
}