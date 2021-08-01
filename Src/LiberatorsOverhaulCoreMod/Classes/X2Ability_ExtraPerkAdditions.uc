class X2Ability_ExtraPerkAdditions extends X2Ability ;

static function array<X2DataTemplate> CreateTemplates()
{
	local array<X2DataTemplate> Templates;
	
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