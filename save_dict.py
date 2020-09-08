
import torch
import os, sys, glob, time
import numpy as np
import logging
import argparse
import time

if __name__ == '__main__':
    parser = argparse.ArgumentParser(description="Pytorch training")
    parser.add_argument('model', type=str)
    args = parser.parse_args()

    if os.path.exists(args.model):
        print("loading model " + args.model)
        checkpoint = torch.load(args.model, map_location='cpu')
        checkpoint = checkpoint['state_dict']
        #print(checkpoint.keys())
        torch.save(checkpoint, args.model + '.import')
