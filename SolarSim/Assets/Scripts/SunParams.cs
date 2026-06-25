using UnityEngine;

namespace SolarSim
{
    public enum WavelengthPreset { Halpha, UV171, UV304, WhiteLight }

    [CreateAssetMenu(fileName = "SunParams", menuName = "SolarSim/Sun Params")]
    public class SunParams : ScriptableObject
    {
        [Header("Time")]
        [Range(0f, 10f)] public float timeScale = 1f;
        public bool paused = false;

        [Header("Surface — Granulation")]
        [Range(1f, 80f)]  public float granulationFrequency      = 40f;
        [Range(1f, 20f)]  public float supergranulationFrequency = 6f;
        [Range(1, 6)]     public int   fbmOctaves                = 4;
        [Range(0f, 8f)]   public float domainWarpStrength        = 4f;
        [Range(0f, 2f)]   public float flowSpeed                 = 0.3f;

        [Header("Surface — Color")]
        public Color  hotColor         = new Color(1f, 0.9f, 0.6f);
        public Color  coolColor        = new Color(0.8f, 0.15f, 0.02f);
        [Range(1f, 10f)] public float emissiveIntensity = 3f;

        [Header("Surface — Limb")]
        [Range(0f, 1f)]   public float limbDarkeningA   = 0.93f;
        [Range(-1f, 1f)]  public float limbDarkeningB   = -0.23f;
        [Range(0f, 5f)]   public float rimGlowIntensity = 1.5f;

        [Header("Surface — Features")]
        [Range(0f, 1f)] public float sunspotThreshold = 0.65f;
        [Range(0f, 1f)] public float activityLevel    = 0.5f;

        [Header("Prominences")]
        [Range(0, 20)]    public int   prominenceCount  = 5;
        [Range(0.1f, 3f)] public float prominenceHeight = 1.2f;
        [Range(0f, 1f)]   public float curlBlend        = 0.2f;

        [Header("Post Processing")]
        [Range(0f, 2f)] public float bloomThreshold = 0.9f;
        [Range(0f, 2f)] public float bloomIntensity = 0.5f;
        [Range(0f, 4f)] public float exposure       = 1f;

        [Header("Wavelength")]
        public WavelengthPreset wavelengthPreset = WavelengthPreset.Halpha;
    }
}
