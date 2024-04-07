#!/usr/bin/env python3
import csv
import numpy as np
from constants import G


class Patient:

    def __init__(self,winters_data,mass,height):

        #initialize patient properties
        self.mass = mass        #kg
        self.height = height    #m

        #initialize dynamic analysis data to a dict
        self.dynamic = {}
        with open(winters_data, mode='r') as file:
            csv_reader = csv.DictReader(file)
            for row in csv_reader:
                frame = int(row['Frame'])
                del row['Frame']
                for key, value in row.items():
                    row[key] = float(value)
                self.dynamic[frame] = row


        #initialize anthropometric data from model
        self.L_foot = 0.152*self.height
        self.L_shank = (0.285-0.039)*self.height
        self.L_thigh = (0.53-0.285)*self.height
        self.m_foot = 0.0145*self.mass
        self.m_shank = 0.0465*self.mass
        self.m_thigh = 0.1*self.mass
        self.w_foot = self.m_foot*G
        self.w_shank = self.m_shank*G
        self.w_thigh = self.m_thigh*G
        
        
        
    def compute_inverse_dynamics(self,frame):
        d = self.dynamic[frame] #d for data

        #geometry
        GRF_pos = [d["GroundCoFPX"],0]
        Ankle_pos = [d["AnkleX"]/100,d["AnkleY"]/100]
        Foot_CoM_pos = [d["FootCoMX"],d["FootCoMY"]]
        Knee_pos = [d["KneeX"]/100,d["KneeY"]/100]
        Leg_CoM_pos = [d["LegCoMX"],d["LegCoMY"]]
        Hip_pos = [d["HipX"]/100,d["HipY"]/100]
        Thigh_CoM_pos = [d["ThighCoMX"],d["ThighCoMY"]]

        #ankle frame
        F_ankle = [self.m_foot*d["FootAX"]-d["GroundRX"], self.m_foot*d["FootAY"]-self.w_foot-d["GroundRY"]]
        GRF = [100*d["GroundRX"]/56.7,100*d["GroundRY"]/56.7] # x100 /56.7 to normalize for the patient weight

        I_foot = ((0.475*self.L_foot)**2)*self.m_foot
        M_ankle = d["FootAA"]*I_foot - np.cross(F_ankle,np.subtract(Foot_CoM_pos,Ankle_pos)) - np.cross(GRF,np.subtract(Foot_CoM_pos,GRF_pos))

        #leg frame
        F_ankle = np.multiply(F_ankle,-1)
        M_ankle = M_ankle*-1

        F_knee = [self.m_shank*d["LegAX"]-F_ankle[0], self.m_shank*d["LegAY"]-self.w_shank-F_ankle[1]]

        I_shank = ((0.302*self.L_shank)**2)*self.m_shank
        M_knee = d["LegAA"]*I_shank - np.cross(F_ankle,np.subtract(Leg_CoM_pos,Ankle_pos)) - np.cross(F_knee,np.subtract(Leg_CoM_pos,Knee_pos)) - M_ankle

        #thigh frame
        F_knee = np.multiply(F_knee,-1)
        M_knee = M_knee*-1

        F_hip = [self.m_thigh*d["ThighAX"]-F_knee[0], self.m_thigh*d["ThighAY"]-self.w_thigh-F_knee[1]]

        I_thigh = ((0.323*self.L_thigh)**2)*self.m_thigh
        M_hip = d["ThighAA"]*I_thigh - np.cross(F_knee,np.subtract(Thigh_CoM_pos,Knee_pos)) - np.cross(F_hip,np.subtract(Thigh_CoM_pos,Hip_pos)) - M_knee

        return {'Rx': F_hip[0], 'Ry': F_hip[1], 'M': M_hip}


