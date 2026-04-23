@echo off
echo bootstrap

where python >nul 2>nul
if %errorlevel% neq 0 (
echo Python not found.
pause
exit /b
)

where git >nul 2>nul
if %errorlevel% neq 0 (
echo Installing Git...
winget install --id Git.Git -e --accept-source-agreements --accept-package-agreements
)

set PROJECT=%USERPROFILE%\TaskManagerBuild
set DESKTOP=%USERPROFILE%\Desktop

if not exist "%PROJECT%" mkdir "%PROJECT%"
cd /d "%PROJECT%"

if not exist venv (
python -m venv venv
)

call venv\Scripts\activate.bat

python -m pip install --upgrade pip
pip install psutil PySide6 pyinstaller

(
echo import sys
echo import psutil
echo from PySide6.QtWidgets import QApplication,QTableWidget,QTableWidgetItem,QVBoxLayout,QWidget
echo from PySide6.QtCore import QTimer
echo.
echo class TaskManager(QWidget):
echo     def __init__(self):
echo         super().__init__()
echo         self.setWindowTitle("Task")
echo         self.resize(900,550)
echo         self.table=QTableWidget()
echo         self.table.setColumnCount(4)
echo         self.table.setHorizontalHeaderLabels(["PID","Name","CPU %%","Memory MB"])
echo         layout=QVBoxLayout()
echo         layout.addWidget(self.table)
echo         self.setLayout(layout)
echo         self.timer=QTimer()
echo         self.timer.timeout.connect(self.update)
echo         self.timer.start(2000)
echo         self.update()
echo.
echo     def update(self):
echo         procs=list(psutil.process_iter(['pid','name','cpu_percent','memory_info']))
echo         self.table.setRowCount(len(procs))
echo         for r,p in enumerate(procs):
echo             mem=p.info['memory_info'].rss/(1024*1024)
echo             self.table.setItem(r,0,QTableWidgetItem(str(p.info['pid'])))
echo             self.table.setItem(r,1,QTableWidgetItem(p.info['name']))
echo             self.table.setItem(r,2,QTableWidgetItem(str(p.info['cpu_percent'])))
echo             self.table.setItem(r,3,QTableWidgetItem(f"{mem:.1f}"))
echo.
echo app=QApplication(sys.argv)
echo w=TaskManager()
echo w.show()
echo sys.exit(app.exec())
) > main.py

pyinstaller --noconfirm --onefile --windowed --name task main.py

copy /Y dist\task.exe "%DESKTOP%\task.exe"

echo Done.
pause