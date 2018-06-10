import numpy as np
import argparse

parser = argparse.ArgumentParser()
parser.add_argument("--length", "-l", type = int, help = "Output length", default = 100)
parser.add_argument("--output", "-o", type = str, help = "Output file", default = "random_current.csv")
parser.add_argument("--scale", "-s", type = np.double, help = "The scale of the random numbers", default = np.double(1.0))
parser.add_argument("--center", "-c", type = np.double, help = "The center of the random numbers", default = np.double(0.0))
args = parser.parse_args()

#Generate values for I
current = list(args.scale * np.random.random((args.length)) + args.center)
current = map(str, current)

#Send values to file
w = open(args.output, "w")
w.write("\n".join(current))
w.close()
