@echo off
echo bootstrap

set DESKTOP=%USERPROFILE%\Desktop
set PROJECT=%USERPROFILE%\TaskBuilderApp

where dotnet >nul 2>nul
if %errorlevel% neq 0 (
echo Installing .NET SDK...
winget install --id Microsoft.DotNet.SDK.8 -e --accept-source-agreements --accept-package-agreements
)

timeout /t 2 >nul

if not exist "%PROJECT%" mkdir "%PROJECT%"
cd /d "%PROJECT%"

dotnet new winforms -n TaskApp -f net8.0 >nul
cd TaskApp

(
echo using System;
echo using System.Diagnostics;
echo using System.Linq;
echo using System.Windows.Forms;
echo.
echo public class MainForm : Form
echo {
echo     DataGridView grid = new DataGridView();
echo     Timer timer = new Timer();
echo.
echo     public MainForm()
echo     {
echo         Text = "Task";
echo         Width = 900;
echo         Height = 600;
echo.
echo         grid.Dock = DockStyle.Fill;
echo         Controls.Add(grid);
echo.
echo         grid.ColumnCount = 4;
echo         grid.Columns[0].Name = "PID";
echo         grid.Columns[1].Name = "Name";
echo         grid.Columns[2].Name = "CPU";
echo         grid.Columns[3].Name = "Memory";
echo.
echo         timer.Interval = 2000;
echo         timer.Tick += (s, e) =^> Load();
echo         timer.Start();
echo.
echo         Load();
echo     }
echo.
echo     void Load()
echo     {
echo         grid.Rows.Clear();
echo         foreach (var p in Process.GetProcesses().Take(200))
echo         {
echo             try
echo             {
echo                 grid.Rows.Add(p.Id, p.ProcessName, "N/A", p.WorkingSet64 / 1024 / 1024 + " MB");
echo             }
echo             catch {}
echo         }
echo     }
echo }
echo.
echo static class Program
echo {
echo     [STAThread]
echo     static void Main()
echo     {
echo         ApplicationConfiguration.Initialize();
echo         Application.Run(new MainForm());
echo     }
echo }
) > Program.cs

dotnet publish -c Release -r win-x64 --self-contained true /p:PublishSingleFile=true >nul

copy /Y bin\Release\net8.0-windows\win-x64\publish\TaskApp.exe "%DESKTOP%\task.exe"

echo Done
pause
