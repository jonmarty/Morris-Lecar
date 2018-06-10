import os

#The values for the test
inputs = {
	"C" : 6.69810502993,
	"V_1" : 30,
	"V_2" : 15,
	"V_3" : 0,
	"V_4" : 30,
	"phi" : 0.025,
	"V_L" : -50,
	"V_Ca" : 100,
	"V_K" : -70,
	"g_Ca" : 1.1,
	"g_K" : 2,
	"g_L" : 0.5,
	"V" : -52.14,
	"N" : 0.02,
	"I" : "random_current.csv"
}

#Create the command
command = ["python","MorrisLecar.py"]
for arg, val in inputs.iteritems():
	command.append("-" + arg)
	command.append(str(val))

#Execute the command
os.system(" ".join(command))
