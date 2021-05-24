using System;

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

Console.WriteLine(byteToString(transformPoint(2.12f, 3.1f, 22.3f, 255, 44, 252)))

//102,12,103,10,122,30,255,44,252