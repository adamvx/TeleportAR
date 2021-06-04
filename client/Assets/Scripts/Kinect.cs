using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using Microsoft.Azure.Kinect.Sensor;

public class Kinect : MonoBehaviour
{
    Device kinect;
    
    Texture2D colorTexture;

    [SerializeField]
    UnityEngine.UI.RawImage rawImage;

    
    void Start()
    {

        Debug.Log("STQRT");
        kinect = Device.Open();
        Debug.Log(Device.GetInstalledCount());
        if (kinect == null) return;
        kinect.StartCameras(new DeviceConfiguration{
            ColorFormat = ImageFormat.ColorBGRA32,
            ColorResolution = ColorResolution.R720p,
            DepthMode = DepthMode.NFOV_2x2Binned,
            SynchronizedImagesOnly = true,
            CameraFPS = FPS.FPS30
        });
        int width = kinect.GetCalibration().ColorCameraCalibration.ResolutionWidth;
        int height = kinect.GetCalibration().ColorCameraCalibration.ResolutionHeight;

        colorTexture = new Texture2D(width, height);

    }

    void Update(){
        if (kinect == null) return;
        Capture capture = kinect.GetCapture();
        Image colorImage = capture.Color;

        Color32[] pixels = colorImage.GetPixels<Color32>().ToArray();
        colorTexture.SetPixels32(pixels);
        colorTexture.Apply();
        rawImage.texture = colorTexture;
    }

    void OnDestroy() {
        kinect.StopCameras();
    }

}
