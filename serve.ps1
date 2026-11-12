$ErrorActionPreference="Stop"
Add-Type -TypeDefinition @"
using System;using System.IO;using System.Net;using System.Text;using System.Collections.Generic;
public class MiniServer {
  public static string Root = "";
  public static Dictionary<string,string> Mime = new Dictionary<string,string>{{".html","text/html; charset=utf-8"},{".css","text/css; charset=utf-8"},{".js","application/javascript"},{".png","image/png"},{".jpg","image/jpeg"},{".svg","image/svg+xml"},{".ico","image/x-icon"}};
  public static void Main2() {
    var l = new HttpListener(); l.Prefixes.Add("http://localhost:8766/"); l.Start();
    while(true){
      var c = l.GetContext();
      try {
        string path = c.Request.Url.AbsolutePath;
        if (path=="/") path="/index.html";
        string file = Path.Combine(Root, path.TrimStart('/').Replace('/',Path.DirectorySeparatorChar));
        if (File.Exists(file)){
          var bytes = File.ReadAllBytes(file);
          string ext = Path.GetExtension(file).ToLower();
          c.Response.Headers["Content-Type"] = Mime.ContainsKey(ext)?Mime[ext]:"application/octet-stream";
          c.Response.Headers["Access-Control-Allow-Origin"]="*";
          c.Response.OutputStream.Write(bytes,0,bytes.Length);
        } else { c.Response.StatusCode=404; }
        c.Response.Close();
      } catch {}
    }
  }
}
"@
[MiniServer]::Root = Join-Path $PSScriptRoot "site"
[MiniServer]::Main2()
