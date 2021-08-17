Class X2AIBT_AdditionalAIActions extends X2AIBTDefaultActions;

static event bool FindBTActionDelegate(name strName, optional out delegate<BTActionDelegate> dOutFn, optional out name NameParam, optional out name MoveProfile)
{
	dOutFn = None;
	switch( strName )
	{
		case 'SetDestructibleTargetStack-StandardShot':
			dOutFn = SetDestructibleTargetStack;
			NameParam = 'StandardShot';
			return true;
		break;

		default:
			`LOG("Unresolved behavior tree Action name with no delegate definition:"@strName);
		break;

	}
	return super.FindBTActionDelegate(strName, dOutFn, NameParam, MoveProfile);
}


function bt_status SetDestructibleTargetStack()
{
	if( BT_SetDestructibleTargetStack(SplitNameParam) )
	{
		return BTS_SUCCESS;
	}
	return BTS_FAILURE;
}

function bool BT_SetDestructibleTargetStack( Name strAbility )
{
	local AvailableTarget kTarget;
	local string DebugText;
	local bool FoundTarget, HoldYourFire;
	local XComGameStateHistory History;
	local XComGameState_Destructible kTargetState;
	local XComGameState_BaseObject TargetStateBase;
	local XComDestructibleActor DestructibleActor;
	local array<XComGameState_Unit> Units;
	local DestructibleActorEvent kEvent;
	local XComDestructibleActor_Action_RadialDamage RadialEvent;
	local int NumEnemiesExcludingLost, NumFriendlies, NumLost;
	local XComGameState_Unit Unit;
	
	m_kBehavior.m_kBTCurrTarget.TargetID = INDEX_NONE;
	m_kBehavior.m_kBTCurrAbility = m_kBehavior.FindAbilityByName( strAbility );
	if (m_kBehavior.m_kBTCurrAbility.AbilityObjectRef.ObjectID > 0 && m_kBehavior.m_kBTCurrAbility.AvailableCode == 'AA_Success' && m_kBehavior.m_kBTCurrAbility.AvailableTargets.Length > 0)
	{
		m_kBehavior.m_strBTCurrAbility = strAbility;
		FoundTarget = false;
		foreach m_kBehavior.m_kBTCurrAbility.AvailableTargets(kTarget)
		{
			Units.length = 0;
			 // Only allow AI to target destructibles.
			History = `XCOMHISTORY;
			TargetStateBase = History.GetGameStateForObjectID(kTarget.PrimaryTarget.ObjectID);
			kTargetState = XComGameState_Destructible(TargetStateBase);
			if (kTargetState == None)
			{
				continue;
			}
			DestructibleActor = XComDestructibleActor(kTargetState.GetVisualizer());
			foreach DestructibleActor.DestroyedEvents(kEvent)
			{
				RadialEvent = XComDestructibleActor_Action_RadialDamage(kEvent.Action);
				if( RadialEvent != None )
				{
					RadialEvent.GetUnitsInBlastRadius(Units);
					`LogAIBT("SetDestructibleTargetStack Found target with radial damage");
					break;
				}
			}
				
			// get unit count within blast radius for enemies and friendlies
			if(Units.length>0)
			{
				`LogAIBT("SetDestructibleTargetStack Found "$Units.length$" units in blast radius");
				NumEnemiesExcludingLost = 0;
				NumFriendlies = 0;
				NumLost = 0;
				foreach Units(Unit)
				{
					if(Unit.IsAlive())
					{
						if(m_kBehavior.UnitState.IsEnemyUnit(Unit))
						{
							if(Unit.GetTeam() == ETeam_TheLost)
							{
								NumLost++;
							}
							else
							{
								NumEnemiesExcludingLost++;
							}
						}
						else if(m_kBehavior.UnitState.IsFriendlyUnit(Unit))
						{
							// If unit in explosion is oneself or one of the Chosen then hold back the shot
							if (Unit.ObjectID == m_kBehavior.UnitState.ObjectID || Unit.IsChosen())
							{
								HoldYourFire = true;
							}
							NumFriendlies++;
						}
					}
				}
				
				`LogAIBT("SetDestructibleTargetStack Found "$NumEnemiesExcludingLost$" enemy units not including the lost in blast radius");
				`LogAIBT("SetDestructibleTargetStack Found "$NumLost$" lost units in blast radius");
				`LogAIBT("SetDestructibleTargetStack Found "$NumFriendlies$" friendly units in blast radius");
				// If there are at least 3 lost OR if number of enemies are greater than 0 (excluding the lost) and there aren't any friendlies
				// in the blast radius than add this target to the stack
				if((NumLost >= 3 || NumEnemiesExcludingLost > 0 && NumFriendlies == 0) ||
				// Or if there at least two enemies and 1 friendly that aren't a chosen or one self
					(NumEnemiesExcludingLost >= 2 && NumFriendlies == 1 && !HoldYourFire))
				{
					m_kBehavior.m_arrBTTargetStack.AddItem(kTarget);
					DebugText @= kTarget.PrimaryTarget.ObjectID;
					FoundTarget = true;
				}
			}
		}
		if(FoundTarget)
		{
			`LogAIBT("SetTargetStack results- Added:"@DebugText);
			return true;
		}
	}
	if( m_kBehavior.m_kBTCurrAbility.AbilityObjectRef.ObjectID <= 0 )
	{
		`LogAIBT("SetDestructibleTargetStack results- no Ability reference found: "$strAbility);
	}
	else if( m_kBehavior.m_kBTCurrAbility.AvailableCode != 'AA_Success' )
	{
		`LogAIBT("SetDestructibleTargetStack results- Ability unavailable - AbilityCode == "$ m_kBehavior.m_kBTCurrAbility.AvailableCode);
	}
	else
	{
		`LogAIBT("SetDestructibleTargetStack results- No targets available! ");
	}
	return false;
}

function bool IsDestructibleTarget(AvailableTarget kTarget, out XComDestructibleActor DestructibleActor)
{
	local XComGameStateHistory History;
	local XComGameState_Destructible kTargetState;
	local XComGameState_BaseObject TargetStateBase;
	
    // Only allow AI to target destructibles.
	History = `XCOMHISTORY;
	TargetStateBase = History.GetGameStateForObjectID(kTarget.PrimaryTarget.ObjectID);
	kTargetState = XComGameState_Destructible(TargetStateBase);
	if (kTargetState == None)
	{
		return false;
	}
	DestructibleActor = XComDestructibleActor(kTargetState.GetVisualizer());
	if (DestructibleActor.HasRadialDamage())
	{
		Return true;
	}
	Return False;
}

defaultproperties
{
}