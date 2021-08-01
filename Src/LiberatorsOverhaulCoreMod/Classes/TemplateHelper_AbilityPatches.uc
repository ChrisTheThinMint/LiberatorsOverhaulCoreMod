class TemplateHelper_AbilityPatches extends Object config(Game);

var config array<name> ItemAbilitiesToPatch;
var config array<name> HackAbilitiesToPatch;
var config array<name> AbilitiesToPatchForQuickdraw;
var config array<name> AbilitiesToPatchForOverclock;
var config array<name> AbilitiesToPatchForBrace;

var config float HAYMAKER_BONUS_DAMAGE_PER_RANK;
var config WeaponDamageValue HAYMAKER_BASEDAMAGE;

static function PatchAbilityTemplates()
{
	local X2AbilityTemplateManager			AbilityTemplateManager;
	local array<X2DataTemplate>				TemplateAllDifficulties;
	local X2DataTemplate					Template;
	local X2AbilityTemplate					AbilityTemplate;
	local name								TemplateName;
	
	local X2AbilityCost_ActionPoints		ActionPointCost;
	local X2AbilityCost_Ammo                AmmoCost;
	local X2AbilityCost						AbilityCost;
    local X2AbilityCharges					Charges;
    local X2AbilityCost_Charges				ChargeCost;
	local X2Effect_Knockback				KnockbackEffect;
	local X2Effect_ApplyScalingDamage		DamageEffect;
	local X2Effect							TargetEffect;
	local X2AbilityToHitCalc_StandardMelee  StandardMelee;
	local X2Effect_PersistentStatChange		PersistentStatChangeEffect;
	local X2Condition_AbilityProperty		AbilityCondition;
	local X2Condition_UnitProperty			FriendlyCondition;
	local X2Condition_Visibility			VisCondition;
	local X2Condition						Condition;
	local X2AbilityCooldown					Cooldown;

	AbilityTemplateManager = class'X2AbilityTemplateManager'.static.GetAbilityTemplateManager();

	Patch_AbilityIcon('RPGORebalance_BITSalvo', "img:///UILibrary_DLC3Images.UIPerk_spark_overdrive", AbilityTemplateManager);

	Patch_MakeAbilityBlueAction('LW2WotC_SteadyWeapon', AbilityTemplateManager);

	Patch_ChangeAbilityCooldown('MusashiThrowKnife', 3, AbilityTemplateManager);

	Patch_AddAdditionalAbility('ShadowOps_ControlledDetonation', 'LW2WotC_BoostedCores', AbilityTemplateManager);
	Patch_AddAdditionalAbility('ShadowOps_ControlledDetonation', 'ShadowOps_DangerZone', AbilityTemplateManager);
	Patch_AddAdditionalAbility('ShadowOps_ImprovedSuppression', 'WOTC_APA_Suppression', AbilityTemplateManager);
	Patch_AddAdditionalAbility('ShadowOps_ImprovedSuppression', 'WOTC_APA_SuppressionShot', AbilityTemplateManager);
	Patch_AddAdditionalAbility('WOTC_APA_SuppressionZone', 'WOTC_APA_SuppressionZoneShot', AbilityTemplateManager);
	Patch_AddAdditionalAbility('WOTC_APA_SuppressionZone', 'WOTC_APA_SuppressionZoneShotCF', AbilityTemplateManager);
	Patch_AddAdditionalAbility('LW2WotC_GrazingFire', 'WOTC_APA_WitheringBarrage', AbilityTemplateManager);
	Patch_AddAdditionalAbility('WOTC_APA_AdvancedTraumaKits', 'WOTC_APA_ManageRevive', AbilityTemplateManager);
	
	Patch_RemoveAdditionalAbility('PerfectPlan', 'LW2WotC_Failsafe', AbilityTemplateManager);

	Patch_AllowSquadsight('WOTC_APA_Suppression', AbilityTemplateManager);
	Patch_AllowSquadsight('WOTC_APA_SuppressionShot', AbilityTemplateManager);

	Patch_StormriderTeleport(AbilityTemplateManager);
	Patch_APATargetingUplink(AbilityTemplateManager);
	Patch_HaywireProtocol(AbilityTemplateManager);
	Patch_TrenchWarfare(AbilityTemplateManager);
	Patch_ReturnFire(AbilityTemplateManager);
	Patch_ShieldStomp(AbilityTemplateManager);
	Patch_Reload(AbilityTemplateManager);
	Patch_MedicalSpecialist(AbilityTemplateManager);
	Patch_Haymaker(AbilityTemplateManager);
	Patch_ShotgunCharge(AbilityTemplateManager);
	Patch_SatStrike(AbilityTemplateManager);
	Patch_FirstAid(AbilityTemplateManager);

	foreach default.HackAbilitiesToPatch(TemplateName)
	{
		Patch_HackAbility(TemplateName, AbilityTemplateManager);
	}
	
	foreach default.AbilitiesToPatchForQuickdraw(TemplateName)
	{
		Patch_Quickdraw(TemplateName, AbilityTemplateManager);
	}

	foreach default.AbilitiesToPatchForOverclock(TemplateName)
	{
		Patch_Overclock(TemplateName, AbilityTemplateManager);
	}

	foreach default.AbilitiesToPatchForBrace(TemplateName)
	{
		Patch_RequireBrace(TemplateName, AbilityTemplateManager);
	}

	foreach default.ItemAbilitiesToPatch(TemplateName)
	{
		Patch_ItemTotalCombat(TemplateName, AbilityTemplateManager);
	}
}

static function Patch_AbilityIcon(name AbilityTemplateName, string imgPath, X2AbilityTemplateManager AbilityTemplateManager)
{
	local array<X2DataTemplate>				TemplateAllDifficulties;
	local X2DataTemplate					Template;
	local X2AbilityTemplate					AbilityTemplate;
	local name								TemplateName;

	AbilityTemplateManager.FindDataTemplateAllDifficulties(AbilityTemplateName, TemplateAllDifficulties);
	foreach TemplateAllDifficulties(Template)
	{
		AbilityTemplate = X2AbilityTemplate(Template);

		if (AbilityTemplate != none)
		{
			`LOG("Ability template" @ AbilityTemplate.DataName @ "exists, patching...", ,'LiberatorsOverhaul');
			AbilityTemplate.IconImage = imgPath;
			`LOG("Changed ability icon image:" @ imgPath, ,'LiberatorsOverhaul');
		}
	}
}

