
import logging
import torch
import torch.nn as nn
import torch.nn.functional as F

class demo(torch.autograd.Function):
    @staticmethod
    def forward(ctx, inputs, basis):
        return y, basis

    @staticmethod
    def backward(ctx, grad_output, grad_basis):
        return grad_input, None, None, None, None, None, None, None, None



