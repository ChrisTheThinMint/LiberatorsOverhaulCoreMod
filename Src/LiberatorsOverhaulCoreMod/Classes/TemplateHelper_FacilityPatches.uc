class TemplateHelper_FacilityPatches extends Object config(GameData);

var config int PROVING_GROUND_TIME;
var config int PROVING_GROUND_POWER;
var config int PROVING_GROUND_UPKEEP;

var config name PROVING_GROUND_TECH;

static function PatchFacilities()
{
	PatchProvingGround();
}

static function PatchProvingGround()
{
	local X2StrategyElementTemplateManager	FacilityTemplateManager;
	local X2FacilityTemplate				FacilityTemplate;
	
	FacilityTemplateManager = class'X2StrategyElementTemplateManager'.static.GetStrategyElementTemplateManager();
	FacilityTemplate = X2FacilityTemplate(FacilityTemplateManager.FindStrategyElementTemplate('ProvingGround'));

	FacilityTemplate.Requirements.RequiredTechs.AddItem(default.PROVING_GROUND_TECH);
	FacilityTemplate.Requirements.bVisibleIfPersonnelGatesNotMet = true;

	FacilityTemplate.PointsToComplete = default.PROVING_GROUND_TIME;
	FacilityTemplate.iPower = default.PROVING_GROUND_POWER;
	FacilityTemplate.UpkeepCost = default.PROVING_GROUND_UPKEEP;
}