// Ugggghhhh copy-paste of X2Action_ApplyWeaponDamageToUnit.  Ripped most of it out.
//-----------------------------------------------------------
// Used by the visualizer system to control a Visualization Actor
//-----------------------------------------------------------
class X2Action_DisplayCoverDR extends X2Action 
	dependson(XComAnimNodeBlendDynamic)
	config(Animation);

var X2AbilityTemplate                                                       AbilityTemplate; //The template for the ability that is affecting us
var Actor                                                                   DamageDealer;
var XComGameState_Unit														SourceUnitState;
var int                                                                     m_iDamage, m_iMitigated, m_iShielded, m_iShredded;
var array<DamageResult>                                                     DamageResults;
var array<EAbilityHitResult>                                                HitResults;
var name																	DamageTypeName;
var Vector                                                                  m_vHitLocation;
var Vector                                                                  m_vMomentum;
var bool                                                                    bGoingToDeathOrKnockback;
var bool                                                                    bWasHit;
var bool                                                                    bWasCounterAttack;
var bool                                                                    bCounterAttackAnim;
var XComGameStateContext_Ability                                            AbilityContext;
var CustomAnimParams                                                        AnimParams;
var EAbilityHitResult                                                       HitResult;
var XComGameStateContext_TickEffect                                         TickContext;
var XComGameStateContext_AreaDamage                                         AreaDamageContext;
var XComGameStateContext_Falling                                            FallingContext;
var XComGameStateContext_ApplyWorldEffects                                  WorldEffectsContext;
var int                                                                     TickIndex;      //This is set by AddX2ActionsForVisualization_Tick
var AnimNodeSequence                                                        PlayingSequence;
var X2Effect                                                                OriginatingEffect;
var X2Effect                                                                AncestorEffect; //In the case of ticking effects causing damage effects, this is the ticking effect (if known and different)
var bool                                                                    bHiddenAction;
var StateObjectReference													CounterAttackTargetRef;
var bool                                                                    bDoOverrideAnim;
var XComGameState_Unit                                                      OverrideOldUnitState;
var X2Effect_Persistent                                                     OverridePersistentEffectTemplate;
var string                                                                  OverrideAnimEffectString;
var bool                                                                    bPlayDamageAnim;  // Only display the first damage hit reaction
var bool                                                                    bIsUnitRuptured;
var bool																	bShouldContinueAnim;
var bool																	bMoving;
var bool																	bSkipWaitForAnim;
var X2Action_MoveDirect														RunningAction;
var config float															HitReactDelayTimeToDeath;
var XComGameState_Unit														UnitState;
var XComGameState_AIGroup													GroupState;
var int																		ScanGroup;
var XGUnit																	ScanUnit;
var XComPerkContentInst														kPerkContent;
var array<name>                                                             TargetAdditiveAnims;
var bool																	bShowFlyovers;		
var bool																	bCombineFlyovers;


var X2Effect DamageEffect;		// If the damage was from an effect, this is the effect
var EAbilityHitResult														EffectHitEffectsOverride;
var X2Action_Fire															CounterattackedAction;

// Needs to match values in DamageMessageBox.as
enum eWeaponDamageType
{
	eWDT_Armor,
	eWDT_Shred,
	eWDT_Repeater,
	eWDT_Psi,
};

