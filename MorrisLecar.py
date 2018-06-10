import numpy as np
import argparse

#Argument parser for ease of use
parser = argparse.ArgumentParser()

#Capacitance
parser.add_argument("--capacitance", "-C", type = np.double)

#Conductance through menbranes channel
parser.add_argument("--conductance_L", "-g_L", type = np.double)
parser.add_argument("--conductance_Ca", "-g_Ca", type = np.double)
parser.add_argument("--conductance_K", "-g_K", type = np.double)

#Equilibrium potential of relevant ion channels
parser.add_argument("--potential_L", "-V_L", type = np.double)
parser.add_argument("--potential_Ca", "-V_Ca", type = np.double)
parser.add_argument("--potential_K", "-V_K", type = np.double)

#Tuning parameters for steady state and time constant
parser.add_argument("--tuning_1", "-V_1", type = np.double)
parser.add_argument("--tuning_2", "-V_2", type = np.double)
parser.add_argument("--tuning_3", "-V_3", type = np.double)
parser.add_argument("--tuning_4", "-V_4", type = np.double)

#Reference frequency
parser.add_argument("--frequency", "-phi", type = np.double)

#Initial values of variables
parser.add_argument("--potential", "-V", type = np.double)
parser.add_argument("--recovery", "-N", type = np.double)

#File for Current Values
parser.add_argument("--current", "-I", type = str)

#Number of steps
parser.add_argument("--steps", "-t", type = int)

#Extract variables
args = parser.parse_args()
C = args.capacitance
g_L = args.conductance_L
g_Ca = args.conductance_Ca
g_K = args.conductance_K
V_L = args.potential_L
V_Ca = args.potential_Ca
V_K = args.potential_K
V_1 = args.tuning_1
V_2 = args.tuning_2
V_3 = args.tuning_3
V_4 = args.tuning_4
phi = args.frequency
V = args.potential
N = args.recovery
current_file = args.current
steps = args.steps


#Define functions
M_ss = lambda: (1/2) * (1 + np.tanh((V - V_1) / V_2))
N_ss = lambda: (1/2) * (1 + np.tanh((V - V_3) / V_4))
T_N = lambda: 1 / (phi * np.cosh((V - V_3) / (2 * V_4)))

#Define differential equations
dV = lambda I: (I - g_L * (V - V_L) - g_Ca * M_ss() * (V - V_Ca) - g_K * N * (V - V_K)) / C
dN = lambda: (N_ss() - N) / T_N()

#Load current data from file
current = map(np.float64, open(current_file, "r").read().split("\n"))

print("current", current)

#Equations for the input of each channel
L = lambda: - g_L * (V - V_L)
Ca = lambda: - g_Ca * M_ss() * (V - V_Ca)
K = lambda: - g_K * N * (V - V_K)

for t, I in zip(range(len(current)), current):
	#Update variables
	print(I - 100000)
	print(map(type, [I, g_L, V, V_L, g_Ca, M_ss(), V_Ca, g_K, N, V_K, C]))
	V = V + dV(I)
	N = N + dN()
	#Print out important values
	print("t: %i" % t)
	print("I: %f" % I)
	print("V: %f" % V)
	print("N: %f" % N)
	print("L: %f" % L())
	print("Ca: %f" % Ca())
	print("K: %f" % K())
	print("N_ss: %f" % N_ss())
	print("T_N: %f" % T_N())
