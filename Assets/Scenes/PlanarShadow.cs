using UnityEngine;

public class PlanarShadow : MonoBehaviour
{
    public Transform plane;
    public Material PlanarShadowMaterial;

    void Start()
    {
        if (plane == null || PlanarShadowMaterial == null)
        {
            enabled = false;
            return;
        }
    }

    void Update()
    {
        PlanarShadowMaterial.SetVector("_PlaneNormal", plane.up);
    }
}
