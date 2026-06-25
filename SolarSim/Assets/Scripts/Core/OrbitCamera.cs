using UnityEngine;
using UnityEngine.InputSystem;

namespace SolarSim.Core
{
    [RequireComponent(typeof(Camera))]
    public class OrbitCamera : MonoBehaviour
    {
        [Header("Orbit")]
        public float orbitSpeed  = 0.25f;
        public float minPitch    = -80f;
        public float maxPitch    =  80f;

        [Header("Zoom")]
        public float zoomSpeed   = 0.004f;
        public float minDistance = 1.5f;
        public float maxDistance = 20f;
        public float startDistance = 6f;

        float _yaw      = 0f;
        float _pitch    = 15f;
        float _distance;

        void Start() => _distance = startDistance;

        void LateUpdate()
        {
            var mouse = Mouse.current;
            if (mouse == null) return;

            if (mouse.leftButton.isPressed)
            {
                var d = mouse.delta.ReadValue();
                _yaw   += d.x * orbitSpeed;
                _pitch -= d.y * orbitSpeed;
                _pitch  = Mathf.Clamp(_pitch, minPitch, maxPitch);
            }

            _distance -= mouse.scroll.ReadValue().y * zoomSpeed;
            _distance  = Mathf.Clamp(_distance, minDistance, maxDistance);

            var rot = Quaternion.Euler(_pitch, _yaw, 0f);
            transform.SetPositionAndRotation(
                -rot * Vector3.forward * _distance,
                rot
            );
        }
    }
}
