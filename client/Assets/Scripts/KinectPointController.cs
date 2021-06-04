using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using Microsoft.Azure.Kinect.Sensor;
using System.Threading.Tasks;
using System.IO;
using System.Text;
using System;
using Mirror.SimpleWeb;
using WebSocketSharp;

public class KinectPointController : MonoBehaviour
{
    public int visibleTo = 4000;
    public int visbleFrom = 400;
    Device kinect;
    int num;
    Mesh mesh;
    Vector3[] vertices;
    Color32[] colors;

    int[] indices;
    Transformation transformation;

    WebSocket client = new WebSocket("ws://localhost:3000/kinect");

    void Start()
    {
        InitKinect();
        InitMesh();
        KinectLoop();

        client.Connect();
        
    }

    void InitKinect()
    {
        kinect = Device.Open();
        kinect.StartCameras(new DeviceConfiguration
        {
            ColorFormat = ImageFormat.ColorBGRA32,
            ColorResolution = ColorResolution.R720p,
            DepthMode = DepthMode.NFOV_2x2Binned,
            SynchronizedImagesOnly = true,
            CameraFPS = FPS.FPS30
        });
        transformation = kinect.GetCalibration().CreateTransformation();
    }

    void InitMesh()
    {
        int width = kinect.GetCalibration().DepthCameraCalibration.ResolutionWidth;
        int height = kinect.GetCalibration().DepthCameraCalibration.ResolutionHeight;

        num = width * height;
        mesh = new Mesh();
        mesh.indexFormat = UnityEngine.Rendering.IndexFormat.UInt32;

        vertices = new Vector3[num];
        colors = new Color32[num];
        indices = new int[num];

        //Initialization of index list
        for (int i = 0; i < num; i++)
        {
            indices[i] = i;
        }


        //Allocate a list of point coordinates, colors, and points to be drawn to mesh
        mesh.vertices = vertices;
        mesh.colors32 = colors;
        mesh.SetIndices(indices, MeshTopology.Points, 0);

        gameObject.GetComponent<MeshFilter>().mesh = mesh;
    }
    int i = 0;
    private async void KinectLoop()
    {
        while (true)
        {
            using (Capture capture = await Task.Run(() => kinect.GetCapture()).ConfigureAwait(true))
            {
                //Getting color information
                Image colorImage = transformation.ColorImageToDepthCamera(capture);
                BGRA[] colorPixels = colorImage.GetPixels<BGRA>().ToArray();

                //Getting vertices of point cloud
                Image depthImage = transformation.DepthImageToPointCloud(capture.Depth);
                Short3[] depthPixels = depthImage.GetPixels<Short3>().ToArray();
                List<byte> res = new List<byte>();
                for (int i = 0; i < num; i++)
                {
                    if (depthPixels[i].Z > visibleTo || depthPixels[i].Z < visbleFrom)
                    {
                        vertices[i].x = 0;
                        vertices[i].y = 0;
                        vertices[i].z = 0;
                        colors[i].a = 0;
                        continue;
                    }

                    vertices[i].x = depthPixels[i].X * 0.01f;
                    vertices[i].y = -depthPixels[i].Y * 0.01f;
                    vertices[i].z = depthPixels[i].Z * 0.01f;

                    colors[i].b = colorPixels[i].B;
                    colors[i].g = colorPixels[i].G;
                    colors[i].r = colorPixels[i].R;
                    colors[i].a = 255;

                    Vector3 v = vertices[i];
                    Color32 c = colors[i];
                    res.AddRange(transformPoint(v.x, v.y, v.z, c.r, c.g, c.b));

                }

                client.Send(res.ToArray());
                using (var writer = new BinaryWriter(File.Open("C:/Users/WinVX/Desktop/bin/bin" + i + ".bin", FileMode.Create))){
                    writer.Write(res.ToArray());
                    writer.Close();
                    i++;
                    Debug.Log("Writing done");
                }
                

                if (mesh == null) return;

                mesh.vertices = vertices;
                mesh.colors32 = colors;

                mesh.RecalculateBounds();

            }
        }
    }
    byte[] transformPoint(float x, float y, float z, byte r, byte g, byte b)
    {
        List<byte> res = new List<byte>();
        res.AddRange(transformFloat(x + 100));
        res.AddRange(transformFloat(y + 100));
        res.AddRange(transformFloat(z + 100));
        res.Add(r);
        res.Add(g);
        res.Add(b);
        return res.ToArray();
    }
    byte[] transformFloat(float n)
    {
        int full = (int)Math.Floor(n);
        int dec = (int)Math.Round((n - full) * 100);
        List<byte> res = new List<byte>();
        res.Add(Convert.ToByte(full));
        res.Add(Convert.ToByte(dec));
        return res.ToArray();
    }

    public static string byteToString(byte[] ba)
    {
        StringBuilder hex = new StringBuilder(ba.Length * 2);
        foreach (byte b in ba)
            hex.AppendFormat("{0:x2}", b);
        return hex.ToString();
    }

    //Stop Kinect as soon as this object disappear
    void OnDestroy()
    {
        kinect.StopCameras();
    }
}
