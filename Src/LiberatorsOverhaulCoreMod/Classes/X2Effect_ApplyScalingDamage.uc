class X2Effect_ApplyScalingDamage extends X2Effect_ApplyWeaponDamage;

//	Applies damage that scales on soldier's rank.

var float BonusDamagePerRank;

function WeaponDamageValue GetBonusEffectDamageValue(XComGameState_Ability AbilityState, XComGameState_Unit SourceUnit, XComGameState_Item SourceWeapon, StateObjectReference TargetRef)
{
	local WeaponDamageValue DamageValue; 

	DamageValue = EffectDamageValue;

	DamageValue.Damage += FCeil(BonusDamagePerRank * SourceUnit.GetSoldierRank());

	return DamageValue;
}

defaultproperties
{
	bIgnoreBaseDamage = true
}