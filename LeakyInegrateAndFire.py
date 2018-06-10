import numpy as np
import argparse

parser = argparse.ArgumentParser()

#Voltage
parser.add_argument("--rest-potential", "-u_rest", type = np.double)
parser.add_argument("--reset-potential" , "-u_reset", type = np.double)
parser.add_argument("--potential", "-u", type = np.double)
parser.add_argument("--threahold", "-t", type = np.double)
parser.add_argument("--capacitance", "-C", type = np.double)
parser.add_argument("--resistance", "-R", type = np.double)

#Time constant
T_m = R * C

#Some equations
u_R = lambda: u - u_rest
I_R = lambda: u_R() / R

#Change in membrane potential
du = lambda: (-u_R + R * I)/T_m

u = lambda: u_rest + R * I_0 * (1 - np.exp(-t/T_m))
I_C = lambda: C * du()

