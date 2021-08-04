class X2DownloadableContentInfo_LiberatorsOverhaulCoreMod extends X2DownloadableContentInfo config(Game);

struct WeaponPoolTemplate
{
	var name WeaponPoolID;
	var name TechCategory;
	var name WeaponCategory;
	var array<name> WhitelistTemplates;
	var array<name> BlacklistTemplates;
};

struct AmmoRestrictionTemplate
{
	var name AmmoTemplate;
	var array<name> WeaponPoolIDs;
};

struct NCETrait
{
	var name Trait;
	var name ExtremeTrait;
	var ECharStatType StatUp;
	var ECharStatType StatDown;
	var int	StatUpValue;
	var int StatDownValue;
};

var config array<WeaponPoolTemplate> WeaponPools;
var config array<AmmoRestrictionTemplate> AmmoRestrictions;

var config array<name> arrUniqueItemInSquad;

var localized string CannotEquipAmmoLabel, CannotEquipWithAmmoLabel;

var config array<NCETrait> NCEStatSwapTraits;
var config array<name> NCE_TRAITS_EXCLUDED_TEMPLATES;

var config bool isPistolSlotLoaded;

static function bool CanAddItemToInventory_CH_Improved(out int bCanAddItem, const EInventorySlot Slot, const X2ItemTemplate ItemTemplate, int Quantity, XComGameState_Unit UnitState, optional XComGameState CheckGameState, optional out string DisabledReason, optional XComGameState_Item ItemState) 
{
    local bool                          OverrideNormalBehavior;
    local bool                          DoNotOverrideNormalBehavior;
    local XComGameState_Item            PrimaryWeapon; //, SecondaryWeapon;
    local X2AmmoTemplate				AmmoTemplate;
    local X2WeaponTemplate              WeaponTemplate;
	local WeaponPoolTemplate			WeaponPool;
	local name							WeaponPoolID;
	local AmmoRestrictionTemplate		AmmoRestriction;
	local array<XComGameState_Item>		InventoryItems;
	local XComGameState_Item			InventoryItem;
 
    OverrideNormalBehavior = CheckGameState != none;
    DoNotOverrideNormalBehavior = CheckGameState == none;
 
    if(DisabledReason != "")
        return DoNotOverrideNormalBehavior;

	WeaponTemplate = X2WeaponTemplate(ItemTemplate);
	if(WeaponTemplate != none && Slot == eInvSlot_PrimaryWeapon)
	{
		foreach default.WeaponPools(WeaponPool)
		{
			if(WeaponPool.BlacklistTemplates.Find(WeaponTemplate.DataName) == -1)
			{
				if(WeaponPool.WhitelistTemplates.Find(WeaponTemplate.DataName) > -1)
				{
					WeaponPoolID = WeaponPool.WeaponPoolID;
					break;
				}

				if(WeaponTemplate.WeaponCat == WeaponPool.WeaponCategory || WeaponTemplate.WeaponTech == WeaponPool.TechCategory)
				{
					WeaponPoolID = WeaponPool.WeaponPoolID;
					break;
				}
			}
		}
 
		InventoryItems = UnitState.GetAllInventoryItems();
 
		foreach InventoryItems(InventoryItem)
		{
			if (InventoryItem.GetMyTemplate().ItemCat == 'ammo')
			{
				foreach default.AmmoRestrictions(AmmoRestriction)
				{
					if(AmmoRestriction.AmmoTemplate == InventoryItem.GetMyTemplateName())
					{
						if(AmmoRestriction.WeaponPoolIDs.Find(WeaponPoolID) == -1)
						{
							bCanAddItem = 0;
							DisabledReason = default.CannotEquipAmmoLabel;
							return OverrideNormalBehavior;
						}
					}
				}
			}
		}
	}

    AmmoTemplate = X2AmmoTemplate(ItemTemplate);
    if(AmmoTemplate != none)
    {
        PrimaryWeapon = UnitState.GetPrimaryWeapon();
        if(PrimaryWeapon != none)
        {
			foreach default.WeaponPools(WeaponPool)
			{
				if(WeaponPool.BlacklistTemplates.Find(PrimaryWeapon.GetMyTemplateName()) == -1)
				{
					if(WeaponPool.WhitelistTemplates.Find(PrimaryWeapon.GetMyTemplateName()) > -1)
					{
						WeaponPoolID = WeaponPool.WeaponPoolID;
						break;
					}

					if(PrimaryWeapon.GetWeaponCategory() == WeaponPool.WeaponCategory || PrimaryWeapon.GetWeaponTech() == WeaponPool.TechCategory)
					{
						WeaponPoolID = WeaponPool.WeaponPoolID;
						break;
					}
				}
			}

			foreach default.AmmoRestrictions(AmmoRestriction)
			{
				if(AmmoRestriction.AmmoTemplate == AmmoTemplate.DataName)
				{
					if(AmmoRestriction.WeaponPoolIDs.Find(WeaponPoolID) == -1)
					{
						bCanAddItem = 0;
						DisabledReason = default.CannotEquipAmmoLabel;
						return OverrideNormalBehavior;
					}
				}
			}
        }
    }

    return DoNotOverrideNormalBehavior;
}

