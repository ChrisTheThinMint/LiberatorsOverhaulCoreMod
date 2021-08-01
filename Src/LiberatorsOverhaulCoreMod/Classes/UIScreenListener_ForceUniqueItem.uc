class UIScreenListener_ForceUniqueItem extends UIStrategyScreenListener;

event OnInit(UIScreen Screen)
{
	local UISquadSelect SquadSelect;

	SquadSelect = UISquadSelect(Screen);
	
	if (SquadSelect != none)
	{
		RemoveUniqueItem(SquadSelect);
	}
}

event OnReceiveFocus(UIScreen Screen)
{
	local UISquadSelect SquadSelect;

	SquadSelect = UISquadSelect(Screen);
	
	if (SquadSelect != none)
	{
		RemoveUniqueItem(SquadSelect);
	}
}

simulated function RemoveUniqueItem(UISquadSelect SquadSelect)
{
    local StateObjectReference UnitReference;
	local XComGameState_Unit UnitState;
    local XComGameState_Unit NewUnitState;
	local name UniqueItem;
    local array<XComGameState_Item> Items;
    local XComGameState_Item ItemState;
    local XComGameState NewGameState;
    local XComGameState_HeadquartersXCom XComHQ;
    local int OneisOK;

	if (IsInStrategy())
	{
		// if (class'XComGameState_ALS'.static.UpdateSquad(`XCOMHQ.Squad))
		// {
		// 	//PrintSquad(`XCOMHQ.Squad);
		// 	SquadSelect.bDirty = true;
		// 	SquadSelect.UpdateData();
		// }

        foreach class'X2DownloadableContentInfo_LiberatorsOverhaulCoreMod'.default.arrUniqueItemInSquad(UniqueItem)
        {
            foreach `XCOMHQ.Squad(UnitReference)
            {
                // Get Unit State of UnitReference
                UnitState = XComGameState_Unit(`XCOMHISTORY.GetGameStateForObjectID(UnitReference.ObjectID));

                // See if it has item of template in config (UnitState.HasItemOfTemplateType(WeaponTemplate.DataName))
                if (UnitState.HasItemOfTemplateType(UniqueItem))
                {                    
                    `LOG("OneisOK " $ OneisOK, true, 'TR_RESTRICTITEM');
                    if (OneisOK < 1)
                    {
                        OneisOK++;                        
                        continue;
                    }

                    // Remove this item from the inventory and put back into HQ
                    Items = UnitState.GetAllInventoryItems();

                    foreach Items(ItemState)
                    {
                        if (ItemState.GetMyTemplateName() == UniqueItem)
                        {
                            NewGameState = class'XComGameStateContext_ChangeContainer'.static.CreateChangeState("Removing Unique Equipped Item");
                            ItemState = XComGameState_Item(NewGameState.ModifyStateObject(class'XComGameState_Item', ItemState.ObjectID));
                            NewUnitState = XComGameState_Unit(NewGameState.ModifyStateObject(class'XComGameState_Unit', UnitState.ObjectID));

                            if (NewUnitState.RemoveItemFromInventory(ItemState, NewGameState))
                            {
                                XComHQ = XComGameState_HeadquartersXCom(NewGameState.ModifyStateObject(class'XComGameState_HeadquartersXCom', `XCOMHQ.ObjectID));
                                XComHQ.PutItemInInventory(NewGameState, ItemState);
                                `GAMERULES.SubmitGameState(NewGameState);
                                SquadSelect.bDirty = true;
			                    SquadSelect.UpdateData();
                            }
                            else
                            {
                                // Failed to remove
                                `LOG("Nothing to remove", true, 'TR_RESTRICTITEM');
                                `XCOMHISTORY.CleanupPendingGameState(NewGameState);
                            }
                        }
                    }                        
                }                
            }            
        }
	}
}