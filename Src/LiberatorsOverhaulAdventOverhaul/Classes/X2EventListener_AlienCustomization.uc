//---------------------------------------------------------------------------------------
//  FILE:    X2EventListener_AlienCustomization.uc
//  AUTHOR:  Peter Ledbrook
//  PURPOSE: Listeners for managing alien customisation, i.e. the look of units
//           like Rocketeers, Scouts and Sergeants. Copies from LW2's
//           XComGameState_AlienCustomizationManager.
//---------------------------------------------------------------------------------------

class X2EventListener_AlienCustomization extends X2EventListener config(AlienVariations);// dependson(XComGameState_AlienCustomizationManager);

// ADVENT Soldiers using the Props_SD_FX_Chunks material - 'TintColor', 'MetalColor'
	// AdvTrooper(M1) - 'TintColor' (Detailing)

// ADVENT soldiers using the AlienUnit_TC parent material - 'TintColor', 'EmissiveColor', 'EmissiveScale'
	// AdvCaptain(all) - 'TintColor' (Armor), 'EmissiveColor', 'EmissiveScale' (Lights)
	// AdvStunLancer(M2/3) - 'EmissiveColor', 'EmissiveScale' (Lights)
	// AdvMEC(M1) - 'TintColor' (Armor)
	// AdvMEC(M2) - 'TintColor' (Armor), 'EmissiveColor', 'EmissiveScale' (Lights)
	// AdvTrooper(M2/3) - 'TintColor' (Detailing), 'EmissiveColor' (Lights)
	// Sectopod - none

// ADVENT soldiers using the Alien_SD_Cloth - 'EmissiveColor', 'EmissiveColor', 'MetalColor'
	// AdvStunLancer(M1)  - 'EmissiveColor', 'EmissiveScale' (Lights)
	// AdvShieldBearer(all)  - 'EmissiveColor', 'EmissiveScale' (Lights)

// Alien Units using the Alien_SD_SSS - 'EmissiveColor', 'FresnelColor' (usually nothing)
	// AdvPsiWitch - 'FresnelColor' (minor)
	// Andromedon - none
	// Archon - 'MetalColor' (Body)
	// Berserker - none
	// Chryssalid - none
	// Codex/Cyberus - none
	// Faceless - none
	// Gatekeeper - none
	// Muton - none
	// Sectoid - 'EmissiveColor' (minor)
	// Viper - 'MetalColor' (Armor)

// Aliens using XCom weapons with the WeaponCustomizable_TC parent material - 'PrimaryColor', 'EmissiveColor', 'Pattern'

// Aliens using Alien weapons with WeaponCustomizable_TC parent material 
	// Viper - 'MetalColor'
	// Archon - 'MetalColor'

struct ColorParameter
{
    var name ParameterName;
    var LinearColor ColorValue;
};

struct ScalarParameter
{
    var name ParameterName;
    var float ScalarValue;
};

struct BoolParameter
{
    var name ParameterName;
    var float BoolValue;
};

struct TextureParameter
{
    var name ParameterName;
    var string ImagePath;
};

struct ObjectAppearance
{
    var array<ColorParameter> ColorParameters;  // instructions on how to color the object
    var array<ScalarParameter> ScalarParameters; // instructions on any scalar parameters to adjust
    var array<BoolParameter> BoolParameters; // instructions on any bool parameters to adjust
    var array<TextureParameter> TextureParameters; // instructions on any texture parameters to adjust
};

struct UnitVariation
{
    var array<name> CharacterNames;  // character that this can apply to
    var bool Automatic;
    var float Probability; // only one variation per unit
    var float Scale; // multiplicative proportional scaling
    var ObjectAppearance BodyAppearance;	
    var ObjectAppearance PrimaryWeaponAppearance;
    var ObjectAppearance SecondaryWeaponAppearance;
    var array<SoldierClassAbilityType> AbilityUpgrades;
    var array<SoldierClassStatType> StatUpgrades;
    var TAppearance BodyPartContent;
    var array<string> GenericBodyPartArchetypes;
};

var config array<UnitVariation> UnitVariations;

static function array<X2DataTemplate> CreateTemplates()
{
	local array<X2DataTemplate> Templates;

	Templates.AddItem(CreateCustomisationListeners());

	return Templates;
}

