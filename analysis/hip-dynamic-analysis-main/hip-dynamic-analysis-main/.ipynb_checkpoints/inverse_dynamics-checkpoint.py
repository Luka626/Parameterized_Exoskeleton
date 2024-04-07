#!/usr/bin/env python3

from patient import Patient
import numpy as np
from numpy import pi as PI
from copy import deepcopy
from plotter import Plotter
from calculation import Calculation
from implant import Implant
# [x,y,z]
# Negative moment is clockwise, positive moment is counterclockwise
# Y positive is up, X positive is to the right

#--- DEFINE ALL THE CALCULATIONS WE WILL DO ---#
class StandardCP(Calculation):
    def calculate_output(self, component, rx, ry):
        resultant = (rx**2+ry**2)**(1/2)
        area = 4*PI*(component['d']/2)**2
        self.output = resultant/area

class HertzCP(Calculation):
    def calculate_output(self, c1, c2, rx, ry):
        resultant = (rx**2 + ry**2)**(1/2)
        d1 = c1['d'] - c1['t']
        d2 = c2['d']

        Cg = (d1*d2)/(d1-d2)
        Cm = (1-c1['v']**2)/c1['E'] + (1-c2['v']**2)/c2['E']
        a = 0.721*(resultant*Cg*Cm)**(1/3)
        Pmax = 1.5*resultant/(PI*(a)**2)
        self.output =Pmax


# we are using 100kg, 1.65645m
# winters' uses 56.7kg, 1.73m
patient_mass = 100 
patient_height = 1.65645


#instantiate plotter object to make all graphs
plotter = Plotter()

#initialize two patient objects, identical but with healthy v. injured dynamic experimental data
healthy_elder = Patient(
        mass=patient_mass,
        height=patient_height,
        winters_data='data_healthy.csv')

injured_elder = Patient(
        mass=patient_mass,
        height=patient_height,
        winters_data='data_injured.csv')

#define important geometry of our implant in implant.py
implant = Implant()

#Initialize basic inverse dynamics calculations
rx_healthy = Calculation(
        patient = healthy_elder,
        implant = implant,
        title = "Rx",
        title_long = "Dynamic Analysis: Hip X Reaction Forces",
        ylim = [-175,150],
        units = "N")
rx_injured = deepcopy(rx_healthy)
rx_injured.patient = injured_elder

ry_healthy = Calculation(
        patient = healthy_elder,
        implant=implant,
        title = "Ry",
        title_long= "Dynamic Analysis: Hip Y Reaction Forces",
        ylim = [-590,250],
        units = "N")
ry_injured = deepcopy(ry_healthy)
ry_injured.patient = injured_elder

rnet_healthy = Calculation(
        patient = healthy_elder,
        implant = implant,
        title = "R",
        title_long = "Dynamic Analysis: Resultant Hip Reaction Force",
        ylim = [-100,600],
        units = "N")
rnet_injured = deepcopy(rnet_healthy)
rnet_injured.patient = injured_elder

m_healthy = Calculation(
        patient=healthy_elder,
        implant=implant,
        title = "M",
        title_long= "Dynamic Analysis: Hip Reaction Moments",
        ylim = [-120,70],
        units = "N*m")
m_injured = deepcopy(m_healthy)
m_injured.patient = injured_elder

shell_cp = StandardCP(
        patient=healthy_elder,
        implant=implant,
        title = "σ",
        title_long = "Dynamic Analysis: Shell Compressive Stress",
        ylim = [-0.02,0.08],
        units = "MPa"
)
liner_cp = deepcopy(shell_cp)
liner_cp.title_long = "Dynamic Analysis: Liner Compressive Stress"
liner_cp.ylim = [-0.02,0.1]

hertz_head_liner = HertzCP(
        patient=healthy_elder,
        implant=implant,
        title = "σ",
        title_long = "Dynamic Analysis: Hertz Contact Stress (Head-Liner)",
        units = "MPa",
        ylim = [0,35])

Rnet = 0
Rnet_index = 0
#compute inverse dynamics for both patients:
for index,_ in enumerate(rx_healthy.x):

    #resolve GRFs into Hip {"Rx": int, "Ry": int, "Rz" : int}
    inverse_dynamics_healthy = healthy_elder.compute_inverse_dynamics(index+1)
    inverse_dynamics_injured = injured_elder.compute_inverse_dynamics(index+1)

    #store healthy data in Calculation.output
    rx_healthy.output = np.append(rx_healthy.output, inverse_dynamics_healthy['Rx'])
    ry_healthy.output = np.append(ry_healthy.output,inverse_dynamics_healthy['Ry'])
    m_healthy.output = np.append(m_healthy.output, inverse_dynamics_healthy['M'])

    #store injured data in Calculation.output
    rx_injured.output = np.append(rx_injured.output, inverse_dynamics_injured['Rx'])
    ry_injured.output = np.append(ry_injured.output, inverse_dynamics_injured['Ry'])
    m_injured.output = np.append(m_injured.output, inverse_dynamics_injured['M'])
    Rnet_healthy = (inverse_dynamics_healthy['Rx']**2 + inverse_dynamics_healthy['Ry']**2)**(1/2)
    Rnet_injured = (inverse_dynamics_injured['Rx']**2 + inverse_dynamics_injured['Ry']**2)**(1/2)
    rnet_healthy.output = np.append(rnet_healthy.output, Rnet_healthy)
    rnet_injured.output = np.append(rnet_injured.output, Rnet_injured)


shell_cp.calculate_output(implant.cup, rx_healthy.output, ry_healthy.output)
liner_cp.calculate_output(implant.liner, rx_healthy.output, ry_healthy.output)
hertz_head_liner.calculate_output(implant.liner, implant.head, rx_healthy.output, ry_healthy.output)
#plot both against each other
plotter.plot_output(calculation=rx_healthy, patient_comparison=rx_injured)
plotter.plot_output(calculation=ry_healthy, patient_comparison=ry_injured)
plotter.plot_output(calculation=m_healthy, patient_comparison=m_injured)
plotter.plot_output(calculation=rnet_healthy, patient_comparison=rnet_injured)
plotter.plot_output(calculation=liner_cp)
plotter.plot_output(calculation=shell_cp)

plotter.plot_output(calculation=hertz_head_liner)

#now for all of our inverse dynamics outputs, we can 
