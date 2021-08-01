class OnStatAssignmentCompleteClosure extends Object dependson(X2DownloadableContentInfo_LiberatorsOverhaulCoreMod);

var public delegate<X2CharacterTemplate.OnStatAssignmentComplete> OnStatAssignmentCompleteOriginalFn;

public function OnStatAssignmentCompleteFn(XComGameState_Unit Unit)
{
	if (OnStatAssignmentCompleteOriginalFn != none)
	{
		`LOG(default.Class @ GetFuncName() @ "calling original delegate" @ OnStatAssignmentCompleteOriginalFn,, 'Liberators Overhaul');
		
		OnStatAssignmentCompleteOriginalFn(Unit);
	}

	class'X2DownloadableContentInfo_LiberatorsOverhaulCoreMod'.static.RollForRandomTraits(Unit);
}