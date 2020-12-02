
import torch
import torch.nn as nn
import torch.nn.functional as F

from gpuinfo import GPUInfo

def gpu_info():
    try:
        percent, memory = GPUInfo.gpu_usage()
    except ValueError:
        return "Error when read GPU utilization"
    return "precent: %r, memory: %r" % (percent, memory)

class conv2d(torch.autograd.Function):
    @staticmethod
    def forward(ctx, input, weight, bias, stride, padding, dilation, groups):
        #with torch.no_grad():
        x = F.conv2d(input, weight, bias, stride, padding, dilation, groups)
        ctx.save_for_backward(input, weight, bias)
        ctx.stride = stride
        ctx.padding = padding
        ctx.dilation = dilation
        ctx.groups = groups
        return x

    @staticmethod
    def backward(ctx, grad_output):
        grad_input, grad_weight, grad_bias = None, None, None
        input, weight, bias = ctx.saved_tensors
        stride = ctx.stride
        padding = ctx.padding
        dilation = ctx.dilation
        groups = ctx.groups

        if ctx.needs_input_grad[0]:
            grad_input = nn.grad.conv2d_input(input.shape, weight, grad_output, stride, padding, dilation, groups)

        if ctx.needs_input_grad[1]:
            grad_weight = nn.grad.conv2d_weight(input, weight.shape, grad_output, stride, padding, dilation, groups)

        if bias is not None and ctx.needs_input_grad[2]:
            grad_bias = grad_output.sum((0,2,3)).squeeze(0)

        return grad_input, grad_weight, grad_bias, None, None, None, None

class custom_conv(nn.Conv2d):
    def __init__(self, in_channels, out_channels, kernel_size, stride=1, padding=0, dilation=1, groups=1, bias=True):
        super(custom_conv, self).__init__(in_channels, out_channels, kernel_size, stride=stride, padding=padding, dilation=dilation, groups=groups, bias=bias)

    #def forward(self, inputs):
    #    output = conv2d.apply(inputs, self.weight, self.bias, self.stride, self.padding, self.dilation, self.groups)
    #    return output


class Model(nn.Module):
    def __init__(self):
        super(Model, self).__init__()
        nn.Conv2d = custom_conv
        self.seq = nn.Sequential(
            nn.Conv2d(64, 64, kernel_size=3, padding=1),
            nn.BatchNorm2d(64),
            nn.ReLU(True),
            nn.Conv2d(64, 64, kernel_size=3, padding=1),
            nn.BatchNorm2d(64),
            nn.ReLU(True),
            nn.Conv2d(64, 64, kernel_size=3, padding=1, bias=False),
            nn.BatchNorm2d(64),
            nn.ReLU(True),
        )

    def forward(self, x):
        x = self.seq(x)
        return x

def main():
    x = torch.rand(128,64,56,56)
    model = Model()
    x = x.cuda()
    model = model.cuda()

    y = model(x)
    z = y.sum()
    print(gpu_info())

    z.backward()
    print(gpu_info())

    import pdb
    pdb.set_trace()


if __name__ == "__main__":
    main()

