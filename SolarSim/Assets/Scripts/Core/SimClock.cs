using UnityEngine;

namespace SolarSim.Core
{
    public class SimClock : MonoBehaviour
    {
        public static SimClock Instance { get; private set; }

        public SunParams sunParams;

        public float Time  { get; private set; }

        void Awake()
        {
            if (Instance != null && Instance != this) { Destroy(gameObject); return; }
            Instance = this;
        }

        void Update()
        {
            if (sunParams == null || sunParams.paused) return;
            Time += UnityEngine.Time.deltaTime * sunParams.timeScale;
        }
    }
}
