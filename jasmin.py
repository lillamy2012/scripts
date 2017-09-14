import os
import sys

infile = open('../Araport11_jasmin.cumulated_incl200up.downstream.bed')
for line in infile:
    a=str.split(line)
    if a[3] == "Upstream_200bp":
        a[2]=int(a[1])+199
        if a[4] == "-":
            a[3]= "Downstream_200bp"
    elif a[3] == "Downstream_200bp":
         a[1]=int(a[2])-199
         if a[4] == "-":
             a[3]= "Upstream_200bp"
    print('\t'.join(map(str,a)))
