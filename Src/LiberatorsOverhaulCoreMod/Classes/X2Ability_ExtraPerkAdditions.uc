class X2Ability_ExtraPerkAdditions extends X2Ability config(GameData_SoldierSkills);

var config int ALLOY_VEST_HP;
var config int CHITIN_VEST_HP;
var config int CARAPACE_VEST_HP;

var config int CHITIN_VEST_DODGE;
var config int CARAPACE_VEST_DODGE;

var config int CARAPACE_VEST_MOB;

var config int PRIORITY_TARGET_DODGE;
var config int PRIORITY_TARGET_DEFENSE;

static function array<X2DataTemplate> CreateTemplates()
{
	local array<X2DataTemplate> Templates;
	
	Templates.AddItem(BITShockproof());
	Templates.AddItem(AlloyPlatingEffect());
	Templates.AddItem(ChitinPlatingEffect());
	Templates.AddItem(CarapacePlatingEffect());

	Templates.AddItem(CannonPriorityTarget());
	
	Templates.AddItem(PurePassive('RPGORebalance_AutogunBuff', "img:///UILibrary_XPACK_Common.PerkIcons.UIPerk_strike"));
	Templates.AddItem(PurePassive('RPGORebalance_BITSalvo', "img:///UILibrary_PerkIcons.UIPerk_salvo"));

	Templates.AddItem(WeaponTraitLink('WeaponTraitSMG', 'ShadowOps_Overkill', 'smg', "img:///XPerkIconPack.UIPerk_command_move"));
	Templates.AddItem(WeaponTraitLink('WeaponTraitBullpup', 'F_Stiletto', 'bullpup', "img:///XPerkIconPack.UIPerk_command_shot"));
	Templates.AddItem(WeaponTraitLink('WeaponTraitRifle', 'F_Predator', 'rifle', "img:///XPerkIconPack.UIPerk_command_rifle"));
	Templates.AddItem(WeaponTraitLink('WeaponTraitShotgun', 'MZRunningOnEmpty', 'shotgun', "img:///XPerkIconPack.UIPerk_command_lightning"));
	Templates.AddItem(WeaponTraitLink('WeaponTraitCannon', 'ShadowOps_PointBlank', 'cannon', "img:///XPerkIconPack.UIPerk_command_suppression"));
	Templates.AddItem(WeaponTraitLink('WeaponTraitSniper', 'ShadowOps_Tactician', 'sniper_rifle', "img:///XPerkIconPack.UIPerk_command_sniper"));
	Templates.AddItem(WeaponTraitLink('WeaponTraitPistol', 'ZeroIn', 'pistol', "img:///XPerkIconPack.UIPerk_command_pistol"));
	Templates.AddItem(WeaponTraitLink('WeaponTraitMelee', 'WOTC_APA_Breakthrough', 'sword', "img:///XPerkIconPack.UIPerk_command_knife"));
	Templates.AddItem(WeaponTraitLink('WeaponTraitVektor', 'GrimyExecuteBonus', 'vektor_rifle', "img:///XPerkIconPack.UIPerk_command_stealth"));

	return Templates;
}

static function X2AbilityTemplate WeaponTraitLink(name TemplateName, name AbilityToAdd, name WeaponCategory, string img)
{

	local X2AbilityTemplate										Template;
	local X2Condition_WOTC_APA_Class_ValidWeaponCategory		WeaponCondition;
	local X2Effect_WOTC_APA_Class_AddAbilitiesToTarget			AbilityEffect;

	Template = PurePassive(TemplateName, img,, 'eAbilitySource_Perk');
	// Create effect to add Squadsight ability when equipped with a sniper rifle
	WeaponCondition = new class'X2Condition_WOTC_APA_Class_ValidWeaponCategory';
	WeaponCondition.AllowedWeaponCategories.AddItem(WeaponCategory);
	WeaponCondition.bCheckSpecificSlot = true;
	WeaponCondition.SpecificSlot = eInvSlot_PrimaryWeapon;

	AbilityEffect = new class'X2Effect_WOTC_APA_Class_AddAbilitiesToTarget';
	AbilityEffect.AddAbilities.AddItem(AbilityToAdd);
	AbilityEffect.TargetConditions.AddItem(WeaponCondition);
	Template.AddTargetEffect(AbilityEffect);

	return Template;
}