static event OnPostTemplatesCreated()
{
	`LOG("Starting patches...", ,'Liberators Overhaul');

	class'TemplateHelper_AbilityPatches'.static.PatchAbilityTemplates();
	class'TemplateHelper_FacilityPatches'.static.PatchFacilities();
	
	UpdateCharacterTemplates();

	RemoveFactionCard('ResCard_MunitionsExperts');
	RemoveFactionCard('ResCard_SuitUp');
	RemoveFactionCard('ResCard_BombSquad');
	
	PatchHoloRounds();
}

// Update the Character Templates to assign the Stat Randomization function
static function UpdateCharacterTemplates()
{
	local X2CharacterTemplateManager	CharacterTemplateManager;
    local X2CharacterTemplate			CharTemplate;
    local array<X2DataTemplate>			DataTemplates;
    local X2DataTemplate				Template, DiffTemplate;
	local OnStatAssignmentCompleteClosure DelegateClosure;

    CharacterTemplateManager = class'X2CharacterTemplateManager'.static.GetCharacterTemplateManager();

    foreach CharacterTemplateManager.IterateTemplates(Template, None)
    {
		if (default.NCE_TRAITS_EXCLUDED_TEMPLATES.Find(Template.DataName) != INDEX_NONE)
		{
			`LOG("Trait-Based NCE: Not implementing for" @ Template.DataName @ " - Template is excluded",,'Liberators Overhaul');
			continue;
		}
		
        CharacterTemplateManager.FindDataTemplateAllDifficulties(Template.DataName, DataTemplates);
        foreach DataTemplates(DiffTemplate)
        {
            CharTemplate = X2CharacterTemplate(DiffTemplate);
            if (CharTemplate.bIsSoldier && !CharTemplate.bIsRobotic)
            {
				DelegateClosure = new class'OnStatAssignmentCompleteClosure';
				DelegateClosure.OnStatAssignmentCompleteOriginalFn = CharTemplate.OnStatAssignmentCompleteFn;
				CharTemplate.OnStatAssignmentCompleteFn = DelegateClosure.OnStatAssignmentCompleteFn;
				`LOG("Trait-Based NCE: Successfully implementing for" @ CharTemplate.DataName, true,'Liberators Overhaul');
			}
		}
	}
	
	CharTemplate = CharacterTemplateManager.FindCharacterTemplate('Civilian');
	if(CharTemplate != none)
	{
		CharTemplate.Abilities.AddItem('Shadowstep');
		CharTemplate.Abilities.RemoveItem('CivilianEasyToHit');
	}
}

static function RemoveFactionCard(name TemplateName)
{
	local X2StrategyElementTemplateManager CardManager;
	local X2StrategyCardTemplate CardTemplate;

	CardManager = class'X2StrategyElementTemplateManager'.static.GetStrategyElementTemplateManager();

	CardTemplate = X2StrategyCardTemplate(CardManager.FindStrategyElementTemplate(TemplateName));
	CardTemplate.Category = "__REMOVED__";
}

static function PatchHoloRounds()
{
	local X2ItemTemplateManager				ItemTemplateManager;
	local X2AmmoTemplate					AmmoTemplate;
	local X2Effect_HoloTarget				HoloEffect;

	ItemTemplateManager = class'X2ItemTemplateManager'.static.GetItemTemplateManager();

	AmmoTemplate = X2AmmoTemplate(ItemTemplateManager.FindItemTemplate('TracerRounds'));
	AmmoTemplate.Abilities.Length = 0;
	HoloEffect = new class'X2Effect_HoloTarget';
	HoloEffect.HitMod = 15;
	HoloEffect.BuildPersistentEffect(1, false, false, false, eGameRule_PlayerTurnBegin);
	HoloEffect.bRemoveWhenTargetDies = true;
	HoloEffect.bUseSourcePlayerState = true;
	HoloEffect.VisualizationFn = EffectFlyOver_Visualization;
	HoloEffect.SetDisplayInfo(ePerkBuff_Penalty, class'X2Ability_GrenadierAbilitySet'.default.HoloTargetEffectName, `XEXPAND.ExpandString(class'X2Ability_GrenadierAbilitySet'.default.HoloTargetEffectDesc), "img:///UILibrary_PerkIcons.UIPerk_holotargeting", true);
	AmmoTemplate.TargetEffects.AddItem(HoloEffect);
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

static function RollForRandomTraits(XComGameState_Unit Unit)
{
	local NCETrait Trait1Ind, Trait2Ind;

	Unit.AcquiredTraits.Length = 0;

	switch(Unit.GetMyTemplateName())
	{
		case 'Soldier' : Unit.AcquiredTraits.AddItem('XCOMSoldier'); break;
		case 'ReaperSoldier' : Unit.AcquiredTraits.AddItem('ReaperSoldier'); break;
		case 'SkirmisherSoldier' : Unit.AcquiredTraits.AddItem('SkirmisherSoldier'); break;
		case 'TemplarSoldier' : Unit.AcquiredTraits.AddItem('TemplarSoldier'); break;
	}

	if(Unit.GetMyTemplateName() == 'Soldier')
	{
		Trait1Ind = default.NCEStatSwapTraits[`SYNC_RAND_STATIC(default.NCEStatSwapTraits.Length)];
		Trait2Ind = default.NCEStatSwapTraits[`SYNC_RAND_STATIC(default.NCEStatSwapTraits.Length)];

		if(Trait1Ind.Trait == Trait2Ind.Trait)
		{
			Unit.AcquiredTraits.AddItem(Trait1Ind.ExtremeTrait);

			Unit.setBaseMaxStat(Trait1Ind.StatUp, Unit.GetBaseStat(Trait1Ind.StatUp) + Trait1Ind.StatUpValue * 2);
			Unit.setCurrentStat(Trait1Ind.StatUp, Unit.GetBaseStat(Trait1Ind.StatUp));

			Unit.setBaseMaxStat(Trait1Ind.StatDown, Unit.GetBaseStat(Trait1Ind.StatDown) + Trait1Ind.StatDownValue * 2);
			Unit.setCurrentStat(Trait1Ind.StatDown, Unit.GetBaseStat(Trait1Ind.StatDown));
		}
		else
		{
			if(Trait1Ind.StatUp == Trait2Ind.StatDown && Trait1Ind.StatDown == Trait2Ind.StatUp)
			{
				Unit.AcquiredTraits.AddItem('NCE_Balanced');
			}
			else
			{
				Unit.AcquiredTraits.AddItem(Trait1Ind.Trait);
				Unit.setBaseMaxStat(Trait1Ind.StatUp, Unit.GetBaseStat(Trait1Ind.StatUp) + Trait1Ind.StatUpValue);
				Unit.setCurrentStat(Trait1Ind.StatUp, Unit.GetBaseStat(Trait1Ind.StatUp));

				Unit.setBaseMaxStat(Trait1Ind.StatDown, Unit.GetBaseStat(Trait1Ind.StatDown) + Trait1Ind.StatDownValue);
				Unit.setCurrentStat(Trait1Ind.StatDown, Unit.GetBaseStat(Trait1Ind.StatDown));

				Unit.AcquiredTraits.AddItem(Trait2Ind.Trait);
				Unit.setBaseMaxStat(Trait2Ind.StatUp, Unit.GetBaseStat(Trait2Ind.StatUp) + Trait2Ind.StatUpValue);
				Unit.setCurrentStat(Trait2Ind.StatUp, Unit.GetBaseStat(Trait2Ind.StatUp));

				Unit.setBaseMaxStat(Trait2Ind.StatDown, Unit.GetBaseStat(Trait2Ind.StatDown) + Trait2Ind.StatDownValue);
				Unit.setCurrentStat(Trait2Ind.StatDown, Unit.GetBaseStat(Trait2Ind.StatDown));
			}
		}
	}
	else
	{
		Trait1Ind = default.NCEStatSwapTraits[`SYNC_RAND_STATIC(default.NCEStatSwapTraits.Length)];

		Unit.AcquiredTraits.AddItem(Trait1Ind.Trait);
		Unit.setBaseMaxStat(Trait1Ind.StatUp, Unit.GetBaseStat(Trait1Ind.StatUp) + Trait1Ind.StatUpValue);
		Unit.setCurrentStat(Trait1Ind.StatUp, Unit.GetBaseStat(Trait1Ind.StatUp));

		Unit.setBaseMaxStat(Trait1Ind.StatDown, Unit.GetBaseStat(Trait1Ind.StatDown) + Trait1Ind.StatDownValue);
		Unit.setCurrentStat(Trait1Ind.StatDown, Unit.GetBaseStat(Trait1Ind.StatDown));
	}
}


static function FinalizeUnitAbilitiesForInit(XComGameState_Unit UnitState, out array<AbilitySetupData> SetupData, optional XComGameState StartState, optional XComGameState_Player PlayerState, optional bool bMultiplayerDisplay)
{
	local array<XComGameState_Item> UnitInventory;
	local int i, j;
	local int ExtraGrenadeAmmo;
	local XComGameState_Item Item, Compare;
	local X2GrenadeTemplate GrenadeTemplate, CompareTemplate;

	if (StartState != none) 
	{
		UnitInventory = UnitState.GetAllInventoryItems(StartState);

		foreach UnitInventory(Item)
		{
			if (!Item.bMergedOut) 
			{
				GrenadeTemplate = X2GrenadeTemplate(item.GetMyTemplate());

				if(GrenadeTemplate != none) 
				{ 
					if(GrenadeTemplate.WeaponCat == 'rocket')
					{
						//Cap rockets to 1 ammo per item
						Item.Ammo = 1;

						foreach UnitInventory(Compare)
						{
							CompareTemplate = X2GrenadeTemplate(Compare.GetMyTemplate());
							if (CompareTemplate == GrenadeTemplate && Compare.bMergedOut)
							{
								Item.Ammo += 1;
							}
						}
					}
					else
					{
						Item.Ammo += 1;

						foreach UnitInventory(Compare)
						{
							CompareTemplate = X2GrenadeTemplate(Compare.GetMyTemplate());
							if (CompareTemplate == GrenadeTemplate && Compare.bMergedOut)
							{
								Item.Ammo += 1;
							}
						}
					}
				}
			}
		}
	}
}

// this function is protected in XComGameState_Unit for apparently no reason
static function int UnitBonusWeaponAmmoFromAbilities(XComGameState_Unit Unit, XComGameState_Item ItemState, XComGameState StartState)
{
	local array<SoldierClassAbilityType> SoldierAbilities;
	local SoldierClassAbilityType Ability;
	local X2AbilityTemplateManager AbilityTemplateManager;
	local X2AbilityTemplate AbilityTemplate;
	local X2CharacterTemplate CharacterTemplate;
	local int Bonus;
	local name AbilityName;

	//  Note: This function is called prior to abilities being generated for the unit, so we only inspect
	//          1) the earned soldier abilities
	//          2) the abilities on the character template

	Bonus = 0;
	AbilityTemplateManager = class'X2AbilityTemplateManager'.static.GetAbilityTemplateManager();

	SoldierAbilities = Unit.GetEarnedSoldierAbilities();

	foreach SoldierAbilities(Ability)
	{
		AbilityTemplate = AbilityTemplateManager.FindAbilityTemplate(Ability.AbilityName);
		if (AbilityTemplate != none && AbilityTemplate.GetBonusWeaponAmmoFn != none)
			Bonus += AbilityTemplate.GetBonusWeaponAmmoFn(Unit, ItemState);
	}

	CharacterTemplate = Unit.GetMyTemplate();
	
	foreach CharacterTemplate.Abilities(AbilityName)
	{
		AbilityTemplate = AbilityTemplateManager.FindAbilityTemplate(AbilityName);
		if (AbilityTemplate != none && AbilityTemplate.GetBonusWeaponAmmoFn != none)
			Bonus += AbilityTemplate.GetBonusWeaponAmmoFn(Unit, ItemState);
	}

	return Bonus;
}
