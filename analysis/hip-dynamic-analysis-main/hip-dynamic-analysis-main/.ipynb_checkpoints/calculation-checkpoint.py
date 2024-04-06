#!/usr/bin/env python3

import numpy as np
from abc import abstractmethod

class Calculation:
    def __init__(self, patient, implant, title, title_long, units, ylim):
        self.title = title
        self.title_long = title_long
        self.units = units
        self.ylim = ylim
        self.output = np.empty(0)
        self.x = np.arange(1,107)
        self.x = 100*self.x/106
        self.patient = patient
        self.implant = implant

    @abstractmethod
    def calculate_output(self):
        pass