static function X2AbilityTemplate BITShockproof()
{
	local X2AbilityTemplate						Template;
	local X2Effect_PersistentStatChange         PersistentStatChangeEffect;
	local X2Effect_DamageImmunity               ImmunityEffect;

	`CREATE_X2ABILITY_TEMPLATE(Template, 'RPGORebalance_Shockproof');

	Template.AbilitySourceName = 'eAbilitySource_Item';
	Template.eAbilityIconBehaviorHUD = EAbilityIconBehavior_NeverShow;
	Template.Hostility = eHostility_Neutral;
	Template.IconImage = "img:///UILibrary_PerkIcons.UIPerk_lightningreflexes";

	Template.AbilityToHitCalc = default.DeadEye;
	Template.AbilityTargetStyle = default.SelfTarget;
	Template.AbilityTriggers.AddItem(default.UnitPostBeginPlayTrigger);

	ImmunityEffect = new class'X2Effect_DamageImmunity';
	ImmunityEffect.EffectName = 'ShockproofImmunity';
	ImmunityEffect.ImmuneTypes.AddItem(class'X2Item_DefaultDamageTypes'.default.DisorientDamageType);
	ImmunityEffect.ImmuneTypes.AddItem('Electrical');
	ImmunityEffect.BuildPersistentEffect(1, true, false, false);
	ImmunityEffect.SetDisplayInfo(ePerkBuff_Bonus, Template.LocFriendlyName, Template.GetMyHelpText(), Template.IconImage, false, , Template.AbilitySourceName);
	Template.AddTargetEffect(ImmunityEffect);

	Template.BuildNewGameStateFn = TypicalAbility_BuildGameState;
	//  NOTE: No visualization on purpose!

	return Template;
}

static function X2AbilityTemplate BITReinforced()
{
	local X2AbilityTemplate                 Template;	
	local X2Effect_PersistentStatChange		PersistentStatChangeEffect;

	`CREATE_X2ABILITY_TEMPLATE(Template, 'LiberatorsOverhaul_Reinforced');
	Template.IconImage = "img:///UILibrary_WOTC_APA_Class_Pack.perk_AdaptiveAlloyPlating";

	Template.AbilitySourceName = 'eAbilitySource_Item';
	Template.eAbilityIconBehaviorHUD = EAbilityIconBehavior_NeverShow;
	Template.Hostility = eHostility_Neutral;
	Template.bDisplayInUITacticalText = false;
	
	Template.AbilityToHitCalc = default.DeadEye;
	Template.AbilityTargetStyle = default.SelfTarget;
	Template.AbilityTriggers.AddItem(default.UnitPostBeginPlayTrigger);
	
	// Bonus to health stat Effect
	PersistentStatChangeEffect = new class'X2Effect_PersistentStatChange';
	PersistentStatChangeEffect.BuildPersistentEffect(1, true, false, false);
	PersistentStatChangeEffect.SetDisplayInfo(ePerkBuff_Passive, Template.LocFriendlyName, Template.GetMyLongDescription(), Template.IconImage, false, , Template.AbilitySourceName);
	PersistentStatChangeEffect.AddPersistentStatChange(eStat_ShieldHP, 1);
	Template.AddTargetEffect(PersistentStatChangeEffect);

	Template.BuildNewGameStateFn = TypicalAbility_BuildGameState;
	
	Template.SetUIStatMarkup(class'XLocalizedData'.default.HealthLabel, eStat_HP, 1);

	return Template;	
}

