using UnityEngine;
using System.Collections;

public class Overlay_ImageEffect : MonoBehaviour
{

    #region Variables  
    public Shader curShader;
    public Texture2D blendTexture;
    public float blendOpacity = 1.0f;

    private Material curMaterial;

    #endregion
    #region Properties  
    public Material material
    {
        get
        {
            if (curMaterial == null)
            {
                curMaterial = new Material(curShader);
                curMaterial.hideFlags = HideFlags.HideAndDontSave;
            }
            return curMaterial;
        }
    }
    #endregion

    // Use this for initialization  
    void Start()
    {
        if (SystemInfo.supportsImageEffects == false)
        {
            enabled = false;
            return;
        }

        if (curShader != null && curShader.isSupported == false)
        {
            enabled = false;
        }
    }

    void OnRenderImage(RenderTexture sourceTexture, RenderTexture destTexture)
    {
        if (curShader != null)
        {
            material.SetTexture("_BlendTex", blendTexture);
            material.SetFloat("_Opacity", blendOpacity);

            Graphics.Blit(sourceTexture, destTexture, material);
        }
        else
        {
            Graphics.Blit(sourceTexture, destTexture);
        }
    }

    // Update is called once per frame  
    void Update()
    {
        blendOpacity = Mathf.Clamp(blendOpacity, 0.0f, 1.0f);
    }

    void OnDisable()
    {
        if (curMaterial != null)
        {
            DestroyImmediate(curMaterial);
        }
    }
}
