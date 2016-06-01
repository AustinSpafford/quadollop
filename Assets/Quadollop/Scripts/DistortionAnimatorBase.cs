using UnityEngine;
using System.Collections;

public abstract class DistortionAnimatorBase : MonoBehaviour
{
	public void Awake()
	{
		materialInstance = GetComponent<Renderer>().material;

		distortionDegreesPropertyId = Shader.PropertyToID("_DistortionDegrees");

		if (materialInstance.HasProperty(distortionDegreesPropertyId) == false)
		{
			throw new System.InvalidOperationException();
		}
	}

	public void Update()
	{
		if (materialInstance != null)
		{
			materialInstance.SetFloat(
				distortionDegreesPropertyId,
				GetCurrentDistortionDegrees());
		}
	}

	public void OnDestroy()
	{
		Destroy(materialInstance);
	}

	public abstract float GetCurrentDistortionDegrees();

	private Material materialInstance = null;
	private int distortionDegreesPropertyId = -1;
}
