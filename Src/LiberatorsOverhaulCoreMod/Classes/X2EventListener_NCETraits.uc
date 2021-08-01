class X2EventListener_NCETraits extends X2EventListener_DefaultTraits config(Game);

var config array<name> TraitsToCreate;

static function array<X2DataTemplate> CreateTemplates()
{
	local array<X2DataTemplate> Templates;
	local name TraitName;

	foreach default.TraitsToCreate(TraitName)
	{
		Templates.AddItem(CreateNCETrait(TraitName));
	}
	
	return Templates;
}

static function X2EventListenerTemplate CreateNCETrait(name TraitName)
{
	local X2EventListenerTemplate Template;

	`CREATE_X2TEMPLATE(class'X2TraitTemplate', Template, TraitName)

	return Template;
}