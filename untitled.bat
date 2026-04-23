@echo off
echo bootstrap

set DESKTOP=%USERPROFILE%\Desktop
set PROJECT=%USERPROFILE%\TaskBuilderWPF
set OUT=%DESKTOP%\task.exe

if exist "%OUT%" del /f /q "%OUT%"

where dotnet >nul 2>nul
if %errorlevel% neq 0 (
echo Installing .NET SDK...
winget install --id Microsoft.DotNet.SDK.8 -e --accept-source-agreements --accept-package-agreements
)

timeout /t 3 >nul

if exist "%PROJECT%" rmdir /s /q "%PROJECT%"
mkdir "%PROJECT%"
cd /d "%PROJECT%"

dotnet new wpf -n TaskApp -f net8.0 >nul
cd TaskApp

del MainWindow.xaml
del MainWindow.xaml.cs
del App.xaml.cs

(
echo ^<Window x:Class="TaskApp.MainWindow"
echo xmlns="http://schemas.microsoft.com/winfx/2006/xaml/presentation"
echo xmlns:x="http://schemas.microsoft.com/winfx/2006/xaml"
echo Title="Task Manager" Height="650" Width="1000"
echo Background="#1e1e1e"
echo Foreground="White"^>
echo ^<Grid Margin="10"^>
echo ^<Grid.RowDefinitions^>
echo ^<RowDefinition Height="Auto"/^>
echo ^<RowDefinition Height="*"/^>
echo ^</Grid.RowDefinitions^>
echo.
echo ^<TextBox Name="SearchBox" Height="30" Margin="0,0,0,10" / ^>
echo.
echo ^<DataGrid Name="Grid" Grid.Row="1" AutoGenerateColumns="False" IsReadOnly="True"/^>
echo.
echo ^</Grid^>
echo ^</Window^>
) > MainWindow.xaml

(
echo using System;
echo using System.Diagnostics;
echo using System.Linq;
echo using System.Windows;
echo using System.Windows.Controls;
echo using System.Collections.Generic;
echo.
echo namespace TaskApp
echo {
echo     public partial class MainWindow : Window
echo     {
echo         public MainWindow()
echo         {
echo             InitializeComponent();
echo             Loaded += MainWindow_Loaded;
echo             SearchBox.TextChanged += (s,e) =^> LoadProcesses();
echo         }
echo.
echo         private void MainWindow_Loaded(object sender, RoutedEventArgs e)
echo         {
echo             Grid.Columns.Add(new DataGridTextColumn { Header="PID", Binding=new System.Windows.Data.Binding("PID") });
echo             Grid.Columns.Add(new DataGridTextColumn { Header="Name", Binding=new System.Windows.Data.Binding("Name") });
echo             Grid.Columns.Add(new DataGridTextColumn { Header="Memory MB", Binding=new System.Windows.Data.Binding("Memory") });
echo.
echo             LoadProcesses();
echo         }
echo.
echo         private void LoadProcesses()
echo         {
echo             string filter = SearchBox.Text?.ToLower() ?? "";
echo             var list = new List^<object^>();
echo.
echo             foreach (var p in Process.GetProcesses().Take(300))
echo             {
echo                 try
echo                 {
echo                     if (!string.IsNullOrEmpty(filter) ^&^& !p.ProcessName.ToLower().Contains(filter))
echo                         continue;
echo.
echo                     list.Add(new
echo                     {
echo                         PID = p.Id,
echo                         Name = p.ProcessName,
echo                         Memory = (p.WorkingSet64 / 1024 / 1024)
echo                     });
echo                 }
echo                 catch { }
echo             }
echo.
echo             Grid.ItemsSource = list;
echo         }
echo     }
echo }
) > MainWindow.xaml.cs

dotnet publish -c Release -r win-x64 --self-contained true /p:PublishSingleFile=true >nul

copy /Y bin\Release\net8.0-windows\win-x64\publish\TaskApp.exe "%OUT%"

echo Done
pauseecho static class Program
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