static function Patch_MakeAbilityBlueAction(name AbilityTemplateName, X2AbilityTemplateManager AbilityTemplateManager)
{
	local array<X2DataTemplate>				TemplateAllDifficulties;
	local X2DataTemplate					Template;
	local X2AbilityTemplate					AbilityTemplate;
	local name								TemplateName;
	local X2AbilityCost_ActionPoints		ActionPointCost;
	local X2AbilityCost						AbilityCost;

	AbilityTemplateManager.FindDataTemplateAllDifficulties(AbilityTemplateName, TemplateAllDifficulties);
	foreach TemplateAllDifficulties(Template)
	{
		AbilityTemplate = X2AbilityTemplate(Template);

		if (AbilityTemplate != none)
		{
			`LOG("Ability template" @ AbilityTemplate.DataName @ "exists, patching...", ,'LiberatorsOverhaul');

			foreach AbilityTemplate.AbilityCosts(AbilityCost)
			{
				ActionPointCost = X2AbilityCost_ActionPoints(AbilityCost);

				if(ActionPointCost != none)
				{
					`LOG("Changed ability cost to not consume all actions", ,'LiberatorsOverhaul');
					ActionPointCost.bConsumeAllPoints = false;
				}
			}
		}
	}
}

static function Patch_ChangeAbilityCooldown(name AbilityTemplateName, int NewCooldown, X2AbilityTemplateManager AbilityTemplateManager)
{
	local array<X2DataTemplate>				TemplateAllDifficulties;
	local X2DataTemplate					Template;
	local X2AbilityTemplate					AbilityTemplate;
	local name								TemplateName;
	local X2AbilityCooldown					Cooldown;

	AbilityTemplateManager.FindDataTemplateAllDifficulties(AbilityTemplateName, TemplateAllDifficulties);
	foreach TemplateAllDifficulties(Template)
	{
		AbilityTemplate = X2AbilityTemplate(Template);

		if (AbilityTemplate != none)
		{
			`LOG("Ability template" @ AbilityTemplate.DataName @ "exists, patching...", ,'LiberatorsOverhaul');
			
			Cooldown = new class'X2AbilityCooldown';
			Cooldown.iNumTurns = NewCooldown;
			AbilityTemplate.AbilityCooldown = Cooldown;
		}
	}
}

static function Patch_AddAdditionalAbility(name AbilityTemplateName, name AdditionalTemplateName, X2AbilityTemplateManager AbilityTemplateManager)
{
	local array<X2DataTemplate>				TemplateAllDifficulties;
	local X2DataTemplate					Template;
	local X2AbilityTemplate					AbilityTemplate;
	local name								TemplateName;

	AbilityTemplateManager.FindDataTemplateAllDifficulties(AbilityTemplateName, TemplateAllDifficulties);
	foreach TemplateAllDifficulties(Template)
	{
		AbilityTemplate = X2AbilityTemplate(Template);

		if (AbilityTemplate != none)
		{
			`LOG("Ability template" @ AbilityTemplate.DataName @ "exists, patching...", ,'LiberatorsOverhaul');
			AbilityTemplate.AdditionalAbilities.AddItem(AdditionalTemplateName);
			`LOG("Added additional ability: " @ AdditionalTemplateName, ,'LiberatorsOverhaul');
		}
	}
}

static function Patch_RemoveAdditionalAbility(name AbilityTemplateName, name AdditionalTemplateName, X2AbilityTemplateManager AbilityTemplateManager)
{
	local array<X2DataTemplate>				TemplateAllDifficulties;
	local X2DataTemplate					Template;
	local X2AbilityTemplate					AbilityTemplate;
	local name								TemplateName;

	AbilityTemplateManager.FindDataTemplateAllDifficulties(AbilityTemplateName, TemplateAllDifficulties);
	foreach TemplateAllDifficulties(Template)
	{
		AbilityTemplate = X2AbilityTemplate(Template);

		if (AbilityTemplate != none)
		{
			`LOG("Ability template" @ AbilityTemplate.DataName @ "exists, patching...", ,'LiberatorsOverhaul');
			AbilityTemplate.AdditionalAbilities.RemoveItem(AdditionalTemplateName);
			`LOG("Added additional ability: " @ AdditionalTemplateName, ,'LiberatorsOverhaul');
		}
	}
}

static function Patch_AllowSquadsight(name AbilityTemplateName, X2AbilityTemplateManager AbilityTemplateManager)
{
	local array<X2DataTemplate>				TemplateAllDifficulties;
	local X2DataTemplate					Template;
	local X2AbilityTemplate					AbilityTemplate;
	local name								TemplateName;
	local X2Condition_Visibility			VisCondition;
	local X2Condition						Condition;

	AbilityTemplateManager.FindDataTemplateAllDifficulties(AbilityTemplateName, TemplateAllDifficulties);
	foreach TemplateAllDifficulties(Template)
	{
		AbilityTemplate = X2AbilityTemplate(Template);

		if (AbilityTemplate != none)
		{
			`LOG("Ability template" @ AbilityTemplate.DataName @ "exists, patching...", ,'LiberatorsOverhaul');
			foreach AbilityTemplate.AbilityTargetConditions(Condition)
			{
				VisCondition = X2Condition_Visibility(Condition);

				if(VisCondition != none)
				{	
					VisCondition.bAllowSquadsight = true;
					VisCondition.bRequireBasicVisibility = false;
					`LOG("Changed visibility condition to allow for squadsight", ,'LiberatorsOverhaul');
				}
			}
		}
	}
}

static function Patch_StormriderTeleport(X2AbilityTemplateManager AbilityTemplateManager)
{
	local array<X2DataTemplate>				TemplateAllDifficulties;
	local X2DataTemplate					Template;
	local X2AbilityTemplate					AbilityTemplate;
	local name								TemplateName;
	local X2Condition_UnitProperty			FriendlyCondition;

	AbilityTemplateManager.FindDataTemplateAllDifficulties('IRI_Rider_Teleport', TemplateAllDifficulties);
	foreach TemplateAllDifficulties(Template)
	{
		AbilityTemplate = X2AbilityTemplate(Template);

		if (AbilityTemplate != none)
		{
			`LOG("Ability template" @ AbilityTemplate.DataName @ "exists, patching...", ,'LiberatorsOverhaul');

			`LOG("Removed old target conditions", ,'LiberatorsOverhaul');
			AbilityTemplate.AbilityTargetConditions.Length = 0;
			
			//  Readd all target conditions except the conduit one
			//	There must be a free tile around the target unit
			AbilityTemplate.AbilityTargetConditions.AddItem(new class'X2Condition_UnblockedNeighborTile');

			//	idk what this does
			AbilityTemplate.AbilityTargetConditions.AddItem(new class'X2Condition_Wrath');

			// The Target must be alive and a humanoid
			FriendlyCondition = new class'X2Condition_UnitProperty';
			FriendlyCondition.ExcludeDead = true;
			FriendlyCondition.ExcludeRobotic = false;
			FriendlyCondition.RequireSquadmates = true;
			FriendlyCondition.ExcludeCivilian = true;
			FriendlyCondition.ExcludeHostileToSource = true;
			FriendlyCondition.ExcludeFriendlyToSource = false;
			FriendlyCondition.ExcludeCosmetic = true;
			FriendlyCondition.TreatMindControlledSquadmateAsHostile = true;
			FriendlyCondition.FailOnNonUnits = true;
			//FriendlyCondition.RequireWithinMinRange = true;
			AbilityTemplate.AbilityTargetConditions.AddItem(FriendlyCondition);
			`LOG("Readded target conditions except line of sight", ,'LiberatorsOverhaul');
			
			AbilityTemplate.AdditionalAbilities.RemoveItem('IRI_Rider_InterceptionReturnTeleport');
			`LOG("Removed bonus interaction with Intercept", ,'LiberatorsOverhaul');
		}
	}
}

static function Patch_APATargetingUplink(X2AbilityTemplateManager AbilityTemplateManager)
{
	local array<X2DataTemplate>				TemplateAllDifficulties;
	local X2DataTemplate					Template;
	local X2AbilityTemplate					AbilityTemplate;
	local name								TemplateName;
	local X2Condition_UnitProperty			FriendlyCondition;
	local X2Condition_Visibility			VisCondition;
	local X2AbilityCost_ActionPoints		ActionPointCost;
	local X2AbilityCost						AbilityCost;

	AbilityTemplateManager.FindDataTemplateAllDifficulties('WOTC_APA_TargetingUplink', TemplateAllDifficulties);
	foreach TemplateAllDifficulties(Template)
	{
		AbilityTemplate = X2AbilityTemplate(Template);

		if (AbilityTemplate != none)
		{
			`LOG("Ability template" @ AbilityTemplate.DataName @ "exists, patching...", ,'LiberatorsOverhaul');
			
			`LOG("Removed old target conditions", ,'LiberatorsOverhaul');
			AbilityTemplate.AbilityTargetConditions.Length = 0;

			FriendlyCondition = new class'X2Condition_UnitProperty';
			FriendlyCondition.ExcludeOrganic = false;
			FriendlyCondition.ExcludeDead = true;
			FriendlyCondition.ExcludeHostileToSource = true;
			FriendlyCondition.ExcludeFriendlyToSource = false;
			AbilityTemplate.AbilityTargetConditions.AddItem(FriendlyCondition);

			VisCondition = new class'X2Condition_Visibility';
			VisCondition.bRequireGameplayVisible = true;
			VisCondition.bActAsSquadsight = true;
			AbilityTemplate.AbilityTargetConditions.AddItem(VisCondition);
			`LOG("Adding new target condition: any visible ally", ,'LiberatorsOverhaul');

			foreach AbilityTemplate.AbilityCosts(AbilityCost)
			{
				ActionPointCost = X2AbilityCost_ActionPoints(AbilityCost);

				if(ActionPointCost != none)
				{
					ActionPointCost.bConsumeAllPoints = false;
				}
			}
			`LOG("Changed ability cost to not consume all actions", ,'LiberatorsOverhaul');
		}
	}
}

static function Patch_HaywireProtocol(X2AbilityTemplateManager AbilityTemplateManager)
{
	local array<X2DataTemplate>				TemplateAllDifficulties;
	local X2DataTemplate					Template;
	local X2AbilityTemplate					AbilityTemplate;
	local name								TemplateName;
    local X2AbilityCharges					Charges;
    local X2AbilityCost_Charges				ChargeCost;

	AbilityTemplateManager.FindDataTemplateAllDifficulties('HaywireProtocol', TemplateAllDifficulties);
	foreach TemplateAllDifficulties(Template)
	{
		AbilityTemplate = X2AbilityTemplate(Template);

		if (AbilityTemplate != none)
		{
			`LOG("Ability template" @ AbilityTemplate.DataName @ "exists, patching...", ,'LiberatorsOverhaul');
			
			Charges = new class'X2AbilityCharges';
			Charges.InitialCharges = 1;
			AbilityTemplate.AbilityCharges = Charges;
			`LOG("Changed ability cost to one charge", ,'LiberatorsOverhaul');

			ChargeCost = new class'X2AbilityCost_Charges';
			ChargeCost.NumCharges = 1;
			ChargeCost.bOnlyOnHit = true;
			AbilityTemplate.AbilityCosts.AddItem(ChargeCost);
			`LOG("Changed ability to have one charge by default", ,'LiberatorsOverhaul');
		}
	}

	AbilityTemplateManager.FindDataTemplateAllDifficulties('CancelHaywire', TemplateAllDifficulties);
	foreach TemplateAllDifficulties(Template)
	{
		AbilityTemplate = X2AbilityTemplate(Template);

		if (AbilityTemplate != none)
		{
			`LOG("Ability template" @ AbilityTemplate.DataName @ "exists, patching...", ,'LiberatorsOverhaul');
			
			AbilityTemplate.BuildNewGameStateFn = CancelFullOverride_BuildGameState;
			`LOG("Added custom game state builder", ,'LiberatorsOverhaul');
		}
	}

	AbilityTemplateManager.FindDataTemplateAllDifficulties('FinalizeHaywire', TemplateAllDifficulties);
	foreach TemplateAllDifficulties(Template)
	{
		AbilityTemplate = X2AbilityTemplate(Template);

		if (AbilityTemplate != none)
		{
			`LOG("Ability template" @ AbilityTemplate.DataName @ "exists, patching...", ,'LiberatorsOverhaul');
			
			AbilityTemplate.BuildNewGameStateFn = CancelFullOverride_BuildGameState;
			`LOG("Added custom game state builder", ,'LiberatorsOverhaul');
		}
	}

}

static function Patch_Interference(X2AbilityTemplateManager AbilityTemplateManager)
{
	local array<X2DataTemplate>				TemplateAllDifficulties;
	local X2DataTemplate					Template;
	local X2AbilityTemplate					AbilityTemplate;
	local name								TemplateName;

	AbilityTemplateManager.FindDataTemplateAllDifficulties('LW2WotC_Interference', TemplateAllDifficulties);
	foreach TemplateAllDifficulties(Template)
	{
		AbilityTemplate = X2AbilityTemplate(Template);

		if (AbilityTemplate != none)
		{
			`LOG("Ability template" @ AbilityTemplate.DataName @ "exists, patching...", ,'LiberatorsOverhaul');
			
			AbilityTemplate.AddTargetEffect(new class'X2Effect_DisableWeapon');
			`LOG("Added weapon disabling effect", ,'LiberatorsOverhaul');
		}
	}
}

static function Patch_TrenchWarfare(X2AbilityTemplateManager AbilityTemplateManager)
{
	local array<X2DataTemplate>				TemplateAllDifficulties;
	local X2DataTemplate					Template;
	local X2AbilityTemplate					AbilityTemplate;
	local name								TemplateName;
	local X2Condition_UnitProperty			FriendlyCondition;
	local X2Effect_PersistentStatChange		PersistentStatChangeEffect;

	AbilityTemplateManager.FindDataTemplateAllDifficulties('TF_TrenchWarfare', TemplateAllDifficulties);
	foreach TemplateAllDifficulties(Template)
	{
		AbilityTemplate = X2AbilityTemplate(Template);

		if (AbilityTemplate != none)
		{
			`LOG("Ability template" @ AbilityTemplate.DataName @ "exists, patching...", ,'LiberatorsOverhaul');
			
			`LOG("Removed old effects", ,'LiberatorsOverhaul');
			AbilityTemplate.AbilityMultiTargetEffects.Length = 0;

			FriendlyCondition = new class'X2Condition_UnitProperty';
			FriendlyCondition.ExcludeAlive = false;
			FriendlyCondition.ExcludeDead = true;
			FriendlyCondition.ExcludeCivilian = true;
			FriendlyCondition.ExcludeUnableToAct = true;
			FriendlyCondition.ExcludeHostileToSource = true;
			FriendlyCondition.FailOnNonUnits = true;

			PersistentStatChangeEffect = new class'X2Effect_PersistentStatChange';
			PersistentStatChangeEffect.EffectName = 'TrenchWarfare';
			PersistentStatChangeEffect.BuildPersistentEffect(2, false, false, false, eGameRule_PlayerTurnEnd);
			PersistentStatChangeEffect.DuplicateResponse = eDupe_Refresh;
			PersistentStatChangeEffect.AddPersistentStatChange(eStat_Defense, 10);
			PersistentStatChangeEffect.TargetConditions.AddItem(FriendlyCondition);
			PersistentStatChangeEffect.VisualizationFn = EffectFlyOver_Visualization;

			AbilityTemplate.AddMultiTargetEffect(PersistentStatChangeEffect);
			`LOG("Added new defense effect", ,'LiberatorsOverhaul');
		}
	}
}

static function Patch_ReturnFire(X2AbilityTemplateManager AbilityTemplateManager)
{
	local array<X2DataTemplate>				TemplateAllDifficulties;
	local X2DataTemplate					Template;
	local X2AbilityTemplate					AbilityTemplate;
	local name								TemplateName;
	local X2Condition_AbilityProperty		AbilityCondition;
	local X2Effect_PersistentStatChange		PersistentStatChangeEffect;

	AbilityTemplateManager.FindDataTemplateAllDifficulties('PistolReturnFire', TemplateAllDifficulties);
	foreach TemplateAllDifficulties(Template)
	{
		AbilityTemplate = X2AbilityTemplate(Template);

		if (AbilityTemplate != none)
		{
			`LOG("Ability template" @ AbilityTemplate.DataName @ "exists, patching...", ,'LiberatorsOverhaul');
			
			AbilityCondition = new class'X2Condition_AbilityProperty';
			AbilityCondition.OwnerHasSoldierAbilities.AddItem('GrimyBolsterPassive');

			PersistentStatChangeEffect = new class'X2Effect_PersistentStatChange';
			PersistentStatChangeEffect.BuildPersistentEffect(1, false, true, false, eGameRule_PlayerTurnEnd);
			PersistentStatChangeEffect.AddPersistentStatChange(eStat_ArmorMitigation, 1);
			PersistentStatChangeEffect.bApplyOnMiss = true;
			PersistentStatChangeEffect.TargetConditions.AddItem(AbilityCondition);
	
			AbilityTemplate.AddShooterEffect(PersistentStatChangeEffect);
			`LOG("Added new bonus effect for Bolster", ,'LiberatorsOverhaul');
		}
	}
}

static function Patch_ShieldStomp(X2AbilityTemplateManager AbilityTemplateManager)
{
	local array<X2DataTemplate>				TemplateAllDifficulties;
	local X2DataTemplate					Template;
	local X2AbilityTemplate					AbilityTemplate;
	local name								TemplateName;
	local X2AbilityToHitCalc_StandardMelee  StandardMelee;

	AbilityTemplateManager.FindDataTemplateAllDifficulties('MZRaptorCyclone', TemplateAllDifficulties);
	foreach TemplateAllDifficulties(Template)
	{
		AbilityTemplate = X2AbilityTemplate(Template);

		if (AbilityTemplate != none)
		{
			`LOG("Ability template" @ AbilityTemplate.DataName @ "exists, patching...", ,'LiberatorsOverhaul');
			
			AbilityTemplate.BuildVisualizationFn = Shielded_BuildVisualization;
			`LOG("Changed visualization", ,'LiberatorsOverhaul');
			
			StandardMelee = new class'X2AbilityToHitCalc_StandardMelee';
			StandardMelee.bMultiTargetOnly = true;
			StandardMelee.bGuaranteedHit = true;
			AbilityTemplate.AbilityToHitCalc = StandardMelee;
			`LOG("Changed hit calculation to be guaranteed", ,'LiberatorsOverhaul');

			AbilityTemplate.AdditionalAbilities.AddItem('MZRaptorWhirlwindPassive');
			AbilityTemplate.PrerequisiteAbilities.RemoveItem('MZRaptorWhirlwind');
			`LOG("Removed prerequisite ability", ,'LiberatorsOverhaul');
		}
	}
}

static function Patch_Reload(X2AbilityTemplateManager AbilityTemplateManager)
{
	local array<X2DataTemplate>				TemplateAllDifficulties;
	local X2DataTemplate					Template;
	local X2AbilityTemplate					AbilityTemplate;
	local name								TemplateName;
	local X2AbilityCost_ActionPoints		ActionPointCost;

	AbilityTemplateManager.FindDataTemplateAllDifficulties('Reload', TemplateAllDifficulties);
	foreach TemplateAllDifficulties(Template)
	{
		AbilityTemplate = X2AbilityTemplate(Template);

		if (AbilityTemplate != none)
		{
			`LOG("Ability template" @ AbilityTemplate.DataName @ "exists, patching...", ,'LiberatorsOverhaul');

			AbilityTemplate.AbilityCosts.Length = 0;
			`LOG("Removed old action cost", ,'LiberatorsOverhaul');

			ActionPointCost = new class'X2AbilityCost_ActionPoints';
			ActionPointCost.iNumPoints = 1;
			ActionPointCost.bConsumeAllPoints = true;
			ActionPointCost.bFreeCost = false;
			ActionPointCost.DoNotConsumeAllSoldierAbilities.AddItem('TotalCombat');
			ActionPointCost.DoNotConsumeAllSoldierAbilities.AddItem('Quickdraw');
			ActionPointCost.DoNotConsumeAllEffects.AddItem('DLC_3Overdrive');
			AbilityTemplate.AbilityCosts.AddItem(ActionPointCost);
			`LOG("Added new action cost", ,'LiberatorsOverhaul');
		}
	}
}

static function Patch_MedicalSpecialist(X2AbilityTemplateManager AbilityTemplateManager)
{
	local array<X2DataTemplate>				TemplateAllDifficulties;
	local X2DataTemplate					Template;
	local X2AbilityTemplate					AbilityTemplate;
	local X2Effect							TargetEffect;
	local name								TemplateName;

	AbilityTemplateManager.FindDataTemplateAllDifficulties('WOTC_APA_MedicalSpecialist', TemplateAllDifficulties);
	foreach TemplateAllDifficulties(Template)
	{
		AbilityTemplate = X2AbilityTemplate(Template);

		if (AbilityTemplate != none)
		{
			`LOG("Ability template" @ AbilityTemplate.DataName @ "exists, patching...", ,'LiberatorsOverhaul');
			// Remove the last effect, which should be the effect that grants revive in 99/100 cases
			// Unfortunately we dont have a precise way to check without compiling against APA
			// Gotta watch out for updates
			TargetEffect = AbilityTemplate.AbilityTargetEffects[AbilityTemplate.AbilityTargetEffects.Length - 1];
			AbilityTemplate.AbilityTargetEffects.RemoveItem(TargetEffect);
			`LOG("Hopefully removed revive effect", ,'LiberatorsOverhaul');
		}
	}
}

static function Patch_ShotgunCharge(X2AbilityTemplateManager AbilityTemplateManager)
{
	local array<X2DataTemplate>				TemplateAllDifficulties;
	local X2DataTemplate					Template;
	local X2AbilityTemplate					AbilityTemplate;
	local name								TemplateName;

	AbilityTemplateManager.FindDataTemplateAllDifficulties('WOTC_APA_Charge', TemplateAllDifficulties);
	foreach TemplateAllDifficulties(Template)
	{
		AbilityTemplate = X2AbilityTemplate(Template);

		if (AbilityTemplate != none)
		{
			`LOG("Ability template" @ AbilityTemplate.DataName @ "exists, patching...", ,'LiberatorsOverhaul');

			AbilityTemplate.AbilityToHitCalc = new class'X2AbilityToHitCalc_DeadEye';
			AbilityTemplate.AbilityToHitOwnerOnMissCalc = new class'X2AbilityToHitCalc_DeadEye';
			`LOG("Changed hit calculation to guaranteed hit", ,'LiberatorsOverhaul');

			AbilityTemplate.ActivationSpeech = 'RunAndGun';
			AbilityTemplate.bSkipMoveStop = false;
			`LOG("Changed visualization", ,'LiberatorsOverhaul');
		}
	}
}

static function Patch_Haymaker(X2AbilityTemplateManager AbilityTemplateManager)
{
	local array<X2DataTemplate>				TemplateAllDifficulties;
	local X2DataTemplate					Template;
	local X2AbilityTemplate					AbilityTemplate;
	local name								TemplateName;
	local X2AbilityToHitCalc_StandardMelee  StandardMelee;
	local X2Effect_ApplyScalingDamage		DamageEffect;
	local X2Effect_Knockback				KnockbackEffect;

	AbilityTemplateManager.FindDataTemplateAllDifficulties('IRI_Rider_Haymaker', TemplateAllDifficulties);
	foreach TemplateAllDifficulties(Template)
	{
		AbilityTemplate = X2AbilityTemplate(Template);

		if (AbilityTemplate != none)
		{
			`LOG("Ability template" @ AbilityTemplate.DataName @ "exists, patching...", ,'LiberatorsOverhaul');
			
			StandardMelee = new class'X2AbilityToHitCalc_StandardMelee';
			StandardMelee.BuiltInHitMod = 20;
			AbilityTemplate.AbilityToHitCalc = StandardMelee;	
			`LOG("Changed hit calculation to grant bonus aim", ,'LiberatorsOverhaul');

			AbilityTemplate.AbilityTargetEffects.Length = 0;
			`LOG("Removed old effects", ,'LiberatorsOverhaul');
			
			DamageEffect = new class'X2Effect_ApplyScalingDamage';
			DamageEffect.BonusDamagePerRank = default.HAYMAKER_BONUS_DAMAGE_PER_RANK;
			DamageEffect.EffectDamageValue = default.HAYMAKER_BASEDAMAGE;
			AbilityTemplate.AddTargetEffect(DamageEffect);
			`LOG("Added new scaling damage effect", ,'LiberatorsOverhaul');

			KnockbackEffect = new class'X2Effect_Knockback';
			KnockbackEffect.KnockbackDistance = 1;
			KnockbackEffect.bKnockbackDestroysNonFragile = false;
			KnockbackEffect.OnlyOnDeath = true;
			AbilityTemplate.AddTargetEffect(KnockbackEffect);
			`LOG("Added new knockback effect", ,'LiberatorsOverhaul');

			AbilityTemplate.ActionFireClass = class'X2Action_Fire_Haymaker';
			`LOG("Changed visualization", ,'LiberatorsOverhaul');
			//AbilityTemplate.CustomFireAnim = 'FF_Melee_Punch';
			//AbilityTemplate.CustomFireKillAnim = 'FF_Melee_Punch';
		}
	}
}

static function Patch_SatStrike(X2AbilityTemplateManager AbilityTemplateManager)
{
	local array<X2DataTemplate>				TemplateAllDifficulties;
	local X2DataTemplate					Template;
	local X2AbilityTemplate					AbilityTemplate;
	local name								TemplateName;
	local X2AbilityCost						AbilityCost;
	local X2AbilityCost_ActionPoints		ActionPointCost;

	AbilityTemplateManager.FindDataTemplateAllDifficulties('CallSatStrike', TemplateAllDifficulties);
	foreach TemplateAllDifficulties(Template)
	{
		AbilityTemplate = X2AbilityTemplate(Template);

		if (AbilityTemplate != none)
		{
			`LOG("Ability template" @ AbilityTemplate.DataName @ "exists, patching...", ,'LiberatorsOverhaul');

			foreach AbilityTemplate.AbilityCosts(AbilityCost)
			{
				ActionPointCost = X2AbilityCost_ActionPoints(AbilityCost);

				if(ActionPointCost != none)
				{	
					ActionPointCost.iNumPoints = 2;
					ActionPointCost.bConsumeAllPoints = true;
					`LOG("Changed ability cost to require two actions", ,'LiberatorsOverhaul');
				}
			}
		}
	}
}

static function Patch_FirstAid(X2AbilityTemplateManager AbilityTemplateManager)
{
	local array<X2DataTemplate>				TemplateAllDifficulties;
	local X2DataTemplate					Template;
	local X2AbilityTemplate					AbilityTemplate;
	local name								TemplateName;
	local X2AbilityCost_ActionPoints		ActionPointCost;

	AbilityTemplateManager.FindDataTemplateAllDifficulties('IRI_FirstAid', TemplateAllDifficulties);
	foreach TemplateAllDifficulties(Template)
	{
		AbilityTemplate = X2AbilityTemplate(Template);

		if (AbilityTemplate != none)
		{
			`LOG("Ability template" @ AbilityTemplate.DataName @ "exists, patching...", ,'LiberatorsOverhaul');

			ActionPointCost = X2AbilityCost_ActionPoints(AbilityTemplate.AbilityCosts[0]);

			if(ActionPointCost != none)
			{
				ActionPointCost.DoNotConsumeAllSoldierAbilities.AddItem('F_Corpsman');
				`LOG("Changed ability to be non-turnending with F_Corpsman", ,'LiberatorsOverhaul');
			}
		}
	}
}

static function Patch_HackAbility(name TemplateName, X2AbilityTemplateManager AbilityTemplateManager)
{
	local array<X2DataTemplate>				TemplateAllDifficulties;
	local X2DataTemplate					Template;
	local X2AbilityTemplate					AbilityTemplate;
	local X2Condition_HackingTarget			HackCondition;
	local X2Condition						Condition;

	AbilityTemplateManager.FindDataTemplateAllDifficulties(TemplateName, TemplateAllDifficulties);
	foreach TemplateAllDifficulties(Template)
	{
		AbilityTemplate = X2AbilityTemplate(Template);

		if (AbilityTemplate != none)
		{
			`LOG("Ability template" @ AbilityTemplate.DataName @ "exists, patching...", ,'LiberatorsOverhaul');
			foreach AbilityTemplate.AbilityTargetConditions(Condition)
			{
				HackCondition = X2Condition_HackingTarget(Condition);
				
				if(HackCondition != none)
				{
					HackCondition.bIntrusionProtocol = false;
				}
			}
		}
	}
}

static function Patch_RequireBrace(name TemplateName, X2AbilityTemplateManager AbilityTemplateManager)
{
	local array<X2DataTemplate>				TemplateAllDifficulties;
	local X2DataTemplate					Template;
	local X2AbilityTemplate					AbilityTemplate;
	local X2Condition_WOTC_APA_Class_EffectRequirement		BracedCondition;

	AbilityTemplateManager.FindDataTemplateAllDifficulties(TemplateName, TemplateAllDifficulties);
	foreach TemplateAllDifficulties(Template)
	{
		AbilityTemplate = X2AbilityTemplate(Template);

		if (AbilityTemplate != none)
		{
			`LOG("Ability template" @ AbilityTemplate.DataName @ "exists, patching...", ,'LiberatorsOverhaul');
			
			// Establish conditions requiring Braced or Temp Braced effects
			// Require that the shooter be Braced or Temp Braced
			BracedCondition = new class'X2Condition_WOTC_APA_Class_EffectRequirement';
			BracedCondition.RequiredEffectNames.AddItem('WOTC_APA_Brace_BracedEffect');
			BracedCondition.RequiredEffectNames.AddItem('WOTC_APA_Brace_TempBracedEffect');
			BracedCondition.bRequireAll = false;
			BracedCondition.RequiredErrorCode = 'AA_RequiresBraced';
			BracedCondition.bCheckSourceUnit = true;
			AbilityTemplate.AbilityShooterConditions.AddItem(BracedCondition);
		}
	}
}

static function Patch_Overclock(name TemplateName, X2AbilityTemplateManager AbilityTemplateManager)
{
	local array<X2DataTemplate>				TemplateAllDifficulties;
	local X2DataTemplate					Template;
	local X2AbilityTemplate					AbilityTemplate;
	local X2AbilityCost						AbilityCost;
	local X2AbilityCost_ActionPoints		ActionPointCost;

	AbilityTemplateManager.FindDataTemplateAllDifficulties(TemplateName, TemplateAllDifficulties);
	foreach TemplateAllDifficulties(Template)
	{
		AbilityTemplate = X2AbilityTemplate(Template);

		if (AbilityTemplate != none)
		{
			`LOG("Ability template" @ AbilityTemplate.DataName @ "exists, patching...", ,'LiberatorsOverhaul');

			foreach AbilityTemplate.AbilityCosts(AbilityCost)
			{
				ActionPointCost = X2AbilityCost_ActionPoints(AbilityCost);

				if(ActionPointCost != none)
				{
					ActionPointCost.bConsumeAllPoints = true;
					ActionPointCost.DoNotConsumeAllSoldierAbilities.Length = 0;
					ActionPointCost.DoNotConsumeAllSoldierAbilities.AddItem('RPGORebalance_BITSalvo');
				}
			}
		}
	}
}

static function Patch_Quickdraw(name TemplateName, X2AbilityTemplateManager AbilityTemplateManager)
{
	local array<X2DataTemplate>				TemplateAllDifficulties;
	local X2DataTemplate					Template;
	local X2AbilityTemplate					AbilityTemplate;
	local X2AbilityCost						AbilityCost;
	local X2AbilityCost_ActionPoints		ActionPointCost;

	AbilityTemplateManager.FindDataTemplateAllDifficulties(TemplateName, TemplateAllDifficulties);
	foreach TemplateAllDifficulties(Template)
	{
		AbilityTemplate = X2AbilityTemplate(Template);

		if (AbilityTemplate != none)
		{
			`LOG("Ability template" @ AbilityTemplate.DataName @ "exists, patching...", ,'LiberatorsOverhaul');

			foreach AbilityTemplate.AbilityCosts(AbilityCost)
			{
				ActionPointCost = X2AbilityCost_ActionPoints(AbilityCost);

				if(ActionPointCost != none)
				{
					ActionPointCost.bConsumeAllPoints = true;
					ActionPointCost.DoNotConsumeAllSoldierAbilities.Length = 0;
					ActionPointCost.DoNotConsumeAllSoldierAbilities.AddItem('Quickdraw');
				}
			}
		}
	}
}

static function Patch_ItemTotalCombat(name TemplateName, X2AbilityTemplateManager AbilityTemplateManager)
{
	local array<X2DataTemplate>				TemplateAllDifficulties;
	local X2DataTemplate					Template;
	local X2AbilityTemplate					AbilityTemplate;
	local X2AbilityCost						AbilityCost;
	local X2AbilityCost_ActionPoints		ActionPointCost;
	local X2AbilityCost_Ammo                AmmoCost;

	AbilityTemplateManager.FindDataTemplateAllDifficulties(TemplateName, TemplateAllDifficulties);
	foreach TemplateAllDifficulties(Template)
	{
		AbilityTemplate = X2AbilityTemplate(Template);

		if (AbilityTemplate != none)
		{
			`LOG("Ability template" @ AbilityTemplate.DataName @ "exists, patching...", ,'LiberatorsOverhaul');

			AbilityTemplate.AbilityCosts.Length = 0;
			
			AmmoCost = new class'X2AbilityCost_Ammo';
			AmmoCost.iAmmo = 1;
			AbilityTemplate.AbilityCosts.AddItem(AmmoCost);

			ActionPointCost = new class'X2AbilityCost_ActionPoints';
			ActionPointCost.iNumPoints = 1;
			ActionPointCost.bConsumeAllPoints = true;
			ActionPointCost.bFreeCost = false;
			ActionPointCost.DoNotConsumeAllSoldierAbilities.AddItem('TotalCombat');
			ActionPointCost.DoNotConsumeAllEffects.AddItem('DLC_3Overdrive');
			AbilityTemplate.AbilityCosts.AddItem(ActionPointCost);
		}
	}
}

simulated function Shielded_BuildVisualization(XComGameState VisualizeGameState)
{
	local XComGameStateHistory History;
	local XComGameStateContext_Ability  Context;
	local StateObjectReference InteractingUnitRef;
	local VisualizationActionMetadata EmptyTrack;
	local VisualizationActionMetadata ActionMetadata;
	local X2Action_PlayAnimation PlayAnimationAction;

	History = `XCOMHISTORY;

	Context = XComGameStateContext_Ability(VisualizeGameState.GetContext());
	InteractingUnitRef = Context.InputContext.SourceObject;

	//Configure the visualization track for the shooter
	//****************************************************************************************
	ActionMetadata = EmptyTrack;
	ActionMetadata.StateObject_OldState = History.GetGameStateForObjectID(InteractingUnitRef.ObjectID, eReturnType_Reference, VisualizeGameState.HistoryIndex - 1);
	ActionMetadata.StateObject_NewState = VisualizeGameState.GetGameStateForObjectID(InteractingUnitRef.ObjectID);
	ActionMetadata.VisualizeActor = History.GetVisualizer(InteractingUnitRef.ObjectID);

	PlayAnimationAction = X2Action_PlayAnimation(class'X2Action_PlayAnimation'.static.AddToVisualizationTree(ActionMetadata, Context, false, ActionMetadata.LastActionAdded));
	PlayAnimationAction.Params.AnimName = 'HL_EnergyShield';
}

// Set this as the VisualizationFn on an X2Effect_Persistent to have it display a flyover over the target when applied.
simulated static function EffectFlyOver_Visualization(XComGameState VisualizeGameState, out VisualizationActionMetadata ActionMetadata, const name EffectApplyResult)
{
	local X2Action_PlaySoundAndFlyOver	SoundAndFlyOver;
	local X2AbilityTemplate             AbilityTemplate;
	local XComGameStateContext_Ability  Context;
	local AbilityInputContext           AbilityContext;
	local EWidgetColor					MessageColor;
	local XComGameState_Unit			SourceUnit;
	local bool							bGoodAbility;

	Context = XComGameStateContext_Ability(VisualizeGameState.GetContext());
	AbilityContext = Context.InputContext;
	AbilityTemplate = class'XComGameState_Ability'.static.GetMyTemplateManager().FindAbilityTemplate(AbilityContext.AbilityTemplateName);
	
	SourceUnit = XComGameState_Unit(`XCOMHISTORY.GetGameStateForObjectID(AbilityContext.SourceObject.ObjectID));

	bGoodAbility = SourceUnit.IsFriendlyToLocalPlayer();
	MessageColor = bGoodAbility ? eColor_Good : eColor_Bad;

	if (EffectApplyResult == 'AA_Success' && XGUnit(ActionMetadata.VisualizeActor).IsAlive())
	{
		SoundAndFlyOver = X2Action_PlaySoundAndFlyOver(class'X2Action_PlaySoundAndFlyOver'.static.AddToVisualizationTree(ActionMetadata, VisualizeGameState.GetContext(), false, ActionMetadata.LastActionAdded));
		SoundAndFlyOver.SetSoundAndFlyOverParameters(None, AbilityTemplate.LocFlyOverText, '', MessageColor, AbilityTemplate.IconImage);
	}
}


// Player has aborted a full override: Refund the chage.
function XComGameState CancelFullOverride_BuildGameState(XComGameStateContext Context)
{
    local XComGameStateContext_Ability AbilityContext;
    local XComGameState NewGameState;

    AbilityContext = XComGameStateContext_Ability(Context);
    NewGameState = class'X2Ability'.static.TypicalAbility_BuildGameState(Context);
    RefundFullOverrideCharge(AbilityContext, NewGameState);
    return NewGameState;
}

// Player has attempted a full override: Perform the normal hack finalization, but in addition
// we need to check if the hack has failed. If so, refund the charge.
simulated function XComGameState FinalizeFullOverrideAbility_BuildGameState(XComGameStateContext Context)
{
    local XComGameStateContext_Ability AbilityContext;
    local XComGameState_BaseObject TargetState;
    local XComGameState_Unit TargetUnit;
    local XComGameState NewGameState;

    // First perform the standard hack finalization.
    NewGameState = FinalizeHackAbility_BuildGameState_Internal(Context);

    // TODO - See comment on FinalizeHackAbility_BuildGameState_Internal function below
    //NewGameState = class'X2Ability_DefaultAbilitySet'.static.FinalizeHackAbility_BuildGameState_Internal(Context);

    AbilityContext = XComGameStateContext_Ability(Context);

    // Check if we have succesfully hacked the target. If not, refund the charge.
    TargetState = NewGameState.GetGameStateForObjectID(AbilityContext.InputContext.PrimaryTarget.ObjectID);
    TargetUnit = XComGameState_Unit(TargetState);
    if (TargetUnit != none && !TargetUnit.bHasBeenHacked)
    {
        RefundFullOverrideCharge(AbilityContext, NewGameState);
    }

    return NewGameState;
}

// Full override only consumes the charge on a successful hack. The charge is attached to the FullOverride ability
// and is charged when the player first selects the ability, similar to the cooldown applied on Haywire protocol.
// As for haywire, if the player cancels the hack we need to refund the charge. Full override also refunds the charge
// if the hack is attempted but fails.
static function RefundFullOverrideCharge(XComGameStateContext_Ability AbilityContext, XComGameState NewGameState)
{
    local XComGameState_Ability AbilityState;
    local XComGameStateHistory History;

    History = `XCOMHISTORY;

    // locate the Ability gamestate for HaywireProtocol associated with this unit, and remove the turn timer
    foreach History.IterateByClassType(class'XComGameState_Ability', AbilityState)
    {
        if( AbilityState.OwnerStateObject.ObjectID == AbilityContext.InputContext.SourceObject.ObjectID &&
           AbilityState.GetMyTemplateName() == 'HaywireProtocol' )
        {
            AbilityState = XComGameState_Ability(NewGameState.CreateStateObject(class'XComGameState_Ability', AbilityState.ObjectID));
            NewGameState.AddStateObject(AbilityState);
            ++AbilityState.iCharges;
			AbilityState.iCooldown = 0;
            return;
        }
    }
}

// TODO This is a straight copy of X2Ability_DefaultAbilitySet.FinalizeHackAbility_BuildGameState()
//      A better solution would be to modify the Community Highlander to make that function static and just call that instead of copying it wholesale,
//      but this will do for the short term.
static function XComGameState FinalizeHackAbility_BuildGameState_Internal(XComGameStateContext Context)
{
	local XComGameStateHistory History;
	local XComGameState NewGameState;
	local XComGameStateContext_Ability AbilityContext;
	local XComGameState_Ability AbilityState;
	local XComGameState_BaseObject TargetState;
	local XComGameState_Unit UnitState, TargetUnit;
	local XComGameState_InteractiveObject ObjectState;
	local XComGameState_Item SourceWeaponState;
	local XComGameState_BattleData BattleData;
	local X2AbilityTemplate AbilityTemplate;
	local array<XComInteractPoint> InteractionPoints;
	local X2EventManager EventManager;
	local bool bHackSuccess;
	local array<int> HackRollMods;
	local Hackable HackableObject;
	local UIHackingScreen HackingScreen;
	local int UserSelectedReward;

	EventManager = `XEVENTMGR;
	History = `XCOMHISTORY;

	//Build the new game state frame
	NewGameState = class'X2Ability'.static.TypicalAbility_BuildGameState(Context);	

	AbilityContext = XComGameStateContext_Ability(Context);	
	AbilityState = XComGameState_Ability(History.GetGameStateForObjectID(AbilityContext.InputContext.AbilityRef.ObjectID, eReturnType_Reference));	
	AbilityTemplate = AbilityState.GetMyTemplate();
	UnitState = XComGameState_Unit(History.GetGameStateForObjectID(AbilityContext.InputContext.SourceObject.ObjectID));
	SourceWeaponState = XComGameState_Item(History.GetGameStateForObjectID(AbilityContext.InputContext.ItemObject.ObjectID));
	InteractionPoints = class'X2Condition_UnitInteractions'.static.GetUnitInteractionPoints(UnitState, eInteractionType_Hack);

	// add a copy of the unit and update apply the costs of the ability to him
	UnitState = XComGameState_Unit(NewGameState.ModifyStateObject(UnitState.Class, UnitState.ObjectID));
	if (SourceWeaponState != none)
		SourceWeaponState = XComGameState_Item(NewGameState.ModifyStateObject(SourceWeaponState.Class, SourceWeaponState.ObjectID));

	TargetState = History.GetGameStateForObjectID(AbilityContext.InputContext.PrimaryTarget.ObjectID);
	TargetState = NewGameState.ModifyStateObject(TargetState.Class, TargetState.ObjectID);

	HackableObject = Hackable(TargetState);

	ObjectState = XComGameState_InteractiveObject(TargetState);
	if (ObjectState == none)
		TargetUnit = XComGameState_Unit(TargetState);

	`assert(ObjectState != none || TargetUnit != none);     //  if we don't have an interactive object or a unit, what is going on?

	HackingScreen = UIHackingScreen(`SCREENSTACK.GetScreen(class'UIHackingScreen'));

	// The bottom values of 0 and 100.0f are for when the HackingScreen is not available.
	// When this is the case, the hack should always succeed and award the lowest valued reward, index 0.
	bHackSuccess = class'X2HackRewardTemplateManager'.static.AcquireHackRewards(
		HackingScreen,
		UnitState, 
		TargetState, 
		AbilityContext.ResultContext.StatContestResult, 
		NewGameState, 
		AbilityTemplate.DataName,
		UserSelectedReward,
		0,
		100.0f);

	if( ObjectState != none )
	{
		ObjectState.bHasBeenHacked = bHackSuccess;
		ObjectState.UserSelectedHackReward = UserSelectedReward;
		if( ObjectState.bHasBeenHacked )
		{
			// award all loot on the hacked object to the hacker
			ObjectState.MakeAvailableLoot(NewGameState);
			class'Helpers'.static.AcquireAllLoot(ObjectState, AbilityContext.InputContext.SourceObject, NewGameState);

			EventManager.TriggerEvent('ObjectHacked', UnitState, ObjectState, NewGameState);
			`TRIGGERXP('XpSuccessfulHack', UnitState.GetReference(), ObjectState.GetReference(), NewGameState);

			// automatically interact with the hacked object as well
			if( InteractionPoints.Length > 0 )
				ObjectState.Interacted(UnitState, NewGameState, InteractionPoints[0].InteractSocketName);
		}

		if( ObjectState.bOffersTacticalHackRewards )
		{
			BattleData = XComGameState_BattleData(History.GetSingleGameStateObjectForClass(class'XComGameState_BattleData'));
			BattleData = XComGameState_BattleData(NewGameState.ModifyStateObject(class'XComGameState_BattleData', BattleData.ObjectID));
			BattleData.bTacticalHackCompleted = true;
		}
	}
	else if( TargetUnit != none )
	{
		TargetUnit.bHasBeenHacked = bHackSuccess;
		TargetUnit.UserSelectedHackReward = UserSelectedReward;
		if( TargetUnit.bHasBeenHacked )
		{
			`TRIGGERXP('XpSuccessfulHack', UnitState.GetReference(), TargetUnit.GetReference(), NewGameState);

		}
	}

	HackableObject.SetHackRewardRollMods(HackRollMods);

	//Return the game state we have created
	return NewGameState;
}