static function X2AbilityTemplate AlloyPlatingEffect()
{
	local X2AbilityTemplate                 Template;	
	local X2Effect_PersistentStatChange		PersistentStatChangeEffect;

	`CREATE_X2ABILITY_TEMPLATE(Template, 'LiberatorsOverhaul_AlloyPlatingEffect');
	Template.IconImage = "img:///UILibrary_PerkIcons.UIPerk_item_nanofibervest";

	Template.AbilitySourceName = 'eAbilitySource_Item';
	Template.eAbilityIconBehaviorHUD = EAbilityIconBehavior_NeverShow;
	Template.Hostility = eHostility_Neutral;
	Template.bDisplayInUITacticalText = false;
	
	Template.AbilityToHitCalc = default.DeadEye;
	Template.AbilityTargetStyle = default.SelfTarget;
	Template.AbilityTriggers.AddItem(default.UnitPostBeginPlayTrigger);
	
	// Bonus to health stat Effect
	PersistentStatChangeEffect = new class'X2Effect_PersistentStatChange';
	PersistentStatChangeEffect.BuildPersistentEffect(1, true, false, false);
	PersistentStatChangeEffect.SetDisplayInfo(ePerkBuff_Passive, Template.LocFriendlyName, Template.GetMyLongDescription(), Template.IconImage, false, , Template.AbilitySourceName);
	PersistentStatChangeEffect.AddPersistentStatChange(eStat_ShieldHP, default.ALLOY_VEST_HP);
	Template.AddTargetEffect(PersistentStatChangeEffect);

	Template.BuildNewGameStateFn = TypicalAbility_BuildGameState;
	
	Template.SetUIStatMarkup(class'XLocalizedData'.default.HealthLabel, eStat_HP, default.ALLOY_VEST_HP);

	return Template;	
}

static function X2AbilityTemplate ChitinPlatingEffect()
{
	local X2AbilityTemplate                 Template;	
	local X2Effect_PersistentStatChange		PersistentStatChangeEffect;

	`CREATE_X2ABILITY_TEMPLATE(Template, 'LiberatorsOverhaul_ChitinPlatingEffect');
	Template.IconImage = "img:///UILibrary_PerkIcons.UIPerk_item_nanofibervest";

	Template.AbilitySourceName = 'eAbilitySource_Item';
	Template.eAbilityIconBehaviorHUD = EAbilityIconBehavior_NeverShow;
	Template.Hostility = eHostility_Neutral;
	Template.bDisplayInUITacticalText = false;
	
	Template.AbilityToHitCalc = default.DeadEye;
	Template.AbilityTargetStyle = default.SelfTarget;
	Template.AbilityTriggers.AddItem(default.UnitPostBeginPlayTrigger);
	
	// Bonus to health stat Effect
	PersistentStatChangeEffect = new class'X2Effect_PersistentStatChange';
	PersistentStatChangeEffect.BuildPersistentEffect(1, true, false, false);
	PersistentStatChangeEffect.SetDisplayInfo(ePerkBuff_Passive, Template.LocFriendlyName, Template.GetMyLongDescription(), Template.IconImage, false, , Template.AbilitySourceName);
	PersistentStatChangeEffect.AddPersistentStatChange(eStat_ShieldHP, default.CHITIN_VEST_HP);
	PersistentStatChangeEffect.AddPersistentStatChange(eStat_Dodge, default.CHITIN_VEST_DODGE);
	Template.AddTargetEffect(PersistentStatChangeEffect);

	Template.BuildNewGameStateFn = TypicalAbility_BuildGameState;
	
	Template.SetUIStatMarkup(class'XLocalizedData'.default.HealthLabel, eStat_HP, default.CHITIN_VEST_HP);
	Template.SetUIStatMarkup(class'XLocalizedData'.default.DodgeLabel, eStat_Dodge, default.CHITIN_VEST_DODGE);

	return Template;	
}

