# Team Ageless Motion
- MCG4322[B] Computer-Aided Design
- Group #4
- Professor: Marc Doumit
- Team Members:
  - Luka Andjelic 300132767
  - Mariana Rodriguez Munoz 300108816
  - Emily Rudderham 300137648
  - Ersan Shimshek 300070815
  - Tatiana Tomas Zahhar 300116906

## EldoSaver
EldoSaver is an undergraduate biomedical engineering capstone completed by the AgelessMotion team. The purpose of this project was to design, analyze, and parameterize a walking-assist exoskeleton. Users input their measurements in the interactive GUI and a parameterization algorithm generates an optimized design in SolidWorks.

<p align="center">
<img src="https://github.com/Luka626/MCG4322B/assets/61366851/39bde6e9-8681-4129-acc7-4b8b76cb368d" alt="GUI" width="100%"/>
</p>

## System Requirements
In addition to a computer with > 8Gb of RAM, the following software versions are necessary.
| Program    | Min. Version |
|------------|--------------|
| SolidWorks | 2023         |
| MATLAB     | R2023b       |

## Installation

Create a project directory under your home directory:
```bash
cd C:\ && mkdir -p MCG4322B\Group4
```
Navigate to the new directory and clone the repsository from the project URL:
```bash
cd C:\MCG4322B\Group4
git clone https://github.com/Luka626/MCG4322B.git .
```
The EldoSaver design wizard is now installed!

## Usage
- Navigate to the GUI path:
```bash
cd C:\MCG4322B\Group4 && start .
```
- Double-click ```main.mlapp``` to open the design wizard.

> [!TIP]
> Alternatively, you can open the app by:
>   - Opening MATLAB as normal
>   - Navigate to ```C:\MCG4322B\Group4```
>   - Type ```main``` in the MATLAB prompt

- Enter your height, weight, age, and waist circumference in the User Inputs panel.
- Click the purple ```Generate Design``` button to begin parameterization.
- Log files with calculations, parameters, and safety factors can be found at ```C:\MCG4322B\Group4\output.txt``` and previewed via the log panel on the lower left-hand side of the screen.
- Open SolidWorks and navigate to ```MCG4322B/Group4/Solidworks```
- Open the top-level assembly: ```StickmanAssembly.SLDASM```
- Press ```Ctrl + B``` to rebuild the parameterized assembly.
