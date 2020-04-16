taskkill /f /im nginx.exe

xcopy conf\*  runtime\conf\ /y /s /e
xcopy script\* runtime\script\ /y /s /e
xcopy extend\* runtime\extend\ /y /s /e
xcopy resource\* runtime\resource\ /y /s /e

start nginx -p runtime

