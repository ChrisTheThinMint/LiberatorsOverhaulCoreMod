class AdventMedic_X2AIBTActions extends X2AIBTDefaultActions;

// SetDestinationNextToTroubledTeammate - Get destination next to closest
function bt_status SetDestinationNextToTroubledTeammate()
{
	local XComGameState_Unit ClosestTargetUnit;
	local XComGameState_Unit Teammate;
	local array<XComGameState_Unit> Teammates;
	local float DistanceSquared;
	local float ClosestDistanceSquared;
	local XComWorldData World;
	local vector ClosestTargetUnitLoc;

	World = `XWORLD;

	// Get units
	m_kBehavior.m_kPlayer.GetUnits(Teammates);

	// Get closest ally that is wounded or unconscious
	foreach Teammates(Teammate)
	{
		if ( !Teammate.IsRobotic() && !Teammate.IsDead() && ( Teammate.IsPanicked() || Teammate.IsUnconscious() || Teammate.IsDazed() || ( Teammate.GetCurrentStat(eStat_HP) < (Teammate.GetMaxStat(eStat_HP) / 1.8) )))
		{
			DistanceSquared = VSizeSq(World.GetPositionFromTileCoordinates(Teammate.TileLocation) - World.GetPositionFromTileCoordinates(m_kUnitState.TileLocation));

			// Make sure we're not looking at the same unit
			if( DistanceSquared > 1 && (( DistanceSquared < ClosestDistanceSquared ) || ClosestTargetUnit == None ))
			{
				ClosestTargetUnit = Teammate;
				ClosestDistanceSquared = DistanceSquared;
			}
		}
	}
	// If we have a target unit, get a destination
	if (ClosestTargetUnit != None)
	{
		// If very far, lets dash
		if ( ClosestDistanceSquared > 1800000 ) {
			m_kBehavior.BT_SetCanDash();
		}
		ClosestTargetUnitLoc = World.GetPositionFromTileCoordinates(ClosestTargetUnit.TileLocation);
		if (m_kBehavior.HasValidDestinationToward(ClosestTargetUnitLoc, ClosestTargetUnitLoc))
		{
			m_kBehavior.GetClosestCoverLocation(ClosestTargetUnitLoc, ClosestTargetUnitLoc, false);
			m_kBehavior.m_vBTDestination = ClosestTargetUnitLoc;
			m_kBehavior.m_bBTDestinationSet = true;
			return BTS_SUCCESS;
		}
	}

	return BTS_FAILURE;
}