function Init()
{
	local int MultiIndex, WorldResultIndex;
	local int DmgIndex;
	local XComGameState_Unit OldUnitState;
	local X2EffectTemplateRef LookupEffect;
	local X2Effect SourceEffect;
	local XComGameState_Item SourceItemGameState;
	local X2WeaponTemplate WeaponTemplate;
	local XComGameStateHistory History;
	local XComGameStateContext_Ability IterateAbility;	
	local XComGameState LastGameStateInInterruptChain;
	local DamageResult DmgResult;
	local bool IsKnockback;
	local array<X2Action> RunningActions;
	local array<X2Action> ApplyDamageToUnitActions;
	local X2Action ParentFireAction;

	super.Init();

	History = `XCOMHISTORY;	

	AbilityContext = XComGameStateContext_Ability(StateChangeContext);	
	if (AbilityContext != none)
	{
		LastGameStateInInterruptChain = AbilityContext.GetLastStateInInterruptChain();

		//Perform special processing for counter attack before doing anything with AbilityContext, as we may need to switch
		//to the counter attack ability context
		if (AbilityContext.ResultContext.HitResult == eHit_CounterAttack)
		{	
			bWasCounterAttack = true;
			//Check if we are the original shooter in a counter attack sequence, meaning that we are now being attacked. The
			//target of a counter attack just plays a different flinch/reaction anim
			IterateAbility = class'X2Ability'.static.FindCounterAttackGameState(AbilityContext, XComGameState_Unit(Metadata.StateObject_NewState));
			if (IterateAbility != None)
			{
				//In this situation we need to update ability context so that it is from the counter attack game state				
				AbilityContext = IterateAbility;
				OldUnitState = XComGameState_Unit(History.GetGameStateForObjectID(Metadata.StateObject_NewState.ObjectID, eReturnType_Reference, AbilityContext.AssociatedState.HistoryIndex - 1));
				UnitState = XComGameState_Unit(History.GetGameStateForObjectID(Metadata.StateObject_NewState.ObjectID, eReturnType_Reference, AbilityContext.AssociatedState.HistoryIndex));
				bCounterAttackAnim = false; //We are the target of the counter attack, don't play the counter attack anim
			}
			else
			{
				CounterAttackTargetRef = AbilityContext.InputContext.SourceObject;
				bCounterAttackAnim = true; //We are counter attacking, play the counter attack anim
				if (FindParentOfType(class'X2Action_Fire', ParentFireAction))
				{
					CounterattackedAction = X2Action_Fire(ParentFireAction);					
				}
			}
		}
		else
		{
			UnitState = XComGameState_Unit(LastGameStateInInterruptChain.GetGameStateForObjectID(Metadata.StateObject_NewState.ObjectID));
			if (UnitState == None) //This can occur for abilities which were interrupted but never resumed, e.g. because the shooter was killed.
				UnitState = XComGameState_Unit(Metadata.StateObject_NewState); //Will typically be the same as the OldState in this case.

			`assert(UnitState != none);			//	this action should have only been added for a unit!
			OldUnitState = XComGameState_Unit(Metadata.StateObject_OldState);
			`assert(OldUnitState != none);
		}
	}
	else
	{
		TickContext = XComGameStateContext_TickEffect(StateChangeContext);
		AreaDamageContext = XComGameStateContext_AreaDamage(StateChangeContext);
		FallingContext = XComGameStateContext_Falling(StateChangeContext);
		WorldEffectsContext = XComGameStateContext_ApplyWorldEffects(StateChangeContext);

		UnitState = XComGameState_Unit(Metadata.StateObject_NewState);
		OldUnitState = XComGameState_Unit(Metadata.StateObject_OldState);
	}

	m_iDamage = 0;
	m_iMitigated = 0;
	
	if (AbilityContext != none)
	{
		SourceUnitState = XComGameState_Unit(History.GetGameStateForObjectID(AbilityContext.InputContext.SourceObject.ObjectID));
		DamageDealer = History.GetGameStateForObjectID(AbilityContext.InputContext.SourceObject.ObjectID).GetVisualizer();
		SourceItemGameState = XComGameState_Item(History.GetGameStateForObjectID(AbilityContext.InputContext.ItemObject.ObjectID));

		if (SourceItemGameState != none)
			WeaponTemplate = X2WeaponTemplate(SourceItemGameState.GetMyTemplate());
	}

	//Set up a damage type
	if (WeaponTemplate != none)
	{
		DamageTypeName = WeaponTemplate.BaseDamage.DamageType;
		if (DamageTypeName == '')
		{
			DamageTypeName = WeaponTemplate.DamageTypeTemplateName;
		}
	}
	else if (TickContext != none || WorldEffectsContext != none)
	{
		for (DmgIndex = 0; DmgIndex < UnitState.DamageResults.Length; ++DmgIndex)
		{
			if (UnitState.DamageResults[DmgIndex].Context == StateChangeContext)
			{
				LookupEffect = UnitState.DamageResults[DmgIndex].SourceEffect.EffectRef;
				SourceEffect = class'X2Effect'.static.GetX2Effect(LookupEffect);
				DamageEffect = SourceEffect;
				if (SourceEffect.DamageTypes.Length > 0)
					DamageTypeName = SourceEffect.DamageTypes[0];
				m_iDamage = UnitState.DamageResults[DmgIndex].DamageAmount;
				break;
			}
		}
	}
	else
	{
		DamageTypeName = class'X2Item_DefaultDamageTypes'.default.DefaultDamageType;
	}

	bWasHit = false;
	IsKnockback = false;
	m_vHitLocation = UnitPawn.GetHeadshotLocation();
	if (AbilityContext != none)
	{
		AbilityTemplate =  class'XComGameState_Ability'.static.GetMyTemplateManager().FindAbilityTemplate(AbilityContext.InputContext.AbilityTemplateName);
		`assert(AbilityTemplate != none);
		if (AbilityContext.InputContext.PrimaryTarget.ObjectID == Metadata.StateObject_NewState.ObjectID)
		{
			bWasHit = bWasHit || AbilityContext.IsResultContextHit();	
			HitResult = AbilityContext.ResultContext.HitResult;
			HitResults.AddItem(HitResult);
		}
		
		for (MultiIndex = 0; MultiIndex < AbilityContext.InputContext.MultiTargets.Length; ++MultiIndex)
		{
			if (AbilityContext.InputContext.MultiTargets[MultiIndex].ObjectID == Metadata.StateObject_NewState.ObjectID)
			{
				bWasHit = bWasHit || AbilityContext.IsResultContextMultiHit(MultiIndex);
				HitResult = AbilityContext.ResultContext.MultiTargetHitResults[MultiIndex];
				HitResults.AddItem(HitResult);
			}
		}	
	}
	else if (TickContext != none)
	{
		bWasHit = (TickIndex == INDEX_NONE) || (TickContext.arrTickSuccess[TickIndex] == 'AA_Success');
		HitResult = bWasHit ? eHit_Success : eHit_Miss;

		if (bWasHit)
			HitResults.AddItem(eHit_Success);
	}
	else if (FallingContext != none || AreaDamageContext != None)
	{
		bWasHit = true;
		HitResult = eHit_Success;

		HitResults.AddItem( eHit_Success );
	}
	else if (WorldEffectsContext != none)
	{
		for (WorldResultIndex = 0; WorldResultIndex < WorldEffectsContext.TargetEffectResults.Effects.Length; ++WorldResultIndex)
		{
			if (WorldEffectsContext.TargetEffectResults.Effects[WorldResultIndex] == OriginatingEffect)
			{
				if (WorldEffectsContext.TargetEffectResults.ApplyResults[WorldResultIndex] == 'AA_Success')
				{
					bWasHit = true;
					HitResult = eHit_Success;
					HitResults.AddItem(eHit_Success);
				}
				else
				{
					bWasHit = false;
					HitResult = eHit_Miss;
					HitResults.AddItem(eHit_Miss);
				}
					
				break;
			}
		}
	}
	else
	{
		`RedScreen("Unhandled context for this action:" @ StateChangeContext @ self);
	}

	if (AbilityContext != none || TickContext != none)
	{
		if (bWasHit)
		{
			bPlayDamageAnim = false;
		}

		for (DmgIndex = 0; DmgIndex < UnitState.DamageResults.Length; ++DmgIndex)
		{ 
			if (LastGameStateInInterruptChain != none)
			{
				if(UnitState.DamageResults[DmgIndex].Context != LastGameStateInInterruptChain.GetContext())
					continue;
			}
			else if (UnitState.DamageResults[DmgIndex].Context != StateChangeContext)
			{
				continue;
			}
			LookupEffect = UnitState.DamageResults[DmgIndex].SourceEffect.EffectRef;
			SourceEffect = class'X2Effect'.static.GetX2Effect(LookupEffect);
			if (SourceEffect == OriginatingEffect || (AncestorEffect != None && SourceEffect == AncestorEffect))
			{
				DamageResults.AddItem(UnitState.DamageResults[DmgIndex]);
				m_iDamage = UnitState.DamageResults[DmgIndex].DamageAmount;
				m_iMitigated = UnitState.DamageResults[DmgIndex].MitigationAmount;

				if (bWasHit)
				{
					bPlayDamageAnim = true;
				}
			}
		}
	}
	else if (AreaDamageContext != None)
	{
		//  For falling and area damage, there isn't an effect to deal with, so just grab the raw change in HP
		m_iDamage = OldUnitState.GetCurrentStat( eStat_HP ) - UnitState.GetCurrentStat( eStat_HP );

		for (DmgIndex = 0; DmgIndex < UnitState.DamageResults.Length; ++DmgIndex)
		{
			if (UnitState.DamageResults[DmgIndex].Context == AreaDamageContext)
			{
				DmgResult = UnitState.DamageResults[DmgIndex];
				break;
			}
		}

		DmgResult.DamageAmount = m_iDamage;
		DmgResult.Context = AreaDamageContext;

		DamageResults.AddItem( DmgResult );

		bPlayDamageAnim = HasSiblingOfType(class'X2Action_ApplyWeaponDamageToUnit', ApplyDamageToUnitActions) ? (ApplyDamageToUnitActions[0] == self) : false;
	}
	else if (FallingContext != none)
	{
		//  For falling and area damage, there isn't an effect to deal with, so just grab the raw change in HP
		m_iDamage = OldUnitState.GetCurrentStat( eStat_HP ) - UnitState.GetCurrentStat( eStat_HP );
		
		DmgResult.DamageAmount = m_iDamage;
		DmgResult.Context = FallingContext;

		DamageResults.AddItem( DmgResult );
	}
	else
	{
		//  For falling and area damage, there isn't an effect to deal with, so just grab the raw change in HP
		m_iDamage = OldUnitState.GetCurrentStat(eStat_HP) - UnitState.GetCurrentStat(eStat_HP);
	}
	
	bGoingToDeathOrKnockback = UnitState.IsDead() || UnitState.IsIncapacitated() || IsKnockback;

	// If the old state was not Ruptured and the new state has become Ruptured
	bIsUnitRuptured = (OldUnitState.Ruptured == 0) && (UnitState.Ruptured > 0);

	bMoving = `XCOMVISUALIZATIONMGR.IsRunningAction(Unit, class'X2Action_Move', RunningActions);
	if( bMoving )
	{
		RunningAction = X2Action_MoveDirect(RunningActions[0]);
	}
}

