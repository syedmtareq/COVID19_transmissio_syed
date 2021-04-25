import os, fnmatch
import re

debug = 1
filebatchshell = "submit_PBS.sh"
fshell = open(filebatchshell, "w")

inputfiles =  fnmatch.filter(os.listdir('counties/'), '*.csv')

step = 1

for i in range(1, (len(inputfiles) + 1), step):
    fin = open("templates/epinow_teamplate.pbs", "r")
    LinesIn = fin.readlines()
    fin.close()
    LinesIn[2] = "#$ -N epi_job"  + str(i) + "\n"

    LinesIn[8] = "R -f batch_Rt_by_county.R --args " + str(i) + " " + str(i+ step - 1) + " 1 4/1/2020" + " " + "10/25/2020" + "\n"

    fileout = "PBS/ts_" + str(i) + "_" + str(i+1) +  ".pbs"
    fout = open(fileout, "w")
    for line in LinesIn:
        fout.write(line)
    fout.close()

    buffer = "qsub " + fileout + "\n"
    fshell.write(buffer)

fshell.close()



