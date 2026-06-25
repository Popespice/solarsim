using UnityEngine;
using UnityEngine.Rendering;

namespace SolarSim
{
    // Replaces the MeshFilter mesh with a smooth UV sphere at startup.
    // Detail lives in the fragment shader; we just need a clean silhouette
    // and analytically perfect normals for limb-darkening math.
    [RequireComponent(typeof(MeshFilter), typeof(MeshRenderer))]
    public class SunSphere : MonoBehaviour
    {
        [Range(32, 256)] public int longitudeSegments = 128;
        [Range(16, 128)] public int latitudeSegments  = 64;

        void Awake() => GetComponent<MeshFilter>().mesh = Build(longitudeSegments, latitudeSegments);

        [ContextMenu("Rebuild")]
        void Rebuild() => GetComponent<MeshFilter>().sharedMesh = Build(longitudeSegments, latitudeSegments);

        static Mesh Build(int lon, int lat)
        {
            int vCount = (lon + 1) * (lat + 1);
            var verts   = new Vector3[vCount];
            var normals = new Vector3[vCount];
            var uvs     = new Vector2[vCount];

            for (int y = 0; y <= lat; y++)
            {
                float v     = (float)y / lat;
                float theta = v * Mathf.PI;
                float sinT  = Mathf.Sin(theta);
                float cosT  = Mathf.Cos(theta);

                for (int x = 0; x <= lon; x++)
                {
                    float u   = (float)x / lon;
                    float phi = u * Mathf.PI * 2f;
                    var n = new Vector3(sinT * Mathf.Cos(phi), cosT, sinT * Mathf.Sin(phi));
                    int  i = y * (lon + 1) + x;
                    verts[i]   = n * 0.5f;  // radius 0.5 matches Unity's default Sphere
                    normals[i] = n;
                    uvs[i]     = new Vector2(u, 1f - v);
                }
            }

            var tris = new int[lon * lat * 6];
            int t = 0;
            for (int y = 0; y < lat; y++)
                for (int x = 0; x < lon; x++)
                {
                    int bl = y * (lon + 1) + x;
                    int br = bl + 1, tl = bl + lon + 1, tr = tl + 1;
                    tris[t++] = bl; tris[t++] = tl; tris[t++] = tr;
                    tris[t++] = bl; tris[t++] = tr; tris[t++] = br;
                }

            var mesh = new Mesh { name = "SunSphere", indexFormat = IndexFormat.UInt32 };
            mesh.SetVertices(verts);
            mesh.SetNormals(normals);
            mesh.SetUVs(0, uvs);
            mesh.SetTriangles(tris, 0);
            mesh.RecalculateBounds();
            return mesh;
        }
    }
}
