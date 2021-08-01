class X2EventListener_NCETraitRoller extends X2EventListener config(GameData);

//OLD EVENT LISTENER IMPLEMENTATION
/*
struct NCETrait
{
	var name Trait;
	var name ExtremeTrait;
	var ECharStatType StatUp;
	var ECharStatType StatDown;
	var int	StatUpValue;
	var int StatDownValue;
};

var config array<NCETrait> NCEStatSwapTraits;

static function array<X2DataTemplate> CreateTemplates()
{
	local array<X2DataTemplate> Templates;

	Templates.AddItem(CreateStartWithTraitsEvent());
	return Templates;
}

static protected function CHEventListenerTemplate CreateStartWithTraitsEvent()
{
	local CHEventListenerTemplate Template;

	`CREATE_X2TEMPLATE(class'CHEventListenerTemplate', Template, 'RM_UnitStartWithTraits');
	//explanation: vanilla X2EvenetLIstenerTemplates do not specify deferrals, instead always being on ELD_OnStateSubmitted.
	//PCSes need to engage as soon as possible, so we use the CH highlander instead.

	Template.RegisterInStrategy = true;
	Template.AddCHEvent('UnitRandomizedStats', AddUnitTrait, ELD_Immediate);
	Template.AddCHEvent('RewardUnitGenerated', AddRewardUnitTrait, ELD_Immediate);

	return Template;
}

static protected function EventListenerReturn AddUnitTrait(Object EventData, Object EventSource, XComGameState GameState, Name Event, Object CallbackData)
{
	local XComGameState_Unit UnitState;

	UnitState = XComGameState_Unit(EventData);
	// bad data somewhere
	if (UnitState == none)
		return ELR_NoInterrupt;

	if(!UnitState.UsesWillSystem())
	{
		return ELR_NoInterrupt; //units that don't use the will system shouldn't get traits
	}

	//if we're here, the listener only kicks in during loaded strategy portions of the game, so we should be safe to assume we can work in here. (The random function only kicks in for new units, after all)

	RollForRandomTraits(UnitState, 0, GameState);

	return ELR_NoInterrupt;
}

static protected function EventListenerReturn AddRewardUnitTrait(Object EventData, Object EventSource, XComGameState GameState, Name Event, Object CallbackData)
{
	local XComGameState_Unit UnitState;

	UnitState = XComGameState_Unit(EventData);
	// bad data somewhere
	if (UnitState == none)
		return ELR_NoInterrupt;

	if(!UnitState.UsesWillSystem())
	{
		return ELR_NoInterrupt; //units that don't use the will system shouldn't get traits
	}
	//if we're here, the listener only kicks in during loaded strategy portions of the game, so we should be safe to assume we can work in here. (The random function only kicks in for new units, after all)

	RollForRandomTraits(UnitState, UnitState.GetRank(), GameState);

	return ELR_NoInterrupt;
}*/