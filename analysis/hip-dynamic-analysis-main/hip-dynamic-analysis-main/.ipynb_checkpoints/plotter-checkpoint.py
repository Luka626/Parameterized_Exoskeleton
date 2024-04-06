#!/usr/bin/env python3
from matplotlib import pyplot as plt
import numpy as np

class Plotter:

    def __init__(self):
        plt.style.use("bmh")
        plt.rcParams['figure.figsize'] = [12, 8]
        self.bbox = 'tight' # 'tight' or None
        

    def plot_output(self, calculation, patient_comparison=None):
        plt.clf()
        plt.figure(num=calculation.title)

        plt.title(calculation.title_long)
        plt.xlabel("Gait Cycle (%)")
        plt.ylabel("{} ({})".format(calculation.title, calculation.units))
        plt.grid(axis = 'y')

        plt.scatter(x=calculation.x, y=calculation.output)
        self.callout(calculation=calculation)
        if patient_comparison:
           plt.scatter(x=calculation.x, y=patient_comparison.output)
         
        if patient_comparison:
            plt.legend(['Healthy Patient','Injured Patient'])
        else:
            plt.legend(['Healthy Patient'])

        plt.ylim(calculation.ylim)
        plt.savefig(calculation.title_long, bbox_inches=self.bbox)

    def callout(self, calculation, ax=None):
        ymin, ymax = min(calculation.output), max(calculation.output)
        xpos_min, xpos_max = np.argmin(calculation.output), np.argmax(calculation.output)
        x_min, x_max = calculation.x[xpos_min], calculation.x[xpos_max]
        text_min = "Frame {:.0f}, {:.3f} {units}".format(xpos_min+1, ymin, units=calculation.units)
        text_max = "Frame {:.0f}, {:.3f} {units}".format(xpos_max+1, ymax, units=calculation.units)
        
        if not ax:
            ax=plt.gca()

        bbox_props = dict(boxstyle="square,pad=0.3", fc="w", ec="k", lw=0.72)

        arrowprops=dict(
                arrowstyle="->",
                connectionstyle="angle,angleA=0,angleB=90",
                color='k')

        kw = dict(
                xycoords='data',
                textcoords="axes fraction",
                arrowprops=arrowprops,
                bbox=bbox_props,
                ha="right",
                va="top")

        plt.annotate(text_max, xy=(x_max, ymax), xytext=(0.4,0.94), **kw)
        plt.annotate(text_min, xy=(x_min, ymin), xytext=(0.75,0.06), **kw)
