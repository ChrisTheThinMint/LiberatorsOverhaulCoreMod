class X2DownloadableContentInfo_LiberatorsOverhaulAdventOverhaul extends X2DownloadableContentInfo config(Game);

// Update the Character Templates to assign the Stat Randomization function
static function UpdateCharacterTemplates()
{
	local X2CharacterTemplateManager	CharacterTemplateManager;
    local X2CharacterTemplate			CharTemplate;
    local array<X2DataTemplate>			DataTemplates;
    local X2DataTemplate				Template, DiffTemplate;

    CharacterTemplateManager = class'X2CharacterTemplateManager'.static.GetCharacterTemplateManager();

    foreach CharacterTemplateManager.IterateTemplates(Template, None)
    {
		
	}
}