function bool AllowEvent(Object EventData, Object EventSource, XComGameState GameState, Name EventID, Object CallbackData)
{
	local XComGameState_Unit EventDataUnit;

	EventDataUnit = XComGameState_Unit(EventData);
	if( EventID == 'Visualizer_ProjectileHit' && (EventDataUnit == None || EventDataUnit.ObjectID != Metadata.StateObject_NewState.ObjectID) )
	{
		return false;
	}

	if (!super.AllowEvent(EventData, EventSource, GameState, EventID, CallbackData))
	{
		return false;
	}

	bShouldContinueAnim = true;

	return true;
}

function bool IsTimedOut()
{
	return ExecutingTime >= TimeoutSeconds;
}

simulated state Executing
{
	simulated event BeginState(name nmPrevState)
	{
		super.BeginState(nmPrevState);
	}

	simulated function ShowDamageMessage(EWidgetColor SuccessfulAttackColor, EWidgetColor UnsuccessfulAttackColor)
	{
		// change here
		if( m_iMitigated > 0 )
		{
			ShowMitigationMessage(UnsuccessfulAttackColor);
		}
	}

	// normally, this message prints the unit's static armor, rather than the damage mitigated.
	// I guess this is done so that the post-shredding armor value is displayed?
	// this is changed to the actual mitigation here so that you can see the effect of cover DR
	// we still remove the shredded amount so that the numbers will add up to the total damage.
	simulated function ShowMitigationMessage(EWidgetColor DisplayColor)
	{
		local int iArmorLeft;
		local int CurrentArmor;
		CurrentArmor = UnitState.GetArmorMitigationForUnitFlag();
		iArmorLeft = m_iMitigated - m_iShredded - CurrentArmor;

		if (iArmorLeft > 0)
		{
			if(UnitState.CanTakeCover())
			{
				class'UIWorldMessageMgr'.static.DamageDisplay(m_vHitLocation, Unit.GetVisualizedStateReference(), class'CoverDR_Impl'.default.MitigationMessage, UnitPawn.m_eTeamVisibilityFlags, , iArmorLeft, /*modifier*/, /*crit*/, eWDT_Armor, DisplayColor);
				//class'UIWorldMessageMgr'.static.DamageDisplay(m_vHitLocation, Unit.GetVisualizedStateReference(), class'CoverDR_Impl'.default.MitigationMessage, UnitPawn.m_eTeamVisibilityFlags, class'XComUIBroadcastWorldMessage_DamageDisplay', iArmorLeft, /*modifier*/, /*crit*/, eWDT_Armor);
			}
			else
			{
				class'UIWorldMessageMgr'.static.DamageDisplay(m_vHitLocation, Unit.GetVisualizedStateReference(), class'CoverDR_Impl'.default.MitigationNoCoverMessage, UnitPawn.m_eTeamVisibilityFlags, , iArmorLeft, /*modifier*/, /*crit*/, eWDT_Armor, DisplayColor);
			}
		}
	}

	simulated function ShowAttackMessages()
	{			
		local int i, SpecialDamageIndex;
		local ETeam TargetUnitTeam;
		local EWidgetColor SuccessfulAttackColor, UnsuccessfulAttackColor;

		if(!class'X2TacticalVisibilityHelpers'.static.IsUnitVisibleToLocalPlayer(UnitState.ObjectId, CurrentHistoryIndex))
			return;

		TargetUnitTeam = UnitState.GetTeam();
		if( TargetUnitTeam == eTeam_XCom || TargetUnitTeam == eTeam_Resistance )
		{
			SuccessfulAttackColor = eColor_Bad;
			UnsuccessfulAttackColor = eColor_Good;
		}
		else
		{
			SuccessfulAttackColor = eColor_Good;
			UnsuccessfulAttackColor = eColor_Bad;
		}

		if (HitResults.Length == 0 && DamageResults.Length == 0 && bWasHit)
		{
			// Must be damage from World Effects (Fire, Poison, Acid)
		}
		else
		{
			//It seems that misses contain a hit result but no damage results. So fill in some zero / null damage result entries if there is a mismatch.
			if(HitResults.Length > DamageResults.Length)
			{				
				for( i = 0; i < HitResults.Length; ++i )
				{
					if( HitResults[i] == eHit_Miss )
					{
						DamageResults.Insert(i, 1);
					}
				}
			}

			if( bCombineFlyovers )
			{
				m_iDamage = 0;
				m_iMitigated = 0;
				m_iShielded = 0;
				m_iShredded = 0;
				for( i = 0; i < HitResults.Length && i < DamageResults.Length; i++ ) // some abilities damage the same target multiple times
				{
					if( HitResults[i] == eHit_Success )
					{
						m_iDamage += DamageResults[i].DamageAmount;
						m_iMitigated += DamageResults[i].MitigationAmount;
						m_iShielded += DamageResults[i].ShieldHP;
						m_iShredded += DamageResults[i].Shred;
					}
				}

				ShowDamageMessage(SuccessfulAttackColor, UnsuccessfulAttackColor);
			}
			else
			{
				for( i = 0; i < HitResults.Length && i < DamageResults.Length; i++ ) // some abilities damage the same target multiple times
				{
					HitResult = HitResults[i];

					m_iDamage = DamageResults[i].DamageAmount;
					m_iMitigated = DamageResults[i].MitigationAmount;
					m_iShielded = DamageResults[i].ShieldHP;
					m_iShredded = DamageResults[i].Shred;

					if( DamageResults[i].bFreeKill )
					{
						//ShowFreeKillMessage( DamageResults[i].FreeKillAbilityName, SuccessfulAttackColor);
						return;
					}

					for( SpecialDamageIndex = 0; SpecialDamageIndex < DamageResults[i].SpecialDamageFactors.Length; ++SpecialDamageIndex )
					{
						//ShowSpecialDamageMessage(DamageResults[i].SpecialDamageFactors[SpecialDamageIndex], (DamageResults[i].SpecialDamageFactors[SpecialDamageIndex].Value > 0) ? SuccessfulAttackColor : UnsuccessfulAttackColor);
					}

					if (DamageResults[i].bImmuneToAllDamage)
					{
						continue;
					}

					switch( HitResult )
					{
					case eHit_Success:
						ShowDamageMessage(SuccessfulAttackColor, UnsuccessfulAttackColor);
						break;
					default:
						break;
					}
				}
			}
		}
	}

Begin:
	if (!bHiddenAction)
	{
		if( bShowFlyovers )
		{
			ShowAttackMessages();
		}
	}

	CompleteAction();
}

DefaultProperties
{
	InputEventIDs.Add( "Visualizer_AbilityHit" )
	InputEventIDs.Add( "Visualizer_ProjectileHit" )
	OutputEventIDs.Add( "Visualizer_EffectApplied" )
	TimeoutSeconds = 8.0f
	bDoOverrideAnim = false
	bPlayDamageAnim = true
	bCauseTimeDilationWhenInterrupting = true
	bShowFlyovers = true
}

