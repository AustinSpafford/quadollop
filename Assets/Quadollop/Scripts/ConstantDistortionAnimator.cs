using UnityEngine;
using System.Collections;

public class ConstantDistortionAnimator : DistortionAnimatorBase
{
	public float CycleSeconds = 2.0f;

	public override float GetCurrentDistortionDegrees()
	{
		float animationFraction = 
			Mathf.Repeat(
				(Time.time / CycleSeconds),
				1.0f);

		return (360.0f * animationFraction);
	}
}