static function CHEventListenerTemplate CreateCustomisationListeners()
{
	local CHEventListenerTemplate Template;

    `CREATE_X2TEMPLATE(class'CHEventListenerTemplate', Template, 'AlienCustomisationListeners');

    // Don't know how important the priority is. Just be aware that reducing it may affect
    // summoned units and reinforcements in terms of their rendering.
	Template.AddCHEvent('OnUnitBeginPlay', OnUnitBeginPlay, ELD_OnStateSubmitted, 55);

	Template.RegisterInTactical = true;

	return Template;
}

// Loops over alien units and installs the customization state
static function EventListenerReturn OnUnitBeginPlay(
    Object EventData,
    Object EventSource,
    XComGameState GameState,
    Name EventID,
    Object CallbackData)
{
	local XComGameState NewGameState;
	local XComGameState_Unit_AlienCustomization AlienCustomization;
	local UnitVariation UnitVar;
	local XComGameStateContext_ChangeContainer ChangeContainer;
	local XComGameState_Unit UnitState, UpdatedUnitState;
	local X2EventManager EventManager;
	local Object CustomizationObject;

	EventManager = `XEVENTMGR;

	`LOG("Alien Pack Customization Manager : OnUnitBeginPlay triggered.");
	UnitState = XComGameState_Unit(EventData);

	`LOG("AlienCustomization: Num Variations =" @ default.UnitVariations.Length);

	if (UnitState != none && (UnitState.IsAlien() || UnitState.IsAdvent()))
	{
		`LOG("AlienCustomization: Placing Unit:" @ UnitState.GetFullName());
		AlienCustomization = class'XComGameState_Unit_AlienCustomization'.static.GetCustomizationComponent(UnitState);
		if (AlienCustomization == none || AlienCustomization.bAutomatic) // only add if new or overriding an automatic customization
		{
			foreach default.UnitVariations(UnitVar)
			{
				`LOG("AlienCustomization: Testing Variation for :" @ UnitVar.CharacterNames[0]);

				if (UnitVar.CharacterNames.Find(UnitState.GetMyTemplateName()) != -1) 
				{
					`LOG("AlienCustomization: Valid template found :" @ UnitVar.CharacterNames[0]);

					//valid unit type without random variation, so roll the dice
					if (`SYNC_FRAND_STATIC() < UnitVar.Probability || UnitVar.Automatic)
					{
						`LOG("AlienCustomization: Template passed, applying :" @ UnitVar.CharacterNames[0]);

						NewGameState = class'XComGameStateContext_ChangeContainer'.static.CreateChangeState("Creating Alien Customization Component");
						UpdatedUnitState = XComGameState_Unit(NewGameState.ModifyStateObject(class'XComGameState_Unit', UnitState.ObjectID));

						AlienCustomization = class'XComGameState_Unit_AlienCustomization'.static.CreateCustomizationComponent(UpdatedUnitState, NewGameState);
						AlienCustomization.GenerateCustomization(UnitVar, UpdatedUnitState, NewGameState);

						ChangeContainer = XComGameStateContext_ChangeContainer(NewGameState.GetContext());
						ChangeContainer.BuildVisualizationFn = CustomizeAliens_BuildVisualization;
						ChangeContainer.SetAssociatedPlayTiming(SPT_BeforeSequential);
						`GAMERULES.SubmitGameState(NewGameState);

						AlienCustomization.ApplyCustomization();

						CustomizationObject = AlienCustomization;
						EventManager.RegisterForEvent(CustomizationObject, 'OnCreateCinematicPawn', AlienCustomization.OnCinematicPawnCreation, ELD_Immediate, 55, UnitState);  
						// trigger when unit cinematic pawn is created

						if (!AlienCustomization.bAutomatic)
							return ELR_NoInterrupt;
					}
				}
			}
		}
	}

	return ELR_NoInterrupt;
}

// A BuildVisualization function that ensures that alien pack enemies have their
// pawns updated via X2Action_CustomizeAlienRNFs.
static function CustomizeAliens_BuildVisualization(XComGameState VisualizeGameState)
{
	local XComGameState_Unit UnitState;
	local VisualizationActionMetadata EmptyMetadata, ActionMetadata;
	local XComGameState_Unit_AlienCustomization AlienCustomization;

	if (VisualizeGameState.GetNumGameStateObjects() > 0)
	{
		foreach VisualizeGameState.IterateByClassType(class'XComGameState_Unit', UnitState)
		{
			AlienCustomization = class'XComGameState_Unit_AlienCustomization'.static.GetCustomizationComponent(UnitState);
			if (AlienCustomization == none)
			{
				continue;
			}

			ActionMetadata = EmptyMetadata;
			ActionMetadata.StateObject_OldState = UnitState;
			ActionMetadata.StateObject_NewState = UnitState;

			ActionMetadata.VisualizeActor = UnitState.GetVisualizer();

			class'X2Action_CustomizeAlienRNFs'.static.AddToVisualizationTree(
				ActionMetadata,
				VisualizeGameState.GetContext(),
				false);
		}
	}
} 