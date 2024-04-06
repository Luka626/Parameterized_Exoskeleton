class Implant():

    def __init__(self):
        self.acetabulum = {
            'd': 53 #mm
        }
        self.cup = {
            'd': 54, #mm
            't': 54-43.68, #mm
            'v': 0.342,
            'E': 113800, #M/mm^2
            'material': 'Titanium Ti-6Al-4V'
        }

        self.liner = {
            'd': 43.58, #mm
            't': 43.58-36.05, #mm
            'E': 175000, #MPa
            'material': 'Zirconia',
            'v': 0.27,
        }

        self.head = {
            'd': 35.95,#mm
            'E': 175000, #N/mm^2
            'v': 0.27,
            'material': 'Zirconia'
        }

        self.neck = {

        }

        self.stem = {

        }
        return
