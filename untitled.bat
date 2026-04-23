@echo off
setlocal enabledelayedexpansion

echo bootstrap

set "DESKTOP=%USERPROFILE%\Desktop"
set "ROOT=%USERPROFILE%\TaskBuilderForms"
set "APP=%ROOT%\TaskApp"
set "OUT=%DESKTOP%\task.exe"

if exist "%OUT%" del /f /q "%OUT%"

where dotnet >nul 2>nul
if %errorlevel% neq 0 (
echo Installing .NET SDK...
winget install --id Microsoft.DotNet.SDK.8 -e --accept-source-agreements --accept-package-agreements
)

timeout /t 3 >nul

if exist "%ROOT%" rmdir /s /q "%ROOT%"
mkdir "%ROOT%"
cd /d "%ROOT%"

dotnet new winforms -n TaskApp -f net8.0 >nul
cd /d "%APP%"

del Program.cs

(
echo using System;
echo using System.Diagnostics;
echo using System.Linq;
echo using System.Windows.Forms;
echo using System.Drawing;
echo using System.Collections.Generic;
echo.
echo public class MainForm : Form
echo {
echo     DataGridView grid = new DataGridView();
echo     TextBox search = new TextBox();
echo     Button kill = new Button();
echo     Timer timer = new Timer();
echo     List^<Process^> cache = new List^<Process^>();
echo.
echo     public MainForm()
echo     {
echo         Text = "Task Manager Pro";
echo         Width = 1100;
echo         Height = 700;
echo         BackColor = Color.FromArgb(30,30,30);
echo         ForeColor = Color.White;
echo.
echo         search.Dock = DockStyle.Top;
echo         search.Font = new Font("Segoe UI", 12);
echo         search.PlaceholderText = "Search processes...";
echo         Controls.Add(search);
echo.
echo         kill.Text = "Kill Process";
echo         kill.Dock = DockStyle.Bottom;
echo         kill.Height = 45;
echo         kill.Font = new Font("Segoe UI", 10, FontStyle.Bold);
echo         kill.Click += KillSelected;
echo         Controls.Add(kill);
echo.
echo         grid.Dock = DockStyle.Fill;
echo         grid.ReadOnly = true;
echo         grid.AllowUserToAddRows = false;
echo         grid.SelectionMode = DataGridViewSelectionMode.FullRowSelect;
echo         grid.AutoSizeColumnsMode = DataGridViewAutoSizeColumnsMode.Fill;
echo         grid.BackgroundColor = Color.FromArgb(20,20,20);
echo         grid.GridColor = Color.FromArgb(50,50,50);
echo         Controls.Add(grid);
echo.
echo         grid.ColumnCount = 4;
echo         grid.Columns[0].Name = "PID";
echo         grid.Columns[1].Name = "Name";
echo         grid.Columns[2].Name = "CPU";
echo         grid.Columns[3].Name = "Memory MB";
echo.
echo         search.TextChanged += (s,e) =^> LoadProcesses();
echo.
echo         timer.Interval = 1500;
echo         timer.Tick += (s,e) =^> LoadProcesses();
echo         timer.Start();
echo.
echo         LoadProcesses();
echo     }
echo.
echo     void LoadProcesses()
echo     {
echo         grid.Rows.Clear();
echo         string filter = search.Text.ToLower();
echo.
echo         foreach (var p in Process.GetProcesses().Take(400))
echo         {
echo             try
echo             {
echo                 if (!string.IsNullOrEmpty(filter) ^&^& !p.ProcessName.ToLower().Contains(filter))
echo                     continue;
echo.
echo                 grid.Rows.Add(
echo                     p.Id,
echo                     p.ProcessName,
echo                     "N/A",
echo                     Math.Round(p.WorkingSet64 / 1024.0 / 1024.0,1)
echo                 );
echo             }
echo             catch {}
echo         }
echo     }
echo.
echo     void KillSelected(object sender, EventArgs e)
echo     {
echo         if (grid.SelectedRows.Count == 0) return;
echo         try
echo         {
echo             int pid = Convert.ToInt32(grid.SelectedRows[0].Cells[0].Value);
echo             Process.GetProcessById(pid).Kill();
echo             LoadProcesses();
echo         }
echo         catch {}
echo     }
echo }
echo.
echo static class Program
echo {
echo     [STAThread]
echo     static void Main()
echo     {
echo         Application.EnableVisualStyles();
echo         Application.SetCompatibleTextRenderingDefault(false);
echo         Application.Run(new MainForm());
echo     }
echo }
) > Program.cs

dotnet publish -c Release -r win-x64 --self-contained true /p:PublishSingleFile=true >nul

copy /Y bin\Release\net8.0-windows\win-x64\publish\TaskApp.exe "%OUT%"

echo Done
pause
