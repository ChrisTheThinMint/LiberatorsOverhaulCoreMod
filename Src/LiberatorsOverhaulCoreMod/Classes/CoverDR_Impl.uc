class CoverDR_Impl extends Object config (GameCore);

var config float HALFCOVER_DMG_REDUCTION;
var config float FULLCOVER_DMG_REDUCTION;

var config bool REACTIONS_IGNORE_STATIC_DR;

var config float HALFCOVER_DMG_REDUCTION_MULT;
var config float FULLCOVER_DMG_REDUCTION_MULT;

var config bool REACTIONS_IGNORE_MULT_DR;

var config float HALFCOVER_DMG_REDUCTION_MAX;
var config float FULLCOVER_DMG_REDUCTION_MAX;

var config bool EXPLOSIVES_IGNORE_DR;
var config bool MELEE_IGNORES_DR;

var config bool ENSURE_MINIMUM_DAMAGE;

var config float UNFLANKABLE_DR;

var config bool LOG_DETAILS;

var localized string MitigationMessage;
var localized string MitigationNoCoverMessage;

static function ApplyCoverDR(out int iDamage, const out EffectAppliedData ApplyEffectParameters, out int ArmorMitigation, out int Pierce, X2Effect_ApplyWeaponDamage SourceDamage)
{
	local XComGameStateHistory History;
	local XComGameState_Unit kSourceUnit;
	local Damageable kTarget;
	local XComGameState_Unit TargetUnit;
	local GameRulesCache_VisibilityInfo VisInfo;
	local ECoverType TargetCover;
	local WeaponDamageValue BaseDamageValue;
	local XComGameState_Item kSourceItem;
	local XComGameState_Ability kAbility;
	local X2AbilityToHitCalc_StandardAim StandardAimHitCalc;
	local X2AbilityToHitCalc AbilityToHitCalc;

	local bool bIsReaction, bExplosive;
	local int iReduction, iRoll;
	local float sReduction, mReduction, fReduction, AbilityRadius, Distance;
	local Vector TargetVector;
	local Array<Vector> HitLocations;
	
	// don't affect 0 damage or less (fix for Fortress etc.)
	if (iDamage <= 0) 
	{
		`LOG("Cover Damage Reduction - Damage is 0 or less, didn't apply");
		return;
	}

	iRoll = `SYNC_RAND_STATIC(100);

	History = `XCOMHISTORY;
	kTarget = Damageable(History.GetGameStateForObjectID(ApplyEffectParameters.TargetStateObjectRef.ObjectID));

	TargetUnit = XComGameState_Unit(kTarget);
	// Can the target even take cover?
	if (!TargetUnit.CanTakeCover())
	{
		if(default.UNFLANKABLE_DR <= 0.0f)
		{
			`LOG("Cover Damage Reduction - Defender can't take cover, no unflankable dr, didn't apply");
			return;
		}
	}
	
	kSourceUnit = XComGameState_Unit(History.GetGameStateForObjectID(ApplyEffectParameters.SourceStateObjectRef.ObjectID));
	kAbility = XComGameState_Ability(History.GetGameStateForObjectID(ApplyEffectParameters.AbilityStateObjectRef.ObjectID));
	if (kAbility.SourceAmmo.ObjectID > 0)
		kSourceItem = XComGameState_Item(History.GetGameStateForObjectID(kAbility.SourceAmmo.ObjectID));		
	else
		kSourceItem = XComGameState_Item(History.GetGameStateForObjectID(ApplyEffectParameters.ItemStateObjectRef.ObjectID));		

	if (kSourceItem != none)
	{
		// find the base damage spec, if it's armor piercing, don't add DR
		kSourceItem.GetBaseWeaponDamageValue(XComGameState_BaseObject(kTarget), BaseDamageValue);
		if (SourceDamage.bIgnoreArmor) 
		{
			`LOG("Cover Damage Reduction - Attacker damage ignores armor, didn't apply");
			return;
		}

		if (kSourceItem.InventorySlot == eInvSlot_PrimaryWeapon && kSourceUnit.HasAbilityFromAnySource('IRI_FireArtilleryCannon_AP_Passive'))
		{
			`LOG("Cover Damage Reduction - Attacker weapon pierces cover, didn't apply");
			return;
		}
	}

	TargetCover = CT_None;
	// Determine cover state and visibility
	if (`TACTICALRULES.VisibilityMgr.GetVisibilityInfo(kSourceUnit.ObjectID, TargetUnit.ObjectID, VisInfo))
	{
		TargetCover = VisInfo.TargetCover;
	}

	// ability handling
	if (kAbility != none)
	{
		AbilityRadius = kAbility.GetAbilityRadius();

		if (default.EXPLOSIVES_IGNORE_DR) 
		{
			`LOG("Cover Damage Reduction - Explosives are set to ignore cover, didn't apply");
			return;
		}
		else if (AbilityRadius > 0)
		{
			
			if (kSourceItem != None && kSourceItem.GetItemEnvironmentDamage() == 0 && SourceDamage.EnvironmentalDamageAmount == 0) 
			{
				`LOG("Cover Damage Reduction - Explosive is AP/Elemental, didn't apply");
				return;
			} 
			else
			{
				bExplosive = true;

				HitLocations = ApplyEffectParameters.AbilityInputContext.TargetLocations;

				if (HitLocations.Length == 1) 
				{
					TargetVector = class'XComWorldData'.static.GetWorldData().GetPositionFromTileCoordinates(TargetUnit.TileLocation);
					TargetCover = class'XComWorldData'.static.GetWorldData().GetCoverTypeForTarget(HitLocations[0], TargetVector, VisInfo.TargetCoverAngle);
				}
			}
		}

		AbilityToHitCalc = kAbility.GetMyTemplate().AbilityToHitCalc;
		StandardAimHitCalc = X2AbilityToHitCalc_StandardAim(AbilityToHitCalc);
		if(StandardAimHitCalc != None)
		{
			if(StandardAimHitCalc.bMeleeAttack && default.MELEE_IGNORES_DR)
			{
				`LOG("Cover Damage Reduction - Melee attacks are set to ignore cover, didn't apply");
				return;
			}

			if(StandardAimHitCalc.bReactionFire)
			{
				bIsReaction = true;
			}
		}
	}

	if(TargetUnit.CanTakeCover())
	{
		switch(TargetCover)
		{  
			case CT_MidLevel: // half cover
				sReduction = default.HALFCOVER_DMG_REDUCTION;
				mReduction = default.HALFCOVER_DMG_REDUCTION_MULT * iDamage;
			break;
			case CT_Standing: // full cover
				sReduction = default.FULLCOVER_DMG_REDUCTION;
				mReduction = default.FULLCOVER_DMG_REDUCTION_MULT * iDamage;
			break;
			default:
				sReduction = 0.0;
				mReduction = 0.0;
			break;
		}

		if(bIsReaction)
		{
			if(default.REACTIONS_IGNORE_STATIC_DR)
			{
				sReduction = 0.0;
			}
			if(default.REACTIONS_IGNORE_MULT_DR)
			{
				mReduction = 0.0;
			}
		}

		fReduction = sReduction + mReduction;

		// cap max dr
		switch(TargetCover)
		{  
			case CT_MidLevel: // half cover
				fReduction = fmin(fReduction, default.HALFCOVER_DMG_REDUCTION_MAX);
			break;
			case CT_Standing: // full cover
				fReduction = fmin(fReduction, default.FULLCOVER_DMG_REDUCTION_MAX);
			break;
		}
	}
	else
	{
		fReduction = default.UNFLANKABLE_DR;
	}

	iReduction = int(fReduction);
	// extra DR chance (floating point DR)
	if ((fReduction - iReduction) * 100 > iRoll) 
	{ 
		iReduction++; 
	}

	if(iReduction > iDamage - 1)
	{
		iReduction = iDamage - 1;
	}

	// apply pierce, but keep dr above 0
	if(iReduction > 0)
	{
		iReduction = fmax(iReduction - Pierce, 0);
	}

	// make sure there is a minimum damage of 1
	if(default.ENSURE_MINIMUM_DAMAGE)
	{
		iReduction = fmin(iReduction, iDamage-1);
	}

	iDamage -= iReduction;
	ArmorMitigation += iReduction;
	
	if(default.LOG_DETAILS)
	{
		`LOG("Cover Damage Reduction - Applied. Results:");
		`LOG("Cover Damage Reduction - Damage:" @ iDamage @ "| Pierce:" @ Pierce);
		if(TargetUnit.CanTakeCover())
		{
			`LOG("Cover Damage Reduction - Cover Status:" @ TargetCover);
		}
		else
		{
			`LOG("Cover Damage Reduction - Cover Status: Unflankable");
		}
		`LOG("Cover Damage Reduction - Was reaction:" @ bIsReaction @ "| Was explosive:" @ bExplosive);
		`LOG("Cover Damage Reduction - sDR:" @ sReduction @ "| mDR:" @ mReduction @ "| fDR:" @ fReduction @ "| iDR:" @ iReduction);
	}
	else
	{
		`LOG("Cover Damage Reduction - Applied. Final DR:" @ iReduction);
	}
}

static function bool IsTargetVisible(Vector Location, XComGameState_Unit TargetUnit) {
	local TTile TargetTile;
	local VoxelRaytraceCheckResult VisInfo;

	TargetTile = `XWORLD.GetTileCoordinatesFromPosition( Location );

	`LOG("Tile check: " @ TargetTile.X @ " " @ TargetTile.Y @ " " @ TargetTile.Z @ " vs " @ TargetUnit.TileLocation.X @ " " @ TargetUnit.TileLocation.Y @ " " @ TargetUnit.TileLocation.Z);
	return !`XWORLD.VoxelRaytrace_Tiles( TargetTile, TargetUnit.TileLocation, VisInfo );
}