class X2Action_Fire_Haymaker extends X2Action_Fire;

function Init()
{
	local XComGameState_Item	PrimaryWeaponState;
	local X2WeaponTemplate		WeaponTemplate;
	local name					TemplateName;

	super.Init();

	PrimaryWeaponState = SourceUnitState.GetItemInSlot(eInvSlot_PrimaryWeapon);

	if (PrimaryWeaponState != none)
	{
		TemplateName = PrimaryWeaponState.GetMyTemplateName();

		WeaponTemplate = X2WeaponTemplate(PrimaryWeaponState.GetMyTemplate());
		if (WeaponTemplate.WeaponCat == 'sword')
		{
			AnimParams.AnimName = 'FF_Haymaker';
		}
		else 
		{
			AnimParams.AnimName = 'FF_Melee_Punch';
		}
	}
	else `LOG("ERROR: X2Action_Fire_Haymaker: no Primary Weapon State while using Haymaker!",, 'IRI_RIDER');
}