static function X2AbilityTemplate CarapacePlatingEffect()
{
	local X2AbilityTemplate                 Template;	
	local X2Effect_PersistentStatChange		PersistentStatChangeEffect;

	`CREATE_X2ABILITY_TEMPLATE(Template, 'LiberatorsOverhaul_CarapacePlatingEffect');
	Template.IconImage = "img:///UILibrary_PerkIcons.UIPerk_item_nanofibervest";

	Template.AbilitySourceName = 'eAbilitySource_Item';
	Template.eAbilityIconBehaviorHUD = EAbilityIconBehavior_NeverShow;
	Template.Hostility = eHostility_Neutral;
	Template.bDisplayInUITacticalText = false;
	
	Template.AbilityToHitCalc = default.DeadEye;
	Template.AbilityTargetStyle = default.SelfTarget;
	Template.AbilityTriggers.AddItem(default.UnitPostBeginPlayTrigger);
	
	// Bonus to health stat Effect
	PersistentStatChangeEffect = new class'X2Effect_PersistentStatChange';
	PersistentStatChangeEffect.BuildPersistentEffect(1, true, false, false);
	PersistentStatChangeEffect.SetDisplayInfo(ePerkBuff_Passive, Template.LocFriendlyName, Template.GetMyLongDescription(), Template.IconImage, false, , Template.AbilitySourceName);
	PersistentStatChangeEffect.AddPersistentStatChange(eStat_ShieldHP, default.CARAPACE_VEST_HP);
	PersistentStatChangeEffect.AddPersistentStatChange(eStat_Dodge, default.CARAPACE_VEST_DODGE);
	PersistentStatChangeEffect.AddPersistentStatChange(eStat_Mobility, default.CARAPACE_VEST_MOB);
	Template.AddTargetEffect(PersistentStatChangeEffect);

	Template.BuildNewGameStateFn = TypicalAbility_BuildGameState;
	
	Template.SetUIStatMarkup(class'XLocalizedData'.default.HealthLabel, eStat_HP, default.CARAPACE_VEST_HP);
	Template.SetUIStatMarkup(class'XLocalizedData'.default.DodgeLabel, eStat_Dodge, default.CARAPACE_VEST_DODGE);
	Template.SetUIStatMarkup(class'XLocalizedData'.default.MobilityLabel, eStat_Mobility, default.CARAPACE_VEST_MOB);

	return Template;	
}

static function X2AbilityTemplate CannonPriorityTarget()
{
	local X2AbilityTemplate                 Template;	
	local X2Effect_PersistentStatChange		PersistentStatChangeEffect;

	`CREATE_X2ABILITY_TEMPLATE(Template, 'CannonPriorityTarget');
	Template.IconImage = "img:///XPerkIconPack.UIPerk_panic_shot";

	Template.AbilitySourceName = 'eAbilitySource_Item';
	Template.eAbilityIconBehaviorHUD = EAbilityIconBehavior_NeverShow;
	Template.Hostility = eHostility_Neutral;
	
	Template.AbilityToHitCalc = default.DeadEye;
	Template.AbilityTargetStyle = default.SelfTarget;
	Template.AbilityTriggers.AddItem(default.UnitPostBeginPlayTrigger);
	
	// Bonus to health stat Effect
	PersistentStatChangeEffect = new class'X2Effect_PersistentStatChange';
	PersistentStatChangeEffect.BuildPersistentEffect(1, true, false, false);
	PersistentStatChangeEffect.SetDisplayInfo(ePerkBuff_Passive, Template.LocFriendlyName, Template.GetMyLongDescription(), Template.IconImage, false, , Template.AbilitySourceName);
	PersistentStatChangeEffect.AddPersistentStatChange(eStat_Dodge, default.PRIORITY_TARGET_DODGE);
	PersistentStatChangeEffect.AddPersistentStatChange(eStat_Defense, default.PRIORITY_TARGET_DEFENSE);
	Template.AddTargetEffect(PersistentStatChangeEffect);

	Template.BuildNewGameStateFn = TypicalAbility_BuildGameState;
	
	Template.SetUIStatMarkup(class'XLocalizedData'.default.DodgeLabel, eStat_Dodge, default.PRIORITY_TARGET_DODGE);
	Template.SetUIStatMarkup(class'XLocalizedData'.default.DefenseLabel, eStat_Defense, default.PRIORITY_TARGET_DEFENSE);

	return Template;	
}