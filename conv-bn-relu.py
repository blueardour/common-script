
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

class custom_norm_relu(torch.autograd.Function):
    @staticmethod
    def forward(ctx, input, weight, bias, running_var, running_mean, eps):
        scale = weight * (running_var + eps).rsqrt()
        if bias is not None:
            bias = bias - running_mean * scale
        else:
            bias = - running_mean * scale
        scale = scale.reshape(1, -1, 1, 1).detach()
        bias = bias.reshape(1, -1, 1, 1).detach()
        weight = weight.reshape(1, -1, 1, 1).detach()
        result = input * scale + bias

        select = result < 0.0
        result.masked_fill_(select, 0.0) # ReLU

        ctx.save_for_backward(result, weight, bias, scale, select)
        #ctx.mark_dirty(result)
        return result # input of next conv layer

    @staticmethod
    def backward(ctx, grad_output):
        grad_input, grad_weight, grad_bias = None, None, None
        ouput, weight, bias, scale, select, = ctx.saved_tensors
        grad_output.masked_fill_(select, 0.0)

        if ctx.needs_input_grad[0]:
            grad_input = grad_output * scale

        if ctx.needs_input_grad[1]:
            grad_weight = grad_output * (ouput - bias).div(weight)
            grad_weight = grad_weight.sum(dim=[0,2,3])

        if ctx.needs_input_grad[2]:
            grad_bias = grad_output.sum(dim=[0,2,3])

        return grad_input, grad_weight, grad_bias, None, None, None

class BatchNorm2d_ReLU(torch.nn.Module):
    """
    BatchNorm2d and ReLU in one Module
    """
    def __init__(self, num_features, eps=1e-5):
        super().__init__()
        self.eps = eps
        self.weight = torch.nn.Parameter(torch.ones(num_features), requires_grad=True)
        self.bias = torch.nn.Parameter(torch.zeros(num_features), requires_grad=True)
        self.register_buffer("running_mean", torch.zeros(num_features))
        self.register_buffer("running_var", torch.ones(num_features) - eps)
        self.fn = custom_norm_relu.apply

    def forward(self, x):
        # To do
        # compute self.running_mean and self.running_var here, omit temporarily
        return self.fn(x, self.weight, self.bias, self.running_var, self.running_mean, self.eps)

class conv2d(torch.autograd.Function):
    @staticmethod
    def forward(ctx, input, weight, bias, stride, padding, dilation, groups):
        with torch.no_grad():
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

    def forward(self, inputs):
        output = conv2d.apply(inputs, self.weight, self.bias, self.stride, self.padding, self.dilation, self.groups)
        return output


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
    x = torch.rand(512,64,56,56)
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

