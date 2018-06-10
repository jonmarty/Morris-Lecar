import numpy as np
import argparse

parser = argparse.ArgumentParser()
parser.add_argument("--length", "-l", type = int, help = "Output length", default = 100)
parser.add_argument("--output", "-o", type = str, help = "Output file", default = "static_current.csv")
parser.add_argument("--value", "-v", type = float, help = "Value of I", default = 1)
args = parser.parse_args()

#Generate values for I
current = [args.value for _ in range(args.length)]
current = map(str, current)

#Send values to file
w = open(args.output, "w")
w.write("\n".join(current))
w.close()
