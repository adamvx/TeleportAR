using System.Collections;
using System.Collections.Generic;
using UnityEngine;

[System.Serializable]
public class PointCloudData
{
    public Vector3 pos;

    public Point[] points = new Point[1024*1024];
}
