$port = 8080
$path = "C:\Users\fareed\.gemini\antigravity\scratch\imperial-restaurant"

$listener = New-Object System.Net.HttpListener
$listener.Prefixes.Add("http://localhost:$port/")
try {
    $listener.Start()
    Write-Output "Server running at http://localhost:$port/"
    while ($listener.IsListening) {
        $context = $listener.GetContext()
        $request = $context.Request
        $response = $context.Response
        
        try {
            $reqUrl = $request.Url.LocalPath.TrimStart('/')
            if ([string]::IsNullOrEmpty($reqUrl) -or $reqUrl -eq "") {
                $reqUrl = "index.html"
            }
            $reqUrl = [System.Uri]::UnescapeDataString($reqUrl)
            $fullPath = Join-Path $path $reqUrl
            
            if (Test-Path $fullPath -PathType Leaf) {
                $bytes = [System.IO.File]::ReadAllBytes($fullPath)
                $ext = [System.IO.Path]::GetExtension($fullPath).ToLower()
                $mime = "text/plain"
                switch ($ext) {
                    ".html" { $mime = "text/html; charset=utf-8" }
                    ".htm"  { $mime = "text/html; charset=utf-8" }
                    ".css"  { $mime = "text/css; charset=utf-8" }
                    ".js"   { $mime = "application/javascript; charset=utf-8" }
                    ".jpg"  { $mime = "image/jpeg" }
                    ".jpeg" { $mime = "image/jpeg" }
                    ".png"  { $mime = "image/png" }
                    ".gif"  { $mime = "image/gif" }
                    ".svg"  { $mime = "image/svg+xml" }
                    ".webp" { $mime = "image/webp" }
                    ".json" { $mime = "application/json" }
                }
                $response.ContentType = $mime
                $response.ContentLength64 = $bytes.LongLength
                $response.OutputStream.Write($bytes, 0, $bytes.Length)
            } else {
                $response.StatusCode = 404
                $errBytes = [System.Text.Encoding]::UTF8.GetBytes("404 Not Found")
                $response.ContentLength64 = $errBytes.LongLength
                $response.OutputStream.Write($errBytes, 0, $errBytes.Length)
            }
        } catch {
            Write-Output "Error handling request: $_"
        } finally {
            try { $response.Close() } catch {}
        }
    }
} finally {
    $listener.Stop()
}
