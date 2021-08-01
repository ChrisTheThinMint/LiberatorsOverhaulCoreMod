class X2Effect_ApplyWeaponDamage_Custom extends X2Effect_ApplyWeaponDamage;

simulated function int CalculateDamageAmount(const out EffectAppliedData ApplyEffectParameters, out int ArmorMitigation, out int NewRupture, out int NewShred, out array<Name> AppliedDamageTypes, out int bAmmoIgnoresShields, out int bFullyImmune, out array<DamageModifierInfo> SpecialDamageMessages, optional XComGameState NewGameState)
{
	local int iDamage, Pierce;
	
	local XComGameStateHistory History;
	local XComGameState_Unit kSourceUnit;
	local Damageable kTarget;
	local XComGameState_Ability kAbility;
	local XComGameState_Item kSourceItem, LoadedAmmo;
	local X2AmmoTemplate AmmoTemplate;
	local array<X2WeaponUpgradeTemplate> WeaponUpgradeTemplates;
	local X2WeaponUpgradeTemplate WeaponUpgradeTemplate;
	local WeaponDamageValue BaseDamageValue, ExtraDamageValue, BonusEffectDamageValue, AmmoDamageValue;
	
	History = `XCOMHISTORY;
	kSourceUnit = XComGameState_Unit(History.GetGameStateForObjectID(ApplyEffectParameters.SourceStateObjectRef.ObjectID));	
	kTarget = Damageable(History.GetGameStateForObjectID(ApplyEffectParameters.TargetStateObjectRef.ObjectID));
	kAbility = XComGameState_Ability(History.GetGameStateForObjectID(ApplyEffectParameters.AbilityStateObjectRef.ObjectID));
	if (kAbility != none && kAbility.SourceAmmo.ObjectID > 0)
		kSourceItem = XComGameState_Item(History.GetGameStateForObjectID(kAbility.SourceAmmo.ObjectID));		
	else
		kSourceItem = XComGameState_Item(History.GetGameStateForObjectID(ApplyEffectParameters.ItemStateObjectRef.ObjectID));		

	if (!bIgnoreBaseDamage)
	{
		kSourceItem.GetBaseWeaponDamageValue(XComGameState_BaseObject(kTarget), BaseDamageValue);
		Pierce += BaseDamageValue.Pierce;
	}
	if (DamageTag != '')
	{
		kSourceItem.GetWeaponDamageValue(XComGameState_BaseObject(kTarget), DamageTag, ExtraDamageValue);
		Pierce += ExtraDamageValue.Pierce;
	}
	if (kSourceItem.HasLoadedAmmo() && !bIgnoreBaseDamage)
	{
		LoadedAmmo = XComGameState_Item(History.GetGameStateForObjectID(kSourceItem.LoadedAmmo.ObjectID));
		AmmoTemplate = X2AmmoTemplate(LoadedAmmo.GetMyTemplate());
		if (AmmoTemplate != none)
		{
			AmmoTemplate.GetTotalDamageModifier(LoadedAmmo, kSourceUnit, XComGameState_BaseObject(kTarget), AmmoDamageValue);
		}
		else
		{
			LoadedAmmo.GetBaseWeaponDamageValue(XComGameState_BaseObject(kTarget), AmmoDamageValue);
		}
		Pierce += AmmoDamageValue.Pierce;
	}
	if (bAllowWeaponUpgrade)
	{
		WeaponUpgradeTemplates = kSourceItem.GetMyWeaponUpgradeTemplates();
		foreach WeaponUpgradeTemplates(WeaponUpgradeTemplate)
		{
			if (WeaponUpgradeTemplate.BonusDamage.Tag == DamageTag)
			{
				Pierce += WeaponUpgradeTemplate.BonusDamage.Pierce;
			}
		}
	}
	
	BonusEffectDamageValue = GetBonusEffectDamageValue(kAbility, kSourceUnit, kSourceItem, ApplyEffectParameters.TargetStateObjectRef);
	Pierce += BonusEffectDamageValue.Pierce;

	iDamage = Super.CalculateDamageAmount(ApplyEffectParameters, ArmorMitigation, NewRupture, NewShred, AppliedDamageTypes, bAmmoIgnoresShields, bFullyImmune, SpecialDamageMessages, NewGameState);

	if (!bIgnoreBaseDamage) {
		class'CoverDR_Impl'.static.ApplyCoverDR(iDamage, ApplyEffectParameters, ArmorMitigation, Pierce, self);
	}

	return iDamage;
}

simulated function AddX2ActionsForVisualization(XComGameState VisualizeGameState, out VisualizationActionMetadata ActionMetadata, name EffectApplyResult)
{
	local X2Action_DisplayCoverDR UnitAction;
	local Array<X2Action> ParentArray;

	if( ActionMetadata.StateObject_NewState.IsA('XComGameState_Unit') )
	{		
		if ((HideVisualizationOfResults.Find(EffectApplyResult) != INDEX_NONE) ||
			(HideVisualizationOfResultsAdditional.Find(EffectApplyResult) != INDEX_NONE))
		{
			return;
		}

		UnitAction = X2Action_DisplayCoverDR(class'X2Action_DisplayCoverDR'.static.AddToVisualizationTree(ActionMetadata, VisualizeGameState.GetContext(),,, ParentArray));//auto-parent to damage initiating action
		UnitAction.OriginatingEffect = self;
	}

	Super.AddX2ActionsForVisualization(VisualizeGameState, ActionMetadata, EffectApplyResult);
}
