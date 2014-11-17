#!/usr/bin/python
## sitemap.py for  in /home/xide
##
## Made by Germain GAU (Billy)
## Login   <germain.gau@epitech.eu>
##
## Started on  Fri Nov 14 14:52:52 2014
## Last update Mon Nov 17 15:03:14 2014 
##

import sys
import argparse
import os

parser = argparse.ArgumentParser(description='Editeur de Sitemaps')
parser.add_argument('-i', '--input', nargs = 1, help='Input folder / default : current folder')
parser.add_argument('-r', '--recursive', action='store_true', help='Recursive mode')
#parser.add_argument('-o', '--output', nargs = 1, help='Output file path')
#parser.add_argument('--https', action='store_true', help='Convert selected sitemap to https')
#parser.add_argument('-m', '--mobile', action='store_true', help='Convert selected sitemap to mobile')

namespace = parser.parse_args(sys.argv[1:])
def f(path):
    for a in os.listdir(path):
        if namespace.recursive and os.path.isdir(a):
            f(a)
        if '.xml' in a and not 'https' in a:
            print 'XML file found : {}.'.format(a)
            with open(a, 'r') as sitemap:
                raw = sitemap.read()
                if raw is not None:
                    fmt = raw[:raw.index('<url>')] + raw[raw.index('<url>'):].replace('http:', 'https:')
                    with open(str(a).split('.')[0] + 'https.xml' , 'w') as sitemap:
                        sitemap.write(fmt)
if namespace.input is not None:
    f(namespace.input[0])
else:
    f(os.getcwd())
#    if namespace.mobile == True:
 #       reg = re.sub('(\.com|\.fr|\.net)/)', 
#        reg = re.sub(r"/?P<1>\.html", '/m-\g<1>|.html', raw ,re.IGNORECASE)
#        print reg
        #raw = re.sub(, '/m-')
#    print raw
